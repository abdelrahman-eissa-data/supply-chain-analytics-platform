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

## Data Architecture

The analytics workflow follows a structured end-to-end data pipeline:

1. **Raw Dataset (CSV Files – Kaggle)**  
   Supply chain dataset containing more than **180,000 rows** stored as CSV files.

2. **Data Cleaning & EDA – Python (Pandas, NumPy)**  
   Data preprocessing, handling missing values, and exploratory analysis using Python.

3. **Data Warehouse Modeling – PostgreSQL**  
   Implementation of a **Star Schema data warehouse** including fact and dimension tables.

4. **SQL Analytics**  
   Advanced SQL queries including **aggregations and window functions** for analytical reporting.

5. **KPI Calculation – DAX (Power BI)**  
   Business metrics and management KPIs calculated using DAX.

6. **Interactive Dashboard – Power BI**  
   Visualization of supply chain insights across management, logistics, and product performance dashboards.

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

## Power BI Dashboard

An interactive **Power BI dashboard** was developed to monitor key supply chain performance indicators and support data-driven decision-making.

The dashboard is structured into three analytical pages, each focusing on a specific business perspective.

### Management Overview
Provides a high-level view of overall business performance, including revenue, profit, and key operational KPIs.

![Management Overview](images/dashboard-overview.png)

### Logistics Performance
Analyzes shipping efficiency, delivery delays, and logistics-related performance metrics.

![Logistics Performance](images/logistics-analysis.png)

### Product Performance
Evaluates product-level performance, profitability, and category-level insights.

![Product Performance](images/product-performance.png)
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
