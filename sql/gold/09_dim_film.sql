CREATE TABLE sakila_gold.dim_film AS
SELECT f.film_id                      AS film_id,
       f.title                        AS film_title,
       f.category                     AS category,
       f.rating                       AS rating,
       f.language_name                AS language_name,
       f.replacement_cost             AS replacement_cost,
       f.rental_rate                  AS rental_rate,
       f.length                       AS length
FROM sakila_silver.film f;
