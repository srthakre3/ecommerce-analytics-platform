# E-Commerce Analytics Platform

End-to-end analytics platform for an e-commerce dataset. Ingests from raw CSV sources into Redshift, runs dbt transformations (staging → intermediate → marts), and produces a governed KPI metric layer powering interactive dashboards. Covers the full BI stack from raw data to executive reporting.

## Architecture

![Architecture Diagram](docs/architecture.svg)

Raw e-commerce data flows through Redshift into dbt's three-layer transformation model (staging → intermediate → mart), feeds a governed metric layer (revenue, churn, cohort retention), and surfaces in interactive QuickSight/Tableau dashboards. Star schema centers on `fact_orders` with dimension tables for customers, products, dates, and channels.

## Tech Stack

| Layer | Tool |
|-------|------|
| Storage | Amazon Redshift / PostgreSQL (local) |
| Transformation | dbt + dbt_utils |
| Ingestion | Python, pandas |
| BI Layer | Amazon QuickSight / Tableau |
| CI | GitHub Actions |

## Project Structure

```
ecommerce-analytics-platform/
├── ingestion/
│   ├── load_orders.py          # Loads orders CSV → Redshift raw schema
│   └── load_customers.py       # Loads customers CSV → Redshift raw schema
├── dbt_project/
│   ├── dbt_project.yml
│   ├── packages.yml
│   ├── profiles.yml
│   └── models/
│       ├── staging/
│       │   ├── stg_orders.sql
│       │   ├── stg_customers.sql
│       │   └── stg_products.sql
│       ├── intermediate/
│       │   ├── int_orders_enriched.sql
│       │   └── int_customer_lifetime.sql
│       └── marts/
│           ├── fct_orders.sql
│           ├── dim_customers.sql
│           └── dim_products.sql
├── dashboards/
│   └── kpi_definitions.md      # KPI definitions for QuickSight
├── docs/
│   └── architecture.svg        # Architecture diagram
├── .github/workflows/
│   └── ci.yml
└── requirements.txt
```

## Key Metrics Produced

| KPI | Model | Description |
|-----|-------|-------------|
| GMV | fct_orders | Gross merchandise value by day/week/month |
| AOV | fct_orders | Average order value |
| Customer LTV | dim_customers | Revenue per customer over lifetime |
| Repeat Rate | dim_customers | % customers with > 1 order |
| Top Products | fct_orders + dim_products | Revenue by SKU |
| Refund Rate | fct_orders | % orders refunded |

## Setup

### Prerequisites

Python 3.11+, dbt-core, and access to a PostgreSQL or Redshift instance.

### Run locally

```bash
# 1. Clone and install dependencies
git clone https://github.com/srthakre3/ecommerce-analytics-platform.git
cd ecommerce-analytics-platform
pip install -r requirements.txt

# 2. Load raw data
python ingestion/load_orders.py --source data/orders.csv --connection $DB_CONN
python ingestion/load_customers.py --source data/customers.csv --connection $DB_CONN

# 3. Run dbt transformations
cd dbt_project
dbt deps
dbt run
dbt test

# 4. Verify marts
dbt run --select marts
```

## Results

- Full dimensional model with 4 mart tables (fct_orders, dim_customers, dim_products, dim_dates)
- Governed metric layer covering revenue, churn, and cohort retention
- dbt tests enforcing referential integrity and null constraints across all models
- Dashboard-ready KPI definitions documented in `dashboards/kpi_definitions.md`

## Author

**Sanket Thakre**, Business Intelligence Engineer @ Amazon
[srthakre3.github.io](https://srthakre3.github.io) · [github.com/srthakre3](https://github.com/srthakre3)
