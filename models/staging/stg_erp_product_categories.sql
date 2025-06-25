-- models/silver/stg_erp_product_categories.sql

SELECT
    id,
    cat,
    subcat,
    maintenance,
    ingestion_timestamp -- Keep this
FROM
    {{ source('erp_raw', 'erp_px_cat_g1v2') }} -- Reference your bronze source here