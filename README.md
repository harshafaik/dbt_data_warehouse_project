SQL Data Warehouse Project: Databricks & dbt Migration
Overview

This project demonstrates the migration and implementation of a modern SQL data warehouse pipeline, transforming raw CRM and ERP operational data into structured, clean, and analytical-ready datasets. The pipeline is built using dbt (data build tool) for data transformations and deployed on Databricks leveraging Unity Catalog and Delta Lake.

The core objective was to migrate an existing data transformation logic (originally in PostgreSQL stored procedures) to a scalable, cloud-native, and version-controlled ELT (Extract, Load, Transform) framework.
Key Technologies

    dbt (data build tool): Orchestrates data transformations, manages dependencies, and automates data quality testing.

    Databricks: Cloud-based data platform for data engineering, machine learning, and data analytics.

        Unity Catalog: Centralized metadata management for data governance.

        Delta Lake: Open-source storage layer that brings ACID transactions, schema enforcement, and other data lakehouse capabilities to existing data lakes.

        Spark SQL / PySpark: Used for efficient data ingestion into the Bronze layer and for dbt model execution.

    Python: For PySpark data ingestion scripts and dbt CLI.

    Git & GitHub: For version control and collaborative development.

Architecture: The Medallion Lakehouse (Bronze, Silver, Gold)

This project follows the Medallion Architecture, a multi-hop approach for organizing data in a data lakehouse.

    Bronze Layer (Raw Data):

        Purpose: Ingests raw data directly from source systems (CRM and ERP) with minimal transformations.

        Storage: Data is loaded into Delta tables in the main.bronze schema within Databricks Unity Catalog.

        Ingestion: Utilizes PySpark notebooks to read raw files (CSV, JSON) from Unity Catalog Volumes and write them as Delta tables.

        Characteristics: Immutable, historical record of source data.

    Silver Layer (Cleaned & Conformed Data - Staging):

        Purpose: Cleans, filters, deduplicates, and standardizes data from the Bronze layer.

        Storage: Data is transformed and materialized into views (or tables) in the main.silver schema using dbt models.

        Transformations: Handles data type corrections, NULL value management, deduplication (e.g., using ROW_NUMBER()), and basic data quality rules.

        Characteristics: High quality, conformed data ready for broader use or further aggregation.

    Gold Layer (Curated & Business-Ready Data - Marts):

        Purpose: Creates highly aggregated and denormalized tables optimized for specific business use cases (e.g., reporting, analytics, BI dashboards).

        Storage: Data is transformed and materialized into views (or tables) in the main.gold (or main.marts) schema using dbt models.

        Models: Includes dimension tables (dim_customers, dim_products) and a fact table (fact_sales).

        Characteristics: Business-friendly, highly performant, and directly consumable by end-users or applications.

Project Structure

The dbt project adheres to best practices for organization:

dbt_data_warehouse_project/
├── models/
│   ├── marts/               # Gold Layer models (dimensions and facts)
│   │   ├── dim_customers.sql
│   │   ├── dim_products.sql
│   │   ├── fact_sales.sql
│   │   └── schema.yaml      # Schema definitions and tests for Gold models
│   ├── staging/             # Silver Layer models (stg_*)
│   │   ├── stg_crm_customers.sql
│   │   ├── stg_crm_products.sql
│   │   ├── stg_crm_sales_details.sql
│   │   ├── stg_erp_customers.sql
│   │   ├── stg_erp_locations.sql
│   │   ├── stg_erp_product_categories.sql
│   │   └── schema.yaml      # Schema definitions and tests for Silver models
│   └── sources/
│       └── bronze_sources.yaml # Defines raw data sources (Bronze layer)
├── dbt_project.yml          # dbt project configuration
├── profiles.yml             # (Symlink/copy) Database connection configuration
├── .gitignore               # Specifies files/directories to ignore in Git
└── README.md                # This file

Setup & Running the Project
Prerequisites

    Databricks Workspace: Access to a Databricks workspace (Community Edition is sufficient for this project).

        Ensure a Serverless SQL Warehouse is configured and running.

        A Unity Catalog is enabled in your workspace.

    dbt CLI: Install dbt-databricks adapter: pip install dbt-databricks

    Python Virtual Environment: Recommended for managing dependencies.

    Raw Data Files: The CRM and ERP raw data files (CSV, JSON) used in the Bronze layer ingestion.

1. Clone the Repository

First, clone this GitHub repository to your local machine:

