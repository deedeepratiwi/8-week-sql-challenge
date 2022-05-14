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