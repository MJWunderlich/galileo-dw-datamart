CREATE TABLE sakila_gold.fact_payment AS
SELECT p.payment_id    AS payment_id,
       p.payment_date  AS payment_date,
       p.payment_day   AS payment_day,
       p.amount        AS amount,
       p.customer_id   AS customer_id,
       p.customer_name AS customer_name,
       p.city          AS city,
       p.country       AS country,
       p.staff_id      AS staff_id,
       p.rental_id     AS rental_id,
       p.film_id       AS film_id,
       p.film_title    AS film_title,
       p.category      AS category
FROM sakila_silver.payment p;
