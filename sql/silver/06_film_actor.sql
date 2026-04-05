CREATE TABLE sakila_silver.film_actor AS
SELECT
    fa.film_id      AS film_id,
    f.title         AS film_title,
    fa.actor_id     AS actor_id,
    a.first_name    AS first_name,
    a.last_name     AS last_name,
    concat(a.first_name, ' ', a.last_name) AS full_name,
    fa.last_update  AS last_update,
    fa._ingested_at AS _ingested_at,
    fa._source      AS _source
FROM sakila_bronze.film_actor fa
JOIN sakila_bronze.actor a ON fa.actor_id = a.actor_id
JOIN sakila_bronze.film f ON fa.film_id = f.film_id;
