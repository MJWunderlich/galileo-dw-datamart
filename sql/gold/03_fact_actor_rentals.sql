CREATE TABLE sakila_gold.fact_actor_rentals AS
SELECT fa.actor_id        AS actor_id,
       fa.full_name       AS full_name,
       COUNT(r.rental_id) AS total_rentals
FROM sakila_silver.rental r
         JOIN sakila_silver.film_actor fa ON r.film_id = fa.film_id
GROUP BY fa.actor_id,
         fa.full_name
ORDER BY total_rentals DESC;
