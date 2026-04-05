CREATE TABLE sakila_gold.fact_rental AS
SELECT r.rental_id            AS rental_id,
       r.rental_date          AS rental_date,
       r.return_date          AS return_date,
       r.rental_duration_days AS rental_duration_days,
       r.customer_id          AS customer_id,
       r.customer_name        AS customer_name,
       r.city                 AS city,
       r.country              AS country,
       r.inventory_id         AS inventory_id,
       r.film_id              AS film_id,
       r.film_title           AS film_title,
       r.category             AS category,
       r.store_id             AS store_id,
       r.staff_id             AS staff_id
FROM sakila_silver.rental AS r;
