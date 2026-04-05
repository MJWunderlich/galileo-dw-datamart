CREATE TABLE sakila_silver.actor AS
SELECT a.actor_id                             AS actor_id,
       a.first_name                           AS first_name,
       a.last_name                            AS last_name,
       concat(a.first_name, ' ', a.last_name) AS full_name,
       a.last_update                          AS last_update,
       a._ingested_at                         AS _ingested_at,
       a._source                              AS _source
FROM sakila_bronze.actor a;
