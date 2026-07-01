-- stg_products: clean and cast raw products

with source as (
    select * from {{ source('raw', 'products') }}
),

cleaned as (
    select
        product_id::varchar                             as product_id,
        trim(product_name)                              as product_name,
        lower(trim(category))                           as category,
        lower(trim(subcategory))                        as subcategory,
        cost_price::decimal(10,2)                       as cost_price,
        list_price::decimal(10,2)                       as list_price,
        (list_price - cost_price)::decimal(10,2)        as gross_margin,
        case
            when list_price > 0
            then round((list_price - cost_price) / list_price * 100, 2)
            else 0
        end                                             as margin_pct,
        current_timestamp                               as _loaded_at

    from source
    where product_id is not null
      and list_price > 0
)

select * from cleaned
