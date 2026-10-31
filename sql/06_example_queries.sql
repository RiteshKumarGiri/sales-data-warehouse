-- Revenue by product through the star schema (matches the flat-table result).
SELECT p.product_name, ROUND(SUM(f.total_price), 2) AS revenue
FROM sales_dw.fact_orders f
JOIN sales_dw.dim_products p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Revenue by quarter: no EXTRACT needed, the date dimension holds the quarter.
SELECT d.year, d.quarter, ROUND(SUM(f.total_price), 2) AS revenue
FROM sales_dw.fact_orders f
JOIN sales_dw.dim_dates d ON f.order_date = d.date
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- Top 5 named customers by spend (customer_id 0 is the shared 'Unknown' row).
SELECT c.customer, ROUND(SUM(f.total_price), 2) AS total_spent
FROM sales_dw.fact_orders f
JOIN sales_dw.dim_customers c ON f.customer_id = c.customer_id
WHERE c.customer_id <> 0
GROUP BY c.customer
ORDER BY total_spent DESC
LIMIT 5;

-- Monthly revenue with previous month, change, and running total.
WITH monthly AS (
  SELECT order_month, SUM(total_price) AS revenue
  FROM `YOUR_PROJECT_ID.sales_dw.sales_py`
  GROUP BY order_month
)
SELECT order_month,
       ROUND(revenue, 2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY order_month), 2) AS prev_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY order_month), 2) AS mom_change,
       ROUND(SUM(revenue) OVER (ORDER BY order_month), 2) AS running_total
FROM monthly
ORDER BY order_month;
