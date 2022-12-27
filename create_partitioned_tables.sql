-- partition on DATE column, daily
CREATE TABLE `<your_project>.<your_dataset>.mytable` 
  (
    my_date DATE
  ) 
  PARTITION BY
    my_date
  OPTIONS (
    partition_expiration_days = 90,
    require_partition_filter = TRUE)

-- <Note>: two special partitions are created as well
-- __NULL__: contains rows with my_date is NULL values
--__UNPARTITIONED__: contains rows with my_date that is earlier than 1960-01-01 or later than 2159-12-31


-- partition on DATE column, monthly
CREATE TABLE `<your_project>.<your_dataset>.mytable` 
  (
    my_date DATE
  ) 
  PARTITION BY
    DATE_TRUNC(my_date, MONTH)
  OPTIONS (
    partition_expiration_days = 90,
    require_partition_filter = TRUE)

-- partition on TIMESTAMP column, daily
CREATE TABLE `<your_project>.<your_dataset>.mytable` 
  (
    my_time TIMESTAMP
  ) 
  PARTITION BY
    TIMESTAMP_TRUNC(my_time, DAY)
  OPTIONS (
    partition_expiration_days = 90,
    require_partition_filter = TRUE)


-- partition on ingestion time, hourly
CREATE TABLE `<your_project>.<your_dataset>.mytable` 
  (
    my_col STRING
  ) 
  PARTITION BY
    TIMESTAMP_TRUNC(_PARTITIONTIME, HOUR)
  OPTIONS (
    partition_expiration_days = 90,
    require_partition_filter = TRUE)


-- partition on ingestion time, daily
CREATE TABLE `<your_project>.<your_dataset>.mytable` 
  (
    my_col STRING
  ) 
  PARTITION BY
    _PARTITIONDATE -- same as DATE_TRUNC(_PARTITIONTIME, DAY)
  OPTIONS (
    partition_expiration_days = 90,
    require_partition_filter = TRUE)


-- partition on integer column
CREATE TABLE `<your_project>.<your_dataset>.mytable` 
  (
    department_id INTEGER
  ) 
  PARTITION BY
    -- start:1, end:100, interval:1
    RANGE_BUCKET(department_id, GENERATE_ARRAY(1, 100, 1))
  OPTIONS (
    require_partition_filter = TRUE);

-- <Note>: two special partitions are created as well
-- __NULL__: contains rows with department_id is NULL values
--__UNPARTITIONED__: contains rows with department_id whose values are outside the range
