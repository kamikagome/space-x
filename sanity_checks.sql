-- Launches per month in this 20-row sample
SELECT d.year_nbr, d.month_nbr, COUNT(*) AS launches
FROM fct_launches f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY 1, 2
ORDER BY 1, 2;

-- Success rate by rocket name
SELECT r.rocket_name,
       SUM(f.success_flag) AS successes,
       COUNT(*) AS launches
FROM fct_launches f
JOIN dim_rocket r ON f.rocket_id = r.rocket_id
GROUP BY 1
ORDER BY launches DESC;