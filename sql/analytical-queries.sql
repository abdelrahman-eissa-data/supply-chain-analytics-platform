-- Top 10 products by profit
SELECT 
product_name,
SUM(profit) AS total_profit
FROM fact_orders
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;
