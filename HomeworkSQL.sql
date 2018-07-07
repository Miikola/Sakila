use sakila;

-- 1a. Display the first and last names of all actors.

SELECT first_name, last_name
FROM sakila.actor;

-- 1b. Display the first and last names of all actors.

SELECT concat(upper(first_name), ' ', upper(last_name)) as actor_name
FROM sakila.actor;

-- 2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe".
SELECT actor_id, first_name, last_name 
FROM sakila.actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters 'GEN'.

SELECT * 
FROM sakila.actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. Order these selected by last name.

SELECT 
last_name,
first_name
FROM sakila.actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China.

SELECT 
country_id, country
FROM sakila.country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor.

ALTER TABLE sakila.actor
ADD middle_name VARCHAR(40) NOT NULL AFTER first_name;


-- 3b. Change the data type of the middle_name column to blobs.

ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;

-- 3c. Delete middle_name column.

ALTER TABLE actor 
DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*)
FROM sakila.actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

SELECT last_name, COUNT(*)
FROM sakila.actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";


-- 4d. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error.

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO';

select * 
from actor 
where last_name = "WILLIAMS";


-- 5a. Locate the scheme of the 'address' table.

SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 

SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.

SELECT staff.staff_id, SUM(payment.amount) AS 'August_2005_Amount'
FROM staff 
JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY staff_id;

-- 6c.  List each film and the number of actors who are listed for that film.

SELECT film_actor.film_id, COUNT(*)
FROM film_actor 
INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film_id;

-- 6d. Count how many copies of the film 'Hunchback Impossible' exist in the inventory system.

SELECT f.title, COUNT(f.film_id)
FROM film f
JOIN inventory i on f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name.

SELECT customer.last_name, SUM(payment.amount) AS 'Total_Customer_Payment_Amount'
FROM customer
JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY customer.last_name
ORDER BY customer.last_name ASC;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE language_id IN
(
	SELECT language_id
    FROM language
	WHERE language_id = 1
    )
    AND title LIKE 'Q%' OR title LIKE 'K%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN
    (
		SELECT film_id
		FROM film
		WHERE title = 'ALONE TRIP'
		)
);

-- 7c. Retrieve the names and email addresses of all Canadian customers.

SELECT first_name, last_name, email
FROM customer
INNER JOIN address ON
customer.address_id = address.address_id
INNER JOIN city ON
address.city_id = city.city_id
INNER JOIN country ON
country.country_id = city.country_id
WHERE country = 'CANADA';

-- 7d. Identify all movies categorized as family films.

SELECT title
FROM film
WHERE film_id IN
(
	SELECT film_id
    FROM film_category
    WHERE category_id IN
    (
		SELECT category_id
		FROM category
		WHERE name = 'Family'
		)
);

-- 7e. Display the most frequently rented movies in descending order.

SELECT i.film_id, film.title, COUNT(*) AS 'rental_count'
FROM rental r
INNER JOIN inventory i ON
r.inventory_id = i.inventory_id
INNER JOIN film ON
i.film_id = film.film_id
GROUP BY film_id
ORDER BY COUNT(*) DESC;

-- 7f. Display how much business, in dollars, each store brought in.
SELECT store.store_id, sum(payment.amount) as Total_Payment
FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
INNER JOIN store ON customer.store_id = store.store_id
GROUP BY store.store_id;

-- 7g. Display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order.

SELECT category.name, SUM(payment.amount) AS Total_Category_Revenue
FROM payment
INNER JOIN rental on payment.rental_id = rental.rental_id
INNER JOIN inventory on rental.inventory_id = inventory.inventory_id
INNER JOIN film on inventory.film_id = film.film_id
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category on category.category_id = film_category.category_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC limit 5;


-- 8a. Use the solution from the problem above to create a view.

CREATE VIEW top_five_genres AS
SELECT name, Total_Category_Revenue
FROM
SELECT category.name, SUM(payment.amount) AS Total_Category_Revenue
FROM payment
INNER JOIN rental on payment.rental_id = rental.rental_id
INNER JOIN inventory on rental.inventory_id = inventory.inventory_id
INNER JOIN film on inventory.film_id = film.film_id
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category on category.category_id = film_category.category_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC limit 5;

-- 8b. Display the view that you created in 8a.

SELECT * FROM top_five_genres;

-- 8c. Write a query to delete the view 'top_five_genres'.
 
 DROP VIEW top_five_genres;



 





