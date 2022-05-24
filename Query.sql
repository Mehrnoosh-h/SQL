USE sql_store;
SELECT 
name,
unit_price,
unit_price * 1.1 As 'new price'
FROM products

SELECT * 
FROM  customers
-- WHERE points >= 3000
-- WHERE state = 'VA'
-- WHERE state <> 'VA'
WHERE birth_date > '1990-01-01'

SELECT * 
FROM customers
-- WHERE birth_date >= '1990-01-01' OR 
-- (points > 1000 AND state = 'VA')
WHERE NOT (birth_date > '1990-01-01' OR points > 1000)
-- not or is and and everything inside () will be negative

SELECT *
FROM Customers
WHERE state IN ('VA' , 'FL', 'GA')

SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72)

SELECT *
FROM customers
-- WHERE points >= 1000 AND points <= 3000
WHERE points BETWEEN 1000 AND 3000

SELECT * 
FROM customers 
WHERE birth_date BETWEEN '1990-01-01' AND '2000-01-01'

SELECT * 
FROM customers
WHERE last_name LIKE 'b%'
-- % means any characters after b and it starts with b
WHERE last_name LIKE 'brush%'
WHERE last_name LIKE '%b%'
WHERE last_name LIKE '%y'
WHERE last_name LIKE '_y'
-- customers whos last name have 2 characters and lat one is y

SELECT * 
FROM customers
WHERE last_name LIKE 'b____y'
-- so use % any number of characters 
-- use _ single chracter

SELECT * 
FROM customers 
WHERE address LIKE '%trail%' OR
      address LIKE '%avenue%'
      
SELECT * 
FROM customers 
WHERE phone NOT LIKE '%9'

-- searching string in a column
SELECT *
FROM customers
-- These 2 lines are exactly the same REGEXP is regular expectation
WHERE last_name LIKE '%field%'
WHERE last_name REGEXP 'field'
WHERE last_name REGEXP '^f' -- start with f
WHERE last_name REGEXP 'f$'

SELECT *
FROM customers
WHERE last_name REGEXP 'field|mac|rose' -- have field or mac or rose  in last name 
WHERE last_name REGEXP '^field|mac|rose' -- or has field at the begining
WHERE last_name REGEXP 'field|mac|rose$' -- or has rose at the end
WHERE last_name REGEXP '[gim]e'  -- last name should have ge or ie or me in it
WHERE last_name REGEXP 'e[fmq]' -- last name should have ef or em or eq in it
WHERE last_name REGEXP 'e[a-h]' -- last name should have e with abcdefgh in it

-- ^ begining
-- $ end
-- | logical or
-- [a-h] a range
-- [emf]e

SELECT * 
FROM customers
WHERE first_name REGEXP 'elka|ambur'

SELECT * 
FROM customers
WHERE last_name REGEXP 'ey$|on$'

SELECT * 
FROM customers
WHERE last_name REGEXP '^my|se'

SELECT * 
FROM customers
WHERE last_name REGEXP 'b[ru]'

-- null values
SELECT *
FROM customers 
WHERE phone IS NOT NULL

SELECT * 
FROM orders 
WHERE shipped_date IS NULL

-- ------ sorting
SELECT * 
FROM customers 
ORDER BY first_name DESC

SELECT * 
FROM customers 
ORDER BY state , first_name  -- order  the customers by states and in each state by first name

SELECT * 
FROM customers 
ORDER BY state DESC, first_name 

SELECT first_name , last_name, 10 AS points
FROM customers
Order BY birth_date, points

SELECT * , quantity * unit_price AS total_price
FROM order_items
WHERE order_id = 2
ORDER By total_price DESC

-- -------limit the number of returns
-- the first 3 customers
SELECT * 
FROM customers
LIMIT 3
 -- customers in diff pages
 -- page 1: 1-3
 -- page 2: 4-6
 
 -- page 3: 7-9
SELECT * 
FROM customers
LIMIT 6, 3   -- skip the first 6 and select the next 3

-- select the most loyal customers
SELECT * 
FROM customers
ORDER BY points DESC
LIMIT 3 -- limit always should be at the end

-- inner joins
-- exm: in orders instead of customer-id show the full name
-- in the result here we first have orders columns because it comes first
-- orders.customer_id when we have the same name column in diff tables should say the name f the table in the begining

