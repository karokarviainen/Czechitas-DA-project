// IROZHLAS:
--- 1 Create table irozhlas_copy - add columns row nr, section and date (WHERE "pageText" <> '')

CREATE OR REPLACE TEMPORARY TABLE irozhlas_copy AS
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

--- 2 Create "kinda clean" table

CREATE OR REPLACE TEMPORARY TABLE irozhlas_kinda_clean AS
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
;