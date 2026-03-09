/* =========================================================
   SUPPLY CHAIN ANALYTICAL SQL QUERIES
   Projekt: Supply Chain Analytics Platform
   Beschreibung:
   Dieses Skript enthält zentrale analytische SQL-Abfragen
   auf Basis des Star-Schema-Data-Warehouse-Modells.
   ========================================================= */


/* =========================================================
   1. TOTAL SALES, TOTAL PROFIT, PROFIT MARGIN
   
   Ziel:
   - Gesamtumsatz und Gesamtgewinn analysieren
   ========================================================= */
SELECT
    SUM(sales) AS total_sales,
    SUM(order_profit_per_order) AS total_profit,
    ROUND((SUM(order_profit_per_order) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_percent
FROM public.fact_orders;


/* =========================================================
   2. ON-TIME DELIVERY RATE
   
   Ziel:
   - Anteil pünktlicher Bestellungen berechnen
   ========================================================= */
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 0 THEN 1 ELSE 0 END) AS on_time_orders,
    ROUND(
        SUM(CASE WHEN late_delivery_risk = 0 THEN 1 ELSE 0 END)::numeric
        / COUNT(*) * 100, 2
    ) AS on_time_delivery_rate_percent
FROM public.fact_orders;


/* =========================================================
   3. AVERAGE DELIVERY DELAY
   
   Ziel:
   - Durchschnittliche Abweichung zwischen realer und geplanter Lieferzeit
   ========================================================= */
SELECT
    ROUND(AVG(days_shipping_real - days_shipment_scheduled)::numeric, 2) AS avg_delay_days
FROM public.fact_orders;


/* =========================================================
   4. TOP 10 PRODUCTS BY SALES
   Ziel:
   - Umsatzstärkste Produkte identifizieren
   ========================================================= */
SELECT
    p.product_name,
    ROUND(SUM(f.sales)::numeric, 2) AS total_sales
FROM public.fact_orders f
JOIN public.dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;


/* =========================================================
   5. TOP 10 PRODUCTS BY PROFIT
   
   Ziel:
   - Profitabelste Produkte identifizieren
   ========================================================= */
SELECT
    p.product_name,
    ROUND(SUM(f.order_profit_per_order)::numeric, 2) AS total_profit
FROM public.fact_orders f
JOIN public.dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 10;


/* =========================================================
   6. PRODUCTS WITH NEGATIVE PROFIT
   
   Ziel:
   - Unprofitable Produkte erkennen
   ========================================================= */
SELECT
    p.product_name,
    ROUND(SUM(f.order_profit_per_order)::numeric, 2) AS total_profit
FROM public.fact_orders f
JOIN public.dim_product p
    ON f.product_card_id = p.product_card_id
GROUP BY p.product_name
HAVING SUM(f.order_profit_per_order) < 0
ORDER BY total_profit ASC;


/* =========================================================
   7. DELIVERY PERFORMANCE BY REGION
   
   Ziel:
   - Regionen mit den höchsten Lieferverzögerungen identifizieren
   ========================================================= */
SELECT
    r.market,
    r.order_region,
    COUNT(*) AS total_orders,
    ROUND(AVG(f.days_shipping_real - f.days_shipment_scheduled)::numeric, 2) AS avg_delay_days
FROM public.fact_orders f
JOIN public.dim_region r
    ON f.region_key = r.region_key
GROUP BY r.market, r.order_region
ORDER BY avg_delay_days DESC;


/* =========================================================
   8. SALES AND PROFIT BY CUSTOMER SEGMENT
   
   Ziel:
   - Umsatz- und Gewinnbeitrag nach Kundensegment analysieren
   ========================================================= */
SELECT
    c.customer_segment,
    ROUND(SUM(f.sales)::numeric, 2) AS total_sales,
    ROUND(SUM(f.order_profit_per_order)::numeric, 2) AS total_profit
FROM public.fact_orders f
JOIN public.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY total_sales DESC;


/* =========================================================
   9. DISCOUNT IMPACT ON PROFIT
   
   Ziel:
   - Zusammenhang zwischen Rabatt und durchschnittlichem Profit analysieren
   ========================================================= */
SELECT
    ROUND(order_item_discount_rate::numeric, 2) AS discount_rate,
    ROUND(AVG(order_profit_per_order)::numeric, 2) AS avg_profit
FROM public.fact_orders
GROUP BY ROUND(order_item_discount_rate::numeric, 2)
ORDER BY discount_rate;


/* =========================================================
   10. MONTHLY SALES TREND
   
   Ziel:
   - Umsatzentwicklung über Zeit analysieren
   ========================================================= */
SELECT
    d.year,
    d.month,
    ROUND(SUM(f.sales)::numeric, 2) AS monthly_sales
FROM public.fact_orders f
JOIN public.dim_date d
    ON f.order_date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;


/* =========================================================
   11. DELIVERY PERFORMANCE BY SHIPPING MODE
   
   Ziel:
   - Effizienz verschiedener Versandarten vergleichen
   ========================================================= */
SELECT
    shipping_mode,
    COUNT(*) AS total_orders,
    ROUND(AVG(days_shipping_real - days_shipment_scheduled)::numeric, 2) AS avg_delay_days
FROM public.fact_orders
GROUP BY shipping_mode
ORDER BY avg_delay_days DESC;


/* =========================================================
   12. LATE DELIVERY RISK BY REGION
   Bonus Query
   Ziel:
   - Regionen mit hohem Lieferausfall-/Verspätungsrisiko identifizieren
   ========================================================= */
SELECT
    r.market,
    r.order_region,
    ROUND(AVG(f.late_delivery_risk)::numeric * 100, 2) AS late_delivery_risk_percent,
    COUNT(*) AS total_orders
FROM public.fact_orders f
JOIN public.dim_region r
    ON f.region_key = r.region_key
GROUP BY r.market, r.order_region
ORDER BY late_delivery_risk_percent DESC;


/* =========================================================
   13. PROFITABILITY BY MARKET 
   
   Ziel:
   - Märkte nach Profitabilität und Stabilität bewerten
   ========================================================= */
SELECT
    r.market,
    ROUND(AVG(f.order_profit_per_order)::numeric, 2) AS avg_profit,
    ROUND(STDDEV_POP(f.order_profit_per_order)::numeric, 2) AS profit_stddev,
    ROUND(AVG(
        CASE
            WHEN f.sales = 0 THEN NULL
            ELSE f.order_profit_per_order / f.sales
        END
    )::numeric, 4) AS avg_profit_margin
FROM public.fact_orders f
JOIN public.dim_region r
    ON f.region_key = r.region_key
GROUP BY r.market
ORDER BY avg_profit_margin DESC;


/* =========================================================
   14. AVG BASKET VALUE BY CUSTOMER SEGMENT 
   
   Ziel:
   - Durchschnittlichen Warenkorbwert je Kundensegment analysieren
   ========================================================= */
WITH order_level AS (
    SELECT
        order_id,
        customer_id,
        SUM(sales) AS order_sales,
        SUM(order_profit_per_order) AS order_profit
    FROM public.fact_orders
    GROUP BY order_id, customer_id
)
SELECT
    c.customer_segment,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.order_sales)::numeric, 2) AS avg_basket_value,
    ROUND(AVG(o.order_profit)::numeric, 2) AS avg_profit_per_order
FROM order_level o
JOIN public.dim_customer c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY avg_basket_value DESC;
