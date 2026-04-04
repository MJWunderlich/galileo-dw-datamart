--------- SILVER: customer ----------

CREATE TABLE sakila_silver.customer AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    concat(c.first_name, ' ', c.last_name) AS full_name,   -- computed
    c.email,
    c.active,
    -- address
    ct.city_id,
    ct.city AS city_name,
    cy.country_id,
    cy.country AS country_name,
    c.create_date,
    c.last_update,
    c._ingested_at,
    c._source
FROM sakila_bronze.customer c
JOIN sakila_bronze.address a ON c.address_id = a.address_id
JOIN sakila_bronze.city ct ON a.city_id = ct.city_id
JOIN sakila_bronze.country cy ON ct.country_id = cy.country_id
