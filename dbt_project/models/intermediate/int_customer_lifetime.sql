-- int_customer_lifetime: aggregate order history per customer

with orders as (
    select * from {{ ref('stg_orders') }}
    where not is_refunded
),

aggregated as (
    select
        customer_id,
        min(order_date)                                     as first_order_date,
        max(order_date)                                     as last_order_date,
        count(distinct order_id)::integer                   as total_orders,
        sum(net_amount)::decimal(14,2)                      as lifetime_revenue,
        avg(net_amount)::decimal(10,2)                      as avg_order_value,

        -- days between first and last order
        (max(order_date) - min(order_date))::integer        as customer_age_days,

        -- repeat buyer flag
        case
            when count(distinct order_id) > 1 then true
            else false
        end                                                 as is_repeat_customer

    from orders
    group by customer_id
)

select * from aggregated
