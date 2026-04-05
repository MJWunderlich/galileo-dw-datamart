CREATE TABLE sakila_silver.inventory AS
SELECT
    i.inventory_id      AS inventory_id,
    i.store_id          AS store_id,
    f.film_id           AS film_id,
    f.title             AS film_title,
    f.category_id       AS category_id,
    f.category          AS category,
    f.rating            AS rating,
    f.rental_rate       AS rental_rate,
    f.replacement_cost  AS replacement_cost,
    i.last_update       AS last_update,
    i._ingested_at      AS _ingested_at,
    i._source           AS _source
FROM sakila_bronze.inventory i
JOIN sakila_silver.film f ON i.film_id = f.film_id;
