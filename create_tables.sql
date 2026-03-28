-- Calendar dimension from the launch dates in the sample
CREATE OR REPLACE TABLE dim_date AS
SELECT DISTINCT
    CAST(strftime(launch_date, '%Y%m%d') AS INTEGER) AS date_key,
    launch_date AS full_date,
    year(launch_date) AS year_nbr,
    month(launch_date) AS month_nbr,
    day(launch_date) AS day_of_month
FROM stg_launches;

-- One row per rocket (in this sample)
CREATE OR REPLACE TABLE dim_rocket AS
SELECT DISTINCT
    rocket_id,
    rocket_name,
    rocket_type
FROM stg_launches;

-- Fact: one row per launch
CREATE OR REPLACE TABLE fct_launches AS
SELECT
    s.launch_id,
    s.flight_number,
    s.mission_name,
    CAST(strftime(s.launch_date, '%Y%m%d') AS INTEGER) AS date_key,
    s.rocket_id,
    CAST(COALESCE(s.launch_success, FALSE) AS INTEGER) AS success_flag
FROM stg_launches s;