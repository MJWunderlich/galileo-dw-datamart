CREATE TABLE sakila_gold.fact_film_performance AS
SELECT f.film_id                      AS film_id,
       f.title                        AS film_title,
       f.category                     AS category,
       f.rating                       AS rating,
       f.rental_rate                  AS rental_rate,
       f.replacement_cost             AS replacement_cost,
       f.length                       AS length,
       f.language_name                AS language_name,
       COUNT(DISTINCT i.inventory_id) AS total_copies,
       COUNT(DISTINCT r.rental_id)    AS total_rentals,
       SUM(p.amount)                  AS total_revenue,
       AVG(r.rental_duration_days)    AS avg_rental_duration_days,
       COUNT(DISTINCT r.rental_id) /
       COUNT(DISTINCT i.inventory_id) AS rentals_per_copy
FROM sakila_silver.film f
         LEFT JOIN sakila_silver.inventory i ON f.film_id = i.film_id
         LEFT JOIN sakila_silver.rental r ON i.inventory_id = r.inventory_id
         LEFT JOIN sakila_silver.payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id,
         f.title,
         f.category,
         f.rating,
         f.rental_rate,
         f.replacement_cost,
         f.length,
         f.language_name;
