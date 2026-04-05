CREATE TABLE sakila_silver.staff AS
SELECT
    st.staff_id     AS staff_id,
    st.first_name   AS first_name,
    st.last_name    AS last_name,
    concat(st.first_name, ' ', st.last_name) AS full_name,
    st.email        AS email,
    st.active       AS active,
    st.username     AS username,
    st.store_id     AS store_id,
    a.address_id    AS address_id,
    a.address       AS address,
    a.city_id       AS city_id,
    a.city          AS city,
    a.country_id    AS country_id,
    a.country       AS country,
    st.last_update  AS last_update,
    st._ingested_at AS _ingested_at,
    st._source      AS _source
FROM sakila_bronze.staff st
JOIN sakila_silver.address a ON st.address_id = a.address_id;
