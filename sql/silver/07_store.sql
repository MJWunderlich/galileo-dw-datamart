CREATE TABLE sakila_silver.store AS
SELECT
    s.store_id      AS store_id,
    a.address_id    AS address_id,
    a.address       AS address,
    a.city_id       AS city_id,
    a.city          AS city,
    a.country_id    AS country_id,
    a.country       AS country,
    s.last_update   AS last_update,
    s._ingested_at  AS _ingested_at,
    s._source       AS _source
FROM sakila_bronze.store s
JOIN sakila_silver.address a ON s.address_id = a.address_id;
