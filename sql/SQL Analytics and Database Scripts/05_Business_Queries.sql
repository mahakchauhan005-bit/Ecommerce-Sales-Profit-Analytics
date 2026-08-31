USE EcommerceAnalytics;
GO
-- ===============================================================
-- Q1 :What is the total revenue generated from all order items?
-- ===============================================================
SELECT
    SUM(price) AS Total_Revenue,
    AVG(price) AS AvgItemPrice,
    COUNT(price) AS TotalItemSold
FROM dbo.olist_order_items_dataset;
GO

-- =============================================
-- Ques 2: Monthly Revenue Trend
-- =============================================

SELECT
    YEAR(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)) AS Year,
    MONTH(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)) AS Month,
    SUM(oi.price) AS MonthlyRevenue
FROM dbo.olist_order_items_dataset AS oi
INNER JOIN dbo.olist_orders_dataset AS o
    ON oi.order_id = o.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY
    YEAR(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)),
    MONTH(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp))
ORDER BY
    Year,
    Month;
GO

-- =============================================
-- Q3: Top 10 Product Categories by Revenue
-- =============================================

SELECT TOP 10
    COALESCE(t.product_category_name_english,
             p.product_category_name,
             'Unknown') AS ProductCategory,
    SUM(oi.price) AS Revenue
FROM dbo.olist_order_items_dataset AS oi
INNER JOIN dbo.olist_products_dataset AS p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(t.product_category_name_english,
             p.product_category_name,
             'Unknown')
ORDER BY
    Revenue DESC;
GO

-- =============================================
-- Q4: Top 10 Sellers by Revenue
-- =============================================

SELECT TOP 10
    s.seller_id,
    s.seller_city,
    s.seller_state,
    SUM(oi.price) AS Revenue
FROM dbo.olist_sellers_dataset AS s

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON s.seller_id = oi.seller_id

GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY
    Revenue DESC;
GO

-- =============================================
-- Q5: Average Order Value
-- =============================================

WITH OrderRevenue AS
(
    SELECT
        order_id,
        SUM(price) AS OrderRevenue
    FROM dbo.olist_order_items_dataset
    GROUP BY order_id
)

SELECT
    COUNT(*) AS TotalOrders,
    SUM(OrderRevenue) AS TotalRevenue,
    AVG(OrderRevenue) AS AverageOrderValue
FROM OrderRevenue;
GO

-- =============================================
-- Q6: Monthly Revenue vs Order Volume
-- =============================================

SELECT
    YEAR(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)) AS Year,
    MONTH(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)) AS Month,

    COUNT(DISTINCT o.order_id) AS TotalOrders,

    SUM(oi.price) AS TotalRevenue

FROM dbo.olist_orders_dataset AS o

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

GROUP BY
    YEAR(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)),
    MONTH(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp))

ORDER BY
    Year,
    Month;
GO

-- =============================================
-- Q7: Top 10 Product Categories by Order Count
-- =============================================

SELECT TOP 10
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS ProductCategory,

    COUNT(DISTINCT oi.order_id) AS TotalOrders

FROM dbo.olist_order_items_dataset AS oi

INNER JOIN dbo.olist_products_dataset AS p
    ON oi.product_id = p.product_id

LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name

GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

ORDER BY
    TotalOrders DESC;
GO

-- =============================================
-- Q8: Top 10 Product Categories by Revenue per Order
-- =============================================
SELECT TOP 10
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS ProductCategory,

    SUM(oi.price) AS TotalRevenue,

    COUNT(DISTINCT oi.order_id) AS TotalOrders,

    CAST(
        SUM(oi.price) / NULLIF(COUNT(DISTINCT oi.order_id), 0)
        AS DECIMAL(12,2)
    ) AS RevenuePerOrder

FROM dbo.olist_order_items_dataset AS oi

INNER JOIN dbo.olist_products_dataset AS p
    ON oi.product_id = p.product_id

LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name

GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

ORDER BY
    RevenuePerOrder DESC;
GO

-- ====================================================
-- Q9: Top 10 Customers by Lifetime Revenue
-- ===================================================

SELECT TOP 10
    c.customer_id AS CustomerID,

    COUNT(DISTINCT o.order_id) AS TotalOrders,

    SUM(oi.price) AS TotalRevenue,

    CAST(
        SUM(oi.price)
        / NULLIF(COUNT(DISTINCT o.order_id), 0)
        AS DECIMAL(12,2)
    ) AS AverageOrderValue

