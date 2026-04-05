CREATE TABLE sakila_silver.payment AS
SELECT
    p.payment_id        AS payment_id,
    p.customer_id       AS customer_id,
    c.full_name         AS customer_name,
    c.city              AS city,
    c.country           AS country,
    p.staff_id          AS staff_id,
    p.rental_id         AS rental_id,
    p.amount            AS amount,
    p.payment_date      AS payment_date,
    toYYYYMMDD(p.payment_date) AS payment_day,
    r.film_id           AS film_id,
    r.film_title        AS film_title,
    r.category          AS category,
    p._ingested_at      AS _ingested_at,
    p._source           AS _source
FROM sakila_bronze.payment p
JOIN sakila_silver.customer c ON p.customer_id = c.customer_id
JOIN sakila_silver.rental r ON p.rental_id = r.rental_id;
