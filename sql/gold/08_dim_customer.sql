CREATE TABLE sakila_gold.dim_customer AS
SELECT c.customer_id               AS customer_id,
       c.full_name                 AS full_name,
       c.email                     AS email,
       c.city                      AS city,
       c.country                   AS country,
       c.active                    AS active
FROM sakila_silver.customer c;
