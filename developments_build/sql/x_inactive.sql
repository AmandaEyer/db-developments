-- Tag projects that have been inactive for at least 2 years
UPDATE developments
	SET x_inactive = TRUE
	WHERE status = 'In progress (last plan disapproved)'
	AND (CURRENT_DATE - status_date::date)/365 >= 2;

-- Tag projects that have been inactive for at least 3 years
UPDATE developments
	SET x_inactive = TRUE
	WHERE status = 'Filed'
	AND (CURRENT_DATE - status_date::date)/365 >= 3;

UPDATE developments
	SET x_inactive = TRUE
	WHERE status = 'In progress'
	AND (CURRENT_DATE - status_date::date)/365 >= 3;

UPDATE developments
	SET x_inactive = FALSE
	WHERE x_inactive IS NULL;