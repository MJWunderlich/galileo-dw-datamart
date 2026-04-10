CREATE TABLE sakila_gold.dim_actor AS
SELECT a.actor_id                             AS actor_id,
       a.first_name                           AS first_name,
       a.last_name                            AS last_name,
       a.full_name                            AS full_name
FROM sakila_silver.actor AS a;