SELECT order_id, orders.customer_id, first_name, last_name  
FROM orders
JOIN customers 
     ON orders.customer_id = customers.customer_id

-- we can select an short alias for tables to avid repeating
SELECT order_id, o.customer_id, first_name, last_name  
FROM orders o
JOIN customers c
     ON o.customer_id = c.customer_id

SELECT order_id, oi.product_id, quantity, oi.unit_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id

-- join across databases
-- here sql_dtore in bold in left so we are writing on that. because earlier we choose (USE) it in the code
-- you should prefix the tables that are not in the current database like sql_inventory.products
SELECT * 
FROM order_items oi
JOIN sql_inventory.products p
     ON   oi.product_id = p.product_id
     
-- Self join
USE sql_hr;
SELECT e.employee_id, e.first_name, m.first_name AS manager
FROM employees e
JOIN employees m
     ON e.reports_to = m.employee_id
     
-- join multiple tables
USE sql_store;
SELECT o.order_id, o.order_date, c.first_name, c.last_name, os.name as status
FROM orders o
JOIN customers c
     ON o.customer_id = c.customer_id
JOIN order_statuses os
     ON  o.status =  os.order_status_id
     
USE sql_invoicing;
SELECT p.date,
       p.invoice_id, 
       p.amount,
       c. name,
       pm.name
FROM payments p
JOIN payment_methods pm
     ON p.payment_method = pm. payment_method_id
JOIN clients c
     ON p.client_id = c.client_id

-- compound join condition
SELECT *
FROM order_items oi
JOIN order_item_notes oin
     ON oi.order_id = oin.order_id
     AND oi.product_id = oin.product_id

-- implicit join syntax
SELECT * 
FROM orders o
JOIN customers c
     ON o.customer_id = c.customer_id
-- we can write like this:
SELECT *
FROM orders o, customers c
WHERE o.customer_id = c.customer_id  

-- outer join
-- Here you can only see the orders donebut some customers d not have order, we need to do outer join
SELECT 
	c.customer_id,
	c.first_name,
    o.order_id
FROM customers c
JOIN orders o
     ON c.customer_id = o.customer_id
ORDER BY c.customer_id

-- OUTER: LEFT or RIGHT join
SELECT 
	c.customer_id,
	c.first_name,
    o.order_id
FROM customers c
LEFT JOIN orders o -- all the customers (Left table) will return weather the condition is correct or not
     ON c.customer_id = o.customer_id
ORDER BY c.customer_id

SELECT 
	c.customer_id,
	c.first_name,
    o.order_id
FROM customers c
RIGHT JOIN orders o -- all the orders (right table) will return weather the condition is correct or not
     ON c.customer_id = o.customer_id
ORDER BY c.customer_id
     

-- Oter join between multiple tables
-- to write clean, avoid RIGHT JOIN and use only left join
SELECT 
	c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
LEFT JOIN shippers sh
	ON o.shipper_id = sh.shipper_id
ORDEr BY c.customer_id


SELECT 
o.order_date,
o.order_id,
c.first_name AS customer,
sh.name AS shipper,
os.name AS status 
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
LEFT JOIN shippers sh
	ON o.shipper_id = sh.shipper_id
LEFT JOIN order_statuses os
	ON o.status = os.order_status_id
ORDER BY status

-- SELF OUTER JOIN
USE sql_hr;
SELECT 
	e.employee_id,
	e.first_name,
	m.first_name AS manager
FROM employees e
LEFT JOIN employees m
	ON e.reports_to = m.employee_id
    
-- The using clause
USE sql_store;
SELECT 
	o.order_id,
    c.first_name,
    sh.name AS shipper
FROM orders o
JOIN customers c
	USING (customer_id) -- you can use USING only if the column has the same name in both tables
LEFT JOIN shippers sh
	USING (shipper_id)

-- more than 2 conditions for join
SELECt * 
FROM order_items oi
JOIN order_item_notes oin 
USING (order_id , product_id)

USE sql_invoicing;
SELECT 
	p.date,
	c.name AS client,
    p.amount,
    pm.name AS payment_method
