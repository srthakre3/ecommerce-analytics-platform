-- dim_products: product dimension with profitability context

with products as (
    select * from {{ ref('stg_products') }}
),

order_stats as (
    select
        product_id,
        count(distinct order_id)                        as total_orders,
        sum(quantity)                                   as total_units_sold,
        sum(net_amount)::decimal(14,2)                  as total_revenue,
        avg(discount)::decimal(5,4)                     as avg_discount

    from {{ ref('stg_orders') }}
    where not is_refunded
    group by product_id
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_sk,
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost_price,
        p.list_price,
        p.gross_margin,
        p.margin_pct,

        coalesce(s.total_orders, 0)                     as total_orders,
        coalesce(s.total_units_sold, 0)                 as total_units_sold,
        coalesce(s.total_revenue, 0)                    as total_revenue,
        coalesce(s.avg_discount, 0)                     as avg_discount

    from products p
    left join order_stats s using (product_id)
)

select * from final
