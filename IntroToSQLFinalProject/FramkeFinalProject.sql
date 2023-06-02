--Intro to SQL 156-109-21018-23
-- Final Project--
--Anthony Framke--

--1. Management would like to track additional information about a product category – the product line it belongs to.
    -- Add the product line information to the database and normalize the data as necessary. You may create as many additional tables as you deem necessary.

    --Creating table for our Product Lines
        --just wanted to see categories
            SELECT Category
            FROM Product

    CREATE TABLE ProductLine (
        ProductLineID INT IDENTITY(1000,8), -- wanted to do something different with the id
        ProductLineName VARCHAR(50) NOT NULL,
        ProductID INT,
            CONSTRAINT PK_ProductLine_ProductLineID PRIMARY KEY (ProductLineID),
            CONSTRAINT FK_ProductLine_ProductID FOREIGN KEY (ProductID) REFERENCES Product (ProductID)
    )
    
        -- Now adding FK ProductLineID to Product table
        ALTER TABLE Product
        ADD ProductLineID INT,
        CONSTRAINT FK_Product_ProductLineID FOREIGN KEY (ProductLineID) REFERENCES ProductLine (ProductLineID)

    -- Adding Product Line info to db w/ normalization

    --inserting ProductLineNname data  into ProductLine table 

    INSERT INTO ProductLine 
    (ProductLineName)
    VALUES ('Accessories'), ('Components'), ('Bikes'), ('Clothing')
    
    --updating Product table with ProductLine data
    SELECT *
    FROM ProductLine


    UPDATE Product
    SET ProductLineID = (SELECT TOP 1 ProductLineID FROM ProductLine WHERE ProductLineName = 'Accessories')
    WHERE Category IN 
    ('Locks', 
    'Cleaners', 
    'Helmets', 
    'Bottles and Cages', 
    'Hydration Packs', 
    'Fenders',
    'Pumps', 
    'Bike Stands', 
    'Lights', 
    'Panniers', 
    'Tires and Tubes')

    UPDATE Product
    SET ProductLineID = (SELECT TOP 1 ProductLineID FROM ProductLine WHERE ProductLineName = 'Components')
    WHERE Category IN
    ('Road Frames', 
    'Mountain Frames', 
    'Derailleurs', 
    'Brakes', 
    'Forks',
    'Touring Frames', 
    'Chains', 
    'Handlebars',
    'Wheels',
    'Saddles',
    'Pedals',
    'Headsets', 
    'Cranksets', 
    'Bottom Brackets')

    UPDATE Product
    SET ProductLineID = (SELECT TOP 1 ProductLineID FROM ProductLine WHERE ProductLineName = 'Bikes')
    WHERE Category IN
    ('Road Bikes', 'Mountain Bikes', 'Touring Bikes')

    UPDATE Product
    SET ProductLineID = (SELECT TOP 1 ProductLineID FROM ProductLine WHERE ProductLineName = 'Clothing')
    WHERE Category IN
    ('Bib-Shorts', 
    'Jerseys', 
    'Gloves', 
    'Socks', 
    'Caps', 
    'Shorts', 
    'Vests', 
    'Tights')

    SELECT * 
    FROM Product;

