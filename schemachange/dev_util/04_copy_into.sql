USE ROLE R_DEV_INGEST;
USE WAREHOUSE WH_DEV_LOAD_XS;
USE DATABASE RAW_DEV;

-- CUSTOMERS
COPY INTO BRONZE.CUSTOMERS_BRONZE
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
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER
  FROM @LANDING.STG_CSV_LANDING/customers/
)
FILE_FORMAT = (FORMAT_NAME = LANDING.FF_CSV_STANDARD)
ON_ERROR = 'CONTINUE';

-- PRODUCTS
COPY INTO BRONZE.PRODUCTS_BRONZE
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
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER
  FROM @LANDING.STG_CSV_LANDING/products/
)
FILE_FORMAT = (FORMAT_NAME = LANDING.FF_CSV_STANDARD)
ON_ERROR = 'CONTINUE';

-- ORDERS
COPY INTO BRONZE.ORDERS_BRONZE
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
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER
  FROM @LANDING.STG_CSV_LANDING/orders/
)
FILE_FORMAT = (FORMAT_NAME = LANDING.FF_CSV_STANDARD)
ON_ERROR = 'CONTINUE';

-- ORDER ITEMS
COPY INTO BRONZE.ORDER_ITEMS_BRONZE
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
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER
  FROM @LANDING.STG_CSV_LANDING/order_items/
)
FILE_FORMAT = (FORMAT_NAME = LANDING.FF_CSV_STANDARD)
ON_ERROR = 'CONTINUE';
