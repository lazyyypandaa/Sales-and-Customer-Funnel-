CREATE TABLE shopify_sales (
    admin_graphql_api_id VARCHAR(100),
    order_number INT,
    billing_address_country VARCHAR(50),
    billing_address_first_name VARCHAR(50),
    billing_address_last_name VARCHAR(50),
    billing_address_province VARCHAR(50),
    billing_address_zip VARCHAR(20),
    city VARCHAR(50),
    currency VARCHAR(10),
    customer_id INT,
    invoice_date TIMESTAMP,
    gateway VARCHAR(50),
    product_id BIGINT,
    product_type VARCHAR(100),
    variant_id BIGINT,
    quantity INT,
    subtotal_price DECIMAL(10,2),
    total_price_usd DECIMAL(10,3),
    total_tax DECIMAL(10,3)
);

Alter table shopify_sales
Alter Column variant_id Type VARCHAR(100);

SELECT * FROM shopify_sales;


/* 1. Problem :
Which customers have generated the highest revenue over time, and how often do they purchase?*/

-- customers generated highest revenue
-- How often they purchase 

SELECT * FROM shopify_sales;

SELECT customer_id, SUM(Subtotal_Price) AS revenue_generated, count(order_number) AS purchased
FROM shopify_sales
GROUP BY customer_id
ORDER BY revenue_generated DESC;

SELECT customer_id, 
SUM(Subtotal_Price) AS revenue_generated, 
count(order_number) AS purchased,
	RANK() OVER (order by SUM(Subtotal_Price) DESC) AS rank
FROM shopify_sales
GROUP BY customer_id
ORDER BY revenue_generated DESC;

/* 2. find out how often repeat customers come back and gap between purchases.*/

---Repeated customers
---- Gap between purchases

SELECT * FROM shopify_sales;
		
WITH CustomerOrders AS (
    SELECT 
        Customer_Id, 
        Order_Number,
        Invoice_Date,
        ROW_NUMBER() OVER (PARTITION BY Customer_Id ORDER BY Invoice_Date) AS order_rank,
        LAG(Invoice_Date) OVER (PARTITION BY Customer_Id ORDER BY Invoice_Date) AS previous_order_date
    FROM shopify_sales
),
RepeatPurchases AS (
    SELECT 
        Customer_Id,
        Order_Number,
        Invoice_Date,
        previous_order_date,
        EXTRACT(DAY FROM Invoice_Date - previous_order_date) AS days_between_orders
    FROM CustomerOrders
    WHERE previous_order_date IS NOT NULL
)
SELECT 
    Customer_Id,
    COUNT(*) AS repeat_order_count,
    ROUND(Sum(days_between_orders), 2) AS days_between_orders
FROM RepeatPurchases
GROUP BY Customer_Id
ORDER BY repeat_order_count DESC;


/* 3. Problem:
What is the trend of total revenue, number of orders, and average order value per day?*/

SELECT EXTRACT(day FROM Invoice_Date) AS Days,
		sum(subtotal_price),
		Count(order_number),
		Round(Avg(subtotal_price),2)
	FROM shopify_sales
	Group By Days
	ORDER BY Days;

/*4. Problem: 
Analyze which payment methods yield higher revenue and average spend per order.*/

SELECT * FROM shopify_sales;

SELECT gateway,
		SUm(subtotal_price) as Revenue,
		ROUND(Sum(subtotal_price)/Count(order_number),2) AS Average_spend
FROM shopify_sales
GROUP BY gateway
ORDER BY Revenue DESC;

/* 5.Problem:
Understand how revenue and average order value fluctuate over time for forecasting and seasonality analysis.*/

SELECT 
		Extract( day from invoice_date) AS day,
		AVG(subtotal_price)	as Avg_order_value,
		SUM(subtotal_price) As revenue
	FROM shopify_sales
GROUP BY day
ORDER BY  day DESC;


	
	

	