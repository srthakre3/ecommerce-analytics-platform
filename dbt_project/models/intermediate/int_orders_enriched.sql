-- int_orders_enriched: join orders with product margin data

with orders as (
    select * from {{ ref('stg_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

enriched as (
    select
        o.order_id,
        o.customer_id,
        o.product_id,
        o.order_date,
        o.quantity,
        o.unit_price,
        o.discount,
        o.gross_amount,
        o.net_amount,
        o.status,
        o.is_refunded,

        -- product context
        p.product_name,
        p.category,
        p.subcategory,
        p.cost_price,
        p.margin_pct,

        -- order profitability
        (o.quantity * p.cost_price)::decimal(12,2)          as total_cost,
        (o.net_amount - o.quantity * p.cost_price)::decimal(12,2) as gross_profit

    from orders o
    left join products p using (product_id)
)

select * from enriched
