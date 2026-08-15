-- ==============================================================================
-- Analyze (Phase 4)
-- Objective: Identify behavioral differences between casual riders and annual members.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 1: Total rides & average duration by user type
-- Purpose: To understand the overall volume and trip length differences between the two user groups.
-- ------------------------------------------------------------------------------
SELECT 
  member_casual,
  COUNT(ride_id) AS total_rides,
  ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes
FROM `stable-ring-382611.cyclistic_case_study.cleaned_tripdata`
GROUP BY member_casual;
/*
Insight 1: Casual riders spend significantly more time per ride compared to members, despite having fewer total rides.
*/


-- ------------------------------------------------------------------------------
-- Query 2: Total rides by day of the week
-- Purpose: To identify weekly usage patterns and compare the volume of rides on weekdays versus weekends for both user groups.
-- ------------------------------------------------------------------------------
SELECT 
  day_of_week,
  member_casual,
  COUNT(ride_id) AS total_rides,
  ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes
FROM `stable-ring-382611.cyclistic_case_study.cleaned_tripdata`
GROUP BY day_of_week, member_casual
ORDER BY 
  CASE day_of_week 
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
  END, 
  member_casual;
/*
Insight 2: Casual riders peak during the weekends (Saturday and Sunday), indicating strong usage for leisure activities. In contrast, annual members maintain a consistent and high volume during the weekdays, reflecting a daily commuting routine.
*/


-- ------------------------------------------------------------------------------
-- Query 3: Total rides by hour of the day
-- Purpose: To analyze intra-day usage trends and pinpoint peak hours for casual riders and members.
-- ------------------------------------------------------------------------------
SELECT 
  start_hour,
  member_casual,
  COUNT(ride_id) AS total_rides
FROM `stable-ring-382611.cyclistic_case_study.cleaned_tripdata`
GROUP BY start_hour, member_casual
ORDER BY start_hour, member_casual;

/*
Insight: Annual members exhibit two distinct usage peaks at 8 AM and 5 PM, which strongly aligns with standard office commuting hours. Casual riders show a gradual increase throughout the day, peaking in the late afternoon for leisurely, unhurried rides.
*/