FROM dbo.olist_customers_dataset AS c

INNER JOIN dbo.olist_orders_dataset AS o
    ON c.customer_id = o.customer_id

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_id

ORDER BY
    TotalRevenue DESC;
GO

-- =========================================================
-- Q10: Repeat Customer Analysis
-- =========================================================

WITH CustomerOrders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS OrderCount

    FROM dbo.olist_customers_dataset AS c

    INNER JOIN dbo.olist_orders_dataset AS o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_unique_id
)

SELECT
    COUNT(*) AS TotalCustomers,

    SUM(
        CASE
            WHEN OrderCount > 1 THEN 1
            ELSE 0
        END
    ) AS RepeatCustomers,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN OrderCount > 1 THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS RepeatCustomerPercentage

FROM CustomerOrders;
GO

-- =========================================================
-- Q11: Customer Revenue Segmentation
-- =========================================================

WITH CustomerRevenue AS
(
    SELECT
        c.customer_unique_id AS CustomerUniqueID,
        COUNT(DISTINCT o.order_id) AS TotalOrders,
        SUM(oi.price) AS TotalRevenue
    FROM dbo.olist_customers_dataset AS c
    INNER JOIN dbo.olist_orders_dataset AS o
        ON c.customer_id = o.customer_id
    INNER JOIN dbo.olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_unique_id
)

SELECT
    CustomerUniqueID,
    TotalOrders,
    TotalRevenue,
    CASE
        WHEN TotalRevenue >= 500 THEN 'High Value'
        WHEN TotalRevenue >= 100 AND TotalRevenue < 500 THEN 'Medium Value'
        WHEN TotalRevenue < 100 THEN 'Low Value'
        ELSE 'Unknown'
    END AS CustomerSegment
FROM CustomerRevenue
ORDER BY TotalRevenue DESC;
GO

-- =========================================================
-- Q12: Top 10 Customers by Order Frequency
-- =========================================================

SELECT TOP 10
    c.customer_unique_id AS CustomerUniqueID,
    COUNT(DISTINCT o.order_id) AS TotalOrders

FROM dbo.olist_customers_dataset AS c

INNER JOIN dbo.olist_orders_dataset AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_unique_id

HAVING COUNT(DISTINCT o.order_id) >= 2

ORDER BY
    TotalOrders DESC;
GO

-- =========================================================
-- Q13: Monthly Average Order Value
-- =========================================================

WITH MonthlySales AS
(
    SELECT
        YEAR(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)) AS Year,
        MONTH(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)) AS Month,

        COUNT(DISTINCT o.order_id) AS TotalOrders,

        SUM(oi.price) AS TotalRevenue

    FROM dbo.olist_orders_dataset AS o

    INNER JOIN dbo.olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_purchase_timestamp IS NOT NULL

    GROUP BY
        YEAR(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)),
        MONTH(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp))
)

SELECT
    Year,
    Month,
    TotalOrders,
    TotalRevenue,

    CAST(
        TotalRevenue / NULLIF(TotalOrders, 0)
        AS DECIMAL(10,2)
    ) AS AverageOrderValue

FROM MonthlySales

ORDER BY
    Year,
    Month;
GO


-- =========================================================
-- Q14: Average Basket Size by Month
-- =========================================================

WITH MonthlySales AS
(
    SELECT
        YEAR(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)) AS Year,
        MONTH(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)) AS Month,

        -- Number of unique orders
        COUNT(DISTINCT o.order_id) AS TotalOrders,

        -- Number of product items sold
        COUNT(*) AS TotalItems

    FROM dbo.olist_orders_dataset AS o

    INNER JOIN dbo.olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_purchase_timestamp IS NOT NULL

    GROUP BY
        YEAR(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp)),
        MONTH(TRY_CONVERT(DATETIME2, o.order_purchase_timestamp))
)

SELECT
    Year,
    Month,
    TotalOrders,
    TotalItems,

    -- Average number of items in one order
    CAST(
        TotalItems * 1.0
        / NULLIF(TotalOrders, 0)
        AS DECIMAL(10,2)
    ) AS AverageItemsPerOrder

FROM MonthlySales

ORDER BY
    Year,
    Month;
