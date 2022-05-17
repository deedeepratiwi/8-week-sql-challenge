/* --------------------
   Case Study Questions
   --------------------*/
   
-- A. Customer Journey
-- Based off the 8 sample customers provided in the sample from the subscriptions table, 
-- write a brief description about each customer's onboarding journey.

SELECT customer_id, s.plan_id, plan_name, start_date
FROM subscriptions s
INNER JOIN plans p ON s.plan_id = p.plan_id
WHERE customer_id IN (1, 57, 93, 215, 301, 450, 573, 648)
ORDER BY customer_id;

-- B. Data Analysis Questions
-- 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS total_customer
FROM subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT MONTH(start_date) AS month, MONTHNAME(start_date) AS month_name, COUNT(customer_id) AS total_customer
FROM subscriptions
WHERE plan_id = 0
GROUP BY MONTH(start_date)
ORDER BY MONTH(start_date);

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT s.plan_id, p.plan_name, COUNT(customer_id) AS total_customer
FROM subscriptions s
INNER JOIN plans p ON s.plan_id = p.plan_id
WHERE start_date >= '2021-01-01'
GROUP BY plan_id
ORDER BY plan_id;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT COUNT(DISTINCT customer_id) AS churn_customers, 
	ROUND(COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS churn_percentage
FROM subscriptions s
INNER JOIN plans p ON s.plan_id = p.plan_id
WHERE plan_name = 'churn';

-- 5. How many customers have churned straight after their initial free trial
-- what percentage is this rounded to the nearest whole number?

WITH get_rank AS(
	SELECT *, RANK() OVER (PARTITION BY customer_id ORDER BY start_date, plan_id) AS ranks
	FROM subscriptions
)
SELECT COUNT(DISTINCT customer_id) AS total_customers, 
	ROUND(COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS percentage
FROM get_rank r
INNER JOIN plans p ON r.plan_id = p.plan_id
WHERE plan_name = 'churn' AND ranks = 2;


-- 6. What is the number and percentage of customer plans after their initial free trial?

WITH next_plan AS(
	SELECT *, LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY plan_id) next_plan
	FROM subscriptions
)
SELECT next_plan, plan_name, COUNT(DISTINCT customer_id) AS total_customers, 
	ROUND(COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS percentage
FROM next_plan n
LEFT JOIN plans p ON n.next_plan = p.plan_id
WHERE n.plan_id = 0 AND next_plan IS NOT NULL
GROUP BY next_plan

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH next_plan AS(
		SELECT *, LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_start_date
		FROM subscriptions
		WHERE start_date <= '2020-12-31'
)
    
SELECT n.plan_id, plan_name, COUNT(DISTINCT customer_id) AS total_customers, 
	ROUND(COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS percentage
FROM next_plan n
LEFT JOIN plans p ON n.plan_id = p.plan_id
WHERE (next_start_date IS NOT NULL AND (start_date <= '2020-12-31' AND next_start_date > '2020-12-31'))
	OR (next_start_date IS NULL AND start_date <= '2020-12-31')
GROUP BY plan_name
ORDER BY n.plan_id

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions s
LEFT JOIN plans p ON s.plan_id = p.plan_id
WHERE plan_name = 'pro annual' AND start_date <= '2020-12-31'

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH 
	temp AS(
		SELECT *, RANK() OVER (PARTITION BY customer_id ORDER BY start_date) AS ranks
		FROM subscriptions
	),
    initial AS(
		SELECT customer_id, plan_id, start_date AS initial_date
        FROM temp
        WHERE ranks = 1
    ),
    
    pro AS(
		SELECT customer_id, plan_id, start_date AS pro_date
		FROM temp
		WHERE plan_id = 3
    )

SELECT ROUND(AVG(DATEDIFF(pro_date, initial_date)),0) AS avg_days_to_upgrade
FROM initial i
INNER JOIN pro p ON i.customer_id = p.customer_id

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0–30 days, 31–60 days etc)

WITH 
	temp AS(
		SELECT *, RANK() OVER (PARTITION BY customer_id ORDER BY start_date) AS ranks
		FROM subscriptions
	),
    initial AS(
		SELECT customer_id, plan_id, start_date AS initial_date
        FROM temp
        WHERE ranks = 1
    ),
    pro AS(
		SELECT customer_id, plan_id, start_date AS pro_date
		FROM temp
		WHERE plan_id = 3
    ),
    avg_upgrade AS(
		SELECT i.customer_id, ROUND(AVG(DATEDIFF(pro_date, initial_date)),0) AS avg_days_to_upgrade
		FROM initial i
		INNER JOIN pro p ON i.customer_id = p.customer_id
        GROUP BY i.customer_id
	),
	bins AS(
		SELECT FLOOR(avg_days_to_upgrade/30) AS bins_floor, COUNT(customer_id) AS total_customers
		FROM avg_upgrade 
		GROUP BY 1
		ORDER BY 1
	)
SELECT CONCAT((bins_floor*30)+1, ' - ', (bins_floor+1)*30, ' days ') AS avg_days_till_upgrade,
	total_customers
FROM bins;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH temp AS(
	SELECT *, LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY plan_id) AS next_plan
	FROM subscriptions s
)

SELECT COUNT(customer_id) AS downgrade_customers
FROM temp
WHERE next_plan = 1 AND plan_id = 2 AND YEAR(start_date) = '2020'

-- C. Challenge Payment Questions
-- The Foodie-Fi team wants you to create a new payments table for the year 2020 
-- that includes amounts paid by each customer in the subscriptions table with the following requirements:
-- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-- once a customer churns they will no longer make payments

WITH 
	initial AS(
		SELECT customer_id, s.plan_id, plan_name, start_date, start_date AS payment_date, price AS amount, 
			LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date, p.plan_id) AS next_date
		FROM subscriptions s
		LEFT JOIN plans p ON s.plan_id = p.plan_id
    ),
    paid_only AS(
    SELECT customer_id, plan_id, plan_name, start_date, payment_date, amount,
		CASE
			WHEN next_date IS NULL OR next_date > '2020-12-31' THEN '2020-12-31'
            ELSE next_date
		END AS next_date
    FROM initial
    WHERE plan_name NOT IN ('trial', 'churn')
    ),
    next_month_pay AS (
		SELECT customer_id, plan_id, plan_name, start_date, payment_date, amount, next_date, 
		DATEADD(M, -1, next_date) AS next_payment
    FROM paid_only
    ),
    get_date AS(
		SELECT customer_id, plan_id, plan_name, start_date, 
        payment_date = (SELECT TOP 1 start_date FROM next_month_pay WHERE customer_id = n.customer_id AND plan_id = n.plan_id),
        next_date, next_payment, amount
		FROM next_month_pay n
        
        UNION ALL 
    
		SELECT customer_id, plan_id, plan_name, start_date, DATEADD(M, 1, payment_date) AS payment_date,
			next_date, next_payment, amount
		FROM get_date g
		WHERE payment_date < next_payment AND  plan_id != 3
	)
    
SELECT customer_id, plan_id, plan_name, payment_date, amount,
	RANK() OVER(PARTITION BY customer_id ORDER BY customer_id, plan_id, payment_date) AS payment_order
FROM get_date
WHERE YEAR(payment_date) = 2020
ORDER BY customer_id, plan_id, payment_date;