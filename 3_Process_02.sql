-- Select the database to use
USE google_news;

-- A table preview
SELECT* FROM gn_sept;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- The secondary process phase --
-- Checking for duplicates
SELECT *
FROM gn_sept
GROUP BY publishtime, publisher, category, link, title
HAVING COUNT(*) > 1;

-- Returning the duplicate by checking in reverse from the link
SELECT *
FROM gn_sept
WHERE link = 'https://news.google.com/articles/CBMidGh0dHBzOi8vbnlwb3N0LmNvbS8yMDIzLzA5LzI0L2phbWFpY2EtZGVjbGFyZXMtZGVuZ3VlLWZldmVyLW91dGJyZWFrLXdpdGgtaHVuZHJlZHMtb2YtY29uZmlybWVkLWFuZC1zdXNwZWN0ZWQtY2FzZXMv0gF4aHR0cHM6Ly9ueXBvc3QuY29tLzIwMjMvMDkvMjQvamFtYWljYS1kZWNsYXJlcy1kZW5ndWUtZmV2ZXItb3V0YnJlYWstd2l0aC1odW5kcmVkcy1vZi1jb25maXJtZWQtYW5kLXN1c3BlY3RlZC1jYXNlcy9hbXAv?hl=en-US&gl=US&ceid=US%3Aen';

-- Drop the Dengue duplicate
-- Adding a new column called 'id'
ALTER TABLE gn_sept
ADD id INT AUTO_INCREMENT PRIMARY KEY;

-- Deleting the big Dengue using its 'id' number
DELETE FROM gn_sept
WHERE id=13719;

-- Rechecking
SELECT* FROM gn_sept WHERE publisher='New York Post ' AND title='Jamaica declares Dengue fever outbreak with hundreds of confirmed and suspected cases';

-- Creating a new table 'news_sept' with the 5 original columns from 'gn_sept'
CREATE TABLE news_sept AS
SELECT publishtime, publisher, category, link, title
FROM gn_sept;

-- Checking the new table 'news_sept'
SELECT* FROM news_sept;

-- Rename 'gn_sept' to 'back_up_gn_sept', as it will not be used in the Analyze phase
RENAME TABLE gn_sept TO back_up_gn_sept;

-- Rename 'news_sept' to 'gn_sept', and use this new table with the old name in the Analyze phase to maintain consistency
RENAME TABLE news_sept TO gn_sept;

-- Final check
SELECT * FROM gn_sept;