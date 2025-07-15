-- What are the top 3 most profitable products in each product category?

SELECT * 
FROM (
    SELECT 
        Category, 
        Product_Name, 
        SUM(Profit) AS Total_Profit, 
        DENSE_RANK() OVER (PARTITION BY Category ORDER BY SUM(Profit) DESC) AS 'rank_'
    FROM projects.superstore
    GROUP BY Category, Product_Name
) t
WHERE t.rank_ < 4
ORDER BY Category, rank_ DESC;

-- Which customers generated above-average total profit compared to all customers?

WITH customer_profit AS (
    SELECT 
        Customer_Name,
        SUM(Profit) AS total_profit
    FROM projects.superstore
    GROUP BY Customer_Name
)

SELECT 
    Customer_Name, 
    total_profit 
FROM customer_profit
WHERE total_profit > (
    SELECT AVG(total_profit) 
    FROM customer_profit
)
ORDER BY total_profit DESC;

-- What is the average delivery time (days between order and shipping) per customer segment?

SELECT Segment,  AVG(DATEDIFF(Ship_Date,Order_Date)) AS 'Avg_delivery'FROM projects.superstore
GROUP BY Segment;

-- How do cumulative monthly sales grow over time?
SELECT * FROM projects.superstore;
SELECT  YEAR(Order_Date) AS 'year', MONTHNAME(Order_Date) AS 'month_name',
ROUND(SUM(Profit),3) AS 'total_sum', 
SUM(SUM(Profit)) OVER(ORDER BY YEAR(Order_Date),MONTH(Order_Date)) AS 'cumalative_sum'
FROM projects.superstore
GROUP BY YEAR(Order_Date), MONTH(Order_Date), MONTHNAME(Order_Date)
ORDER BY YEAR(Order_Date), MONTH(Order_Date);

-- Within each region, what is the ranking of cities based on total profit?

SELECT region, City, profit_sum, 
DENSE_RANK() OVER(PARTITION BY region ORDER BY profit_sum DESC) AS 'rank'
FROM (
		SELECT region, City, 
		SUM(Profit) AS 'profit_sum'
		FROM projects.superstore
		GROUP BY region, City
        ) AS t
        ORDER BY region, City;

-- What is the best-selling sub-category (by quantity) in each region?

SELECT 
    region, 
    sub_category, 
    quantity_sold,
    DENSE_RANK() OVER(PARTITION BY region ORDER BY quantity_sold DESC) AS rank_
FROM (
    SELECT 
        region, 
        sub_category, 
        SUM(quantity) AS quantity_sold
    FROM projects.superstore
    GROUP BY region, sub_category
) AS t
ORDER BY region, rank_;

-- What is the average profit per product with and without discount, and how does discount affect profit?

WITH with_discount AS (
    SELECT 
        Product_Name,
        ROUND(AVG(Profit), 2) AS avg_profit_with_discount
    FROM projects.superstore
    WHERE Discount > 0
    GROUP BY Product_Name
),

without_discount AS (
    SELECT 
        Product_Name,
        ROUND(AVG(Profit), 2) AS avg_profit_without_discount
    FROM projects.superstore
    WHERE Discount = 0
    GROUP BY Product_Name
)

SELECT 
    COALESCE(wd.Product_Name, wod.Product_Name) AS Product_Name,
    wd.avg_profit_with_discount,
    wod.avg_profit_without_discount
FROM with_discount wd
LEFT JOIN without_discount wod 
    ON wd.Product_Name = wod.Product_Name

UNION

SELECT 
    COALESCE(wd.Product_Name, wod.Product_Name) AS Product_Name,
    wd.avg_profit_with_discount,
    wod.avg_profit_without_discount
FROM without_discount wod
LEFT JOIN with_discount wd 
    ON wd.Product_Name = wod.Product_Name

ORDER BY Product_Name;

-- What percentage of total profit is contributed by each customer segment?

SELECT 
    Segment,
    ROUND(SUM(Profit), 2) AS segment_profit,
    ROUND(100 * SUM(Profit) / SUM(SUM(Profit)) OVER (), 2) AS profit_percentage
FROM projects.superstore
GROUP BY Segment
ORDER BY profit_percentage DESC;

-- Which products have increasing or decreasing monthly sales trends?

WITH monthly_sales AS (
    SELECT 
        Product_Name,
        DATE_FORMAT(Order_Date, '%Y-%m') AS year_months,
        SUM(Sales) AS monthly_sales
    FROM projects.superstore
    GROUP BY Product_Name, DATE_FORMAT(Order_Date, '%Y-%m')
),

sales_with_trend AS (
    SELECT 
        Product_Name,
        year_months,
        monthly_sales,
        LAG(monthly_sales) OVER (PARTITION BY Product_Name ORDER BY year_months) AS prev_month_sales
    FROM monthly_sales
)

SELECT 
    Product_Name,
    year_months,
    monthly_sales,
    prev_month_sales,
    CASE 
        WHEN prev_month_sales IS NULL THEN 'N/A'
        WHEN monthly_sales > prev_month_sales THEN 'Increasing'
        WHEN monthly_sales < prev_month_sales THEN 'Decreasing'
        ELSE 'Stable'
    END AS trend
FROM sales_with_trend
ORDER BY Product_Name, year_months;

-- Which customers have placed more than one order?

SELECT 
    Customer_ID,
    Customer_Name
FROM projects.superstore
WHERE Customer_ID IN (
    SELECT Customer_ID
    FROM projects.superstore
    GROUP BY Customer_ID
    HAVING COUNT(*) > 1
)
ORDER BY Customer_ID



