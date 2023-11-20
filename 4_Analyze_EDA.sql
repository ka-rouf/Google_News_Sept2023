-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- EDA -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Questions List:
-- 1. What is the total number of Google News articles in September 2023?  -exact number at the top dashboard
-- 2. How many publishers are included in the dataset? -exact number at the top dasboard
-- 3. What is the distribution of Google News articles in September 2023 by each publisher? -bar graph
-- 4. How are Google News articles distributed across different categories in September 2023? (Ignoring the fact that news articles can belong to multiple categories) -pie graph
-- 5. How many news articles have two or more categories? -exact number at the top dasboard
-- 6. What is the distribution of category combinations? - pie or bar graph
-- 7. How does the number of news articles vary over the course of the month? -line graph
-- 8. What is the average number of news articles per day in September? -exact number at the top dasboard
-- 9. What is the average number of words used in article titles for each publisher? (MySQL only)
-- 10. What is the average number of words used in article titles for each category? (Articles can belong to two categories) (MySQL only)
-- 11. How do the top 20 longest news article titles look? (MySQL only)
-- 12. How many news articles have titles with more than 18 words? -exact number at the top
-- 13. Which are the top 100 most frequently used words in article titles? -bar graph
-- 14. What are the top 100 most frequently used words in article titles? (Excluding the 100 most common words according to Wikipedia and any special characters or punctuation marks)
-- 15. Which publishers are common in specific categories? (MySQL only)

-- Show the full records, ordered from the latest articles
SELECT * FROM gn_sept ORDER BY publishtime DESC;

-- Show the full records, ordered from the oldest articles
SELECT * FROM gn_sept ORDER BY publishtime;

-- 1. What is the total number of Google News articles in September 2023?
-- Use distinct link
SELECT COUNT(DISTINCT(link)) AS total_articles FROM gn_sept;

-- Use distinct publishtime, publisher, link, title (combination)
SELECT COUNT(*) AS total_articles
FROM (
	SELECT DISTINCT publishtime, publisher, link, title
	FROM gn_sept
) AS distinct_news;

-- 2. How many publishers are included in the dataset? -exact number at the top dasboard
SELECT COUNT(DISTINCT(publisher)) AS total_publishers FROM gn_sept;

-- 3. What is the distribution of Google News articles in September 2023 by each publisher?
-- Number of articles for each publisher (INCORRECT)
SELECT publisher, COUNT(*) AS number_of_articles
FROM gn_sept
GROUP BY publisher
ORDER BY number_of_articles DESC; -- Delete 'DESC' to order from smallest number

-- Number of articles for each publisher (CORRECT)
SELECT publisher, COUNT(*) AS number_of_articles
FROM (
    SELECT DISTINCT publishtime, publisher, link, title
    FROM gn_sept
) AS distinct_news
GROUP BY publisher
ORDER BY number_of_articles DESC; -- Delete 'DESC' to order from smallest number


-- 4. How are Google News articles distributed across different categories in September 2023? 
-- Ignoring the fact that news articles can belong to multiple categories
SELECT category, COUNT(category) AS number_of_articles
FROM gn_sept
GROUP BY category
ORDER BY number_of_articles DESC;

-- Not ignoring the fact that news articles can belong to multiple categories
SELECT A.categories, COUNT(*) AS number_of_articles
FROM (
    SELECT
        publishtime,
        publisher,
        GROUP_CONCAT(DISTINCT category ORDER BY category) AS categories,
        link,
        title
    FROM gn_sept
    GROUP BY publishtime, publisher, link, title
) AS A
GROUP BY A.categories
ORDER BY number_of_articles DESC;

-- 5. How many news articles have two or more categories?
-- -- List
SELECT title, GROUP_CONCAT(DISTINCT category ORDER BY category) AS categories
FROM gn_sept
GROUP BY title
HAVING COUNT(DISTINCT category) >= 2;
-- -- Exact number
SELECT COUNT(*) AS number_of_articles
FROM (
    SELECT title
    FROM gn_sept
    GROUP BY title
    HAVING COUNT(DISTINCT category) >= 2
) AS articles_with_multiple_categories;

-- 6. What is the distribution of category combinations?
SELECT category_combination, COUNT(*) AS number_of_articles
FROM (
    SELECT GROUP_CONCAT(DISTINCT category ORDER BY category) AS category_combination
    FROM gn_sept
    GROUP BY title
    HAVING COUNT(DISTINCT category) >= 2
) AS subquery
GROUP BY category_combination
ORDER BY number_of_articles DESC;

-- 7. How does the number of news articles vary over the course of the month?
SELECT DATE(publishtime) AS publishdate, COUNT(*) AS number_of_articles_by_date
FROM (                                                       -- This is
    SELECT DISTINCT publishtime, publisher, link, title      -- to exclude
    FROM gn_sept                                             -- duplicate
) AS distinct_news                                           -- news articles
GROUP BY publishdate
ORDER BY publishdate;

-- 8. What is the average number of news articles per day in September? 
-- 'ROUND' is used because it is common to have whole numbers of articles published per day
SELECT ROUND(COUNT(*) /  COUNT(DISTINCT(DATE(publishtime))), 0) AS avg_articles_per_day
FROM (                                                       -- This is
    SELECT DISTINCT publishtime, publisher, link, title      -- to exclude
    FROM gn_sept                                             -- duplicate
) AS distinct_news;                                          -- news articles

