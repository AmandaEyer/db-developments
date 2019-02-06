-- set units_init = 0 for new building projects
UPDATE developments
SET units_init = '0'
WHERE units_init IS NULL
AND job_type = 'New Building';

-- set units_prop = 0 for demolition projects
UPDATE developments
SET units_prop = '0'
WHERE units_prop IS NULL
AND job_type = 'Demolition';

-- set units_prop to 0 when multiple dwelling units are coverted to hotels
-- to reflect the loss of residential units when multiple dwellings are converted into hotels (but only for alterations)
UPDATE developments
SET units_prop = '0'
WHERE job_type = 'Alteration' 
	AND (occ_init LIKE '%Residential%'
		OR occ_init LIKE '%Assisted%')
	AND occ_prop LIKE '%Hotel%'
	AND x_mixeduse IS NULL;

-- set units_init to 0 when hotels are converted into multiple dwellings
-- to reflect the gain of residential units when hotels are converted into multiple dwellings (but only for alterations)
UPDATE developments
SET units_init = '0'
WHERE job_type = 'Alteration' 
	AND occ_init LIKE '%Hotel%'
	AND (occ_prop LIKE '%Residential%'
		OR occ_prop LIKE '%Assisted%')
	AND x_mixeduse IS NULL;

-- populate units_net to capture proposed net change in units
-- negative for demolitions, proposed for new buildings, and net change for alterations
-- (note: if an alteration is missing value for existing or proposed units, value set to null)
-- only calculated when both units_init and units_prop are available
UPDATE developments 
SET units_net =
	(CASE
		WHEN job_type = 'Demolition' AND units_init ~ '[0-9]' THEN units_init::numeric * -1
		WHEN job_type = 'New Building' AND units_prop ~ '^[0-9\.]+$' THEN units_prop::numeric
		WHEN job_type = 'Alteration' AND units_init::integer IS NOT NULL AND units_prop::integer IS NOT NULL AND units_prop ~ '^[0-9\.]+$' AND units_init ~ '[0-9]' THEN units_prop::integer - units_init::integer
		ELSE NULL 
	END)
WHERE units_init ~ '[0-9]' AND units_prop ~ '^[0-9\.]+$' AND units_init IS NOT NULL AND units_prop IS NOT NULL;