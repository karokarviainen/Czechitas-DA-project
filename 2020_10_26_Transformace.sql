// AERONET:
--- Create table aeronet_copy, add columns row_nr, author, date, opener (WHERE "pageText" <> '')

CREATE OR REPLACE TABLE aeronet_copy AS
SELECT CASE WHEN "pageText" LIKE '%Pozorovatelka%' THEN 'Pozorovatelka'
            WHEN "pageText" LIKE '%Jiří B%' OR "pageText" LIKE '%B a ť a%' THEN 'Jiří Baťa'
            WHEN "pageText" LIKE '%-MarekM-%' THEN 'MarekM'
            WHEN "pageText" LIKE '%Šéfredaktor AE News%' OR "pageText" LIKE '%V.K.%' OR "pageText" LIKE '%-VK-%' THEN 'VK/Šéfredaktor AE News'
            WHEN "pageText" LIKE '%Svatoslav Kontroš%' THEN 'Svatoslav Kontroš'
            WHEN "pageText" LIKE '%Petr Cvalín%' THEN 'Petr Cvalín'
            WHEN "pageText" LIKE '%Administrator%' OR "pageText" LIKE '%-Admin-%' THEN 'Admin/Administrator'
            WHEN "pageText" LIKE '%-Redakce AE News-%' THEN 'Redakce AE News'
            WHEN "pageText" LIKE '%-SKReport-%' THEN 'SKReport'
            WHEN "pageText" LIKE '%Valerij X%' THEN 'Valerij X'
            WHEN "pageText" LIKE '%Vladimír Kapal%' THEN 'Vladimír Kapal'
            WHEN "pageText" LIKE '%Namibudoucim%' THEN 'Namibudoucim'
            WHEN "pageText" LIKE '%Radola Rys%' THEN 'Radola Rys'
            WHEN "pageText" LIKE '%Václav Kytička%' THEN 'Václav Kytička'
       ELSE 'Other/Unknown'
       END AS author
       , SPLIT("pageDate", ', ')[1] as rok
       , SPLIT(SPLIT("pageDate", ', ')[0], ' ')[0] AS mesic_txt
       , SPLIT(SPLIT("pageDate", ', ')[0], ' ')[1] AS den
       , CASE WHEN mesic_txt = 'Led' THEN '01'
              WHEN mesic_txt = 'Úno' THEN '02'
              WHEN mesic_txt = 'Bře' THEN '03'
              WHEN mesic_txt = 'Dub' THEN '04'
              WHEN mesic_txt = 'Kvě' THEN '05'
              WHEN mesic_txt = 'Čvn' THEN '06'
              WHEN mesic_txt = 'Čvc' THEN '07'
              WHEN mesic_txt = 'Srp' THEN '08'
              WHEN mesic_txt = 'Zář' THEN '09'
              WHEN mesic_txt = 'Říj' THEN '10'
              WHEN mesic_txt = 'Lis' THEN '11'
              WHEN mesic_txt = 'Pro' THEN '12'
          END AS mesic
          , CASE WHEN "pageOpener" = '' THEN "pageTitle"
            ELSE "pageOpener"
            END AS opener
          , DATE_FROM_PARTS(rok, mesic, den) AS date
          , ROW_NUMBER() OVER(ORDER BY date) AS row_nr
          , *
FROM aeronet
WHERE "pageText" <> ''
;

--- Add column "source"

ALTER TABLE aeronet_copy ADD COLUMN "source" varchar(255);

UPDATE aeronet_copy SET "source" = 'aeronet';

--- Create "kinda clean" table (Russia)

CREATE OR REPLACE TABLE aeronet_kinda_clean AS
SELECT   author AS "pageAuthor"
       , date as "pageDate"
       , opener AS "pageOpener"
       , "pageSection"
       , "pageText"
       , "pageTitle"
       , "url"
       , "source"
FROM aeronet_copy 
WHERE "pageTitle" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%putin%'
OR "pageTitle" ILIKE '%moskv%'
OR "pageTitle" ILIKE '%moskev%'
OR "pageTitle" ILIKE '%kreml%'
OR "pageTitle" ILIKE '%kremel%';

