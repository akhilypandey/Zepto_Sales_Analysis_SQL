drop table if exists zepto; 
--Creating Table to import data 
create table zepto( sku_id SERIAL PRIMARY KEY, category VARCHAR(120), name VARCHAR(150) NOT NULL, mrp NUMERIC(8,2), discountPercent NUMERIC(5,2), availableQuantity INTEGER, discountedSellingPrice NUMERIC(8,2), weightInGms INTEGER, outOfStock BOOLEAN, quantity INTEGER ) 
-- Data Exploration 

--Count of Rows 
SELECT COUNT(*) FROM zepto; 

--Sample Data of 10 records 
SELECT * FROM zepto LIMIT 10; 

--Null Values 
SELECT * FROM zepto 
WHERE name IS NULL 
OR 
category IS NULL 
OR 
mrp IS NULL 
OR 
discountPercent IS NULL 
OR
discountedSellingPrice IS NULL 
OR 
weightInGms IS NULL 
OR
availableQuantity IS NULL 
OR 
outOfStock IS NULL 
OR
quantity IS NULL; 

--Explore all the product categories 
SELECT DISTINCT category 
FROM zepto 
ORDER BY category; 

--How many products are in stock and out-of-stock 
SELECT outOfStock, COUNT(sku_id) 
FROM zepto 
GROUP BY outOfStock; 

--Check for product names present multiple times 
SELECT name, COUNT(sku_id) as "Number of SKU's" 
FROM zepto 
GROUP BY name 
HAVING COUNT (sku_id)>1 
ORDER BY COUNT(sku_id) DESC; 

-- Data Cleaning 

-- Check for product where price is 0 
SELECT * FROM zepto 
WHERE mrp=0 OR discountedSellingPrice = 0; 

DELETE FROM zepto 
WHERE mrp =0; 

--Converting price to rupee from paise 
UPDATE zepto 
SET mrp = mrp/100.0, discountedSellingPrice = discountedSellingPrice/100.0;

SELECT mrp,discountedSellingPrice FROM zepto;

-- Q1. Top 10 best-value products by discount percentage
-- Business Explanation:
-- Identifies products with the highest discounts to support deal-driven marketing
-- and attract price-sensitive customers.

SELECT
    z.name,
    z.mrp,
    z.discountPercent
FROM zepto AS z
WHERE z.discountPercent IS NOT NULL
ORDER BY z.discountPercent DESC
LIMIT 10 ;


-- Q2. High-MRP products that are out of stock
-- Business Explanation:
-- Helps inventory teams identify high-revenue products that need urgent restocking
-- to avoid potential revenue loss.

SELECT
    z.name,
    z.mrp
FROM zepto z
WHERE z.outOfStock = TRUE
  AND z.mrp >= 300
ORDER BY z.mrp DESC;


-- Q3. Estimated revenue contribution by category
-- Business Explanation:
-- Shows which categories generate the most revenue, enabling category-level
-- planning, prioritization, and promotional decisions.

SELECT
    z.category,
    SUM(z.availableQuantity) * AVG(z.discountedSellingPrice) AS estimated_revenue
FROM zepto z
WHERE z.availableQuantity > 0
GROUP BY z.category
ORDER BY estimated_revenue DESC;


-- Q4. Premium products with minimal discounts
-- Business Explanation:
-- Identifies premium products with low discounts, indicating strong pricing power
-- and opportunities for upselling strategies.

SELECT
    z.name,
    z.mrp,
    z.discountPercent
FROM zepto z
WHERE z.mrp > 500
  AND z.discountPercent BETWEEN 0 AND 10
ORDER BY z.mrp DESC;


-- Q5. Categories with the highest average discount (Top 5)
-- Business Explanation:
-- Highlights categories where heavy discounting is used, helping evaluate margin
-- impact and promotional effectiveness.

SELECT
    category,
    CAST(AVG(discountPercent) AS NUMERIC(5,2)) AS mean_discount
FROM zepto
GROUP BY category
HAVING COUNT(*) > 1
ORDER BY mean_discount DESC
LIMIT 5;


-- Q6. Best value products based on price per gram
-- Business Explanation:
-- Enables fair value comparison across products, supporting transparent pricing
-- and better customer purchase decisions.

SELECT
    z.name,
    z.weightInGms,
    z.discountedSellingPrice,
    ROUND(z.discountedSellingPrice / NULLIF(z.weightInGms, 0), 3) AS cost_per_gram
FROM zepto z
WHERE z.weightInGms >= 100
ORDER BY cost_per_gram ASC;


-- Q7. Product segmentation by weight category
-- Business Explanation:
-- Segments products into low, medium, and bulk categories to support personalized
-- recommendations and packaging strategies.

SELECT
    z.name,
    z.weightInGms,
    CASE
        WHEN z.weightInGms < 1000 THEN 'Low Quantity'
        WHEN z.weightInGms < 5000 THEN 'Medium Quantity'
        ELSE 'Bulk Pack'
    END AS packaging_type
FROM zepto z;


-- Q8. Total inventory weight per category
-- Business Explanation:
-- Helps logistics and warehouse teams understand inventory load distribution
-- for storage optimization and operational efficiency.

SELECT
    category,
    SUM(weightInGms) * SUM(availableQuantity) AS inventory_weight_gms
FROM zepto
GROUP BY category
ORDER BY inventory_weight_gms DESC;