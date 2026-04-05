CREATE TABLE sakila_silver.film AS
SELECT
    f.film_id               AS film_id,
    f.title                 AS title,
    f.description           AS description,
    f.release_year          AS release_year,
    f.rental_duration       AS rental_duration,
    f.rental_rate           AS rental_rate,
    f.length                AS length,
    f.replacement_cost      AS replacement_cost,
    f.rating                AS rating,
    f.special_features      AS special_features,
    l.language_id           AS language_id,
    l.name                  AS language_name,
    cat.category_id         AS category_id,
    cat.name                AS category,
    f.last_update           AS last_update,
    f._ingested_at          AS _ingested_at,
    f._source               AS _source
FROM sakila_bronze.film f
JOIN sakila_bronze.language l ON f.language_id = l.language_id
JOIN sakila_bronze.film_category fc ON f.film_id = fc.film_id
JOIN sakila_bronze.category cat ON fc.category_id = cat.category_id;
