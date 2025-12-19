USE ROLE {{ deploy_role }};
USE WAREHOUSE {{ load_wh }};
USE DATABASE {{ raw_db }};
USE SCHEMA {{ util_schema }};

CREATE OR REPLACE PROCEDURE SP_LOAD_CUSTOMERS_BRONZE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  COPY INTO {{ raw_db }}.{{ bronze_schema }}.CUSTOMERS_BRONZE
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
    FROM @{{ raw_db }}.{{ landing_schema }}.{{ stage_name }}/customers/
  )
  FILE_FORMAT = (FORMAT_NAME = {{ raw_db }}.{{ landing_schema }}.{{ file_format_name }})
  ON_ERROR = 'CONTINUE'
  PATTERN = '.*';

  INSERT INTO {{ raw_db }}.{{ util_schema }}.FILE_LOAD_LOG (
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
      table_name => '{{ raw_db }}.{{ bronze_schema }}.CUSTOMERS_BRONZE',
      start_time => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
  ) f
  WHERE f.filename LIKE '%/customers/%'
    AND NOT EXISTS (
      SELECT 1
      FROM {{ raw_db }}.{{ util_schema }}.FILE_LOAD_LOG l
      WHERE l.dataset = 'customers'
        AND l.file_name = f.filename
        AND l.status = 'SUCCESS'
    );

  RETURN 'OK';
END;
$$;


CREATE OR REPLACE PROCEDURE SP_LOAD_PRODUCTS_BRONZE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  COPY INTO {{ raw_db }}.{{ bronze_schema }}.PRODUCTS_BRONZE
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
      METADATA$FILENAME AS _source_file,
      METADATA$FILE_ROW_NUMBER AS _source_row_num
    FROM @{{ raw_db }}.{{ landing_schema }}.{{ stage_name }}/products/
  )
  FILE_FORMAT = (FORMAT_NAME = {{ raw_db }}.{{ landing_schema }}.{{ file_format_name }})
  ON_ERROR = 'CONTINUE'
  PATTERN = '.*';

  INSERT INTO {{ raw_db }}.{{ util_schema }}.FILE_LOAD_LOG (
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
      table_name => '{{ raw_db }}.{{ bronze_schema }}.PRODUCTS_BRONZE',
      start_time => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
  ) f
  WHERE f.filename LIKE '%/products/%'
    AND NOT EXISTS (
      SELECT 1
      FROM {{ raw_db }}.{{ util_schema }}.FILE_LOAD_LOG l
      WHERE l.dataset = 'products'
        AND l.file_name = f.filename
        AND l.status = 'SUCCESS'
    );

  RETURN 'OK';
END;
$$;


CREATE OR REPLACE PROCEDURE SP_LOAD_ORDERS_BRONZE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  COPY INTO {{ raw_db }}.{{ bronze_schema }}.ORDERS_BRONZE
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
      METADATA$FILENAME AS _source_file,
      METADATA$FILE_ROW_NUMBER AS _source_row_num
    FROM @{{ raw_db }}.{{ landing_schema }}.{{ stage_name }}/orders/
  )
  FILE_FORMAT = (FORMAT_NAME = {{ raw_db }}.{{ landing_schema }}.{{ file_format_name }})
  ON_ERROR = 'CONTINUE'
  PATTERN = '.*';

  INSERT INTO {{ raw_db }}.{{ util_schema }}.FILE_LOAD_LOG (
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
      table_name => '{{ raw_db }}.{{ bronze_schema }}.ORDERS_BRONZE',
      start_time => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
  ) f
  WHERE f.filename LIKE '%/orders/%'
    AND NOT EXISTS (
      SELECT 1
      FROM {{ raw_db }}.{{ util_schema }}.FILE_LOAD_LOG l
      WHERE l.dataset = 'orders'
        AND l.file_name = f.filename
        AND l.status = 'SUCCESS'
    );

  RETURN 'OK';
END;
$$;


CREATE OR REPLACE PROCEDURE SP_LOAD_ORDER_ITEMS_BRONZE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  COPY INTO {{ raw_db }}.{{ bronze_schema }}.ORDER_ITEMS_BRONZE
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
      METADATA$FILENAME AS _source_file,
      METADATA$FILE_ROW_NUMBER AS _source_row_num
    FROM @{{ raw_db }}.{{ landing_schema }}.{{ stage_name }}/order_items/
  )
  FILE_FORMAT = (FORMAT_NAME = {{ raw_db }}.{{ landing_schema }}.{{ file_format_name }})
  ON_ERROR = 'CONTINUE'
  PATTERN = '.*';

  INSERT INTO {{ raw_db }}.{{ util_schema }}.FILE_LOAD_LOG (
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
      table_name => '{{ raw_db }}.{{ bronze_schema }}.ORDER_ITEMS_BRONZE',
      start_time => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
  ) f
  WHERE f.filename LIKE '%/order_items/%'
    AND NOT EXISTS (
      SELECT 1
      FROM {{ raw_db }}.{{ util_schema }}.FILE_LOAD_LOG l
      WHERE l.dataset = 'order_items'
        AND l.file_name = f.filename
        AND l.status = 'SUCCESS'
    );

  RETURN 'OK';
END;
$$;
