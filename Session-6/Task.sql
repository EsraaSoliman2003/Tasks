--1.1 List all employees hired after January 1, 2012, showing their ID, 
--first name, last name, and hire date, ordered by hire date descending.
SELECT 
    e.BusinessEntityID AS ID,
    p.FirstName,
    p.LastName,
    e.HireDate
FROM HumanResources.Employee e
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
WHERE HireDate > '2012-01-01'
ORDER BY HireDate DESC;

--1.2 List products with a list price between $100 and $500, showing product ID, 
--name, list price, and product number, ordered by list price ascending.
SELECT 
    ProductID,
    Name,
    ListPrice,
    ProductNumber
FROM Production.Product
WHERE ListPrice BETWEEN 100 AND 500
ORDER BY ListPrice;

--1.3 List customers from the cities 'Seattle' or 'Portland', showing customer ID,
--first name, last name, and city, using appropriate joins.
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    a.City
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.Address a ON c.CustomerID = a.AddressID
WHERE a.City IN ('Seattle', 'Portland');

--1.4 List the top 15 most expensive products currently being sold, showing name, 
--list price, product number, and category name, excluding discontinued products.
SELECT TOP 15
    p.Name,
    p.ListPrice,
    p.ProductNumber,
    pc.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE p.DiscontinuedDate IS NULL
ORDER BY p.ListPrice DESC;

--2.1 List products whose name contains 'Mountain' and color is 'Black',
--showing product ID, name, color, and list price.
select ProductID, Name, Color, ListPrice
from Production.Product
where name like '%Mountain%' and
color = 'Black'

--2.2 List employees born between January 1, 1970, and December 31, 1985,
--showing full name, birth date, and age in years.
select p.FirstName+ ' ' + p.MiddleName + ' ' + p.LastName as fullName,
e.BirthDate,
YEAR(GETDATE()) - YEAR(e.BirthDate) as age
from HumanResources.Employee e
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
where e.BirthDate between '1970-01-01' and '1985-12-31'

--2.3 List orders placed in the fourth quarter of 2013, showing order ID,
--order date, customer ID, and total due.
select SalesOrderID,
OrderDate,
CustomerID,
TotalDue
from Sales.SalesOrderHeader
where OrderDate between '2013-10-01' and '2013-12-31'

--2.4 List products with a null weight but a non-null size,
--showing product ID, name, weight, size, and product number.
select
ProductID,
Name,
Weight,
Size,
ProductNumber
from Production.Product
where Weight is null and
size is not null

--3.1 Count the number of products by category, ordered by count descending.
select
c.ProductCategoryID,
COUNT(*)
from Production.Product p
join Production.ProductSubcategory c on p.ProductSubcategoryID = c.ProductSubcategoryID
group by c.ProductCategoryID
order by COUNT(*) DESC

--3.2 Show the average list price by product subcategory, including only subcategories with more than five products.
select
c.ProductSubcategoryID,
count(*),
avg(p.ListPrice)
from Production.ProductSubcategory c
join Production.Product p on c.ProductSubcategoryID = p.ProductSubcategoryID
group by c.ProductSubcategoryID
having count(*)>5

--3.3 List the top 10 customers by total order count, including customer name.
select top 10
c.CustomerID,
p.FirstName+ ' ' + p.MiddleName + ' ' + p.LastName as fullName,
COUNT(soh.SalesOrderID)
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.MiddleName, p.LastName
order by COUNT(soh.SalesOrderID) desc

--3.4 Show monthly sales totals for 2013, displaying the month name and total amount.
select
DATENAME(month, OrderDate) AS MonthName,
count(MONTH(OrderDate))
from Sales.SalesOrderHeader
where YEAR(OrderDate) = '2013'
group by DATENAME(month, OrderDate)
ORDER BY MIN(OrderDate);

--4.1 Find all products launched in the same year as 'Mountain-100 Black, 42'.
--Show product ID, name, sell start date, and year.
select
ProductID,
Name,
SellStartDate,
YEAR(SellStartDate)
from Production.Product
WHERE YEAR(SellStartDate)=(SELECT
								YEAR(SellStartDate) 
                             FROM Production.Product 
                             WHERE Name = 'Mountain-100 Black, 42')
ORDER BY SellStartDate;

--4.2 Find employees who were hired on the same date as someone else.
--Show employee names, shared hire date, and the count of employees hired that day.
SELECT 
    STRING_AGG(p.FirstName + ' ' + ISNULL(p.MiddleName + ' ', '') + p.LastName, ', ') AS fullNames,
    e.HireDate AS sharedHireDate,
    COUNT(e.HireDate) AS numberOfEmployees
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY e.HireDate
HAVING COUNT(e.HireDate) > 1;

