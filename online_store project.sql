-- SECTION 1: Creating the Database
-- SECTION 2: CREATE TABLES (Database Design + Data Types)

-- Customers Table
CREATE TABLE customer (
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	email VARCHAR(255) UNIQUE NOT NULL,
	phone VARCHAR(15),
	address TEXT,
	date_of_birth DATE,
	created_at TIMESTAMPTZ DEFAULT NOW()
);

--  Categories Table 
CREATE TABLE categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL,
    description     TEXT
);

-- Products Table
CREATE TABLE products (
	product_id SERIAL PRIMARY KEY,
	product_name VARCHAR(255) NOT NULL,
	category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,
	price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
	stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
	created_at TIMESTAMPTZ DEFAULT  NOW ()
);

ALTER TABLE customer
RENAME TO customers;

-- Orders table
CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date      TIMESTAMPTZ DEFAULT NOW(),
    status          VARCHAR(20) DEFAULT 'pending'
                    CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    total_amount    DECIMAL(10, 2) DEFAULT 0
);

-- Order Items table (junction table for M:N between orders and products)
CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      INT REFERENCES products(product_id) ON DELETE CASCADE,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10, 2) NOT NULL
);

-- Payments table
CREATE TABLE payments (
    payment_id      SERIAL PRIMARY KEY,
    order_id        INT REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_date    TIMESTAMPTZ DEFAULT NOW(),
    amount          DECIMAL(10, 2) NOT NULL,
    payment_method  VARCHAR(50) CHECK (payment_method IN ('credit_card', 'debit_card', 'upi', 'net_banking', 'cash')),
    status          VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded'))
);

-- Audit log table (used by trigger)
CREATE TABLE order_audit_log (
    log_id          SERIAL PRIMARY KEY,
    order_id        INT,
    old_status      VARCHAR(20),
    new_status      VARCHAR(20),
    changed_at      TIMESTAMPTZ DEFAULT NOW()
)

-- SECTION 3: Insert sample data (dml - insert)

-- Insert categories
INSERT INTO categories (category_name, description) VALUES 
('Electronics',   'Gadgets and electronic devices'),
('Clothing',      'Apparel and fashion items'),
('Books',         'Physical and digital books'),
('Home & Kitchen','Home appliances and kitchen tools'),
('Sports',        'Sports and fitness equipment');

-- Insert customers
INSERT INTO customers (first_name, last_name, email, phone, address, date_of_birth) VALUES
('Arun',    'Kumar',   'arun.kumar@email.com',   '9876543210', 'Kochi, Kerala',       '1995-04-15'),
('Priya',   'Nair',    'priya.nair@email.com',   '9876543211', 'Thrissur, Kerala',    '1998-07-22'),
('Rahul',   'Menon',   'rahul.menon@email.com',  '9876543212', 'Kozhikode, Kerala',   '1993-11-08'),
('Sneha',   'Thomas',  'sneha.thomas@email.com', '9876543213', 'Trivandrum, Kerala',  '2000-02-28'),
('Vishnu',  'Pillai',  'vishnu.pillai@email.com','9876543214', 'Kollam, Kerala',      '1990-09-10'),
('Anjali',  'Raj',     'anjali.raj@email.com',   '9876543215', 'Ernakulam, Kerala',   '1997-06-05'),
('Deepak',  'Singh',   'deepak.singh@email.com', '9876543216', 'Mumbai, Maharashtra', '1992-12-19'),
('Meera',   'Iyer',    'meera.iyer@email.com',   '9876543217', 'Chennai, Tamil Nadu', '1999-03-14');

-- Insert products
INSERT INTO products (product_name, category_id, price, stock_quantity) VALUES
('Smartphone X12',       1, 29999.00, 50),
('Wireless Earbuds',     1,  2999.00, 100),
('Laptop Pro 15',        1, 75000.00, 20),
('Smart Watch',          1,  8999.00, 35),
('Cotton T-Shirt',       2,   499.00, 200),
('Denim Jeans',          2,  1299.00, 150),
('Running Shoes',        5,  2499.00, 80),
('Python Programming',   3,   599.00, 60),
('Database Systems',     3,   799.00, 40),
('Rice Cooker',          4,  1599.00, 45),
('Coffee Maker',         4,  3499.00, 30),
('Yoga Mat',             5,   899.00, 90);

