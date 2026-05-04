"""
Load Olist CSVs into the Postgres container's 'raw' schema.
Run once: python load_to_postgres.py
"""
import os
import pandas as pd
from sqlalchemy import create_engine, text

RAW_DIR = os.path.join(os.path.dirname(__file__), "Raw")
CONN = "postgresql://lightdash:lightdash@localhost:5432/lightdash"

TABLES = [
    "olist_orders_dataset",
    "olist_order_items_dataset",
    "olist_customers_dataset",
    "olist_products_dataset",
    "olist_sellers_dataset",
    "olist_order_reviews_dataset",
    "olist_order_payments_dataset",
]

engine = create_engine(CONN)

with engine.connect() as conn:
    conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw"))
    conn.commit()

for table in TABLES:
    path = os.path.join(RAW_DIR, f"{table}.csv")
    print(f"Loading {table}...", end=" ")
    df = pd.read_csv(path)
    df.to_sql(table, engine, schema="raw", if_exists="replace", index=False)
    print(f"{len(df):,} rows")

print("\nDone. All tables loaded into schema 'raw'.")
