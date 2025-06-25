-- models/marts/dim_products.sql

SELECT
    row_number() OVER (ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key, -- Surrogate key
    cpi.prd_id AS product_id,
    cpi.prd_key AS product_number,
    cpi.prd_nm AS product_name,
    cpi.cat_id AS category_id,
    epcgv.cat AS category,
    epcgv.subcat AS subcategory,
    epcgv.maintenance AS maintenance,
    cpi.prd_cost AS product_cost,
    cpi.prd_line AS product_line,
    cpi.prd_start_dt AS start_date
FROM
    {{ ref('stg_crm_products') }} cpi  -- Reference the Silver layer CRM product model
LEFT JOIN
    {{ ref('stg_erp_product_categories') }} epcgv  -- Reference the Silver layer ERP product categories model
    ON cpi.cat_id = epcgv.id
WHERE prd_end_dt IS NULL -- Filter for active products