-- Insert orders
INSERT INTO orders (customer_id, status, total_amount) VALUES
(1, 'delivered',  32998.00),
(2, 'shipped',     3798.00),
(3, 'confirmed',  76299.00),
(4, 'pending',     1398.00),
(5, 'delivered',  11498.00),
(1, 'cancelled',   2999.00),
(6, 'delivered',   1298.00),
(7, 'shipped',     9898.00),
(8, 'pending',      599.00);

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 29999.00),
(1, 2, 1,  2999.00),
(2, 2, 1,  2999.00),
(2, 9, 1,   799.00),
(3, 3, 1, 75000.00),
(3, 8, 1,   599.00),
(3, 9, 1,   700.00),
(4, 5, 2,   499.00),
(4, 6, 1,   400.00),
(5, 4, 1,  8999.00),
(5, 11,1,  2499.00),
(6, 2, 1,  2999.00),
(7, 5, 2,   499.00),
(7, 7, 1,  2499.00),
(7, 12,1,   899.00),
(8, 4, 1,  8999.00),
(8, 10,1,  1599.00),
(8, 2, 1,   300.00),
(9, 8, 1,   599.00);

-- Insert payments
INSERT INTO payments (order_id, amount, payment_method, status) VALUES
(1, 32998.00, 'credit_card',  'completed'),
(2,  3798.00, 'upi',          'completed'),
(3, 76299.00, 'net_banking',  'completed'),
(4,  1398.00, 'debit_card',   'pending'),
(5, 11498.00, 'credit_card',  'completed'),
(6,  2999.00, 'upi',          'refunded'),
(7,  1298.00, 'cash',         'completed'),
(8,  9898.00, 'credit_card',  'completed');

-- SECTION 4 : Basic SQL commands

-- SELECT all customers
SELECT * FROM customers;
 
-- SELECT specific columns
SELECT first_name, last_name, email FROM customers;
 
-- WHERE clause - filter by city
SELECT * FROM customers WHERE address LIKE '%Kerala%';
 
-- ORDER BY - sort products by price descending
SELECT product_name, price FROM products ORDER BY price DESC;
 
-- ORDER BY multiple columns
SELECT first_name, last_name, created_at
FROM customers
ORDER BY last_name ASC, first_name ASC;

-- SECTION 5 Datatypes & operators 

-- Arithmetic operators - calculate discounted price
SELECT
    product_name,
    price,
    price * 0.10                        AS discount_amount,
    price - (price * 0.10)              AS discounted_price
FROM products;

-- Comparison operators - products priced above 5000
SELECT product_name, price
FROM products
WHERE price > 5000;

-- Logical operators - electronics under 10000
SELECT product_name, price, category_id
FROM products
WHERE category_id = 1 AND price < 10000;

-- BETWEEN operator
SELECT product_name, price
FROM products
WHERE price BETWEEN 500 AND 5000;

-- IN operator
SELECT * FROM orders
WHERE status IN ('delivered', 'shipped');

-- SECTION 6 Aggregate Functions

-- COUNT total customers
SELECT COUNT(*) AS total_customers FROM customers;
 
-- SUM total revenue from completed payments
SELECT SUM(amount) AS total_revenue
FROM payments
WHERE status = 'completed';
 
-- AVG average product price
SELECT AVG(price) AS average_price FROM products;
 
-- MIN and MAX product prices
SELECT
    MIN(price) AS cheapest_product,
    MAX(price) AS most_expensive_product
FROM products;
 
-- GROUP BY - total orders per customer
SELECT
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
 
-- HAVING - customers who spent more than 10000
SELECT
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > 10000;
 
-- GROUP BY category - product count and avg price per category
SELECT
    cat.category_name,
    COUNT(p.product_id)  AS total_products,
    ROUND(AVG(p.price),2) AS avg_price,
    SUM(p.stock_quantity) AS total_stock
FROM categories cat
LEFT JOIN products p ON cat.category_id = p.category_id
GROUP BY cat.category_id, cat.category_name
ORDER BY total_products DESC;

-- SECTION 7 Joins

-- INNER JOIN - orders with customer details
SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    o.order_date,
    o.status,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;
 
