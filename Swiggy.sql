USE [Swiggy db]
GO

SELECT * FROM Swiggy_Data;

-- Data Validation & Cleaning
-- Check for NULL values
SELECT
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_State,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name, 
	SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
	SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
	SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price_inr,
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM Swiggy_Data;

-- If null values are found, we can remove the null row or give an default value
--DELETE FROM Swiggy_Data WHERE Column_Name is NULL;
--UPDATE Swiggy_Data SET Column_Name = 'Default Value' WHERE Column_Name is NULL;


-- Check for empty strings 
SELECT * FROM Swiggy_Data
WHERE 
State = '' OR City = '' OR Restaurant_Name = '' OR Location = '';

-- Check for duplicate values
SELECT 
State , City , Order_Date , Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating, Rating_Count , COUNT(*) AS duplicate_count
FROM Swiggy_Data
-- while using aggregate function, we need to use GROUP BY clause to group the data by the columns we want to check for duplicates
GROUP BY State , City , Order_Date , Restaurant_Name, Location, Category, Dish_Name, Price_INR , Rating , Rating_Count
HAVING COUNT(*) > 1;

-- Delete duplicate rows, keeping only one instance
WITH CTE AS ( 
SELECT *,
ROW_NUMBER() OVER(PARTITION BY State , City , Order_Date , Restaurant_Name, Location, Category, Dish_Name, Price_INR , Rating , Rating_Count ORDER BY (SELECT NULL)) AS d1
FROM Swiggy_Data
)
DELETE FROM CTE WHERE d1 > 1;


-- Create Schema (Dimension and Fact tables)
-- Date Table
CREATE TABLE dim_date(
	date_id INT IDENTITY(1,1) PRIMARY KEY,
	Full_date DATE,
	Year INT,
	Month INT,
	Month_name VARCHAR(20),
	Quater INT,
	Day INT,
	Week INT
);

--Location Table
CREATE TABLE dim_location(
	location_id INT IDENTITY(1,1) PRIMARY KEY,
	State VARCHAR(50),
	City VARCHAR(50),
	Location VARCHAR(100)
);

--Restaurant Table
CREATE TABLE dim_restaurant(
	restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
	Restaurant_Name VARCHAR(200)
);

--Category Table
CREATE TABLE dim_category(
	category_id INT IDENTITY(1,1) PRIMARY KEY,
	Category VARCHAR(200)
);

--Dish Table
CREATE TABLE dim_dish(
	dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_Name VARCHAR(200)
);

--Fact Table
CREATE TABLE fact_sales(
	order_id INT IDENTITY(1,1) PRIMARY KEY,

	price_inr DECIMAL(10,2),
	rating DECIMAL(4,2),
	rating_count INT,
	
	date_id INT,
	category_id INT,
	location_id INT,
	dish_id INT,
	restaurant_id INT,

	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id),
	FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id)
);

--Inserting Data into Dimension Tables
--Date Table
INSERT INTO dim_date (Full_date, Year, Month, Month_name, Quater, Day, Week)
 SELECT DISTINCT
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATENAME(MONTH, Order_Date),
	DATEPART(QUARTER, Order_Date),
	DATENAME(DAY, Order_Date),
	DATENAME(WEEK, Order_Date)
FROM Swiggy_Data
WHERE Order_Date IS NOT NULL;

--Location Table
INSERT INTO dim_location (State, City, Location)
 SELECT DISTINCT
 State,
 City,
 Location
FROM Swiggy_Data;

--Dish Table
INSERT INTO dim_dish (Dish_Name)
 SELECT DISTINCT
 Dish_Name
FROM Swiggy_Data;

--Restaurant Table
INSERT INTO dim_restaurant (Restaurant_Name)
 SELECT DISTINCT
 Restaurant_Name
FROM Swiggy_Data;

--Category Table
INSERT INTO dim_category (Category)
 SELECT DISTINCT
 Category
FROM Swiggy_Data;



--Fact_Sales Table
INSERT INTO fact_sales (
    date_id,
    price_inr,
    rating,
    rating_count,
    category_id,
    location_id,
    dish_id,
    restaurant_id
)
SELECT
    dd.date_id,
    s.price_inr,
    s.rating,
    s.rating_count,
    dc.category_id,
    dl.location_id,
    dh.dish_id,
    dr.restaurant_id
FROM Swiggy_Data s

JOIN dim_date dd
    ON dd.full_date = s.order_date   

JOIN dim_location dl
    ON dl.State = s.State
   AND dl.City = s.City
   AND dl.Location = s.Location

JOIN dim_restaurant dr
    ON dr.Restaurant_Name = s.Restaurant_Name

JOIN dim_category dc
    ON dc.Category = s.Category

JOIN dim_dish dh
    ON dh.Dish_Name = s.Dish_Name;

-- This is the schema we have created for the Swiggy database (Based on this schema we are going to write queries to get insights from the data)
SELECT * FROM fact_sales f
	JOIN dim_category dc
		ON f.category_id = dc.category_id
	JOIN dim_date dd
		ON f.date_id = dd.date_id
	JOIN dim_dish dh
		ON f.dish_id = dh.dish_id
	JOIN dim_location dl
		ON f.location_id = dl.location_id
	JOIN dim_restaurant dr
		ON f.restaurant_id = dr.restaurant_id;

-- KPI's
-- Total orders
SELECT COUNT(*) AS Total_Orders 
FROM fact_sales;

