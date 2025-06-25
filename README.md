# SQL Data Warehouse Project: Databricks & dbt Migration

## Overview

This project demonstrates the migration and implementation of a modern SQL data warehouse pipeline, transforming raw CRM and ERP operational data into structured, clean, and analytical-ready datasets. The pipeline is built using **dbt (data build tool)** for data transformations and deployed on **Databricks** leveraging **Unity Catalog** and **Delta Lake**.

The core objective was to migrate an existing data transformation logic (originally in PostgreSQL stored procedures) to a scalable, cloud-native, and version-controlled ELT (Extract, Load, Transform) framework.

## Key Technologies

* **dbt (data build tool):** Orchestrates data transformations, manages dependencies, and automates data quality testing.
* **Databricks:** Cloud-based data platform for data engineering, machine learning, and data analytics.
    * **Unity Catalog:** Centralized metadata management for data governance.
    * **Delta Lake:** Open-source storage layer that brings ACID transactions, schema enforcement, and other data lakehouse capabilities to existing data lakes.
    * **Spark SQL / PySpark:** Used for efficient data ingestion into the Bronze layer and for dbt model execution.
* **Python:** For PySpark data ingestion scripts and dbt CLI.
* **Git & GitHub:** For version control and collaborative development.

## Architecture: The Medallion Lakehouse (Bronze, Silver, Gold)

This project follows the **Medallion Architecture**, a multi-hop approach for organizing data in a data lakehouse.

1.  **Bronze Layer (Raw Data):**
    * **Purpose:** Ingests raw data directly from source systems (CRM and ERP) with minimal transformations.
    * **Storage:** Data is loaded into Delta tables in the `main.bronze` schema within Databricks Unity Catalog.
    * **Ingestion:** Utilizes PySpark notebooks to read raw files (CSV, JSON) from Unity Catalog Volumes and write them as Delta tables.
    * **Characteristics:** Immutable, historical record of source data.

2.  **Silver Layer (Cleaned & Conformed Data - Staging):**
    * **Purpose:** Cleans, filters, deduplicates, and standardizes data from the Bronze layer.
    * **Storage:** Data is transformed and materialized into views (or tables) in the `main.silver` schema using dbt models.
    * **Transformations:** Handles data type corrections, `NULL` value management, deduplication (e.g., using `ROW_NUMBER()`), and basic data quality rules.
    * **Characteristics:** High quality, conformed data ready for broader use or further aggregation.

3.  **Gold Layer (Curated & Business-Ready Data - Marts):**
    * **Purpose:** Creates highly aggregated and denormalized tables optimized for specific business use cases (e.g., reporting, analytics, BI dashboards).
    * **Storage:** Data is transformed and materialized into views (or tables) in the `main.gold` (or `main.marts`) schema using dbt models.
    * **Models:** Includes dimension tables (`dim_customers`, `dim_products`) and a fact table (`fact_sales`).
    * **Characteristics:** Business-friendly, highly performant, and directly consumable by end-users or applications.

## Data Models

### Bronze Layer (Sources)

* `crm_cust_info`
* `crm_prd_info`
* `crm_sales_details`
* `erp_cust_az12`
* `erp_loc_a101`
* `erp_px_cat_g1v2`

### Silver Layer (Staging)

* `stg_crm_customers`: Cleans and deduplicates CRM customer data.
* `stg_crm_products`: Cleans and standardizes CRM product data, handles effective dates.
* `stg_crm_sales_details`: Cleans and transforms CRM sales transaction data.
* `stg_erp_customers`: Cleans and transforms ERP customer demographic data.
* `stg_erp_locations`: Cleans and standardizes ERP location data.
* `stg_erp_product_categories`: Cleans ERP product category data.

### Gold Layer (Marts)

* `dim_customers`: Conformed customer dimension combining CRM and ERP data. Includes a surrogate key (`customer_key`).
* `dim_products`: Conformed product dimension combining CRM and ERP data. Includes a surrogate key (`product_key`).
* `fact_sales`: Sales fact table linking `stg_crm_sales_details` to `dim_customers` and `dim_products` via surrogate keys.

## Data Quality & Testing

dbt's built-in testing framework is used to ensure data quality:

* **`not_null` tests:** Applied to critical primary and foreign keys.
* **`unique` tests:** Ensures uniqueness for primary keys in dimension models.
* **`relationships` tests:** Verifies referential integrity between fact and dimension tables in the Gold layer.

## Future Enhancements

* Implement `incremental` materializations for large tables in the Silver or Gold layer to optimize run times.
* Add more sophisticated custom dbt tests for specific business rules.
* Integrate data loading into Databricks using Databricks Workflows for scheduled runs.
* Connect BI tools (e.g., Power BI, Tableau, Looker) to the Gold layer for dashboarding.
* Explore audit columns (e.g., `dbt_updated_at`) for tracking freshness.