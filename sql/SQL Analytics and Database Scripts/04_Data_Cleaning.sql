USE EcommerceAnalytics;
GO
-- Check duplicate customers
SELECT
    customer_id,
    COUNT(*) AS DuplicateCount
FROM dbo.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check duplicate orders
SELECT
    order_id,
    COUNT(*) AS DuplicateCount
FROM dbo.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check missing customer IDs in orders
SELECT COUNT(*) AS MissingCustomerIDs
FROM dbo.olist_orders_dataset
WHERE customer_id IS NULL
   OR LTRIM(RTRIM(customer_id)) = '';

-- Check missing product IDs in order items
SELECT COUNT(*) AS MissingProductIDs
FROM dbo.olist_order_items_dataset
WHERE product_id IS NULL
   OR LTRIM(RTRIM(product_id)) = '';

-- Check invalid prices
SELECT COUNT(*) AS InvalidPrices
FROM dbo.olist_order_items_dataset
WHERE price IS NULL
   OR price < 0;

-- Check invalid review scores
SELECT COUNT(*) AS InvalidReviewScores
FROM dbo.olist_order_reviews_dataset
WHERE review_score IS NULL
   OR review_score NOT BETWEEN 1 AND 5;

-- Check the raw date values
SELECT TOP 20
    order_purchase_timestamp
FROM dbo.olist_orders_dataset
WHERE order_purchase_timestamp IS NOT NULL;

-- TEST TTHE CONVERSION 
SELECT TOP 20
    order_purchase_timestamp,
    TRY_CONVERT(DATETIME2, order_purchase_timestamp) AS CleanPurchaseTimestamp
FROM dbo.olist_orders_dataset;

-- TEST ALL ORDERS DATES
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE
        WHEN order_purchase_timestamp IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_purchase_timestamp) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidPurchaseDates
FROM dbo.olist_orders_dataset;

-- Check order_approved_at
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE
        WHEN order_approved_at IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_approved_at) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidApprovedDates
FROM dbo.olist_orders_dataset;
GO

-- Check order_delivered_carrier_date
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE
        WHEN order_delivered_carrier_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_delivered_carrier_date) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidCarrierDates
FROM dbo.olist_orders_dataset;
GO

-- Check order_delivered_customer_date
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE
        WHEN order_delivered_customer_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_delivered_customer_date) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidCustomerDeliveryDates
FROM dbo.olist_orders_dataset;
GO

-- Check order_estimated_delivery_date
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE
        WHEN order_estimated_delivery_date IS NOT NULL
         AND TRY_CONVERT(DATETIME2, order_estimated_delivery_date) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidEstimatedDates
FROM dbo.olist_orders_dataset;
GO

-- =============================================
-- Delivery Performance Analysis
-- =============================================

SELECT
    order_id AS OrderID,

    TRY_CONVERT(DATETIME2, order_purchase_timestamp) AS PurchaseDate,

    TRY_CONVERT(DATETIME2, order_delivered_customer_date) AS DeliveredDate,

    TRY_CONVERT(DATETIME2, order_estimated_delivery_date) AS EstimatedDate,

    -- Actual number of days taken to deliver
    CASE
        WHEN order_delivered_customer_date IS NOT NULL
        THEN DATEDIFF(
            DAY,
            TRY_CONVERT(DATETIME2, order_purchase_timestamp),
            TRY_CONVERT(DATETIME2, order_delivered_customer_date)
        )
        ELSE NULL
    END AS ActualDeliveryDays,

    -- Expected number of days
    DATEDIFF(
        DAY,
        TRY_CONVERT(DATETIME2, order_purchase_timestamp),
        TRY_CONVERT(DATETIME2, order_estimated_delivery_date)
    ) AS EstimatedDeliveryDays,

    -- Delivery classification
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'

        WHEN TRY_CONVERT(DATETIME2, order_delivered_customer_date)
             <= TRY_CONVERT(DATETIME2, order_estimated_delivery_date)
            THEN 'Delivered On Time'

        WHEN TRY_CONVERT(DATETIME2, order_delivered_customer_date)
             > TRY_CONVERT(DATETIME2, order_estimated_delivery_date)
            THEN 'Delivered Late'

        ELSE 'Unknown'
    END AS DeliveryStatus

