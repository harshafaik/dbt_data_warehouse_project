-- models/silver/stg_erp_customers.sql

SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > CURRENT_TIMESTAMP() THEN NULL -- Use CURRENT_TIMESTAMP() or NOW() in Spark SQL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        ELSE 'n/a'
    END AS gen,
    ingestion_timestamp -- Keep this
FROM
    {{ source('erp_raw', 'erp_cust_az12') }} -- Reference your bronze source here