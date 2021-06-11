/*1. The poetry in this database is the work of children in grades 1 through 5.
a. How many poets (11,156 total) from each grade are represented in the data?
b. How many of the poets in each grade are Male and how many are Female? Only return the poets identified as Male or Female.
c. Do you notice any trends across all grades?*/

--1a.
SELECT COUNT (DISTINCT id), grade_id
FROM author
GROUP BY grade_id;
--1b. 
SELECT author.grade_id, gender.name AS gender, COUNT (DISTINCT author.id) 
FROM author
LEFT JOIN gender
ON author.gender_id = gender.id
GROUP BY author.grade_id, gender.name
HAVING gender.name = 'Female'
OR gender.name = 'Male'
ORDER BY grade_id;
--1c. Across all grade levels, the count of female poets is higher than the count of male poets for that grade.

/*2. Love and death have been popular themes in poetry throughout time. 
Which of these things do children write about more often?  Which do they have the most to say about when they do? 
Return the total number of poems, their average character count for poems that mention 'death' and poems that mention 'love'. 
Do this in a single query.*/
--2.Answer Kids write about love more often. But they have more to say about death. 
SELECT 'death' as theme, COUNT(id), (AVG(char_count))
FROM poem
WHERE text ILIKE '%death%'
OR title ILIKE '%death%'
UNION
SELECT 'love' as theme, COUNT(id), (AVG(char_count))
FROM poem
WHERE text ILIKE '%love%'
OR title ILIKE '%love%';


/*3. Do longer poems have more emotional intensity compared to shorter poems?
a. Start by writing a query to return each emotion in the database with its average intensity and character count.
	Which emotion is associated the longest poems on average?
	Which emotion has the shortest?
b. Convert the query you wrote in part 'a' into a CTE. Then find the 5 most intense poems that express joy and whether 
they are to be longer or shorter than the average joy poem.
	3b. part 2. What is the most joyful poem about?
	3b. part 3. Do you think these are all classified correctly?*/
--3a. Anger is longest. Joy is shortest.	
SELECT emotion.name, AVG(poem_emotion.intensity_percent) AS avg_intensity_perc, AVG(poem.char_count) AS avg_char_count
FROM poem_emotion
LEFT JOIN emotion
ON poem_emotion.emotion_id = emotion.id
LEFT JOIN poem
ON poem_emotion.poem_id = poem.id
GROUP BY emotion.name
ORDER BY avg_char_count DESC;
--3b. The top 5 most intense Joy poems tend to be shorter than the average Joy poem.
WITH emotion_intensity_length AS
					(SELECT poem_emotion.emotion_id, emotion.name, AVG(poem_emotion.intensity_percent) AS avg_intensity_perc, AVG(poem.char_count) AS avg_char_count
					FROM poem_emotion
					LEFT JOIN emotion
					ON poem_emotion.emotion_id = emotion.id
					LEFT JOIN poem
					ON poem_emotion.poem_id = poem.id
					GROUP BY emotion.name, poem_emotion.emotion_id
					ORDER BY avg_char_count DESC)
SELECT poem_emotion.poem_id, poem_emotion.intensity_percent, emotion.name, poem.char_count, eil.avg_char_count 
	FROM poem_emotion
	LEFT JOIN emotion
	ON poem_emotion.emotion_id = emotion.id
	LEFT JOIN poem
	ON poem_emotion.poem_id = poem.id
	LEFT JOIN emotion_intensity_length AS eil
	ON poem_emotion.emotion_id = eil.emotion_id
	WHERE emotion.name = 'Joy' 
	ORDER BY poem_emotion.intensity_percent DESC, poem.char_count DESC
	LIMIT 5;

--3b. part 2. What is the most joyful poem about? The most joyful poem is about the author's dog. It seems the dog's name is Dagwood.
SELECT title, text
FROM poem
WHERE id = 29675;
/*3b. part 3. Do you think these (Top 5 Joyful Poems) are all classified correctly? I do not. Poem ID 30476 is about Lightning scaring 
townspeople & destroying happiness. Poem ID 29590 is about darkness & depression. I do not think these two poems are classified correctly.*/
WITH emotion_intensity_length AS
					(SELECT poem_emotion.emotion_id, emotion.name, AVG(poem_emotion.intensity_percent) AS avg_intensity_perc, AVG(poem.char_count) AS avg_char_count
					FROM poem_emotion
					LEFT JOIN emotion
					ON poem_emotion.emotion_id = emotion.id
					LEFT JOIN poem
					ON poem_emotion.poem_id = poem.id
					GROUP BY emotion.name, poem_emotion.emotion_id
					ORDER BY avg_char_count DESC),
