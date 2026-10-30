-- 1. Create DataBase
CREATE DATABASE Logistics;
GO
USE Logistics;
GO

-- 2. Create Tables
CREATE TABLE Branches (
    Branch_ID INT PRIMARY KEY,
    Branch_Name VARCHAR(100),
    City VARCHAR(100)
);

CREATE TABLE Drivers (
    Driver_ID INT IDENTITY(1,1) PRIMARY KEY,
    Driver_Name VARCHAR(100),
    Branch_ID INT,
    Phone_Number VARCHAR(20)
);

CREATE TABLE Customers (
    Customer_ID INT IDENTITY(1000,1) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Phone_Number VARCHAR(50),
    Customer_Segment VARCHAR(50), -- هنسيبه فاضي عشان تعمله Update بالتحليل
    Join_Date DATE
);

CREATE TABLE Shipments (
    Shipment_ID VARCHAR(20),
    Customer_ID INT,
    Driver_ID INT,
    Branch_ID INT,
    Order_Date DATE,
    Expected_Delivery_Date DATE,
    Actual_Delivery_Date VARCHAR(50), -- مقصود يكون نص عشان التواريخ البايظة
    Shipment_Status VARCHAR(50),
    Shipping_Cost VARCHAR(50) -- مقصود يكون نص عشان علامات العملة
);
GO

