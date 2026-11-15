/*
SET 1 – LOGISTICS SHIPMENT ANALYSIS
MySQL 8.4 LTS

Deliverable: advanced_reports.sql

SCHEMA NOTE
The assignment does not provide an existing database schema. This script therefore
creates a normalized sample schema for the stated business scenario:
hubs, employees, carriers, customers, shipments and delivery_events.

Run this script in MySQL Workbench or the MySQL 8.4 command line.
The DROP TABLE statements reset only these assignment tables in the selected
database. Change the database name below if required.
*/

CREATE DATABASE IF NOT EXISTS logistics_shipment_analysis;
USE logistics_shipment_analysis;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS delivery_events;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS carriers;
DROP TABLE IF EXISTS hubs;
SET FOREIGN_KEY_CHECKS = 1;

/* =========================================================
   1. DATABASE SCHEMA
   ========================================================= */

CREATE TABLE hubs (
    hub_id INT PRIMARY KEY,
    hub_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);

CREATE TABLE carriers (
    carrier_id INT PRIMARY KEY,
    carrier_name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(20)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE,
    city VARCHAR(100)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(120) NOT NULL,
    job_title VARCHAR(80) NOT NULL,
    hub_id INT NOT NULL,
    supervisor_id INT NULL,
    CONSTRAINT fk_employee_hub
        FOREIGN KEY (hub_id) REFERENCES hubs(hub_id),
    CONSTRAINT fk_employee_supervisor
        FOREIGN KEY (supervisor_id) REFERENCES employees(employee_id)
);

CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    carrier_id INT NOT NULL,
    origin_hub_id INT NOT NULL,
    destination_hub_id INT NOT NULL,
    handled_by_employee_id INT NULL,
    shipped_at DATE NOT NULL,
    expected_delivery DATE NOT NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_shipment_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_shipment_carrier
        FOREIGN KEY (carrier_id) REFERENCES carriers(carrier_id),
    CONSTRAINT fk_shipment_origin
        FOREIGN KEY (origin_hub_id) REFERENCES hubs(hub_id),
    CONSTRAINT fk_shipment_destination
        FOREIGN KEY (destination_hub_id) REFERENCES hubs(hub_id),
    CONSTRAINT fk_shipment_employee
        FOREIGN KEY (handled_by_employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE delivery_events (
    event_id INT PRIMARY KEY,
    shipment_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_date DATE NOT NULL,
    actual_delivery DATE NULL,
    remarks VARCHAR(255),
    CONSTRAINT fk_event_shipment
        FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

/* =========================================================
   2. SAMPLE DATA
   ========================================================= */

INSERT INTO hubs (hub_id, hub_name, city, region) VALUES
(1, 'Chennai Central Hub', 'Chennai', 'South'),
(2, 'Bengaluru Hub', 'Bengaluru', 'South'),
(3, 'Hyderabad Hub', 'Hyderabad', 'South'),
(4, 'Mumbai Hub', 'Mumbai', 'West'),
(5, 'Kolkata Hub', 'Kolkata', 'East');

INSERT INTO carriers (carrier_id, carrier_name, contact_number) VALUES
(1, 'BlueDart Logistics', '9000000001'),
(2, 'SafeRoute Transport', '9000000002'),
(3, 'SwiftMove Cargo', '9000000003'),
(4, 'National Parcel Service', '9000000004');

INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(1, 'Aarav Traders', 'aarav@example.com', 'Chennai'),
(2, 'Meera Retail', 'meera@example.com', 'Bengaluru'),
(3, 'Kavin Enterprises', 'kavin@example.com', 'Coimbatore'),
(4, 'Nila Stores', 'nila@example.com', 'Hyderabad'),
(5, 'Orbit Technologies', 'orbit@example.com', 'Mumbai'),
(6, 'GreenBasket Foods', 'greenbasket@example.com', 'Kolkata');

INSERT INTO employees (employee_id, employee_name, job_title, hub_id, supervisor_id) VALUES
(101, 'Ravi Kumar', 'Regional Manager', 1, NULL),
(102, 'Priya Shah', 'Operations Supervisor', 1, 101),
(103, 'Arun Das', 'Shipment Executive', 2, 102),
(104, 'Divya Menon', 'Hub Supervisor', 3, 101),
(105, 'Imran Khan', 'Delivery Coordinator', 4, 104),
(106, 'Sana Roy', 'Shipment Executive', 5, 104),
(107, 'Vikram Rao', 'Operations Associate', 2, 103);

INSERT INTO shipments
(shipment_id, customer_id, carrier_id, origin_hub_id, destination_hub_id,
 handled_by_employee_id, shipped_at, expected_delivery, shipping_cost) VALUES
(1001, 1, 1, 1, 2, 102, '2026-10-01', '2026-10-03', 1200.00),
(1002, 2, 2, 2, 3, 103, '2026-10-02', '2026-10-04', 900.00),
(1003, 3, 1, 1, 4, 102, '2026-10-03', '2026-10-05', 1500.00),
(1004, 1, 3, 3, 1, 104, '2026-10-04', '2026-10-06', 1100.00),
(1005, 4, 2, 2, 1, 103, '2026-10-05', '2026-10-07', 700.00),
(1006, 5, 3, 4, 2, 105, '2026-10-06', '2026-10-08', 1800.00),
(1007, 2, 1, 1, 3, 102, '2026-10-07', '2026-10-09', 1000.00),
(1008, 6, 2, 5, 1, 106, '2026-10-08', '2026-10-10', 1300.00),
(1009, 3, 3, 3, 4, 104, '2026-10-09', '2026-10-11', 1600.00),
(1010, 1, 1, 1, 5, 102, '2026-10-10', '2026-10-12', 2000.00),
(1011, 5, 2, 4, 3, 105, '2026-10-11', '2026-10-13', 1400.00),
(1012, 6, 3, 5, 2, 106, '2026-10-12', '2026-10-14', 1250.00),
(1013, 2, 1, 2, 4, 103, '2026-10-13', '2026-10-15', 950.00),
(1014, 4, 2, 2, 3, 103, '2026-10-14', '2026-10-16', 850.00);

INSERT INTO delivery_events
(event_id, shipment_id, event_type, event_date, actual_delivery, remarks) VALUES
(1, 1001, 'DELIVERED', '2026-10-07', '2026-10-07', 'Traffic delay'),
(2, 1002, 'DELIVERED', '2026-10-05', '2026-10-05', 'Delivered'),
(3, 1003, 'DELIVERED', '2026-10-09', '2026-10-09', 'Weather delay'),
(4, 1004, 'DELIVERED', '2026-10-06', '2026-10-06', 'Delivered on time'),
(5, 1005, 'DELIVERED', '2026-10-11', '2026-10-11', 'Route disruption'),
(6, 1006, 'DELIVERED', '2026-10-08', '2026-10-08', 'Delivered on time'),
(7, 1007, 'DELIVERED', '2026-10-12', '2026-10-12', 'Heavy rain'),
(8, 1008, 'DELIVERED', '2026-10-10', '2026-10-10', 'Delivered on time'),
(9, 1009, 'DELIVERED', '2026-10-15', '2026-10-15', 'Vehicle issue'),
(10, 1010, 'DELIVERED', '2026-10-12', '2026-10-12', 'Delivered on time'),
(11, 1011, 'DELIVERED', '2026-10-17', '2026-10-17', 'Late delivery'),
(12, 1012, 'DELIVERED', '2026-10-14', '2026-10-14', 'Delivered on time'),
(13, 1013, 'DELIVERED', '2026-10-15', '2026-10-15', 'Delivered on time'),
(14, 1014, 'DELIVERED', '2026-10-20', '2026-10-20', 'Late delivery');

/* =========================================================
   3. TEN BUSINESS QUESTIONS USING JOINS
   ========================================================= */

/* Q1. Find shipments delayed by more than two days, with carrier,
       origin hub, destination hub and delay in days.
       INNER JOIN is used because matching shipment, carrier, hub and
       delivery-event records are required. */
SELECT
    s.shipment_id,
    c.carrier_name,
    oh.hub_name AS origin_hub,
    dh.hub_name AS destination_hub,
    de.actual_delivery,
    DATEDIFF(de.actual_delivery, s.expected_delivery) AS delay_days
FROM shipments s
INNER JOIN carriers c ON c.carrier_id = s.carrier_id
INNER JOIN hubs oh ON oh.hub_id = s.origin_hub_id
INNER JOIN hubs dh ON dh.hub_id = s.destination_hub_id
INNER JOIN delivery_events de ON de.shipment_id = s.shipment_id
WHERE de.actual_delivery IS NOT NULL
  AND DATEDIFF(de.actual_delivery, s.expected_delivery) > 2
ORDER BY delay_days DESC;

/* Q2. List every hub and its outbound shipment count, including hubs
       with zero outbound shipments.
       LEFT JOIN preserves every row from hubs. */
SELECT
    h.hub_id,
    h.hub_name,
    COUNT(s.shipment_id) AS outbound_shipment_count
FROM hubs h
LEFT JOIN shipments s ON s.origin_hub_id = h.hub_id
GROUP BY h.hub_id, h.hub_name
ORDER BY h.hub_id;

/* Q3. Show employees and their supervisors.
       This is a self join because both employee and supervisor are
       rows in the employees table. */
SELECT
    e.employee_id,
    e.employee_name AS employee,
    e.job_title,
    COALESCE(m.employee_name, 'No supervisor') AS supervisor
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.supervisor_id
ORDER BY e.employee_id;

/* Q4. List all shipments with customer and carrier details.
       RIGHT JOIN keeps all carrier rows, including carriers with no
       shipment. */
SELECT
    c.carrier_id,
    c.carrier_name,
    s.shipment_id,
    cu.customer_name,
    s.shipping_cost
FROM shipments s
RIGHT JOIN carriers c ON c.carrier_id = s.carrier_id
LEFT JOIN customers cu ON cu.customer_id = s.customer_id
ORDER BY c.carrier_id, s.shipment_id;

/* Q5. Find customers who have shipped more than once, with shipment count
       and total shipping spend. */
SELECT
    cu.customer_id,
    cu.customer_name,
    COUNT(s.shipment_id) AS shipment_count,
    SUM(s.shipping_cost) AS total_shipping_spend
FROM customers cu
INNER JOIN shipments s ON s.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.customer_name
HAVING COUNT(s.shipment_id) > 1
ORDER BY total_shipping_spend DESC;

/* Q6. Find customers who have shipped to EVERY hub.
       NOT EXISTS performs relational division: there must not be a hub
       for which the customer has no shipment.
       IN identifies the set of destination hubs reached by that customer. */
SELECT
    cu.customer_id,
    cu.customer_name
FROM customers cu
WHERE NOT EXISTS (
    SELECT 1
    FROM hubs h
    WHERE h.hub_id NOT IN (
        SELECT s.destination_hub_id
        FROM shipments s
        WHERE s.customer_id = cu.customer_id
    )
)
ORDER BY cu.customer_id;

/* Q7. Find carriers whose average delivery delay is greater than the
       overall average delay. ALL is used against the one-row result
       containing the overall average. */
SELECT
    c.carrier_id,
    c.carrier_name,
    AVG(DATEDIFF(de.actual_delivery, s.expected_delivery)) AS avg_delay_days
FROM carriers c
INNER JOIN shipments s ON s.carrier_id = c.carrier_id
INNER JOIN delivery_events de ON de.shipment_id = s.shipment_id
WHERE de.actual_delivery IS NOT NULL
GROUP BY c.carrier_id, c.carrier_name
HAVING AVG(DATEDIFF(de.actual_delivery, s.expected_delivery)) > ALL (
    SELECT AVG(DATEDIFF(de2.actual_delivery, s2.expected_delivery))
    FROM shipments s2
    INNER JOIN delivery_events de2 ON de2.shipment_id = s2.shipment_id
    WHERE de2.actual_delivery IS NOT NULL
)
ORDER BY avg_delay_days DESC;

/* Q8. Find shipments whose shipping cost is greater than ANY average
       shipment cost recorded for a hub. This demonstrates ANY for a
       comparison against a set of values. */
SELECT
    s.shipment_id,
    s.shipping_cost,
    h.hub_name AS origin_hub
FROM shipments s
INNER JOIN hubs h ON h.hub_id = s.origin_hub_id
WHERE s.shipping_cost > ANY (
    SELECT AVG(s2.shipping_cost)
    FROM shipments s2
    GROUP BY s2.origin_hub_id
)
ORDER BY s.shipping_cost DESC;

/* Q9. Find hubs that have at least one outbound shipment using EXISTS.
       EXISTS checks whether a matching row is present. */
SELECT
    h.hub_id,
    h.hub_name
FROM hubs h
WHERE EXISTS (
    SELECT 1
    FROM shipments s
    WHERE s.origin_hub_id = h.hub_id
)
ORDER BY h.hub_id;

/* Q10. Show shipment counts for every destination hub, including hubs
        that have not received any shipment.
        RIGHT JOIN preserves all destination hubs. */
SELECT
    h.hub_id,
    h.hub_name,
    COUNT(s.shipment_id) AS inbound_shipment_count
FROM shipments s
RIGHT JOIN hubs h ON h.hub_id = s.destination_hub_id
GROUP BY h.hub_id, h.hub_name
ORDER BY h.hub_id;

/* =========================================================
   4. TWO SUBQUERIES REWRITTEN AS JOINS
   ========================================================= */

/* Rewrite 1A – Subquery version:
   Customers who have at least one shipment. */
SELECT customer_id, customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM shipments
);

/* Rewrite 1B – Equivalent JOIN version. DISTINCT avoids duplicate
   customers when a customer has multiple shipments. */
SELECT DISTINCT cu.customer_id, cu.customer_name
FROM customers cu
INNER JOIN shipments s ON s.customer_id = cu.customer_id;

/* Rewrite 2A – Subquery version:
   Shipments costing more than the overall average shipping cost. */
SELECT shipment_id, shipping_cost
FROM shipments
WHERE shipping_cost > (
    SELECT AVG(shipping_cost)
    FROM shipments
);

/* Rewrite 2B – JOIN to a derived table containing the overall average.
   The derived table has one row, so each shipment is compared with
   the same average value. */
SELECT s.shipment_id, s.shipping_cost
FROM shipments s
CROSS JOIN (
    SELECT AVG(shipping_cost) AS overall_avg_cost
    FROM shipments
) avg_cost
WHERE s.shipping_cost > avg_cost.overall_avg_cost;

/* =========================================================
   5. NESTED SUBQUERY – SECOND-HIGHEST SHIPPING COST PER HUB
   ========================================================= */

/* Returns the second-highest DISTINCT shipping cost for each origin hub.
   The inner query finds the maximum cost below the hub's highest cost.
   Hubs with fewer than two distinct costs return NULL. */
SELECT
    h.hub_id,
    h.hub_name,
    (
        SELECT MAX(s2.shipping_cost)
        FROM shipments s2
        WHERE s2.origin_hub_id = h.hub_id
          AND s2.shipping_cost < (
              SELECT MAX(s3.shipping_cost)
              FROM shipments s3
              WHERE s3.origin_hub_id = h.hub_id
          )
    ) AS second_highest_shipping_cost
FROM hubs h
ORDER BY h.hub_id;

/* =========================================================
   6. OPTIONAL VALIDATION QUERIES
   ========================================================= */

SELECT COUNT(*) AS total_hubs FROM hubs;
SELECT COUNT(*) AS total_carriers FROM carriers;
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_shipments FROM shipments;
SELECT COUNT(*) AS total_delivery_events FROM delivery_events;
