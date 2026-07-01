-- stg_orders: clean and cast raw orders

with source as (
    select * from {{ source('raw', 'orders') }}
),

cleaned as (
    select
        order_id::varchar                               as order_id,
        customer_id::varchar                            as customer_id,
        product_id::varchar                             as product_id,
        order_date::date                                as order_date,
        quantity::integer                               as quantity,
        unit_price::decimal(10,2)                       as unit_price,
        coalesce(discount, 0)::decimal(5,4)             as discount,
        lower(trim(status))                             as status,
        gross_amount::decimal(12,2)                     as gross_amount,
        net_amount::decimal(12,2)                       as net_amount,

        -- derived
        case
            when lower(trim(status)) = 'refunded' then true
            else false
        end                                             as is_refunded,

        current_timestamp                               as _loaded_at

    from source
    where order_id is not null
      and customer_id is not null
      and order_date is not null
      and net_amount >= 0
)

select * from cleaned