FROM payments p
JOIN clients c USING (client_id)
JOIN payment_methods pm
	ON p.payment_id = pm.payment_method_id
    
    
 -- NATURAL  JOIN is joining tables with common columns
USE sql_store;
SELECT  
	o.order_id,
	c.first_name
FROM orders o
NATURAL JOIN customers c

-- CROSS JOINs: every records from table 1 join with every record with table 2
SELECT 
	c.first_name AS customer,
    p.name AS products
FROM customers c, orders o
CROSS JOIN products p
ORDER BY c.first_name

SELECT 
	sh.name AS shipper,
    p.name AS product
FROM shippers sh, products p
CROSS JOIN products p

SELECT 
	sh.name AS shipper,
    p.name AS product
FROM shippers sh
CROSS JOIN products p

-- UNIONS (jOIN ROWS) to combine results from muliple queries and it chooses the name from the first query
SELECT 
	order_id,
    order_date,
    'Active' AS status 
FROM orders
WHERE order_date >= '2019-01-01'
UNION
SELECT 
	order_id,
    order_date,
    'Archived' AS status
FROM orders
WHERE order_date < '2019-01-01'

----- 
SELECt first_name 
FROM customers
UNION
SELECT name
FROM shippers
-- - 

SELECT customer_id, first_name, points , 'Bronz' AS type
FROM customers c
WHERE points < 2000 
UNION 
SELECT customer_id, first_name, points , 'Silver' AS type
FROM customers c
WHERE points BETWEEN 2000  AND  3000 
UNION 
SELECT customer_id, first_name, points , 'Gold' AS type
FROM customers c
Where points > 3000 
ORDER BY first_name

-- -- Inserting, Updating, and Deleting Data
-- INSERt A NEW ROW
INSERT INTO customers
VALUES (DEFAULT, 'Mehrnoosh', 'Hasanzade', '1987-01-01', NULL, 'address', 'Milwaukee', 'WI', DEFAULT )
-- or we can list only columns we wanna fill and no order neede

INSERT INTO customers (first_name, last_name, birth_date, address, city, state)
VALUES ('Mehrnoosh', 'Hasanzade', '1987-01-01', 'address', 'Milwaukee', 'WI' )

-- inserting multiple rows
INSERT INTO shippers (name)
VALUES ('shipper1'),
	   ('shipper2'),
	   ('shipper3')
       
-- INSERT 3 rows in the products table
INSERT INTO products (name, quantity_in_stock, unit_price)
VALUES ('A' , 68, 2),
	   ('B', 69, 2.5),
       ('C', 70, 3)
       
-- Inserting hierarchical rows
INSERT INTO orders (customer_id, order_date, status)
VALUES (1, '2019-01-02', 1);

INSERT INTO order_items
VALUES 
	(LAST_INSERT_ID(), 1, 1, 2.95),
	(LAST_INSERT_ID(), 2, 1, 3.95)

-- Creating a copy of a table
CREATE TABLE orders_archived AS
SELECT * FROM orders -- this is a sub_query

-- ---
INSERT INTO orders_archived
SELECT * 
FROM orders
WHERE order_date < '2019-01-01'

USE sql_invoicing;
CREATE TABLE invoices_archived As
SELECT 
	i.invoice_id,
	i.number,
    c.name AS client,
    i.invoice_total,
    i.payment_total,
    i.invoice_date,
    i.due_date
FROM invoices i
JOIN clients c USING (client_id)
WHERE i.payment_date IS NOT NULL

-- updating a single row
UPDATE invoices
SET payment_total=10 , payment_date= '2019-03-01'
WHERE invoice_id= 1

UPDATE invoices
SET payment_total= DEFAULT , payment_date= NULL
WHERE invoice_id= 1

UPDATE invoices
SET 
	payment_total= invoice_total * 0.5 ,
	payment_date= due_date
WHERE invoice_id= 3
-- 
-- Updating multiple rows-- MYSQL does not let yo to do that:
-- On top right menue click on (setting sign )MYSQL Workbench, SQL Editor, on the bottum untick tha Safe Updates
USE sql_invoicing;
UPDATE invoices
SET 
	payment_total= invoice_total * 0.5 ,
	payment_date= due_date
WHERE client_id IN (3, 4)
-- 
USE sql_store;
UPDATE customers
SET points = points + 50
WHERE birth_date < '1990-01-01'

