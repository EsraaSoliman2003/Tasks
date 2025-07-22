select * from production.brands
select * from production.categories
select * from production.products
select * from production.stocks
select * from sales.customers
select * from sales.order_items
select * from sales.orders
select * from sales.staffs
select * from sales.stores
--------------------------------------------------------------------------------
SELECT 
  product_id,
  list_price,
  CASE
    WHEN list_price < 300 THEN 'Economy'
    WHEN list_price >= 300 AND list_price <= 999 THEN 'Standard'
    WHEN list_price >= 1000 AND list_price <= 2499 THEN 'Premium'
    WHEN list_price >= 2500 THEN 'Luxury'
  END AS price_category
FROM production.products;
--------------------------------------------------------------------------------
SELECT 
  order_id,
  order_status,
  order_date,

  CASE 
    WHEN order_status = 1 THEN 'Order Received'
    WHEN order_status = 2 THEN 'In Preparation'
    WHEN order_status = 3 THEN 'Order Cancelled'
    WHEN order_status = 4 THEN 'Order Delivered'
    ELSE 'Unknown Status'
  END AS status_description,

  CASE 
    WHEN order_status = 1 AND DATEDIFF(DAY, order_date, GETDATE()) >5 THEN 'URGENT'
    WHEN order_status = 2 AND DATEDIFF(DAY, order_date, GETDATE()) >3 THEN 'HIGH'
    ELSE 'NORMAL'
  END AS priority_level


FROM sales.orders;
--------------------------------------------------------------------------------
select
s.staff_id,
COUNT(*) as count,
case
	WHEN COUNT(*) = 0 THEN 'New Staff'
	WHEN COUNT(*) >=1 AND COUNT(*) <= 10 THEN 'Junior Staff'
	WHEN COUNT(*) >= 11 AND COUNT(*) <= 25 THEN 'Senior Staff'
	WHEN COUNT(*) >= 26 THEN 'Expert Staff'
END AS state
from sales.staffs s
join sales.orders o on s.staff_id = o.staff_id
group by s.staff_id
--------------------------------------------------------------------------------
select
customer_id,
ISNULL(phone, 'Phone Not Available') as phone_number,
coalesce(phone, email, 'No Contact Method') as preferred_contact,
*
from sales.customers
--------------------------------------------------------------------------------
select
	p.product_id,
	p.product_name,
	p.list_price,
	s.quantity,
    ISNULL(p.list_price / NULLIF(s.quantity, 0), 0) AS price_per_unit,
    CASE 
        WHEN s.quantity IS NULL THEN 'No Stock'
        WHEN s.quantity = 0 THEN 'Out of Stock'
        WHEN s.quantity > 0 AND s.quantity <= 10 THEN 'Low Stock'
        WHEN s.quantity > 10 AND s.quantity <= 50 THEN 'Moderate Stock'
        ELSE 'High Stock'
    END AS stock_status
from production.products p
join production.stocks s on p.product_id = s.product_id
where s.store_id=1
--------------------------------------------------------------------------------
SELECT 
    customer_id,
    first_name,
    last_name,
    COALESCE(street, 'Unknown Street') AS street,
    COALESCE(city, 'Unknown City') AS city,
    COALESCE(state, 'Unknown State') AS state,
    COALESCE(zip_code, 'No ZIP') AS zip_code,
    CONCAT(
        COALESCE(street, 'Unknown Street'), ', ',
        COALESCE(city, 'Unknown City'), ', ',
        COALESCE(state, 'Unknown State'), ' ',
        COALESCE(zip_code, 'No ZIP')
    ) AS formatted_address
FROM sales.customers;
--------------------------------------------------------------------------------
WITH CustomerSpending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
    HAVING SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 1500
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    cs.total_spent
FROM CustomerSpending cs
JOIN sales.customers c ON cs.customer_id = c.customer_id
ORDER BY cs.total_spent DESC;
--------------------------------------------------------------------------------
WITH CategoryRevenue AS (
    SELECT 
        c.category_id,
        c.category_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM production.categories c
    JOIN production.products p ON c.category_id = p.category_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id, c.category_name
),
CategoryAvgOrder AS (
    SELECT 
        c.category_id,
        c.category_name,
        AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS avg_order_value
    FROM production.categories c
    JOIN production.products p ON c.category_id = p.category_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id, c.category_name
)
SELECT 
    cr.category_name,
    cr.total_revenue,
    cao.avg_order_value,
    CASE 
        WHEN cr.total_revenue > 50000 THEN 'Excellent'
        WHEN cr.total_revenue > 20000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_rating
