CREATE OR REPLACE TABLE `stable-ring-382611.cyclistic_case_study.combined_tripdata` AS
SELECT *
FROM `stable-ring-382611.cyclistic_case_study.tripdata_*`
WHERE _TABLE_SUFFIX IN (
    '202501', '202507', '202508', '202509', '202510', '202511', '202512',
    '202602', '202603', '202604', '202605', '202606'
)