-- 8- Using Subqueries in Updates
USE sql_invoicing;
UPDATE invoices
SET 
	payment_total= invoice_total * 0.5 ,
	payment_date= due_date
WHERE client_id = 
				(SELECT client_id
                FROM clients
                WHERE name = 'Myworks')


UPDATE invoices
SET 
	payment_total= invoice_total * 0.5 ,
	payment_date= due_date
WHERE client_id IN
				(SELECT client_id
                FROM clients
                WHERE state IN ('NY', 'CA'))

UPDATE invoices
SET 
	payment_total= invoice_total * 0.5 ,
	payment_date= due_date
WHERE payment_date IS NULL
--
USE sql_store;

UPDATE orders 
SET comments = 'Gold customer'
WHERE order_date IS NOT NULL 
				AND customer_id IN
				( SELECT customer_id
				FROM customers
				WHERE points > 3000)

-- 9- Delrting rows
DELETE FROM invoices
WHERE client_id = (
		SELECT * 
		FROM clients
		WHERE name = 'Myworks'
        )

-- 10- Restoring the Databases
-- on file menue Run SQL Script, open create databases, run it and retrive all the gdatabases


-- Summarizing Data 
-- 1- Aggregate Functions

MAX()
MIN()
AVG()
SUM()
COUNT()
-- 
SELECT 
	MAX(invoice_total) AS highest,
    MIN(invoice_total) AS lowest,
    AVG(invoice_total) AS average,
    SUM(invoice_total) AS total,
    COUNT(invoice_total) AS number_of_invoices,
    COUNT(payment_date) AS count_of_payments, -- non null payments
    MAX(payment_date) AS latest_date,
    COUNT(*) AS total_recordes,
    SUM(invoice_total * 1.1) AS total
FROM invoices -- we can have a condition or not
WHERE invoice_date > '2019-07-01'

SELECT 
	COUNT(DISTINCT client_id) AS total_recordes
FROM invoices -- we can have a condition or not
WHERE invoice_date > '2019-07-01'
-- 

SELECT 
    'First Half of 2019' AS date_range,
	SUM(invoice_total) AS total_sale,
	SUM(payment_total) AS total_payments,
	SUM(invoice_total -payment_total) AS what_we_expect
FROM invoices
WHERE invoice_date BETWEEN '2019-01-01' AND '2019-06-30'
UNION
SELECT 
	'Second Half of 2019' AS date_range,
	SUM(invoice_total) AS total_sale,
	SUM(payment_total) AS total_payments,
	SUM(invoice_total - payment_total) AS what_we_expect
FROM invoices
WHERE invoice_date BETWEEN '2019-07-01' AND '2019-12-31'
UNION
SELECT 
	'Total' AS date_range,
	SUM(invoice_total) AS total_sale,
	SUM(payment_total) AS total_payments,
	SUM(invoice_total - payment_total) AS what_we_expect
FROM invoices
WHERE invoice_date BETWEEN '2019-01-01' AND '2019-12-31'
-- 
SELECT
	state,
    city,
	SUM(invoice_total) AS total_sale
FROM invoices
JOIN clients USING (client_id)
GROUP BY state, city
ORDER BY total_sale DESC
-- 
SELECT 
	date,
	pm.name AS payment_method,
	SUM(amount) AS total_payments
FROM payments p
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id
GROUP BY date
ORDER BY date
-- 
-- HAVING clause
SELECT
	client_id,
	SUM(invoice_total) AS total_sales,
    COUNT(*) As number_of_invoices
FROM invoices
GROUP BY client_id
HAVING total_sales> 500 AND number_of_invoices >5 -- to dondition fdata after GROUP 
--
SELECT 
	c.customer_id,
    c.first_name,
    c.last_name,   
	SUM(oi.quantity * oi.unit_price) AS total_sales
From customers c	
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE state = 'VA'
GROUP BY 
	c.customer_id,
    c.first_name,
    c.last_name 
HAVING total_sales > 100

-- ROLLING UP
SELECT 
	state,
    city,
    SUM(invoice_total) AS total_sales
FROM invoices i
JOIN clients c USING(client_id)
GROUP BY state, city WITH ROLLUP
-- 
SELECT
	pm.name AS payment_method,
	SUM(p.amount) AS total
