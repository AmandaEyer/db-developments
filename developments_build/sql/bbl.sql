-- populate the bbl field
-- create the boro code lookup table
WITH borolookup AS (
SELECT DISTINCT boro,
	(CASE 
		WHEN boro = 'MANHATTAN' THEN '1'
		WHEN boro = 'BRONX' THEN '2'
		WHEN boro = 'BROOKLYN' THEN '3'
		WHEN boro = 'QUEENS' THEN '4'
		WHEN boro = 'STATEN ISLAND' THEN '5'
		ELSE NULL
	END ) borocode
FROM developments
)

UPDATE developments a
SET bbl = b.borocode||a.bbl
FROM borolookup b
WHERE a.boro=b.boro;

UPDATE developments a
SET bbl = trim(trailing '0' FROM bbl::text)
WHERE length(bbl)>10;