-- 1.	Retrieve the total number of orders placed.
SELECT 
    COUNT(*)
FROM
    ORDERS;

-- 2.	Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(OD.QUANTITY * P.PRICE), 0) AS TOTAL_PRICE
FROM
    ORDERS O
        JOIN
    ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
        JOIN
    PIZZAS P ON OD.PIZZA_ID = P.PIZZA_ID;

-- 3.	Identify the highest-priced pizza.
SELECT 
    PT.NAME, MAX(P.PRICE) AS MAX_PRICE
FROM
    PIZZAS P
        JOIN
    PIZZA_TYPES PT ON P.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID;

-- 4.	Identify the most common pizza size ordered.
SELECT 
    PIZZA_NAME, MAX(NO_OF_ORDERS) AS MOST_ORDERED
FROM
    (SELECT 
        PIZZA_ID AS PIZZA_NAME, COUNT(*) AS NO_OF_ORDERS
    FROM
        ORDER_DETAILS
    GROUP BY PIZZA_ID) MOST_COMMON_PIZZA;

-- 5.	List the top 5 most ordered pizza types along with their quantities.

SELECT 
    *
FROM
    (SELECT 
        PIZZA_ID AS PIZZA_NAME,
            COUNT(*) AS NO_OF_ORDERS,
            SUM(QUANTITY) AS QUANTITY
    FROM
        ORDER_DETAILS
    GROUP BY PIZZA_ID
    ORDER BY 2 DESC) AS MOST_ORDERED
LIMIT 5;

-- 1.	Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    PT.PIZZA_TYPE_ID,
    PT.NAME,
    SUM(OD.QUANTITY) AS TOTAL_QUANTITY
FROM
    PIZZA_TYPES PT
        JOIN
    PIZZAS P ON PT.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS OD ON OD.PIZZA_ID = P.PIZZA_ID
        JOIN
    ORDERS O ON O.ORDER_ID = OD.ORDER_ID
GROUP BY PT.PIZZA_TYPE_ID , PT.NAME;

-- 2.	Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(TIME) AS ORDER_HOUR, COUNT(*) AS TOTAL_ORDERS
FROM
    ORDERS
GROUP BY ORDER_HOUR
ORDER BY ORDER_HOUR;

-- 3.	Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    PT.CATEGORY, SUM(OD.QUANTITY) AS TOTAL_PIZZAS_ORDERED
FROM
    PIZZA_TYPES PT
        JOIN
    PIZZAS P ON PT.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS OD ON OD.PIZZA_ID = P.PIZZA_ID
GROUP BY PT.CATEGORY;

-- 4.	Group the orders by date and calculate the average number of pizzas ordered per day.
-- Step 1: Total pizzas per day
SELECT 
    DATE(O.DATE) AS order_day, SUM(od.quantity) AS total_pizzas
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY order_day;

-- Step 2: Average number of pizzas ordered per day

SELECT 
    AVG(DAILY_PIZZAS.TOTAL_PIZZAS) AS AVG_PIZZAS_PER_DAY
FROM
    (SELECT 
        DATE(O.DATE) AS ORDER_DAY, SUM(OD.QUANTITY) AS TOTAL_PIZZAS
    FROM
        ORDERS O
    JOIN ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
    GROUP BY ORDER_DAY) AS DAILY_PIZZAS;

-- 5.	Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    P.PIZZA_TYPE_ID, SUM(OD.QUANTITY * P.PRICE) AS TOTAL_REVENUE
FROM
    ORDER_DETAILS OD
        JOIN
    PIZZAS P ON OD.PIZZA_ID = P.PIZZA_ID
GROUP BY P.PIZZA_TYPE_ID
ORDER BY TOTAL_REVENUE DESC
LIMIT 3;

-- 1.	Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    p.pizza_type_id,
    ROUND(SUM(od.quantity * p.price), 2) AS pizza_revenue,
    ROUND(SUM(od.quantity * p.price) * 100 / (SELECT 
                    SUM(od2.quantity * p2.price)
                FROM
                    order_details od2
                        JOIN
                    pizzas p2 ON od2.pizza_id = p2.pizza_id),
            2) AS revenue_percentage
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type_id
ORDER BY revenue_percentage DESC;
    
-- 2.	Analyze the cumulative revenue generated over time.

SELECT 
    order_day,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_day) AS cumulative_revenue
FROM (
    SELECT 
        DATE(o.date) AS order_day,
        SUM(od.quantity * p.price) AS daily_revenue
    FROM 
        orders o
    JOIN 
        order_details od ON o.order_id = od.order_id
    JOIN 
        pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY 
        order_day
) AS daily_summary
ORDER BY 
    order_day;
    
-- 3.	Determine the top 3 most ordered pizza types based on revenue for each pizza category.  

WITH pizza_revenue_by_category AS (
    SELECT 
        pt.category as category,
        p.pizza_type_id as pizza_type,
        SUM(od.quantity * p.price) AS total_revenue,
        DENSE_RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_in_category
    FROM 
        order_details od
    JOIN 
        pizzas p ON od.pizza_id = p.pizza_id
    JOIN  pizza_types pt ON pt.pizza_type_id = p.pizza_type_id   
    GROUP BY 
        pt.category, p.pizza_type_id
)

SELECT 
    category,
    pizza_type,
    total_revenue
FROM 
    pizza_revenue_by_category
WHERE 
    rank_in_category <= 3
ORDER BY 
    category, total_revenue DESC;
  
    

