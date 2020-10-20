------------------------------------------------------------------------------------
-------------------------- 1. AERONET ----------------------------------------------

SELECT * FROM aeronet_unclean;

/*
// CO MUSÍME UDĚLAT:
--- pridat ID pro kazdy zaznam (kombinace media, titulku a data) --- Mám, akorát ještě nepropsané.
--- odstranit bordely v textech (opakujici se veci) pomoci regexu, dvojite radky nahradit jednoduchymi --- Ještě nemám.
--- pridat sloupec "source" --- Mám.
--- osekat data, dat do jednotneho formatu --- No, to asi později.
--- vymazat zaznamy bez textu --- To zatím neubudu dělat, ale nebude to tak těžké.
--- nazvy v Keboole: podtrzitka, datum --- Ok.
*/

-------------- PRACOVNÍ TABULKA
--- Nejdřív si vytvořím tabulku aeronet_copy, se kterou budu pracovat, abych si v té aeronet_unclean nic nezměnila
CREATE OR REPLACE TABLE aeronet_copy AS
SELECT * FROM aeronet_unclean;

SELECT * FROM aeronet_copy;
// V dalším kroku si to hned přepíšu, tak tehle krok nebyl úplně nutný, ale to je jedno.
// V jiných případech by se asi hodil.

--------------- DATUM: zkouška
--- Rozdělím si datum podle čárky a podle mezery na rok, měsíc a den,
--- měsíc nahradím číslem
--- a pak rok, měsíc a den spojím do nového sloupce date.

SELECT SPLIT("pageDate", ', ')[1] as rok
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
              WHEN mesic_txt = 'Lid' THEN '11'
              WHEN mesic_txt = 'Pro' THEN '12'
          END AS mesic
          , DATE_FROM_PARTS(rok, mesic, den) AS date
FROM aeronet_copy;

---------- DATUM: propsat do tabulky

CREATE OR REPLACE TABLE aeronet_copy AS
SELECT SPLIT("pageDate", ', ')[1] as rok
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
              WHEN mesic_txt = 'Lid' THEN '11'
              WHEN mesic_txt = 'Pro' THEN '12'
          END AS mesic
          , DATE_FROM_PARTS(rok, mesic, den) AS date
          , *
FROM aeronet_unclean;

SELECT * FROM aeronet_copy;

--- A vyhodím ty provizorní sloupce pro datum.
--- Původní datum pro jistotu nechám, kdyby se někdy zjistilo, že jsem něco udělala špatně.

ALTER TABLE aeronet_copy DROP COLUMN rok;
ALTER TABLE aeronet_copy DROP COLUMN mesic_txt;
ALTER TABLE aeronet_copy DROP COLUMN den;
ALTER TABLE aeronet_copy DROP COLUMN mesic;

SELECT * FROM aeronet_copy;

---------- SLOUPEC SOURCE
--- Vytvořím sloupec source a napíšu do něj 'Aeronet':

ALTER TABLE aeronet_copy ADD COLUMN source varchar(255);

UPDATE aeronet_copy SET source = 'Aeronet';


---------- POČET ČLÁNKŮ? 
--- Konečně se podívám, kolik mám různých kombinací SOURCE-DATE-pageTitle:

SELECT DISTINCT(source || date || "pageTitle")
FROM aeronet_copy;
--- 10 731 rows

--- Z toho by se asi mohla vytvořit nová tabulka aeronet_distinct a zbytek by se mohl nechat být?

---------- POČET ČLÁNKŮ, KDE SKUTEČNĚ JE I TEXT apod.

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
FROM aeronet_copy 
WHERE "pageText" <> '' --- 2458 rows // No, nic moc...
AND "pageTitle" <> '' --- 2457
AND "pageDate" <> '' --- 2457
AND "pageText" ILIKE '%rusk%' --- 1516 rows // Víc než polovina, to je zase docela dobrý.
;

--- Asi by to chtělo propsat id do tabulky taky hned na začátku, ale teď už to nechám, zas tak to nevadí.

/* Co musím udělat dál:
--- Hlavně osekat bordel v textech. To jsem zatím neřešila.
*/
