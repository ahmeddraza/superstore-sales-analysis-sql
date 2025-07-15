# Superstore Advanced Sales Analysis Using SQL

## Project Overview

This project is a comprehensive SQL-based analysis of the Superstore dataset. It leverages advanced SQL techniques like **CTEs**, **window functions**, **subqueries**, and **aggregation** to uncover key business insights, including customer behavior, product trends, profitability, and operational performance.

The dataset contains detailed information on sales transactions, customers, products, regions, shipping details, and profit. By querying this data, we extract answers to complex business questions.

---

## Key Business Questions Answered

### 1. **Top 3 Most Profitable Products in Each Product Category**
```sql
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
```

---

### 2. **Customers Generating Above-Average Total Profit**
```sql
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
```

---

### 3. **Average Delivery Time Per Customer Segment**
```sql
SELECT Segment,  AVG(DATEDIFF(Ship_Date,Order_Date)) AS 'Avg_delivery'
FROM projects.superstore
GROUP BY Segment;
```

---

### 4. **Cumulative Monthly Profit Over Time**
```sql
SELECT  YEAR(Order_Date) AS 'year', MONTHNAME(Order_Date) AS 'month_name',
ROUND(SUM(Profit),3) AS 'total_sum',
SUM(SUM(Profit)) OVER(ORDER BY YEAR(Order_Date),MONTH(Order_Date)) AS 'cumalative_sum'
FROM projects.superstore
GROUP BY YEAR(Order_Date), MONTH(Order_Date), MONTHNAME(Order_Date)
ORDER BY YEAR(Order_Date), MONTH(Order_Date);
```

---

### 5. **City Rankings by Profit Within Each Region**
```sql
SELECT region, City, profit_sum,
DENSE_RANK() OVER(PARTITION BY region ORDER BY profit_sum DESC) AS 'rank'
FROM (
    SELECT region, City,
    SUM(Profit) AS 'profit_sum'
    FROM projects.superstore
    GROUP BY region, City
) AS t
ORDER BY region, City;
```

---

### 6. **Best-Selling Sub-Category (by Quantity) in Each Region**
```sql
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
```

---

### 7. **Average Profit Per Product With and Without Discount**
```sql
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
```

---

### 8. **Profit Percentage by Segment**
```sql
SELECT
    Segment,
    ROUND(SUM(Profit), 2) AS segment_profit,
    ROUND(100 * SUM(Profit) / SUM(SUM(Profit)) OVER (), 2) AS profit_percentage
FROM projects.superstore
GROUP BY Segment
ORDER BY profit_percentage DESC;
```

---

### 9. **Monthly Sales Trend per Product (Increasing or Decreasing)**
```sql
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
```

---

### 10. **Repeat Customers**
```sql
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
ORDER BY Customer_ID;
```

---

## Conclusion

This analysis extracts powerful business insights from the Superstore dataset using advanced SQL. Highlights include:

- Key customers and their profit contributions
- Product performance by category, region, and time
- Shipping and discount effects on profitability
- Sales trends and customer loyalty insights

These insights help businesses optimize pricing, product strategies, marketing efforts, and delivery operations.

## Getting Started

### Requirements
- SQL database (MySQL/PostgreSQL/SQLite)
- Superstore dataset loaded into a table named `projects.superstore`

### How to Run
- Use MySQL Workbench, pgAdmin, or DB Browser for SQLite
- Execute each query one by one to generate the outputs

## About the Author
- **Name**: [Your Name Here]  
- **GitHub**: [Your GitHub]  
- **LinkedIn**: [Your LinkedIn]  
- **Email**: [Your Email Address]

Feel free to contribute or fork this project to explore further enhancements!

