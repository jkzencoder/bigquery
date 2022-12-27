-- select subset of `bigquery-public-data.google_trends.international_top_terms` to `<your_project>.<your_dataset>.top_terms_original` 
CREATE OR REPLACE TABLE `<your_project>.<your_dataset>.top_terms_original`
(
  week DATE,
  country_name STRING,
  country_code STRING,
  region_name STRING,
  region_code STRING,
  term STRING,
  score INT64,
  rank INT64
)
AS (
  SELECT 
    week,
    country_name,
    country_code,
    region_name,
    region_code,
    term,
    score,
    rank
FROM `bigquery-public-data.google_trends.international_top_terms` 
WHERE refresh_date = "2022-12-23" 
);

-- create partitioned table
CREATE OR REPLACE TABLE `<your_project>.<your_dataset>.top_terms_partitioned` 
  (
    week DATE,
    country_name STRING,
    country_code STRING,
    region_name STRING,
    region_code STRING,
    term STRING,
    score INT64,
    rank INT64
  ) 
  PARTITION BY
    week
  OPTIONS (
    partition_expiration_days = 2000,
    require_partition_filter = TRUE)
  AS 
  (
  SELECT
    *
  FROM
    `<your_project>.<your_dataset>.top_terms_original` 
  );


-- create clustering table
CREATE OR REPLACE TABLE `<your_project>.<your_dataset>.top_terms_clustered` 
  ( 
    week DATE,
    country_name STRING,
    country_code STRING,
    region_name STRING,
    region_code STRING,
    term STRING,
    score INT64,
    rank INT64
  ) 
  CLUSTER BY
    country_name, region_name
  AS 
  (
  SELECT
    *
  FROM
    `<your_project>.<your_dataset>.top_terms_original` 
  );

-- create partitioned and clustered table
CREATE OR REPLACE TABLE `<your_project>.<your_dataset>.top_terms_partitioned_clustered` 
  ( 
    week DATE,
    country_name STRING,
    country_code STRING,
    region_name STRING,
    region_code STRING,
    term STRING,
    score INT64,
    rank INT64
  ) 
  PARTITION BY
    week
  CLUSTER BY
    country_name, region_name
  OPTIONS (
    partition_expiration_days = 2000,
    require_partition_filter = TRUE)
  AS 
  (
  SELECT
    *
  FROM
    `<your_project>.<your_dataset>.top_terms_original` 
  );


-- select top three terms in each region of Canada
SELECT region_name, rank, term
FROM `<your_project>.<your_dataset>.top_terms_original` 
WHERE week='2022-12-18'
  AND country_name='Canada'
  AND rank<=3
ORDER BY region_name, rank