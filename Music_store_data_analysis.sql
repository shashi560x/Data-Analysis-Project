-- Q1. Finding the senior most employee based on designation.
select first_name, last_name, title, levels from employee
order by levels desc
limit 1;
--Madan Mohan, senior general manager, L7

--Q2. Finding the country having the highest invoices?
select * from invoice

select billing_country, count(*) as c
from invoice
group by billing_country
order by c desc
limit 2
-- USA being the 1st country having the most invoices of 131 and 2nd is Canada.
--Q3. finding the top 3 values from total.
select total from invoice
order by total desc
limit 3;
-- top 3 are 23.75, 19.8 and 19.8 respectively.
--Q4. which city has the best customers? In which city we made the most money?write a query 
--which return one city with total sum.
select * from invoice
select billing_city, sum(total) as s from invoice
group by billing_city
order by s desc
limit 1;
--prague is the city, where most albums are sold so the best customers belong to prague city.

--Q5. the best customer with respect to spending the most money on music is--
select * from customer
select * from invoice

select c.first_name, c.last_name, sum(i.total) as s from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by c.customer_id
order by s desc
limit 1;
-- R madhav is the customer who has spent the most on purchasing.
-- Q6. Write query to print email, first_name, last_name and genre of all rock music listners.
-- list ordered alphabetically by email starting by A. and also count them.
with ert as(
	select distinct first_name, last_name, email from customer
	join invoice on invoice.customer_id= customer.customer_id
	join invoice_line on invoice.invoice_id=invoice_line.invoice_id
	where track_id in
				(select track_id from track
				join genre on genre.genre_id=track.genre_id
				where genre.name like 'Rock')
	

order by email asc

)
select count(*) from ert
			
-- so we got the outcome and also counted it which is 59.
-- Q7. write a query to return the top 10 artists or band who have created the most "Rock" songs.
select * from artist
select * from genre
select * from album
select * from track

select artist.artist_id, artist.name, count(artist.artist_id) as num_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id= album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by num_of_songs desc
limit 10;
-- so we got the required result by this code
--Q8. return all the track names that have a song length longer than the average length.
--  return name and millisecond for each track in desc order.
select * from track

select name, milliseconds from track
where milliseconds >
			(select avg(milliseconds)
			 from track)
order by milliseconds desc;
	
--well we found out the tracks which are longer than the avg length of track in desc order.
-- Now if we want to know the exact number of tracks we can find that also using the code--

with how_much as (
select name, milliseconds from track
where milliseconds >
			(select avg(milliseconds)
			 from track)
order by milliseconds desc
	)
	select count(*) from how_much;

--which are 494 in numbers.
--Q9. write a query to return customer name, artist name and total spent money .

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1
/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

--I have analysed the data using some simple questions answers and found out lots of insights in the data.
--Thanking you !













