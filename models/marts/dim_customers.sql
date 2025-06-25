-- models/marts/dim_customers.sql

SELECT
    row_number() OVER (ORDER BY crm_cust.cst_id) AS customer_key, -- Surrogate key
    crm_cust.cst_id AS customer_id,
    crm_cust.cst_key AS customer_number,
    crm_cust.cst_firstname AS first_name,
    crm_cust.cst_lastname AS last_name,
    erp_loc.cntry AS country,
    crm_cust.cst_marital_status AS marital_status,
    CASE
        WHEN crm_cust.cst_gndr != 'n/a' THEN crm_cust.cst_gndr
        ELSE coalesce(erp_cust.gen, 'n/a')
    END AS gender,
    erp_cust.bdate AS birthdate,
    crm_cust.cst_create_date AS create_date
FROM
    {{ ref('stg_crm_customers') }} AS crm_cust  -- Reference the Silver layer customer model
LEFT JOIN
    {{ ref('stg_erp_customers') }} AS erp_cust  -- Reference the Silver layer ERP customer model
    ON crm_cust.cst_key = erp_cust.cid
LEFT JOIN
    {{ ref('stg_erp_locations') }} AS erp_loc  -- Reference the Silver layer ERP location model
    ON crm_cust.cst_key = erp_loc.cid