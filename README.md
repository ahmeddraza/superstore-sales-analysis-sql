# Superstore Sales Analysis Using SQL

## Project Overview

The goal of this project is to analyze Superstore sales data using SQL queries. The dataset contains information about customer orders, shipping details, regional performance, and product profitability. By executing a series of structured SQL queries, this project aims to extract valuable business insights, reveal customer behavior patterns, and identify trends in sales and profitability.

### Key Features

1. **Total Orders**: Count the total number of customer orders.
2. **Profit by Customer Segment**: Measure profit contribution percentage from each segment.
3. **Delivery Time Analysis**: Calculate average shipping time by customer segment.
4. **Repeat Customers**: Identify customers who placed more than one order.
5. **Top Products by Profit**: Rank top 3 most profitable products within each category.
6. **City-wise Profit Ranking**: Determine the most profitable cities by region.
7. **Monthly Profit Trend**: Track profit over time and compute cumulative profit.
8. **Discount Impact**: Compare average profit per product with and without discounts.
9. **Product Sales Trend**: Detect increasing or decreasing monthly sales trends.

## SQL Query Script and Results

### 1. **Total Orders**

```sql
SELECT COUNT(*) AS total_orders FROM projects.superstore;
```

**Output:**

| total\_orders |
| ------------- |
| 9994          |

### 2. **Profit Contribution by Segment**

```sql
SELECT
  Segment,
  ROUND(100 * SUM(Profit) / SUM(SUM(Profit)) OVER (), 2) AS profit_percentage
FROM projects.superstore
GROUP BY Segment;
```

### 3. **Average Delivery Time by Segment**

```sql
SELECT
  Segment,
  ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 2) AS avg_delivery_days
FROM projects.superstore
GROUP BY Segment;
```

### 4. **Repeat Customers**

```sql
SELECT
  Customer_ID,
  Customer_Name,
  COUNT(*) AS order_count
FROM projects.superstore
GROUP BY Customer_ID, Customer_Name
HAVING COUNT(*) > 1;
```

### 5. **Top 3 Profitable Products by Category**

```sql
SELECT * FROM (
  SELECT
    Category, Product_Name,
    SUM(Profit) AS total_profit,
    DENSE_RANK() OVER(PARTITION BY Category ORDER BY SUM(Profit) DESC) AS rank_
  FROM projects.superstore
  GROUP BY Category, Product_Name
) t
WHERE rank_ <= 3
ORDER BY Category, rank_;
```

### 6. **Most Profitable Cities by Region**

```sql
WITH city_profits AS (
  SELECT region, city, SUM(profit) AS total_profit
  FROM projects.superstore
  GROUP BY region, city
)
SELECT
  region, city, total_profit,
  DENSE_RANK() OVER(PARTITION BY region ORDER BY total_profit DESC) AS rank
FROM city_profits
ORDER BY region, rank;
```

### 7. **Monthly & Cumulative Profit Trend**

```sql
SELECT  
  YEAR(Order_Date) AS year,
  MONTHNAME(Order_Date) AS month,
  ROUND(SUM(Profit), 2) AS total_profit,
  ROUND(SUM(SUM(Profit)) OVER(ORDER BY YEAR(Order_Date), MONTH(Order_Date)), 2) AS cumulative_profit
FROM projects.superstore
GROUP BY YEAR(Order_Date), MONTH(Order_Date), MONTHNAME(Order_Date)
ORDER BY year, MONTH(Order_Date);
```

### 8. **Discount Impact on Profit**

```sql
WITH with_discount AS (
  SELECT Product_Name, AVG(Profit) AS avg_profit_with_discount
  FROM projects.superstore
  WHERE Discount > 0
  GROUP BY Product_Name
),
without_discount AS (
  SELECT Product_Name, AVG(Profit) AS avg_profit_without_discount
  FROM projects.superstore
  WHERE Discount = 0
  GROUP BY Product_Name
)
SELECT
  COALESCE(wd.Product_Name, wod.Product_Name) AS Product_Name,
  wd.avg_profit_with_discount,
  wod.avg_profit_without_discount
FROM with_discount wd
LEFT JOIN without_discount wod ON wd.Product_Name = wod.Product_Name
UNION
SELECT
  COALESCE(wd.Product_Name, wod.Product_Name),
  wd.avg_profit_with_discount,
  wod.avg_profit_without_discount
FROM without_discount wod
LEFT JOIN with_discount wd ON wod.Product_Name = wd.Product_Name;
```

### 9. **Product Sales Trend Over Time**

```sql
WITH monthly_sales AS (
  SELECT
    Product_Name,
    DATE_FORMAT(Order_Date, '%Y-%m') AS year_month,
    SUM(Sales) AS monthly_sales
  FROM projects.superstore
  GROUP BY Product_Name, DATE_FORMAT(Order_Date, '%Y-%m')
),
sales_with_trend AS (
  SELECT
    Product_Name,
    year_month,
    monthly_sales,
    LAG(monthly_sales) OVER (PARTITION BY Product_Name ORDER BY year_month) AS prev_month_sales
  FROM monthly_sales
)
SELECT
  Product_Name,
  year_month,
  monthly_sales,
  prev_month_sales,
  CASE
    WHEN prev_month_sales IS NULL THEN 'N/A'
    WHEN monthly_sales > prev_month_sales THEN 'Increasing'
    WHEN monthly_sales < prev_month_sales THEN 'Decreasing'
    ELSE 'Stable'
  END AS trend
FROM sales_with_trend
ORDER BY Product_Name, year_month;
```

---

## Conclusion

This Superstore analysis reveals valuable insights across different business areas:

- Corporate segment contributed highest to total profit.
- Repeat purchases indicate customer loyalty trends.
- Discounted items typically show lower average profits.
- Top-selling products and cities vary by region and category.
- Profitability follows monthly seasonal patterns with cumulative growth.

These insights can guide marketing decisions, inventory strategies, pricing optimization, and delivery planning.

## Getting Started

### Prerequisites

- SQL RDBMS: MySQL, PostgreSQL, or SQLite
- A cleaned version of the Superstore dataset imported as a SQL table (`projects.superstore`)

### Running the Queries

1. Open your SQL editor (MySQL Workbench, pgAdmin, etc.)
2. Connect to the database containing the Superstore dataset
3. Run each query from the script above to explore various metrics

## Contributing

If you have suggestions or want to add more advanced queries or visualizations, feel free to fork and submit a pull request!

## About the Author

- **Name**: [Your Name Here]
- **Email**: [Your Email]
- **LinkedIn**: [Your LinkedIn]
- **GitHub**: [Your GitHub Username]

