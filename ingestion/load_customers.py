"""
Load Customers
Reads customers CSV → cleans → loads into Redshift/PostgreSQL raw.customers table.

Usage:
    python ingestion/load_customers.py --source data/customers.csv --connection $DB_CONN
"""

import argparse
import logging
import pandas as pd
from sqlalchemy import create_engine, text

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

SCHEMA = "raw"
TABLE = "customers"

EXPECTED_COLUMNS = [
    "customer_id", "email", "first_name", "last_name",
    "signup_date", "country", "segment",
]


def load_customers(source_path: str, connection_string: str) -> None:
    log.info(f"Reading {source_path}")
    df = pd.read_csv(source_path, parse_dates=["signup_date"])

    missing = set(EXPECTED_COLUMNS) - set(df.columns)
    if missing:
        raise ValueError(f"Missing columns in source: {missing}")

    df = df[EXPECTED_COLUMNS].copy()
    df["signup_date"] = pd.to_datetime(df["signup_date"], errors="coerce")
    df["email"] = df["email"].str.lower().str.strip()
    df["segment"] = df["segment"].fillna("unknown")
    df.dropna(subset=["customer_id", "email"], inplace=True)

    log.info(f"{len(df):,} rows to load into {SCHEMA}.{TABLE}")

    engine = create_engine(connection_string)
    with engine.begin() as conn:
        conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS "{SCHEMA}"'))
        df.to_sql(TABLE, conn, schema=SCHEMA, if_exists="replace", index=False, chunksize=5000)

    log.info(f"✅ Loaded {len(df):,} rows into {SCHEMA}.{TABLE}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="Path to customers CSV")
    parser.add_argument("--connection", required=True, help="SQLAlchemy connection string")
    args = parser.parse_args()
    load_customers(args.source, args.connection)


if __name__ == "__main__":
    main()
