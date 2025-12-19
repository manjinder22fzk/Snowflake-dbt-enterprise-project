USE ROLE R_DEV_INGEST;
USE WAREHOUSE WH_DEV_LOAD_XS;
USE DATABASE RAW_DEV;
USE SCHEMA UTIL;

CREATE OR REPLACE PROCEDURE SP_LOAD_CUSTOMERS_BRONZE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Load all files from the stage path
  COPY INTO RAW_DEV.BRONZE.CUSTOMERS_BRONZE
  (
    customer_id, first_name, last_name, email, phone, country,
    created_at, updated_at, is_deleted,
    _source_file, _source_row_num
  )
  FROM (
    SELECT
      $1::NUMBER,
      $2::STRING,
      $3::STRING,
      $4::STRING,
      $5::STRING,
      $6::STRING,
      $7::TIMESTAMP_NTZ,
      $8::TIMESTAMP_NTZ,
      $9::BOOLEAN,
      METADATA$FILENAME AS _source_file,
      METADATA$FILE_ROW_NUMBER AS _source_row_num
    FROM @RAW_DEV.LANDING.STG_CSV_LANDING/customers/
  )
  FILE_FORMAT = (FORMAT_NAME = RAW_DEV.LANDING.FF_CSV_STANDARD)
  ON_ERROR = 'CONTINUE'
  PATTERN = '.*';

  -- Log files that were just loaded, using COPY_HISTORY for this table
  INSERT INTO RAW_DEV.UTIL.FILE_LOAD_LOG (
    file_name, stage_path, dataset, loaded_at, rows_loaded, status, error_message
  )
  SELECT
    f.filename                         AS file_name,
    'customers/'                       AS stage_path,
    'customers'                        AS dataset,
    f.last_load_time                   AS loaded_at,
    f.row_count                        AS rows_loaded,
    'SUCCESS'                          AS status,
    NULL                               AS error_message
  FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
      table_name => 'RAW_DEV.BRONZE.CUSTOMERS_BRONZE',
      start_time => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
  ) f
  WHERE f.filename LIKE '%/customers/%'
    AND NOT EXISTS (
      SELECT 1
      FROM RAW_DEV.UTIL.FILE_LOAD_LOG l
      WHERE l.dataset = 'customers'
        AND l.file_name = f.filename
        AND l.status = 'SUCCESS'
    );

  RETURN 'OK';
END;
$$;
