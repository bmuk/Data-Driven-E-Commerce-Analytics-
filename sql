
-- total revenue


SELECT 
    SUM(total_amount) AS total_revenue
FROM 
    orders
WHERE 
    status = 'Delivered';
-- average order values
SELECT 
    AVG(total_amount) AS average_order_value
FROM 
    orders
WHERE 
    status = 'Delivered';
    
-- top selling product

SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    orders o ON oi.order_id = o.order_id
WHERE 
    o.status = 'Delivered'
GROUP BY 
    p.product_name
ORDER BY 
    total_revenue DESC;

-- customer segments

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM 
    orders o
JOIN 
    customer c ON o.customer_id = c.customer_id
WHERE 
    o.status = 'Delivered'
GROUP BY 
    c.customer_id
ORDER BY 
    total_spent DESC;
    
    -- low stock product
    
SELECT 
    p.product_name,
    i.quantity AS stock_level
FROM 
    inventory i
JOIN 
    products p ON i.product_id = p.product_id
WHERE 
    i.quantity < 50;  -- Threshold for low stock
    
    -- overstock product
SELECT 
    p.product_name,
    i.quantity AS stock_level
FROM 
    inventory i
JOIN 
    products p ON i.product_id = p.product_id
WHERE 
    i.quantity > 200;  -- Threshold for overstock
    
    
    -- montly revenue
    
    SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS monthly_revenue
FROM 
    orders
WHERE 
    status = 'Delivered'
GROUP BY 
    month
ORDER BY 
    month;
    
    -- daily revenue
    
SELECT 
    DATE(order_date) AS day,
    SUM(total_amount) AS daily_revenue
FROM 
    orders
WHERE 
    status = 'Delivered'
GROUP BY 
    day
ORDER BY 
    day;
    
    -- repeat customer
    
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders
FROM 
    orders
WHERE 
    status = 'Delivered'
GROUP BY 
    customer_id
HAVING 
    COUNT(order_id) > 1;
    
    -- customer life time values
    
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent,
    COUNT(o.order_id) AS total_orders,
    AVG(o.total_amount) AS avg_order_value
FROM 
    orders o
JOIN 
    customer c ON o.customer_id = c.customer_id
WHERE 
    o.status = 'Delivered'
GROUP BY 
    c.customer_id
ORDER BY 
    total_spent DESC;
    
    -- Orders by Campaign Period
    
    
    SELECT 
    DATE(order_date) AS order_date,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM 
    orders
WHERE 
    status = 'Delivered'
GROUP BY 
    order_date
ORDER BY 
    order_date;
    
    
   -- Indexing for Performance 
    CREATE INDEX idx_customer_email ON customer(email);
CREATE INDEX idx_order_date ON orders(order_date);
CREATE INDEX idx_product_name ON products(product_name);


-- Partitioning Large Tables


ALTER TABLE orders PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p0 VALUES LESS THAN (2020),
    PARTITION p1 VALUES LESS THAN (2021),
    PARTITION p2 VALUES LESS THAN (2022),
    PARTITION p3 VALUES LESS THAN (2023),
    PARTITION p4 VALUES LESS THAN (2024)
);

-- Customer Retention Rate

SELECT 
    COUNT(DISTINCT repeat_customers.customer_id) * 100.0 / COUNT(DISTINCT all_customers.customer_id) AS retention_rate
FROM 
    (SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(order_id) > 1) AS repeat_customers,
    (SELECT customer_id FROM orders) AS all_customers;
    
-- Customer Churn Rate

SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    MAX(o.order_date) AS last_order_date
FROM 
    customer c
LEFT JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id
HAVING 
    last_order_date < DATE_SUB(NOW(), INTERVAL 6 MONTH) 
    OR last_order_date IS NULL;
    
    -- Product Affinity Analysis
    
    SELECT 
    p1.product_name AS product_1, 
    p2.product_name AS product_2, 
    COUNT(*) AS times_bought_together
FROM 
    order_items oi1
JOIN 
    order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
JOIN 
    products p1 ON oi1.product_id = p1.product_id
JOIN 
    products p2 ON oi2.product_id = p2.product_id
GROUP BY 
    p1.product_name, p2.product_name
ORDER BY 
    times_bought_together DESC;
    
