Data Warehouse Implementation

The cleaned dataset was loaded into a PostgreSQL staging table and transformed into a dimensional data warehouse model using a star schema design.

The warehouse consists of one fact table (fact_orders) and multiple dimension tables (dim_customer, dim_product, dim_region, dim_date).

Two main challenges occurred during implementation:

1. Duplicate matches in the region dimension
The dim_region table contained duplicate geographic combinations, which caused multiple matches during the join with the fact table. This was solved by rebuilding the dimension using DISTINCT ON and enforcing uniqueness with a UNIQUE INDEX.

2. Missing values in the date dimension
The fact table references both order_date and shipping_date. Some shipping dates were not present in the date dimension, causing foreign key violations. The issue was resolved by generating a complete dynamic calendar using PostgreSQL generate_series().
