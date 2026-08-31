🛒 E-Commerce Sales & Profit Analytics

End-to-end e-commerce analytics project built with Python, SQL, Excel, Power BI, and DAX using the Brazilian E-Commerce Public Dataset by Olist.

This portfolio project covers the full analytics workflow from data preparation and exploratory analysis to customer segmentation, SQL business analytics, Excel reporting, and an interactive Power BI dashboard.

📊 Dashboard Preview

🏠 Executive Summary



🛍️ Product Performance Analysis



👥 Customer & Segment Analysis



🚚 Delivery Performance Analysis



🔎 Product Detail Drill-through



💡 Product Performance Tooltip



🔎 Project Overview

This project analyzes an e-commerce business across four core areas:

Sales and revenue performance

Product performance

Customer behavior and segmentation

Delivery and operational performance

The workflow combines Python analysis, SQL analytics, Excel reporting, Power Query transformations, and Power BI visualization.

🎯 Business Questions

How is revenue changing over time?

Which product categories generate the most revenue?

Which categories have the highest sales volume?

Which customer segments generate the most revenue?

Which Brazilian states contribute the most revenue?

How many orders are delivered versus late?

How does delivery performance change over time?

Which customer segments generate the highest revenue per customer?

🛠️ Tools & Technologies

Area

Tools

Data Analysis

Python, Pandas, NumPy

Statistical Analysis

Python

Database & Analytics

MySQL, SQL

Spreadsheet Analysis

Microsoft Excel

Data Preparation

Power Query

BI & Visualization

Power BI, DAX

Development Environment

Jupyter Notebook

🐍 Python Analysis

The Python workflow includes:

Data validation

Data cleaning

Exploratory Data Analysis (EDA)

Customer-level aggregation

RFM-style customer segmentation

Statistical analysis

Generation of processed Fact and Dimension datasets

👥 Customer Segmentation

Customers were analyzed using RFM-style features:

Recency

Frequency

Monetary Value

Main customer segments:

At Risk

Regular Customers

Champions

📓 Main Notebooks

01_data_validation.ipynb

02_eda.ipynb

03_customer_analysis.ipynb

04_statistical_analysis.ipynb

🐍 Main Scripts

customer_segmentation.py

create_processed_tables.py

data_cleaning.py

data_validation.py

🗄️ SQL Analytics

The SQL component demonstrates database design, SQL programming, optimization, and business analytics.

Included

Database creation

Table creation

Data loading

Data cleaning

Business analytics queries

Advanced analytics

Views

Query optimization

SQL Concepts

SELECT

WHERE

ORDER BY

GROUP BY

HAVING

Aggregate Functions

INNER JOIN

LEFT JOIN

Subqueries

Views

Stored Procedures

Triggers

Transactions

Indexes

Primary Keys

Foreign Keys

Constraints

📗 Excel Analysis

The Excel workbook contains:

Executive Summary

Monthly Sales Analysis

Customer Analysis

Product Analysis

Delivery Analysis

PivotTables

PivotCharts

Workbook:

excel/Ecommerce_Analysis.xlsx

📌 Executive Summary KPIs

KPI

Value

Total Revenue

13.59M

Total Orders

98.67K

Total Customers

95.42K

Average Order Value

136.68

Total Freight

2.25M

Late Delivery Rate

8.11%

📈 Power BI Dashboard

The Power BI report uses a star-schema model with interactive report pages, DAX measures, slicers, drill-through, report tooltips, and KPI targets.

🏠 Executive Summary

Key visuals include:

Total Revenue

Total Orders

Total Customers

Average Order Value

Total Freight

Late Delivery Rate

Monthly Revenue Trend

Monthly Order Volume

Top 10 Product Categories by Revenue

Revenue by Customer Segment

Average Delivery Days by Month

Interactive slicers and page navigation

🛍️ Product Performance Analysis

Key visuals include:

Top 10 Product Categories by Revenue

Top 10 Product Categories by Items Sold

Average Selling Price by Product Category

Product Volume vs Revenue

👥 Customer & Segment Analysis

Key visuals include:

Revenue by Customer Segment

Customers by Segment

Top 10 States by Revenue

Revenue per Customer by Segment

Interactive customer-segment filtering

Customer segments:

At Risk

Regular Customers

Champions

🚚 Delivery Performance Analysis

Key visuals include:

Late Delivery Rate vs 5% Target

Delivered vs Late Orders

Average Delivery Days by State

Average Delivery Days Trend

Interactive Year, Customer State, and Order Status filters

🔎 Advanced Power BI Features

The report demonstrates:

Star-schema data modeling

DAX KPI measures

Page navigation

Interactive slicers

Synced slicers

Product-category drill-through

Product performance report tooltip

KPI target gauge

Time-based analysis

Interactive filtering

Product Detail Drill-through

