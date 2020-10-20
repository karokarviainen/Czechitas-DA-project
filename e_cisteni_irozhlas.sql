------------------------------------------------------------------------------------------------------- 2. IROZHLAS ------------------------------------------

SELECT * FROM irozhlas_unclean;

-------------- PRACOVNÍ TABULKA
--- Nejdřív si vytvořím tabulku aeronet_copy, se kterou budu pracovat, abych si v té aeronet_unclean nic nezměnila
CREATE OR REPLACE TABLE irozhlas_copy AS
SELECT * FROM irozhlas_unclean;

SELECT * FROM irozhlas_copy; --- 57 490 rows

--------------- DATUM: zkouška
--- Jsou tam asi různé formáty...
--- Zkusím nejdřív tenhle formát: '8:39 3. 8. 2019'

--- Budu to muset řešit jen u řádků, kde je pageText, protože tam, kde není, jsou nemožné formáty data.

SELECT *
FROM irozhlas_copy
WHERE "pageText" = '';
--- 13 568 rows: takže tyhle řádky vypadnou a zbyde nám 43 922 rows.

SELECT "pageDate"
       , SPLIT("pageDate", ' ') as pagedate_split
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
          , *
FROM irozhlas_unclean
WHERE "pageText" <> '';
--- 43 922 rows

--- Tohle propíšu do tabulky a budu mít tabulku s datem, kde nikde nechybí pageText:
--- Ale ono to nejde! SQL compilation error: Missing column specification
// A pak další errory, když jsem nenazvala sloupce nebo si vypala sloupec "pageDate" jako první.
// Po úpravách: tohle funguje:

CREATE OR REPLACE TABLE irozhlas_copy AS
SELECT SPLIT("pageDate", ' ') AS pagedate_split
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
          , *
FROM irozhlas_unclean
WHERE "pageText" <> '';

SELECT * FROM irozhlas_copy;
--- 43 922 rows

--- Pak vyhodím pomocné sloupce den, mesic, rok a nechám si jen pageDate a hlavně date:

ALTER TABLE irozhlas_copy DROP COLUMN rok;
ALTER TABLE irozhlas_copy DROP COLUMN mesic_txt;
ALTER TABLE irozhlas_copy DROP COLUMN den;
ALTER TABLE irozhlas_copy DROP COLUMN mesic;
ALTER TABLE irozhlas_copy DROP COLUMN pagedate_split;

SELECT * FROM irozhlas_copy;

---------- SLOUPEC SOURCE
--- Vytvořím sloupec source a napíšu do něj 'iRozhlas':

ALTER TABLE irozhlas_copy ADD COLUMN source varchar(255);

UPDATE irozhlas_copy SET source = 'iRozhlas';

---------- POČET ČLÁNKŮ? 
--- Konečně se podívám, kolik mám různých kombinací SOURCE-DATE-pageTitle:

SELECT DISTINCT(source || date || "pageTitle")
FROM irozhlas_copy;
--- 43 885 rows

--- A kdybych se chtěla podívat, v kolika řádcích je různý text:
SELECT DISTINCT "pageText"
FROM irozhlas_copy;
--- 43663 rows

--- A kde není žádný text:
SELECT *
FROM irozhlas_copy
WHERE "pageText" = '';
--- 0: ty už jsem vyhodila.

---------- POČET ČLÁNKŮ, KDE SKUTEČNĚ JE I TEXT apod.

SELECT * FROM aeronet_copy
WHERE "pageText" IS NULL;
--- Tak to tam není - 0 rows.

SELECT DISTINCT(source || date || "pageTitle") AS id
       , date
       , "pageDate"
       , "pageAuthor"
       , "pageSection"
       , "pageTitle"
       , "pageOpener"
       , "pageText"
       , "url"
       , source
FROM irozhlas_copy 
WHERE "pageText" <> '' --- 43 921 rows 
AND "pageTitle" <> '' --- 43 921 rows
AND "pageDate" <> '' --- 43 921 rows
AND "pageText" ILIKE '%rusk%'; --- 5112 rows // To není moc.