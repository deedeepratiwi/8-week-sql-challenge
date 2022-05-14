--#8WeekSQLChallenge: Case Study #2 - Pizza Runner

/* --------------------
   Tables
   --------------------*/

CREATE SCHEMA `pizza_runner` ;

CREATE TABLE `pizza_runner`.`runners` (
  `runner_id` INT NOT NULL,
  `registration_date` DATE NULL,
  PRIMARY KEY (`runner_id`));

INSERT INTO runners VALUES (1, '2021-01-01');
INSERT INTO runners VALUES (2, '2021-01-03');
INSERT INTO runners VALUES (3, '2021-01-08');
INSERT INTO runners VALUES (4, '2021-01-15');

CREATE TABLE `pizza_runner`.`pizza_names` (
  `pizza_id` INT NOT NULL,
  `pizza_name` VARCHAR(45) NULL,
  PRIMARY KEY (`pizza_id`));

INSERT INTO pizza_names VALUES (1, 'Meatlovers');
INSERT INTO pizza_names VALUES (2, 'Vegetarian');

CREATE TABLE `pizza_runner`.`pizza_recipes` (
  `pizza_id` INT NOT NULL,
  `toppings` VARCHAR(45) NULL,
  PRIMARY KEY (`pizza_id`));

INSERT INTO pizza_recipes VALUES (1, '1, 2, 3, 4, 5, 6, 8, 10');
INSERT INTO pizza_recipes VALUES (2, '4, 6, 7, 9, 11, 12');

CREATE TABLE `pizza_runner`.`pizza_toppings` (
  `topping_id` INT NOT NULL,
  `topping_name` VARCHAR(45) NULL);

INSERT INTO pizza_toppings VALUES (1, 'Bacon');
INSERT INTO pizza_toppings VALUES (2, 'BBQ Sauce');
INSERT INTO pizza_toppings VALUES (3, 'Beef');
INSERT INTO pizza_toppings VALUES (4, 'Cheese');
INSERT INTO pizza_toppings VALUES (5, 'Chicken');
INSERT INTO pizza_toppings VALUES (6, 'Mushrooms');
INSERT INTO pizza_toppings VALUES (7, 'Onions');
INSERT INTO pizza_toppings VALUES (8, 'Pepperoni');
INSERT INTO pizza_toppings VALUES (9, 'Peppers');
INSERT INTO pizza_toppings VALUES (10, 'Salami');
INSERT INTO pizza_toppings VALUES (11, 'Tomatoes');
INSERT INTO pizza_toppings VALUES (12, 'Tomato Sauce');

CREATE TABLE `pizza_runner`.`customer_orders` (
  `order_id` INT NULL,
  `customer_id` INT NULL,
  `pizza_id` INT NULL,
  `exclusions` VARCHAR(4) NULL,
  `extras` VARCHAR(4) NULL,
  `order_time` DATETIME NULL);

INSERT INTO customer_orders VALUES ('1', '101', '1', '', '', '2020-01-01 18:05:02');
INSERT INTO customer_orders VALUES ('2', '101', '1', '', '', '2020-01-01 19:00:52');
INSERT INTO customer_orders VALUES ('3', '102', '1', '', '', '2020-01-02 23:51:23');
INSERT INTO customer_orders VALUES ('3', '102', '2', '', NULL, '2020-01-02 23:51:23');
INSERT INTO customer_orders VALUES ('4', '103', '1', '4', '', '2020-01-04 13:23:46');
INSERT INTO customer_orders VALUES ('4', '103', '1', '4', '', '2020-01-04 13:23:46');
INSERT INTO customer_orders VALUES ('4', '103', '2', '4', '', '2020-01-04 13:23:46');
INSERT INTO customer_orders VALUES ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29');
INSERT INTO customer_orders VALUES ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13');
INSERT INTO customer_orders VALUES ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29');
INSERT INTO customer_orders VALUES ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33');
INSERT INTO customer_orders VALUES ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59');
INSERT INTO customer_orders VALUES ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49');
INSERT INTO customer_orders VALUES ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

CREATE TABLE `pizza_runner`.`runner_orders` (
  `order_id` INT NULL,
  `runner_id` INT NULL,
  `pickup_time` VARCHAR(19) NULL,
  `distance` VARCHAR(7) NULL,
  `duration` VARCHAR(10) NULL,
  `cancellation` VARCHAR(23) NULL);

