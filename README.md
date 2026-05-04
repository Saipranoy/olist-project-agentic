# Olist Analytics Stack

A fully containerised, end-to-end modern data stack built on the [Olist Brazilian e-commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle.

The stack turns raw CSVs into a production-style analytics environment with a semantic layer, a BI tool, and an AI chat agent — all running locally via Docker Compose.

---

## What's inside

| Layer | Tool | Purpose |
|---|---|---|
| Raw ingestion | Python + pandas | Load CSVs into PostgreSQL `raw` schema |
| Transformation | dbt (PostgreSQL adapter) | Staging views + mart tables |
| Warehouse | PostgreSQL 15 | Single source of truth |
| Object storage | MinIO | S3-compatible storage for Lightdash result pagination |
| BI & semantic layer | Lightdash | Metrics, dimensions, dashboards |
| AI chat agent | Nao | Ask questions about your data in plain English |

---

## Architecture

```
Raw CSVs
   │
   ▼
load_to_postgres.py  ──►  PostgreSQL (raw schema)
                                │
                           dbt run
                                │
                    ┌───────────┴──────────┐
                    │                      │
              staging views          mart tables
              (stg_orders, etc.)     (fct_orders, rfm_segments, etc.)
                                          │
                          ┌───────────────┼───────────────┐
                          │               │               │
                     Lightdash           Nao           Your SQL
                  (dashboards)       (AI chat)        client
```

---

## dbt models

### Staging (views)
| Model | Source table |
|---|---|
| `stg_orders` | olist_orders_dataset |
| `stg_order_items` | olist_order_items_dataset |
| `stg_customers` | olist_customers_dataset |
| `stg_products` | olist_products_dataset |
| `stg_sellers` | olist_sellers_dataset |
| `stg_reviews` | olist_order_reviews_dataset |
| `stg_payments` | olist_order_payments_dataset |

> Cancelled orders are filtered out at this layer and never appear downstream.

### Marts (tables)
| Model | Description |
|---|---|
| `fct_orders` | One row per order — revenue, freight, delivery times, state |
| `fct_order_items` | One row per order line item |
| `dim_customers` | One row per unique customer with lifetime metrics |
| `dim_products` | Product dimension with category translations |
| `rfm_segments` | RFM-scored customer segments (Champion, Loyal, At Risk, etc.) |
| `seller_scorecard` | Per-seller delivery and review performance |
| `monthly_revenue` | Pre-aggregated MoM revenue with growth % |
| `monthly_cohorts` | Monthly customer cohort retention |

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (running)
- Python 3.9+ with `pip`
- dbt Core with the PostgreSQL adapter: `pip install dbt-core dbt-postgres`
- The Olist dataset CSVs placed in a `Raw/` folder (see below)

### Get the data

Download the Olist dataset from Kaggle:
[https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

Unzip and place the CSV files into a `Raw/` folder at the root of this project:

```
Olist/
├── Raw/
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_customers_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   └── olist_order_payments_dataset.csv
```

---

## Setup

### 1. Configure credentials

Copy the example env file and fill in your keys:

```bash
cp .env.example .env
```

Edit `.env`:

```env
ANTHROPIC_API_KEY=your_anthropic_key_here
NAO_PG_USER=lightdash
NAO_PG_PASSWORD=lightdash
```

> Get an Anthropic API key at [console.anthropic.com](https://console.anthropic.com)

### 2. Start the stack

```bash
docker compose up -d
```

This starts PostgreSQL, MinIO, Lightdash, and Nao. Wait ~30 seconds for services to become healthy.

### 3. Load raw data

```bash
python load_to_postgres.py
```

Run this once. Data persists in a named Docker volume (`pgdata`) — you don't need to reload after restarts.

### 4. Run dbt

```bash
cd olist_project
dbt run --target postgres
```

### 5. Open the tools

| Tool | URL |
|---|---|
| Lightdash | http://localhost:8082 |
| Nao AI chat | http://localhost:5005 |
| MinIO console | http://localhost:9001 |

---

## Daily startup

After the first-time setup, just run:

```bash
docker compose up -d
```

Your data and dbt models persist. No need to reload CSVs or rerun dbt unless you change models.

---

## Lightdash notes

- After `lightdash deploy`, go to **Settings → Warehouse connections** and change the host from `localhost` to `db` (the internal Docker service name).
- Deploy command: `lightdash deploy --create --target postgres --ignore-errors`

---

## AI chat (Nao)

Nao is configured via two files:

- **`nao_config.yaml`** — database connection and LLM settings
- **`RULES.md`** — semantic layer in plain English (metric definitions, table descriptions, common question mappings)

Ask questions like:
- *"What is total revenue by state?"*
- *"Which customer segment has the highest average spend?"*
- *"Show me month-on-month revenue growth"*
- *"What is the late delivery rate?"*

---

## Project structure

```
Olist/
├── docker-compose.yml       # Full stack definition
├── .env                     # Secrets (not committed)
├── .env.example             # Template for .env
├── load_to_postgres.py      # CSV → PostgreSQL loader
├── nao_config.yaml          # Nao AI agent config
├── RULES.md                 # Semantic layer for Nao
├── Raw/                     # Source CSVs (not committed)
└── olist_project/           # dbt project
    ├── dbt_project.yml
    └── models/
        ├── staging/         # Source-aligned views
        └── marts/           # Business-ready tables
```

---

## Tech stack

- **dbt Core** — SQL transformation and testing
- **PostgreSQL 15** — analytical warehouse
- **Lightdash** — open-source BI and semantic layer
- **Nao** — open-source AI analytics agent ([getnao/nao](https://github.com/getnao/nao))
- **MinIO** — local S3-compatible object storage
- **Docker Compose** — orchestrates all services

---

## Dataset

Olist Store is a Brazilian e-commerce marketplace. The dataset contains ~100k orders from 2016–2018 across multiple Brazilian states, including order status, price, payment, freight, customer location, product attributes, and customer reviews.

Source: [Olist on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — CC BY-NC-SA 4.0
