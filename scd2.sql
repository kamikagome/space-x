CREATE OR REPLACE TABLE dim_rocket_scd2 (
    rocket_sk BIGINT PRIMARY KEY,
    rocket_id VARCHAR NOT NULL,
    rocket_name VARCHAR NOT NULL,
    rocket_type VARCHAR,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    is_current BOOLEAN NOT NULL
);

INSERT INTO dim_rocket_scd2
SELECT
    ROW_NUMBER() OVER (ORDER BY rocket_id) AS rocket_sk,
    rocket_id,
    rocket_name,
    rocket_type,
    DATE '2010-01-01' AS valid_from,
    DATE '9999-12-31' AS valid_to,
    TRUE AS is_current
FROM dim_rocket;

-- Close the old row and open a new version for the rename
UPDATE dim_rocket_scd2
SET valid_to = DATE '2026-03-24', is_current = FALSE
WHERE rocket_id = '5e9d0d95eda69973a809d1ec'
  AND is_current = TRUE;

INSERT INTO dim_rocket_scd2 (rocket_sk, rocket_id, rocket_name, rocket_type, valid_from, valid_to, is_current)
SELECT
    COALESCE((SELECT MAX(rocket_sk) FROM dim_rocket_scd2), 0) + 1,
    '5e9d0d95eda69973a809d1ec',
    'Falcon 9 Block 5',
    rocket_type,
    DATE '2026-03-25',
    DATE '9999-12-31',
    TRUE
FROM dim_rocket
WHERE rocket_id = '5e9d0d95eda69973a809d1ec'
LIMIT 1;