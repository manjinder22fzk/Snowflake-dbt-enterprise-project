{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge'
) }}

with orders as (
  select *
  from {{ ref('stg_orders') }}
  where is_deleted = false
),
items as (
  select
    order_id,
    sum(quantity * unit_price) as order_amount
  from {{ ref('stg_order_items') }}
  group by 1
)
select
  o.order_id,
  o.customer_id,
  o.order_ts,
  o.status,
  o.currency,
  i.order_amount,
  o.updated_at
from orders o
left join items i
  on o.order_id = i.order_id

{% if is_incremental() %}
where o.updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{ this }})
{% endif %}