-- LEFT JOIN - all customers including those with no orders
SELECT
    c.first_name,
    c.last_name,
    o.order_id,
    o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;
 
-- RIGHT JOIN - all orders with customer info
SELECT
    c.first_name,
    c.last_name,
    o.order_id,
    o.total_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;
 
-- FULL OUTER JOIN - all customers and all orders
SELECT
    c.first_name,
    c.last_name,
    o.order_id,
    o.status
FROM customers c
FULL OUTER JOIN orders o ON c.customer_id = o.customer_id;
 
-- Multi-table JOIN - order details with product names
SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
JOIN customers c    ON o.customer_id  = c.customer_id
JOIN order_items oi ON o.order_id     = oi.order_id
JOIN products p     ON oi.product_id  = p.product_id
ORDER BY o.order_id;

-- SECTION 8 Advanced Joins

-- CROSS JOIN - all combinations of categories and payment methods
SELECT
    cat.category_name,
    pay_methods.method
FROM categories cat
CROSS JOIN (
    VALUES ('credit_card'), ('upi'), ('net_banking'), ('cash')
) AS pay_methods(method);
 
-- SELF JOIN - find customers from the same city
SELECT
    a.first_name || ' ' || a.last_name AS customer_1,
    b.first_name || ' ' || b.last_name AS customer_2,
    a.address
FROM customers a
JOIN customers b ON a.address = b.address
    AND a.customer_id < b.customer_id;
 
-- UNION - combine delivered and shipped orders
SELECT order_id, customer_id, status FROM orders WHERE status = 'delivered'
UNION
SELECT order_id, customer_id, status FROM orders WHERE status = 'shipped';
 
-- UNION ALL - includes duplicates
SELECT payment_method FROM payments WHERE status = 'completed'
UNION ALL
SELECT payment_method FROM payments WHERE status = 'refunded';

-- SECTION 9 Subqueries 

-- Subquery in WHERE - customers who placed at least one order
SELECT first_name, last_name, email
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id FROM orders
);
 
-- Subquery in WHERE - products more expensive than average
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;
 
