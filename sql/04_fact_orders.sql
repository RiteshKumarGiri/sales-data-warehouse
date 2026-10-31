-- Fact table: one row per order. LEFT JOINs keep every order even if a
-- dimension key fails to match; 05_validation_checks.sql then counts orphans.
CREATE OR REPLACE TABLE sales_dw.fact_orders AS
SELECT a.order_id,
       b.customer_id,
       c.product_id,
       DATE(a.order_date) AS order_date,
       a.quantity,
       a.price,
       a.total_price
FROM `YOUR_PROJECT_ID.sales_dw.sales_py` a
LEFT JOIN sales_dw.dim_customers b ON a.customer = b.customer
LEFT JOIN sales_dw.dim_products  c ON a.product  = c.product_name;
