CREATE TABLE sakila_silver.customer AS
SELECT
    c.customer_id   AS customer_id,
    c.first_name    AS first_name,
    c.last_name     AS last_name,
    concat(c.first_name, ' ', c.last_name) AS full_name,
    c.email         AS email,
    c.active        AS active,
    c.store_id      AS store_id,
    a.address_id    AS address_id,
    a.address       AS address,
    a.city_id       AS city_id,
    a.city          AS city,
    a.country_id    AS country_id,
    a.country       AS country,
    c.create_date   AS create_date,
    c.last_update   AS last_update,
    c._ingested_at  AS _ingested_at,
    c._source       AS _source
FROM sakila_bronze.customer c
JOIN sakila_silver.address a ON c.address_id = a.address_id;
