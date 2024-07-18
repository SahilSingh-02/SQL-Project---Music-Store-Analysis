--SET-1
--Q1: Who is the senior most employee based on job title? 
		SELECT TOP 1 title, last_name, first_name 
		FROM employee
		ORDER BY levels DESC;

--Q2: Which countries have the most Invoices?
		SELECT billing_country, COUNT(*) AS total_invoice
		FROM invoice
		GROUP BY billing_country
		ORDER BY total_invoice DESC;

--Q3: What are top 3 values of total invoice? 
		SELECT TOP 3 total 
		FROM invoice
		ORDER BY total DESC;

--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
		SELECT TOP 1 billing_city,SUM(total) AS InvoiceTotal
		FROM invoice
		GROUP BY billing_city
		ORDER BY InvoiceTotal DESC;

--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
		SELECT TOP 1 c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spending
		FROM customer c
		JOIN invoice i ON c.customer_id = i.customer_id
		GROUP BY c.customer_id, c.first_name, c.last_name
		ORDER BY total_spending DESC;


--SET-2
--Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.
--Method 1 :
		SELECT DISTINCT email,first_name, last_name
		FROM customer c
		JOIN invoice i ON c.customer_id = i.customer_id
		JOIN invoice_line l ON i.invoice_id =l.invoice_id
		WHERE track_id IN(
			SELECT track_id FROM track t
			JOIN genre g ON t.genre_id = g.genre_id
			WHERE g.name LIKE 'Rock')
		ORDER BY email;

--Method 2 :
		SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, g.name AS Name
		FROM customer c
		JOIN invoice i ON i.customer_id = c.customer_id
		JOIN invoice_line l ON l.invoice_id = i.invoice_id
		JOIN track t ON t.track_id =l.track_id
		JOIN genre g ON g.genre_id = t.genre_id
		WHERE g.name LIKE 'Rock'
		ORDER BY email;

--Q2: Let's invite the artists who have written the most rock music in our dataset.Write a query that returns the Artist name and total track count of the top 10 rock bands. 
		SELECT TOP 10 s.artist_id, s.name,COUNT(s.artist_id) AS number_of_songs
		FROM track t
		JOIN album a ON a.album_id = t.album_id
		JOIN artist s ON s.artist_id = a.artist_id
		JOIN genre g ON g.genre_id = t.genre_id
		WHERE g.name LIKE 'Rock'
		GROUP BY s.artist_id,s.name
		ORDER BY number_of_songs DESC;

--Q3: Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
		SELECT name, milliseconds
		FROM track
		WHERE milliseconds > (
			SELECT AVG(milliseconds) AS avg_track_length
			FROM track )
		ORDER BY milliseconds DESC;


--SET-3
--Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
		WITH best_selling_artist AS (
			SELECT TOP 1 s.artist_id AS artist_id, s.name AS artist_name, SUM(l.unit_price*l.quantity) AS total_sales
			FROM invoice_line l
			JOIN track t ON t.track_id = l.track_id
			JOIN album a ON a.album_id = t.album_id
			JOIN artist s ON s.artist_id = a.artist_id
			GROUP BY s.artist_id,s.name
			ORDER BY total_sales DESC 
			)
		SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(l.unit_price*l.quantity) AS amount_spent
		FROM invoice i
		JOIN customer c ON c.customer_id = i.customer_id
		JOIN invoice_line l ON l.invoice_id = i.invoice_id
		JOIN track t ON t.track_id = l.track_id
		JOIN album a ON a.album_id = t.album_id
		JOIN best_selling_artist bsa ON bsa.artist_id = a.artist_id
		GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
		ORDER BY amount_spent DESC;

--Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.
		WITH popular_genre AS 
		(
			SELECT COUNT(l.quantity) AS purchases, c.country, g.name, g.genre_id, 
			ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(l.quantity) DESC) AS RowNo 
			FROM invoice_line l 
			JOIN invoice i ON i.invoice_id = l.invoice_id
			JOIN customer c ON c.customer_id = i.customer_id
			JOIN track t ON t.track_id = l.track_id
			JOIN genre g ON g.genre_id = t.genre_id
			GROUP BY c.country, g.name, g.genre_id
		)
		SELECT * FROM popular_genre WHERE RowNo <= 1



--Q3: Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount. 
		WITH Customter_with_country AS (
				SELECT c.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
				ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
				FROM invoice i
				JOIN customer c ON c.customer_id = i.customer_id
				GROUP BY c.customer_id,first_name,last_name,billing_country
				)
		SELECT * FROM Customter_with_country WHERE RowNo <= 1

