-- Date dimension: one row per distinct order date. The date itself is the key.
-- A fuller version would generate every calendar day in a range
-- (GENERATE_DATE_ARRAY) so days with no sales still appear in reports.
CREATE OR REPLACE TABLE sales_dw.dim_dates AS
SELECT DISTINCT
  DATE(order_date)               AS date,
  EXTRACT(YEAR FROM order_date)    AS year,
  EXTRACT(MONTH FROM order_date)   AS month,
  FORMAT_DATE('%B', order_date)    AS month_name,
  EXTRACT(QUARTER FROM order_date) AS quarter,
  FORMAT_DATE('%A', order_date)    AS day_of_week
FROM `YOUR_PROJECT_ID.sales_dw.sales_py`;