GO

-- =========================================================
-- Q15: Revenue by Payment Type
-- =========================================================

SELECT
    payment_type AS PaymentType,

    COUNT(DISTINCT order_id) AS TotalOrders,

    SUM(payment_value) AS TotalPaymentValue,

    AVG(payment_value) AS AveragePaymentValue

FROM dbo.olist_order_payments_dataset

GROUP BY
    payment_type

ORDER BY
    TotalPaymentValue DESC;
GO

-- =========================================================
-- Q16: Payment Type Share of Revenue
-- =========================================================

WITH PaymentTypeRevenue AS
(
    SELECT
        payment_type,
        SUM(payment_value) AS TotalPaymentValue

    FROM dbo.olist_order_payments_dataset

    GROUP BY
        payment_type
)

SELECT
    payment_type AS PaymentType,

    TotalPaymentValue,

    CAST(
        TotalPaymentValue * 100.0
        / NULLIF(
            SUM(TotalPaymentValue) OVER (),
            0
        )
        AS DECIMAL(10,2)
    ) AS RevenueSharePercent

FROM PaymentTypeRevenue

ORDER BY
    RevenueSharePercent DESC;
GO

-- =========================================================
-- Q17: Late Delivery Rate by Order Status
-- =========================================================

WITH DeliveryStatus AS
(
    SELECT
        order_status,

        -- Count orders that were actually delivered
        COUNT(*) AS TotalDeliveredOrders,

        -- Count delivered orders that arrived late
        SUM(
            CASE
                WHEN TRY_CONVERT(DATETIME2, order_delivered_customer_date)
                     >
                     TRY_CONVERT(DATETIME2, order_estimated_delivery_date)
                THEN 1
                ELSE 0
            END
        ) AS LateOrders

    FROM dbo.olist_orders_dataset

    WHERE order_delivered_customer_date IS NOT NULL

    GROUP BY
        order_status
)

SELECT
    order_status AS OrderStatus,
    TotalDeliveredOrders,
    LateOrders,

    CAST(
        LateOrders * 100.0
        / NULLIF(TotalDeliveredOrders, 0)
        AS DECIMAL(10,2)
    ) AS LateDeliveryRatePercent

FROM DeliveryStatus

ORDER BY
    LateDeliveryRatePercent DESC;
GO

-- =========================================================
-- Q18: Delivery Performance by Month
-- =========================================================

WITH DeliveryPerformance AS
(
    SELECT
        YEAR(TRY_CONVERT(DATETIME2, order_delivered_customer_date)) AS Year,
        MONTH(TRY_CONVERT(DATETIME2, order_delivered_customer_date)) AS Month,

        COUNT(*) AS TotalDeliveredOrders,

        SUM(
            CASE
                WHEN TRY_CONVERT(DATETIME2, order_delivered_customer_date)
                     >
                     TRY_CONVERT(DATETIME2, order_estimated_delivery_date)
                THEN 1
                ELSE 0
            END
        ) AS LateOrders

    FROM dbo.olist_orders_dataset

    WHERE order_delivered_customer_date IS NOT NULL

    GROUP BY
        YEAR(TRY_CONVERT(DATETIME2, order_delivered_customer_date)),
        MONTH(TRY_CONVERT(DATETIME2, order_delivered_customer_date))
)

SELECT
    Year,
    Month,
    TotalDeliveredOrders,
    LateOrders,

    CAST(
        LateOrders * 100.0
        / NULLIF(TotalDeliveredOrders, 0)
        AS DECIMAL(10,2)
    ) AS LateDeliveryRatePercent

FROM DeliveryPerformance

ORDER BY
    Year,
    Month;
GO

-- =========================================================
-- Q19: Top 10 Customer Cities by Revenue
-- =========================================================

SELECT TOP 10
    c.customer_city AS CustomerCity,
    c.customer_state AS CustomerState,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.price) AS TotalRevenue

FROM dbo.olist_customers_dataset AS c

INNER JOIN dbo.olist_orders_dataset AS o
    ON c.customer_id = o.customer_id

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_city,
    c.customer_state

ORDER BY
    TotalRevenue DESC;
GO

-- =========================================================
-- Q20: Revenue by Customer State
-- =========================================================

