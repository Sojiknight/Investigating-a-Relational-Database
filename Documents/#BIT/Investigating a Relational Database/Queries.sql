/*PROJECT 1: INVESTIGATE A RELATIONAL DATABASE*/
--QUESTIONS (Q1 & Q2 Obtained from previous question sets)

--Q1
/*Provide a table with the family-friendly film category(Animation, Children,
Classics, Comedy, Family and Music),each of the quartiles, and the corresponding
count of movies within each combination of film category for each corresponding
rental duration category. The resulting table should have three columns:
Category, Rental length category and Count*/

--SOLUTION
SELECT
   category_of_film,
   std_quartile,
   COUNT(*) AS movie_count
FROM
   (
      SELECT
         film_title,
         category_of_film,
         rental_duration,
         NTILE(4) OVER (
      ORDER BY
         rental_duration) AS std_quartile
      FROM
         (
            SELECT
               f.title AS film_title,
               c.name AS category_of_film,
               f.rental_duration AS rental_duration
            FROM
               film AS f
               JOIN
                  film_category AS fc
                  ON f.film_id = fc.film_id
               JOIN
                  category AS c
                  ON c.category_id = fc.category_id
            WHERE
               c.name IN
               (
                  'Animation',
                  'Children',
                  'Classics',
                  'Comedy',
                  'Family',
                  'Music'
               )
            GROUP BY
               1,
               2,
               3
            ORDER BY
               2,
               1
         )
         sub1
      ORDER BY
         3
   )
   sub2
GROUP BY
   1,
   2
ORDER BY
   1,
   2;


--Q2
/*Identify the top 10 paying customers, how many payments they made on a monthly
basis during the year 2007, and what was the amount of the monthly payments.
Write a query to capture the customer’s name, total payment count, and total
amount paid for each of the top 10 paying customers?*/

--SOLUTION
WITH t1 AS
(
   SELECT
      CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
      DATE_TRUNC('month', p.payment_date) AS payment_month,
      COUNT(p.payment_id) AS monthly_payment_count,
      SUM(p.amount) AS total_amount_spent
   FROM
      customer AS cu
      JOIN
         payment AS p
         ON cu.customer_id = p.customer_id
   WHERE
      CONCAT(cu.first_name, ' ', cu.last_name) IN
      (
         SELECT
            customer_name
         FROM
            (
               SELECT
                  CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
                  DATE_PART('year', p.payment_date) AS payment_year,
                  SUM(p.amount) AS total_amount_spent
               FROM
                  customer AS cu
                  JOIN
                     payment AS p
                     ON cu.customer_id = p.customer_id
               GROUP BY
                  1,
                  2
               ORDER BY
                  3 DESC LIMIT 10
            )
            sub1
      )
   GROUP BY
      1,
      2
   ORDER BY
      1
)

SELECT
   customer_name,
   SUM(monthly_payment_count) total_payment_count,
   SUM(total_amount_spent) total_amount_spent
FROM
   t1
GROUP BY
   1;



--Q3
/*Find the most watched movie category and return the top ten countries where it
 is the highest rented category*/

--SOLUTION
WITH t1 AS
(
   SELECT
      ca.name category,
      COUNT(*)
   FROM
      category AS ca
      JOIN
         film_category AS fc
         ON ca.category_id = fc.category_id
      JOIN
         film AS f
         ON fc.film_id = f.film_id
      JOIN
         inventory AS i
         ON f.film_id = i.film_id
      JOIN
         rental AS r
         ON i.inventory_id = r.inventory_id
   GROUP BY
      1
   ORDER BY
      2 DESC LIMIT 1
)
SELECT
   co.country AS country,
   ca.name AS category,
   COUNT(r.rental_id) AS rental_count
FROM
   category AS ca
   JOIN
      film_category AS fc
      ON ca.category_id = fc.category_id
   JOIN
      film AS f
      ON fc.film_id = f.film_id
   JOIN
      inventory AS i
      ON f.film_id = i.film_id
   JOIN
      rental AS r
      ON i.inventory_id = r.inventory_id
   JOIN
      customer AS cu
      ON r.customer_id = cu.customer_id
   JOIN
      address AS ad
      ON ad.address_id = cu.address_id
   JOIN
      city AS ci
      ON ci.city_id = ad.city_id
   JOIN
      country AS co
      ON co.country_id = ci.country_id
WHERE
   ca.name =
   (
      SELECT
         category
      FROM
         t1
   )
GROUP BY
   1,
   2
ORDER BY
   3 DESC LIMIT 10;



--Q4
/*Who are the top ten most frequent actors in the family-friendly
film category?*/

--SOLUTION
SELECT
   actor_name,
   SUM(films_starred) AS no_of_films
FROM
   (
      SELECT
         ca.name AS movie_category,
         a.first_name || ' ' || a.last_name AS actor_name,
         COUNT(*) AS films_starred
      FROM
         category AS ca
         JOIN
            film_category AS fc
            ON ca.category_id = fc.category_id
         JOIN
            film AS f
            ON f.film_id = fc.film_id
         JOIN
            film_actor AS fa
            ON f.film_id = fa.film_id
         JOIN
            actor AS a
            ON a.actor_id = fa.actor_id
      WHERE
         ca.name IN
         (
            'Animation',
            'Children',
            'Classics',
            'Comedy',
            'Family',
            'Music'
         )
      GROUP BY
         1,
         2
      ORDER BY
         3 DESC
   )
   sub1
GROUP BY
   1
ORDER BY
   2 DESC LIMIT 10;
