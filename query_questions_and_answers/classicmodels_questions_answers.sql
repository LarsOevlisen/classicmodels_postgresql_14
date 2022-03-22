--------- Questions and answers - Start ---------
-- 1. Single entity
-- 1.1 Prepare a list of offices sorted by country, state, city.

SELECT
	*
FROM	
	classicmodels.offices
ORDER BY
	country ASC NULLS LAST,
	state ASC NULLS LAST,
	city ASC NULLS LAST;

-- 1.2 How many employees are there in the company?
SELECT
	COUNT(employeenumber) AS n_employees
FROM
	classicmodels.employees;

-- 1.3 What is the total of payments received?
SELECT
	SUM(amount) AS total_payments_received
FROM
	classicmodels.payments;

-- 1.4 List the product lines that contain 'Cars'.
SELECT
	*
FROM
	classicmodels.productlines
WHERE
	productline ILIKE '%_car_%';

-- 1.5 Report total payments for October 28, 2004.
SELECT
	paymentdate::DATE,
	SUM(amount) AS total_payments_received_20041028
FROM
	classicmodels.payments
WHERE
	paymentdate::DATE = '2004-10-28'
GROUP BY
	paymentdate;

-- 1.6 Report those payments greater than $100,000.
SELECT
	*
FROM
	classicmodels.payments
WHERE
	amount > 100000
ORDER BY
	amount DESC;

-- 1.7 List the products in each product line.
SELECT
	productline,
	productcode
FROM
	classicmodels.products
ORDER BY
	productline;

-- 1.8 How many products in each product line?
SELECT
	productline,
	COUNT(productcode) AS n_productcode
FROM
	classicmodels.products
GROUP BY
	productline
ORDER BY
	n_productcode DESC;

-- 1.9 What is the minimum payment received?
SELECT
	*
FROM (
	SELECT
		*,
		MIN(amount) OVER () AS min_amount
	FROM
		classicmodels.payments) AS t
WHERE
	amount = min_amount;

-- 1.10 List all payments greater than twice the average payment.
SELECT
	*
FROM (
	SELECT
		*,
		2 * AVG(amount) OVER () AS avg_amount
	FROM
		classicmodels.payments) AS t
WHERE
	amount > avg_amount;;

-- 1.11 What is the average percentage markup of the MSRP on buyPrice?
SELECT
	100 * AVG(avg_msrp / avg_buyprice) AS average_pct_markup_msrp_buyprice
FROM (
	SELECT
		AVG(msrp) AS avg_msrp,
		AVG(buyprice) AS avg_buyprice
	FROM
		classicmodels.products) AS t;

-- 1.12 How many distinct products does ClassicModels sell?
SELECT
	COUNT(DISTINCT(productcode)) AS n_distinct_productcode
FROM
	classicmodels.products;

-- 1.13 Report the name and city of customers who don't have sales representatives.
SELECT
	customername,
	city
FROM
	classicmodels.customers
WHERE
	salesrepemployeenumber IS NULL;

-- 1.14 What are the names of executives with VP or Manager in their title? Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.
SELECT
	firstname || lastname AS employee_name
FROM
	classicmodels.employees
WHERE
	jobtitle ILIKE '%vp%'
	OR jobtitle ILIKE '%manager%';

-- 1.15 Which orders have a value greater than $5,000?
WITH order_totals AS (
	SELECT
		ordernumber,
		SUM(quantityordered * priceeach) AS order_total
	FROM
		classicmodels.orderdetails
	GROUP BY
		ordernumber
)
SELECT
	*
FROM
	order_totals;

-- 2. One to many relationship
-- 2.1 Report the account representative for each customer.
SELECT
	cust.customernumber,
	cust.customername,
	empl.employeenumber AS account_rep_empl_number,
	TRIM(CONCAT(empl.firstname, ' ', empl.lastname)) AS account_rep_name,
	empl.officecode AS account_rep_office
FROM
	classicmodels.customers AS cust
	LEFT JOIN classicmodels.employees AS empl ON cust.salesrepemployeenumber = empl.employeenumber ORDER BY customernumber ASC;

-- 2.2 Report total payments for Atelier graphique.
SELECT
	cust.customername,
	cust.customernumber,
	SUM(paym.amount) AS total
FROM
	classicmodels.customers AS cust
	INNER JOIN classicmodels.payments AS paym ON cust.customernumber = paym.customernumber
WHERE
	cust.customername = 'Atelier graphique'
GROUP BY
	1,
	2;

-- 2.3 Report the total payments by date
SELECT
	paymentdate::DATE,
	SUM(amount) AS total_payment_amount
FROM classicmodels.payments
GROUP BY
	paymentdate
ORDER BY
	paymentdate ASC;

-- 2.4 Report the products that have not been sold.
SELECT
	orderd.ordernumber,
	prod.*