SELECT
    c.customer_state AS CustomerState,

    COUNT(DISTINCT o.order_id) AS TotalOrders,

    SUM(oi.price) AS TotalRevenue,

    CAST(
        SUM(oi.price) * 1.0
        / NULLIF(COUNT(DISTINCT o.order_id), 0)
        AS DECIMAL(12,2)
    ) AS AverageOrderValue

FROM dbo.olist_customers_dataset AS c

INNER JOIN dbo.olist_orders_dataset AS o
    ON c.customer_id = o.customer_id

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_state

ORDER BY
    TotalRevenue DESC;
GO

-- =========================================================
-- Q21: Order Status Distribution
-- =========================================================

SELECT
    order_status AS OrderStatus,

    COUNT(*) AS TotalOrders,

    CAST(
        COUNT(*) * 100.0
        / NULLIF(SUM(COUNT(*)) OVER (), 0)
        AS DECIMAL(10,2)
    ) AS OrderStatusPercentage

FROM dbo.olist_orders_dataset

GROUP BY
    order_status

ORDER BY
    TotalOrders DESC;
GO

-- =========================================================
-- Q22: Average Review Score by Product Category
-- =========================================================

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS ProductCategory,

    COUNT(DISTINCT r.review_id) AS TotalReviews,

    CAST(
        AVG(CAST(r.review_score AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageReviewScore

FROM dbo.olist_products_dataset AS p

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON p.product_id = oi.product_id

INNER JOIN dbo.olist_order_reviews_dataset AS r
    ON oi.order_id = r.order_id

LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name

GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

HAVING
    COUNT(DISTINCT r.review_id) >= 20

ORDER BY
    AverageReviewScore DESC;
GO

 =========================================================
-- Q23: Customer Satisfaction by Review Category
-- =========================================================

SELECT
    CASE
        WHEN review_score IN (4, 5) THEN 'Positive'
        WHEN review_score = 3 THEN 'Neutral'
        WHEN review_score IN (1, 2) THEN 'Negative'
        ELSE 'Unknown'
    END AS ReviewCategory,

    COUNT(*) AS TotalReviews,

    CAST(
        COUNT(*) * 100.0
        / NULLIF(SUM(COUNT(*)) OVER (), 0)
        AS DECIMAL(10,2)
    ) AS ReviewPercentage

FROM dbo.olist_order_reviews_dataset

GROUP BY
    CASE
        WHEN review_score IN (4, 5) THEN 'Positive'
        WHEN review_score = 3 THEN 'Neutral'
        WHEN review_score IN (1, 2) THEN 'Negative'
        ELSE 'Unknown'
    END

ORDER BY
    ReviewPercentage DESC;
GO

-- =========================================================
-- Q24: Top 10 Product Categories by Average Review Score
-- =========================================================

SELECT TOP 10

    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS ProductCategory,

    COUNT(DISTINCT r.review_id) AS TotalReviews,

    CAST(
        AVG(CAST(r.review_score AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageReviewScore

FROM dbo.olist_products_dataset AS p

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON p.product_id = oi.product_id

INNER JOIN dbo.olist_order_reviews_dataset AS r
    ON oi.order_id = r.order_id

LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name

GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

HAVING
    COUNT(DISTINCT r.review_id) >= 100

ORDER BY
    AverageReviewScore DESC;

GO

-- =========================================================
-- Q25: Monthly Order Growth Rate
-- =========================================================

WITH MonthlyOrders AS
(
    SELECT
        YEAR(TRY_CONVERT(DATETIME2, order_purchase_timestamp)) AS Year,
        MONTH(TRY_CONVERT(DATETIME2, order_purchase_timestamp)) AS Month,

        COUNT(DISTINCT order_id) AS TotalOrders

    FROM dbo.olist_orders_dataset

    WHERE order_purchase_timestamp IS NOT NULL

    GROUP BY
        YEAR(TRY_CONVERT(DATETIME2, order_purchase_timestamp)),
        MONTH(TRY_CONVERT(DATETIME2, order_purchase_timestamp))
),

OrdersWithPreviousMonth AS
(
    SELECT
        Year,
        Month,
        TotalOrders,

        LAG(TotalOrders) OVER (
            ORDER BY Year, Month
        ) AS PreviousMonthOrders

    FROM MonthlyOrders
)

SELECT
    Year,
    Month,
    TotalOrders,
    PreviousMonthOrders,

    CAST(
        (TotalOrders - PreviousMonthOrders) * 100.0
        / NULLIF(PreviousMonthOrders, 0)
        AS DECIMAL(10,2)
    ) AS MonthlyGrowthPercent

FROM OrdersWithPreviousMonth

ORDER BY
    Year,
    Month;
GO

-- =========================================================
-- Q26: Top 10 Products by Revenue
-- =========================================================

SELECT TOP 10
    p.product_id AS ProductID,
    p.product_category_name AS ProductCategory,

    COUNT(*) AS TotalItemsSold,

    SUM(oi.price) AS TotalRevenue,

    AVG(oi.price) AS AverageSellingPrice

FROM dbo.olist_products_dataset AS p

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON oi.product_id = p.product_id

GROUP BY
    p.product_id,
    p.product_category_name

ORDER BY
    TotalRevenue DESC;
GO

-- =========================================================
-- Q27: Top 10 Product Categories by Freight-to-Revenue Ratio
-- =========================================================

SELECT TOP 10

    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS ProductCategory,

    -- Total revenue generated by the category
    SUM(oi.price) AS TotalRevenue,

    -- Total freight cost for the category
    SUM(oi.freight_value) AS TotalFreight,

    -- Average selling price per item
    CAST(
        AVG(oi.price)
        AS DECIMAL(10,2)
    ) AS AverageProductPrice,

    -- Average freight value per item
    CAST(
        AVG(oi.freight_value)
        AS DECIMAL(10,2)
    ) AS AverageFreightValue,

    -- Freight as a percentage of revenue
    CAST(
        SUM(oi.freight_value) * 100.0
        / NULLIF(SUM(oi.price), 0)
        AS DECIMAL(10,2)
    ) AS FreightToRevenuePercent

FROM dbo.olist_order_items_dataset AS oi

INNER JOIN dbo.olist_products_dataset AS p
    ON oi.product_id = p.product_id

LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name

GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

ORDER BY
    FreightToRevenuePercent DESC;

GO

-- =========================================================
-- Q28: Seller Performance Analysis
-- =========================================================

SELECT TOP 10

    s.seller_id AS SellerID,

    s.seller_city AS SellerCity,

    s.seller_state AS SellerState,

    -- Number of unique orders handled by the seller
    COUNT(DISTINCT oi.order_id) AS TotalOrders,

    -- Number of items sold by the seller
    COUNT(*) AS TotalItemsSold,

    -- Total revenue generated by the seller
    SUM(oi.price) AS TotalRevenue,

    -- Average selling price per item
    CAST(
        AVG(oi.price)
        AS DECIMAL(10,2)
    ) AS AverageItemPrice

FROM dbo.olist_sellers_dataset AS s

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON s.seller_id = oi.seller_id

GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY
    TotalRevenue DESC;

GO

-- =========================================================
-- Q29: Seller Delivery Performance
-- =========================================================

SELECT TOP 10

    s.seller_id AS SellerID,

    s.seller_city AS SellerCity,

    s.seller_state AS SellerState,

    -- Total unique orders handled by the seller
    COUNT(DISTINCT oi.order_id) AS TotalOrders,

    -- Orders that were actually delivered
    COUNT(
        DISTINCT CASE
            WHEN o.order_delivered_customer_date IS NOT NULL
            THEN oi.order_id
        END
    ) AS DeliveredOrders,

    -- Delivered orders that arrived after the estimated date
    COUNT(
        DISTINCT CASE
            WHEN o.order_delivered_customer_date IS NOT NULL
             AND TRY_CONVERT(
                    DATETIME2,
                    o.order_delivered_customer_date
                 )
                 >
                 TRY_CONVERT(
                    DATETIME2,
                    o.order_estimated_delivery_date
                 )
            THEN oi.order_id
        END
    ) AS LateOrders,

    -- Late delivered orders as a percentage of delivered orders
    CAST(
        COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date IS NOT NULL
                 AND TRY_CONVERT(
                        DATETIME2,
                        o.order_delivered_customer_date
                     )
                     >
                     TRY_CONVERT(
                        DATETIME2,
                        o.order_estimated_delivery_date
                     )
                THEN oi.order_id
            END
        ) * 100.0
        /
        NULLIF(
            COUNT(
                DISTINCT CASE
                    WHEN o.order_delivered_customer_date IS NOT NULL
                    THEN oi.order_id
                END
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS LateDeliveryRatePercent

FROM dbo.olist_sellers_dataset AS s

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON s.seller_id = oi.seller_id

INNER JOIN dbo.olist_orders_dataset AS o
    ON oi.order_id = o.order_id

GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state

-- Keep sellers with at least 20 delivered orders
HAVING
    COUNT(
        DISTINCT CASE
            WHEN o.order_delivered_customer_date IS NOT NULL
            THEN oi.order_id
        END
    ) >= 20

ORDER BY
    LateDeliveryRatePercent DESC;

GO

-- =========================================================
-- Q30: Customer Revenue by State
-- =========================================================

SELECT
    c.customer_state AS CustomerState,

    -- Number of unique customers in the state
    COUNT(DISTINCT c.customer_unique_id) AS TotalCustomers,

    -- Number of unique orders from the state
    COUNT(DISTINCT o.order_id) AS TotalOrders,

    -- Total revenue generated by the state
    SUM(oi.price) AS TotalRevenue,

    -- Revenue generated per customer
    CAST(
        SUM(oi.price) * 1.0
        / NULLIF(COUNT(DISTINCT c.customer_unique_id), 0)
        AS DECIMAL(12,2)
    ) AS RevenuePerCustomer

FROM dbo.olist_customers_dataset AS c

INNER JOIN dbo.olist_orders_dataset AS o
    ON c.customer_id = o.customer_id

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_state

ORDER BY
    TotalRevenue DESC;

GO

-- =========================================================
-- Q31: Top 10 Customers by Total Spending
-- =========================================================

SELECT TOP 10

    c.customer_unique_id AS CustomerUniqueID,

    -- Number of unique orders placed by the customer
    COUNT(DISTINCT o.order_id) AS TotalOrders,

    -- Total amount spent by the customer
    SUM(oi.price) AS TotalRevenue,

    -- Average value of each order
    CAST(
        SUM(oi.price) * 1.0
        / NULLIF(COUNT(DISTINCT o.order_id), 0)
        AS DECIMAL(12,2)
    ) AS AverageOrderValue

FROM dbo.olist_customers_dataset AS c

INNER JOIN dbo.olist_orders_dataset AS o
    ON c.customer_id = o.customer_id

INNER JOIN dbo.olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_unique_id

ORDER BY
    TotalRevenue DESC;

GO

-- =========================================================
-- Q32: Overall Business KPI Summary
-- =========================================================

SELECT

    -- Total number of unique customers
    (
        SELECT COUNT(DISTINCT customer_unique_id)
        FROM dbo.olist_customers_dataset
    ) AS TotalCustomers,

    -- Total number of orders
    (
        SELECT COUNT(DISTINCT order_id)
        FROM dbo.olist_orders_dataset
    ) AS TotalOrders,

    -- Total number of products
    (
        SELECT COUNT(DISTINCT product_id)
        FROM dbo.olist_products_dataset
    ) AS TotalProducts,

    -- Total number of sellers
    (
        SELECT COUNT(DISTINCT seller_id)
        FROM dbo.olist_sellers_dataset
    ) AS TotalSellers,

    -- Total revenue from product prices
    (
        SELECT SUM(price)
        FROM dbo.olist_order_items_dataset
    ) AS TotalRevenue,

    -- Average order value
    (
        SELECT
            SUM(price) * 1.0
            / NULLIF(COUNT(DISTINCT order_id), 0)
        FROM dbo.olist_order_items_dataset
    ) AS AverageOrderValue,

    -- Average customer review score
    (
        SELECT AVG(CAST(review_score AS DECIMAL(10,2)))
        FROM dbo.olist_order_reviews_dataset
    ) AS AverageReviewScore,

    -- Total freight cost
    (
        SELECT SUM(freight_value)
        FROM dbo.olist_order_items_dataset
    ) AS TotalFreight,

    -- Orders delivered late
    (
        SELECT COUNT(*)
        FROM dbo.olist_orders_dataset
        WHERE order_delivered_customer_date IS NOT NULL
          AND TRY_CONVERT(
                DATETIME2,
                order_delivered_customer_date
              )
              >
              TRY_CONVERT(
                DATETIME2,
                order_estimated_delivery_date
              )
    ) AS LateOrders;

GO