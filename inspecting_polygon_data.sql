-- INSPECTING DATA

-- total polygons
SELECT COUNT(*) FROM data_loading_country; -- 246 countries

-- VALIDITY OF POLYGONS
-- To see about the topic: https://postgis.net/workshops/postgis-intro/validity.html

-- Are all the features valid?

SELECT id, name, ST_IsValid(geom) from data_loading_country;

-- DROP VIEW valid_geom_view; -- drop view if necessary
-- Save valid geometries in a View
CREATE OR REPLACE VIEW valid_geom_view AS
SELECT 
	id, 
	name, 
	ST_MakeValid(geom) as valid_geom,
FROM data_loading_country;

-- Analize if all the geometries are now valid
SELECT id, name, ST_IsValid(valid_geom) from valid_geom_view
	WHERE ST_IsValid(valid_geom) = false;  -- 0 rows with invalid geometries

SELECT COUNT(*) from valid_geom_view
	WHERE ST_IsValid(valid_geom) = true; -- 246 countries are valid

-- SIMPLIFY POLYGONS

-- Before simplifying
SELECT SUM(ST_NumGeometries(geom))
FROM data_loading_country; -- 3775 total geometries

-- Create table with simplified polygons
CREATE TABLE simplified_valid_pol AS
SELECT 
	id, 
	name, 
	ST_Simplify(valid_geom, 0.01) as geom
FROM valid_geom_view;

-- After Simplifying
SELECT SUM(ST_NumGeometries(geom))
FROM simplified_valid_pol; -- 3587 total geometries

-- After creating the table and saving it as .shp with Qgis,
-- its size was 1.84 MB vs 6.20 MB of the original .shp.

