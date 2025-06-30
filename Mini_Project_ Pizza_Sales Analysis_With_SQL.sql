-- Question 1:	Retrieve the total number of orders placed.
/*
Total Number of Orders Placed
------------------------------

What the query is doing:
Counts the total number of records in the ORDERS table.

SQL Functions Used:
COUNT(*)

Why those functions:
COUNT(*) efficiently calculates the number of rows representing the total orders placed.*/

-- Solution:

SELECT 
    COUNT(*)
FROM
    ORDERS;

-- Question 2:	Calculate the total revenue generated from pizza sales.
/*
Total Revenue Generated from Pizza Sales
----------------------------------------

What the query is doing:
Calculates the total revenue by multiplying the quantity of pizzas ordered by their price and summing them up.

SQL Functions Used:

SUM()
ROUND()
JOIN

Why those functions:
SUM() aggregates the total revenue, ROUND() formats it to 0 decimal places, and JOINs connect order details to pricing.
*/

-- Solution:

SELECT 
    ROUND(SUM(OD.QUANTITY * P.PRICE), 0) AS TOTAL_PRICE
FROM
    ORDERS O
        JOIN
    ORDER_DETAILS OD ON O.ORDER_ID = OD.ORDER_ID
        JOIN
    PIZZAS P ON OD.PIZZA_ID = P.PIZZA_ID;

-- Question 3:	Identify the highest-priced pizza.
/*
Highest-Priced Pizza
---------------------

What the query is doing:
Retrieves the name and price of the highest-priced pizza.

SQL Functions Used:

MAX()
JOIN

Why those functions:
MAX() helps find the highest value, and the join ensures that name and type are fetched alongside.
*/

-- Solution:

SELECT 
    PT.NAME, MAX(P.PRICE) AS MAX_PRICE
FROM
    PIZZAS P
        JOIN
    PIZZA_TYPES PT ON P.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID;

-- Question 4:	Identify the most common pizza size ordered.
/*
Most Common Pizza Size Ordered
-------------------------------

What the query is doing:
Identifies the most frequently ordered pizza by counting order frequency.

SQL Functions Used:

COUNT()
GROUP BY
Subquery
MAX()

Why those functions:
GROUP BY with COUNT() helps in counting per pizza, subquery aggregates, and MAX() fetches the top one.
*/

-- Solution:

SELECT 
    PIZZA_NAME, MAX(NO_OF_ORDERS) AS MOST_ORDERED
FROM
    (SELECT 
        PIZZA_ID AS PIZZA_NAME, COUNT(*) AS NO_OF_ORDERS
    FROM
        ORDER_DETAILS
    GROUP BY PIZZA_ID) MOST_COMMON_PIZZA;

-- Question 5:	List the top 5 most ordered pizza types along with their quantities.
/*
Top 5 Most Ordered Pizza Types (Quantity)
------------------------------------------

What the query is doing:
Lists the top 5 pizzas based on total quantity ordered.

SQL Functions Used:

COUNT()
SUM()
ORDER BY
LIMIT

Why those functions:
Helps rank and filter top-selling pizzas by frequency and quantity.
*/

-- Solution:

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

-- Question 6 :	Join the necessary tables to find the total quantity of each pizza category ordered.
/*
Total Quantity by Pizza Category
--------------------------------

What the query is doing:
Calculates total quantity sold per pizza category.

SQL Functions Used:

JOIN
SUM()
GROUP BY

Why those functions:
Enables relational aggregation to analyze category-wise sales.
*/

-- Solution:

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

-- Question 7:	Determine the distribution of orders by hour of the day.

/*
Order Distribution by Hour
--------------------------

What the query is doing:
Shows order count distributed by hour of the day.

SQL Functions Used:

HOUR()
COUNT()
GROUP BY

Why those functions:
To extract and group orders based on time granularity (hour).
*/

-- Solution:

SELECT 
    HOUR(TIME) AS ORDER_HOUR, COUNT(*) AS TOTAL_ORDERS
FROM
    ORDERS
GROUP BY ORDER_HOUR
ORDER BY ORDER_HOUR;

-- Question 8:	Join relevant tables to find the category-wise distribution of pizzas.
/*
Category-wise Pizza Distribution
--------------------------------

What the query is doing:
Sums the number of pizzas sold by category.

SQL Functions Used:

SUM()
JOIN
GROUP BY

Why those functions:
Allows category-level aggregation using relational joins.
*/

-- Solution:

SELECT 
    PT.CATEGORY, SUM(OD.QUANTITY) AS TOTAL_PIZZAS_ORDERED
FROM
    PIZZA_TYPES PT
        JOIN
    PIZZAS P ON PT.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS OD ON OD.PIZZA_ID = P.PIZZA_ID
GROUP BY PT.CATEGORY;

-- Question 9:	Group the orders by date and calculate the average number of pizzas ordered per day.
/*
Average Pizzas Ordered per Day
-------------------------------

What the query is doing:
First computes total pizzas ordered each day, then calculates the daily average.

SQL Functions Used:

SUM()
AVG()
GROUP BY

Why those functions:
To perform time-based aggregation and averaging.

*/

-- Solution:

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

-- Question 10:	Determine the top 3 most ordered pizza types based on revenue.
/*
Top 3 Pizza Types by Revenue
----------------------------

What the query is doing:
Calculates revenue by pizza type and lists the top 3.

SQL Functions Used:

SUM()
GROUP BY
ORDER BY
LIMIT

Why those functions:
To rank and filter top revenue-generating pizzas.
*/

-- Solution:

SELECT 
    P.PIZZA_TYPE_ID, SUM(OD.QUANTITY * P.PRICE) AS TOTAL_REVENUE
FROM
    ORDER_DETAILS OD
        JOIN
    PIZZAS P ON OD.PIZZA_ID = P.PIZZA_ID
GROUP BY P.PIZZA_TYPE_ID
ORDER BY TOTAL_REVENUE DESC
LIMIT 3;

-- Question 11:	Calculate the percentage contribution of each pizza type to total revenue.
/*
Revenue % by Pizza Type
------------------------

What the query is doing:
Calculates revenue contribution percentage of each pizza type.

SQL Functions Used:

SUM()
Subquery
ROUND()

Why those functions:
Enables relative performance measurement of each type.
*/

-- Solution:

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
    
-- Question 12:	Analyze the cumulative revenue generated over time.
/*
Cumulative Revenue Over Time
-----------------------------

What the query is doing:
Displays daily revenue and cumulative revenue trends.

SQL Functions Used:

SUM()
OVER() (Window Function)
DATE()

Why those functions:
To accumulate running totals chronologically.
*/

-- Solution :

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
    
-- Question 13:	Determine the top 3 most ordered pizza types based on revenue for each pizza category.  
/*
Top 3 Revenue Pizzas by Category
---------------------------------

What the query is doing:
Ranks pizzas within each category based on revenue and filters top 3.

SQL Functions Used:

SUM()
DENSE_RANK()
PARTITION BY
CTE (WITH)

Why those functions:
Required for intra-category ranking and filtering.
*/

-- Solution:

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
  
    