--- Trim "pageTitle"

CREATE OR REPLACE TABLE aeronet_kinda_clean AS
(SELECT 
 "pageAuthor"
,"pageDate"
,"pageOpener"
,"pageSection"
,"pageText"
,TRIM(SPLIT("pageTitle", '!')[0]) AS "pageTitle"
,"url"
,"source"
FROM aeronet_kinda_clean
WHERE "pageText" <> ''
AND "pageTitle" LIKE '%!%'
UNION ALL
SELECT 
 "pageAuthor"
,"pageDate"
,"pageOpener"
,"pageSection"
,"pageText"
,TRIM(SPLIT("pageTitle", '.')[0]) AS "pageTitle"
,"url"
,"source"
FROM aeronet_kinda_clean
WHERE "pageText" <> ''
AND "pageTitle" NOT LIKE '%!%')
;

-- 583 rows

// AKTUALNE:
--- Create table aktualne_copy, add columns date, row_nr (WHERE "pageText" <> '')

CREATE OR REPLACE TABLE aktualne_copy AS
SELECT REPLACE("pageDate", 'Aktualizováno ') AS date_replaced
       , SPLIT(LEFT(date_replaced, 12), '.') AS pagedate_split  
       , LEFT(SPLIT(LEFT(date_replaced, 12), '.')[2], 5) AS rok
       , SPLIT(LEFT(date_replaced, 12), '.')[1] AS mesic
       , SPLIT(LEFT(date_replaced, 12), '.')[0] AS den
       , DATE_FROM_PARTS(rok, mesic, den) AS date
       , ROW_NUMBER() OVER(ORDER BY date) AS row_nr
       , *        
FROM aktualne
WHERE rok IS NOT NULL
      AND mesic IS NOT NULL
      AND den IS NOT NULL
      AND "pageText" <> '';

--- Add column "source"

ALTER TABLE aktualne_copy ADD COLUMN "source" varchar(255);

UPDATE aktualne_copy SET "source" = 'aktualne';

--- Create "kinda clean" table (Russia)

CREATE OR REPLACE TABLE aktualne_kinda_clean AS
SELECT 
         "pageAuthor"
       , date AS "pageDate"
       , "pageOpener"
       , "pageSection"
       , "pageText"
       , "pageTitle"
       , "url"
       , "source"
FROM aktualne_copy
WHERE "pageTitle" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%putin%'
OR "pageTitle" ILIKE '%moskv%'
OR "pageTitle" ILIKE '%moskev%'
OR "pageTitle" ILIKE '%kreml%'
OR "pageTitle" ILIKE '%kremel%'
;

-- 5 743 rows

//IDNES:

// 1) Make copy of the original table 2) Remove rows with empty text
// 3) Make column "source" 4) Remove excessive stuff from "pageAuthor"
// 5) Remove excessive stuff from "pageTitle" 6) Remove days names from "pageDate":
CREATE OR REPLACE TABLE idnes_copy AS
SELECT 
    REPLACE(REPLACE("pageAuthor", 'Autoři: '), 'Autor: ') AS "pageAuthor" 
    , REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("pageDate", 'neděle'), 'sobota'), 'pátek'), 'čtvrtek'), 'středa'), 'úterý'), 'pondělí') AS "pageDate"
    , "pageOpener"
    , "pageSection"
    , "pageText"
    , REPLACE("pageTitle", ' - iDNES.cz') AS "pageTitle"
    , "url"
    , 'idnes' AS "source"
FROM idnes
WHERE "pageText" <> ''
;

// 7) Handle the date (part2):
CREATE OR REPLACE TABLE idnes_copy AS
SELECT 
     "pageAuthor"
    , TRIM(SPLIT(TRIM("pageDate"), ' ')[0]) AS day
    , TRIM(SPLIT(TRIM("pageDate"), ' ')[1]) AS month
    , TRIM(SPLIT(TRIM("pageDate"), ' ')[2]) AS year
    , "pageOpener"
    , "pageSection"
    , "pageText"
    , "pageTitle"
    , "url"
    , "source"
