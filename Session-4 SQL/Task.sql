-- 1. Count the total number of products in the database
SELECT COUNT(*) AS total_products
FROM production.products;

-- 2. Find the average, minimum, and maximum price of all products
SELECT 
  AVG(list_price) AS average_price,
  MIN(list_price) AS minimum_price,
  MAX(list_price) AS maximum_price
FROM production.products;

-- 3. Count how many products are in each category
SELECT category_id, COUNT(*) AS product_count
FROM production.products
GROUP BY category_id;

-- 4. Find the total number of orders for each store
SELECT store_id, COUNT(*) AS total_orders
FROM sales.orders
GROUP BY store_id;

-- 5. Show customer first names in UPPERCASE and last names in lowercase for the first 10 customers
SELECT 
  UPPER(first_name) AS upper_first_name,
  LOWER(last_name) AS lower_last_name
FROM sales.customers
ORDER BY customer_id
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 6. Get the length of each product name. Show product name and its length for the first 10 products
SELECT 
  product_name,
  LEN(product_name) AS name_length
FROM production.products
ORDER BY product_id
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 7. Format customer phone numbers to show only the area code (first 3 digits) for customers 1�15
SELECT 
  customer_id,
  LEFT(phone, 3) AS area_code
FROM sales.customers
ORDER BY customer_id
OFFSET 0 ROWS FETCH NEXT 15 ROWS ONLY;

-- 8. Show the current date and extract the year and month from order dates for orders 1�10
SELECT 
  order_id,
  order_date,
  YEAR(order_date) AS order_year,
  MONTH(order_date) AS order_month
FROM sales.orders
ORDER BY order_id
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 9. Join products with their categories. Show product name and category name for first 10 products
SELECT
  p.product_name,
  c.category_name
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
ORDER BY p.product_id
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 10. Join customers with their orders. Show customer name and order date for first 10 orders
SELECT 
  c.first_name + ' ' + c.last_name AS customer_name,
  o.order_date
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 11. Show all products with their brand names, even if some products don't have brands
SELECT 
  p.product_name,
  ISNULL(b.brand_name, 'No Brand') AS brand_name
FROM production.products p
LEFT JOIN production.brands b ON p.brand_id = b.brand_id;

-- 12. Find products that cost more than the average product price
SELECT 
  product_name,
  list_price
FROM production.products
WHERE list_price > (
  SELECT AVG(list_price)
  FROM production.products
);

-- 13. Find customers who have placed at least one order using a subquery with IN
SELECT 
  customer_id,
  first_name + ' ' + last_name AS customer_name
FROM sales.customers
WHERE customer_id IN (
  SELECT DISTINCT customer_id
  FROM sales.orders
  WHERE customer_id IS NOT NULL
);

-- 14. For each customer, show their name and total number of orders using a subquery in the SELECT clause
SELECT 
  first_name + ' ' + last_name AS customer_name,
  (SELECT COUNT(*) FROM sales.orders o WHERE o.customer_id = c.customer_id) AS order_count
FROM sales.customers c;

-- 15. Create a simple view called easy_product_list and query it
CREATE VIEW easy_product_list AS
SELECT 
  p.product_name,
  c.category_name,
  p.list_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id;
-- Query the view for products where price > 100
SELECT *
FROM easy_product_list
WHERE list_price > 100;

-- 16. Create a view customer_info and query customers from California (CA)
CREATE VIEW customer_info AS
SELECT 
  customer_id,
  first_name + ' ' + last_name AS full_name,
  email,
  city + ', ' + state AS location
FROM sales.customers;
-- Query the view for customers from CA
SELECT *
FROM customer_info
WHERE location LIKE '%, CA';

-- 17. Find all products that cost between $50 and $200, ordered by price
SELECT 
  product_name,
  list_price
FROM production.products
WHERE list_price BETWEEN 50 AND 200
ORDER BY list_price ASC;

-- 18. Count how many customers live in each state, ordered by count descending
SELECT 
  state,
  COUNT(*) AS customer_count
FROM sales.customers
GROUP BY state
ORDER BY customer_count DESC;

-- 19. Find the most expensive product in each category
SELECT 
  c.category_name,
  p.product_name,
  p.list_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
WHERE p.list_price = (
  SELECT MAX(list_price)
  FROM production.products
  WHERE category_id = p.category_id
);

-- 20. Show all stores and their cities, including the total number of orders from each store
SELECT 
  s.store_name,
  s.city,
  COUNT(o.order_id) AS order_count
FROM sales.stores s
LEFT JOIN sales.orders o ON s.store_id = o.store_id
GROUP BY s.store_id, s.store_name, s.city;
