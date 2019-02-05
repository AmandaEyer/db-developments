-- sum stats for job_type
DROP TABLE IF EXISTS dev_qc_jobtypestats;
CREATE TABLE dev_qc_jobtypestats AS (
	SELECT job_type, COUNT(*) 
	FROM dev_export 
	GROUP BY job_type 
	ORDER BY job_type);

-- sum stats for x_geomsource
DROP TABLE IF EXISTS dev_qc_geocodedstats;
CREATE TABLE dev_qc_geocodedstats AS (
	SELECT x_geomsource, COUNT(*) 
	FROM dev_export
	GROUP BY x_geomsource
	ORDER BY x_geomsource);

-- general counts of output
DROP TABLE IF EXISTS dev_qc_countsstats;
CREATE TABLE dev_qc_countsstats AS (
SELECT 'sum of units_net' AS stat, SUM(units_net::numeric) as count
FROM dev_export a
UNION
SELECT 'sum of units_prop' AS stat, SUM(units_prop::numeric) as count
FROM dev_export a
UNION
SELECT 'sum of units_complete' AS stat, SUM(units_complete::numeric) as count
FROM dev_export a
UNION
SELECT 'number of alterations with +/- 100 units' AS stat, COUNT(*) as count
FROM dev_export a
WHERE job_type = 'Alteration' AND (units_net::numeric >= 100 OR units_net::numeric <= 100)
UNION
SELECT 'number of inactive records' AS stat, COUNT(*) as count
FROM dev_export a
WHERE x_inactive = 'true'
UNION
SELECT 'number of mixused records' AS stat, COUNT(*) as count
FROM dev_export a
WHERE x_mixeduse = 'true'
UNION
SELECT 'number of outlier records' AS stat, COUNT(*) as count
FROM dev_export a
WHERE x_outlier = 'true'
);
-- UNION
-- SELECT 'number of hotel/residential records' AS stat, COUNT(*) as count
-- FROM housing_export a
-- WHERE job_type = 'Alteration' AND (units_net::numeric >= 100 OR units_net::numeric <= 100)

-- reporting possible duplicate records where the records have the same job_type and address and units_net > 0
-- order by address then job type then units descending
DROP TABLE IF EXISTS dev_qc_potentialdups;
CREATE TABLE dev_qc_potentialdups AS (
	WITH housing_export_rownum AS (
	SELECT a.*, ROW_NUMBER()
    	OVER (PARTITION BY address, job_type
      	ORDER BY address, job_type, units_net::numeric DESC) AS row_number
  		FROM dev_export a
  		WHERE units_net::numeric > 0
  		AND x_inactive <> 'true'
  		AND status <> 'Withdrawn'
  		AND occ_prop <> 'Garage/Miscellaneous')
	SELECT * 
	FROM housing_export_rownum 
	WHERE address||job_type IN (SELECT address||job_type 
	FROM housing_export_rownum WHERE row_number = 2));

-- outputting records for research based on occupancy categories
DROP TABLE IF EXISTS dev_qc_occupancyresearch;
CREATE TABLE dev_qc_occupancyresearch AS (
	SELECT * FROM dev_export 
	WHERE occ_init = 'Assembly: Other' 
	OR occ_prop = 'Assembly: Other' 
	OR (occ_prop = 'Assembly: Other' 
		AND occ_category = 'Other')
	OR job_number IN (
		SELECT DISTINCT jobnumber 
		FROM dob_jobapplications
		WHERE occ_init = 'H-2' 
		OR occ_prop = 'H-2'));