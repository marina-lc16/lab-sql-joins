-- Lab-sql-joins

USE sakila;

-- 1.- List the nfilm_idumber of films per category.
 
SELECT c.name as category, count(f.film_id) as number_of_films FROM sakila.category as c
JOIN sakila.film_category as f
ON c.category_id = f.category_id
GROUP BY c.name
ORDER BY number_of_films DESC;
 
/*
Let's see where is the data that we need:

- Number of films --> film_id (film_category)
- Category films -> category_id (film_category & category)
- Category name -> name (category)

First make the join with the common column and decide which table will be the left
SELECT * 
FROM sakila.category as c
JOIN sakila.film_category as f
ON c.category_id = f.category_id;

Once we have the table we can add the filters to get:
- Number of films per category
- Name of each category

So, first, create the filter: name + num of films (AGG=COUNT)
	SELECT c.name as category, count(f.film_id) as number_of_films

Then, we want to group the info a new column and order them by NAME and ORDER
	GROUP BY c.name
	ORDER BY number_of_films DESC;
*/

-- 2.- Retrieve the store ID, city, and country for each store.

/*
store: store_id / address_id
city: city / city_id / country_id
country: country / country_id
address: address_id / city_id
*/

# To start: check every table
SELECT*FROM sakila.store;
SELECT*FROM sakila.country;
SELECT*FROM sakila.city;

# First join: city table + country table to merge 'city' and 'country'
SELECT *
FROM sakila.city as c
JOIN sakila.country as co
ON c.country_id = co.country_id;

# Second join: country table + address table to get a table that contains "address_id" because is the string we need to merge the "store table"
# Third join: join total + store table, to finally, get the "store_id" 
SELECT s.store_id as store, c.city, co.country
FROM sakila.city as c
JOIN sakila.country as co
ON c.country_id = co.country_id
JOIN sakila.address as a
ON a.city_id = c.city_id
JOIN sakila.store as s
ON s.address_id = a.address_id;

-- 3.- Calculate the total revenue generated by each store in dollars.

select* from sakila.payment;

/*
Count the revenue (payment: amount)
	Payment table: amount / staff_id / customer_id
Group by: Store(store_id)
	Rental table: customer_id / staff_id / rental_id
    Store table: store_id / address_id
    Staff table: staff_id / store_id
Store: store_id
In dolars
*/

# Two joins
# 
# 
SELECT p.amount as revenue, s.store_id as store
FROM sakila.payment as p
JOIN sakila.staff as s
ON p.staff_id = s.staff_id
JOIN sakila.store as st
ON s.store_id = st.store_id;

# Now we can calculare Total revenue per store + in dollars
SELECT FORMAT(count(p.amount), 'C0', 'en-us') as total_revenue, st.store_id as store
FROM sakila.payment as p
JOIN sakila.staff as s
ON p.staff_id = s.staff_id
JOIN sakila.store as st
ON s.store_id = st.store_id
GROUP BY st.store_id;

-- 4.- Determine the average running time of films for each category.

/*
AVG the running time of films (film: length)
	Film: title / length / film_id
Group by: category(  )
	Category: category_id / name 
	Film category: film_id / category_id
*/

SELECT * FROM sakila.film;

SELECT*
FROM sakila.film as f
JOIN sakila.film_category as fc
ON f.film_id = fc.film_id;

SELECT c.name as category_name, round(AVG(f.length),2) as film_duration
FROM sakila.film as f
JOIN sakila.film_category as fc
ON f.film_id = fc.film_id
JOIN sakila.category as c
ON c.category_id = fc.category_id
GROUP BY c.name;

-- 5.- Identify the film categories with the longest average running time.

# We add a ORDER agg to the previous function 
SELECT c.name as category_name, round(AVG(f.length),2) as film_duration
FROM sakila.film as f
JOIN sakila.film_category as fc
ON f.film_id = fc.film_id
JOIN sakila.category as c
ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY film_duration DESC;


-- 6.- Display the top 10 most frequently rented movies in descending order.

SELECT * FROM sakila.rental;

/*
Rental: rental_id / inventory_id
Inventory: inventory_id / film_id
Film: film_id/ title
*/

# First join: <inventory> table and <rental> table to get rented movies data and their frequency
SELECT *
FROM sakila.inventory as i
JOIN sakila.rental as r
ON i.inventory_id = r.inventory_id;

# Second join: now we add <film> table to get the title of each movie 
# With the new database we can filter by title, and count the rentals per each, filtering per data and descending numebr of rentals
SELECT f.title as film_name, count(r.rental_id) as rentals
FROM sakila.inventory as i
JOIN sakila.rental as r
ON i.inventory_id = r.inventory_id
JOIN sakila.film as f
ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY rentals DESC
LIMIT 10;

-- 7.- Determine if "Academy Dinosaur" can be rented from Store 1.
/*
Film name
Inventory
Store

title = film_name --> sakila.film
film_id --> sakila.inventory and sakila.film
store_id --> sakila.inventory and sakila.store
inventory_id --> sakila.inventory and sakila.rental
*/

SELECT f.title as film_name, i.store_id as store, i.inventory_id as dispo
FROM sakila.inventory as i
JOIN sakila.film as f
ON i.film_id = f.film_id;

SELECT f.title as film_name, i.store_id as store, count(i.inventory_id) as dispo
FROM sakila.inventory as i
JOIN sakila.film as f
ON i.film_id = f.film_id
WHERE (f.title = 'ACADEMY DINOSAUR') AND (i.store_id = "1");


-- 8.- Provide a list of all distinct film titles, along with their availability status in the inventory. 
-- Include a column indicating whether each title is 'Available' or 'NOT available.' 
-- Note that there are 42 titles that are not in the inventory, 
-- and this information can be obtained using a CASE statement combined with IFNULL."

# See inside each table
SELECT * FROM sakila.film;
SELECT* FROM sakila.inventory;

SELECT count(distinct title) FROM sakila.film;
SELECT count(distinct film_id) FROM sakila.inventory;

/*
sakila.film: film_id, title, 
sakila.inventory: inventory_id, film_id
sakila.rental: rental_id, inventory_id
*/

-- # First left-join: we merge <film> table + <inventory> table to get the titles and their inventory data toghether

SELECT *
FROM sakila.film as f
LEFT JOIN sakila.inventory as i
ON i.film_id = f.film_id;

# Option 2 withouth duplicating the column film_id

SELECT *
FROM sakila.film as f
left JOIN sakila.inventory as i
USING (film_id);

SELECT title, film_id, inventory_id
FROM sakila.film 
left JOIN sakila.inventory 
USING (film_id);

SELECT 
    film_id,
    MAX(title),
    COUNT(inventory_id) AS 'number_of_copies',
    MAX(CASE
        WHEN inventory_id IS NULL THEN 'unavailable'
        ELSE 'available'
    END) AS rental_available
FROM
    film
        LEFT JOIN
    inventory USING (film_id)
GROUP BY film_id;

# The final function doens't work on macOs
