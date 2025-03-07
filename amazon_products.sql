USE AmazonDB;

-- Products Table
CREATE TABLE Products (
    product_id VARCHAR(255) PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL
);

-- Discounts Table
CREATE TABLE Discounts (
    product_id VARCHAR(255),
    discounted_price DECIMAL(10,2),
    actual_price DECIMAL(10,2),
    discount_percentage DECIMAL(5,2),
    PRIMARY KEY (product_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Users Table
CREATE TABLE Users (
    user_id VARCHAR(255) PRIMARY KEY,
    user_name VARCHAR(255)
);

-- Reviews Table
CREATE TABLE Reviews (
    review_id VARCHAR(255) PRIMARY KEY,
    product_id VARCHAR(255),
    user_id VARCHAR(255),
    review_title TEXT,
    review_content TEXT,
    rating FLOAT,
    rating_count INT,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Top 10 best rated products overall 

SELECT p.product_id, p.product_name, ROUND(AVG(r.rating),2) AS average_rating 
FROM Products p JOIN Reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC
LIMIT 10;

-- Top 10 worst rated products overall 

SELECT p.product_id, p.product_name, ROUND(AVG(r.rating),2) AS average_rating 
FROM Products p JOIN Reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating
LIMIT 10;

-- Product with rating greater than or equal to 4.5 but rating count less than 100

SELECT p.product_id, p.product_name, ROUND(AVG(r.rating),2) AS average_rating, 
SUM(r.rating_count) as total_rating_count
FROM Products p JOIN Reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name 
HAVING average_rating>= 4.5 AND total_rating_count<100;

-- Average Rating per category

SELECT p.category, ROUND(AVG(r.rating),2) as average_rating
FROM Products p JOIN Reviews r ON p.product_id = r.product_id
GROUP BY p.category
ORDER BY average_rating DESC;

-- Average Discount % per category

SELECT p.category, ROUND(AVG(d.discount_percentage),2) as average_discount_percentage
FROM Products p JOIN Discounts d on p.product_id = d.product_id
GROUP BY p.category
ORDER BY average_discount_percentage DESC;

-- Top 5 Products in each category with the highest discount percentage

with DiscountedRanks as(
Select p.product_id, p.product_name, p.category, d.discount_percentage,
DENSE_RANK() OVER( PARTITION BY p.category order by d.discount_percentage DESC) AS discount_rank
from Products p join Discounts d
group by p.product_id, p.product_name, p.category, d.discount_percentage)

SELECT * FROM DiscountedRanks where discount_rank<=5;

-- Avg Rating by category considering products with greater tha 100 review count

SELECT p.category, ROUND(AVG(rating),2) as avg_rating, COUNT(r.product_id) as no_of_products
FROM Products p JOIN Reviews r ON p.product_id = r.product_id 
WHERE r.rating_count>100
GROUP BY p.category
ORDER BY avg_rating DESC;

-- Identifying products that have higher than average discount in their category

SELECT p.product_id, p.product_name, p.category, d.discount_percentage
FROM Products p JOIN Discounts d ON p.product_id = d.product_id
WHERE d.discount_percentage > (
    SELECT AVG(d2.discount_percentage) 
    FROM Discounts d2 JOIN Products p2 ON d2.product_id = p2.product_id
    WHERE p.category = p2.category
)
ORDER BY d.discount_percentage DESC;

-- Categorizing products on discount percentage

SELECT p.product_id, p.product_name, p.category, AVG(d.discount_percentage) as avg_discount,
    CASE 
        WHEN AVG(d.discount_percentage) >= 50 THEN 'High Discount'
        WHEN AVG(d.discount_percentage) BETWEEN 20 AND 49 THEN 'Medium Discount'
        ELSE 'Low Discount'
    END AS discount_category
FROM Products p 
JOIN Discounts d ON p.product_id = d.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY discount_percentage DESC;

