--#8WeekSQLChallenge: Case Study #1 — Danny’s Diner


/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


/* --------------------
   Solutions
   --------------------*/
   
-- 1. What is the total amount each customer spent at the restaurant?

SELECT sales.customer_id, SUM(price) AS total_price
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS total_visit
FROM dannys_diner.sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH temp AS(
 SELECT customer_id, order_date, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS purchase_order, product_name
 FROM dannys_diner.sales
 INNER JOIN menu ON menu.product_id = sales.product_id
 )
    
SELECT customer_id, order_date, product_name
FROM temp
WHERE purchase_order = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, COUNT(product_name) AS total_sold
FROM dannys_diner.sales
INNER JOIN menu ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY total_sold DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH temp AS(
 SELECT customer_id, product_name, COUNT(product_name) AS total_bought, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) AS product_rank
 FROM dannys_diner.sales
 INNER JOIN menu ON menu.product_id = sales.product_id
 GROUP BY customer_id, product_name
 )

SELECT *
FROM temp
WHERE product_rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH temp AS(
 SELECT sales.customer_id, order_date, join_date, product_name, DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date) AS purchase_rank
 FROM dannys_diner.sales
 INNER JOIN members ON sales.customer_id = members.customer_id
 INNER JOIN menu ON sales.product_id = menu.product_id
 WHERE sales.order_date >= members.join_date
 )

SELECT *
FROM temp
WHERE purchase_rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH temp AS(
 SELECT sales.customer_id, order_date, join_date, product_name, DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC) AS purchase_rank
 FROM dannys_diner.sales
 INNER JOIN members ON sales.customer_id = members.customer_id
 INNER JOIN menu ON sales.product_id = menu.product_id
 WHERE sales.order_date < members.join_date
 )
 
SELECT *
FROM temp
WHERE purchase_rank = 1;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT sales.customer_id, COUNT(sales.product_id) AS total_item, SUM(price) AS total_amount
FROM dannys_diner.sales
INNER JOIN members ON sales.customer_id = members.customer_id
INNER JOIN menu ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id
ORDER BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_table AS(
 SELECT *,
 CASE
  WHEN product_name = 'sushi' THEN (price * 10) * 2
  ELSE price * 10
 END AS points
 FROM menu
 )
    
SELECT customer_id, SUM(points) AS total_points
FROM points_table p
INNER JOIN sales s ON p.product_id = s.product_id
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH points_table AS(
 SELECT s.customer_id, s.product_id, order_date, join_date, m.product_name, m.price,
  CASE
   WHEN order_date < join_date THEN NULL
   WHEN order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 7 DAY) THEN (price *10) * 2
   ELSE
    CASE
     WHEN product_name = 'sushi' THEN (price * 10) * 2
     ELSE price * 10
    END
  END AS points
  FROM sales s
  INNER JOIN menu m ON s.product_id = m.product_id
  INNER JOIN members mb ON s.customer_id = mb.customer_id
 )
    
SELECT customer_id, SUM(points) AS total_points
FROM points_table
WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY customer_id;


/* --------------------
   Bonus Questions
   --------------------*/

-- Join all the things

SELECT sales.customer_id, order_date, product_name, price,
CASE
 WHEN order_date >= join_date THEN 'Y'
 ELSE 'N'
END AS member
FROM dannys_diner.sales
LEFT JOIN members ON sales.customer_id = members.customer_id
INNER JOIN menu ON sales.product_id = menu.product_id
ORDER BY customer_id, order_date, product_name;

-- Rank all the things

WITH temp AS(
 SELECT sales.customer_id, order_date, product_name, price,
  CASE
   WHEN order_date >= join_date THEN 'Y'
   ELSE 'N'
  END AS member
 FROM dannys_diner.sales
 LEFT JOIN members ON sales.customer_id = members.customer_id
 INNER JOIN menu ON sales.product_id = menu.product_id
 )
 
SELECT *,
 CASE 
  WHEN member = 'Y' THEN DENSE_RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
  ELSE NULL
 END AS ranking
FROM temp