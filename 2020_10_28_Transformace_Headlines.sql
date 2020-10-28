// AERONET:
--- 1 Create table aeronet_copy (WHERE "pageText" <> ''), add columns row_nr, author, date (adjusted date), title > opener, source

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
          , 'aeronet' AS "source"
          , *
FROM aeronet
WHERE "pageText" <> ''
;

// SELECT * FROM aeronet_copy; --- 2458 rows


--- 2 Create "kinda clean" table (only with article about Russia)

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
WHERE CONCAT("pageText","pageTitle","pageOpener") ILIKE '%rusk%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%putin%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskv%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskev%'
;

--- 3 Trim "pageTitle"

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

--- 4 Replace too short trimmed "pageTitle" with 1st sentence from "pageOpener"

CREATE OR REPLACE TABLE aeronet_kinda_clean AS
SELECT "pageAuthor"
       ,"pageDate"
       ,"pageOpener"
       ,"pageSection"
       ,"pageText"
       , CASE WHEN "pageTitle" = 'Otázky a odpovědi V' THEN 'Otázky a odpovědi V. V. Pjakina'
              WHEN "pageTitle" = 'V' THEN 'V. V. Pjakin'
              WHEN "pageTitle" = 'Analýza V' THEN 'Analýza V. V. Pjakina'
              WHEN "pageTitle" = '“D' THEN '“D. Trump je naivní a neví, kdo proti němu v Kremlu sedí.”'
              WHEN "pageTitle" = 'D' THEN 'D. Trump, rozpad NATO, Nová Evropa – tažení na Rusko nikdy neskončilo.'
              WHEN "pageTitle" = 'A' THEN 'A. Dugin: “Velká válka kontinentů právě začala”.'
              WHEN "pageTitle" = 'P' THEN 'P. C. Roberts: Válka je na obzoru – není už příliš pozdě ji zastavit?'
              WHEN "pageTitle" = '60' THEN '60. výročí podpisu Římských smluv a Bílá kniha EU jako dva konce globalistického provazu'
              WHEN "pageTitle" = '17' THEN '17. září 2015 – den D pro ceny ropy. Rubl se připravuje na ropný šok. Rusko chce stavět plynovod, Evropa nemá zájem'
              WHEN "pageTitle" = 'iDnes' AND "pageDate" = '2015-10-02' THEN 'iDnes.cz šíří podvržené fotografie, aby očernil syrskou vládu Bašára Assada a zdiskreditoval ruskou intervenci v Sýrii!'
              WHEN "pageTitle" = 'iDnes' AND "pageDate" = '2015-04-07' THEN 'iDnes.cz jde ve stopách ČT aneb jak se ková poctivá propaganda.'
              WHEN "pageTitle" = '4' AND "pageDate" = '2017-12-09' THEN '4. prosince židé oslavili Nový rok.'
              WHEN "pageTitle" = '4' AND "pageDate" = '2017-12-04' THEN '4. prosinec 1941 – Hitler 30 km před Moskvou.'
              WHEN "pageTitle" = 'Moskva 9' THEN 'Moskva 9. května 2017'
              WHEN "pageTitle" = 'Obama vs' THEN 'Obama vs. Putin'
              WHEN "pageTitle" = 'USA vs' THEN 'USA vs. Rusko'
              WHEN "pageTitle" = 'Sionisté vs' THEN 'Sionisté vs. Chabad'
              WHEN "pageTitle" = 'Pane Dr' THEN 'Pane Dr. Čulíku, brzděte!'
              WHEN "pageTitle" = 'Narozen 4' THEN 'Narozen 4. července – co přát zrozenci?'
              WHEN "pageTitle" = 'Prezident' THEN 'Prezident. Co to je „prezident“?'              
         ELSE "pageTitle"
         END AS "pageTitle"
       ,"url"
       ,"source"
FROM aeronet_kinda_clean;

// SELECT * FROM aeronet_kinda_clean; --- 1559 rows

// AKTUALNE:

--- 1 Create table aktualne_copy (WHERE "pageText" <> ''), adjust date format, add row_nr

CREATE OR REPLACE TABLE aktualne_copy AS
SELECT REPLACE("pageDate", 'Aktualizováno ') AS date_replaced
       , CASE WHEN date_replaced ILIKE 'před%' THEN '18. 10. 2020 00:00'
              WHEN date_replaced = 'za okamžik' THEN '18. 10. 2020 00:00'  
         ELSE date_replaced
         END AS date_unified
       , SPLIT(LEFT(date_unified, 12), '.') AS date_split  
       , LEFT(SPLIT(LEFT(date_unified, 12), '.')[2], 5) AS rok
       , SPLIT(LEFT(date_unified, 12), '.')[1] AS mesic
       , SPLIT(LEFT(date_unified, 12), '.')[0] AS den
       , DATE_FROM_PARTS(rok, mesic, den) AS date
       , ROW_NUMBER() OVER(ORDER BY date) AS row_nr
       , 'aktualne' AS "source"
       , *        
FROM aktualne
WHERE "pageText" <> ''
;

SELECT * FROM aktualne_copy; --- 187 119 rows

--- 2 Create "kinda clean" table (only with articles about Russia)

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
WHERE CONCAT("pageText","pageTitle","pageOpener") ILIKE '%rusk%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%putin%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskv%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskev%'
;

