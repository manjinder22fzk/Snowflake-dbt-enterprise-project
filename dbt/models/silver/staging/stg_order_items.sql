with src as (
  select
    order_item_id::number as order_item_id,
    order_id::number as order_id,
    product_id::number as product_id,
    quantity::number as quantity,
    unit_price::number(10,2) as unit_price,
    created_at::timestamp_ntz as created_at,
    updated_at::timestamp_ntz as updated_at,
    _ingested_at::timestamp_ntz as _ingested_at
  from {{ source('raw_dev', 'order_items_bronze') }}
),
dedup as (
  select *
  from src
  qualify row_number() over (partition by order_item_id order by updated_at desc, _ingested_at desc) = 1
)
select * from dedup;
