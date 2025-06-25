-- models/silver/stg_erp_locations.sql

SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States' -- <--- IMPORTANT: Changed 'US, USA' to separate values 'US', 'USA'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE cntry
    END AS cntry,
    ingestion_timestamp -- Keep this
FROM
    {{ source('erp_raw', 'erp_loc_a101') }} -- Reference your bronze source here