select * from netflix;
select count(*) as total_content from netflix;   --8807 rows
-- The data is already cleaned in this table 
-- therefore starting to solve the business problems directly 

-- Question-1
--Count the number of Movies vs TV Shows
select type, count(type) as total from netflix
group by type;  

-- Question-2
--Find the most common rating for movies and TV shows
select * from (select type, rating, count(rating) as common_rating,
rank() over(partition by type order by count(rating) desc) as ranking
from netflix
group by type,rating
order by type,count(rating) desc
) where ranking=1;

-- Question-3
--List all movies released in a specific year (e.g., 2020)
select * from netflix 
where type='Movie'
and release_year=2020;

--	question-4
-- Find the top 5 countries with the most content on Netflix
select count(show_id) as content,
unnest(string_to_array(country, ',')) as new_country 
from netflix
group by 2
order by 1 desc
limit 5;

--QUESTION-5
-- Identify the longest movie
SELect type,title, duration from netflix 
where type= 'Movie'
and duration= (select max(duration) from netflix);
-- ALTERNATE APPROACH
select type,title, duration,
dense_rank() over(partition by duration order by duration desc) 
from netflix 
where type='Movie'
and duration is not null;

--QUESTION-6 
--Find content added in the last 5 years
select count(*) from select * 
from netflix
where 
to_date(date_added, 'month dd, yyyy') >= current_date - interval '5 years';

--	QUESTION-7 
--Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM NETFLIX
WHERE DIRECTOR ilike '%Rajiv Chilaka%';

--QUESTION-8 
--List all TV shows with more than 5 seasons
SELECT type, title,duration FROM NETFLIX
where type= 'TV Show'
and 
duration >'5%'
-- BETTER WAY TO SOLVE THE QUERY 
select type, title,duration from netflix 
where split_part(duration,' ',1)::numeric >5
and type='TV Show';

--QUESTION-9
--Count the number of content items in each genre
select unnest(string_to_array(listed_in,',')), count(*)  from netflix
group by 
unnest(string_to_array(listed_in,',')) 
order by 1;

--QUESTION-10
--Find each year and the average numbers of content release in India on netflix. 
select year, (round(((count(show_id)::numeric)/(
select count(show_id) from (
select show_id,
extract(year from to_date(date_added, 'Month dd, yyyy'))as year,
unnest(string_to_array(country,','))
as new_country 
from netflix
)
where new_country= 'India' 
)):: numeric,4))*100||'%' as average
from (
select show_id,
extract(year from to_date(date_added, 'Month dd, yyyy'))as year,
unnest(string_to_array(country,','))
as new_country 
from netflix
)
where new_country ilike 'India' 
group by year
order by year desc;

--QUESTION-11
--List all movies that are documentaries
select * from netflix
where type= 'Movie'
and 
listed_in ilike 'documentaries';

--QUESTION-12 
--Find all content without a director
select * from netflix 
where director is null;

--	QUESTION-13
-- Find how many movies actor 'Salman Khan' appeared in last 10 years!
select title, release_year from netflix 
where netflix.cast ilike '%salman khan%'
and to_date(date_added, 'month dd,yyyy') >= current_date - interval '10 years'
order by release_year desc;

--QUESTION-14
--Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
unnest(string_to_array(netflix.cast,',')) as actors,
count(*) as total_movies
FROM NETFLIX 
WHERE country ilike '%india%'
and type='Movie'
group by actors 
order by 2 desc 
limit 10;

--QUESTION 15
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
with new_table 
as (
SELECT *,
case 
	when
	description ilike '%kill%'
or description ilike '%violence%'
then 'Bad_content'
else 'Good_content'
end content_type 
FROM NETFLIX 
)

select content_type, count(*) as total_content 
from new_table
group by content_type;

