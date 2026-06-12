# Online Store Relational Database

A fully structured relational database for an online store, built using **PostgreSQL**. This project was designed to demonstrate core and advanced SQL concepts including table design, normalization, joins, subqueries, stored procedures, triggers, views, transactions, and query optimization.

---

## ER Diagram

> Import the `online_store.sql` file and run it in pgAdmin to set up the full database. Add a screenshot of the ER diagram here.

---

## Database Schema

| Table | Description |
|---|---|
| `customers` | Stores customer personal details |
| `categories` | Product category information |
| `products` | Product listings with price and stock |
| `orders` | Customer orders with status tracking |
| `order_items` | Individual items within each order |
| `payments` | Payment records for each order |
| `order_audit_log` | Automatic log of order status changes (via trigger) |

---

## Concepts Covered

- **Database Design** — Normalization, ER diagrams, primary and foreign keys
- **Data Types** — SERIAL, VARCHAR, CHAR, TEXT, DECIMAL, INT, TINYINT, DATE, TIMESTAMPTZ
- **Basic SQL** — SELECT, WHERE, ORDER BY, BETWEEN, IN, LIKE
- **DML** — INSERT, UPDATE, DELETE
- **Aggregate Functions** — COUNT, SUM, AVG, MIN, MAX with GROUP BY and HAVING
- **Joins** — INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF JOIN
- **Set Operations** — UNION, UNION ALL
- **Subqueries** — In WHERE, SELECT, and FROM clauses
- **Indexes** — Single column and composite indexes for performance
- **Views** — Order summary, product inventory, customer summary
- **Transactions** — BEGIN, COMMIT, ROLLBACK
- **Stored Procedures** — Place order, update order status
- **Functions** — Calculate customer age, get category revenue
- **Triggers** — Audit log on status change, prevent deletion of delivered orders
- **Date and String Functions** — AGE, DATE_PART, TO_CHAR, CONCAT, SUBSTRING
- **Query Optimization** — EXPLAIN, EXPLAIN ANALYZE, index usage

---

## How to Set It Up

### Requirements
- PostgreSQL installed on your system
- pgAdmin or any PostgreSQL client

### Steps

1. Open pgAdmin and connect to your PostgreSQL server
2. Create a new database called `online_store`
3. Open the Query Tool for that database
4. Open the `online_store.sql` file via File → Open
5. Press **F5** to run the full script
6. All tables, data, views, procedures, and triggers will be created automatically

---

## Sample Queries

**Top spending customers:**
```sql
SELECT
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
```

**Best selling products:**
```sql
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 5;
```

**Place an order using stored procedure:**
```sql
CALL place_order(3, 5, 2, 'upi');
```

---

## Project Structure

```
online-store-db/
│
├── online_store.sql       -- Full database script
└── README.md              -- Project documentation
```

---

## Author

Built as part of a database design course project covering relational database concepts using PostgreSQL.
