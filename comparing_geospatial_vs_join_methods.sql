-- Add indexes
CREATE INDEX ind_ac_count
	ON data_loading_acrecord(observation_count);

CREATE INDEX ind_pol_id
	ON data_loading_worldborder(id);


-- Update count values. If the value of observation_count is null, update with 1
-- because for sure at least 1 a. cristatellus was observed

SELECT COUNT(*) FROM data_loading_acrecord
	WHERE observation_count IS NULL; -- 14365 records

UPDATE data_loading_acrecord
	SET observation_count = 1
	WHERE observation_count IS NULL;  -- 14365 records were updated

-- Number of observations events per country (rows per country)
SELECT COUNT(country_code) FROM data_loading_acrecord
	GROUP BY country_code;
	
-- Total count of ac. cristatellus individuals per country
SELECT country_code, SUM(observation_count) FROM data_loading_acrecord
	GROUP BY country_code;

-- Add geometry point to ac data
ALTER TABLE data_loading_acrecord ADD COLUMN geom geometry(Point, 4326);
UPDATE data_loading_acrecord 
	SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

-- Comparing with results obtained by geoprocessing
SELECT 
	wb.iso2,
	COUNT(ac.country_code)
	FROM data_loading_acrecord ac, data_loading_country wb
	WHERE ST_WITHIN(ac.geom, wb.geom)
	GROUP BY wb.iso2;

-- Create table to save summary information by country
-- DROP TABLE ac_by_country;

CREATE TABLE ac_by_country(
	id SERIAL,
	iso2 VARCHAR,
	total_events INT,
	total_birds INT,
	geom GEOMETRY(MULTIPOLYGON, 4326)
)

-- Total count of ac. cristatellus individuals per country per year
SELECT country_code, SUM(observation_count), year FROM data_loading_acrecord
	GROUP BY country_code, year
	ORDER BY country_code, year ASC;

-- insert data into countrywithacrecord table
INSERT INTO data_loading_countrywithacrecord(name, iso2, geom)
SELECT DISTINCT ON (ac.country_code) 
	ct.name,
	ac.country_code,
	ct.geom
FROM data_loading_acrecord ac, data_loading_country ct 
WHERE ct.iso2 = ac.country_code;

-- Update total observations events
UPDATE data_loading_countrywithacrecord AS ct
SET tot_observations_events = ac.record_count
FROM (
    SELECT country_code, COUNT(*) AS record_count
    FROM data_loading_acrecord
    GROUP BY country_code
) AS ac
WHERE ac.country_code = ct.iso2;

-- Update total birds count
UPDATE data_loading_countrywithacrecord AS ct
SET tot_birds_count = ac.birds_count
FROM (
    SELECT 
		SUM(observation_count) AS birds_count,
		country_code
    FROM data_loading_acrecord
    GROUP BY country_code
) AS ac
WHERE ac.country_code = ct.iso2;


-- Assert that count is ok
SELECT SUM(observation_count) FROM data_loading_acrecord
	WHERE country_code = 'AR';
