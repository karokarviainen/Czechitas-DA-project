--------------------------------------------------------------------------------------------------- 3. NOVINKY  ----------------------------------------------

SELECT * FROM novinky_unclean;
--- 148 536 rows

-------------- PRACOVNÍ TABULKA
--- Nejdřív si vytvořím tabulku aeronet_copy, se kterou budu pracovat, abych si v té aeronet_unclean nic nezměnila
CREATE OR REPLACE TABLE novinky_copy AS
SELECT * FROM novinky_unclean;

SELECT * FROM novinky_copy;

--------------- DATUM: zkouška
--- 29. 11. 2011, 15:12včera 20:13včera 18:47včera 17:07včera 22:30

SELECT *
FROM novinky_copy
WHERE "pageText" = '';
--- 11 574 rows

SELECT "pageDate"
       , SPLIT(LEFT("pageDate", 12), '.') AS pagedate_split  
       , LEFT(SPLIT(LEFT("pageDate", 12), '.')[2], 5) AS rok
       , SPLIT(LEFT("pageDate", 12), '.')[1] AS mesic
       , SPLIT(LEFT("pageDate", 12), '.')[0] AS den
       , DATE_FROM_PARTS(rok, mesic, den) AS date
       , *        
FROM novinky_copy
WHERE rok IS NOT NULL
      AND mesic IS NOT NULL
      AND den IS NOT NULL
;       
--- 148 242 rows

-----------------------------------------------------------------------------------------------
--- (294 řádků nám vypadlo, protože mají datum ve formátu dnes + čas, včera + čas apod.)
--- To bych nahrazovala, teď to nebudu řešit, ale pak to udělám.
-----------------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE novinky_copy AS
SELECT SPLIT(LEFT("pageDate", 12), '.') AS pagedate_split  
       , LEFT(SPLIT(LEFT("pageDate", 12), '.')[2], 5) AS rok
       , SPLIT(LEFT("pageDate", 12), '.')[1] AS mesic
       , SPLIT(LEFT("pageDate", 12), '.')[0] AS den
       , DATE_FROM_PARTS(rok, mesic, den) AS date
       , *        
FROM novinky_unclean
WHERE rok IS NOT NULL
      AND mesic IS NOT NULL
      AND den IS NOT NULL
;
--- Zatím propíšu do tabulky bez těch 294 nich, abych se mohla podívat, kolik dat se opakuje.

SELECT * FROM novinky_copy;
--- 148 242 rows

--- Pak vyhodím pomocné sloupce den, mesic, rok a nechám si jen pageDate a hlavně date:

ALTER TABLE novinky_copy DROP COLUMN rok;
ALTER TABLE novinky_copy DROP COLUMN den;
ALTER TABLE novinky_copy DROP COLUMN mesic;
ALTER TABLE novinky_copy DROP COLUMN pagedate_split;

SELECT * FROM novinky_copy;

---------- SLOUPEC SOURCE
--- Vytvořím sloupec source a napíšu do něj 'iRozhlas':

ALTER TABLE novinky_copy ADD COLUMN source varchar(255);

UPDATE novinky_copy SET source = 'Novinky';

---------- POČET ČLÁNKŮ? 
--- Konečně se podívám, kolik mánovinky_copym různých kombinací SOURCE-DATE-pageTitle:

SELECT DISTINCT(source || date || "pageTitle")
FROM novinky_copy;
--- 146 934 rows

--- A kdybych se chtěla podívat, v kolika řádcích je různý text:
SELECT DISTINCT "pageText"
FROM novinky_copy;
--- 136 275 rows

--- A kde není žádný text:
SELECT *
FROM irozhlas_copy
WHERE "pageText" = '' OR "pageText" IS NULL;
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
FROM novinky_copy 
WHERE "pageText" <> '' --- 136 872 rows
AND "pageTitle" <> '' --- 136 872 rows
AND "pageDate" <> '' --- 136 872 rows
AND "pageText" ILIKE '%rusk%'; --- 15 426 rows

