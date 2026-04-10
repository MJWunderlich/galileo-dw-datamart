CREATE TABLE sakila_gold.agg_actor_rentals AS
SELECT fa.actor_id        AS actor_id,
       COUNT(r.rental_id) AS total_rentals
FROM sakila_silver.rental r
         JOIN sakila_silver.film_actor fa ON r.film_id = fa.film_id
GROUP BY fa.actor_id
ORDER BY total_rentals DESC;
