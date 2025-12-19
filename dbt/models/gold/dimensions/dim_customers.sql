select
  customer_id,
  first_name,
  last_name,
  email,
  phone,
  country,
  created_at,
  updated_at
from {{ ref('stg_customers') }}
where is_deleted = false;
