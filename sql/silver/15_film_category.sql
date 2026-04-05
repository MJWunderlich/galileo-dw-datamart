CREATE TABLE sakila_silver.film_category AS
SELECT fc.film_id      AS film_id,
       fc.category_id  AS category_id,
       c.name          AS category,
       fc.last_update  AS last_update,
       fc._ingested_at AS _ingested_at,
       fc._source      AS _source
FROM sakila_bronze.film_category fc
         JOIN sakila_bronze.category c
              ON fc.category_id = c.category_id;
