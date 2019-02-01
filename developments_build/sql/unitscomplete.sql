UPDATE developments
SET units_complete =
	-- Calculation is not performed if units_net or u_prop were NULL
		(CASE
			WHEN status = 'Complete (demolition)' AND units_net IS NOT NULL THEN units_net
			WHEN co_latest_units IS NULL AND units_net IS NOT NULL THEN '0' 
			WHEN job_type = 'Alteration' AND co_latest_units IS NOT NULL AND units_net IS NOT NULL THEN (co_latest_units::numeric - units_init::numeric)::text
			WHEN job_type = 'Alteration' AND status = 'Complete' AND units_net IS NOT NULL THEN units_net
			WHEN job_type = 'New Building' AND co_latest_units IS NOT NULL AND units_net IS NOT NULL THEN co_latest_units
		END),
	units_incomplete =
		(CASE 
			WHEN units_net IS NOT NULL AND status LIKE '%Complete%' THEN '0'
			WHEN units_net IS NOT NULL AND status <> 'Complete' THEN (units_net::numeric - units_complete::numeric)::text
			WHEN job_type = 'Alteration' AND status <> 'Complete' AND units_net IS NOT NULL THEN units_net
			WHEN units_net IS NULL AND units_prop IS NOT NULL AND co_latest_units IS NOT NULL THEN (units_prop::numeric - co_latest_units::numeric)::text
			ELSE units_net
		END);