FROM idnes_copy 
WHERE day NOT LIKE 'aktualizováno' AND day NOT LIKE 'před' AND LENGTH(year) >= 4;

// 8) Handle the date (part 3):
CREATE OR REPLACE TABLE idnes_copy AS
SELECT
     "pageAuthor"
    , day
    , month
    , CASE WHEN month = 'ledna' THEN '01.'
              WHEN month = 'února' THEN '02.'
              WHEN month = 'března' THEN '03.'
              WHEN month = 'dubna' THEN '04.'
              WHEN month = 'května' THEN '05.'
              WHEN month = 'června' THEN '06.'
              WHEN month = 'července' THEN '07.'
              WHEN month = 'srpna' THEN '08.'
              WHEN month = 'září' THEN '09.'
              WHEN month = 'října' THEN '10.'
              WHEN month = 'listopadu' THEN '11.'
              WHEN month = 'prosince' THEN '12.'
          END AS month_num
    , LEFT(year, 4) as year
    , "pageOpener"
    , "pageSection"
    , "pageText"
    , "pageTitle"
    , "url"
    , "source"
FROM idnes_copy;

// 9) Handle the date (part 4):
CREATE OR REPLACE TABLE idnes_copy AS
SELECT
     "pageAuthor"
    , DATE_FROM_PARTS(year, month_num, day) AS "pageDate"
    , "pageOpener"
    , "pageSection"
    , "pageText"
    , "pageTitle"
    , "url"
    , "source"
FROM idnes_copy
WHERE LENGTH(day) IN (2, 3) AND LENGTH(month_num) = 3 AND LENGTH(year) = 4 AND year NOT LIKE ('%:%');

// 10) Only include articles about Russia:
CREATE OR REPLACE TABLE idnes_kinda_clean AS
SELECT DISTINCT * FROM idnes_copy
WHERE "pageTitle" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%putin%'
OR "pageTitle" ILIKE '%moskv%'
OR "pageTitle" ILIKE '%moskev%'
OR "pageTitle" ILIKE '%kreml%'
OR "pageTitle" ILIKE '%kremel%'
;

-- 11 015 rows

// IROZHLAS:
--- Create table irozhlas_copy - add columns row nr, section and date (WHERE "pageText" <> '')

CREATE OR REPLACE TABLE irozhlas_copy AS
SELECT CASE WHEN "pageSection" LIKE '%Ekonomika%' THEN 'Ekonomika'
            WHEN "pageSection" LIKE '%Zprávy ze světa%' THEN 'Zprávy ze světa'
            WHEN "pageSection" LIKE '%Zprávy z domova%' THEN 'Zprávy z domova'
            WHEN "pageSection" LIKE '%Věda a technologie%' THEN 'Věda a technologie'
            WHEN "pageSection" LIKE '%Komentáře%' THEN 'Komentáře'
            WHEN "pageSection" LIKE '%Životní styl a společnost%' THEN 'Životní styl a společnost'
            WHEN "pageSection" LIKE '%Kultura%' THEN 'Kultura'
            WHEN "pageSection" LIKE '%Sport%' THEN 'Sport'
       END AS section
       , SPLIT("pageDate", ' ') AS pagedate_split
       , LEFT(SPLIT("pageDate", ' ')[3], 4) AS rok
       , SPLIT("pageDate", ' ')[2] AS mesic_txt
       , CASE WHEN mesic_txt = 'ledna' OR mesic_txt = '1.' THEN '01'
              WHEN mesic_txt = 'února' OR mesic_txt = '2.' THEN '02'
              WHEN mesic_txt = 'března' OR mesic_txt = '3.' THEN '03'
              WHEN mesic_txt = 'dubna' OR mesic_txt = '4.' THEN '04'
              WHEN mesic_txt = 'května' OR mesic_txt = '5.' THEN '05'
              WHEN mesic_txt = 'června' OR mesic_txt = '6.' THEN '06'
              WHEN mesic_txt = 'července' OR mesic_txt = '7.' THEN '07'
              WHEN mesic_txt = 'srpna' OR mesic_txt = '8.' THEN '08'
              WHEN mesic_txt = 'září' OR mesic_txt = '9.' THEN '09'
              WHEN mesic_txt = 'října' OR mesic_txt = '10.' THEN '10'
              WHEN mesic_txt = 'listopadu' OR mesic_txt = '11.' THEN '11'
              WHEN mesic_txt = 'prosince' OR mesic_txt = '12.' THEN '12'
          END AS mesic
          , RTRIM(SPLIT("pageDate", ' ')[1],'.') AS den
          , DATE_FROM_PARTS(rok, mesic, den) AS date
          , ROW_NUMBER() OVER(ORDER BY date) AS row_nr
          , *
