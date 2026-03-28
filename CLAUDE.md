# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **practical data modeling project** demonstrating Kimball dimensional modeling using SpaceX launch data. The goal is to transform raw transactional data into a clean star schema suitable for analytical queries.

## Architecture: Bronze-Silver-Gold Pattern

The data pipeline follows three layers:

1. **Bronze (Raw):** Source data fetched directly from the SpaceX public API
   - File: `fetch_launches.sql`
   - Creates: `stg_launches` (staging table with 20 most recent launches)
   - Note: Fetches only 20 rows; remove `LIMIT 20` for full dataset

2. **Silver (Staging):** Cleaned, deduplicated source data
   - `stg_launches` table with normalized columns and type casting
   - Joins launch and rocket data from separate API endpoints

3. **Gold (Star Schema):** Business-ready dimensional model
   - **Fact Table:** `fct_launches` (one row per launch with foreign keys and metrics)
   - **Dimension Tables:**
     - `dim_date` (calendar dimension from launch dates)
     - `dim_rocket` (rocket attributes with SCD Type 2 variant in `dim_rocket_scd2`)

## Key Files

- **`fetch_launches.sql`** — Fetches SpaceX API data and builds `stg_launches`. Requires network access.
- **`create_tables.sql`** — Builds dimensional model: `dim_date`, `dim_rocket`, `fct_launches`.
- **`scd2.sql`** — Implements Type 2 Slowly Changing Dimension (SCD2) for rocket attributes. Shows how to handle dimension changes with validity periods (`valid_from`, `valid_to`, `is_current`).
- **`sanity_checks.sql`** — Validation queries demonstrating fact/dimension joins and aggregations.

## Development Workflow

### Running the Full Pipeline
```bash
duckdb spacex_modelling.duckdb < fetch_launches.sql
duckdb spacex_modelling.duckdb < create_tables.sql
duckdb spacex_modelling.duckdb < sanity_checks.sql
```

### Running Individual Scripts
Each script can be run independently, but they have dependencies:
- `fetch_launches.sql` must run first (creates `stg_launches`)
- `create_tables.sql` depends on `stg_launches`
- `scd2.sql` depends on `dim_rocket` from `create_tables.sql`
- `sanity_checks.sql` reads from the final dimensional tables

### Querying the Database
```bash
duckdb spacex_modelling.duckdb
# Then run SQL queries interactively
```

## Important Notes

- **Database:** This project uses **DuckDB** (not PostgreSQL/Snowflake/BigQuery as the README header suggests)
- **Data Volume:** The staging table is limited to 20 recent launches for development/demo purposes. Remove `LIMIT 20` in `fetch_launches.sql` for full dataset
- **API Dependency:** `fetch_launches.sql` requires network access to the SpaceX public API (community-maintained, may change)
- **ETag Handling:** `unsafe_disable_etag_checks = true` is set to handle remote JSON caching issues
- **SCD2 Pattern:** `scd2.sql` demonstrates handling dimension changes with validity periods. The example shows renaming "Falcon 9" to "Falcon 9 Block 5" with a cutover date (2026-03-24 → 2026-03-25)

## Star Schema Queries

The dimensional model supports typical analytical queries:
- **Time-based analysis:** Launches by month/year (join `fct_launches` → `dim_date`)
- **Rocket performance:** Success rates by rocket type (join `fct_launches` → `dim_rocket`)
- **SCD2 temporal queries:** Track attribute changes over time using validity periods