--5.1 Create a table named Sales.ProductReviews with columns for review ID,
--product ID, customer ID, rating, review date, review text, verified purchase flag,
--and helpful votes. Include appropriate primary key, foreign keys, check constraints,
--defaults, and a unique constraint on product ID and customer ID.
CREATE TABLE Sales.ProductReviews (
    reviewID INT PRIMARY KEY,
    productID INT NOT NULL,
    customerID INT NOT NULL,
    rating DECIMAL NOT NULL,
    reviewDate DATE NOT NULL DEFAULT GETDATE(),
    reviewText VARCHAR(255),
    verifiedPurchaseFlag BIT NOT NULL DEFAULT 0,
    helpfulVotes INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_ProductReviews_Product FOREIGN KEY (productID) REFERENCES Production.Product(ProductID),
    CONSTRAINT FK_ProductReviews_Customer FOREIGN KEY (customerID) REFERENCES Sales.Customer(CustomerID),
    CONSTRAINT CHK_Rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT CHK_VerifiedPurchaseFlag CHECK (verifiedPurchaseFlag IN (0, 1)),
    CONSTRAINT CHK_HelpfulVotes CHECK (helpfulVotes >= 0),
    CONSTRAINT UQ_ProductCustomer UNIQUE (productID, customerID)
);

--6.1 Add a column named LastModifiedDate to the Production.Product table, with a default value of the current date and time.
ALTER TABLE Sales.ProductReviews
ADD LastModifiedDate DATETIME DEFAULT GETDATE();

--6.2 Create a non-clustered index on the LastName column of the Person.Person table, including FirstName and MiddleName.
CREATE NONCLUSTERED INDEX nonClusteredIndex
ON Person.Person (LastName)
INCLUDE (FirstName, MiddleName);

--6.3 Add a check constraint to the Production.Product table to ensure that ListPrice is greater than StandardCost.
ALTER TABLE Production.Product
ADD CONSTRAINT CHK_ListPrice_GreaterThan_StandardCost
CHECK (ListPrice > StandardCost);

--7.1 Insert three sample records into Sales.ProductReviews 
--using existing product and customer IDs, with varied ratings and meaningful review text.
INSERT INTO Sales.ProductReviews (reviewID, productID, customerID, rating, reviewDate, reviewText, verifiedPurchaseFlag, helpfulVotes)
VALUES 
    (1, 1, 1, 5, '2025-07-01', 'Excellent product, highly recommend!', 1, 10),
    (2, 2, 2, 4, '2025-07-10', 'Good quality, but delivery was slow.', 0, 3),
    (3, 3, 3, 3, '2025-07-15', 'Average performance, meets expectations.', 1, 1);

--7.2 Insert a new product category named 'Electronics' and
--a corresponding product subcategory named 'Smartphones' under Electronics.
INSERT INTO Production.ProductCategory (Name)
VALUES ('Electronics');
INSERT INTO Production.ProductSubcategory (ProductCategoryID, Name, rowguid, ModifiedDate)
VALUES (5, 'Electronics', NEWID(), GETDATE());

--7.3 Copy all discontinued products (where SellEndDate is not null)
--into a new table named Sales.DiscontinuedProducts.
CREATE TABLE Sales.DiscontinuedProducts (
    ProductID INT NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    ProductNumber NVARCHAR(25) NOT NULL,
    MakeFlag BIT NOT NULL,
    FinishedGoodsFlag BIT NOT NULL,
    Color NVARCHAR(15) NULL,
    SafetyStockLevel SMALLINT NOT NULL,
    ReorderPoint SMALLINT NOT NULL,
    StandardCost MONEY NOT NULL,
    ListPrice MONEY NOT NULL,
    Size NVARCHAR(5) NULL,
    SizeUnitMeasureCode NCHAR(3) NULL,
    WeightUnitMeasureCode NCHAR(3) NULL,
    Weight DECIMAL(8,2) NULL,
    DaysToManufacture INT NOT NULL,
    ProductLine NCHAR(2) NULL,
    Class NCHAR(2) NULL,
    Style NCHAR(2) NULL,
    ProductSubcategoryID INT NULL,
    ProductModelID INT NULL,
    SellStartDate DATETIME NOT NULL,
    SellEndDate DATETIME NULL,
    DiscontinuedDate DATETIME NULL,
    rowguid UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate DATETIME NOT NULL
);

INSERT INTO Sales.DiscontinuedProducts
SELECT *
FROM Production.Product
WHERE SellEndDate IS NOT NULL;

--8.1 Update the ModifiedDate to the current date for all products where ListPrice is greater than $1000 and SellEndDate is null.
update Production.Product
set ModifiedDate = getdate()
where ListPrice >1000 and
SellEndDate is null

--8.2 Increase the ListPrice by 15% for all products in the 'Bikes' category and update the ModifiedDate.
update  p
set p.ListPrice = ListPrice * 1.15,
ModifiedDate = getdate()
from Production.Product p
join Production.ProductSubcategory s
on p.ProductSubcategoryID = s.ProductSubcategoryID
join Production.ProductCategory c
on s.ProductCategoryID = c.ProductCategoryID
where c.Name = 'Bikes'

