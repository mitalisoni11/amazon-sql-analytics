import pymysql
import pandas as pd
import re

# MySQL Database Configuration
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "Illusion1198",
    "database": "AmazonDB"
}

# Load CSV file
file_path = "amazon.csv"
df = pd.read_csv(file_path)


# Data Cleaning Functions
def clean_price(price):
    """Convert price strings (₹1,099) to float (1099.00)."""
    if isinstance(price, str):
        price = re.sub(r"[^\d.]", "", price)  # Remove currency symbols
        return float(price) if price else None
    return None


def clean_discount(discount):
    """Convert discount strings (e.g., '50%') to float (50.00)."""
    if isinstance(discount, str):
        discount = discount.replace("%", "").strip()  # Remove percentage symbol
        return float(discount) if discount else None
    return None


def clean_rating_count(count):
    """Convert rating count (e.g., '24,269') to integer."""
    if isinstance(count, str):
        count = count.replace(",", "")  # Remove commas
        return int(count) if count.isdigit() else None
    return None


# Clean Data
df["discounted_price"] = df["discounted_price"].apply(clean_price)
df["actual_price"] = df["actual_price"].apply(clean_price)
df["discount_percentage"] = df["discount_percentage"].apply(clean_discount)
df["rating_count"] = df["rating_count"].apply(clean_rating_count)
df["rating"] = pd.to_numeric(df["rating"], errors="coerce")
df = df.dropna()  # Remove rows with missing values


# Insert Data into MySQL
INSERT_PRODUCTS = """
INSERT INTO Products (product_id, product_name, category)
VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE product_name = VALUES(product_name), category = VALUES(category);
"""

INSERT_DISCOUNTS = """
INSERT INTO Discounts (product_id, discounted_price, actual_price, discount_percentage)
VALUES (%s, %s, %s, %s) ON DUPLICATE KEY UPDATE discounted_price = VALUES(discounted_price), 
actual_price = VALUES(actual_price), discount_percentage = VALUES(discount_percentage);
"""

INSERT_USERS = """
INSERT INTO Users (user_id, user_name)
VALUES (%s, %s) ON DUPLICATE KEY UPDATE user_name = VALUES(user_name);
"""

INSERT_REVIEWS = """
INSERT INTO Reviews (review_id, product_id, user_id, review_title, review_content, rating, rating_count)
VALUES (%s, %s, %s, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE review_title = VALUES(review_title), 
review_content = VALUES(review_content), rating = VALUES(rating), rating_count = VALUES(rating_count);
"""

# Connect to MySQL and Insert Data
try:
    connection = pymysql.connect(**DB_CONFIG)
    cursor = connection.cursor()

    # Insert records into the tables
    for _, row in df.iterrows():
        # Insert into Products
        cursor.execute(INSERT_PRODUCTS, (row["product_id"], row["product_name"], row["category"]))

        # Insert into Discounts
        cursor.execute(INSERT_DISCOUNTS, (row["product_id"], row["discounted_price"], row["actual_price"], row["discount_percentage"]))

        # Insert into Users (avoid duplicate user IDs)
        cursor.execute(INSERT_USERS, (row["user_id"], row["user_name"]))

        # Insert into Reviews
        cursor.execute(INSERT_REVIEWS, (row["review_id"], row["product_id"], row["user_id"], row["review_title"], row["review_content"], row["rating"], row["rating_count"]))

    # Commit all insertions
    connection.commit()
    print("Data inserted successfully!")

except pymysql.MySQLError as e:
    print("Error:", e)
finally:
    cursor.close()
    connection.close()
