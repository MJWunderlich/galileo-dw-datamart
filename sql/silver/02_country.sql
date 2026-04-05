CREATE TABLE sakila_silver.country AS
SELECT c.country_id   AS country_id,
       c.country      AS country,
       c.last_update  AS last_update,
       c._ingested_at AS _ingested_at,
       c._source      AS _source
FROM sakila_bronze.country c;
