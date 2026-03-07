# Supply Chain Analytics Platform

## Project Overview

This project demonstrates an end-to-end data analytics workflow for analyzing supply chain performance.

The goal of this project is to transform raw operational data into actionable business insights using Python, SQL, and Power BI.

The project includes data cleaning, exploratory data analysis, data warehouse modeling, and KPI reporting through an interactive dashboard.

---

## Dataset

The dataset used in this project comes from **Kaggle** and contains more than **180,000 rows** of supply chain and sales data.

The dataset includes information about:

- Orders
- Customers
- Products
- Shipping performance
- Markets and regions
- Sales and profit metrics

---

## Exploratory Data Analysis (EDA)

Exploratory Data Analysis was performed using **Python (Pandas, NumPy)** to understand the structure and quality of the dataset.

Key EDA tasks included:

- Data cleaning and handling missing values
- Identifying outliers
- Sales and profit distribution analysis
- Shipping delay investigation
- Product and market performance exploration

---

## Data Warehouse Design

A **PostgreSQL data warehouse** was designed using a **Star Schema architecture**.

The warehouse includes:

- Fact_Orders (Fact table)
- Dim_Product
- Dim_Customer
- Dim_Date
- Dim_Market

This structure enables efficient analytical queries and KPI calculations.

---

## SQL Analysis

Advanced SQL queries were developed for analytical reporting, including:

- Aggregations
- Window Functions
- Profit and revenue calculations
- Market and product performance analysis

---

## Key Business KPIs

The following management KPIs were implemented:

- Total Revenue
- Total Profit
- Profit Margin
- Average Shipping Delay
- Late Delivery Rate
- Top Performing Products
- Market Revenue Distribution

---

## Dashboard

An interactive **Power BI dashboard** was created with three analytical pages:

1. **Management Overview**
2. **Logistics Performance**
3. **Product Performance**

Dashboard screenshots can be found in the **images** folder.

---

## Tech Stack

- Python (Pandas, NumPy)
- SQL
- PostgreSQL
- Power BI
- DAX
- Data Warehousing
- ETL

---

## Project Structure
