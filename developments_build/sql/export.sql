-- create a tempory table from the housing table where development happened
-- with the desired fields in the desired order named approriatly
-- copy that table to the output folder and drop the table
-- update the cutoff dates
	-- Cutoff date for 1st quarter would be March 31st.
	-- Cutoff date for 1st quarter would be June 30th.
	-- Cutoff date for 3rd quarter is Sept 30th.
	-- Cutoff date for 4th quarter is Dec 31st.
DROP TABLE IF EXISTS dev_export;
CREATE TABLE dev_export AS 
	(SELECT *
	FROM developments
	WHERE (co_earliest_effectivedate::date >= '2010-01-01' AND co_earliest_effectivedate::date <=  '2018-12-31')
	OR (co_earliest_effectivedate IS NULL AND status_q::date >= '2010-01-01' AND status_q::date <=  '2018-12-31')
	OR (co_earliest_effectivedate IS NULL AND status_q IS NULL AND status_a::date >= '2010-01-01' AND status_a::date <=  '2018-12-31')
	AND x_outlier <> 'true'
	);

DROP TABLE IF EXISTS housing_export;
CREATE TABLE housing_export AS 
	(SELECT *
	FROM developments
	WHERE ((co_earliest_effectivedate::date >= '2010-01-01' AND co_earliest_effectivedate::date <=  '2018-12-31')
	OR (co_earliest_effectivedate IS NULL AND status_q::date >= '2010-01-01' AND status_q::date <=  '2018-12-31')
	OR (co_earliest_effectivedate IS NULL AND status_q IS NULL AND status_a::date >= '2010-01-01' AND status_a::date <=  '2018-12-31'))
	AND (occ_category = 'Residential' OR occ_prop LIKE '%Residential%' OR occ_init LIKE '%Residential%' OR occ_prop LIKE '%Assisted%Living%' OR occ_init LIKE '%Assisted%Living%')
	AND (occ_init IS DISTINCT FROM 'Garage/Miscellaneous' OR occ_prop IS DISTINCT FROM 'Garage/Miscellaneous')
	AND job_number NOT IN (
		SELECT DISTINCT job_number 
		FROM developments
		WHERE job_type = 'New Building' AND occ_prop = 'Hotel or Dormitory' AND x_mixeduse IS NULL)
	AND x_outlier <> 'true'
	);

-- drop outlier column from final output
ALTER TABLE dev_export
DROP COLUMN x_outlier;
ALTER TABLE housing_export
DROP COLUMN x_outlier;

-- export
--all records
\copy (SELECT * FROM dev_export) TO '/prod/db-developments/developments_build/output/devdb_developments.csv' DELIMITER ',' CSV HEADER;
-- only points
\copy (SELECT * FROM dev_export WHERE ST_GeometryType(geom)='ST_Point') TO '/prod/db-developments/developments_build/output/devdb_developments_pts.csv' DELIMITER ',' CSV HEADER;
-- records that did not geocode
\copy (SELECT * FROM dev_export WHERE geom IS NULL AND latitude IS NULL AND upper(address) NOT LIKE '% TEST %') TO '/prod/db-developments/developments_build/output/devdb_developments_nogeom' DELIMITER ',' CSV HEADER;
-- only housing records
\copy (SELECT * FROM housing_export) TO '/prod/db-developments/developments_build/output/devdb_housing.csv' DELIMITER ',' CSV HEADER;
-- only housing points
\copy (SELECT * FROM housing_export WHERE ST_GeometryType(geom)='ST_Point') TO '/prod/db-developments/developments_build/output/devdb_housing_pts.csv' DELIMITER ',' CSV HEADER;
-- ony housing records that did not geocode
\copy (SELECT * FROM housing_export WHERE geom IS NULL AND latitude IS NULL AND upper(address) NOT LIKE '% TEST %') TO '/prod/db-developments/developments_build/output/devdb_housing_nogeom.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT * FROM developments_co) TO '/prod/db-developments/developments_build/output/devdb_cos.csv' DELIMITER ',' CSV HEADER;

-- DROP TABLE dev_export;
-- DROP TABLE housing_export;