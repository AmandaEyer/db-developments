#!/bin/bash

# make sure we are at the top of the git directory
REPOLOC="$(git rev-parse --show-toplevel)"
cd $REPOLOC

# load config
DBNAME=$(cat $REPOLOC/developments.config.json | jq -r '.DBNAME')
DBUSER=$(cat $REPOLOC/developments.config.json | jq -r '.DBUSER')

start=$(date +'%T')
echo "Starting to build Developments DB"
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/create.sql
# populate job application data
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/jobnumber.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/clean.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/removejobs.sql
echo 'Transforming data attributes to DCP values'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/bbl.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/address.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/jobtype.sql

## pull out records with a specific occupancy code for manual research
## occupancy codes: A-3 (ASSEMBLY: OTHER), H-2 (HIGH HAZARD: ACCELERATED BURNING)
echo 'Outputting records for research'
## move to QA/QC scripts 
## psql -U $DBUSER -d $DBNAME -c "COPY (SELECT * FROM developments WHERE occ_init = 'A-3' OR occ_prop = 'A-3' OR occ_init = 'H-2' OR occ_prop = 'H-2') TO '$REPOLOC/developments_build/output/qc_occupancyresearch.csv' DELIMITER ',' CSV HEADER;"


echo 'Adding on DCP researched attributes'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/dcpattributes.sql

echo 'Calculating data attributes'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/occ_.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/statusq.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/units_.sql

echo 'Adding on CO data attributes'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/cotable.sql 
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/co_.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/status.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/unitscomplete.sql


echo 'Outputting records for research'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/qc_outlier.sql
psql -U $DBUSER -d $DBNAME -c "COPY (SELECT * FROM qc_outliers WHERE job_number NOT IN (SELECT DISTINCT job_number FROM qc_outliersacrhived WHERE outlier = 'N' OR outlier = 'C')) TO '$REPOLOC/db-developments/developments_build/output/qc_outliers.csv' DELIMITER ',' CSV HEADER;"
psql -U $DBUSER -d $DBNAME -c "COPY (SELECT * FROM qc_outliersacrhived) TO '$REPOLOC/db-developments/developments_build/output/qc_outliersacrhived.csv' DELIMITER ',' CSV HEADER;"


echo 'Populating DCP data flags'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/x_inactive.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/x_mixeduse.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/x_outlier.sql

## not implementing until issue number 8 is addressed
## psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/units_hotels.sql


echo 'Geocoding geoms...'
# Makde sure you have virtual environment named with base created

source $REPOLOC/developments_build/python/base/bin/activate
time python $REPOLOC/developments_build/python/geocode_address_new.py
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/geo_create_tmp.sql
psql -U $DBUSER -d $DBNAME -c "\\COPY development_tmp FROM 'developments_build/python/db-development-geocoding.csv' CSV HEADER;"
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/geo_merge.sql
rm developments_build/python/db-development-geocoding.csv

psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/geoaddress.sql

psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/geombbl.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/geomdcp.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/latlong.sql