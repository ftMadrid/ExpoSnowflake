-- levantar el warehouse en snowflake
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE WAREHOUSE WH_EXPO_PAGILA WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;
CREATE OR REPLACE DATABASE PAGILA_DWH;
USE DATABASE PAGILA_DWH;
USE SCHEMA PUBLIC;

CREATE OR REPLACE TABLE FACT_FILM_REVENUE (
    film_id INT,
    title STRING,
    category_name STRING,
    rental_rate FLOAT,
    total_rentals INT,
    total_revenue FLOAT
);

-- exportar a csv
SELECT f.film_id, 
       f.title, 
       c.name AS category_name, 
       f.rental_rate::float,
       COUNT(r.rental_id) AS total_rentals,
       COALESCE(SUM(p.amount), 0) AS total_revenue
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title, c.name, f.rental_rate
ORDER BY total_revenue DESC;

-- datos en snowflake
SELECT * FROM FACT_FILM_REVENUE
ORDER BY TOTAL_REVENUE DESC;