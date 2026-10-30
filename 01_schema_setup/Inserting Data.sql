-- 3. Insert Data
INSERT INTO Branches VALUES 
(1, '  Alexandria Main ', ' Alexandria'),
(2, 'cairo_branch', 'Cairo '),
(3, 'Giza-Hub', 'giza'),
(4, '  Mansoura  ', 'Mansoura'),
(5, 'Suez port', ' Suez');

-- 4. توليد 50 مندوب وتوزيعهم على الـ 5 فروع (10 لكل فرع)
DECLARE @DriverCounter INT = 1;
WHILE @DriverCounter <= 50
BEGIN
    INSERT INTO Drivers (Driver_Name, Branch_ID, Phone_Number)
    VALUES (
        'Driver_' + CAST(@DriverCounter AS VARCHAR),
        ((@DriverCounter - 1) % 5) + 1, 
        '01' + CAST(CAST(RAND() * 1000000000 AS INT) AS VARCHAR)
    );
    SET @DriverCounter = @DriverCounter + 1;
END;

-- 5. توليد 150 عميل (مع تعمد أخطاء في أرقام التليفونات لبعضهم)
DECLARE @CustCounter INT = 1;
WHILE @CustCounter <= 150
BEGIN
    DECLARE @Phone VARCHAR(50) = '01' + CAST(CAST(RAND() * 1000000000 AS INT) AS VARCHAR);
    
    -- إتلاف بعض الأرقام عمداً للتنظيف
    IF @CustCounter % 10 = 0 SET @Phone = '+2' + @Phone;
    IF @CustCounter % 15 = 0 SET @Phone = @Phone + ' ';
    IF @CustCounter % 25 = 0 SET @Phone = NULL;

    INSERT INTO Customers (Customer_Name, Phone_Number, Join_Date)
    VALUES (
        'Customer_' + CAST(@CustCounter AS VARCHAR),
        @Phone,
        DATEADD(DAY, -CAST(RAND() * 1000 AS INT), GETDATE()) -- تواريخ انضمام عشوائية لمعرفة الولاء
    );
    SET @CustCounter = @CustCounter + 1;
END;

-- 6. توليد 120 شحنة عشوائية
DECLARE @OrderCounter INT = 1;
WHILE @OrderCounter <= 120
BEGIN
    DECLARE @Status VARCHAR(50);
    DECLARE @ActualDate VARCHAR(50);
    DECLARE @RandStatus INT = CAST(RAND() * 4 AS INT);
    DECLARE @OrderDate DATE = DATEADD(DAY, -CAST(RAND() * 100 AS INT), GETDATE());

    IF @RandStatus = 0 BEGIN SET @Status = 'Delivered'; SET @ActualDate = CAST(DATEADD(DAY, 2, @OrderDate) AS VARCHAR); END;
    IF @RandStatus = 1 BEGIN SET @Status = 'Out for Delivery'; SET @ActualDate = NULL; END;
    IF @RandStatus = 2 BEGIN SET @Status = 'At Branch'; SET @ActualDate = NULL; END;
    IF @RandStatus = 3 BEGIN SET @Status = 'Returned'; SET @ActualDate = CAST(DATEADD(DAY, 5, @OrderDate) AS VARCHAR); END;

    INSERT INTO Shipments (Shipment_ID, Customer_ID, Driver_ID, Branch_ID, Order_Date, Expected_Delivery_Date, Actual_Delivery_Date, Shipment_Status, Shipping_Cost)
    VALUES (
        'SHP-' + CAST(@OrderCounter + 10000 AS VARCHAR),
        (SELECT TOP 1 Customer_ID FROM Customers ORDER BY NEWID()), -- عميل عشوائي
        (SELECT TOP 1 Driver_ID FROM Drivers ORDER BY NEWID()), -- مندوب عشوائي
        ((@OrderCounter % 5) + 1), -- فرع
        @OrderDate,
        DATEADD(DAY, 3, @OrderDate),
        @ActualDate,
        @Status,
        CAST(CAST(RAND() * (200 - 50) + 50 AS DECIMAL(10,2)) AS VARCHAR)
    );
    
    SET @OrderCounter = @OrderCounter + 1;
END;

-- 7. حقن (إتلاف) متعمد في بيانات الشحنات لاختبار مهاراتك في التنظيف!
-- تكرار شحنات (Duplicates)
INSERT INTO Shipments (Shipment_ID, Customer_ID, Driver_ID, Branch_ID, Order_Date, Expected_Delivery_Date, Actual_Delivery_Date, Shipment_Status, Shipping_Cost)
SELECT TOP 5 Shipment_ID, Customer_ID, Driver_ID, Branch_ID, Order_Date, Expected_Delivery_Date, Actual_Delivery_Date, Shipment_Status, Shipping_Cost FROM Shipments ORDER BY NEWID();

-- أخطاء إملائية في الحالات ومسافات
UPDATE Shipments SET Shipment_Status = ' Delivred ' WHERE Shipment_ID = 'SHP-10010';
UPDATE Shipments SET Shipment_Status = 'returned' WHERE Shipment_ID = 'SHP-10020';
UPDATE Shipments SET Shipment_Status = 'Out_For_Delivery' WHERE Shipment_ID = 'SHP-10030';

-- أخطاء في تكلفة الشحن (عملات ونصوص)
UPDATE Shipments SET Shipping_Cost = '150 EGP' WHERE Shipment_ID = 'SHP-10015';
UPDATE Shipments SET Shipping_Cost = '$200' WHERE Shipment_ID = 'SHP-10025';
UPDATE Shipments SET Shipping_Cost = '  120.5 ' WHERE Shipment_ID = 'SHP-10035';

-- تواريخ غير صالحة (Invalid Dates)
UPDATE Shipments SET Actual_Delivery_Date = 'Pending' WHERE Shipment_ID = 'SHP-10040';
UPDATE Shipments SET Actual_Delivery_Date = '' WHERE Shipment_ID = 'SHP-10045';

-- مندوب مفقود (NULL)
UPDATE Shipments SET Driver_ID = NULL WHERE Shipment_Status = 'At Branch' AND Shipment_ID = 'SHP-10050';

WITH NameList AS (
    SELECT Driver_ID,
           CHOOSE(Driver_ID % 10 + 1, 'Ahmed','Shehab','Belal','Khaled', 'Mohamed', 'Mahmoud', 'Mostafa', 'Karim', 'Omar', 'Ali', 'Hussein', 'Ibrahim', 'Hassan') + ' ' +
           CHOOSE((Driver_ID / 10) % 5 + 1, 'Sayed','Samir','Zedan','Moamen','Atef','Amr','Omar', 'Abdelrhman', 'Yakout','Ismail','Maher', 'Tarek', 'Adel') AS Real_Name
    FROM Drivers
)
UPDATE d
SET Driver_Name = nl.Real_Name
FROM Drivers d
JOIN NameList nl ON d.Driver_ID = nl.Driver_ID;

WITH NameList AS (
    SELECT Customer_ID,
           CHOOSE(Customer_ID % 10 + 1, 'Mostafa', 'Karim', 'Omar', 'Ali', 'Hussein', 'Ibrahim', 'Hassan') + ' ' +
           CHOOSE((Customer_ID / 10) % 5 + 1, 'Samir','Zedan','Moamen','Atef','Amr','Omar','Ismail','Maher', 'Tarek', 'Adel') AS cust_Real_Name
    FROM Customers
)
UPDATE c
SET customer_name = nl.cust_Real_Name
FROM Customers c
JOIN NameList nl ON c.Customer_ID = nl.Customer_ID;
GO