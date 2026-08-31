USE EcommerceAnalytics;
GO

-- Create customer dimension
CREATE TABLE DimCustomer
(
    CustomerID VARCHAR(50) NOT NULL,
    CustomerUniqueID VARCHAR(50) NOT NULL,
    CustomerZipCodePrefix INT NULL,
    CustomerCity VARCHAR(100) NULL,
    CustomerState CHAR(2) NULL,

    CONSTRAINT PK_DimCustomer
        PRIMARY KEY (CustomerID)
);
GO
SELECT TOP 10 *
FROM dbo.DimCustomer;

-- Create Product dimension
CREATE TABLE DimProduct
(
    ProductID VARCHAR(50) NOT NULL,
    ProductCategoryName VARCHAR(100) NULL,
    ProductNameLength INT NULL,
    ProductDescriptionLength INT NULL,
    ProductPhotosQty INT NULL,
    ProductWeightG INT NULL,
    ProductLengthCM DECIMAL(10,2) NULL,
    ProductHeightCM DECIMAL(10,2) NULL,
    ProductWidthCM DECIMAL(10,2) NULL,

    CONSTRAINT PK_DimProduct
        PRIMARY KEY (ProductID)
);
GO

-- Create Seller dimension
CREATE TABLE DimSeller
(
    SellerID VARCHAR(50) NOT NULL,
    SellerZipCodePrefix INT NULL,
    SellerCity VARCHAR(100) NULL,
    SellerState CHAR(2) NULL,

    CONSTRAINT PK_DimSeller
        PRIMARY KEY (SellerID)
);
GO

-- Create Category dimension
CREATE TABLE DimCategory
(
    ProductCategoryName VARCHAR(100) NOT NULL,
    ProductCategoryNameEnglish VARCHAR(100) NULL,

    CONSTRAINT PK_DimCategory
        PRIMARY KEY (ProductCategoryName)
);
GO

-- Create Geography dimension 
CREATE TABLE DimGeography
(
    GeographyID INT IDENTITY(1,1) NOT NULL,
    ZipCodePrefix INT NOT NULL,
    Latitude DECIMAL(10,7) NULL,
    Longitude DECIMAL(10,7) NULL,
    City VARCHAR(100) NULL,
    State CHAR(2) NULL,

    CONSTRAINT PK_DimGeography
        PRIMARY KEY (GeographyID)
);
GO

-- Create Date dimension
CREATE TABLE DimDate
(
    DateKey INT NOT NULL,
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    QuarterNumber INT NOT NULL,
    QuarterName VARCHAR(10) NOT NULL,
    MonthNumber INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    WeekNumber INT NOT NULL,
    DayOfMonth INT NOT NULL,
    DayName VARCHAR(20) NOT NULL,

    CONSTRAINT PK_DimDate
        PRIMARY KEY (DateKey)
);
GO

-- Create Orders fact table
CREATE TABLE FactOrders
(
    OrderID VARCHAR(50) NOT NULL,
    CustomerID VARCHAR(50) NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,
    OrderPurchaseTimestamp DATETIME2 NULL,
    OrderApprovedAt DATETIME2 NULL,
    OrderDeliveredCarrierDate DATETIME2 NULL,
    OrderDeliveredCustomerDate DATETIME2 NULL,
    OrderEstimatedDeliveryDate DATETIME2 NULL,

    CONSTRAINT PK_FactOrders
        PRIMARY KEY (OrderID),

    CONSTRAINT FK_FactOrders_DimCustomer
        FOREIGN KEY (CustomerID)
        REFERENCES DimCustomer(CustomerID)
);
GO

-- Create Order Items fact table
CREATE TABLE FactOrderItems
(
    OrderID VARCHAR(50) NOT NULL,
    OrderItemID INT NOT NULL,
    ProductID VARCHAR(50) NOT NULL,
    SellerID VARCHAR(50) NOT NULL,
    ShippingLimitDate DATETIME2 NULL,
    Price DECIMAL(12,2) NOT NULL,
    FreightValue DECIMAL(12,2) NOT NULL,

    CONSTRAINT PK_FactOrderItems
        PRIMARY KEY (OrderID, OrderItemID),

    CONSTRAINT FK_FactOrderItems_FactOrders
        FOREIGN KEY (OrderID)
        REFERENCES FactOrders(OrderID),

    CONSTRAINT FK_FactOrderItems_DimProduct
        FOREIGN KEY (ProductID)
        REFERENCES DimProduct(ProductID),

    CONSTRAINT FK_FactOrderItems_DimSeller
        FOREIGN KEY (SellerID)
        REFERENCES DimSeller(SellerID)
);
GO

-- Create Payments fact table
CREATE TABLE FactPayments
(
    OrderID VARCHAR(50) NOT NULL,
    PaymentSequential INT NOT NULL,
    PaymentType VARCHAR(30) NOT NULL,
    PaymentInstallments INT NOT NULL,
    PaymentValue DECIMAL(12,2) NOT NULL,

    CONSTRAINT PK_FactPayments
        PRIMARY KEY (OrderID, PaymentSequential),

    CONSTRAINT FK_FactPayments_FactOrders
        FOREIGN KEY (OrderID)
        REFERENCES FactOrders(OrderID)
);
GO

-- Create Reviews fact table
CREATE TABLE FactReviews
(
    ReviewID VARCHAR(50) NOT NULL,
    OrderID VARCHAR(50) NOT NULL,
    ReviewScore INT NULL,
    ReviewCommentTitle VARCHAR(1000) NULL,
    ReviewCommentMessage VARCHAR(4000) NULL,
    ReviewCreationDate DATETIME2 NULL,
    ReviewAnswerTimestamp DATETIME2 NULL,

    CONSTRAINT PK_FactReviews
        PRIMARY KEY (ReviewID),

    CONSTRAINT FK_FactReviews_FactOrders
        FOREIGN KEY (OrderID)
        REFERENCES FactOrders(OrderID)
);
GO




USE master;
GO

ALTER DATABASE EcommerceAnalytics
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE EcommerceAnalytics;
GO

CREATE DATABASE EcommerceAnalytics;
GO