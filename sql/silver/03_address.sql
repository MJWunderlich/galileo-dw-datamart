CREATE TABLE sakila_silver.address AS
SELECT
    a.address_id     AS address_id,
    a.address        AS address,
    a.address2       AS address2,
    a.district       AS district,
    a.postal_code    AS postal_code,
    a.phone          AS phone,
    ci.city_id       AS city_id,
    ci.city          AS city,
    co.country_id    AS country_id,
    co.country       AS country,
    a.last_update    AS last_update,
    a._ingested_at   AS _ingested_at,
    a._source        AS _source
FROM sakila_bronze.address a
JOIN sakila_bronze.city ci ON a.city_id = ci.city_id
JOIN sakila_bronze.country co ON ci.country_id = co.country_id;
