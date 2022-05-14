/* --------------------
   Case Study Questions
   --------------------*/
   
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