-- Subquery in SELECT - total orders per customer inline
SELECT
    first_name,
    last_name,
    (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count
FROM customers c;
 
-- Subquery in FROM (derived table) - top spending customers
SELECT *
FROM (
    SELECT
        c.first_name,
        c.last_name,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) AS spending_summary
WHERE total_spent > 5000
ORDER BY total_spent DESC;

-- SECTION 10 - Indexes

-- Index on email for faster customer lookup
CREATE INDEX idx_customers_email ON customers(email);
 
-- Index on product name for faster search
CREATE INDEX idx_products_name ON products(product_name);
 
-- Index on order status for faster filtering
CREATE INDEX idx_orders_status ON orders(status);
 
-- Composite index on order_items
CREATE INDEX idx_order_items_order_product ON order_items(order_id, product_id);


-- View all indexes
SELECT indexname, tablename, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename;

-- SECTION 11: VIEWS

-- View 1: Complete order summary
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.email,
    o.order_date,
    o.status,
    o.total_amount,
    pay.payment_method,
    pay.status AS payment_status
FROM orders o
JOIN customers c  ON o.customer_id = c.customer_id
LEFT JOIN payments pay ON o.order_id = pay.order_id;
 
-- View 2: Product inventory with category
CREATE OR REPLACE VIEW vw_product_inventory AS
SELECT
    p.product_id,
    p.product_name,
    cat.category_name,
    p.price,
    p.stock_quantity,
    CASE
        WHEN p.stock_quantity = 0    THEN 'Out of Stock'
        WHEN p.stock_quantity < 20   THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM products p
JOIN categories cat ON p.category_id = cat.category_id;
 
-- View 3: Customer purchase summary
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    COUNT(o.order_id)       AS total_orders,
    SUM(o.total_amount)     AS total_spent,
    MAX(o.order_date)       AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;
 
-- Use the views
SELECT * FROM vw_order_summary;
SELECT * FROM vw_product_inventory WHERE stock_status = 'Low Stock';
SELECT * FROM vw_customer_summary ORDER BY total_spent DESC;

-- SECTION 12: TRANSACTIONS

-- Transaction: Place a new order safely
BEGIN;
 
    -- Step 1: Insert new order
    INSERT INTO orders (customer_id, status, total_amount)
    VALUES (2, 'confirmed', 3898.00);
 
    -- Step 2: Insert order items
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (currval('orders_order_id_seq'), 12, 2, 899.00),
           (currval('orders_order_id_seq'), 8,  1, 599.00);
 
    -- Step 3: Update stock
    UPDATE products SET stock_quantity = stock_quantity - 2 WHERE product_id = 12;
    UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 8;
 
    -- Step 4: Insert payment
    INSERT INTO payments (order_id, amount, payment_method, status)
    VALUES (currval('orders_order_id_seq'), 3898.00, 'upi', 'completed');
 
COMMIT;
 
-- Example of ROLLBACK (if something goes wrong)
BEGIN;
    UPDATE products SET price = 0 WHERE category_id = 1;
    -- Oops! Wrong update — roll it back
ROLLBACK;
 
-- Verify price is unchanged after rollback
SELECT product_name, price FROM products WHERE category_id = 1;


-- SECTION 13: STORED PROCEDURES

-- Procedure 1: Place a new order
CREATE OR REPLACE PROCEDURE place_order(
    p_customer_id   INT,
    p_product_id    INT,
    p_quantity      INT,
    p_payment_method VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_price         DECIMAL(10,2);
    v_total         DECIMAL(10,2);
    v_order_id      INT;
    v_stock         INT;
BEGIN
    -- Get product price and stock
    SELECT price, stock_quantity INTO v_price, v_stock
    FROM products WHERE product_id = p_product_id;
 
    -- Check stock availability
    IF v_stock < p_quantity THEN
        RAISE EXCEPTION 'Not enough stock. Available: %', v_stock;
    END IF;
 
    v_total := v_price * p_quantity;
 
    -- Insert order
    INSERT INTO orders (customer_id, status, total_amount)
    VALUES (p_customer_id, 'confirmed', v_total)
    RETURNING order_id INTO v_order_id;
 
    -- Insert order item
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_quantity, v_price);
 
    -- Reduce stock
    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;
 
    -- Insert payment
    INSERT INTO payments (order_id, amount, payment_method, status)
    VALUES (v_order_id, v_total, p_payment_method, 'completed');
 
    RAISE NOTICE 'Order placed successfully! Order ID: %', v_order_id;
END;
$$;
 
-- Call the procedure
CALL place_order(3, 5, 2, 'upi');
 
-- Procedure 2: Update order status
CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id  INT,
    p_new_status VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET status = p_new_status
    WHERE order_id = p_order_id;
 
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order ID % not found', p_order_id;
    END IF;
 
    RAISE NOTICE 'Order % updated to status: %', p_order_id, p_new_status;
END;
$$;
 
-- Call the procedure
CALL update_order_status(4, 'confirmed');


-- SECTION 14: FUNCTIONS

-- Function 1: Calculate age from date of birth
CREATE OR REPLACE FUNCTION get_customer_age(p_customer_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_dob   DATE;
    v_age   INT;
BEGIN
    SELECT date_of_birth INTO v_dob
    FROM customers WHERE customer_id = p_customer_id;
 
    v_age := DATE_PART('year', AGE(NOW(), v_dob));
    RETURN v_age;
END;
$$;
 
-- Use the function
SELECT
    first_name,
    last_name,
    date_of_birth,
    get_customer_age(customer_id) AS age
FROM customers;
 
-- Function 2: Get total revenue for a category
CREATE OR REPLACE FUNCTION get_category_revenue(p_category_id INT)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    v_revenue DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(oi.quantity * oi.unit_price), 0)
    INTO v_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE p.category_id = p_category_id
      AND o.status != 'cancelled';
 
    RETURN v_revenue;
END;
$$;
 
-- Use the function
SELECT
    category_name,
    get_category_revenue(category_id) AS total_revenue
FROM categories
ORDER BY total_revenue DESC;

-- SECTION 15: TRIGGERS

-- Trigger 1: Log order status changes
CREATE OR REPLACE FUNCTION fn_log_order_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO order_audit_log (order_id, old_status, new_status)
        VALUES (OLD.order_id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$;
 
CREATE TRIGGER trg_order_status_change
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION fn_log_order_status_change();
 
-- Test the trigger
UPDATE orders SET status = 'shipped' WHERE order_id = 4;
UPDATE orders SET status = 'delivered' WHERE order_id = 4;
 
-- Check audit log
SELECT * FROM order_audit_log;
 
-- Trigger 2: Prevent deletion of delivered orders
CREATE OR REPLACE FUNCTION fn_prevent_delete_delivered()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status = 'delivered' THEN
        RAISE EXCEPTION 'Cannot delete a delivered order (Order ID: %)', OLD.order_id;
    END IF;
    RETURN OLD;
END;
$$;
 
CREATE TRIGGER trg_prevent_delete_delivered
BEFORE DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_delete_delivered();
 
-- Test: this should raise an error (order 1 is delivered)
-- DELETE FROM orders WHERE order_id = 1;

-- SECTION 16: DATE AND STRING FUNCTIONS

-- Date functions
SELECT
    first_name,
    date_of_birth,
    AGE(NOW(), date_of_birth)                       AS exact_age,
    DATE_PART('year', AGE(NOW(), date_of_birth))    AS age_years,
    TO_CHAR(date_of_birth, 'DD Month YYYY')         AS formatted_dob,
    DATE_PART('month', date_of_birth)               AS birth_month
FROM customers;
 
-- Orders placed in the last 30 days (simulated)
SELECT order_id, order_date, status
FROM orders
WHERE order_date >= NOW() - INTERVAL '30 days';
 
-- String functions
SELECT
    first_name,
    last_name,
    UPPER(first_name)                               AS upper_name,
    LOWER(email)                                    AS lower_email,
    LENGTH(first_name)                              AS name_length,
    CONCAT(first_name, ' ', last_name)              AS full_name,
    SUBSTRING(email FROM 1 FOR POSITION('@' IN email) - 1) AS email_username,
    TRIM(address)                                   AS trimmed_address
FROM customers;

-- SECTION 17: PERFORMANCE TUNING (Query Optimization)

-- EXPLAIN to see query plan
EXPLAIN SELECT * FROM customers WHERE email = 'arun.kumar@email.com';
 
-- EXPLAIN ANALYZE for actual execution stats
EXPLAIN ANALYZE
SELECT
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;
 
-- Optimized query using index
-- The index idx_customers_email created earlier speeds this up:
SELECT * FROM customers WHERE email = 'priya.nair@email.com';


-- SECTION 18: COMPLEX QUERIES (Showcasing all skills)

-- Query 1: Full sales report
SELECT
    cat.category_name,
    COUNT(DISTINCT p.product_id)            AS total_products,
    COUNT(oi.order_item_id)                 AS total_items_sold,
    SUM(oi.quantity)                        AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price)        AS total_revenue,
    ROUND(AVG(oi.unit_price), 2)            AS avg_selling_price
FROM categories cat
LEFT JOIN products p    ON cat.category_id  = p.category_id
LEFT JOIN order_items oi ON p.product_id   = oi.product_id
LEFT JOIN orders o      ON oi.order_id     = o.order_id
    AND o.status != 'cancelled'
GROUP BY cat.category_id, cat.category_name
ORDER BY total_revenue DESC NULLS LAST;
 
-- Query 2: Top 5 best selling products
SELECT
    p.product_name,
    cat.category_name,
    SUM(oi.quantity)                    AS units_sold,
    SUM(oi.quantity * oi.unit_price)    AS revenue
FROM products p
JOIN categories cat  ON p.category_id  = cat.category_id
JOIN order_items oi  ON p.product_id   = oi.product_id
JOIN orders o        ON oi.order_id    = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY units_sold DESC
LIMIT 5;
 
-- Query 3: Monthly revenue
SELECT
    DATE_TRUNC('month', o.order_date)   AS month,
    COUNT(o.order_id)                   AS total_orders,
    SUM(o.total_amount)                 AS monthly_revenue
FROM orders o
WHERE o.status != 'cancelled'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;
 
-- Query 4: Customers who never placed an order
SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
 
-- Query 5: Payment method analysis
SELECT
    payment_method,
    COUNT(*)            AS total_transactions,
    SUM(amount)         AS total_amount,
    ROUND(AVG(amount),2) AS avg_amount
FROM payments
WHERE status = 'completed'
GROUP BY payment_method
ORDER BY total_amount DESC;

-- END OF PROJECT