CREATE TABLE sakila_gold.agg_customer_behavior AS
SELECT c.customer_id               AS customer_id,
       COUNT(DISTINCT r.rental_id) AS total_rentals,
       SUM(p.amount)               AS total_spent,
       AVG(p.amount)               AS avg_payment_amount,
       AVG(r.rental_duration_days) AS avg_rental_duration_days,
       MIN(r.rental_date)          AS first_rental_date,
       MAX(r.rental_date)          AS last_rental_date
FROM sakila_silver.customer c
         LEFT JOIN sakila_silver.rental r ON c.customer_id = r.customer_id
         LEFT JOIN sakila_silver.payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id;