top_5_joyful AS
			(SELECT poem_emotion.poem_id, poem_emotion.intensity_percent, emotion.name, poem.char_count, eil.avg_char_count 
			FROM poem_emotion
			LEFT JOIN emotion
			ON poem_emotion.emotion_id = emotion.id
			LEFT JOIN poem
			ON poem_emotion.poem_id = poem.id
			LEFT JOIN emotion_intensity_length AS eil
			ON poem_emotion.emotion_id = eil.emotion_id
			WHERE emotion.name = 'Joy' 
			ORDER BY poem_emotion.intensity_percent DESC, poem.char_count DESC
			LIMIT 5)
SELECT top_5_joyful.poem_id, poem.title, poem.text
FROM top_5_joyful
LEFT JOIN poem
ON top_5_joyful.poem_id = poem.id; 
	
--4. Compare the 5 most angry poems by 1st graders to the 5 most angry poems by 5th graders.
WITH firstgrade AS
			(SELECT poem_emotion.poem_id, poem.author_id, author.grade_id, poem_emotion.intensity_percent, emotion.name, gender.name, poem.title, poem.text  
			FROM poem_emotion
			LEFT JOIN emotion
			ON poem_emotion.emotion_id = emotion.id
			LEFT JOIN poem
			ON poem_emotion.poem_id = poem.id
			LEFT JOIN author
			ON poem.author_id = author.id
			LEFT JOIN gender
			 ON author.gender_id = gender.id
			WHERE emotion.name = 'Anger' 
			AND author.grade_id = 1
			ORDER BY poem_emotion.intensity_percent DESC
			LIMIT 5),
fifthgrade AS 
			(SELECT poem_emotion.poem_id, poem.author_id, author.grade_id, poem_emotion.intensity_percent, emotion.name, gender.name, poem.title, poem.text  
			FROM poem_emotion
			LEFT JOIN emotion
			ON poem_emotion.emotion_id = emotion.id
			LEFT JOIN poem
			ON poem_emotion.poem_id = poem.id
			LEFT JOIN author
			ON poem.author_id = author.id
			 LEFT JOIN gender
			 ON author.gender_id = gender.id
			WHERE emotion.name = 'Anger' 
			AND author.grade_id = 5
			ORDER BY poem_emotion.intensity_percent DESC
			LIMIT 5)
SELECT *
FROM firstgrade
UNION
SELECT * 
FROM fifthgrade
ORDER BY intensity_percent DESC;
/* 4
a. Which group writes the angreist poems according to the intensity score? Fifth graders.
b. Who shows up more in the top five for grades 1 and 5, males or females? Female! 
c. Which of these do you like the best? Poem 566, Pie, written by a first grade female. Because I think
the smell of a pie attacking someone sounds cute*/

/*5. Emily Dickinson was a famous American poet, who wrote many poems in the 1800s, including one about a caterpillar that begins:
 > A fuzzy fellow, without feet,
 > Yet doth exceeding run!
 > Of velvet, is his Countenance,
 > And his Complexion, dun!
a. Examine the poets in the database with the name emily. Create a report showing the count of emilys by grade along with the 
distribution of emotions that characterize their work.
--b. Export this report to Excel and create a visualization that shows what you have found.*/

--The query below shows the count of Emilys by grade
SELECT COUNT(*) AS count_of_emilys, grade_id
FROM author
WHERE name ILIKE 'emily'
GROUP BY grade_id;
--The query below shows the distribution of emotions that characterize the work of the Emilys.
SELECT author.id AS author_id, author.name, author.grade_id, poem.id AS poemid, emotion.name
FROM author
LEFT JOIN poem
ON author.id = poem.author_id
LEFT JOIN poem_emotion
ON poem.id = poem_emotion.poem_id
LEFT JOIN emotion
ON poem_emotion.emotion_id = emotion.id
WHERE author.name ILIKE 'emily'
ORDER BY author.id, poemid;

