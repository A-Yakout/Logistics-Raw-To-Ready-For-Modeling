-- Data Profiling (Exploring and assesing the data quality)


-- 1-Uniqueness & Grain
-- Finding out if there are any duplicates in the primary key
-- Primary Key Violation
SELECT
	COUNT(DISTINCT customer_id) as cnt_key,
	COUNT(*) AS cnt_all,
	COUNT(*) - COUNT(DISTINCT customer_id) as diff
FROM Customers


SELECT 
	COUNT(DISTINCT Driver_ID) as cnt_key,
	COUNT(*) AS cnt_all,
	COUNT(*) - COUNT(DISTINCT Driver_ID) as diff
FROM Drivers


SELECT 
	COUNT(DISTINCT Branch_ID) as cnt_key,
	COUNT(*) AS cnt_all,
	COUNT(*) - COUNT(Branch_ID) as diff
FROM Branches


-- HERE, There are 5 duplicates
SELECT
	COUNT(DISTINCT shipment_id) as cnt_key,
	COUNT(*) AS cnt_all,
	COUNT(*) - COUNT(DISTINCT shipment_id) as diff
FROM Shipments


-- If there are any duplicated keys , HOW TO FIND OUT THE ACTUAL DUPLICATES ?
SELECT
	Shipment_id,
	COUNT(*) AS cnt
FROM Shipments
GROUP BY Shipment_ID
HAVING COUNT(*) > 1



-- Exact Row Duplication
SELECT 
	COUNT(*) AS cnt_duplicates
FROM(
SELECT
	Shipment_ID,
	Customer_ID,
	Driver_ID,
	Branch_ID,
	Order_Date,
	Expected_Delivery_Date,
	Actual_Delivery_Date,
	Shipment_Status,
	Shipping_Cost,
	COUNT(*) AS records
FROM Shipments
GROUP BY 
	Shipment_ID,Customer_ID,Driver_ID,	Branch_ID,	Order_Date,	Expected_Delivery_Date,
	Actual_Delivery_Date,Shipment_Status,Shipping_Cost
) t 
WHERE records > 1



-- Exact Row Duplication
SELECT
	Shipment_ID,
	Customer_ID,
	Driver_ID,
	Branch_ID,
	Order_Date,
	Expected_Delivery_Date,
	Actual_Delivery_Date,
	Shipment_Status,
	Shipping_Cost,
	COUNT(*) AS records
FROM Shipments
GROUP BY 
	Shipment_ID,Customer_ID,Driver_ID,Branch_ID,Order_Date,Expected_Delivery_Date,
	Actual_Delivery_Date,Shipment_Status,Shipping_Cost
HAVING COUNT(*) > 1


-- Test profiling before CASTING the Actual delivery date INTO DATE
SELECT
    Shipment_ID,
    Actual_Delivery_Date
FROM Shipments
WHERE ISDATE(Actual_Delivery_Date) = 0
  AND Actual_Delivery_Date IS NOT NULL
  AND TRIM(Actual_Delivery_Date) <> '';


-- Test profiling for the shipment id column
SELECT
    Shipment_ID
FROM Shipments
WHERE TRY_CAST(Shipment_ID AS INT) IS NULL


-- Test profiling for shipping cost column to see if it is contain something not number
SELECT
Shipment_ID,
Shipping_Cost
FROM Shipments
WHERE Shipping_Cost LIKE '%[^0-9.]%' 
AND Shipping_Cost <> '';            


-- Test profiling for DATE column to see How many nulls it have
SELECT
	COUNT(ISDATE(Actual_Delivery_Date)) as cnt_null
FROM Shipments
WHERE ISDATE(Actual_Delivery_Date) = 0

SELECT
	*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers'

SELECT
	* 
FROM Customers
WHERE LEN(REPLACE(TRIM(Phone_Number),'+2','')) < 11


SELECT *
FROM Customers
WHERE 
Phone_Number LIKE '%[^0-9.]%'

-- Finding the problem of some customers made the first order before joining
SELECT
	customer_id,
	customer_name,
	DATEDIFF(MONTH,Join_Date, first_order) as timer_to_first_order 
FROM(
SELECT 
	MIN(order_date) AS first_order,
	c.customer_id,
	customer_name,
	c.Join_Date
FROM Shipments s 
LEFT JOIN Customers c 
ON c.Customer_ID = s.Customer_ID
GROUP BY 
	c.customer_id,
	customer_name,
	c.Join_Date
) t 

-- Data Profiling for Drivers Table
SELECT COUNT(*) AS CNT
FROM Drivers
WHERE Driver_ID is null 
OR
Driver_Name IS NULL
OR 
Phone_Number IS NULL

SELECT 
	Driver_ID AS driver_id,
	Driver_Name AS driver_name,
	Branch_ID AS branch_id,
	CASE
		WHEN Phone_Number IS NULL THEN 'Invalid Number'
		WHEN LEN(REPLACE(TRIM(Phone_Number),'+2','')) < 11 THEN 'Invalid Number'
		ELSE REPLACE(TRIM(Phone_Number), '+2', '')
	END AS phone_number
FROM Drivers 


SELECT 
	Branch_ID,
	UPPER(LEFT(TRIM(Branch_name),1)) + LOWER(SUBSTRING(TRIM(Branch_Name),2,LEN(TRIM(Branch_Name)))) as branch_name,
	UPPER(LEFT(TRIM(City),1)) + LOWER(SUBSTRING(TRIM(City),2,LEN(TRIM(City)))) as city
FROM Branches