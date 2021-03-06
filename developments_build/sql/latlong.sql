-- set the latitude and longitude
UPDATE developments
SET latitude = ST_Y(geom),
	longitude = ST_X(geom)
	WHERE geom IS NOT NULL;
-- If there is no geometry but there is a lat / long then create the geometry
UPDATE developments
SET geom = ST_SetSRID(ST_MakePoint(longitude::double precision, latitude::double precision), 4326)
WHERE geom IS NULL AND longitude IS NOT NULL;