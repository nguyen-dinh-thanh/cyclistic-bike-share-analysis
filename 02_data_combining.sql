/*
=============================================================================
Script: 02_data_combining.sql
Purpose: To merge 12 separate monthly tables into one master dataset 
         using BigQuery's _TABLE_SUFFIX wildcard.
Result:  Creates a single, unified raw dataset (combined_tripdata) containing nearly 6 million 
         rows representing the full 12-month riding history.
=============================================================================
*/
CREATE OR REPLACE TABLE `stable-ring-382611.cyclistic_case_study.combined_tripdata` AS
SELECT *
FROM `stable-ring-382611.cyclistic_case_study.tripdata_*`
WHERE _TABLE_SUFFIX IN (
    '202501', '202507', '202508', '202509', '202510', '202511', '202512',
    '202602', '202603', '202604', '202605', '202606'
)