-- Total Revenue
SELECT SUM(price_inr) AS Total_Revenue -- FORMAT(SUM(CONVERT(FLOAT , price_inr))/1000000, 'N2') + ' INR MILLION' AS Total_Revenue
FROM fact_sales;

-- Average Dish Price
SELECT FORMAT(AVG(CONVERT(FLOAT , price_inr)) , 'N2' )+ ' INR' AS Average_Dish_Price
FROM fact_sales;

-- Average Rating
SELECT AVG(rating) AS Average_Rating
FROM fact_sales;

-- Deep-dive analysis
-- Monthly Orders Trends
SELECT 
d.year , d.month , d.month_name , COUNT(*) AS Total_Orders
FROM fact_sales f
JOIN dim_date d
	ON f.date_id = d.date_id
GROUP BY d.year , d.month , d.month_name
ORDER BY COUNT(*) DESC;

-- Monthly Total Revenue Trends
SELECT 
d.year , d.month , d.month_name , SUM(price_inr) AS Total_Revenue
FROM fact_sales f
JOIN dim_date d
	ON f.date_id = d.date_id
GROUP BY d.year , d.month , d.month_name
ORDER BY SUM(price_inr) DESC;

-- Quarterly Orders Trends
SELECT 
d.year , d.Quater , COUNT(*) AS Total_Orders
FROM fact_sales f
JOIN dim_date d
	ON f.date_id = d.date_id
GROUP BY d.year , d.Quater
ORDER BY COUNT(*) DESC;

-- Yearly Trends
SELECT 
d.year , COUNT(*) AS Total_Orders
FROM fact_sales f
JOIN dim_date d
	ON f.date_id = d.date_id
GROUP BY d.year 
ORDER BY COUNT(*) DESC;

-- Orders by day of week
SELECT 
DATENAME(WEEKDAY , d.full_date) AS Day_Name,
COUNT(*) AS Total_Orders
FROM fact_sales f
JOIN dim_date d
 ON d.date_id = f.date_id
GROUP BY DATENAME(WEEKDAY , d.full_date)
ORDER BY COUNT(*) DESC;

-- Top 10 Cities By Orders Value
SELECT TOP 10
d.city,
COUNT(*) AS Total_Orders
FROM fact_sales f
JOIN dim_location d
 ON d.location_id = f.location_id
GROUP BY d.city
ORDER BY COUNT(*) DESC;

-- Revenue Contribution by States
SELECT
d.state,
COUNT(*) AS Total_Orders
FROM fact_sales f
JOIN dim_location d
 ON d.location_id = f.location_id
GROUP BY d.state
ORDER BY COUNT(*) DESC;

--Top 10 Restaurants by Orders
SELECT TOP 10
r.restaurant_name,
SUM(price_inr) AS Total_Revenue
FROM fact_sales f
JOIN dim_restaurant r
 ON r.restaurant_id = f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY SUM(price_inr) DESC;

-- Top Categories by Order Volume
SELECT 
c.category,
COUNT(*) AS Total_Orders
FROM fact_sales f
JOIN dim_category c
	ON c.category_id = f.category_id
GROUP BY c.Category
ORDER BY COUNT(*) DESC;

-- Most Ordered Dishes
SELECT
d.dish_name,
COUNT(*) AS Total_Orders
FROM fact_sales f
JOIN dim_dish d
	ON d.dish_id = f.dish_id
GROUP BY d.Dish_Name
ORDER BY COUNT(*) DESC;

-- Cuisine Performance (Orderes + Avg Rating)
SELECT TOP 10
c.category,
COUNT(*) AS Total_Orders,
AVG(rating) AS Avg_Rating
FROM fact_sales f
JOIN dim_category c
	ON c.category_id = f.category_id
GROUP BY c.category
ORDER BY COUNT(*) DESC;

-- Total Orders by price range
SELECT 
 CASE
	WHEN CONVERT(FLOAT , price_inr) < 100 THEN '0 - 100'
	WHEN CONVERT(FLOAT , price_inr) BETWEEN 100 AND 199 THEN '100 - 199'
	WHEN CONVERT(FLOAT , price_inr) BETWEEN 200 AND 299 THEN '200 - 299'
	WHEN CONVERT(FLOAT , price_inr) BETWEEN 300 AND 399 THEN '300 - 399'
	WHEN CONVERT(FLOAT , price_inr) BETWEEN 400 AND 499 THEN '400 - 499'
	ELSE '500+'
 END AS Price_Range,
 COUNT(*) AS Total_orders
 FROM fact_sales
 GROUP BY 
  CASE
    WHEN CONVERT(FLOAT , price_inr) < 100 THEN '0 - 100'
	WHEN CONVERT(FLOAT , price_inr) BETWEEN 100 AND 199 THEN '100 - 199'
	WHEN CONVERT(FLOAT , price_inr) BETWEEN 200 AND 299 THEN '200 - 299'
	WHEN CONVERT(FLOAT , price_inr) BETWEEN 300 AND 399 THEN '300 - 399'
	WHEN CONVERT(FLOAT , price_inr) BETWEEN 400 AND 499 THEN '400 - 499'
	ELSE '500+'
 END
ORDER BY COUNT(*) DESC;

-- Rating count distribution
SELECT 
rating,
COUNT(*) AS Total_rating
FROM fact_sales
GROUP BY rating
ORDER BY COUNT(*) DESC;