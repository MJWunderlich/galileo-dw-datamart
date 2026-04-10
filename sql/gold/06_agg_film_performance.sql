CREATE TABLE sakila_gold.agg_film_performance AS
SELECT i.film_id                      AS film_id,
       COUNT(DISTINCT i.inventory_id) AS total_copies,
       COUNT(DISTINCT r.rental_id)    AS total_rentals,
       SUM(p.amount)                  AS total_revenue,
       AVG(r.rental_duration_days)    AS avg_rental_duration_days,
       COUNT(DISTINCT r.rental_id) /
       COUNT(DISTINCT i.inventory_id) AS rentals_per_copy
FROM sakila_silver.inventory AS i
         LEFT JOIN sakila_silver.rental r ON i.inventory_id = r.inventory_id
         LEFT JOIN sakila_silver.payment p ON r.rental_id = p.rental_id
GROUP BY i.film_id;
