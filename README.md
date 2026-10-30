# 🚚 Logistics Data Engineering: Profiling, Cleaning, and Dimensional Modeling

This repository demonstrates a complete SQL-based data engineering workflow. It takes raw, messy logistics data and transforms it into a clean, analysis-ready Star Schema using a non-destructive approach. 

## 🛠️ Project Workflow

### 1. Schema Generation & Data Mocking
* Designed an operational database (OLTP) simulating a real-world freight and logistics system.
* Generated realistic datasets with intentional anomalies (nulls, duplicates, inconsistent formats) to reflect actual industry challenges.

### 2. Systematic Data Profiling
* Applied a structured, step-by-step SQL profiling methodology to assess data health.
* Identified missing values, logical errors, invalid date ranges, and referential integrity breaches across all tables.

### 3. Non-Destructive Cleaning & Dimensional Modeling
* **Zero-Touch Raw Data:** Kept the original source tables 100% intact to preserve data integrity and historical accuracy.
* **View-Based ETL:** Created clean Fact and Dimension tables (Star Schema) entirely through SQL `VIEW`s. 
* Handled transformations, deduplication, and standardization on the fly, creating an optimized layer directly consumable by BI tools.

## 📂 Repository Structure

* `01_schema_setup.sql`: DDL scripts for table creation and raw data insertion.
* `02_data_profiling.sql`: Standardized SQL queries for EDA and data quality assessment.
* `03_cleaning_and_modeling.sql`: The transformation layer containing the `VIEW` definitions for the Star Schema.

## 🚀 Tech Stack & Skills
* **Language:** Advanced SQL
* **Techniques:** Data Profiling, ETL/ELT Design, Dimensional Modeling (Star Schema), Non-destructive Transformations, SQL Views.
