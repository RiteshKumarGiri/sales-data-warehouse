-- Product dimension: one row per distinct product.
-- Replace YOUR_PROJECT_ID with your GCP project ID before running.
-- Surrogate keys are numbered alphabetically, so they are only stable while
-- every table is rebuilt together from the same source (see README).
CREATE OR REPLACE TABLE sales_dw.dim_products AS
SELECT ROW_NUMBER() OVER (ORDER BY product_name) AS product_id,
       product_name
FROM (
  SELECT DISTINCT product AS product_name
  FROM `YOUR_PROJECT_ID.sales_dw.sales_py`
);
