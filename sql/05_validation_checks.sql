-- Run these after building the star schema. BigQuery does not enforce primary
-- or foreign keys, so these checks are the enforcement.

-- 1. Dimension keys are unique (all three numbers should be equal per table).
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT customer) AS distinct_names,
       COUNT(DISTINCT customer_id) AS distinct_ids
FROM sales_dw.dim_customers;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT product_name) AS distinct_names,
       COUNT(DISTINCT product_id) AS distinct_ids
FROM sales_dw.dim_products;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT date) AS distinct_dates
FROM sales_dw.dim_dates;

-- 2. Fact grain: one row per order, no orphan keys.
SELECT COUNT(*) AS rows_,
       COUNT(DISTINCT order_id) AS distinct_orders,
       ROUND(SUM(total_price), 2) AS revenue,
       COUNTIF(customer_id IS NULL OR product_id IS NULL) AS orphans
FROM sales_dw.fact_orders;

-- 3. Reconcile against the flat source table (rows and revenue must match).
SELECT COUNT(*) AS rows_, ROUND(SUM(total_price), 2) AS revenue
FROM `YOUR_PROJECT_ID.sales_dw.sales_py`;

-- 4. Every fact date exists in the date dimension.
SELECT COUNT(*) AS missing_dates
FROM sales_dw.fact_orders f
LEFT JOIN sales_dw.dim_dates d ON f.order_date = d.date
WHERE d.date IS NULL;

-- 5. Date range sanity check. The sample generator only produces dates from
-- 2024-01-01 to 2024-10-27, so anything later was misread (see README, known
-- limitations). Adjust the bounds for your own data.
SELECT MIN(date) AS first_date,
       MAX(date) AS last_date,
       COUNTIF(date > '2024-10-27') AS impossible_dates
FROM sales_dw.dim_dates;
