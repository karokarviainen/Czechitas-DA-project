// Karolína - čištění Sputnik.

SELECT 'sputnik' || TRIM(SPLIT("pageDate", ' ')[1]) || "pageTitle" AS "ID"
, "pageAuthor"
, TRIM(SPLIT("pageDate", ' ')[1]) AS "pageDate"
, *
, 'Sputnik' AS "source"
FROM "sputnik"
WHERE "pageText" <> '' -- 68352 rows
AND "pageText" ILIKE '%rusk%' -- 28883 rows
LIMIT 10
;


SELECT DISTINCT('sputnik' || TRIM(SPLIT("pageDate", ' ')[1]) || TRIM(SPLIT("pageTitle", '- Sputnik Česká republika')[0])) AS "ID" -- 28883
, "pageAuthor"
, TRIM(SPLIT("pageDate", ' ')[1]) AS "pageDate"
, "pageOpener"
, "pageSection"
, "pageText"
, TRIM(SPLIT("pageTitle", '- Sputnik Česká republika')[0]) AS "pageTitle"
, "url"
, 'Sputnik' AS "source"
FROM "sputnik"
WHERE "pageText" <> ''-- 68352 rows
AND "pageTitle" <> ''
AND "pageDate" <> ''
AND "pageText" ILIKE '%rusk%' -- 28883 rows
;