// Connect tables and include only articles with keywords related to Russia in title
// only from 2014 on:

CREATE OR REPLACE TABLE PROJECT_ALL_RUSSIA_FINAL AS
SELECT * FROM
(SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" FROM idnes_kinda_clean
UNION ALL
SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" FROM sputnik_kinda_clean
UNION ALL
SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" FROM lidovky_kinda_clean
UNION ALL
SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" FROM aeronet_kinda_clean
UNION ALL
SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" FROM aktualne_kinda_clean
UNION ALL
SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" FROM irozhlas_kinda_clean
UNION ALL
SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" FROM novinky_kinda_clean
UNION ALL
SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" FROM parlamentnilisty_kinda_clean)
WHERE
"pageDate" >= '2014-01-01'
AND ("pageTitle" ILIKE '% rusk%'
OR "pageTitle" ILIKE '% ruští%'
OR "pageTitle" LIKE '%Rusk%'
OR "pageTitle" LIKE '%Ruští%'
OR "pageTitle" LIKE '%Rusové%'
OR "pageTitle" LIKE '%Rusů%'
OR "pageTitle" LIKE '%Rusy%'
OR "pageTitle" LIKE '%Rusech%'
OR "pageTitle" ILIKE '%moskv%'
OR "pageTitle" ILIKE '%moskev%'
OR "pageTitle" ILIKE '%putin%'
OR "pageTitle" ILIKE '%kreml%'
OR "pageTitle" ILIKE '%kremel%'
OR "pageTitle" ILIKE '%lavrov%'
OR "pageTitle" ILIKE '%koněv%'
OR "pageTitle" ILIKE '%medvěděv%'
OR "pageTitle" ILIKE '%skripal%'
OR "pageTitle" ILIKE '%lenin%'
OR "pageTitle" ILIKE '%stalin%'
OR "pageTitle" LIKE '%Kalašnikov%'
OR "pageTitle" ILIKE '%peskov%'
OR "pageTitle" ILIKE '%gagarin%'
OR "pageTitle" ILIKE '%chruščov%'
OR "pageTitle" ILIKE '%gorbač%'
OR "pageTitle" ILIKE '%jelcin%'
OR "pageTitle" ILIKE '%nikulin%'
OR "pageTitle" ILIKE '%navaln%'
OR "pageTitle" ILIKE '%gagarin%'
OR "pageTitle" ILIKE '%puškov%'
OR "pageTitle" ILIKE '%rosatom%'
OR "pageTitle" ILIKE '%gazprom%'
OR "pageTitle" ILIKE '%uaz%'
OR "pageTitle" ILIKE '%gagarin%'
OR "pageTitle" ILIKE '%roskosmos%'
OR "pageTitle" ILIKE '%šojg%'
OR "pageTitle" ILIKE '%litviněnk%'
OR "pageTitle" ILIKE '%chodorkovsk%'
OR "pageTitle" ILIKE '%rogozin%'
OR "pageTitle" ILIKE '%němcov%' AND "pageText" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%pravoslavn%' AND "pageText" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%noční vlk%' AND "pageText" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%noční vlc%' AND "pageText" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%nočních vlk%' AND "pageText" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%nočních vlc%' AND "pageText" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%nočními vlk%' AND "pageText" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%kuzněcov%'
OR "pageTitle" ILIKE '%jakunin%'
OR "pageTitle" ILIKE '%medinsk%'
OR "pageTitle" ILIKE '%politkovsk%'
OR "pageTitle" ILIKE '%krym%' AND "pageText" ILIKE '%rusk%')
;

--- 79 543 rows  

// Remove duplicates (subset source-date-pageTitle)

CREATE OR REPLACE TABLE PROJECT_ALL_RUSSIA_FINAL AS
SELECT "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source"
       , ROW_NUMBER() OVER (PARTITION BY "source", "pageDate", "pageTitle" ORDER BY "source") AS row_number
FROM PROJECT_ALL_RUSSIA_FINAL
QUALIFY row_number = 1;

--- 52 564 rows

// Create ID
CREATE OR REPLACE TABLE PROJECT_ALL_RUSSIA_FINAL AS
SELECT ROW_NUMBER() OVER(ORDER BY "source") AS "rowNum"
       , "pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source" 
FROM PROJECT_ALL_RUSSIA_FINAL;

CREATE OR REPLACE TABLE PROJECT_ALL_RUSSIA_FINAL AS
SELECT CONCAT("source", '_', "rowNum") AS ID
       ,"pageAuthor", "pageDate", "pageOpener", "pageSection", "pageText", "pageTitle", "url", "source"
FROM PROJECT_ALL_RUSSIA_FINAL;

--- 52 564 rows