FROM CategoryRevenue cr
JOIN CategoryAvgOrder cao ON cr.category_id = cao.category_id
ORDER BY cr.total_revenue DESC;
--------------------------------------------------------------------------------
WITH MonthlySales AS (
    SELECT 
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS sales_month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS monthly_total
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
),
MonthlyComparison AS (
    SELECT 
        sales_year,
        sales_month,
        monthly_total,
        LAG(monthly_total) OVER (ORDER BY sales_year, sales_month) AS prev_month_total
    FROM MonthlySales
)
SELECT 
    sales_year,
    sales_month,
    monthly_total,
    prev_month_total,
    CASE 
        WHEN prev_month_total IS NOT NULL 
        THEN ((monthly_total - prev_month_total) / prev_month_total * 100)
        ELSE NULL 
    END AS growth_percentage
FROM MonthlyComparison
ORDER BY sales_year, sales_month;
--------------------------------------------------------------------------------
WITH ProductRankings AS (
    SELECT 
        c.category_name,
        p.product_name,
        p.list_price,
        ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY p.list_price DESC) AS row_num,
        RANK() OVER (PARTITION BY c.category_id ORDER BY p.list_price DESC) AS rank,
        DENSE_RANK() OVER (PARTITION BY c.category_id ORDER BY p.list_price DESC) AS dense_rank
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
)
SELECT 
    category_name,
    product_name,
    list_price,
    row_num,
    rank,
    dense_rank
FROM ProductRankings
WHERE row_num <= 3
ORDER BY category_name, list_price DESC;
--------------------------------------------------------------------------------
WITH CustomerSpending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    cs.total_spent,
    RANK() OVER (ORDER BY cs.total_spent DESC) AS spending_rank,
    NTILE(5) OVER (ORDER BY cs.total_spent DESC) AS spending_quintile,
    CASE NTILE(5) OVER (ORDER BY cs.total_spent DESC)
        WHEN 1 THEN 'VIP'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
        WHEN 5 THEN 'Standard'
    END AS spending_tier
FROM CustomerSpending cs
JOIN sales.customers c ON cs.customer_id = c.customer_id
ORDER BY cs.total_spent DESC;
--------------------------------------------------------------------------------
WITH StorePerformance AS (
    SELECT 
        s.store_id,
        s.store_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_id, s.store_name
)
SELECT 
    store_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    order_count,
    RANK() OVER (ORDER BY order_count DESC) AS order_count_rank,
    PERCENT_RANK() OVER (ORDER BY total_revenue) AS revenue_percentile
FROM StorePerformance
ORDER BY total_revenue DESC;
--------------------------------------------------------------------------------
SELECT 
    category_name,
    ISNULL([Electra], 0) AS Electra,
    ISNULL([Haro], 0) AS Haro,
    ISNULL([Trek], 0) AS Trek,
    ISNULL([Surly], 0) AS Surly
FROM (
    SELECT 
        c.category_name,
        b.brand_name
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    JOIN production.brands b ON p.brand_id = b.brand_id
    WHERE b.brand_name IN ('Electra', 'Haro', 'Trek', 'Surly')
) AS SourceTable
PIVOT (
    COUNT(brand_name)
    FOR brand_name IN (Electra, Haro, Trek, Surly)
) AS PivotTable
ORDER BY category_name;
--------------------------------------------------------------------------------
SELECT 
    store_name,
    ISNULL([1], 0) AS Jan,
    ISNULL([2], 0) AS Feb,
    ISNULL([3], 0) AS Mar,
    ISNULL([4], 0) AS Apr,
    ISNULL([5], 0) AS May,
    ISNULL([6], 0) AS Jun,
    ISNULL([7], 0) AS Jul,
    ISNULL([8], 0) AS Aug,
    ISNULL([9], 0) AS Sep,
    ISNULL([10], 0) AS Oct,
    ISNULL([11], 0) AS Nov,
    ISNULL([12], 0) AS Dec,
    ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0) + ISNULL([4], 0) + 
    ISNULL([5], 0) + ISNULL([6], 0) + ISNULL([7], 0) + ISNULL([8], 0) + 
    ISNULL([9], 0) + ISNULL([10], 0) + ISNULL([11], 0) + ISNULL([12], 0) AS Total
