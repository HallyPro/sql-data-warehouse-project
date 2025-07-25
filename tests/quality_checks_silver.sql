/*
===============================================================================================
Quality Checks
===============================================================================================
Script Purpose:
  This Script performs various quality checks for data consistency, accuracy,
  and standardization across the 'silver' schemas.  It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistiency.
  - Invalid date ranges and orders.
  - Data consistency between related fields.

Usage Notes:
  - Run these checks after data loading the Silver Layer.
  - Investigate and resolve any discrepancies found during the checks.
===============================================================================================
*/

-- Checking 'silver.crm_prd_info'
-- >> Checking for duplicates
SELECT prd_id, COUNT(*) FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- >> Checking for unwanted spaces
SELECT prd_nm FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- >> Checking for negative numbers and nulls 
SELECT prd_cost FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- >> Checking Data Standardization & Consistency
SELECT DISTINCT prd_line FROM silver.crm_prd_info

-- >> Checking inconsistent dates 
SELECT prd_start_dt, prd_end_dt FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- Checking 'silver.crm_sales_details'
-- >> Checking invalid dates for sales details
SELECT NULLIF(sls_due_dt, 0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt < 0 
OR sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- >> Check for Invalid Date Orders 
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Quantity, and Price 
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero or negative.
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL or sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 or sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


-- Checking 'silver.erp_cust_az12'
-- >> Identify Out-of-Range Dates 
-- >> Expectation: Birthdate between 1924-01-01 and Today 
SELECT DISTINCT 
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();

-- >> Data standardization & consistency 
SELECT DISTINCT 
    gen
FROM silver.erp_cust_az12;


--  Checking 'silver.erp_loc_a101'
-- >> Data standardization & consistency
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- Checking 'silver.erp_px_cat_g1v2'

-- >> Check for unwanted spaces
SELECT
 *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);
