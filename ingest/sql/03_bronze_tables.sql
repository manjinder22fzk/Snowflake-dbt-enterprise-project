USE ROLE R_DEV_INGEST;
USE WAREHOUSE WH_DEV_LOAD_XS;
USE DATABASE RAW_DEV;
USE SCHEMA BRONZE;

CREATE OR REPLACE TABLE CUSTOMERS_BRONZE (
  customer_id      NUMBER,
  first_name       STRING,
  last_name        STRING,
  email            STRING,
  phone            STRING,
  country          STRING,
  created_at       TIMESTAMP_NTZ,
  updated_at       TIMESTAMP_NTZ,
  is_deleted       BOOLEAN,

  -- load metadata
  _ingested_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  _source_file     STRING,
  _source_row_num  NUMBER
);

CREATE OR REPLACE TABLE PRODUCTS_BRONZE (
  product_id       NUMBER,
  product_name     STRING,
  category         STRING,
  price            NUMBER(10,2),
  created_at       TIMESTAMP_NTZ,
  updated_at       TIMESTAMP_NTZ,
  is_active        BOOLEAN,

  _ingested_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  _source_file     STRING,
  _source_row_num  NUMBER
);

CREATE OR REPLACE TABLE ORDERS_BRONZE (
  order_id         NUMBER,
  customer_id      NUMBER,
  order_ts         TIMESTAMP_NTZ,
  status           STRING,
  currency         STRING,
  created_at       TIMESTAMP_NTZ,
  updated_at       TIMESTAMP_NTZ,
  is_deleted       BOOLEAN,

  _ingested_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  _source_file     STRING,
  _source_row_num  NUMBER
);

CREATE OR REPLACE TABLE ORDER_ITEMS_BRONZE (
  order_item_id    NUMBER,
  order_id         NUMBER,
  product_id       NUMBER,
  quantity         NUMBER,
  unit_price       NUMBER(10,2),
  created_at       TIMESTAMP_NTZ,
  updated_at       TIMESTAMP_NTZ,

  _ingested_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  _source_file     STRING,
  _source_row_num  NUMBER
);
