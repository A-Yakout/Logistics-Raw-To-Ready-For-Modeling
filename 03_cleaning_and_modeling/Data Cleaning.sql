/*
===================================
Creating fact table as View
===================================
*/

CREATE VIEW fact_shipments AS
-- Deduplication
WITH cleaned_shipments AS (
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY shipment_id ORDER BY order_date) as rnk
FROM Shipments
) 
SELECT
	TRIM(Shipment_ID) AS shipment_id,
	Customer_ID AS customer_id,
	Driver_ID as driver_id,
	Branch_ID as branch_id,
	CAST(Order_Date AS DATE) as order_date,
	CAST(Expected_Delivery_Date AS DATE) as expected_delivery_date,
	TRY_CAST(TRIM(Actual_Delivery_Date) AS DATE) AS actual_delivery_date,
	UPPER(TRIM(Shipment_Status)) AS shipment_status,
	TRY_CAST(TRIM(REPLACE(REPLACE(UPPER(shipping_cost),'EGP',''),'$','')) AS DECIMAL(7,2)) AS shipping_cost
FROM cleaned_shipments
WHERE rnk = 1

SELECT
*
FROM fact_shipments

/*
===================================
Creating dim_customer table as View
===================================
*/


ALTER VIEW dim_customer AS
SELECT 
	Customer_ID AS customer_id,
	COALESCE(customer_name,'Customer_' + CAST(customer_id AS VARCHAR) ) AS customer_name,
	CASE 
		WHEN Phone_Number IS NULL THEN 'Invalid Number'
		WHEN LEN(REPLACE(TRIM(Phone_Number),'+2','')) < 11 THEN 'Invalid Number'
		ELSE REPLACE(TRIM(Phone_Number), '+2', '')
	END AS phone_number,
	Join_Date as join_date
FROM Customers

SELECT *
FROM dim_customer

/*
===================================
Creating dim_driver table as View
===================================
*/
CREATE VIEW dim_driver AS
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

SELECT *
FROM dim_driver

/*
===================================
Creating dim_branch table as View
===================================
*/
CREATE VIEW dim_branch AS
SELECT 
	Branch_ID,
	UPPER(LEFT(TRIM(Branch_name),1)) + LOWER(SUBSTRING(TRIM(Branch_Name),2,LEN(TRIM(Branch_Name)))) as branch_name,
	UPPER(LEFT(TRIM(City),1)) + LOWER(SUBSTRING(TRIM(City),2,LEN(TRIM(City)))) as city
FROM Branches


-- Solving the problem of some customers made the first order before joining
WITH FirstOrders AS (
    SELECT Customer_ID, MIN(Order_Date) AS First_Order_Date
    FROM Shipments
    GROUP BY Customer_ID
)
UPDATE c
SET c.Join_Date = f.First_Order_Date
FROM Customers c
JOIN FirstOrders f ON c.Customer_ID = f.Customer_ID
WHERE c.Join_Date > f.First_Order_Date;