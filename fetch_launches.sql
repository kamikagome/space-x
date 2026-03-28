-- SpaceX public API (community-maintained). Requires network.
-- Run from this folder:
--   duckdb spacex_modelling.duckdb < fetch_launches.sql

INSTALL httpfs;
LOAD httpfs;

-- Remote JSON can change between HTTP reads; DuckDB may error on ETag mismatch.
SET unsafe_disable_etag_checks = true;

DROP TABLE IF EXISTS stg_launches;

CREATE TABLE stg_launches AS
WITH l AS (
    SELECT *
    FROM read_json_auto('https://api.spacexdata.com/v4/launches')
),
r AS (
    SELECT *
    FROM read_json_auto('https://api.spacexdata.com/v4/rockets')
)
SELECT
    l.id AS launch_id,
    l.flight_number,
    l.name AS mission_name,
    CAST(l.date_utc AS TIMESTAMP) AS launch_ts,
    CAST(CAST(l.date_utc AS TIMESTAMP) AS DATE) AS launch_date,
    l.success AS launch_success,
    l.rocket AS rocket_id,
    r.name AS rocket_name,
    r.type AS rocket_type
FROM l
INNER JOIN r ON l.rocket = r.id
WHERE l.date_utc IS NOT NULL
ORDER BY launch_ts DESC
LIMIT 20;

SELECT 'stg_launches rows' AS check_name, COUNT(*) AS n FROM stg_launches;
