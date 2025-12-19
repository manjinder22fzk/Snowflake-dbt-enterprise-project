with src as (
  select
    customer_id::number as customer_id,
    first_name::string as first_name,
    last_name::string as last_name,
    email::string as email,
    phone::string as phone,
    country::string as country,
    created_at::timestamp_ntz as created_at,
    updated_at::timestamp_ntz as updated_at,
    is_deleted::boolean as is_deleted,
    _ingested_at::timestamp_ntz as _ingested_at
  from {{ source('raw_dev', 'customers_bronze') }}
),
dedup as (
  select *
  from src
  qualify row_number() over (partition by customer_id order by updated_at desc, _ingested_at desc) = 1
)
select * from dedup;
