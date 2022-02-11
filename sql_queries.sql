SELECT DISTINCT channel
FROM web_events;

SELECT *
FROM accounts;

SELECT *
FROM sales_reps;

SELECT *
FROM region;

--QUESTION 1
SELECT acc.name, we.channel,
	   COUNT(we.channel) AS no_of_times,
	   SUM(o.total_amt_usd) AS total_amt_spent
FROM web_events AS we
JOIN accounts AS acc
ON we.account_id = acc.id
JOIN orders AS o
ON o.account_id = acc.id
WHERE we.channel = 'direct' AND 
	  we.occurred_at::varchar LIKE '%2016%'
GROUP BY 1, 2
ORDER BY 4 DESC, 3 DESC
LIMIT 20;
	  
--Q2	  
SELECT acc.name, SUM(o.total) AS total_qty,
	   SUM(o.total_amt_usd) AS tot_amt_spent,
	   CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Top level'
	   WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000 THEN 'Second level'
	   ELSE 'Lowest level' END AS level_of_customer
FROM accounts AS acc
JOIN orders AS o
ON o.account_id = acc.id
GROUP BY 1
ORDER BY SUM(o.total_amt_usd) DESC;

--Q3
SELECT sr.name, SUM(o.total) AS qty_ordered,
	   CASE WHEN SUM(o.total) > 200 THEN 'Top'
	   ELSE 'Not' END AS sales_rep_level
FROM sales_reps AS sr
JOIN accounts AS acc
ON sr.id = acc.sales_rep_id
JOIN orders AS o
ON o.account_id = acc.id
GROUP BY 1
ORDER BY 2 DESC;

--Q4
SELECT sr.name, 
	   SUM(o.total) AS qty_ordered, 
	   SUM(o.total_amt_usd) AS total_amt_made,
	   CASE WHEN SUM(o.total) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'Top'
	   WHEN SUM(o.total) > 150 AND SUM(o.total) < 200 OR SUM(o.total_amt_usd) > 500000 AND SUM(o.total_amt_usd) < 750000 THEN 'Middle'
	   ELSE 'Low' END AS sales_rep_level
FROM sales_reps AS sr
JOIN accounts AS acc
ON sr.id = acc.sales_rep_id
JOIN orders AS o
ON o.account_id = acc.id
GROUP BY 1
ORDER BY SUM(o.total_amt_usd) DESC;

--Q5
SELECT channel, COUNT(channel) AS no_of_events
FROM web_events AS we
JOIN accounts AS a
ON a.id = we.account_id
WHERE a.name = (SELECT name
				FROM
					(SELECT acc.name, SUM(o.total_amt_usd) AS tot_amt_spent
					FROM accounts AS acc
					JOIN orders AS o
					ON o.account_id = acc.id
					JOIN web_events AS we
					ON we.account_id = acc.id
					GROUP BY 1
					ORDER BY 2 DESC
					LIMIT 1) AS sub1)
GROUP BY 1
ORDER BY 2 DESC;

SELECT a.name, SUM(o.total_amt_usd) AS total_spent
FROM account AS a
JOIN orders As o 
ON a.id = o.account_id
	  