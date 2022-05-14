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