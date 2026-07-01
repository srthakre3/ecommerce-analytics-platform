"""
Load Orders
Reads orders CSV → cleans → upserts into Redshift/PostgreSQL raw.orders table.

Usage:
    python ingestion/load_orders.py --source data/orders.csv --connection $DB_CONN
"""

import argparse
import logging
import pandas as pd
from sqlalchemy import create_engine, text

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

SCHEMA = "raw"
TABLE = "orders"

EXPECTED_COLUMNS = [
    "order_id", "customer_id", "product_id", "order_date",
    "quantity", "unit_price", "discount", "status",
]


def load_orders(source_path: str, connection_string: str) -> None:
    log.info(f"Reading {source_path}")
    df = pd.read_csv(source_path, parse_dates=["order_date"])

    # Validate columns
    missing = set(EXPECTED_COLUMNS) - set(df.columns)
    if missing:
        raise ValueError(f"Missing columns in source: {missing}")

    # Clean
    df = df[EXPECTED_COLUMNS].copy()
    df["order_date"] = pd.to_datetime(df["order_date"], errors="coerce")
    df["quantity"] = pd.to_numeric(df["quantity"], errors="coerce").fillna(0).astype(int)
    df["unit_price"] = pd.to_numeric(df["unit_price"], errors="coerce")
    df["discount"] = pd.to_numeric(df["discount"], errors="coerce").fillna(0.0)
    df["gross_amount"] = df["quantity"] * df["unit_price"]
    df["net_amount"] = df["gross_amount"] * (1 - df["discount"])
    df.dropna(subset=["order_id", "customer_id", "order_date"], inplace=True)

    log.info(f"{len(df):,} rows to load into {SCHEMA}.{TABLE}")

    engine = create_engine(connection_string)
    with engine.begin() as conn:
        conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS "{SCHEMA}"'))
        df.to_sql(TABLE, conn, schema=SCHEMA, if_exists="replace", index=False, chunksize=5000)

    log.info(f"✅ Loaded {len(df):,} rows into {SCHEMA}.{TABLE}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="Path to orders CSV")
    parser.add_argument("--connection", required=True, help="SQLAlchemy connection string")
    args = parser.parse_args()
    load_orders(args.source, args.connection)


if __name__ == "__main__":
    main()
