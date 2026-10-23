USE SwiggyDB;

SELECT * FROM Swiggy_Data
-- Data validation and cleaning
-- Null check
USE SwiggyDB

SELECT 
SUM (CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Null_city,
SUM(CASE WHEN Order_date IS NULL THEN 1 ELSE 0 END) AS null_order_data,
SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS Null_restaurant,
SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS Null_location,
SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS Null_category,
SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS Null_dish_name,
SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS Null_price,
SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS Null_rating,
SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS Null_rating_count
FROM Swiggy_Data;

-- Empty strings
SELECT *
FROM Swiggy_Data
WHERE 
State = '' OR City = '' OR Restaurant_Name = '' OR Location = '' OR Dish_name = '' 

-- Duplicate detection

SELECT
State, City,Order_date, restaurant_name,location, category, dish_name,Price_INR,rating_count, count(*) AS CNT
FROM Swiggy_Data
GROUP BY
State, City,Order_date, restaurant_name,location, category, dish_name,Price_INR,rating_count
HAVING count(*) >1


-- Remove Duplicates
WITH CTE AS (
SELECT *,ROW_NUMBER() OVER (PARTITION BY State, City,Order_date, restaurant_name,location, category, 
dish_name,Price_INR,rating_count
ORDER BY (SELECT NULL)
) AS NEWD
FROM swiggy_data
)
DELETE FROM CTE
WHERE NEWD>1


-- Creating tables

CREATE TABLE Date_Table (
date_id INT IDENTITY (1,1) PRIMARY KEY,
Full_date DATE,
Year INT,
Month INT,
Month_name VARCHAR(20),
Quarter int,
Day INT,
Week INT
)

CREATE TABLE Location_table (
location_id INT IDENTITY(1,1) PRIMARY KEY,
State VARCHAR(100),
City VARCHAR(100),
Location VARCHAR(200)
);

CREATE TABLE restaurant_table (
restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
restaurant_name VARCHAR(200)
);

CREATE TABLE Category_table (
category_id INT IDENTITY(1,1) PRIMARY KEY,
Category VARCHAR(200)
)

CREATE TABLE Dish_table (
dish_id int IDENTITY (1,1) PRIMARY KEY,
Dish_name VARCHAR(200)
)

SELECT * from Swiggy_orders

CREATE TABLE Swiggy_orders (
order_id INT IDENTITY(1,1) PRIMARY KEY,
date_id INT,
Price_INR DECIMAL(10,2),
Rating DECIMAL(4,2),
Rating_count INT,
location_id INT,
restaurant_id INT,
category_id INT,
Dish_id INT,
FOREIGN KEY (date_id) REFERENCES date_table(date_id),
FOREIGN KEY (location_id) REFERENCES location_table(location_id),
FOREIGN KEY (restaurant_id) REFERENCES restaurant_table(restaurant_id),
FOREIGN KEY (category_id) REFERENCES category_table(category_id),
FOREIGN KEY (dish_id) REFERENCES dish_table(dish_id)
)

DROP TABLE Swiggy_orders;

-- Insert data into the table

INSERT INTO Date_table (Full_date, Year, Month, Month_name, Quarter,Day, Week)
SELECT DISTINCT
Order_Date,
YEAR(Order_Date),
MONTH(Order_Date),
DATENAME(MONTH, Order_Date),
DATEPART (QUARTER, Order_Date),
DAY (Order_Date),
DATEPART (WEEK,Order_Date)
from Swiggy_Data
WHERE Order_Date IS NOT NULL;

SELECT * FROM Date_Table;

--- location data entered

INSERT INTO Location_table (State, City, Location)
SELECT DISTINCT
State,
City,
Location
FROM Swiggy_Data;

SELECT * FROM Location_table;

---Restaurant table
INSERT INTO restaurant_table (Restaurant_name)
SELECT DISTINCT
Restaurant_Name
FROM Swiggy_Data;

--- Category table

INSERT INTO Category_table (Category)
SELECT DISTINCT
Category
FROM Swiggy_Data;

-- Dish table

INSERT INTO Dish_table (Dish_name)
SELECT DISTINCT
Dish_name
FROM Swiggy_Data;

--- swiggy order table

INSERT INTO Swiggy_orders
(
    date_id,
    Price_INR,
    Rating,
    Rating_count,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT
    dd.date_id,
    s.Price_INR,
    s.Rating,
    s.Rating_count,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM Swiggy_Data s

JOIN Date_table dd
    ON dd.Full_Date = s.Order_Date

JOIN location_table dl
    ON dl.State = s.State
    AND dl.City = s.City
    AND dl.location = s.location

JOIN restaurant_table dr
    ON dr.restaurant_name = s.restaurant_name

JOIN Category_table dc
    ON dc.category = s.category

JOIN Dish_table dsh
    ON dsh.Dish_name = s.Dish_Name

SELECT * FROM Swiggy_orders;

-- Joining all the table


    SELECT * FROM Swiggy_Orders f

    JOIN date_table d ON f.date_id = d.date_id
    JOIN location_table l ON f.location_id = l.location_id
    JOIN restaurant_table r ON f.restaurant_id = r.restaurant_id
    JOIN category_table c ON f.category_id = c.category_id
    JOIN dish_table di ON f.dish_id  = di.dish_id;



-- KPI's
-- Total order

SELECT COUNT(*) AS Total_Orders
FROM swiggy_orders;


-- Total Revenue

SELECT FORMAT(SUM (CONVERT(FLOAT,Price_INR))/1000000, 'N2') + ' M Million'
AS Total_Revenue
FROM Swiggy_Orders;


-- Avg Dish price

SELECT FORMAT (AVG (CONVERT(FLOAT,Price_INR)), 'N2') + ' INR'
AS Avg_Revenue
FROM Swiggy_Orders

-- Avg Rating

SELECT AVG(Rating) AS Avg_Rating
FROM Swiggy_orders;


-- Date-Based Analysis
--- Monthly orders analysis
SELECT 
d.year,
d.Month,
d.Month_name,
COUNT(*) AS Total_orders
FROM swiggy_orders f
JOIN Date_table d
ON f.date_id = d.date_id
GROUP BY 
d.Year,
d.Month,
d.Month_name
Order by COUNT(*) desc

--- Monthly order sales

SELECT 
d.year,
d.Month,
d.Month_name,
FORMAT (SUM(CONVERT(FLOAT, Price_INR))/1000000, 'N2') +'M' AS Total_Revenue
FROM swiggy_orders f
JOIN Data_table d
ON f.date_id = d.date_id
GROUP BY 
d.Year,
d.Month,
d.Month_name
Order by SUM(Price_INR) desc

-- Quarterly ORDER Analysis

SELECT 
d.year,
d.Quarter,
COUNT(*) AS Total_orders
FROM swiggy_orders f
JOIN Data_table d
ON f.date_id = d.date_id
GROUP BY 
d.Year,
d.Quarter
ORDER BY COUNT(*) desc

--- Yearly Order analysis
SELECT
d.year,
count(*) AS Total_orders
FROM Swiggy_orders f
JOIN Data_table d
ON f.date_id = d.date_id
GROUP BY d.year

-- week days analysis
SELECT
DATENAME(WEEKDAY,d.Full_date) AS Day_name,
COUNT(*) AS Total_orders
FROM Swiggy_orders f
JOIN Data_table d
ON f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY,d.Full_date), DATEPART(WEEKDAY, d.Full_date)
ORDER BY DATEPART(WEEKDAY,d.Full_date);

-- Top 10 cities by order

SELECT TOP 10
l.City,
COUNT(*) AS Total_orders FROM Swiggy_orders f
JOIN location_table l
ON l.location_id = f.Location_id
GROUP BY l.city
ORDER BY COUNT(*) DESC;

-- Bottom 5 cities order

SELECT TOP 5
l.City,
COUNT(*) AS Total_orders FROM Swiggy_orders f
JOIN location_table l
ON l.location_id = f.Location_id
GROUP BY l.city
ORDER BY COUNT(*) ASC;

-- Revenue contribution by states

SELECT
l.State,
FORMAT(SUM(CONVERT(FLOAT,f.Price_INR))/1000000,'N2')+ 'M' AS Total_Revenue FROM Swiggy_Orders f
JOIN Location_table l
ON l.Location_id = f.Location_id
GROUP BY l.State
ORDER BY SUM(f.Price_INR) DESC;

-- Top 10 restaurants by orders

SELECT TOP 10
r.restaurant_name,
COUNT(*) AS Total_Order_by_Restaurant FROM Swiggy_orders f
JOIN Restaurant_table r
ON r.restaurant_id = f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY COUNT(*) DESC

-- Top 10 restaurants by revenue

SELECT TOP 10
r.restaurant_name,
SUM(f.Price_INR) AS Total_Restaurants_Revenue FROM Swiggy_orders f
JOIN Restaurant_table r
ON r.restaurant_id = f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY SUM(f.Price_INR) DESC


-- Top categories by orders

SELECT
c.category,
COUNT(*) AS Total_orders FROM Swiggy_orders f
JOIN category_table c
ON c.category_id = f.category_id
GROUP BY c.category
ORDER BY COUNT(*) DESC;

-- Most ordered dishes

SELECT TOP 10
d.dish_name,
COUNT(*) AS Total_orders FROM Swiggy_orders f
JOIN Dish_table d
ON f.dish_id = d.dish_id
GROUP BY d.Dish_name
ORDER BY Total_orders DESC;

-- Cuisine performance → Orders + Avg Rating

SELECT
c.category,
COUNT(*) AS Total_order,
AVG(f.rating) AS Order_rating
FROM Swiggy_orders f
JOIN category_table c
ON f.category_id = c.category_id
GROUP BY c.category
ORDER BY COUNT(*) DESC

-- Price Range Order

SELECT 
     CASE
     WHEN CONVERT(FLOAT,Price_INR)<100 THEN 'Under 100'
     WHEN CONVERT(FLOAT,Price_INR) BETWEEN 100 AND 199 THEN '100-199'
     WHEN CONVERT(FLOAT,Price_INR) BETWEEN 200 AND 299 THEN '200-299'
     WHEN CONVERT(FLOAT,Price_INR) BETWEEN 300 AND 499 THEN '300-499'
     ELSE '500+'
  END AS Price_range,
  COUNT(*) AS Total_orders
FROM Swiggy_orders
GROUP BY
     CASE
     WHEN CONVERT(FLOAT,Price_INR)<100 THEN 'Under 100'
     WHEN CONVERT(FLOAT,Price_INR) BETWEEN 100 AND 199 THEN '100-199'
     WHEN CONVERT(FLOAT,Price_INR) BETWEEN 200 AND 299 THEN '200-299'
     WHEN CONVERT(FLOAT,Price_INR) BETWEEN 300 AND 499 THEN '300-499'
     ELSE '500+'
  END
  ORDER BY Total_orders DESC;

  -- Rating count distribution

  SELECT
  rating,
  COUNT(*) AS Rating_count
  FROM Swiggy_orders
  GROUP BY rating
  ORDER BY COUNT(*) DESC