FROM
	classicmodels.products AS prod
	LEFT JOIN classicmodels.orderdetails AS orderd ON prod.productcode = orderd.productcode
WHERE orderd.ordernumber IS NULL;

-- 2.5 List the amount paid by each customer.
SELECT
	customers.customernumber AS cust_number,
	customers.customername,
	ROUND(SUM(payments.amount)) AS total_cust_payment_rounded
FROM
	classicmodels.customers AS customers
	LEFT JOIN classicmodels.payments AS payments ON customers.customernumber = payments.customernumber
GROUP BY
	customers.customernumber,
	customers.customername
ORDER BY
	total_cust_payment_rounded DESC NULLS LAST;

-- 2.6 How many orders have been placed by Herkku Gifts?
SELECT
	customers.customername,
	COUNT(orders.ordernumber)
FROM classicmodels.orders AS orders
INNER JOIN classicmodels.customers AS customers
ON
	orders.customernumber = customers.customernumber
	AND customers.customername = 'Herkku Gifts'
GROUP BY customers.customername;

-- 2.7 Who are the employees in Boston?
SELECT
	*
FROM classicmodels.employees AS employees
INNER JOIN classicmodels.offices AS offices
ON
	employees.officecode = offices.officecode
	AND offices.city = 'Boston';

-- 2.8 Report those payments greater than $100,000. Sort the report so the customer who made the highest payment appears first.
SELECT
	payments.*,
	customers.customernumber,
	customers.customername
FROM classicmodels.payments AS payments
INNER JOIN classicmodels.customers AS customers
ON
	payments.customernumber = customers.customernumber
	AND payments.amount > 100000
ORDER BY amount DESC;

-- 2.9 List the value of 'On Hold' orders.
SELECT
	orders.status,
	SUM(quantityordered * priceeach) AS order_value
FROM classicmodels.orderdetails AS orderdetails
INNER JOIN classicmodels.orders AS orders
ON
	orderdetails.ordernumber = orders.ordernumber
GROUP BY status;

-- 2.10 Report the number of orders 'On Hold' for each customer.
SELECT
	customers.customernumber,
	customers.customername,
	orders.status,
	COUNT(orders.ordernumber)
FROM classicmodels.customers AS customers
INNER JOIN classicmodels.orders AS orders
ON
	customers.customernumber = orders.customernumber
	AND orders.status = 'On Hold'
GROUP BY
	customers.customernumber,
	customers.customername,
	orders.status
ORDER BY customernumber ASC;

SELECT -- Alternative solution utilising COALESCE to force status to 'On Hold' for all left joined order rows where status was not 'On Hold' (counted as 0 'On Hold' since they are not present in orders table)
	customers.customernumber,
	customers.customername,
	COALESCE(orders.status, 'On Hold') AS status,
	COUNT(orders.ordernumber) AS n_status_on_hold
FROM classicmodels.customers AS customers
LEFT JOIN classicmodels.orders AS orders
ON
	customers.customernumber = orders.customernumber
	AND orders.status = 'On Hold'
GROUP BY
	customers.customernumber,
	customers.customername,
	orders.status
ORDER BY n_status_on_hold DESC;


-- 3. Many to many relationship
-- 3.1 List products sold by order date.
SELECT
	orders.orderdate,
	products.productname
FROM classicmodels.orders AS orders
INNER JOIN classicmodels.orderdetails AS orderdetails ON orders.ordernumber = orderdetails.ordernumber
INNER JOIN classicmodels.products AS products ON orderdetails.productcode = products.productcode
ORDER BY orders.orderdate ASC;

-- 3.2 List the order dates in descending order for orders for the 1940 Ford Pickup Truck.


-- 3.3 List the names of customers and their corresponding order number where a particular order from that customer has a value greater than $25,000?


-- 3.4 Are there any products that appear on all orders?


-- 3.5 List the names of products sold at less than 80% of the MSRP.


-- 3.6 Reports those products that have been sold with a markup of 100% or more (i.e.,  the priceEach is at least twice the buyPrice)


-- 3.7 List the products ordered on a Monday.


-- 3.8 What is the quantity on hand for products listed on 'On Hold' orders?


-- 4. Regular expressions

-- 4.1 Find products containing the name 'Ford'.


-- 4.2 List products ending in 'ship'.


-- 4.3 Report the number of customers in Denmark, Norway, and Sweden.


-- 4.4 What are the products with a product code in the range S700_1000 to S700_1499?


-- 4.5 Which customers have a digit in their name?


-- 4.6 List the names of employees called Dianne or Diane.


-- 4.7 List the products containing ship or boat in their product name.


-- 4.8 List the products with a product code beginning with S700.


-- 4.9 List the names of employees called Larry or Barry.


-- 4.10 List the names of employees with non-alphabetic characters in their names.


-- 4.11 List the vendors whose name ends in Diecast


-- 5. General queries
-- 5.1 Who is at the top of the organization (i.e.,  reports to no one).


