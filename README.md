# 🍽️ Swiggy Data Analysis & Data Warehouse Project

## 📌 Project Overview

This project focuses on building a complete SQL-based Data Warehouse for Swiggy food delivery data and performing Exploratory Data Analysis (EDA) to uncover business insights.

The project follows a Star Schema architecture consisting of Dimension Tables and a Fact Table. Raw Swiggy data is cleaned, transformed, loaded into the warehouse, and analyzed using SQL queries.

---

# 🎯 Objectives

- Perform Data Cleaning and Validation
- Remove duplicate records
- Design a Star Schema Data Warehouse
- Build Dimension and Fact tables
- Generate Key Performance Indicators (KPIs)
- Perform Exploratory Data Analysis (EDA)
- Derive business insights from food ordering patterns

---

# 📂 Dataset Information

The dataset contains the following information:

| Column |
|---------|
| State |
| City |
| Order_Date |
| Restaurant_Name |
| Location |
| Category |
| Dish_Name |
| Price_INR |
| Rating |
| Rating_Count |

---

# 🧹 Data Cleaning & Validation

The following quality checks were performed:

### 1. Null Value Detection

Checked all columns for missing values using:

```sql
SUM(CASE WHEN Column IS NULL THEN 1 ELSE 0 END)
```

### 2. Empty String Detection

```sql
WHERE State='' OR City='' OR Restaurant_Name=''
```

### 3. Duplicate Record Detection

Used:

```sql
GROUP BY
HAVING COUNT(*) > 1
```

### 4. Duplicate Removal

Implemented using Window Functions:

```sql
ROW_NUMBER() OVER (
PARTITION BY ...
)
```

Duplicate rows were deleted while retaining a single valid record.

---

# 🏗️ Data Warehouse Design

The warehouse follows a **Star Schema** model.

## Dimension Tables

### dim_date

Stores date-related attributes.

| Column |
|----------|
| date_id |
| Full_date |
| Year |
| Month |
| Month_name |
| Quarter |
| Day |
| Week |

---

### dim_location

Stores geographical information.

| Column |
|----------|
| location_id |
| State |
| City |
| Location |

---

### dim_restaurant

Stores restaurant information.

| Column |
|----------|
| restaurant_id |
| Restaurant_Name |

---

### dim_category

Stores cuisine/category information.

| Column |
|----------|
| category_id |
| Category |

---

### dim_dish

Stores dish information.

| Column |
|----------|
| dish_id |
| Dish_Name |

---

## Fact Table

### fact_sales

Central table containing transactional data.

| Column |
|----------|
| order_id |
| price_inr |
| rating |
| rating_count |
| date_id |
| category_id |
| location_id |
| dish_id |
| restaurant_id |

---

# 🔄 Extract , Transform  , Load Process (ETL)

## Extract

Raw data loaded from the Swiggy source table.

## Transform

- Null value checks
- Duplicate removal
- Date decomposition
- Dimension key generation

## Load

Data loaded into:

- dim_date
- dim_location
- dim_restaurant
- dim_category
- dim_dish
- fact_sales

using SQL JOIN operations.

---

# 📊 Key Performance Indicators (KPIs)

The following KPIs were calculated:

### Total Orders

```sql
SELECT COUNT(*) FROM fact_sales;
```

### Total Revenue

```sql
SELECT SUM(price_inr) FROM fact_sales;
```

### Average Dish Price

```sql
SELECT AVG(price_inr) FROM fact_sales;
```

### Average Rating

```sql
SELECT AVG(rating) FROM fact_sales;
```

---

# 📈 Exploratory Data Analysis (EDA)

## Time-Based Analysis

### Monthly Order Trends

- Analyze order volume across months.
- Identify peak ordering periods.

### Monthly Revenue Trends

- Revenue generated per month.

### Quarterly Order Trends

- Compare performance across quarters.

### Yearly Trends

- Analyze annual growth.

### Orders by Day of Week

- Identify busiest days.

---

## Location Analysis

### Top 10 Cities by Orders

Find cities generating maximum order volume.

### Revenue Contribution by State

Analyze state-level business performance.

---

## Restaurant Analysis

### Top 10 Restaurants by Revenue

Identify highest revenue-generating restaurants.

---

## Cuisine Analysis

### Top Categories by Orders

Identify most popular cuisines.

### Cuisine Performance

Metrics analyzed:

- Total Orders
- Average Rating

---

## Dish Analysis

### Most Ordered Dishes

Identify customer favorite dishes.

---

## Price Analysis

Orders segmented into:

- ₹0–100
- ₹100–199
- ₹200–299
- ₹300–399
- ₹400–499
- ₹500+

Used to understand customer spending behavior.

---

## Rating Analysis

### Rating Distribution

Analyzed rating frequencies to understand customer satisfaction levels.

---

# 💡 Key Business Insights

The project helps answer:

- Which city generates the most orders?
- Which restaurant earns the highest revenue?
- Which cuisine category is most popular?
- What are the peak ordering months?
- How are customer ratings distributed?
- Which price range receives the most orders?
- What dishes are ordered most frequently?

---

# 🛠️ Technologies Used

- SQL Server
- T-SQL
- Data Warehousing
- ETL Concepts
- Window Functions
- Aggregate Functions
- Joins
- CTEs
- Star Schema Modeling

---

# 📚 SQL Concepts Demonstrated

- Joins
- Common Table Expressions (CTEs)
- Window Functions
- Aggregate Functions
- CASE Statements
- GROUP BY
- HAVING
- Data Cleaning Techniques
- Star Schema Design
- Fact and Dimension Modeling

---

# 🚀 Future Enhancements

- Build interactive Power BI Dashboard
- Add Customer Dimension
- Add Delivery Performance Metrics
- Implement Incremental ETL Loading
- Create Revenue Forecasting Models
- Perform Advanced Customer Segmentation

---

# 👨‍💻 

**Amir Lakra**

SQL Data Analytics Project focused on Data Warehousing, ETL Processes, and Exploratory Data Analysis using Swiggy food delivery data.
