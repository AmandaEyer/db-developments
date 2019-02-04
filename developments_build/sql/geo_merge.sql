UPDATE developments a 
SET geo_bbl = b.bbl, 
    geo_bin = b.bin, 
    geo_address_house = b.hnum, 
    geo_address_street = b.sname, 
    geo_boro = b.bcode, 
    geo_cd = b.cd,
    geo_council = b.council,
    geo_ntacode2010 = b.nta, 
    geo_censusblock2010 = b.cblock, 
    geo_csd = b.csd, 
    latitude = b.lat, 
    longitude = b.lon
FROM development_tmp b
WHERE a.job_number = b.uid;

-- DROP TABLE development_tmp;