Selecting a product category from the Product Performance page allows the user to drill into a dedicated Product Detail page containing category-level metrics.

Product Performance Tooltip

Hovering over product categories displays additional performance metrics through a dedicated report-page tooltip.

🧩 Data Model

The Power BI model follows a star-schema architecture.

Fact Tables

FactOrders

FactOrderItems

Dimension Tables

DimCustomers

DimCustomerSegments

DimProducts

DimSellers

DateTable

Core Relationships

DimCustomers        1 ─── * FactOrders
FactOrders          1 ─── * FactOrderItems
DimProducts         1 ─── * FactOrderItems
DimSellers          1 ─── * FactOrderItems
DateTable           1 ─── * FactOrders

The product_category_name_translation.csv lookup is used during Power Query preparation to add English product category names to DimProducts.

🧮 Core DAX Measures

Total Revenue =
SUM(FactOrderItems[price])

Total Orders =
DISTINCTCOUNT(FactOrders[order_id])

Total Customers =
DISTINCTCOUNT(DimCustomers[customer_unique_id])

Average Order Value =
DIVIDE([Total Revenue], [Total Orders])

Total Freight =
SUM(FactOrderItems[freight_value])

Average Freight =
AVERAGE(FactOrderItems[freight_value])

Delivered Orders =
CALCULATE(
    [Total Orders],
    FactOrders[order_status] = "delivered"
)

Late Orders =
CALCULATE(
    [Total Orders],
    FILTER(
        FactOrders,
        NOT(ISBLANK(FactOrders[order_delivered_customer_date]))
            &&
        FactOrders[order_delivered_customer_date]
            > FactOrders[order_estimated_delivery_date]
    )
)

Late Delivery Rate =
DIVIDE([Late Orders], [Delivered Orders], 0)

Total Items Sold =
COUNTROWS(FactOrderItems)

Revenue per Customer =
DIVIDE([Total Revenue], [Total Customers])

Late Delivery Target =
0.05

Average Selling Price =
DIVIDE([Total Revenue], [Total Items Sold])

📌 Data Source

This project uses the Brazilian E-Commerce Public Dataset by Olist.

The original raw CSV files are intentionally not stored directly in this repository because several source files exceed GitHub's standard web-upload file-size limit.

Dataset

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

See data/raw/README.md for setup instructions.

📂 Project Structure

Ecommerce-Sales-Profit-Analytics/
│
├── data/
│   ├── raw/
│   │   └── README.md
│   │
│   └── processed/
│       ├── fact/
│       │   ├── FactOrders.csv
│       │   ├── FactOrderItems.csv
│       │   └── README.md
│       │
│       └── dimension/
│           ├── DateTable.csv
│           ├── DimCustomers.csv
│           ├── DimCustomerSegments.csv
│           ├── DimProducts.csv
│           ├── DimSellers.csv
│           └── README.md
│
├── images/
│   ├── executive_summary.png
│   ├── product_performance.png
│   ├── customer_segment_analysis.png
│   ├── delivery_performance.png
│   ├── product_detail.png
│   └── product_tooltip.png
│
├── python/
│   ├── notebooks/
│   │   ├── 01_data_validation.ipynb
│   │   ├── 02_eda.ipynb
│   │   ├── 03_customer_analysis.ipynb
│   │   ├── 04_statistical_analysis.ipynb
│   │   └── README.md
│   │
│   └── scripts/
│       ├── customer_segmentation.py
│       ├── create_processed_tables.py
│       ├── data_cleaning.py
│       ├── data_validation.py
│       └── README.md
│
├── sql/
│   └── SQL Analytics and Database Scripts/
│       ├── 01_Create_Database.sql
│       ├── 02_Create_Tables.sql
│       ├── 03_Load_Data.sql
│       ├── 04_Data_Cleaning.sql
│       ├── 05_Business_Queries.sql
│       ├── 06_Advanced_Analytics.sql
│       ├── 07_Views.sql
│       └── README.md
│
├── excel/
│   ├── Ecommerce_Analysis.xlsx
│   └── README.md
│
├── powerbi/
│   ├── Ecommerce-Sales-Profit-Analytics.pbix
│   └── README.md
│
└── README.md

🧠 Learning Outcomes

Through this project I practiced:

Data Cleaning & Validation

Exploratory Data Analysis

RFM Customer Segmentation

Business Analytics

SQL Query Development

Database Design

Excel Reporting

Power Query

Star-Schema Data Modeling

DAX Measure Development

Interactive Power BI Dashboard Development

Drill-through Analysis

Report Tooltip Design

KPI Target Analysis

Business-focused Data Storytelling

👩‍💻 Author

Mahak Chauhan

🔗 GitHub: https://github.com/mahakchauhan005-bit

⭐ If you found this project useful, consider giving it a star on GitHub!
E-Commerce Sales & Profit Analytics Portfolio Project