FROM dbo.olist_orders_dataset;
GO

-- =============================================
-- Delivery Summary
-- =============================================

WITH DeliveryData AS
(
    SELECT
        order_id,

        TRY_CONVERT(DATETIME2, order_delivered_customer_date)
            AS DeliveredDate,

        TRY_CONVERT(DATETIME2, order_estimated_delivery_date)
            AS EstimatedDate

    FROM dbo.olist_orders_dataset
)

SELECT
    COUNT(*) AS TotalOrders,

    SUM(
        CASE
            WHEN DeliveredDate IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS DeliveredOrders,

    SUM(
        CASE
            WHEN DeliveredDate IS NOT NULL
             AND DeliveredDate > EstimatedDate
            THEN 1
            ELSE 0
        END
    ) AS LateOrders,

    SUM(
        CASE
            WHEN DeliveredDate IS NOT NULL
             AND DeliveredDate <= EstimatedDate
            THEN 1
            ELSE 0
        END
    ) AS OnTimeOrders,

    SUM(
        CASE
            WHEN DeliveredDate IS NULL
            THEN 1
            ELSE 0
        END
    ) AS NotDeliveredOrders,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN DeliveredDate IS NOT NULL
                 AND DeliveredDate > EstimatedDate
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN DeliveredDate IS NOT NULL
                    THEN 1
                    ELSE 0
                END
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS LateDeliveryRatePercent

FROM DeliveryData;
GO

-- Null Analysis on Orders
SELECT
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS ApprovedNulls,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS CarrierDateNulls,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS CustomerDeliveryNulls,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS EstimatedDeliveryNulls
FROM dbo.olist_orders_dataset;
GO

-- Analyze NULLs by Order Status
SELECT 
    order_status,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS ApprovedNulls,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS CarrierDateNulls,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS CustomerDeliveryNulls
FROM dbo.olist_orders_dataset
GROUP BY order_status
ORDER BY TotalOrders DESC;
GO

--Check for Invalid Sales Values
SELECT
    SUM(CASE 
            WHEN price IS NULL OR price <= 0 
            THEN 1 ELSE 0 
        END) AS InvalidPriceRows,

    SUM(CASE 
            WHEN freight_value IS NULL OR freight_value < 0 
            THEN 1 ELSE 0 
        END) AS InvalidFreightRows,

    SUM(CASE 
            WHEN order_item_id IS NULL OR order_item_id <= 0 
            THEN 1 ELSE 0 
        END) AS InvalidOrderItemRows

FROM dbo.olist_order_items_dataset;
GO

-- Check Duplicate Order Items
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS DuplicateCount
FROM dbo.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
GO

--Check for orphan records
SELECT COUNT(*) AS OrphanProductRows
FROM dbo.olist_order_items_dataset oi
LEFT JOIN dbo.olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
GO

-- Sellers
SELECT COUNT(*) AS OrphanSellerRows
FROM dbo.olist_order_items_dataset oi
LEFT JOIN dbo.olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;
GO

-- Check Payment Data Quality
SELECT 
    SUM(CASE
        WHEN payment_value IS NULL OR payment_value < 0
        THEN 1 ELSE 0
    END) AS InvalidPaymentValues,

    SUM(CASE
        WHEN payment_installments IS NULL OR payment_installments < 1
        THEN 1 ELSE 0
    END) AS InvalidInstallments,

    SUM(CASE
        WHEN payment_type IS NULL OR LTRIM(RTRIM(payment_type)) = ''
        THEN 1 ELSE 0
    END) AS InvalidPaymentTypes

FROM dbo.olist_order_payments_dataset;
GO

-- Investigate the 2 Invalid Installments
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM dbo.olist_order_payments_dataset
WHERE payment_installments IS NULL
   OR payment_installments < 1;
GO

--Decide how to handle the 2 invalid installments
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments AS OriginalInstallments,

    CASE
        WHEN payment_installments IS NULL
          OR payment_installments < 1
        THEN 1
        ELSE payment_installments
    END AS CleanInstallments,

    payment_value
FROM dbo.olist_order_payments_dataset
WHERE payment_installments IS NULL
   OR payment_installments < 1;
GO

-- Review Data Quality Audit
SELECT
    SUM(
        CASE
            WHEN review_score IS NULL
              OR review_score NOT BETWEEN 1 AND 5
            THEN 1
            ELSE 0
        END
    ) AS InvalidReviewScores,

    SUM(
        CASE
            WHEN review_id IS NULL
              OR LTRIM(RTRIM(review_id)) = ''
            THEN 1
            ELSE 0
        END
    ) AS InvalidReviewIDs,

    SUM(
        CASE
            WHEN order_id IS NULL
              OR LTRIM(RTRIM(order_id)) = ''
            THEN 1
            ELSE 0
        END
    ) AS InvalidOrderIDs

FROM dbo.olist_order_reviews_dataset;
GO



-- =============================================
-- Task 35: Product Category Data Quality Audit
-- =============================================

-- Count products with a missing or blank category
SELECT
    SUM(
        CASE
            WHEN product_category_name IS NULL
              OR LTRIM(RTRIM(product_category_name)) = ''
            THEN 1
            ELSE 0
        END
    ) AS MissingCategory,

    -- Total number of products
    COUNT(*) AS TotalProducts,

    -- Percentage of products with missing categories
    CAST(
        100.0 *
        SUM(
            CASE
                WHEN product_category_name IS NULL
                  OR LTRIM(RTRIM(product_category_name)) = ''
                THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS CategoryMissingPercentage

FROM dbo.olist_products_dataset;
GO

-- =============================================
-- Task 36: Final Data Quality Summary
-- =============================================

SELECT
    -- Customers
    (
        SELECT COUNT(*)
        FROM dbo.olist_customers_dataset
    ) AS TotalCustomers,

    -- Orders
    (
        SELECT COUNT(*)
        FROM dbo.olist_orders_dataset
    ) AS TotalOrders,

    -- Products
    (
        SELECT COUNT(*)
        FROM dbo.olist_products_dataset
    ) AS TotalProducts,

    -- Sellers
    (
        SELECT COUNT(*)
        FROM dbo.olist_sellers_dataset
    ) AS TotalSellers,

    -- Order Items
    (
        SELECT COUNT(*)
        FROM dbo.olist_order_items_dataset
    ) AS TotalOrderItems,

    -- Payments
    (
        SELECT COUNT(*)
        FROM dbo.olist_order_payments_dataset
    ) AS TotalPayments,

    -- Reviews
    (
        SELECT COUNT(*)
        FROM dbo.olist_order_reviews_dataset
    ) AS TotalReviews,

    -- Products missing category
    (
        SELECT COUNT(*)
        FROM dbo.olist_products_dataset
        WHERE product_category_name IS NULL
           OR LTRIM(RTRIM(product_category_name)) = ''
    ) AS ProductsMissingCategory,

    -- Orders not delivered
    (
        SELECT COUNT(*)
        FROM dbo.olist_orders_dataset
        WHERE order_delivered_customer_date IS NULL
    ) AS OrdersNotDelivered,

    -- Invalid payment installments
    (
        SELECT COUNT(*)
        FROM dbo.olist_order_payments_dataset
        WHERE payment_installments IS NULL
           OR payment_installments < 1
    ) AS InvalidPaymentInstallments;
GO


-- Rename the imported translation columns
EXEC sp_rename 
    'dbo.product_category_name_translation.column1',
    'product_category_name',
    'COLUMN';
GO

EXEC sp_rename 
    'dbo.product_category_name_translation.column2',
    'product_category_name_english',
    'COLUMN';
GO
-- RUN OR VERIFY
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'product_category_name_translation'
ORDER BY ORDINAL_POSITION;
GO