-- 9. What is the average number of words used in article titles for each publisher?
SELECT publisher, COUNT(publisher) AS articles,
       ROUND(AVG(LENGTH(title) - LENGTH(REPLACE(title, ' ', '')) + 1),2) AS avg_words,
       ROUND(AVG(LENGTH(title) - LENGTH(REPLACE(title, ' ', '')) + 1),0) AS rounded_avg
FROM (
    SELECT DISTINCT publishtime, publisher, link, title
    FROM gn_sept
) AS distinct_news
GROUP BY publisher
ORDER BY COUNT(publisher) DESC;

-- 10. What is the average number of words used in article titles for each category? (Articles can belong to two categories)
SELECT category, COUNT(category) AS articles,
       ROUND(AVG(LENGTH(title) - LENGTH(REPLACE(title, ' ', '')) + 1),2) AS avg_words, 
       ROUND(AVG(LENGTH(title) - LENGTH(REPLACE(title, ' ', '')) + 1),0) AS rounded_avg
FROM gn_sept
GROUP BY category;

-- 11. How do the top 20 longest news article titles look?
SELECT publisher, category, LENGTH(title) AS num_chars, 
	LENGTH(title) - LENGTH(REPLACE(title, ' ', '')) + 1 AS num_words, title, link
FROM gn_sept
ORDER BY LENGTH(title) DESC LIMIT 20;

-- 12. How many news articles have titles with more than 18 words?
SELECT COUNT(DISTINCT publishtime, publisher, link, title) AS num_of_articles
FROM gn_sept
WHERE LENGTH(title) - LENGTH(REPLACE(title, ' ', '')) + 1 > 18 ;

-- 13. Which are the top 100 most frequently used words in article titles?
SELECT word, COUNT(*) AS word_count
FROM (
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(title, ' ', n), ' ', -1) AS word
    FROM (
		SELECT DISTINCT publishtime, publisher, link, title
		FROM gn_sept
	) AS distinct_news
    JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35 UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40 UNION SELECT 41 UNION SELECT 42) AS numbers
    WHERE CHAR_LENGTH(title) - CHAR_LENGTH(REPLACE(title, ' ', '')) >= n - 1
) AS words
GROUP BY word
ORDER BY word_count DESC
LIMIT 100;

-- 14. What are the top 100 most frequently used words in article titles? (Excluding the 100 most common words according to Wikipedia and any special characters or punctuation marks)
SELECT word, COUNT(*) AS word_count
FROM (
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(title, ' ', n), ' ', -1) AS word
    FROM (
		SELECT DISTINCT publishtime, publisher, link, title
		FROM gn_sept
	) AS distinct_news
    JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35 UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40 UNION SELECT 41 UNION SELECT 42) AS numbers
    WHERE CHAR_LENGTH(title) - CHAR_LENGTH(REPLACE(title, ' ', '')) >= n - 1
) AS words
WHERE word NOT IN ('the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'I',
    'it', 'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at',
    'this', 'but', 'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she',
    'or', 'an', 'will', 'my', 'one', 'all', 'would', 'there', 'their', 'what',
    'so', 'up', 'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me',
    'when', 'make', 'can', 'like', 'time', 'no', 'just', 'him', 'know', 'take',
    'people', 'into', 'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other',
    'than', 'then', 'now', 'look', 'only', 'come', 'its', 'over', 'think', 'also',
    'back', 'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well', 'way',
    'even', 'new', 'want', 'because', 'any', 'these', 'give', 'day', 'most', 'us',
    'The', 'Be', 'To', 'Of', 'And', 'A', 'In', 'That', 'Have', 'I',
    'It', 'For', 'Not', 'On', 'With', 'He', 'As', 'You', 'Do', 'At',
    'This', 'But', 'His', 'By', 'From', 'They', 'We', 'Say', 'Her', 'She',
    'Or', 'An', 'Will', 'My', 'One', 'All', 'Would', 'There', 'Their', 'What',
    'So', 'Up', 'Out', 'If', 'About', 'Who', 'Get', 'Which', 'Go', 'Me',
    'When', 'Make', 'Can', 'Like', 'Time', 'No', 'Just', 'Him', 'Know', 'Take',
    'People', 'Into', 'Year', 'Your', 'Good', 'Some', 'Could', 'Them', 'See', 'Other',
    'Than', 'Then', 'Now', 'Look', 'Only', 'Come', 'Its', 'Over', 'Think', 'Also',
    'Back', 'After', 'Use', 'Two', 'How', 'Our', 'Work', 'First', 'Well', 'Way',
    'Even', 'New', 'Want', 'Because', 'Any', 'These', 'Give', 'Day', 'Most', 'Us',
    '|', '-', '&', '–', '—', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'
)
GROUP BY word
ORDER BY word_count DESC
LIMIT 100;

-- 15. Which publishers are common in specific categories?
WITH TopPublishers AS (
   SELECT publisher, COUNT(*) AS publisher_count
   FROM (SELECT DISTINCT publishtime, publisher, link, title FROM gn_sept) AS A
   GROUP BY publisher
   ORDER BY publisher_count DESC
   LIMIT 20     -- Edit to adjust the range 10, 20, 30, 50, 100, 200 --
)
SELECT T.publisher, C.category, 
      COUNT(*) AS _count,
      ROUND(COUNT(*) / T.publisher_count * 100, 2) AS percentage
FROM gn_sept AS C
JOIN TopPublishers AS T ON C.publisher = T.publisher
GROUP BY T.publisher, C.category
ORDER BY percentage DESC;

