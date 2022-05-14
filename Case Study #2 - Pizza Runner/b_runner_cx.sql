/* --------------------
   Case Study Questions
   --------------------*/
   
-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT WEEK(registration_date,0) AS registration_week, COUNT(runner_id) AS total_runners
FROM pizza_runner.runners
GROUP BY WEEK(registration_date)

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id, AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) AS avg_time_minute
FROM runner_orders_cleaned ro
INNER JOIN customer_orders_cleaned co ON ro.order_id = co.order_id
WHERE cancellation IS NULL
GROUP BY runner_id

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH temp AS(
 SELECT ro.order_id, COUNT(pizza_id) AS total_pizza, TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS total_prep_time
 FROM runner_orders_cleaned ro
 INNER JOIN customer_orders_cleaned co ON ro.order_id = co.order_id
 WHERE cancellation IS NULL
 GROUP BY ro.order_id
)
SELECT total_pizza, AVG(total_prep_time)
FROM temp
GROUP BY total_pizza

-- 4. What was the average distance travelled for each customer?

SELECT customer_id, AVG(distance)
FROM runner_orders_cleaned ro
INNER JOIN customer_orders_cleaned co ON ro.order_id = co.order_id
WHERE cancellation IS NULL
GROUP BY customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration) AS longest_delivery, MIN(duration) AS shortest_delivery,  MAX(duration) - MIN(duration) AS difference
FROM runner_orders_cleaned
WHERE cancellation IS NULL

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id, ro.order_id, COUNT(pizza_id) AS total_pizza, distance, duration, AVG(distance/(duration/60)) AS speed_kmh
FROM runner_orders_cleaned ro
INNER JOIN customer_orders_cleaned co ON ro.order_id = co.order_id
WHERE cancellation IS NULL
GROUP BY runner_id, ro.order_id
ORDER BY runner_id

-- 7. What is the successful delivery percentage for each runner?

SELECT runner_id,
 (SUM(CASE WHEN DISTANCE IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS success_rate
FROM runner_orders_cleaned
WHERE cancellation IS NULL
GROUP BY runner_id
