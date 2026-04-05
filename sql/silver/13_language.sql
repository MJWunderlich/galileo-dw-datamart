CREATE TABLE sakila_silver.language AS
SELECT l.language_id  AS language_id,
       l.name         AS language_name,
       l.last_update  AS last_update,
       l._ingested_at AS _ingested_at,
       l._source      AS _source
FROM sakila_bronze.language l;