-- 5.2 Who reports to William Patterson?


-- 5.3 List all the products purchased by Herkku Gifts.


-- 5.4 Compute the commission for each sales representative, assuming the commission is 5% of the value of an order. Sort by employee last name and first name.


-- 5.5 What is the difference in days between the most recent and oldest order date in the Orders file?


-- 5.6 Compute the average time between order date and ship date for each customer ordered by the largest difference.


-- 5.7 What is the value of orders shipped in August 2004? (Hint).


-- 5.8 Compute the total value ordered, total amount paid, and their difference for each customer for orders placed in 2004 and payments received in 2004 (Hint; Create views for the total paid and total ordered).


-- 5.9 List the employees who report to those employees who report to Diane Murphy. Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.


-- 5.10 What is the percentage value of each product in inventory sorted by the highest percentage first (Hint: Create a view first).


-- 5.11 Write a function to convert miles per gallon to liters per 100 kilometers.


-- 5.12 Write a procedure to increase the price of a specified product category by a given percentage. You will need to create a product table with appropriate data to test your procedure. Alternatively, load the ClassicModels database on your personal machine so you have complete access. You have to change the DELIMITER prior to creating the procedure.


-- 5.13 What is the value of orders shipped in August 2004? (Hint).


-- 5.14 What is the ratio the value of payments made to orders received for each month of 2004. (i.e., divide the value of payments made by the orders received)?


-- 5.15 What is the difference in the amount received for each month of 2004 compared to 2003?


-- 5.16 Write a procedure to report the amount ordered in a specific month and year for customers containing a specified character string in their name.


-- 5.17 Write a procedure to change the credit limit of all customers in a specified country by a specified percentage.


-- 5.18 Basket of goods analysis: A common retail analytics task is to analyze each basket or order to learn what products are often purchased together. Report the names of products that appear in the same order ten or more times.


-- 5.19 ABC reporting: Compute the revenue generated by each customer based on their orders. Also, show each customer's revenue as a percentage of total revenue. Sort by customer name.


-- 5.20 Compute the profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit. Sort by profit descending.


-- 5.21 Compute the revenue generated by each sales representative based on the orders from the customers they serve.


-- 5.22 Compute the profit generated by each sales representative based on the orders from the customers they serve. Sort by profit generated descending.


-- 5.23 Compute the revenue generated by each product, sorted by product name.


-- 5.24 Compute the profit generated by each product line, sorted by profit descending.


-- 5.25 Same as Last Year (SALY) analysis: Compute the ratio for each product of sales for 2003 versus 2004.


-- 5.26 Compute the ratio of payments for each customer for 2003 versus 2004.


-- 5.27 Find the products sold in 2003 but not 2004.


-- 5.28 Find the customers without payments in 2003.


-- 6. Correlated subqueries
-- 6.1 Who reports to Mary Patterson?


-- 6.2 Which payments in any month and year are more than twice the average for that month and year (i.e. compare all payments in Oct 2004 with the average payment for Oct 2004)? Order the results by the date of the payment. You will need to use the date functions.


-- 6.3 Report for each product, the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs. Order the report by product line and percentage value within product line descending. Show percentages with two decimal places.


-- 6.4 For orders containing more than two products, report those products that constitute more than 50% of the value of the order.


-- 7. Spatial data
-- The Offices and Customers tables contain the latitude and longitude of each office and customer in officeLocation and customerLocation, respectively, in POINT format. Conventionally, latitude and longitude and reported as a pair of points, with latitude first.

-- 7.1 Which customers are in the Southern Hemisphere?


-- 7.2 Which US customers are south west of the New York office?


-- 7.3 Which customers are closest to the Tokyo office (i.e., closer to Tokyo than any other office)?


-- 7.4 Which French customer is furthest from the Paris office?


-- 7.5 Who is the northernmost customer?


-- 7.6 What is the distance between the Paris and Boston offices?
-- To be precise for long distances, the distance in kilometers, as the crow flies, between two points when you have latitude and longitude, is (ACOS(SIN(lat1*PI()/180)*SIN(lat2*PI()/180)+COS(lat1*PI()/180)*COS(lat2*PI()/180)* COS((lon1-lon2)*PI()/180))*180/PI())*60*1.8532


-- 8. Data visualization
-- For each problem, use R to run an SQL query and then visualize the results. The first step in all cases is to load the MySQL library and access the database.

-- 8.1 Visualize in blue the number of items for each product scale.


-- 8.2 Prepare a line plot with appropriate labels for total payments for each month in 2004.


-- 8.3 Create a histogram with appropriate labels for the value of orders received from the Nordic countries (Denmark,Finland, Norway,Sweden).


-- 8.4 Create a heatmap for product lines and Norwegian cities.


-- 8.5 Create a parallel coordinates plot for product scale, quantity in stock, and MSRP in the Products table.
--------- Questions and answers - End ---------