INSERT INTO runner_orders VALUES ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', '');
INSERT INTO runner_orders VALUES ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', '');
INSERT INTO runner_orders VALUES ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL);
INSERT INTO runner_orders VALUES ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL);
INSERT INTO runner_orders VALUES ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL);
INSERT INTO runner_orders VALUES ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation');
INSERT INTO runner_orders VALUES ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null');
INSERT INTO runner_orders VALUES ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null');
INSERT INTO runner_orders VALUES ('9', '2', 'null', 'null', 'null', 'Customer Cancellation');
INSERT INTO runner_orders VALUES('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

/* --------------------
   Data Cleaning
   --------------------*/

CREATE TEMPORARY TABLE customer_orders_cleaned
SELECT order_id, customer_id, pizza_id,
 CASE
  WHEN exclusions = '' OR exclusions = 'null' THEN exclusions = NULL
        ELSE exclusions
 END AS exclusions,
    CASE
  WHEN extras = '' OR extras = 'null' THEN extras = NULL
        ELSE extras
 END AS extras,
 order_time
FROM customer_orders

CREATE TEMPORARY TABLE runner_orders_cleaned
SELECT order_id, runner_id, 
 CASE 
  WHEN pickup_time = 'null' THEN pickup_time = NULL
        ELSE pickup_time
 END AS pickup_time, 
    CASE
  WHEN distance = 'null' THEN distance = NULL
        WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
        ELSE distance
 END AS distance,
    CASE
  WHEN duration = 'null' THEN duration = NULL
        WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
        WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
        WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
        ELSE duration
 END AS duration,
    CASE
  WHEN cancellation = '' OR cancellation = 'null' THEN cancellation = NULL
        ELSE cancellation
 END AS cancellation
FROM runner_orders

ALTER TABLE runner_orders_cleaned MODIFY COLUMN pickup_time DATETIME;
ALTER TABLE runner_orders_cleaned MODIFY COLUMN distance DECIMAL(10,2);
ALTER TABLE runner_orders_cleaned MODIFY COLUMN duration INT;

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

-- C. Ingredient Optimization

-- 1. What are the standard ingredients for each pizza?

SELECT pizza_id, TRIM(VALUE) toppings
INTO #pizza_recipes_split
FROM pizza_recipes
CROSS APPLY STRING_SPLIT(toppings, ',')
ORDER BY pizza_id;

SELECT pizza_name, STRING_AGG(topping_name, ', ') AS ingredients
FROM pizza_names pn
INNER JOIN #pizza_recipes_split pr ON pn.pizza_id = pr.pizza_id
LEFT JOIN pizza_toppings pt ON pr.toppings = pt.topping_id
GROUP BY pn.pizza_name

-- 2. What was the most commonly added extra?

SELECT order_id, customer_id, pizza_id, exclusions, TRIM(VALUE) extras, order_time  
INTO #co_extras_split
FROM #customer_orders_cleaned
OUTER APPLY STRING_SPLIT(extras, ',');

ALTER TABLE #co_extras_split ALTER COLUMN extras int;

SELECT topping_id, topping_name, COUNT(extras) AS total
FROM #co_extras_split co
INNER JOIN pizza_toppings tp ON co.extras = tp.topping_id
GROUP BY topping_id, topping_name
ORDER BY total DESC;

-- 3. What was the most common exclusion?

SELECT order_id, customer_id, pizza_id, TRIM(VALUE) exclusions, extras, order_time 
INTO #co_exclusions_split
FROM #customer_orders_cleaned
OUTER APPLY STRING_SPLIT(exclusions, ',');

ALTER TABLE #co_exclusions_split ALTER COLUMN exclusions int;

SELECT topping_id, topping_name, COUNT(exclusions) AS total
FROM #co_exclusions_split co
INNER JOIN pizza_toppings tp ON co.exclusions = tp.topping_id
GROUP BY topping_id, topping_name
ORDER BY total DESC;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH temp AS(
	SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time, 
		CASE
			WHEN exc1_name IS NULL AND exc2_name IS NULL THEN ''
			WHEN exc1_name IS NOT NULL AND exc2_name IS NULL THEN CONCAT(' - Exclude ', exc1_name)
			ELSE CONCAT(' - Exclude ', exc1_name, ', ', exc2_name)
		END AS exc,
		CASE
			WHEN ext1_name IS NULL AND ext2_name IS NULL THEN ''
			WHEN ext1_name IS NOT NULL AND ext2_name IS NULL THEN CONCAT(' - Extra ', ext1_name)
			ELSE CONCAT(' - Extra ', ext1_name, ', ', ext2_name)
		END AS ext
	FROM(
		SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time, exc1, exc2, ext1, ext2, 
			pt1.topping_name AS exc1_name, pt2.topping_name AS exc2_name, pt3.topping_name AS ext1_name, 
			pt4.topping_name AS ext2_name
		FROM(
			SELECT *,
				LEFT(exclusions, CHARINDEX(',', exclusions+',')-1) AS exc1,
				STUFF(exclusions, 1, LEN(exclusions)+2-CHARINDEX(',', REVERSE(exclusions)), '') AS exc2,
				LEFT(extras, CHARINDEX(',', extras +',')-1) AS ext1,
				STUFF(extras, 1, LEN(extras)+2-CHARINDEX(',',REVERSE(extras)), '') AS ext2
			FROM customer_orders_cleaned
			) co_split
		LEFT JOIN pizza_toppings pt1 on exc1 = pt1.topping_id
		LEFT JOIN pizza_toppings pt2 on exc2 = pt2.topping_id
		LEFT JOIN pizza_toppings pt3 on ext1 = pt3.topping_id
		LEFT JOIN pizza_toppings pt4 on ext2 = pt4.topping_id
		) get_name
)

SELECT order_id, customer_id, temp.pizza_id, exclusions, extras, order_time, 
	CASE
		WHEN exclusions IS NULL AND extras IS NULL THEN pizza_name
		ELSE CONCAT(pizza_name, exc, ext)
	END AS order_item
FROM temp
INNER JOIN pizza_names pn ON temp.pizza_id = pn.pizza_id;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order 
-- from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"



-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- D. Pricing and Ratings

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes
-- how much money has Pizza Runner made so far if there are no delivery fees?

WITH temp AS (
 SELECT co.order_id, pizza_id, cancellation,
 CASE
  WHEN pizza_id = 1 THEN 12
  WHEN pizza_id = 2 THEN 10
 END AS price
FROM customer_orders_cleaned co
INNER JOIN runner_orders_cleaned ro ON co.order_id = ro.order_id
)
SELECT SUM(price) AS total_price
FROM temp
WHERE cancellation IS NULL

-- 2. What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

WITH temp AS(
	SELECT SUM(CASE WHEN pizza_id = 1 THEN 12
				WHEN pizza_id = 2 THEN 10
				END) price
	FROM customer_orders_cleaned co
	INNER JOIN runner_orders_cleaned ro ON co.order_id = ro.order_id
	WHERE cancellation IS NULL

	UNION ALL

	SELECT SUM(CASE WHEN extras != 0 then 1 ELSE 0 END) price
	FROM(
		SELECT co.order_id, pizza_id, exclusions, cancellation, CAST(TRIM(value) AS int) AS extras
		FROM customer_orders_cleaned co
		LEFT JOIN runner_orders_cleaned ro on ro.order_id = co.order_id
		CROSS APPLY STRING_SPLIT(extras, ',')
		WHERE cancellation IS NULL
	) ext
)

SELECT SUM(price) AS total_earnings
FROM temp;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset - generate a schema for this new table 
-- and insert your own data for ratings for each successful customer order between 1 to 5.

CREATE TABLE `pizza_runner`.`ratings` (
  `order_id` INT NULL,
  `rating` INT NULL,
  `comments` TEXT(500) NULL);

INSERT INTO ratings VALUES(1, 5, 'Excellent service');
INSERT INTO ratings VALUES(2, 5, '');
INSERT INTO ratings VALUES(3, 3, 'Good service');
INSERT INTO ratings VALUES(4, 5, 'Delivery was fast');
INSERT INTO ratings VALUES(5, 2, 'Pizza tasted bad');
INSERT INTO ratings VALUES(7, 1, 'Took too long');
INSERT INTO ratings VALUES(8, 1, 'Rude driver');
INSERT INTO ratings VALUES(10, 5, '');

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id, order_id,runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas

SELECT co.customer_id, co.order_id, runner_id, rating, order_time, pickup_time, 
TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS prep_time, 
duration, AVG(distance/(duration/60)) AS avg_speed, COUNT(pizza_id) AS total_pizza 
FROM customer_orders_cleaned co
LEFT JOIN runner_orders_cleaned ro ON co.order_id = ro.order_id
LEFT JOIN ratings r ON co.order_id = r.order_id 
WHERE cancellation IS NULL
GROUP BY order_id

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled
-- how much money does Pizza Runner have left over after these deliveries?

WITH temp AS(
    SELECT SUM(
		CASE
			WHEN pizza_id = 1 THEN 12
			WHEN pizza_id = 2 THEN 10
		END) AS price
	FROM customer_orders_cleaned co
    LEFT JOIN runner_orders_cleaned ro ON co.order_id = ro.order_id
    WHERE cancellation IS NULL

	UNION ALL
	SELECT (SUM(distance) * -0.30) AS price
	FROM runner_orders_cleaned
    WHERE cancellation IS NULL
)

SELECT SUM(price) AS net_income
FROM temp

-- Bonus Questions
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design?
-- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

INSERT INTO pizza_names VALUES (3, 'Supreme');
INSERT INTO pizza_recipes VALUES (3, '2, 3, 4, 6, 7, 8');