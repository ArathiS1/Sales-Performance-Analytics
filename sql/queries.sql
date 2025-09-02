/* ============================================================
   SALES PERFORMANCE ANALYTICS - SQL QUERIES
   Dataset: sales_insights_dataset
   ============================================================ */

---------------------------------------------------------------
-- Query 1: Year-over-Year (YoY) Growth per Product
---------------------------------------------------------------
WITH SalesByYear AS (
    SELECT
        Product,
        EXTRACT(YEAR FROM OrderDate) AS OrderYear,
        SUM(Sales) AS TotalSales
    FROM sales_insights_dataset
    GROUP BY Product, EXTRACT(YEAR FROM OrderDate)
)
SELECT
    Product,
    OrderYear,
    TotalSales,
    LAG(TotalSales) OVER (PARTITION BY Product ORDER BY OrderYear) AS SalesLY,
    (TotalSales - LAG(TotalSales) OVER (PARTITION BY Product ORDER BY OrderYear)) * 100.0 /
    NULLIF(LAG(TotalSales) OVER (PARTITION BY Product ORDER BY OrderYear), 0) AS YoYGrowthPercent
FROM SalesByYear
ORDER BY Product, OrderYear;

---------------------------------------------------------------
-- Query 2: Top 10 Customers by Sales
---------------------------------------------------------------
SELECT
    CustomerName,
    SUM(Sales) AS TotalSales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS CustomerRank
FROM sales_insights_dataset
GROUP BY CustomerName
ORDER BY TotalSales DESC
LIMIT 10;

---------------------------------------------------------------
-- Query 3: Return Rate by Product Category
---------------------------------------------------------------
SELECT
    Category,
    COUNT(CASE WHEN OrderStatus = 'Returned' THEN 1 END) * 100.0 / COUNT(*) AS ReturnRatePercent
FROM sales_insights_dataset
GROUP BY Category;

---------------------------------------------------------------
-- Query 4: Average Order Value (AOV)
---------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM OrderDate) AS OrderYear,
    EXTRACT(MONTH FROM OrderDate) AS OrderMonth,
    SUM(Sales) / COUNT(DISTINCT OrderID) AS AvgOrderValue
FROM sales_insights_dataset
GROUP BY OrderYear, OrderMonth
ORDER BY OrderYear, OrderMonth;

---------------------------------------------------------------
-- Query 5: Regional Revenue Performance
---------------------------------------------------------------
SELECT
    Region,
    SUM(Sales) AS TotalRevenue,
    COUNT(DISTINCT CustomerName) AS UniqueCustomers,
    COUNT(DISTINCT OrderID) AS TotalOrders
FROM sales_insights_dataset
GROUP BY Region
ORDER BY TotalRevenue DESC;

---------------------------------------------------------------
-- Query 6: Customer Churn Rate
-- Logic: Customers inactive for 180+ days are churned.
---------------------------------------------------------------
WITH CustomerActivity AS (
    SELECT
        CustomerName,
        MAX(OrderDate) AS LastOrderDate
    FROM sales_insights_dataset
    GROUP BY CustomerName
)
SELECT
    COUNT(CASE WHEN DATE_PART('day', CURRENT_DATE - LastOrderDate) > 180 THEN 1 END) * 1.0 /
    COUNT(*) * 100 AS ChurnRatePercent
FROM CustomerActivity;

---------------------------------------------------------------
-- Query 7: Product Contribution to Revenue
---------------------------------------------------------------
SELECT
    Product,
    SUM(Sales) AS ProductRevenue,
    SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER() AS RevenueContributionPercent
FROM sales_insights_dataset
GROUP BY Product
ORDER BY RevenueContributionPercent DESC;

---------------------------------------------------------------
-- Query 8: Monthly Sales Trend
---------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM OrderDate) AS OrderYear,
    EXTRACT(MONTH FROM OrderDate) AS OrderMonth,
    SUM(Sales) AS TotalSales
FROM sales_insights_dataset
GROUP BY OrderYear, OrderMonth
ORDER BY OrderYear, OrderMonth;

---------------------------------------------------------------
-- Query 9: Profitability by Product
-- Requires 'Profit' column (if exists in dataset)
---------------------------------------------------------------
SELECT
    Product,
    SUM(Sales) AS Revenue,
    SUM(Profit) AS Profit,
    (SUM(Profit) * 100.0 / SUM(Sales)) AS ProfitMarginPercent
FROM sales_insights_dataset
GROUP BY Product
ORDER BY Profit DESC;

---------------------------------------------------------------
-- Query 10: Daily Sales Performance (Last 30 Days)
---------------------------------------------------------------
SELECT
    CAST(OrderDate AS DATE) AS OrderDay,
    SUM(Sales) AS DailySales
FROM sales_insights_dataset
WHERE OrderDate >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY OrderDay
ORDER BY OrderDay;
