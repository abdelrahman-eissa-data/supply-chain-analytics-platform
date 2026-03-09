/* =========================================================
   SUPPLY CHAIN DATA WAREHOUSE
   Load Data from stage_data into Dimension Tables and Fact Table
   ========================================================= */

/* =========================================================
   Data Warehouse Implementation

   The cleaned dataset was loaded into a PostgreSQL staging table and transformed into a dimensional data warehouse model using a star schema design.

   The warehouse consists of one fact table (fact_orders) and multiple dimension tables (dim_customer, dim_product, dim_region, dim_date).

   Two main challenges occurred during implementation:

   1. Duplicate matches in the region dimension
   The dim_region table contained duplicate geographic combinations, which caused multiple matches during the join with the fact table. This was solved by rebuilding the dimension using DISTINCT ON and enforcing uniqueness with a UNIQUE INDEX.

   2. Missing values in the date dimension
   The fact table references both order_date and shipping_date. Some shipping dates were not present in the date dimension, causing foreign key violations. The issue was resolved by generating a complete dynamic calendar using PostgreSQL generate_series().

   ========================================================= */


/* =========================================================
   0. SOURCE CHECK
   ========================================================= */

SELECT *
FROM public.stage_data;

/* =========================================================

Alte dim_date
Insert Data to dim_Date (Alle Daten von Order_Date & Shipping_Date werden angezeigt in dim_Date)

INSERT INTO dim_date (date_key, year, month, quarter)
SELECT DISTINCT
  d::date AS date_key,
  EXTRACT(YEAR FROM d)::int,
  EXTRACT(MONTH FROM d)::int,
  EXTRACT(QUARTER FROM d)::int
FROM (
    SELECT "order date (DateOrders)" AS d FROM stage_data
    UNION
    SELECT "shipping date (DateOrders)" AS d FROM stage_data
) all_dates
WHERE d IS NOT NULL;
   ========================================================= */



/* =========================================================
   1. LOAD dim_date
   Ziel:
   - Aufbau einer vollständigen Date-Dimension
   - Dynamischer Kalender von MIN(order/shipping date)
     bis MAX(order/shipping date)
   - Keine Datums-Lücken
   ========================================================= */

/* Optional: Check min/max dates */
SELECT
  MIN(("order date (DateOrders)")::date)    AS min_order_date,
  MAX(("order date (DateOrders)")::date)    AS max_order_date,
  MIN(("shipping date (DateOrders)")::date) AS min_ship_date,
  MAX(("shipping date (DateOrders)")::date) AS max_ship_date
FROM public.stage_data;

/* Truncate fact first because of foreign key dependency */
TRUNCATE TABLE public.fact_orders;
TRUNCATE TABLE public.dim_date CASCADE;

/* Insert complete dynamic calendar */
INSERT INTO public.dim_date (date_key, year, month, quarter)
SELECT
  d::date AS date_key,
  EXTRACT(YEAR FROM d)::int AS year,
  EXTRACT(MONTH FROM d)::int AS month,
  EXTRACT(QUARTER FROM d)::int AS quarter
FROM generate_series(
  (
    SELECT LEAST(
      MIN(("order date (DateOrders)")::date),
      MIN(("shipping date (DateOrders)")::date)
    )
    FROM public.stage_data
  ),
  (
    SELECT GREATEST(
      MAX(("order date (DateOrders)")::date),
      MAX(("shipping date (DateOrders)")::date)
    )
    FROM public.stage_data
  ),
  INTERVAL '1 day'
) AS d;


/* Check dim_date */
SELECT *
FROM public.dim_date;

SELECT *
FROM public.dim_date
WHERE date_key = DATE '2018-02-03';


/* =========================================================
   2. LOAD dim_customer
   Ziel:
   - Einmalige Kundenstammdaten laden
   ========================================================= */

INSERT INTO public.dim_customer (
  customer_id,
  customer_segment,
  customer_country,
  customer_state,
  customer_city,
  customer_zipcode
)
SELECT DISTINCT
  "Customer Id",
  "Customer Segment",
  "Customer Country",
  "Customer State",
  "Customer City",
  "Customer Zipcode"
FROM public.stage_data
WHERE "Customer Id" IS NOT NULL
ON CONFLICT (customer_id) DO NOTHING;

/* Check dim_customer */
SELECT *
FROM public.dim_customer;


/* =========================================================
   3. LOAD dim_product
   Ziel:
   - Produktstammdaten dedupliziert laden
   ========================================================= */

