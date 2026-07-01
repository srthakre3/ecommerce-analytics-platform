-- dim_customers: customer dimension with lifetime value metrics

with customers as (
    select * from {{ ref('stg_customers') }}
),

lifetime as (
    select * from {{ ref('int_customer_lifetime') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} as customer_sk,
        c.customer_id,
        c.email,
        c.first_name,
        c.last_name,
        c.signup_date,
        c.country,
        c.segment,

        -- lifetime metrics (null if no orders yet)
        coalesce(l.first_order_date, null)              as first_order_date,
        coalesce(l.last_order_date, null)               as last_order_date,
        coalesce(l.total_orders, 0)                     as total_orders,
        coalesce(l.lifetime_revenue, 0)                 as lifetime_revenue,
        coalesce(l.avg_order_value, 0)                  as avg_order_value,
        coalesce(l.is_repeat_customer, false)           as is_repeat_customer,

        -- customer value tier
        case
            when coalesce(l.lifetime_revenue, 0) >= 1000 then 'high'
            when coalesce(l.lifetime_revenue, 0) >= 200  then 'mid'
            else 'low'
        end                                             as value_tier

    from customers c
    left join lifetime l using (customer_id)
)

select * from final
