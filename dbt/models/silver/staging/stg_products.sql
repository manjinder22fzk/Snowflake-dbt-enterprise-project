with src as (
  select
    product_id::number as product_id,
    product_name::string as product_name,
    category::string as category,
    price::number(10,2) as price,
    created_at::timestamp_ntz as created_at,
    updated_at::timestamp_ntz as updated_at,
    is_active::boolean as is_active,
    _ingested_at::timestamp_ntz as _ingested_at
  from {{ source('raw_dev', 'products_bronze') }}
),
dedup as (
  select *
  from src
  qualify row_number() over (partition by product_id order by updated_at desc, _ingested_at desc) = 1
)
select * from dedup;
