USE ROLE R_DEV_INGEST;
USE WAREHOUSE WH_DEV_LOAD_XS;
USE DATABASE RAW_DEV;
USE SCHEMA UTIL;


-- File ledger: prevents re-loading same file again
CREATE OR REPLACE TABLE UTIL.FILE_LOAD_LOG (
  file_name          STRING,
  stage_path         STRING,
  dataset            STRING,
  loaded_at          TIMESTAMP_NTZ,
  rows_loaded        NUMBER,
  status             STRING,
  error_message      STRING
);

-- Helpful view for quick monitoring
CREATE OR REPLACE VIEW UTIL.VW_FILE_LOAD_LOG_LATEST AS
SELECT *
FROM UTIL.FILE_LOAD_LOG
QUALIFY ROW_NUMBER() OVER (PARTITION BY dataset ORDER BY loaded_at DESC) = 1;
