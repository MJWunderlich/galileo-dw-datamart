CREATE TABLE sakila_silver.rental AS
SELECT
    r.rental_id         AS rental_id,
    r.rental_date       AS rental_date,
    r.return_date       AS return_date,
    dateDiff('day', r.rental_date, r.return_date) AS rental_duration_days,
    r.customer_id       AS customer_id,
    c.full_name         AS customer_name,
    c.city              AS city,
    c.country           AS country,
    r.inventory_id      AS inventory_id,
    i.film_id           AS film_id,
    i.film_title        AS film_title,
    i.category          AS category,
    i.store_id          AS store_id,
    r.staff_id          AS staff_id,
    r.last_update       AS last_update,
    r._ingested_at      AS _ingested_at,
    r._source           AS _source
FROM sakila_bronze.rental r
JOIN sakila_silver.customer c ON r.customer_id = c.customer_id
JOIN sakila_silver.inventory i ON r.inventory_id = i.inventory_id;
