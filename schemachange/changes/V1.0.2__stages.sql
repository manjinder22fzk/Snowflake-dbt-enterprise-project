USE ROLE {{ deploy_role }};
USE WAREHOUSE {{ load_wh }};
USE DATABASE {{ raw_db }};
USE SCHEMA {{ landing_schema }};

CREATE OR REPLACE STAGE {{ stage_name }}
  FILE_FORMAT = {{ file_format_name }};