FROM irozhlas
WHERE "pageText" <> '';

--- Add column "source"

ALTER TABLE irozhlas_copy ADD COLUMN "source" varchar(255);

UPDATE irozhlas_copy SET "source" = 'irozhlas';

--- Create "kinda clean" table (Russia)

CREATE OR REPLACE TABLE irozhlas_kinda_clean AS
SELECT DISTINCT
         "pageAuthor"
       , date AS "pageDate"
       , "pageOpener"
       , section AS "pageSection"
       , TRIM(SPLIT("pageText", 'Sdílet na Facebooku')[0]) AS "pageText"
       , "pageTitle"
       , "url"
       , "source"
FROM irozhlas_copy 
WHERE "pageTitle" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%putin%'
OR "pageTitle" ILIKE '%moskv%'
OR "pageTitle" ILIKE '%moskev%'
OR "pageTitle" ILIKE '%kreml%'
OR "pageTitle" ILIKE '%kremel%';

-- 2144 rows

// LIDOVKY:

// 1) Make copy of the original table 2) Remove rows with empty text
// 3) Make column "source" 4) Remove excessive stuff from "pageTitle"
// 5) Remove excessive stuff from "pageSection" 6) Start fixing "pageDate":
CREATE OR REPLACE TABLE lidovky_copy AS
SELECT "pageAuthor"
    , TRIM(SPLIT("pageDate", ' ')[0]) AS "day"
    , TRIM(SPLIT("pageDate", ' ')[1]) AS "month_txt"
    , CASE WHEN "month_txt" = 'ledna' THEN '01.'
              WHEN "month_txt" = 'února' THEN '02.'
              WHEN "month_txt" = 'března' THEN '03.'
              WHEN "month_txt" = 'dubna' THEN '04.'
              WHEN "month_txt" = 'května' THEN '05.'
              WHEN "month_txt" = 'června' THEN '06.'
              WHEN "month_txt" = 'července' THEN '07.'
              WHEN "month_txt" = 'srpna' THEN '08.'
              WHEN "month_txt" = 'září' THEN '09.'
              WHEN "month_txt" = 'října' THEN '10.'
              WHEN "month_txt" = 'listopadu' THEN '11.'
              WHEN "month_txt" = 'prosince' THEN '12.'
          END AS "month"
    , TRIM(SPLIT((SPLIT("pageDate", ' ')[2]), ' ')[0]) AS "year"
    , "pageOpener"
    , TRIM(SPLIT("pageSection", '>')[2]) AS "pageSection"
    , "pageText"
    , TRIM(SPLIT("pageTitle", '|')[0]) AS "pageTitle"
    , "url"
    , 'lidovky' AS "source"
FROM lidovky
WHERE "pageText" <> ''
;

// 7) Finish modifications of "pageDate" 8) Tidy "pageAuthor" 9) Only include articles about Russia:
CREATE OR REPLACE TABLE lidovky_kinda_clean AS
SELECT
     REPLACE(REPLACE("pageAuthor", ',,', ','), ',', ' |') AS "pageAuthor"
    , DATE_FROM_PARTS(LEFT("year", 4), "month", "day") AS "pageDate"
    , "pageOpener"
    , "pageSection"
    , "pageText"
    , "pageTitle"
    , "url"
    , "source"
FROM lidovky_copy
WHERE "pageTitle" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%putin%'
OR "pageTitle" ILIKE '%moskv%'
OR "pageTitle" ILIKE '%moskev%'
OR "pageTitle" ILIKE '%kreml%'
OR "pageTitle" ILIKE '%kremel%'
;

