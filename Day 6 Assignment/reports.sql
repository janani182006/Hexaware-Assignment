

-- =========================================================
-- QUESTION 1: EIGHT RETAIL SALES REPORTING QUERIES
-- =========================================================

-- 1. Top 5 Products by Revenue
SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 5;


-- 2. Month-wise Sales
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY sales_month
ORDER BY sales_month;


-- 3. Customers with More Than 3 Orders (HAVING)
SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 3;


-- 4. Average Basket Value per City
SELECT
    c.city,
    ROUND(AVG(oi.order_total), 2) AS avg_basket_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) oi
    ON o.order_id = oi.order_id
GROUP BY c.city;


-- 5. Orders Without Payment (LEFT JOIN)
SELECT
    o.order_id,
    o.order_date
FROM orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;


-- 6. Customers with No Orders
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 7. Product-Category Revenue Share
SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) * 100 /
        NULLIF(
            (SELECT SUM(quantity * unit_price)
             FROM order_items),
            0
        ),
        2
    ) AS revenue_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category;


-- 8. Day with the Highest Sales
SELECT
    DATE(o.order_date) AS sales_day,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE(o.order_date)
ORDER BY total_sales DESC
LIMIT 1;


-- =========================================================
-- QUESTION 2: STRING, DATE AND MATHEMATICAL FUNCTIONS
-- UPPER(), CONCAT(), DATEDIFF(), DATE_FORMAT(), ROUND()
-- =========================================================

SELECT
    UPPER(c.customer_name) AS customer_name,
    CONCAT('Customer ID: ', c.customer_id) AS customer_details,
    DATEDIFF(CURDATE(), o.order_date) AS days_since_order,
    DATE_FORMAT(o.order_date, '%d-%m-%Y') AS formatted_date,
    ROUND(oi.quantity * oi.unit_price, 2) AS total_amount
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id;


-- =========================================================
-- QUESTION 3: DEMONSTRATE NULL BEHAVIOUR
-- COUNT(*), COUNT(column), SUM() AND AVG()
-- =========================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(discount) AS discount_count,
    SUM(discount) AS total_discount,
    AVG(discount) AS average_discount
FROM order_items;


-- =========================================================
-- QUESTION 4: DIFFERENCE BETWEEN WHERE AND HAVING
-- =========================================================

-- WHERE example: filters individual rows before grouping.
SELECT *
FROM orders
WHERE order_date >= '2026-01-01';


-- HAVING example: filters groups after GROUP BY.
SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 3;


-- End of Set 1 – Retail Sales Reporting
