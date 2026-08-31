USE EcommerceAnalytics;
GO
SELECT TOP 10 *
FROM dbo.olist_customers_dataset;
GO

SELECT COUNT(*) AS TotalCustomers
FROM dbo.olist_customers_dataset;
GO

-- Check Product data load

SELECT TOP 10 *
FROM dbo.olist_products_dataset;
GO

SELECT COUNT(*) AS TotalProducts
FROM dbo.olist_products_dataset;
GO

-- Check Seller load

SELECT TOP 10 *
FROM dbo.olist_sellers_dataset;
GO

SELECT COUNT(*) AS TotalSellers
FROM dbo.olist_sellers_dataset;
GO

-- Check Geoloction load
SELECT TOP 10 *
FROM dbo.olist_geolocation_dataset;
GO

SELECT COUNT(*) AS TotalGeographyRows
FROM dbo.olist_geolocation_dataset;
GO

-- Check orders data load
SELECT TOP 10 *
FROM dbo.olist_orders_dataset;
GO

SELECT COUNT(*) AS TotalOrders
FROM dbo.olist_orders_dataset;
GO

-- Check Order_items data load
SELECT TOP 10 *
FROM dbo.olist_order_items_dataset;
GO

SELECT COUNT(*) AS TotalOrderItems
FROM dbo.olist_order_items_dataset;
GO

-- check payments data load
SELECT TOP 10 *
FROM dbo.olist_order_payments_dataset;
GO

SELECT COUNT(*) AS TotalPaymentRows
FROM dbo.olist_order_payments_dataset;
GO

-- check reviews data loads
SELECT TOP 10 *
FROM dbo.olist_order_reviews_dataset;
GO

SELECT COUNT(*) AS TotalReviews
FROM dbo.olist_order_reviews_dataset;
GO

-- check poduct category name translation dta load
SELECT TOP 10 *
FROM dbo.product_category_name_translation;
GO

SELECT COUNT(*) AS TotalCategories
FROM dbo.product_category_name_translation;
GO