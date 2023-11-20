-- Export table to create dashboard --
SELECT
    publishtime,
    publisher,
    GROUP_CONCAT(DISTINCT category ORDER BY category) AS categories,
    link,
    title
FROM gn_sept
GROUP BY publishtime, publisher, link, title;