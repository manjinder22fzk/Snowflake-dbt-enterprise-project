with src as (
  select
    order_id::number as order_id,
    customer_id::number as customer_id,
    order_ts::timestamp_ntz as order_ts,
    status::string as status,
    currency::string as currency,
    created_at::timestamp_ntz as created_at,
    updated_at::timestamp_ntz as updated_at,
    is_deleted::boolean as is_deleted,
    _ingested_at::timestamp_ntz as _ingested_at
  from {{ source('raw_dev', 'orders_bronze') }}
),
dedup as (
  select *
  from src
  qualify row_number() over (partition by order_id order by updated_at desc, _ingested_at desc) = 1
)
select * from dedup;
