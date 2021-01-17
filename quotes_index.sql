-- Add quote index, quote ID and remove quotes shorter than 4 words.

CREATE TABLE "2020_11_27_PROJECT_QUOTES_FINAL" AS
SELECT 
    ID AS "article_ID"
    , ROW_NUMBER() OVER (PARTITION BY ID ORDER BY ID) AS "quote_index"
    , "pageDate"
    , "cit" AS "quote"
    , "url"
    , "source"
FROM "2020_11_27_PROJECT_QUOTES"
WHERE ARRAY_SIZE(SPLIT("cit", ' ')) > 4;

CREATE OR REPLACE TABLE "2020_11_27_PROJECT_QUOTES_FINAL" AS
SELECT 
    ("article_ID" || '_' || "quote_index") AS "quote_ID"
    , "article_ID"
    , "quote_index"
    , "pageDate"
    , "quote"
    , "url"
    , "source"
FROM "2020_11_27_PROJECT_QUOTES_FINAL";