git clone [https://github.com/YOUR_GITHUB_USERNAME/dbt_data_warehouse_project.git]
cd dbt_data_warehouse_project

(Remember to replace YOUR_GITHUB_USERNAME with your actual GitHub username.)
2. Configure dbt Profiles

Create or update your ~/.dbt/profiles.yml file to connect to your Databricks workspace.

# ~/.dbt/profiles.yml
dbt_data_warehouse_project: # This is the profile name
  target: dev
  outputs:
    dev:
      type: databricks
      host: <YOUR_DATABRICKS_WORKSPACE_URL> # e.g., dbc-xxxxxxxx-xxxx.cloud.databricks.com
      http_path: <YOUR_SQL_WAREHOUSE_HTTP_PATH> # Found in SQL Warehouse -> Connection Details
      token: <YOUR_DATABRICKS_PERSONAL_ACCESS_TOKEN> # Generate in User Settings -> Access Tokens
      catalog: main # Your Unity Catalog name
      schema: silver # Default schema for dbt models (can be overridden)

(Replace placeholders with your actual Databricks credentials.)
3. Initialize Unity Catalog

In your Databricks workspace (via a SQL Editor or Notebook), create the necessary schemas in Unity Catalog:

CREATE SCHEMA IF NOT EXISTS main.bronze;
CREATE SCHEMA IF NOT EXISTS main.silver;
CREATE SCHEMA IF NOT EXISTS main.marts; -- Or main.gold if you named it 'gold'

4. Ingest Raw Data to Bronze Layer

Upload your raw CRM and ERP data files into a Unity Catalog Volume. It's recommended to maintain the original folder structure (e.g., source_crm/ and source_erp/) within the volume.

Example Volume Path: /Volumes/main/bronze/raw_data_files/

Then, use a PySpark notebook in Databricks to read these files and create Delta tables in the main.bronze schema.
(Example PySpark code for ingestion is typically found in accompanying Databricks notebooks, not directly in the dbt project.)

Example for crm_cust_info.csv:

from pyspark.sql.functions import current_timestamp

raw_file_path = "dbfs:/Volumes/main/bronze/raw_data_files/source_crm/crm_cust_info.csv"
bronze_table_name = "main.bronze.crm_cust_info"

df_raw = (
    spark.read.format("csv")
    .option("header", "true")
    .option("inferSchema", "true")
    .load(raw_file_path)
)

df_bronze = df_raw.withColumn("ingestion_timestamp", current_timestamp())
df_bronze.write.format("delta").mode("overwrite").saveAsTable(bronze_table_name)

Repeat this for all raw files, adjusting format (csv/json) and options accordingly.
5. Run dbt Models

After setting up your profiles.yml and ingesting raw data, run your dbt models to build the Silver and Gold layers:

# Ensure your Python virtual environment (if used) is activated
dbt run

6. Run dbt Tests

Verify data quality and integrity across your layers:

dbt test

7. Generate Documentation

Explore your data lineage and definitions through auto-generated dbt documentation:

dbt docs generate
dbt docs serve
# This will provide a URL (usually http://localhost:8080) to view docs in your browser.

Data Models
Bronze Layer (Sources)

    crm_cust_info

    crm_prd_info

    crm_sales_details

    erp_cust_az12

    erp_loc_a101

    erp_px_cat_g1v2

Silver Layer (Staging)

    stg_crm_customers: Cleans and deduplicates CRM customer data.

    stg_crm_products: Cleans and standardizes CRM product data, handles effective dates.

    stg_crm_sales_details: Cleans and transforms CRM sales transaction data.

    stg_erp_customers: Cleans and transforms ERP customer demographic data.

    stg_erp_locations: Cleans and standardizes ERP location data.

    stg_erp_product_categories: Cleans ERP product category data.

Gold Layer (Marts)

    dim_customers: Conformed customer dimension combining CRM and ERP data. Includes a surrogate key (customer_key).

    dim_products: Conformed product dimension combining CRM and ERP data. Includes a surrogate key (product_key).

    fact_sales: Sales fact table linking stg_crm_sales_details to dim_customers and dim_products via surrogate keys.

Data Quality & Testing

dbt's built-in testing framework is used to ensure data quality:

    not_null tests: Applied to critical primary and foreign keys.

    unique tests: Ensures uniqueness for primary keys in dimension models.

    relationships tests: Verifies referential integrity between fact and dimension tables in the Gold layer.

Future Enhancements

    Implement incremental materializations for large tables in the Silver or Gold layer to optimize run times.

    Add more sophisticated custom dbt tests for specific business rules.

    Integrate data loading into Databricks using Databricks Workflows for scheduled runs.

    Connect BI tools (e.g., Power BI, Tableau, Looker) to the Gold layer for dashboarding.

    Explore audit columns (e.g., dbt_updated_at) for tracking freshness.

(Optional: Add your contact info here)
[Your Name/GitHub Profile Link]