INSERT INTO public.dim_product (
  product_card_id,
  product_name,
  product_category_id,
  category_name,
  department_id,
  department_name,
  product_price,
  product_status
)
SELECT DISTINCT
  "Product Card Id",
  "Product Name",
  "Product Category Id",
  "Category Name",
  "Department Id",
  "Department Name",
  "Product Price",
  "Product Status"
FROM public.stage_data
WHERE "Product Card Id" IS NOT NULL
ON CONFLICT (product_card_id) DO NOTHING;

/* Check dim_product */
SELECT *
FROM public.dim_product;


/* =========================================================
   4. LOAD dim_region
   Ziel:
   - Eindeutige geografische Dimension aufbauen
   - Duplikate vermeiden
   ========================================================= */

/* Falls nötig: alte Daten löschen */
TRUNCATE TABLE public.fact_orders;
TRUNCATE TABLE public.dim_region RESTART IDENTITY CASCADE;

/* Insert deduplicated region records */
INSERT INTO public.dim_region (
  market,
  order_region,
  order_country,
  order_state,
  order_city,
  latitude,
  longitude
)
SELECT DISTINCT ON (
  "Market",
  "Order Region",
  "Order Country",
  "Order State",
  "Order City"
)
  "Market"        AS market,
  "Order Region"  AS order_region,
  "Order Country" AS order_country,
  "Order State"   AS order_state,
  "Order City"    AS order_city,
  "Latitude"      AS latitude,
  "Longitude"     AS longitude
FROM public.stage_data
ORDER BY
  "Market",
  "Order Region",
  "Order Country",
  "Order State",
  "Order City";

/* Create unique index to prevent duplicates in future */
CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_region_geo
ON public.dim_region (
  market,
  order_region,
  order_country,
  order_state,
  order_city
);

/* Check dim_region */
SELECT *
FROM public.dim_region;

/* Duplicate check */
SELECT
  market,
  order_region,
  order_country,
  order_state,
  order_city,
  COUNT(*) AS cnt
FROM public.dim_region
GROUP BY
  market,
  order_region,
  order_country,
  order_state,
  order_city
HAVING COUNT(*) > 1;


/* =========================================================
   5. LOAD fact_orders
   Ziel:
   - Faktentabelle mit allen Measures und Foreign Keys befüllen
   ========================================================= */

TRUNCATE TABLE public.fact_orders;

INSERT INTO public.fact_orders (
  order_item_id,
  order_id,
  customer_id,
  product_card_id,
  region_key,
  order_date_key,
  shipping_date_key,
  shipping_mode,
  delivery_status,
  order_status,
  type,
  days_shipping_real,
  days_shipment_scheduled,
  late_delivery_risk,
  order_item_quantity,
  sales,
  order_profit_per_order,
  benefit_per_order,
  sales_per_customer,
  order_item_total,
  order_item_discount,
  order_item_discount_rate,
  order_item_profit_ratio,
  order_item_product_price
)
SELECT
  s."Order Item Id",
  s."Order Id",
  s."Customer Id",
  s."Product Card Id",
  r.region_key,
  (s."order date (DateOrders)")::date,
  (s."shipping date (DateOrders)")::date,
  s."Shipping Mode",
  s."Delivery Status",
  s."Order Status",
  s."Type",
  s."Days for shipping (real)",
  s."Days for shipment (scheduled)",
  s."Late_delivery_risk",
  s."Order Item Quantity",
  s."Sales",
  s."Order Profit Per Order",
  s."Benefit per order",
  s."Sales per customer",
  s."Order Item Total",
  s."Order Item Discount",
  s."Order Item Discount Rate",
  s."Order Item Profit Ratio",
  s."Order Item Product Price"
FROM public.stage_data s
JOIN public.dim_region r
  ON r.market        = s."Market"
 AND r.order_region  = s."Order Region"
 AND r.order_country = s."Order Country"
 AND r.order_state   = s."Order State"
 AND r.order_city    = s."Order City";


/* =========================================================
   6. FINAL CHECKS
   ========================================================= */

SELECT COUNT(*) AS stage_rows      FROM public.stage_data;
SELECT COUNT(*) AS fact_rows       FROM public.fact_orders;
SELECT COUNT(*) AS customer_rows   FROM public.dim_customer;
SELECT COUNT(*) AS product_rows    FROM public.dim_product;
SELECT COUNT(*) AS region_rows     FROM public.dim_region;
SELECT COUNT(*) AS date_rows       FROM public.dim_date;

/* Sanity check: Region distribution */
SELECT
  r.market,
  r.order_region,
  COUNT(*) AS row_count
FROM public.fact_orders f
JOIN public.dim_region r
  ON r.region_key = f.region_key
GROUP BY
  r.market,
  r.order_region

ORDER BY row_count DESC;
