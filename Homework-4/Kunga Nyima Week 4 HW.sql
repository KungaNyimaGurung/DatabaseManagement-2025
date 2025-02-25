Use BikeStores;
/*
1.QQ::Count of Orders Per Year (With Order Type Filtering)
Task: Count orders per year, but only include:

-Orders placed after 2015 (WHERE filter)
-Only customers with at least 3 orders (HAVING filter)
*/
SELECT 
    DATEPART(YEAR,order_date) AS ORDER_YEAR,
    COUNT(*) AS TOTAL_ORDERS
FROM 
    Sales.Orders
WHERE 
    order_date > '2015-01-01'
GROUP BY 
    DATEPART(YEAR, order_date), customer_id
HAVING 
    COUNT(order_id) >= 3
ORDER BY 
    order_year;

/*
2.QQ:Customer Spending Summary (SUM, AVG, and MIN/MAX with HAVING)
Task: Show each order numbers total spending, average order value, and highest order amount, but only for:

-order numbers that spent more than $5,000 total
-Only include customers with an average order value above $200
*/
SELECT 
    order_id,
    SUM(list_price) AS total_spending,
    AVG(list_price) AS avg_order_value,
    MAX(list_price) AS highest_order_amount
FROM 
    Sales.Order_Items
GROUP BY 
    order_id
HAVING 
    SUM(list_price) > 5000
    AND AVG(list_price) > 200
ORDER BY 
    order_id;

/*
3.QQ:Total Revenue Per Category (Filtered by Min Sales)
Task: Find total revenue per product category (item_id), but:

-Only include item_ids where at least 5 products have been sold
-Only include sales after 2018
*/
SELECT 
    oi.item_id,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM 
    Sales.Order_Items oi
JOIN 
    Sales.Orders o ON oi.order_id = o.order_id
WHERE 
    o.order_date > '2018-01-01'  -- Include only sales after 2018
GROUP BY 
    oi.item_id
HAVING 
    SUM(oi.quantity) >= 5  -- Only include item_ids with at least 5 products sold
ORDER BY 
    total_revenue DESC;


/*
4.QQ:Average Discount Per Order Status
Task: Calculate the average discount for each order id, but only:

-Include statuses that had at least 5 orders

*/

SELECT 
    o.order_status,
    AVG(oi.list_price * oi.discount) AS avg_discount
FROM 
    Sales.Order_Items oi
JOIN 
    Sales.Orders o ON oi.order_id = o.order_id
GROUP BY 
    o.order_status
HAVING 
    COUNT(o.order_id) >= 5  -- Only include statuses with at least 5 orders
ORDER BY 
    avg_discount DESC;

/*
5.QQ:Top and Bottom Selling Products
Task: Show best and worst-selling products, but:

-Exclude products with fewer than 5 total sales
-Exclude products with over 1,000 sales
*/
SELECT 
    oi.product_id,
    SUM(oi.quantity) AS total_sales
FROM 
    Sales.Order_Items oi
JOIN 
    Sales.Orders o ON oi.order_id = o.order_id
GROUP BY 
    oi.product_id
HAVING 
    SUM(oi.quantity) >= 5  -- Exclude products with fewer than 5 sales
    AND SUM(oi.quantity) <= 1000  -- Exclude products with more than 1,000 sales
ORDER BY 
    total_sales DESC;  -- Best-selling products first

/*
6.QQ:Monthly Revenue Breakdown (CASE WHEN + SUM)
Show total revenue per quarter, categorizing months as follows:

Q1: January - March
Q2: April - June
Q3: July - September
Q4: October - December
*/
SELECT 
    CASE 
        WHEN MONTH(o.order_date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(o.order_date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(o.order_date) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(o.order_date) BETWEEN 10 AND 12 THEN 'Q4'
    END AS quarter,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM 
    Sales.Order_Items oi
JOIN 
    Sales.Orders o ON oi.order_id = o.order_id
GROUP BY 
    CASE 
        WHEN MONTH(o.order_date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(o.order_date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(o.order_date) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(o.order_date) BETWEEN 10 AND 12 THEN 'Q4'
    END
ORDER BY 
    quarter;

/*
7.QQ:High-Value Customers and Their Last Order
Find products that have generated more than $10,000 in total revenue.

-Use the Sales.Order_Items table only.
-Calculate total sales per product (SUM(quantity * list_price * (1 - discount))).
-Filter for products with total sales above $10,000.
-Sort the results in descending order of total sales.
*/

SELECT 
    product_id,
    SUM(quantity * list_price * (1 - discount)) AS total_sales
FROM 
    Sales.Order_Items
GROUP BY 
    product_id
HAVING 
    SUM(quantity * list_price * (1 - discount)) > 10000  -- Filter for products with total sales above $10,000
ORDER BY 
    total_sales DESC;  -- Sort by total sales in descending order

/*
8.QQ:DELETE: Remove Orders Before 2015
Task: Delete all orders that were placed before January 1, 2015.
*/
DELETE FROM Sales.Orders
WHERE order_date < '2015-01-01';

/*
9.QQ:UPDATE: Increase Prices for Older Products
Task: Increase the price of all products from model year 2018 or older by 10%.
*/
UPDATE Production.Products
SET list_price = list_price * 1.10  -- Increase price by 10%
WHERE model_year <= 2018;-- Select products from model year 2018 or older

/*
10.QQ:INSERT: Add a New Customer
Task: Insert a new customer into Sales.Customers.
*/
INSERT INTO Sales.Customers ( first_name, last_name, phone,email,street,city,state,zip_code)
VALUES ( 'Kunga', 'Gurung','929-727-8830','kungagrg@gmail.com','8420 Britton Ave','NY','Queens','11373');


/*
11.QQ:DELETE Task:
-Delete customers who have never placed an order (i.e., they do not exist in Sales.Orders).
-Only remove them if their email is not a store email (@bikestores.com).
*/
DELETE FROM Sales.Customers
WHERE customer_id NOT IN (  -- Select customers who have never placed an order
    SELECT DISTINCT customer_id
    FROM Sales.Orders
)
AND email NOT LIKE '%@bikestores.com';  -- Exclude store email addresses

/*
12.QQ:INSERT Statement: Add a New Order & Order Items
Task:
-Add a new order for an existing customer (ID: 105).
-The order should have status 1 (Pending) and be required within 7 days.
-Also, add two products to the order.
*/
DECLARE @OrderID INT;

-- Insert a new order
INSERT INTO sales.orders (customer_id, order_status, order_date, required_date, store_id, staff_id)
VALUES 
(105, 1, GETDATE(), DATEADD(DAY, 7, GETDATE()), 1, 2);

-- Get the newly created order_id
SET @OrderID = SCOPE_IDENTITY();

-- Insert order items for the new order
INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
VALUES
(@OrderID, 1, 5, 2, 1299.99, 0.10), -- Product 1
(@OrderID, 2, 12, 1, 799.99, 0.05); -- Product 2







/*
13.QQ:Task:
-Delete customers who have never placed an order (i.e., they do not exist in Sales.Orders).
-Only remove them if their email is not a store email (@bikestores.com).
*/

DELETE FROM Sales.Customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM Sales.Orders
)
AND email NOT LIKE '%@bikestores.com';
