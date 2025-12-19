USE ROLE {{ deploy_role }};
USE WAREHOUSE {{ load_wh }};
USE DATABASE {{ raw_db }};
USE SCHEMA {{ util_schema }};

CREATE OR REPLACE TABLE FILE_LOAD_LOG (
  file_name      STRING,
  stage_path     STRING,
  dataset        STRING,
  loaded_at      TIMESTAMP_NTZ,
  rows_loaded    NUMBER,
  status         STRING,
  error_message  STRING
);

CREATE OR REPLACE VIEW VW_FILE_LOAD_LOG_LATEST AS
SELECT *
FROM FILE_LOAD_LOG
QUALIFY ROW_NUMBER() OVER (PARTITION BY dataset ORDER BY loaded_at DESC) = 1;
