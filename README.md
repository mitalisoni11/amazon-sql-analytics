# Amazon Product Sales Analysis

## Overview

This project analyzes an Amazon sales dataset using MySQL to extract insights into product pricing, discounts, and customer reviews. The dataset is structured into multiple normalized tables (Products, Discounts, Users, and Reviews) for efficient querying and analysis. Additionally, a Python-based ETL pipeline cleans and loads the data into a MySQL database.

## Database Schema

**Tables**

- Products (product_id, product_name, category)
- Discounts (product_id, discounted_price, actual_price, discount_percentage)
- Users (user_id, user_name)
- Reviews (review_id, product_id, user_id, review_title, review_content, rating, rating_count)

## Features
- Data Cleaning & Processing: Cleans raw CSV data using Python (Pandas & Regex) to ensure consistency.
- Database Schema: MySQL database with normalized tables to store products, users, discounts, and reviews.
- SQL Queries for Insights: Executes complex queries to extract insights such as:
  - Top-rated and worst-rated products.
  - Products with high ratings but low review counts.
  - Average ratings and discount percentages per category.
  - Products with above-average discounts in their category.
  - Discount categorization (High, Medium, Low).
- ETL Pipeline: Automates the data ingestion into MySQL using Python and pymysql.

## SQL Queries Implemented
- Top 10 best & worst rated products
- Products with high ratings but low review counts
- Average rating per category
- Average discount percentage per category
- Top 5 products with highest discounts per category
- Average rating by category for products with >100 reviews
- Products with above-average discounts in their category
- Discount categorization (High, Medium, Low)

## Python Data Pipeline
- Reads raw data from a CSV file.
- Cleans and transforms data (price conversion, discount normalization, rating count parsing).
- Inserts data into MySQL database using pymysql.




