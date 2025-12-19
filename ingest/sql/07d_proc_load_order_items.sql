USE ROLE R_DEV_INGEST;
USE WAREHOUSE WH_DEV_LOAD_XS;
USE DATABASE RAW_DEV;
USE SCHEMA UTIL;

CREATE OR REPLACE PROCEDURE SP_LOAD_ORDER_ITEMS_BRONZE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Load all order_items files from the stage path
  COPY INTO RAW_DEV.BRONZE.ORDER_ITEMS_BRONZE
  (
    order_item_id, order_id, product_id, quantity, unit_price,
    created_at, updated_at,
    _source_file, _source_row_num
  )
  FROM (
    SELECT
      $1::NUMBER,
      $2::NUMBER,
      $3::NUMBER,
      $4::NUMBER,
      $5::NUMBER(10,2),
      $6::TIMESTAMP_NTZ,
      $7::TIMESTAMP_NTZ,
      METADATA$FILENAME        AS _source_file,
      METADATA$FILE_ROW_NUMBER AS _source_row_num
    FROM @RAW_DEV.LANDING.STG_CSV_LANDING/order_items/
  )
  FILE_FORMAT = (FORMAT_NAME = RAW_DEV.LANDING.FF_CSV_STANDARD)
  ON_ERROR = 'CONTINUE'
  PATTERN = '.*';

  -- Log files that were just loaded, using COPY_HISTORY
  INSERT INTO RAW_DEV.UTIL.FILE_LOAD_LOG (
    file_name, stage_path, dataset, loaded_at, rows_loaded, status, error_message
  )
  SELECT
    f.filename       AS file_name,
    'order_items/'   AS stage_path,
    'order_items'    AS dataset,
    f.last_load_time AS loaded_at,
    f.row_count      AS rows_loaded,
    'SUCCESS'        AS status,
    NULL             AS error_message
  FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
      table_name => 'RAW_DEV.BRONZE.ORDER_ITEMS_BRONZE',
      start_time => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
  ) f
  WHERE f.filename LIKE '%/order_items/%'
    AND NOT EXISTS (
      SELECT 1
      FROM RAW_DEV.UTIL.FILE_LOAD_LOG l
      WHERE l.dataset = 'order_items'
        AND l.file_name = f.filename
        AND l.status = 'SUCCESS'
    );

  RETURN 'OK';
END;
$$;
