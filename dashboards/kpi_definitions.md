# KPI Definitions — E-Commerce Analytics Platform

These KPIs are computed from the marts layer and fed into Amazon QuickSight SPICE datasets.

---

## Revenue KPIs

### Gross Merchandise Value (GMV)
- **Source model:** `fct_orders`
- **Formula:** `SUM(gross_amount)` grouped by `order_date`
- **Grain:** daily / weekly / monthly
- **QuickSight visual:** Line chart, time series

### Net Revenue
- **Source model:** `fct_orders`
- **Formula:** `SUM(net_amount) WHERE is_refunded = FALSE`
- **Grain:** daily

### Average Order Value (AOV)
- **Source model:** `fct_orders`
- **Formula:** `SUM(net_amount) / COUNT(DISTINCT order_id)`
- **Grain:** monthly

### Refund Rate
- **Source model:** `fct_orders`
- **Formula:** `COUNT(DISTINCT order_id WHERE is_refunded) / COUNT(DISTINCT order_id)`
- **Target:** < 5%

---

## Customer KPIs

### Customer Lifetime Value (LTV)
- **Source model:** `dim_customers`
- **Formula:** `AVG(lifetime_revenue)` segmented by `segment` or `value_tier`

### Repeat Purchase Rate
- **Source model:** `dim_customers`
- **Formula:** `COUNT(customer_id WHERE is_repeat_customer) / COUNT(customer_id)`
- **Target:** > 30%

### New vs Returning Mix
- **Source model:** `dim_customers` joined with `fct_orders`
- **Formula:** orders from customers where `first_order_date = order_date` (new) vs all others (returning)

---

## Product KPIs

### Top 10 Products by Revenue
- **Source model:** `dim_products`
- **Formula:** `total_revenue DESC LIMIT 10`
- **QuickSight visual:** Horizontal bar chart

### Category Revenue Mix
- **Source model:** `fct_orders`
- **Formula:** `SUM(net_amount)` grouped by `category`
- **QuickSight visual:** Donut chart

### Gross Margin by Category
- **Source model:** `fct_orders`
- **Formula:** `SUM(gross_profit) / SUM(net_amount)` grouped by `category`

---

## QuickSight Dataset Config

```
SPICE Dataset: ecommerce_fct_orders
  Source: Redshift marts.fct_orders
  Refresh: Daily at 07:00 UTC
  Columns: all

SPICE Dataset: ecommerce_dim_customers
  Source: Redshift marts.dim_customers
  Refresh: Daily at 07:30 UTC

SPICE Dataset: ecommerce_dim_products
  Source: Redshift marts.dim_products
  Refresh: Daily at 07:45 UTC
```
