# Cyclistic Bike-Share Case Study: Converting Casual Riders

## 📝 Introduction
Cyclistic is a successful bike-share program based in Chicago. The company offers casual riding passes and annual memberships. The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. This project analyzes historical trip data to uncover the distinct usage behaviors between casual riders and annual members to drive future marketing strategies.

### The Business Task
Analyze Cyclistic's historical bike trip data to identify differences in usage habits between casual riders and annual members. These data-backed insights will guide marketing strategies aimed at converting casual riders into annual members.

### Core Question
How do annual members and casual riders use Cyclistic bikes differently?

### Key Stakeholders
* **Lily Moreno:** Director of Marketing and direct manager.
* **Cyclistic Marketing Analytics Team:** Fellow data analysts responsible for collecting and reporting data.
* **Cyclistic Executive Team:** The detail-oriented team responsible for approving the recommended marketing program.*

## 🛠 Data Preparation & Processing
### Data Source & Organization:
The data source used consists of Cyclistic's historical trip datasets covering the previous 12 months, made publicly available by Motivate International Inc. The data is organized in monthly/quarterly CSV files. Key features include ride ID, bike type, start and end timestamps, start and end station names/IDs, geographic coordinates, and customer category (casual rider or annual member).

### Data Credibility (ROCCC):
* **Reliable & Original:** First-party data directly captured from Cyclistic's tracking and station system.
* **Comprehensive & Current:** Covers a large volume of trips across the most recent 12-month period, reflecting up-to-date user trends without sampling bias.
* **Cited:** Officially made available under a license by Motivate International Inc.
* **Privacy & Security:** Personally identifiable information (PII) such as rider names or credit card details has been excluded to preserve privacy and ensure compliance with data protection standards. Due to privacy regulations, individual user behavior cannot be tracked longitudinally or mapped to specific residential locations.

### Data Cleaning & Feature Engineering
```SQL
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
  AND end_lng BETWEEN -87.9 AND -87.5;
```
## 📊 Analysis & Visualization
### Analysis
***Objective:** Identify behavioral differences between casual riders and annual members.*

#### Query 1: Total rides & average duration by user type
***Purpose:** To understand the overall volume and trip length differences between the two user groups.*
```sql
SELECT 
  member_casual,
  COUNT(ride_id) AS total_rides,
  ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes
FROM `stable-ring-382611.cyclistic_case_study.cleaned_tripdata`
GROUP BY member_casual;
```
***Insight:** Casual riders spend significantly more time per ride compared to members, despite having fewer total rides.*

---

#### Query 2: Total rides by day of the week
***Purpose:** To identify weekly usage patterns and compare the volume of rides on weekdays versus weekends for both user groups.*
```sql
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
  ```
***Insight:** Casual riders peak during the weekends (Saturday and Sunday), indicating strong usage for leisure activities. In contrast, annual members maintain a consistent and high volume during the weekdays, reflecting a daily commuting routine.*

---

#### Query 3: Total rides by hour of the day
***Purpose:** To analyze intra-day usage trends and pinpoint peak hours for casual riders and members.*
```sql
SELECT 
  start_hour,
  member_casual,
  COUNT(ride_id) AS total_rides
FROM `stable-ring-382611.cyclistic_case_study.cleaned_tripdata`
GROUP BY start_hour, member_casual
ORDER BY start_hour, member_casual;
```
***Insight:** Annual members exhibit two distinct usage peaks at 8 AM and 5 PM, which strongly aligns with standard office commuting hours. Casual riders show a gradual increase throughout the day, peaking in the late afternoon for leisurely, unhurried rides.*

### Visualization
*To effectively communicate the differences between "Commuters" (members) and "Leisure Riders" (casuals) to the Executive Team, I built an interactive dashboard using Tableau and embedded it into this notebook.*

<img width="999" height="799" alt="Cyclistic Bike-Share_ Member vs  Casual Riders Analysis" src="https://github.com/user-attachments/assets/c5e8ed92-9f3a-41d1-96a7-2c7fc56f2e3e" />

*As shown in the interactive dashboard above, casual riders ride longer for leisure on weekends, while members commute daily during peak hours.*

https://public.tableau.com/views/VizofCyclisticBike/CyclisticBike-ShareMembervs_CasualRidersAnalysis?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link

## 💡 Strategic Recommendations (Act Phase)

### Conclusion
Through comprehensive analysis using Python and SQL, the data clearly defines the underlying differences in usage behaviors. Annual members primarily use bikes for daily, routine commuting with shorter ride durations on weekdays. In contrast, casual riders use bikes for leisure and tourism, with significantly longer ride durations concentrated on weekends and during the summer.

### Solutions & Strategic Recommendations
To convert casual riders into annual members, Cyclistic should avoid pitching "daily commute savings" and instead focus messaging on maximizing savings on leisure activities and weekend rides.

1. **Introduce Flexible Leisure-Oriented Passes:** Launch a seasonal "Summer Membership" or a "Weekend Member Pass," featuring a credit-rollover option where pass fees can be applied toward upgrading to a full Annual Membership.
   * **Pros:** Lowers the entry barrier for casual riders; encourages gradual transition to annual plans.
   * **Cons:** Requires adjustments to the current billing and app infrastructure.
2. **Execute Time- and Location-Targeted Digital Campaigns:** Focus digital ad spending (social media, in-app push notifications) around high-traffic casual stations near parks, waterfronts, and tourist destinations.
   * **Pros:** High ROI on marketing budget by targeting the right audience at the right time.
   * **Cons:** May miss casual riders who ride outside of these specific "hot zones."
3. **Implement Gamification & Cost Comparison:** Introduce an in-app feature highlighting cost comparisons: "You spent $X on single passes this month. An Annual Membership would have saved you $Y!"
   * **Pros:** Provides a strong, personalized financial incentive to upgrade based on the user's actual behavior.
   * **Cons:** Requires development time from the software engineering team to integrate dynamic messaging.

### Next Steps & Action Plan
* **Who:** The Cyclistic Marketing Analytics Team & Digital Marketing Team.
* **What:** Pilot a targeted digital marketing campaign using the "Cost Comparison" messaging across email and social media channels. Gather supplementary data, specifically weather patterns and financial pricing models, to refine the break-even point for riders.
* **When:** Launch the pilot campaign in May, exactly 4 weeks ahead of the upcoming summer peak season. Track and evaluate the casual-to-member conversion rate throughout the summer months to determine campaign efficacy.


## 🧠 Project Retrospective & Learnings
* Stepping outside the hypothetical business scenario, working on this case study provided invaluable hands-on experience with real-world data engineering challenges.

* The most significant hurdle I encountered was environment compatibility during the data ingestion phase. Initially, I wrote a Python script in Google Colab to automate pushing 12 massive CSV files from Google Drive to BigQuery to overcome standard upload limits. However, when migrating the portfolio project to Kaggle, I quickly realized that the google.colab library (specifically the authentication and Drive mounting functions) was entirely incompatible with the Kaggle environment.

* To resolve this, I had to adapt my workflow. Instead of relying on Google Drive, I sourced the dataset directly within Kaggle and modified my Python script to dynamically read from Kaggle's ../input/ directory using the os and glob libraries. This allowed the pandas.to_gbq() function to successfully push the data to BigQuery without relying on external dependencies.

* This roadblock turned into a highly rewarding learning opportunity. It not only strengthened my Python programming skills but also taught me the importance of writing adaptable code, troubleshooting environment-specific limitations, and independently researching technical workarounds—essential problem-solving skills for any data professional.
