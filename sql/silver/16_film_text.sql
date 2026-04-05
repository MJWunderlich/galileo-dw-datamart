CREATE TABLE sakila_silver.film_text AS
SELECT ft.film_id      AS film_id,
       ft.title        AS title,
       ft.description  AS description,
       f.category      AS category,
       f.rating        AS rating,
       f.rental_rate   AS rental_rate,
       f.language_name AS language_name,
       ft._ingested_at AS _ingested_at,
       ft._source      AS _source
FROM sakila_bronze.film_text ft
         JOIN sakila_silver.film f ON ft.film_id = f.film_id;
