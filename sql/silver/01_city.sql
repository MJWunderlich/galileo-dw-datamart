CREATE TABLE sakila_silver.city AS
SELECT
    ci.city_id       AS city_id,
    ci.city          AS city,
    co.country_id    AS country_id,
    co.country       AS country,
    ci.last_update   AS last_update,
    ci._ingested_at  AS _ingested_at,
    ci._source       AS _source
FROM sakila_bronze.city ci
JOIN sakila_bronze.country co ON ci.country_id = co.country_id;