--2. Management would also like one table that stores address information, instead of having the customer’s home address in the Customer table, and their shipping address on the OrderHeader table. 
    --The table should hold a minimum of two rows per customer – one row for the home address, and one row for each unique shipping address. Populate the addresses into the new address table. 
    --When finished moving the data, remove the old address fields from Customer and OrderHeader. 
    --Make sure you have a way to link the home and shipping addresses back to the correct customers and orders before you remove the address columns!

    -- Address table
        --SELECT *
        --FROM Customer

    CREATE TABLE Address (
        AddressID INT IDENTITY(1, 1) PRIMARY KEY,
        CustomerID INT,
        OrderID INT,
        AddressType VARCHAR(20),
        Street VARCHAR(50),
        City VARCHAR(50),
        State VARCHAR(2),
        ZipCode VARCHAR(10)
    );

    SELECT *
    FROM Address
    --Insert Home Address
    INSERT INTO Address ( CustomerID, AddressType, Street, City, State, ZipCode)
    SELECT CustomerID, 'Home', Address, City, State, ZipCode
    FROM Customer c;

   --Insert shipping address
   
   INSERT INTO Address (CustomerID, OrderID, AddressType, Street, City, State, ZipCode)
   SELECT oh.CustomerID, oh.OrderID, 'Shipping', oh.ShipAddress, oh.ShipCity, oh.ShipState, oh.ShipZipCode
   FROM OrderHeader oh

    --need to create my FK for Address table
    ALTER TABLE Address
    ADD CONSTRAINT FK_Address_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID);

    ALTER TABLE Address
    ADD CONSTRAINT FK_Address_OrderID FOREIGN KEY (OrderID) REFERENCES OrderHeader (OrderID);
   
   --displays home/shipping address by customerID
    SELECT c.CustomerID, c.FirstName, c.LastName, a.AddressType, a.Street, a.City, a.State, a.ZipCode
    FROM Customer c
    JOIN Address a ON c.CustomerID = a.CustomerID
    ORDER BY c.CustomerID
   
   -- removing old address fields

    ALTER TABLE Customer
        DROP COLUMN Address
     ALTER TABLE Customer
        DROP COLUMN City
     ALTER TABLE Customer
        DROP COLUMN State
     ALTER TABLE Customer
        DROP COLUMN ZipCode;

    ALTER TABLE OrderHeader
        DROP COLUMN ShipAddress
    ALTER TABLE Customer
         DROP COLUMN ShipCity
    ALTER TABLE Customer    
        DROP COLUMN ShipState
    ALTER TABLE Customer
         DROP COLUMN ShipZipCode;

    --adding FK

    ALTER TABLE SalesTax
    ADD CONSTRAINT PK_SalesTax_SalesTaxID PRIMARY KEY (SalesTaxID);


    ALTER TABLE OrderHeader
    ADD SalesTaxID SMALLINT
    CONSTRAINT FK_OrderHeader_SalesTaxID FOREIGN KEY (SalesTaxID) REFERENCES SalesTax (SalesTaxID)

    ALTER TABLE OrderHeader
    ADD CONSTRAINT FK_OrderHeader_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)

    ALTER TABLE Address
    ADD SalesTaxID INT
    CONSTRAINT FK_Address_SalesTaxID FOREIGN KEY (SalesTaxID) REFERENCES SalesTax (SalesTaxID)

    ALTER TABLE Customer
    ADD AddressID INT
    CONSTRAINT FK_Customer_AddressID FOREIGN KEY (AddressID) REFERENCES Address (AddressID)

    ALTER TABLE OrderDetail
    ADD CONSTRAINT FK_OrderDetail_OrderID FOREIGN KEY (OrderID) REFERENCES OrderHeader (OrderID)

    ALTER TABLE OrderHeader
    ADD OrderDetailID INT
    CONSTRAINT FK_OrderHeader_OrderDetailD FOREIGN KEY (OrderDetailID) REFERENCES OrderDetail (OrderDetailID)

    ALTER TABLE OrderDetail
    ADD CONSTRAINT FK_OrderDetail_ProductID FOREIGN KEY (ProductID) REFERENCES Product (ProductID)

    ALTER TABLE OrderDetail
    ALTER COLUMN SalesPromotionID SMALLINT
    
    ALTER TABLE OrderDetail
    ADD CONSTRAINT FK_OrderDetail_SalesPromotionID FOREIGN KEY (SalesPromotionID) REFERENCES SalesPromotion (SalesPromotionID)

    ALTER TABLE Product
    ADD CONSTRAINT FK_Product_VendorID FOREIGN KEY (VendorID) REFERENCES Vendor (VendorID)

    --4. see ERD

    ---Database Objects

    --1. Create a stored procedure that takes an CustomerID and returns a result set with the customer's name and home address fields.

GO
    CREATE PROCEDURE spCustomerHomeAddress
    @CustomerID INT
    AS
    BEGIN
        SELECT c.FirstName, c.LastName, a.Street, a.City, a.State, a.ZipCode
        FROM Customer c
        JOIN Address a ON c.CustomerID = a.CustomerID
        WHERE c.CustomerID = @CustomerID
        AND a.AddressType = 'Home'
END

GO

EXECUTE spCustomerHomeAddress @CustomerID = 300

--2. Create a function that calculates sales tax given a state and an amount to be taxed. If the state does not exist in the SalesTax table, the function should return 0.

