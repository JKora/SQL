use sakila;

show tables;
describe actor;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.

SELECT concat(first_name, ' ', last_name) AS actor FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

SELECT * FROM actor WHERE(first_name LIKE 'JOE');

-- 2b. Find all actors whose last name contain the letters GEN
SELECT * FROM actor WHERE (last_name LIKE '%GEN%');

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order
SELECT last_name, first_name FROM actor 
WHERE (last_name LIKE '%LI%') 
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country 
WHERE (COUNTRY IN ('Afghanistan', 'Bangladesh', 'China'));

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.
ALTER TABLE actor 
ADD COLUMN middle_name varchar(45) NULL AFTER first_name;


-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.

DESCRIBE actor;
ALTER TABLE actor 
CHANGE COLUMN middle_name middle_name BLOB NOT NULL ;

-- 3c. Now delete the middle_name column.

ALTER TABLE actor 
DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) AS countof FROM actor 
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) AS countof 
FROM actor
GROUP BY last_name
HAVING countof > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

-- use the below select query to find the actor_id (unique identifier).
select * from actor where last_name like 'WILLIAMS' ;
-- update the actor's first name where actor_id = 172
UPDATE actor 
SET first_name = 'HARPO' 
WHERE actor_id = 172 ;
-- last_name LIKE 'WILLIAMS' AND first_name LIKE 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, 
-- as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
-- (Hint: update the record using a unique identifier.)

UPDATE actor
SET    first_name = CASE WHEN 
					first_name = 'HARPO'
                    THEN 'GROUCHO' 
                    ELSE 'MUCHO GROUCHO' END
WHERE actor_id = 172;
 -- instead of actor_id in the where statement above u can also use the below condition
 -- last_name = 'WILLIAMS'AND first_name NOT IN ('SEAN', 'MORGAN')
 
-- 5a. You cannot locate the schema of the address table. 
--  Which query would you use to re-create it?
SHOW CREATE TABLE ADDRESS; -- this will show the create table used to create the address table.

-- or u can use the below query to create a copy (or replica) of address table.
CREATE TABLE new_table_name AS
    SELECT *
    FROM address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

SELECT S.staff_id, S.first_name, S.last_name, A.address FROM staff AS S
LEFT JOIN address AS A ON S.address_id
WHERE S.address_id = A.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment. 

SELECT sum(payment.amount) AS Total, staff.staff_id FROM payment
RIGHT JOIN staff ON staff.staff_id
WHERE payment.staff_id = staff.staff_id and payment.payment_date LIKE '2005-08%'
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

SELECT film.film_id, COUNT(film_actor.actor_id ) AS no_of_actors  FROM film
INNER JOIN film_actor ON film_actor.film_id
WHERE film.film_id = film_actor.film_id 
GROUP BY film.film_id;

-- another way to query the total number of actors for a film_id by just using film_actor table.
SELECT COUNT(actor_id), film_id FROM film_actor GROUP BY film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.film_id, film.title, COUNT(inventory.inventory_id) FROM film
LEFT JOIN inventory ON film.film_id
WHERE film.film_id = inventory.film_id AND film.title LIKE 'HUNCHBACK IMPOSSIBLE'
GROUP BY film.film_id;

-- Another way to find the number of copies of the film exist using Sub-query
SELECT count(*) as num_of_copies
FROM inventory
WHERE film_id IN
(
SELECT film_id
FROM film
WHERE title = 'HUNCHBACK IMPOSSIBLE'
);

-- Verify: find the film_id for the title from film table and query the inventory table for that film_id
SELECT COUNT(*) FROM INVENTORY WHERE FILM_ID = 439;

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
DESCRIBE payment;
DESCRIBE customer;

SELECT c.customer_id, c.last_name, c.first_name, sum(p.amount) AS TOTAL_PAID FROM customer c
LEFT JOIN payment p ON c.customer_id 
WHERE c.customer_id = p.customer_id
GROUP BY p.customer_id
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q 
-- whose language is English.

-- the first subquery in the main select statement, is used to retrieve the language_name from language
-- table.

SELECT title, language_id, (SELECT name 
							FROM language 
                            WHERE language.language_id = film.language_id
                            ) AS language_name 
FROM film 
-- the subquery for title IN retrieves the titles starting with Q and K
WHERE title IN (
				SELECT title FROM film
                WHERE title LIKE 'Q%' OR title LIKE 'K%'
                )
-- the last query for language_id retrieves the language_id for ENGLISH from Language table.
AND language_id = (
				SELECT language_id FROM language
                WHERE name = 'English'
                );

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name, actor_id FROM actor 
WHERE actor_id IN (
					SELECT actor_id FROM film_actor 
                    WHERE film_id =(
									SELECT film_id 
                                    FROM film 
                                    WHERE title = 'ALONE TRIP'
                                    )
                );

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customer c 
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city ON a.city_id = city.city_id
LEFT JOIN country cntry ON city.country_id = cntry.country_id
WHERE cntry.country = 'canada';
 
-- 7d. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.

-- using subqueries
SELECT film_id, title FROM film
WHERE film_id IN (
				SELECT film_id FROM film_category 
				WHERE category_id = (
									SELECT category_id FROM category 
									WHERE name = 'family'
                                    )
				);
                
-- using joins
SELECT f.film_id, f.title, fc.category_id, c.name
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT count(r.rental_id) AS rent_cnt, i.film_id
FROM rental r
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
GROUP BY i.film_id
ORDER BY rent_cnt desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT sum(p.amount) AS business_$, s.store_id FROM payment p
LEFT JOIN staff s ON p.staff_id = s.staff_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

-- using sub-queries
SELECT store_id, 
		(SELECT city FROM city 
			WHERE city_id IN (
							SELECT city_id FROM address
							WHERE address.address_id = store.address_id
							)
		) AS city,
        (SELECT country FROM country 
			WHERE country_id IN 
            ( SELECT country_id FROM city 
				WHERE city_id IN (
									SELECT city_id FROM address
									WHERE address.address_id = store.address_id
								) 
			)
		) AS country
															
FROM store;

-- using joins.
SELECT s.store_id, c.city, cntry.country
FROM store s
LEFT JOIN address a ON s.address_id = a.address_id
LEFT JOIN city c ON a.city_id = c.city_id
LEFT JOIN country cntry ON c.country_id = cntry.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)

SELECT fc.category_id, c.name, SUM(p.amount) AS gross_rev
FROM payment p 
LEFT JOIN rental r ON p.rental_id = r.rental_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film_category fc ON i.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE p.rental_id IS NOT NULL
GROUP BY fc.category_id
ORDER BY gross_rev DESC;
 
-- 8a. In your new role as an executive, 
-- you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW revenue_view AS

SELECT fc.category_id, c.name, SUM(p.amount) AS gross_rev
FROM payment p 
LEFT JOIN rental r ON p.rental_id = r.rental_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film_category fc ON i.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE p.rental_id IS NOT NULL
GROUP BY fc.category_id
ORDER BY gross_rev DESC;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM revenue_view;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW revenue_view;