// SELECT * FROM aktualne_kinda_clean; --- 21 049 rows


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

SELECT * FROM idnes_copy; -- 495 787 rows

// 10) Only include articles about Russia:
CREATE OR REPLACE TABLE idnes_kinda_clean AS
SELECT DISTINCT * FROM idnes_copy
WHERE CONCAT("pageText","pageTitle","pageOpener") ILIKE '%rusk%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%putin%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskv%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskev%'
;

SELECT * FROM idnes_kinda_clean; --- 51 380 rows


// IROZHLAS:
--- 1 Create table irozhlas_copy - add columns row nr, section and date (WHERE "pageText" <> '')

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
          , 'irozhlas' AS "source"
          , *
FROM irozhlas
WHERE "pageText" <> '';

SELECT * FROM irozhlas_copy; --- 43 922 rows


--- 2 Create "kinda clean" table (Russia)

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
WHERE CONCAT("pageText","pageTitle","pageOpener") ILIKE '%rusk%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%putin%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskv%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskev%'
;

// SELECT * FROM irozhlas_kinda_clean; --- 5562 rows

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

// SELECT * FROM lidovky_copy; --- 224 055 rows

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
WHERE CONCAT("pageText","pageTitle","pageOpener") ILIKE '%rusk%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%putin%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskv%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskev%'
;

// SELECT * FROM lidovky_kinda_clean; --- 28 065 rows

// NOVINKY:
--- 1 Create table novinky_copy (WHERE "pageText" <> ''), add columns row nr, section and date (adjusted date)

CREATE OR REPLACE TABLE novinky_copy  AS
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
       , CASE WHEN "pageDate" ILIKE 'Včera%' THEN '17. 10. 2020, 00:00'
              WHEN "pageDate" ILIKE 'Dnes%' THEN '18. 10. 2020, 00:00'
         ELSE "pageDate"
         END AS date_unified
       , SPLIT(LEFT(date_unified, 12), '.') AS date_split  
       , LEFT(SPLIT(LEFT(date_unified, 12), '.')[2], 5) AS rok
       , SPLIT(LEFT(date_unified, 12), '.')[1] AS mesic
       , SPLIT(LEFT(date_unified, 12), '.')[0] AS den
       , DATE_FROM_PARTS(rok, mesic, den) AS date
       , ROW_NUMBER() OVER(ORDER BY date) AS row_nr
       , 'novinky' AS "source"
       , *        
FROM novinky
WHERE "pageText" <> ''
;

// SELECT * FROM novinky_copy; --- 136 962 rows 

--- 2 Create "kinda clean" table (only with articles about Russia)

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
WHERE CONCAT("pageText","pageTitle","pageOpener") ILIKE '%rusk%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%putin%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskv%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskev%'
;

// SELECT * FROM novinky_kinda_clean; --- 17 067 rows


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
WHERE CONCAT("pageText","pageTitle","pageOpener") ILIKE '%rusk%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%putin%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskv%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskev%'
;

// SELECT * FROM parlamentnilisty_kinda_clean; --- 96 251 rows

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

// SELECT * FROM sputnik_copy; -- 68352 rows (SPUTNIK originally 72541 rows)


// 6) Only include articles about Russia:
CREATE OR REPLACE TABLE sputnik_kinda_clean AS
SELECT DISTINCT * FROM sputnik_copy
WHERE CONCAT("pageText","pageTitle","pageOpener") ILIKE '%rusk%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%putin%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskv%'
OR CONCAT("pageText","pageTitle","pageOpener") ILIKE '%moskev%'
;

// SELECT * FROM sputnik_kinda_clean; --- 17 550 rows


// Connect tables:
CREATE OR REPLACE TABLE PROJECT_HEADLINES AS
SELECT "pageTitle", "source" FROM idnes_kinda_clean
UNION ALL
SELECT "pageTitle", "source" FROM sputnik_kinda_clean
UNION ALL
SELECT "pageTitle", "source" FROM lidovky_kinda_clean
UNION ALL
SELECT "pageTitle", "source" FROM aeronet_kinda_clean
UNION ALL
SELECT "pageTitle", "source" FROM aktualne_kinda_clean
UNION ALL
SELECT "pageTitle", "source" FROM irozhlas_kinda_clean
UNION ALL
SELECT "pageTitle", "source" FROM novinky_kinda_clean
UNION ALL
SELECT "pageTitle", "source" FROM parlamentnilisty_kinda_clean
;

// SELECT * FROM PROJECT_HEADLINES; --- 255 245 rows
// SELECT DISTINCT * FROM PROJECT_HEADLINES; --- 148 753 rows

CREATE OR REPLACE TABLE PROJECT_HEADLINES AS
SELECT DISTINCT * FROM PROJECT_HEADLINES;

CREATE OR REPLACE TABLE PROJECT_HEADLINES AS
SELECT ROW_NUMBER() OVER(ORDER BY "source") AS "rowNum"
       , "source" 
       , "pageTitle" 
FROM PROJECT_HEADLINES;

CREATE OR REPLACE TABLE PROJECT_HEADLINES AS
SELECT CONCAT("source", "rowNum") AS ID
       ,"pageTitle"
FROM PROJECT_HEADLINES;

SELECT * FROM PROJECT_HEADLINES; --- 148 753 rows

