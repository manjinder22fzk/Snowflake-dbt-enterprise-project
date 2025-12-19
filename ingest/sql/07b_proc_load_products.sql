USE ROLE R_DEV_INGEST;
USE WAREHOUSE WH_DEV_LOAD_XS;
USE DATABASE RAW_DEV;
USE SCHEMA UTIL;

CREATE OR REPLACE PROCEDURE SP_LOAD_PRODUCTS_BRONZE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Load all product files from the stage path
  COPY INTO RAW_DEV.BRONZE.PRODUCTS_BRONZE
  (
    product_id, product_name, category, price,
    created_at, updated_at, is_active,
    _source_file, _source_row_num
  )
  FROM (
    SELECT
      $1::NUMBER,
      $2::STRING,
      $3::STRING,
      $4::NUMBER(10,2),
      $5::TIMESTAMP_NTZ,
      $6::TIMESTAMP_NTZ,
      $7::BOOLEAN,
      METADATA$FILENAME       AS _source_file,
      METADATA$FILE_ROW_NUMBER AS _source_row_num
    FROM @RAW_DEV.LANDING.STG_CSV_LANDING/products/
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
    'products/'      AS stage_path,
    'products'       AS dataset,
    f.last_load_time AS loaded_at,
    f.row_count      AS rows_loaded,
    'SUCCESS'        AS status,
    NULL             AS error_message
  FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
      table_name => 'RAW_DEV.BRONZE.PRODUCTS_BRONZE',
      start_time => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
  ) f
  WHERE f.filename LIKE '%/products/%'
    AND NOT EXISTS (
      SELECT 1
      FROM RAW_DEV.UTIL.FILE_LOAD_LOG l
      WHERE l.dataset = 'products'
        AND l.file_name = f.filename
        AND l.status = 'SUCCESS'
    );

  RETURN 'OK';
END;
$$;