-- 10 390 rows;

// NOVINKY:
--- Create table novinky_copy - add columns row nr, section and date (WHERE "pageText" <> '')

CREATE OR REPLACE TABLE novinky_copy AS
SELECT CASE WHEN "url" LIKE '%zahranicni%' THEN 'Zahraniční'
            WHEN "url" LIKE '%volby%' THEN 'Volby'
            WHEN "url" LIKE '%internet-a-pc%' THEN 'Internet a PC'
            WHEN "url" LIKE '%koronavirus%' THEN 'Koronavirus'
            WHEN "url" LIKE '%domaci%' THEN 'Domácí'
            WHEN "url" LIKE '%ekonomika%' THEN 'Ekonomika'
            WHEN "url" LIKE '%veda-skoly%' THEN 'Věda a školy'
            WHEN "url" LIKE '%finance%' THEN 'Finance'
            WHEN "url" LIKE '%komentare%' THEN 'Komentáře'
       END AS section
       , SPLIT(LEFT("pageDate", 12), '.') AS pagedate_split  
       , LEFT(SPLIT(LEFT("pageDate", 12), '.')[2], 5) AS rok
       , SPLIT(LEFT("pageDate", 12), '.')[1] AS mesic
       , SPLIT(LEFT("pageDate", 12), '.')[0] AS den
       , DATE_FROM_PARTS(rok, mesic, den) AS date
       , ROW_NUMBER() OVER(ORDER BY date) AS row_nr
       , *        
FROM novinky
WHERE rok IS NOT NULL
      AND mesic IS NOT NULL
      AND den IS NOT NULL
      AND "pageText" <> '';

--- Add column "source"

ALTER TABLE novinky_copy ADD COLUMN "source" varchar(255);

UPDATE novinky_copy SET "source" = 'novinky';

--- Create "kinda clean" table (Russia)

CREATE OR REPLACE TABLE novinky_kinda_clean AS
SELECT DISTINCT
         "pageAuthor"
       , date AS "pageDate"
       , "pageOpener"
       , section AS "pageSection"
       , REPLACE("pageText", '[celá zpráva]') AS "pageText"
       , "pageTitle"
       , "url"
       , "source"
FROM novinky_copy
WHERE "pageTitle" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%putin%'
OR "pageTitle" ILIKE '%moskv%'
OR "pageTitle" ILIKE '%moskev%'
OR "pageTitle" ILIKE '%kreml%'
OR "pageTitle" ILIKE '%kremel%';

--6139 rows

// PARLAMENTNI LISTY

// 1) Set "source" column 2) Select only "pageTitle" about Russia
// 3) Fix and trim "pageDate" 3) Fix "pageSection" - add '|' as separator
// 5) Remove excessive stuff from "pageText" 6) Remove excessive stuff from "pageTitle"
// 7) Select only articles with non-empty "pageText" 8) Tidy "pageAuthor"
CREATE OR REPLACE TABLE parlamentnilisty_kinda_clean AS
SELECT REPLACE(REPLACE("pageAuthor", '- profil'), ',', ' |') AS "pageAuthor"
    ,DATE_FROM_PARTS(LEFT(TRIM(SPLIT("pageDate", '.')[2]), 4), TRIM(SPLIT("pageDate", '.')[1]), TRIM(SPLIT("pageDate", '.')[0])) AS "pageDate"
    ,"pageOpener"
    ,REPLACE(REPLACE("pageSection", '                                        ', '| '), '\n', ' ') AS "pageSection" -- 40 spaces and a new line
    ,REPLACE(TRIM(SPLIT("pageText", 'Jste politik?')[0]), '\n\n', '') AS "pageText"
    ,REPLACE("pageTitle", ' | ParlamentniListy.cz – politika ze všech stran') AS "pageTitle"
    ,"url" 
    ,'parlamentnilisty' AS "source"
