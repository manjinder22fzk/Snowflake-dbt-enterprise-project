USE ROLE R_DEV_INGEST;
USE WAREHOUSE WH_DEV_LOAD_XS;
USE DATABASE RAW_DEV;
USE SCHEMA UTIL;

CREATE OR REPLACE PROCEDURE SP_LOAD_ORDERS_BRONZE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Load all order files from the stage path
  COPY INTO RAW_DEV.BRONZE.ORDERS_BRONZE
  (
    order_id, customer_id, order_ts, status, currency,
    created_at, updated_at, is_deleted,
    _source_file, _source_row_num
  )
  FROM (
    SELECT
      $1::NUMBER,
      $2::NUMBER,
      $3::TIMESTAMP_NTZ,
      $4::STRING,
      $5::STRING,
      $6::TIMESTAMP_NTZ,
      $7::TIMESTAMP_NTZ,
      $8::BOOLEAN,
      METADATA$FILENAME        AS _source_file,
      METADATA$FILE_ROW_NUMBER AS _source_row_num
    FROM @RAW_DEV.LANDING.STG_CSV_LANDING/orders/
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
    'orders/'        AS stage_path,
    'orders'         AS dataset,
    f.last_load_time AS loaded_at,
    f.row_count      AS rows_loaded,
    'SUCCESS'        AS status,
    NULL             AS error_message
  FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
      table_name => 'RAW_DEV.BRONZE.ORDERS_BRONZE',
      start_time => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
  ) f
  WHERE f.filename LIKE '%/orders/%'
    AND NOT EXISTS (
      SELECT 1
      FROM RAW_DEV.UTIL.FILE_LOAD_LOG l
      WHERE l.dataset = 'orders'
        AND l.file_name = f.filename
        AND l.status = 'SUCCESS'
    );

  RETURN 'OK';
END;
$$;
