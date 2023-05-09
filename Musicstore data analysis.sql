select * from `music-385404.msd.album`;
select * from `music-385404.msd.employee`;
select * from `music-385404.msd.artist`;
select * from `music-385404.msd.customer`;
select * from `music-385404.msd.genre`;
select * from `music-385404.msd.invoice`;
select * from `music-385404.msd.invoice_line`;
select * from `music-385404.msd.media_type`;
select * from `music-385404.msd.playlist`;
select * from `music-385404.msd.playlist_track`;
select * from `music-385404.msd.track`;



-- QUESTION SET 1 

-- Q1: Who is the senior most employee based on job title? 


select *
from `music-385404.msd.employee`
order by levels desc
limit 1;


--  Q2: Which countries have the most Invoices? 


select 
count(invoice_id)as cnt,
billing_country
from `music-385404.msd.invoice`
group by billing_country
order by cnt  desc;


--  Q3: What are top 3 values of total invoice? 


select 
distinct total
from `music-385404.msd.invoice`
order by total desc
limit 3;


--  Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals 


select 
billing_city,
sum(total) as total_sum
from `music-385404.msd.invoice`
group by billing_city
order by total_sum desc
limit 1;


--  Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.


select 
c.customer_id,
c.first_name,
c.last_name,
sum(i.total) as total_money_spent
from `msd.customer` c join `msd.invoice` i 
on c.customer_id = i.customer_id
group by 
c.customer_id,
c.first_name,
c.last_name
order by total_money_spent desc
limit 1;



-- QUESTION SET 2 

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


-- joins 
-- order by email

select 
distinct c.email,
c.first_name,
c.last_name,
g.name
from 
`msd.customer` c 
join `msd.invoice` i on c.customer_id = i.customer_id
join `msd.invoice_line` il on i.invoice_id = il.invoice_id
join `msd.track` t on  il.track_id = t.track_id
join `msd.genre` g on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

-- count.artist - written songs of genre=rock
-- join
-- select * from `msd.track`;
-- select * from `msd.album`;
-- select * from `msd.artist`;

with main as
(select 
t.track_id,
t.name,
t.genre_id,
t.album_id
from `msd.track` t
where t.genre_id = 1
)

select
artist.name,
count(artist.artist_id) as no_of_songs
from
main m 
join `msd.album` a on m.album_id = a.album_id
join `msd.artist` artist on artist.artist_id = a.artist_id
group by artist.name
order by no_of_songs desc
limit 10;


--  Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. 


-- avg(length of song)< length of song


select * from `msd.track`;

select
name,
milliseconds
from `msd.track`
where milliseconds > (select
avg(milliseconds) as average
from `msd.track`
) 
order by milliseconds desc;



-- QUESTION SET 3 


--  Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 


-- select * from `music-385404.msd.artist`;
-- select * from `music-385404.msd.customer`;
-- select * from `music-385404.msd.invoice`;
-- select * from `music-385404.msd.invoice_line`;
-- for sales multiply price by quantity
-- join artist output on other joins
-- refer notes again

with main as 
(
select 
artist.artist_id , 
artist.name,
sum(il.unit_price*il.quantity) as total_sales
from `msd.invoice_line` il
join `msd.track` t on t.track_id = il.track_id
join `msd.album` a on a.album_id = t.album_id
join `msd.artist` artist on artist.artist_id = a.artist_id
group by 1 ,2
limit 1
)
select 
c.customer_id, c.first_name, c.last_name,main.name, sum(il.unit_price*il.quantity) as amount_spent
from `msd.invoice` i
join `msd.customer` c on c.customer_id = i.customer_id
join `msd.invoice_line` il on il.invoice_id = i.invoice_id
join `msd.track` t on t.track_id = il.track_id
join `msd.album` a on a.album_id = t.album_id
join main on main.artist_id = a.artist_id
group by 1,2,3,4
order by  5 desc;







/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */



-- each country           =     most popular genre
--  most popular genre    =     max (count of purchases)
-- for  each country      =     their top genre


with main as 
(select 
i.billing_country,
g.genre_id,
g.name,
count(il.quantity) as purchases,
row_number() over (partition by i.billing_country order by count(il.quantity) desc ) as row_no
from 
`msd.invoice` i 
join `msd.invoice_line` il on i.invoice_id = il.invoice_id
join `msd.track` t on  il.track_id = t.track_id
join `msd.genre` g on t.genre_id = g.genre_id
group by 1,2,3
order by 1)
select 
billing_country,
name,
row_no 
from main
where 
row_no <= 1
;



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */



-- each country  - customer  -   spent max on music
--  country.......top customer .......amount spent


-- select * from `music-385404.msd.customer`;
-- select * from `music-385404.msd.invoice`;


with main as
(select 
customer_id,
billing_country,
sum (total) as total_spent,
row_number() over (partition by billing_country order by  sum(total) desc ) as row_no
from `music-385404.msd.invoice`
group by 1,2
) 
select *
from main
where row_no <= 1;
