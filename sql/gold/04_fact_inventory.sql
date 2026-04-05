CREATE TABLE sakila_gold.fact_inventory AS
SELECT i.inventory_id     AS inventory_id,
       i.store_id         AS store_id,
       s.city             AS store_city,
       s.country          AS store_country,
       i.film_id          AS film_id,
       i.film_title       AS film_title,
       i.category         AS category,
       i.rating           AS rating,
       i.rental_rate      AS rental_rate,
       i.replacement_cost AS replacement_cost,
       COUNT(r.rental_id) AS times_rented
FROM sakila_silver.inventory i
         JOIN sakila_silver.store s ON i.store_id = s.store_id
         LEFT JOIN sakila_silver.rental r ON i.inventory_id = r.inventory_id
GROUP BY i.inventory_id,
         i.store_id,
         s.city,
         s.country,
         i.film_id,
         i.film_title,
         i.category,
         i.rating,
         i.rental_rate,
         i.replacement_cost;
