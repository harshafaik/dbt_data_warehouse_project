-- models/silver/stg_crm_customers.sql

SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status, -- Add AS for clarity in column alias
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr, -- Add AS for clarity in column alias
    cst_create_date,
    ingestion_timestamp -- Keep this from your bronze layer if you added it
FROM
    (SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM
        {{ source('crm_raw', 'crm_cust_info') }} -- Reference your bronze source here
    ) AS ranked_customers -- Add an alias for the subquery
WHERE
    flag_last = 1
      AND cst_id IS NOT NULL;