--8.3 Update the JobTitle to 'Senior' plus the existing job title for employees hired before January 1, 2010.
UPDATE HumanResources.Employee
SET JobTitle = 'Senior ' + JobTitle
WHERE HireDate < '2010-01-01';

--9.1 Delete all product reviews with a rating of 1 and helpful votes equal to 0.
delete from sales.ProductReviews
where rating = 1 and
helpfulVotes = 0

--9.2 Delete products that have never been ordered, using a NOT EXISTS condition with Sales.SalesOrderDetail.
delete from Production.BillOfMaterials
where ComponentID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Production.ProductInventory
where ProductID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Production.ProductProductPhoto
where ProductID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Purchasing.ProductVendor
where ProductID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Production.BillOfMaterials
where ProductAssemblyID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Production.ProductDocument
where ProductID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Purchasing.PurchaseOrderDetail
where ProductID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Production.TransactionHistory
where ProductID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Sales.ProductReviews
where ProductID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

delete from Production.WorkOrder
where ProductID in (
	SELECT ProductID
    FROM Production.Product
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sales.SalesOrderDetail sod
        WHERE sod.ProductID = Production.Product.ProductID
    )
);

DELETE FROM Production.Product
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail sod
    WHERE sod.ProductID = Production.Product.ProductID
);

--9.3 Delete all purchase orders from vendors that are no longer active.
DELETE FROM Purchasing.PurchaseOrderHeader
WHERE VendorID IN (
    SELECT BusinessEntityID
    FROM Purchasing.Vendor
    WHERE ActiveFlag = 0
);
DELETE FROM Purchasing.PurchaseOrderDetail
WHERE PurchaseOrderID IN (
    SELECT PurchaseOrderID
    FROM Purchasing.PurchaseOrderHeader
    WHERE VendorID IN (
        SELECT BusinessEntityID
        FROM Purchasing.Vendor
        WHERE ActiveFlag = 0
    )
);

--10.1 Calculate the total sales amount by year from 2011 to 2014, showing year, total sales, average order value, and order count.
SELECT 
    YEAR(soh.OrderDate) AS SalesYear,
    SUM(sod.UnitPrice * sod.OrderQty) AS TotalSales,
    SUM(sod.UnitPrice * sod.OrderQty) / COUNT(DISTINCT soh.SalesOrderID) AS AverageOrderValue,
    COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
GROUP BY YEAR(soh.OrderDate)
ORDER BY YEAR(soh.OrderDate);

--10.2 For each customer, show customer ID, total orders, total amount, average order value, first order date, and last order date.
SELECT 
    soh.CustomerID,
    COUNT(DISTINCT soh.SalesOrderID) AS totalOrders,
    SUM(sod.UnitPrice * sod.OrderQty) AS totalAmount,
    SUM(sod.UnitPrice * sod.OrderQty) / COUNT(DISTINCT soh.SalesOrderID) AS averageOrderValue,
    MIN(soh.OrderDate) AS firstOrderDate,
    MAX(soh.OrderDate) AS lastOrderDate
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.CustomerID;

--10.3 List the top 20 products by total sales amount, including product name, category, total quantity sold, and total revenue.
SELECT TOP 20
    p.Name AS ProductName,
    pc.Name AS CategoryName,
    SUM(sod.OrderQty) AS TotalQuantitySold,
    SUM(sod.UnitPrice * sod.OrderQty) AS TotalRevenue
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.Name, pc.Name
ORDER BY TotalRevenue DESC;

--10.4 Show sales amount by month for 2013, displaying the month name, sales amount, and percentage of the yearly total.
WITH YearlyTotal AS (
    SELECT SUM(sod.UnitPrice * sod.OrderQty) AS TotalYearlySales
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    WHERE YEAR(soh.OrderDate) = 2013
)
SELECT 
    DATENAME(month, soh.OrderDate) AS MonthName,
    SUM(sod.UnitPrice * sod.OrderQty) AS SalesAmount,
    CAST(SUM(sod.UnitPrice * sod.OrderQty) * 100.0 / (SELECT TotalYearlySales FROM YearlyTotal) AS DECIMAL(10, 2)) AS PercentageOfYearlyTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE YEAR(soh.OrderDate) = 2013
GROUP BY DATENAME(month, soh.OrderDate)
ORDER BY MIN(soh.OrderDate);

------------------------------------------------------------------------------------------------------------------------

select * from HumanResources.Employee
select * from Person.Person
select * from Purchasing.PurchaseOrderDetail
select * from Purchasing.PurchaseOrderHeader
select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeaderSalesReason
select * from Sales.SalesOrderHeader
select * from Purchasing.ProductVendor
select * from sales.Customer
select * from Person.Person
select * from Sales.Store
select * from Sales.SalesTerritory
select * from Production.Product
select * from Production.ProductSubcategory
select * from Production.ProductCategory
select * from Production.BillOfMaterials










