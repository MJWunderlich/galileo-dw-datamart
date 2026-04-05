CREATE TABLE sakila_silver.category AS
SELECT c.category_id  AS category_id,
       c.name         AS category_name,
       c.last_update  AS last_update,
       c._ingested_at AS _ingested_at,
       c._source      AS _source
FROM sakila_bronze.category c;
