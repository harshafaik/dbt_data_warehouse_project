-- models/silver/stg_crm_sales_details.sql

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    -- Change TEXT/VARCHAR to STRING for casting, and LENGTH works fine
    CASE
        WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS STRING)) != 8 THEN NULL
        ELSE TO_DATE(CAST(sls_order_dt AS STRING), 'yyyyMMdd') -- Use yyyyMMdd format for TO_DATE
    END AS sls_order_dt,
    CASE
        WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS STRING)) != 8 THEN NULL
        ELSE TO_DATE(CAST(sls_ship_dt AS STRING), 'yyyyMMdd')
    END AS sls_ship_dt,
    CASE
        WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS STRING)) != 8 THEN NULL
        ELSE TO_DATE(CAST(sls_due_dt AS STRING), 'yyyyMMdd')
    END AS sls_due_dt,
    CASE
        WHEN sls_sales != sls_quantity * ABS(sls_price) OR sls_sales IS NULL OR sls_sales <= 0
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN ABS(sls_sales) / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price,
    ingestion_timestamp -- Keep this
FROM
    {{ source('crm_raw', 'crm_sales_details') }} -- Reference your bronze source here