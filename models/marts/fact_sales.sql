-- models/marts/fact_sales.sql

SELECT
    csd.sls_ord_num AS order_number,
    dp.product_key, -- Get product_key from dim_products
    dc.customer_key, -- Get customer_key from dim_customers
    csd.sls_order_dt AS order_date,
    csd.sls_ship_dt AS shipping_date,
    csd.sls_due_dt AS due_date,
    csd.sls_sales AS sales_amount,
    csd.sls_quantity AS quantity,
    csd.sls_price AS price
FROM
    {{ ref('stg_crm_sales_details') }} csd -- Reference the Silver layer CRM sales details model
LEFT JOIN
    {{ ref('dim_products') }} dp -- Reference the newly created Gold dim_products model
    ON csd.sls_prd_key = dp.product_number
LEFT JOIN
    {{ ref('dim_customers') }} dc -- Reference the newly created Gold dim_customers model
    ON csd.sls_cust_id = dc.customer_id