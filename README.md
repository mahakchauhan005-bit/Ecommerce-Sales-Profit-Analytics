E-Commerce Sales & Profit Analytics

End-to-end e-commerce analytics project built with Python, SQL, Excel, and Power BI using the Brazilian Olist e-commerce dataset.

Dashboard Preview

Executive Summary



Product Performance Analysis



Customer & Segment Analysis



Delivery Performance Analysis



Product Detail Drill-through



Product Performance Tooltip



Project Overview

This project analyzes an e-commerce business across sales, products, customers, and delivery operations.

The workflow combines data validation and exploratory analysis in Python, SQL analytics, Excel reporting, and an interactive Power BI dashboard.

Business Questions

How is revenue changing over time?

Which product categories generate the most revenue?

Which categories have the highest sales volume?

Which customer segments generate the most revenue?

Which Brazilian states contribute the most revenue?

How many orders are delivered versus late?

How does delivery performance change over time?

Which customer segments generate the highest revenue per customer?

Tools & Technologies

Area

Tools

Data Analysis

Python, Pandas, NumPy

Database & Analytics

MySQL, SQL

Spreadsheet Analysis

Microsoft Excel

Data Preparation

Power Query

BI & Visualization

Power BI, DAX

Python Analysis

The Python workflow covers data validation, EDA, data cleaning, customer-level analysis, RFM-style segmentation, and statistical analysis.

Customer Segmentation

Customers were grouped using Recency, Frequency, and Monetary Value features.

Main segments:

At Risk

Regular Customers

Champions

SQL Analytics

The SQL work covers database and business analytics, including:

Table/database design

Views

Stored procedures

Triggers

Transactions

Indexes

Business analysis queries

Excel Analysis

The Excel workbook contains:

Monthly sales analysis

Customer analysis

Product analysis

Delivery analysis

PivotTables

PivotCharts

Executive Summary

Executive Summary KPIs

Total Revenue: 13.59M

Total Orders: 98.67K

Total Customers: 95.42K

Average Order Value: 136.68

Total Freight: 2.25M

Late Delivery Rate: 8.11%

Power BI Dashboard

The Power BI report uses a star-schema model and interactive report pages.

Executive Summary

KPI cards

Monthly Revenue Trend

Monthly Order Volume

Top 10 Product Categories by Revenue

Revenue by Customer Segment

Average Delivery Days by Month

Interactive slicers

Page navigation

Product Performance Analysis

Top 10 Product Categories by Revenue

Top 10 Product Categories by Items Sold

Average Selling Price by Product Category

Product Volume vs Revenue

Customer & Segment Analysis

Revenue by Customer Segment

Customers by Segment

Top 10 States by Revenue

Revenue per Customer by Segment

Customer filters and segment analysis

Delivery Performance Analysis

Late Delivery Rate vs 5% Target

Delivered vs Late Orders

Average Delivery Days by State

Average Delivery Days Trend

Interactive Year, State, and Order Status filters

Advanced Power BI Features

Star-schema data model

DAX measures

Page navigation

Synced slicers

Product-category drill-through

Report-page tooltip

KPI target gauge

Interactive filtering

Data Model

Fact Tables

FactOrders

FactOrderItems

Dimension Tables

DimCustomers

DimCustomerSegments

DimProducts

DimSellers

DateTable

Supporting Lookup

product_category_name_translation.csv is used during Power Query preparation to add English product category names to DimProducts.

Core Relationships

DimCustomers        1 ─── * FactOrders
FactOrders          1 ─── * FactOrderItems
DimProducts         1 ─── * FactOrderItems
DimSellers          1 ─── * FactOrderItems
DateTable           1 ─── * FactOrders

Core DAX Measures

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

Project Structure

Ecommerce-Sales-Profit-Analytics/
│
├── data/
│   ├── raw/
│   └── processed/
│       ├── fact/
│       └── dimension/
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
│   └── scripts/
│
├── sql/
│   └── SQL Analytics and Database Scripts/
│
├── excel/
│   └── Ecommerce_Analysis.xlsx
│
├── powerbi/
│   └── Ecommerce-Sales-Profit-Analytics.pbix
│
└── README.md

Dataset

This project uses the Brazilian E-Commerce Public Dataset by Olist.

Original source files are kept in data/raw/.

Author

Mahak Chauhan

E-Commerce Sales & Profit Analytics Portfolio Project