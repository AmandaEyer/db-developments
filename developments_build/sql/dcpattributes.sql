-- overwite DOB data with DCP researched values
-- where DCP reseached value is valid
UPDATE developments a
SET stories_prop = TRIM(b.prop_stories),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.prop_stories ~ '[0-9]'
	AND a.job_number=b.job_number;

UPDATE developments a
SET occ_init = TRIM(b.occ_init),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.occ_init IS NOT NULL
	AND a.job_number=b.job_number;

UPDATE developments a
SET occ_prop = TRIM(b.dcp_occ_pr),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.dcp_occ_pr IS NOT NULL
	AND a.job_number=b.job_number;

UPDATE developments a
SET occ_category = TRIM(b.dcp_occ_category),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.dcp_occ_category IS NOT NULL
	AND a.job_number=b.job_number;

UPDATE developments a
SET units_init = TRIM(b.units_init),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.units_init ~ '[0-9]'
	AND b.units_init IS NOT NULL
	AND a.job_number=b.job_number;

UPDATE developments a
SET units_prop = TRIM(b.units_prop_res),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.units_prop_res ~ '[0-9]'
	AND b.units_prop_res IS NOT NULL
	AND a.job_number=b.job_number;

UPDATE developments a
SET units_prop = TRIM(b.units_prop),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.units_prop ~ '[0-9]'
	AND a.job_number=b.job_number
	AND b.units_prop_res IS NULL;

UPDATE developments a
SET units_complete = TRIM(b.u_net_comp),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.u_net_inc ~ '[0-9]'
	AND a.job_number=b.job_number;

UPDATE developments a
SET units_incomplete = TRIM(b.u_net_inc),
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE b.u_net_inc ~ '[0-9]'
	AND a.job_number=b.job_number;

UPDATE developments a
SET x_mixeduse = TRUE,
	x_dcpedited = TRUE,
	x_reason = b.reason
FROM housing_input_dcpattributes b
WHERE upper(b.x_mixeduse) = 'TRUE'
	AND a.job_number=b.job_number;

-- UPDATE developments a
-- SET co_latest_units = TRIM(b.c_u_latest),
-- 	x_dcpedited = TRUE,
-- 	x_reason = b.reason
-- FROM housing_input_dcpattributes b
-- WHERE b.c_u_latest ~ '[0-9]'
-- 	AND a.job_number=b.job_number;

-- UPDATE developments a
-- SET x_inactive = TRIM(b.x_inactive),
-- 	x_dcpedited = TRUE,
-- 	x_reason = b.reason
-- FROM housing_input_dcpattributes b
-- WHERE b.x_inactive IS NOT NULL
-- 	AND a.job_number=b.job_number;