FROM payments p
JOIN payment_methods pm 
	ON p.payment_method = pm.payment_method_id
GROUP BY pm.name WITH ROLLUP  -- we cannot group by the name we choose. it should be the real name of column

-- Writing complex QUERY
-- Subqueries
SELECT 
	p.product_id,
	p.name,
    p.unit_price
FROM products p
WHERE unit_price > ( 
SELECT unit_price
FROM products
WHERE product_id = 3
)
-- 
SELECT * 
FROM employees
WHERE salary > (
SELECT AVG(salary)
FROM employees)
-- 
USE sql_store;
SELECT *
FROM products
WHERE product_id NOT IN (
	SELECT DISTINCT product_id
	FROM order_items)

-- 
USE sql_invoicing;
SELECT *
FROM clients
WHERE client_id NOT IN (
	SELECT DISTINCT client_id
    FROM invoices
)

SELECT *
FROM clients
LEFT JOIN invoices USING (client_id)
WHERE invoice_id IS NULL
-- 
USE sql_store;
SELECT 
	customer_id,
	first_name,
	last_name
FROM customers 
WHERE customer_id IN (
	SELECT  o.customer_id
	FROM order_items oi
    JOIN orders o USING (order_id)
	WHERE product_id = 3
        )
--  MOSt of the tiem writing a query with JOIN is more readable
SELECT DISTINCT
	customer_id,
	first_name,
	last_name
FROM customers C
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE product_id = 3
 -- -
SELECT DISTINCT
	customer_id,
	first_name,
	last_name
FROM customers 
WHERE customer_id IN (
	SELECT  customer_id
	FROM orders
    WHERE order_id IN(
    SELECT order_id
    FROM order_items
	WHERE product_id = 3
        ))
-- ALL keyword
USE sql_invoicing;
SELECT *
FROM invoices
WHERE invoice_total > (
	SELECT 
	MAX(invoice_total)
	FROM invoices
	WHERE client_id =3
)

SELECT *  -- this is better
FROM invoices
WHERE invoice_total > ALL (  -- ANY & SOME
	SELECT invoice_total
	FROM invoices
	WHERE client_id =3
)

-- SELECT Clients with at least 2 invoices
SELECT *
FROM clients
WHERE client_id = ANY (            -- = ANY is equall to IN
	SELECT DISTINCT client_id
	FROM invoices
	GROUP BY client_id
	HAVING COUNT(invoice_total) >= 2
)

-- SELECT employees whose salary is above the average in their office
USE sql_hr;
SELECT *
FROM employees e
WHERE salary > (
	SELECT AVG(salary)
	FROM employees m
	WHERE e.office_id = m.office_id)

-- Get invoices that are larger than the client's average invoice amount
USE sql_invoicing;
SELECT * 
FROM invoices i
WHERE invoice_total > (
	SELECT AVG(invoice_total)
	FROM invoices
	WHERE client_id = i.client_id
)

-- select clients that have an invoice
SELECT *
FROM clients c
WHERE c.client_id IN (
	SELECT DISTINCT client_id
	FROM invoices i 
 )
-- 2nd way
-- EXISTS operator -- this is a better approach
SELECT *
FROM clients c
WHERE EXISTS (
	SELECT client_id
	FROM invoices
    WHERE client_id = c.client_id
 )

-- find the products that have never been ordered
USE sql_store;
SELECT *
FROM products p
WHERE NOT EXISTS (
	SELECT DISTINCT product_id
	FROM order_items 
    WHERE product_id = p.product_id
)



-- 9- Subqueries in the SELECT Clause
SELECT
	invoice_id,
	invoice_total,
	(SELECT AVG(invoice_total)
		FROM invoices) AS invoice_average,
	invoice_total - (SELECT invoice_average) AS difference
FROM invoices

--
SELECT 
	client_id,
    name,
    (SELECT SUM(invoice_total)
		FROM invoices 
        WHERE c.client_id = client_id) AS total_sale,
    (SELECT AVG(invoice_total)
		FROM invoices) AS average,
	(SELECT total_sale - average) AS difference
FROM clients c

