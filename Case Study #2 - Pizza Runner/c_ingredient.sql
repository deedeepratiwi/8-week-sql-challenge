/* --------------------
   Case Study Questions
   --------------------*/

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