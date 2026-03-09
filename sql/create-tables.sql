DROP TABLE IF EXISTS stage_data;

CREATE TABLE stage_data (
  "Type" text,
  "Days for shipping (real)" int,
  "Days for shipment (scheduled)" int,
  "Benefit per order" numeric(18,2),
  "Sales per customer" numeric(18,2),
  "Delivery Status" text,
  "Late_delivery_risk" int,
  "Category Id" int,
  "Category Name" text,
  "Customer City" text,
  "Customer Country" text,
  "Customer Id" int,
  "Customer Segment" text,
  "Customer State" text,
  "Customer Street" text,
  "Customer Zipcode" text,
  "Department Id" int,
  "Department Name" text,
  "Latitude" numeric(10,6),
  "Longitude" numeric(10,6),
  "Market" text,
  "Order City" text,
  "Order Country" text,
  "Order Customer Id" int,
  "order date (DateOrders)" timestamp,
  "Order Id" int,
  "Order Item Cardprod Id" int,
  "Order Item Discount" numeric(18,2),
  "Order Item Discount Rate" numeric(10,6),
  "Order Item Id" int,
  "Order Item Product Price" numeric(18,2),
  "Order Item Profit Ratio" numeric(10,6),
  "Order Item Quantity" int,
  "Sales" numeric(18,2),
  "Order Item Total" numeric(18,2),
  "Order Profit Per Order" numeric(18,2),
  "Order Region" text,
  "Order State" text,
  "Order Status" text,
  "Product Card Id" int,
  "Product Category Id" int,
  "Product Name" text,
  "Product Price" numeric(18,2),
  "Product Status" int,
  "shipping date (DateOrders)" timestamp,
  "Shipping Mode" text
);






----Creat dim_date Table 

DROP TABLE IF EXISTS dim_date CASCADE;

CREATE TABLE dim_date (
  date_key date PRIMARY KEY,
  year int,
  month int,
  quarter int
);











---dim_customer

DROP TABLE IF EXISTS dim_customer CASCADE;

CREATE TABLE dim_customer (
  customer_id int PRIMARY KEY,
  customer_segment text,
  customer_country text,
  customer_state text,
  customer_city text,
  customer_zipcode text
);
















----dim_product
DROP TABLE IF EXISTS dim_product CASCADE;

CREATE TABLE dim_product (
  product_card_id int PRIMARY KEY,
  product_name text,
  product_category_id int,
  category_name text,
  department_id int,
  department_name text,
  product_price numeric(18,2),
  product_status int
);















--- dim_region

DROP TABLE IF EXISTS dim_region CASCADE;

CREATE TABLE dim_region (
  region_key bigserial PRIMARY KEY,
  market text,
  order_region text,
  order_country text,
  order_state text,
  order_city text,
  latitude numeric(10,6),
  longitude numeric(10,6)
);


















---- Fact Table 

DROP TABLE IF EXISTS fact_orders CASCADE;

CREATE TABLE fact_orders (
  order_item_id int PRIMARY KEY,
  order_id int,

  customer_id int REFERENCES dim_customer(customer_id),
  product_card_id int REFERENCES dim_product(product_card_id),
  region_key bigint REFERENCES dim_region(region_key),

  order_date_key date REFERENCES dim_date(date_key),
  shipping_date_key date REFERENCES dim_date(date_key),

  shipping_mode text,
  delivery_status text,
  order_status text,
  type text,

  days_shipping_real int,
  days_shipment_scheduled int,
  late_delivery_risk int,

  order_item_quantity int,
  sales numeric(18,2),
  order_profit_per_order numeric(18,2),
  benefit_per_order numeric(18,2),
  sales_per_customer numeric(18,2),

  order_item_total numeric(18,2),
  order_item_discount numeric(18,2),
  order_item_discount_rate numeric(10,6),
  order_item_profit_ratio numeric(10,6),
  order_item_product_price numeric(18,2)
);

