GO
    CREATE FUNCTION udf_CalcSalesTax
    (@State VARCHAR(2),
     @AmountTaxed DECIMAL(18, 2)
    )
    RETURNS DECIMAL(18, 2)
    AS
    BEGIN
      DECLARE @SalesTaxRate DECIMAL(18, 2)
    
        SELECT @SalesTaxRate = TaxRate
        FROM SalesTax
        WHERE State = @State
    
        IF @SalesTaxRate IS NULL
        RETURN 0
    
        RETURN @AmountTaxed * (@SalesTaxRate / 100.00)
END
GO

--DROP FUNCTION dbo.udf_CalcSalesTax
SELECT dbo.udf_CalcSalesTax('FL', 100.00) AS SalesTaxAmount

SELECT *
FROM SalesTax

--3. Create a view that displays the customer's name, OrderID, order subtotal, tax, freight, Order total (Subtotal + Tax + Freight), and shipping address fields.

GO
    /*CREATE VIEW CustomerOrder AS
        SELECT c.FirstName + ' ' + c.LastName As CustomerName, oh.OrderId, SUM(od.OrderQuantity * p.ListPrice) AS 'SubTotal',
    st.TaxRate AS 'TAX', oh.ShippingCost, (st.TaxRate * 100) + oh.ShippingCost + SUM(od.OrderQuantity * p.ListPrice) AS 'OrderTotal',
    a.AddressType,
    a.Street AS ShipStreet,
    a.City AS ShipCity,
    a.State AS ShipState,
    a.ZipCode AS ShipZipCode
    FROM OrderHeader oh
    JOIN Customer c ON oh.CustomerID = c.CustomerID
    JOIN Address a ON oh.CustomerID = a.CustomerID AND oh.OrderID = a.OrderID
    JOIN OrderDetail od ON oh.OrderID = od.OrderID
    JOIN Product p ON od.ProductID = p.ProductID
    JOIN SalesTax st ON oh.SalesTaxID = st.SalesTaxID
    WHERE a.AddressType = 'Shipping'
    GROUP BY
        c.FirstName,
        c.LastName,
        oh.OrderID,
        st.TaxRate,
        oh.ShippingCost,
        a.AddressType,
        a.Street,
        a.City,
        a.State,
        a.ZipCode; */

    CREATE VIEW CustomerOrder AS
    SELECT
        CONCAT(c.FirstName, ' ', c.LastName) AS 'CustomerName',
        oh.OrderId,
        SUM(od.OrderQuantity * p.ListPrice) AS SubTotal,
        st.TaxRate AS 'Tax',
        oh.ShippingCost,
        SUM(od.OrderQuantity * p.ListPrice) * (1 + st.TaxRate/100) + oh.ShippingCost AS OrderTotal,
        a.AddressType,
        a.Street AS 'ShipStreet',
        a.City AS 'ShipCity',
        a.State AS 'ShipState',
        a.ZipCode AS 'ShipZipCode'
    FROM OrderHeader oh
    JOIN Customer c ON oh.CustomerID = c.CustomerID
    JOIN Address a ON oh.CustomerID = a.CustomerID AND oh.OrderID = a.OrderID
    JOIN OrderDetail od ON oh.OrderID = od.OrderID
    JOIN Product p ON od.ProductID = p.ProductID
    JOIN SalesTax st ON oh.SalesTaxID = st.SalesTaxID
    WHERE a.AddressType = 'Shipping'
    GROUP BY
    c.FirstName,
    c.LastName,
    oh.OrderId,
    a.AddressType,
    a.Street,
    a.City,
    a.State,
    a.ZipCode,
    st.TaxRate,
    oh.ShippingCost;
GO

--DROP VIEW dbo.CustomerOrder
SELECT *
FROM CustomerOrder

/*UPDATE Address
SET SalesTaxID = st.SalesTaxID
FROM Address a
JOIN Customer c ON a.CustomerID = c.CustomerID
JOIN SalesTax st ON a.State = st.State

--SELECT *
--FROM CustomerOrder;

UPDATE ProductLine
SET ProductID = p.ProductID
FROM ProductLine pl
JOIN Product p ON pl.ProductID = p.ProductID 
WHERE pl.ProductID IS NULL *?

