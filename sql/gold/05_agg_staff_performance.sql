CREATE TABLE sakila_gold.agg_staff_performance AS
SELECT st.staff_id                  AS staff_id,
       st.full_name                 AS full_name,
       st.store_id                  AS store_id,
       st.city                      AS city,
       st.country                   AS country,
       COUNT(DISTINCT r.rental_id)  AS total_rentals_processed,
       COUNT(DISTINCT p.payment_id) AS total_payments_processed,
       SUM(p.amount)                AS total_revenue_collected
FROM sakila_silver.staff st
         LEFT JOIN sakila_silver.rental r ON st.staff_id = r.staff_id
         LEFT JOIN sakila_silver.payment p ON st.staff_id = p.staff_id
GROUP BY st.staff_id,
         st.full_name,
         st.store_id,
         st.city,
         st.country;
