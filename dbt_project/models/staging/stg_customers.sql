-- stg_customers: clean and cast raw customers

with source as (
    select * from {{ source('raw', 'customers') }}
),

cleaned as (
    select
        customer_id::varchar                            as customer_id,
        lower(trim(email))                              as email,
        trim(first_name)                                as first_name,
        trim(last_name)                                 as last_name,
        signup_date::date                               as signup_date,
        lower(trim(country))                            as country,
        coalesce(lower(trim(segment)), 'unknown')       as segment,
        current_timestamp                               as _loaded_at

    from source
    where customer_id is not null
      and email is not null
)

select * from cleaned
