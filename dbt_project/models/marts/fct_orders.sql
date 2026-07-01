-- fct_orders: core fact table — one row per order line

with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['order_id', 'product_id']) }} as order_sk,
        order_id,
        customer_id,
        product_id,
        product_name,
        category,
        subcategory,
        order_date,
        extract(year from order_date)::integer          as order_year,
        extract(month from order_date)::integer         as order_month,
        extract(dow from order_date)::integer           as order_dow,
        quantity,
        unit_price,
        discount,
        gross_amount,
        net_amount,
        total_cost,
        gross_profit,
        status,
        is_refunded

    from orders
)

select * from final
