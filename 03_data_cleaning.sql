/*
=============================================================================
Script: 03_data_cleaning.sql
Purpose: To filter out anomalies (negative durations, missing coordinates, 
         staff test rides) and engineer new calculated features like trip 
         duration and day of the week.
Result:  Produces a fully cleaned, analysis-ready table (cleaned_tripdata) 
         with logical trip bounds (1 min to 24 hours) and zero test entries.
=============================================================================
*/
CREATE OR REPLACE TABLE `stable-ring-382611.cyclistic_case_study.cleaned_tripdata` AS

WITH deduplicated_and_casted AS (
  SELECT DISTINCT
    ride_id,
    rideable_type,
    CAST(started_at AS TIMESTAMP) AS started_at,
    CAST(ended_at AS TIMESTAMP) AS ended_at,
    start_station_name,
    end_station_name,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
  FROM `stable-ring-382611.cyclistic_case_study.combined_tripdata`
),
engineered_features AS (
  SELECT 
    *,
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS duration_minutes,
    FORMAT_TIMESTAMP('%A', started_at) AS day_of_week,
    FORMAT_TIMESTAMP('%B', started_at) AS month,
    EXTRACT(HOUR FROM started_at) AS start_hour
  FROM deduplicated_and_casted
)
SELECT *
FROM engineered_features
WHERE 
  end_lat IS NOT NULL 
  AND end_lng IS NOT NULL
  AND duration_minutes >= 1 
  AND duration_minutes <= 1440
  AND COALESCE(LOWER(start_station_name), '') NOT LIKE '%test%'
  AND COALESCE(LOWER(end_station_name), '') NOT LIKE '%test%'
  AND end_lat BETWEEN 41.6 AND 42.1 
  AND end_lng BETWEEN -87.9 AND -87.5
