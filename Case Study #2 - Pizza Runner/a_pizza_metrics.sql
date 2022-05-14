/* --------------------
   Case Study Questions
   --------------------*/
   
-- A. Pizza Metrics
-- 1. How many pizzas were ordered?

SELECT COUNT(*) AS total_pizza
FROM customer_orders_cleaned

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_order
FROM customer_orders_cleaned

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders_cleaned
WHERE cancellation IS NULL
GROUP BY runner_id

-- 4. How many of each type of pizza was delivered?

SELECT co.pizza_id, pizza_name, COUNT(pizza_name) AS total_pizza_delivered
FROM runner_orders_cleaned ro
INNER JOIN customer_orders_cleaned co ON ro.order_id = co.order_id
INNER JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
WHERE cancellation IS NULL
GROUP BY pizza_name

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT co.customer_id,
 SUM(CASE WHEN co.pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers,
    SUM(CASE WHEN co.pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM runner_orders_cleaned ro
INNER JOIN customer_orders_cleaned co ON ro.order_id = co.order_id
INNER JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY customer_id

-- 6. What was the maximum number of pizzas delivered in a single order?

WITH temp AS(
 SELECT co.order_id, COUNT(pizza_id) AS total_pizza
 FROM customer_orders_cleaned co
 INNER JOIN runner_orders_cleaned ro ON co.order_id = ro.order_id
 WHERE cancellation IS NULL
 GROUP BY order_id
)
SELECT MAX(total_pizza)
FROM temp

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT customer_id,
 SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS at_least_one_change,
    SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS no_change
FROM customer_orders_cleaned co
INNER JOIN runner_orders_cleaned ro ON co.order_id = ro.order_id
WHERE cancellation IS NULL
GROUP BY customer_id

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS total_delivered
FROM customer_orders_cleaned co
INNER JOIN runner_orders_cleaned ro ON co.order_id = ro.order_id
WHERE cancellation IS NULL AND exclusions IS NOT NULL AND extras IS NOT NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT(HOUR FROM order_time) AS hour_of_the_day, COUNT(*) AS total_pizza_ordered
FROM customer_orders_cleaned co
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY hour_of_the_day

-- 10. What was the volume of orders for each day of the week?

SELECT DAYNAME(order_time) AS day_of_the_week, COUNT(*) AS total_pizza_ordered
FROM customer_orders_cleaned co
GROUP BY DAYNAME(order_time)
ORDER BY DAYOFWEEK(order_time)
