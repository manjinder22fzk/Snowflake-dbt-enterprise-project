# Assumes Snowflake CLI "snow" is installed and authenticated

# Upload each dataset into a folder under the stage
snow stage copy "data/sample_csv/customers_v1.csv" "@RAW_DEV.LANDING.STG_CSV_LANDING/customers/" 
snow stage copy "data/sample_csv/products_v1.csv"  "@RAW_DEV.LANDING.STG_CSV_LANDING/products/"
snow stage copy "data/sample_csv/orders_v1.csv"    "@RAW_DEV.LANDING.STG_CSV_LANDING/orders/"
snow stage copy "data/sample_csv/order_items_v1.csv" "@RAW_DEV.LANDING.STG_CSV_LANDING/order_items/"
