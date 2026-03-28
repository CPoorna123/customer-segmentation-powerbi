use retail_project;
-- Check total number of rows in the dataset
SELECT COUNT(*) AS total_rows
FROM online_retail;

-- Identify transactions with missing CustomerID
SELECT COUNT(*) AS missing_customers
FROM online_retail
WHERE CustomerID IS NULL;

-- Disable safe update mode to allow DELETE operation
SET SQL_SAFE_UPDATES = 0;

-- Remove rows where CustomerID is NULL
DELETE FROM online_retail
WHERE CustomerID IS NULL;

-- Remove transactions with negative or zero quantity (cancelled orders)
DELETE FROM online_retail
WHERE Quantity <= 0;

-- Check number of rows after data cleaning
SELECT COUNT(*) AS cleaned_rows
FROM online_retail;

-- Calculate revenue for each transaction
SELECT 
Invoice,
CustomerID,
Quantity,
Price,
Quantity * Price AS Revenue
FROM online_retail;

-- Analyze total revenue by country
SELECT 
Country,
SUM(Quantity * Price) AS TotalRevenue
FROM online_retail
GROUP BY Country
ORDER BY TotalRevenue DESC;

-- Identify top 10 high-value customers
SELECT 
CustomerID,
SUM(Quantity * Price) AS TotalSpent
FROM online_retail
GROUP BY CustomerID
ORDER BY TotalSpent DESC
LIMIT 10;

-- Find top 10 most purchased products
SELECT 
Description,
SUM(Quantity) AS TotalSold
FROM online_retail
GROUP BY Description
ORDER BY TotalSold DESC
LIMIT 10;

-- Analyze how frequently customers place orders
SELECT 
CustomerID,
COUNT(DISTINCT Invoice) AS PurchaseFrequency
FROM online_retail
GROUP BY CustomerID
ORDER BY PurchaseFrequency DESC;

-- Calculate RFM metrics for customer segmentation
SELECT
CustomerID,
MAX(InvoiceDate) AS LastPurchaseDate,
COUNT(DISTINCT Invoice) AS Frequency,
SUM(Quantity * Price) AS MonetaryValue
FROM online_retail
GROUP BY CustomerID;

-- Create RFM table from customer transaction data
CREATE TABLE rfm_table AS
SELECT
CustomerID,
MAX(InvoiceDate) AS LastPurchaseDate,
COUNT(DISTINCT Invoice) AS Frequency,
SUM(Quantity * Price) AS MonetaryValue
FROM online_retail
GROUP BY CustomerID;

SELECT * 
FROM rfm_table
LIMIT 10;

-- Segment customers based on purchase behavior
SELECT
CustomerID,
Frequency,
MonetaryValue,

CASE
WHEN MonetaryValue > 5000 THEN 'VIP Customers'
WHEN Frequency > 10 THEN 'Loyal Customers'
WHEN Frequency BETWEEN 5 AND 10 THEN 'Potential Customers'
ELSE 'At Risk Customers'
END AS CustomerSegment

FROM rfm_table
ORDER BY MonetaryValue DESC;

-- Count number of customers in each segment
SELECT
CustomerSegment,
COUNT(*) AS TotalCustomers
FROM
(
SELECT
CustomerID,
CASE
WHEN MonetaryValue > 5000 THEN 'VIP Customers'
WHEN Frequency > 10 THEN 'Loyal Customers'
WHEN Frequency BETWEEN 5 AND 10 THEN 'Potential Customers'
ELSE 'At Risk Customers'
END AS CustomerSegment
FROM rfm_table
) AS segments
GROUP BY CustomerSegment;

-- Calculate revenue contribution by customer segment
SELECT
CustomerSegment,
SUM(MonetaryValue) AS TotalRevenue
FROM
(
SELECT
CustomerID,
MonetaryValue,
CASE
WHEN MonetaryValue > 5000 THEN 'VIP Customers'
WHEN Frequency > 10 THEN 'Loyal Customers'
WHEN Frequency BETWEEN 5 AND 10 THEN 'Potential Customers'
ELSE 'At Risk Customers'
END AS CustomerSegment
FROM rfm_table
) AS segment_data
GROUP BY CustomerSegment
ORDER BY TotalRevenue DESC;