--  10- Subqueries in the FROM Clause
SELECT*
FROM (
SELECT 
	client_id,
    name,
    (SELECT SUM(invoice_total)
		FROM invoices 
        WHERE c.client_id = client_id) AS total_sales,
    (SELECT AVG(invoice_total)
		FROM invoices) AS average,
	(SELECT total_sale - average) AS difference
FROM clients c
) AS sales_summary -- alias is requiered when we have subquery in FROM clause
WHERE total_sales IS NOT NULL

--
--   1- Numeric Functions
SELECT ROUND(5.7263 , 2)
SELECT TRUNCATE(5.7263 , 2)
SELECT CEILING(5.7)
SELECT FLOOR(5.7)
SELECT ABS(-5.2)
SELECT RAND() -- creating a random value between 0 and 1
-- MYSQL NUMERIC FUNCTION ON GOOGle

--  2- String Functions
SELECT LENGTH('sky')
SELECT UPPER('sky')
SELECT LOWER('sky')
SELECT LTRIM('   sky') -- remove left spaces
SELECT RTRIM('sky   ')-- remove right spaces
SELECT TRIM('  sky   ') -- reemove all the spaces from left and right
SELECT LEFT ('Kindergarten', 4) -- select 4 characters from left
SELECT RIGHT ('Kindergarten', 6) -- select 6 characters from right
SELECT SUBSTRING('Kindergarten', 3, 5) -- select some characters from 3rd in length 5 but 5 id optional
SELECT LOCATE('N', 'Kindergarten') -- show the location of a string in another one (first one)
SELECT LOCATE('q', 'Kindergarten') -- return 0 when it is not in the string
SELECT LOCATE('garten', 'Kindergarten') -- shows the start point of a string in another
SELECT REPLACE('Kindergarten', 'garten', 'garden') -- show the location of a string in another one (first one'
SELECT CONCAT('first',' ', 'last')

SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM customers
-- find the coplete list of functions in GOOGLE

  -- 3- Date Functions in MySQL
SELECT NOW(), CURDATE(), CURTIME() -- curretnt date and time,  current date, current time
SELECT YEAR(NOW()) -- return only year
SELECT MONTH(NOW()) -- return only month
SELECT DAY(NOW()) -- return only day
SELECT HOUR(NOW()) -- return only hour
SELECT MINUTE(NOW()) -- return only minute
SELECT SECOND(NOW()) -- return only second
SELECT DAYNAME(NOW()) 
SELECT MONTHNAME(NOW()) 
SELECT EXTRACT(DAY FROM NOW()) --extract function
SELECT EXTRACT(YEAR FROM NOW())

-- 
SELECT *
FROM orders
WHERE YEAR(order_date) = YEAR(NOW())
-- 
--   4- Formatting Dates and Times
SELECT DATE_FORMAT(NOW(),'%Y')
SELECT DATE_FORMAT(NOW(),'%Y')
SELECT DATE_FORMAT(NOW(),'%M %d %Y')
SELECT DATE_FORMAT(NOW(),'%H:%i %p')
SELECT DATE_ADD(NOW(), INTERVAL 1 DAY)
SELECT DATE_ADD(NOW(), INTERVAL -1 YEAR)
SELECT DATEDIFF(NOW() , '2019-01-01') -- diff in days
SELECT TIME_TO_SEC('09:00')- TIME_TO_SEC('09:02') -- diff in days

--   6- The IFNULL and COALESCE Functions
SELECT 
	order_id,
    IFNULL(shipper_id, 'Not Assigned') AS shipper
FROM orders
-- WHIT IFNULL we can substitute anul value with something else

SELECT 
	order_id,
    COALESCE(shipper_id, comments, 'Not Assigned') AS shipper
FROM orders
-- whit coalesce we give a list of values and this function return the first nonnull value in the list

SELECT 
	CONCAT(first_name, ' ',last_name) AS customer,
    IFNULL(phone, 'Unknown') AS phone
    FROM customers

--   7- The IF Function---------------------------------------------------
-- IF(expression, first , second)
SELECT 
	order_id,
    order_date,
    IF(
    YEAR(order_date)= YEAR(NOW()),
    'Active',
    'Archive') AS category
FROM orders
-- --------------------------------------------------------
SELECT 
	p.product_id,
	p.name,
    COUNT(*) AS orders,
	IF(cOUNT(*) > 1, 'Many times' , 'Once') AS frequency
FROM products p
JOIN order_items USING(product_id)
GROUP BY p.product_id, p.name

-- 
SELECT 
	order_id,
    CASE
		WHEN YEAR (order_date) = YEAR(NOW())-3 THEN 'From 2019' 
		WHEN YEAR (order_date) = YEAR(NOW()) -4 THEN 'From 2018' 
		WHEN YEAR (order_date) < YEAR(NOW()) -1 THEN 'Archived' 
        ELSE 'Future'
	END AS category
FROM orders

-- ----------------------------------
SELECT
	CONCAT(first_name, ' ' ,last_name),
    points,
    CASE
		WHEN points > 3000 THEN 'Gold'
		WHEN points >= 2000 THEN 'Silver'
		ELSE 'Bronze'
	END AS category
FROM customers
ORDER BY points DESC

-- Views
--   1- Creating Views
USE sql_invoicing;

CREATE VIEW sales_by_client AS -- does not return result like SELECT, instead return an object
SELECT 
	c.client_id,
    c.name,
    SUM(invoice_total) AS total_sales
 FROM clients c
 JOIN invoices i USING (client_id)
 GROUP BY client_id, name
 
-- VIWE s do not store data. They are just a view to the underlying table
-- we can use VIEW s as a table:
SELECT * 
FROM sales_by_client
JOIN clients USING(client_id)
WHERE total_sales> 500
ORDER BY total_sales DESC

-- Creat a view to see the balance for each client. 
CREATE VIEW clients_balance AS
SELECT 
	c.client_id,
    c.name,
  SUM( i.invoice_total- i.payment_total) AS balance
FROM clients c
JOIN invoices i USING (client_id)
GROUP BY c.client_id, c.name

--   2- Altering or Dropping Views
DROP VIEW sales_by_client
DROP oR REPLACE VIEW sales_by_client

 --   3- Updatable Views -----------------------------------
-- we can use views on select and  in INSER, UPDATE and DELETE statement under certain circumstantous
-- If we dont have any of these staemnet in our view, we refer to that view as an updatable view. we can update data through it:
-- DISTINCT
-- Aggregate functions (MIN, MAX, SUM...)
-- GROUP BY
-- UNION

CREATE OR REPLACE VIEW invoice_with_balance AS
SELECT
	invoice_id,
	number,
	client_id,
	invoice_total,
    payment_total,
    invoice_total - payment_total AS balance,
    invoice_date,
    due_date,
    payment_date
FROM invoices
WHERE (invoice_total -payment_total) > 0
--
DELETE FROM invoice_with_balance
WHERE invoice_id = 1

-- update
UPDATE invoice_with_balance
SET due_date = DATE_ADD(due_date, INTERVAL 2 DAY)
WHERE invoice_id = 2

-- INSER NEW INVOICE
-- Instead of changing updating tables directly because of security, we can update the views

UPDATE invoice_with_balance
SET Payment_total = invoice_total
WHERE invoice_id = 2 -- invoice number 2 disapeared . sometimes you want to prevent this:
-- you add WITH CHECK OPTION to the VIEW

CREATE OR REPLACE VIEW invoice_with_balance AS
SELECT
	invoice_id,
	number,
	client_id,
	invoice_total,
    payment_total,
    invoice_total - payment_total AS balance,
    invoice_date,
    due_date,
    payment_date
FROM invoices
WHERE (invoice_total -payment_total) > 0
WITH CHECK OPTION 

UPDATE invoice_with_balance
SET (Payment_total > invoice_total)>0
WHERE invoice_id = 3

--   5- Other Benefits of Views
-- If you dacide to make change name or anything in the table, for example in invices, you have to 
-- back and fix all the queries that refrences this table. But, you are not allowed to write any query against this table.
--  Instead you should always use this view that you created earlier--> invoice_with_balance
-- which is exactly the same as invoices table wth an extra column named balance. 
-- -- VIEW simplify queries, reduce the impact of changes, restrict access to the data

CREATE VIEW my_view AS
SELECT 
	payment_date AS payment_due
FROM invoices

-- Stored Procedures
--  1- What are Stored Procedures


























