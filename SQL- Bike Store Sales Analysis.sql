# Query 1
SELECT s.store_name,
       ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN stores s ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_revenue DESC;

#Query 2
SELECT *
FROM (
    SELECT c.category_name,
           SUM(oi.quantity) AS total_units_sold
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_name
    ORDER BY total_units_sold DESC
)
WHERE ROWNUM <= 5;

#Query 3
SELECT s.first_name || ' ' || s.last_name AS staff_name,
       COUNT(o.order_id) AS total_orders
FROM orders o
JOIN staffs s ON o.staff_id = s.staff_id
GROUP BY s.first_name, s.last_name
ORDER BY total_orders DESC;

#Query 4
SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month,
       ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2017  -- or latest year available
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month;

#Query 5
SELECT b.brand_name,
       ROUND(AVG(oi.discount) * 100, 2) AS avg_discount_percent
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY avg_discount_percent DESC;

#Query 6 
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 5000
ORDER BY total_spent DESC;

#Query 7 
WITH store_profit AS (
    SELECT s.state,
           s.store_name,
           ROUND(SUM(oi.quantity * (oi.list_price * (1 - oi.discount))), 2) AS total_profit
    FROM stores s
    JOIN orders o ON s.store_id = o.store_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY s.state, s.store_name
)
SELECT state, store_name, total_profit,
       RANK() OVER (PARTITION BY state ORDER BY total_profit DESC) AS state_rank
FROM store_profit
ORDER BY state, state_rank;

#Query 8
WITH category_sales AS (
    SELECT c.category_name,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_name
)
SELECT category_name,
       ROUND(revenue, 2) AS revenue,
       ROUND(revenue / SUM(revenue) OVER () * 100, 2) AS percent_of_total
FROM category_sales
ORDER BY percent_of_total DESC;

#Query 9
WITH yearly_sales AS (
    SELECT EXTRACT(YEAR FROM o.order_date) AS year,
           SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT year,
       ROUND(revenue, 2) AS total_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY year)) / LAG(revenue) OVER (ORDER BY year) * 100, 2) AS growth_rate
FROM yearly_sales
ORDER BY year;

#Query 10
SELECT p.product_name, b.brand_name, s.store_name, st.quantity
FROM stocks st
JOIN products p ON st.product_id = p.product_id
JOIN brands b ON p.brand_id = b.brand_id
JOIN stores s ON st.store_id = s.store_id
WHERE st.quantity < 5
ORDER BY st.quantity ASC;