FROM (
    SELECT 
        s.store_name,
        MONTH(o.order_date) AS sales_month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_name, MONTH(o.order_date)
) AS SourceTable
PIVOT (
    SUM(revenue)
    FOR sales_month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS PivotTable
ORDER BY store_name;
--------------------------------------------------------------------------------
SELECT 
    store_name,
    ISNULL([1], 0) AS Pending,
    ISNULL([2], 0) AS Processing,
    ISNULL([4], 0) AS Completed,
    ISNULL([3], 0) AS Rejected
FROM (
    SELECT 
        s.store_name,
        o.order_status
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
) AS SourceTable
PIVOT (
    COUNT(order_status)
    FOR order_status IN ([1], [2], [3], [4])
) AS PivotTable
ORDER BY store_name;
--------------------------------------------------------------------------------
WITH BrandSales AS (
    SELECT 
        b.brand_name,
        YEAR(o.order_date) AS sales_year,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM production.brands b
    JOIN production.products p ON b.brand_id = p.brand_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    JOIN sales.orders o ON oi.order_id = o.order_id
    GROUP BY b.brand_name, YEAR(o.order_date)
),
PivotedSales AS (
    SELECT 
        brand_name,
        ISNULL([2016], 0) AS [2016],
        ISNULL([2017], 0) AS [2017],
        ISNULL([2018], 0) AS [2018]
    FROM BrandSales
    PIVOT (
        SUM(revenue)
        FOR sales_year IN ([2016], [2017], [2018])
    ) AS PivotTable
)
SELECT 
    brand_name,
    [2016],
    [2017],
    [2018],
    CASE 
        WHEN [2016] > 0 
        THEN (([2017] - [2016]) / [2016] * 100) 
        ELSE NULL 
    END AS growth_2016_2017,
    CASE 
        WHEN [2017] > 0 
        THEN (([2018] - [2017]) / [2017] * 100) 
        ELSE NULL 
    END AS growth_2017_2018
FROM PivotedSales
ORDER BY brand_name;
--------------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.product_name,
    'In Stock' AS availability_status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity > 0
UNION
SELECT 
    p.product_id,
    p.product_name,
    'Out of Stock' AS availability_status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL
UNION
SELECT 
    p.product_id,
    p.product_name,
    'Discontinued' AS availability_status
FROM production.products p
WHERE p.product_id NOT IN (SELECT product_id FROM production.stocks)
ORDER BY product_id;
--------------------------------------------------------------------------------
WITH Customers2017 AS (
    SELECT DISTINCT customer_id
    FROM sales.orders
    WHERE YEAR(order_date) = 2017
),
Customers2018 AS (
    SELECT DISTINCT customer_id
    FROM sales.orders
    WHERE YEAR(order_date) = 2018
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE c.customer_id IN (
    SELECT customer_id FROM Customers2017
    INTERSECT
    SELECT customer_id FROM Customers2018
)
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
--------------------------------------------------------------------------------
WITH AllStores AS (
    SELECT product_id
    FROM production.stocks
    WHERE store_id = 1
    INTERSECT
    SELECT product_id
    FROM production.stocks
    WHERE store_id = 2
    INTERSECT
    SELECT product_id
    FROM production.stocks
    WHERE store_id = 3
),
Store1Not2 AS (
    SELECT product_id
    FROM production.stocks
    WHERE store_id = 1
    EXCEPT
    SELECT product_id
    FROM production.stocks
    WHERE store_id = 2
)
SELECT 
    p.product_id,
    p.product_name,
    'Available in All Stores' AS distribution_status
FROM production.products p
WHERE p.product_id IN (SELECT product_id FROM AllStores)
UNION
SELECT 
    p.product_id,
    p.product_name,
    'Store 1 Only (Not in Store 2)' AS distribution_status
FROM production.products p
WHERE p.product_id IN (SELECT product_id FROM Store1Not2)
ORDER BY product_id;
--------------------------------------------------------------------------------
WITH Customers2016 AS (
    SELECT DISTINCT customer_id
    FROM sales.orders
    WHERE YEAR(order_date) = 2016
),
Customers2017 AS (
    SELECT DISTINCT customer_id
    FROM sales.orders
    WHERE YEAR(order_date) = 2017
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    'Lost Customers' AS customer_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE c.customer_id IN (
    SELECT customer_id FROM Customers2016
    EXCEPT
    SELECT customer_id FROM Customers2017
)
AND YEAR(o.order_date) = 2016
GROUP BY c.customer_id, c.first_name, c.last_name
UNION ALL
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    'New Customers' AS customer_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE c.customer_id IN (
    SELECT customer_id FROM Customers2017
    EXCEPT
    SELECT customer_id FROM Customers2016
)
AND YEAR(o.order_date) = 2017
GROUP BY c.customer_id, c.first_name, c.last_name
UNION ALL
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    'Retained Customers' AS customer_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE c.customer_id IN (
    SELECT customer_id FROM Customers2016
    INTERSECT
    SELECT customer_id FROM Customers2017
)
AND YEAR(o.order_date) IN (2016, 2017)
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY customer_status, total_spent DESC;