FROM "pl"
WHERE "pageText" <> '' AND
    ("pageTitle" ILIKE '%rusk%'
    OR "pageTitle" ILIKE '%putin%'
    OR "pageTitle" ILIKE '%moskv%'
    OR "pageTitle" ILIKE '%moskev%'
    OR "pageTitle" ILIKE '%kreml%'
    OR "pageTitle" ILIKE '%kremel%')
;

// SPUTNIK:

// 1) Make copy of the original table 2) Remove rows with empty text
// 3) Make column "source" 4) Fix "pageDate"
// 5) Remove excessive stuff from "pageTitle" 6) Remove excessive stuff from "pageText"
CREATE OR REPLACE TABLE sputnik_copy AS
SELECT "pageAuthor"
    , DATE_FROM_PARTS((SPLIT(TRIM(SPLIT("pageDate", ' ')[1]), '.')[2]), (SPLIT(TRIM(SPLIT("pageDate", ' ')[1]), '.')[1]),(SPLIT(TRIM(SPLIT("pageDate", ' ')[1]), '.')[0])) AS "pageDate"
    , "pageOpener"
    , "pageSection"
    , REPLACE(REPLACE(REPLACE("pageText", 'Názory vyjádřené v článku se nemusí vždy shodovat s postojem Sputniku.'), 'Názor autora se nemusí shodovat s názorem redakce'), 'Názor autora nemusí shodovat s názorem redakce') AS "pageText"
    , REPLACE("pageTitle", '- Sputnik Česká republika') AS "pageTitle"
    , "url"
    , 'sputnik' AS "source"
FROM "sputnik"
WHERE "pageText" <> ''
;

-- 68352 rows (SPUTNIK originally 72541 rows)


// 6) Only include articles about Russia:
CREATE OR REPLACE TABLE sputnik_kinda_clean AS
SELECT DISTINCT * FROM sputnik_copy
WHERE "pageTitle" ILIKE '%rusk%'
OR "pageTitle" ILIKE '%putin%'
OR "pageTitle" ILIKE '%moskv%'
OR "pageTitle" ILIKE '%moskev%'
OR "pageTitle" ILIKE '%kreml%'
OR "pageTitle" ILIKE '%kremel%'
;

-- 17 550 rows

// Connect tables:
CREATE OR REPLACE TABLE PROJECT_CONNECTED_CLEAN AS
SELECT "pageAuthor","pageDate","pageOpener","pageSection","pageText","pageTitle","url","source" FROM idnes_kinda_clean
UNION ALL
SELECT "pageAuthor","pageDate","pageOpener","pageSection","pageText","pageTitle","url","source" FROM sputnik_kinda_clean
UNION ALL
SELECT "pageAuthor","pageDate","pageOpener","pageSection","pageText","pageTitle","url","source" FROM lidovky_kinda_clean
UNION ALL
SELECT "pageAuthor","pageDate","pageOpener","pageSection","pageText","pageTitle","url","source" FROM aeronet_kinda_clean
UNION ALL
SELECT "pageAuthor","pageDate","pageOpener","pageSection","pageText","pageTitle","url","source" FROM aktualne_kinda_clean
UNION ALL
SELECT "pageAuthor","pageDate","pageOpener","pageSection","pageText","pageTitle","url","source" FROM irozhlas_kinda_clean
UNION ALL
SELECT "pageAuthor","pageDate","pageOpener","pageSection","pageText","pageTitle","url","source" FROM novinky_kinda_clean
UNION ALL
SELECT "pageAuthor","pageDate","pageOpener","pageSection","pageText","pageTitle","url","source" FROM parlamentnilisty_kinda_clean
;

CREATE OR REPLACE TABLE PROJECT_CONNECTED_CLEAN AS
SELECT ROW_NUMBER() OVER(ORDER BY "url") AS "rowNum", * FROM PROJECT_CONNECTED_CLEAN;

CREATE OR REPLACE TABLE PROJECT_CONNECTED_CLEAN AS
SELECT CONCAT("source", "rowNum") AS ID
,"pageAuthor"
,"pageDate"
,"pageOpener"
,"pageSection"
,"pageText"
,"pageTitle"
,"url"
,"source"
FROM PROJECT_CONNECTED_CLEAN;
