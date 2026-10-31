-- Customer dimension. The customer name is the business key (assumption: one
-- name = one customer in this sample data; see README).
-- 'Unknown' stands in for many anonymous buyers, so it maps to the reserved
-- key 0. It is hardcoded so the reserved row always exists, even if a future
-- load contains no anonymous orders.
CREATE OR REPLACE TABLE sales_dw.dim_customers AS
SELECT ROW_NUMBER() OVER (ORDER BY customer) AS customer_id,
       customer
FROM (
  SELECT DISTINCT customer
  FROM `YOUR_PROJECT_ID.sales_dw.sales_py`
  WHERE customer <> 'Unknown'
)
UNION ALL
SELECT 0 AS customer_id, 'Unknown' AS customer;
