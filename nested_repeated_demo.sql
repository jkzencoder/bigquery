-- Constructing/accessing/filtering Struct
SELECT STRUCT('magic street' AS street, 'Vancouver' AS city, 'BC' AS province, 'V6T 1Z4' AS postal_code) AS address;

WITH addresses AS 
(
  SELECT STRUCT('magic street' AS street, 'Vancouver' AS city, 'BC' AS province, 'V6T 1Z4' AS postal_code) AS address
  UNION ALL SELECT ('magic street', 'Toronto', 'ON', 'M5S 1A1')
)
SELECT address.postal_code
FROM addresses;

-- Constructing Array
SELECT [1, 3, 4] AS arr;

-- using ARRAY()
-- double the value of array elements and only keep the elements less than 6
WITH arrays AS
  (SELECT [1, 2, 3, 4] AS nums
  UNION ALL SELECT [2, 4, 6, 8, 10] AS nums)
SELECT 
  nums,
  ARRAY(SELECT x * 2 FROM UNNEST(nums) AS x WHERE x<6) AS doubled_greater_than_six
FROM arrays;


-- ARRAY_AGG(): aggregate values into an array
WITH items AS
  (SELECT "category1" AS category, 10 AS value
   UNION ALL SELECT "category2", 20
   UNION ALL SELECT "category1", 30
   UNION ALL SELECT "category2", 40
   UNION ALL SELECT "category3", 50
   )
SELECT category, ARRAY_AGG(value) AS category_values
FROM items
GROUP BY category;
-- Results:
-- category1, [10, 30]
-- category2, [20, 40]
-- category3, [50]

-- GENERATE_ARRAY(start_expression, end_expression[, step_expression])
SELECT GENERATE_ARRAY(0, 5) AS arr; -- [0, 1, 2, 3, 4, 5]

SELECT GENERATE_ARRAY(0, 10, 4) AS arr; -- [0, 4, 8]

SELECT GENERATE_ARRAY(10, 0, -4) AS arr; -- [10, 6, 2]

-- GENERATE_DATE_ARRAY(start_date, end_date[, INTERVAL INT64_expr date_part])
-- Allowed date_part values are: DAY, WEEK, MONTH, QUARTER, or YEAR
SELECT GENERATE_DATE_ARRAY('2023-01-05', '2023-01-10') AS dates;

SELECT GENERATE_DATE_ARRAY('2023-01-01', '2023-12-01', INTERVAL 1 MONTH) AS dates;

SELECT GENERATE_DATE_ARRAY('2023-12-01', '2023-01-01', INTERVAL -2 MONTH) AS dates;


-- GENERATE_TIMESTAMP_ARRAY(start_timestamp, end_timestamp, INTERVAL step_expression date_part)
-- Allowed date_part values are: MICROSECOND, MILLISECOND, SECOND, MINUTE, HOUR, or DAY
SELECT GENERATE_TIMESTAMP_ARRAY('2023-01-05 00:00:00', '2023-01-05 12:00:00', INTERVAL 2 HOUR) AS timestamps;

SELECT GENERATE_TIMESTAMP_ARRAY('2023-01-05 12:00:00', '2023-01-05 00:00:00', INTERVAL -2 HOUR) AS timestamps;

-- Accessing Array Elements
SELECT[1,2][OFFSET(0)]; -- result: 1
SELECT[1,2][ORDINAL(1)]; -- result: 1
SELECT[1,2][ORDINAL(0)]; -- result: error
SELECT[1,2][SAFE_OFFSET(2)]; -- result: null (not throw error)

-- Flattern Array
SELECT
  *
FROM
  UNNEST([1, 2, 3, 4]) AS unnest_column WITH OFFSET AS `offset`;

-- Filtering Array 
-- IN(): returns the array contains element 8
WITH
  Sequences AS (
    SELECT [1, 2, 4] AS numbers
    UNION ALL
    SELECT [2, 4, 8]
    UNION ALL
    SELECT [5, 10]
  )
SELECT numbers 
FROM Sequences
WHERE 8 IN UNNEST(Sequences.numbers);


-- EXISTS(): output arrays contains elements greater than 5. second and third array will be returned
WITH
  Sequences AS (
    SELECT [1, 2, 4] AS numbers
    UNION ALL
    SELECT [2, 4, 8]
    UNION ALL
    SELECT [5, 10]
  )
SELECT numbers 
FROM Sequences
WHERE EXISTS(SELECT * FROM UNNEST(numbers) AS n WHERE n > 5);

-- Other Array Functions

-- ARRAY_LENGTH: returns the size of the array
SELECT ARRAY_LENGTH([1, 3, 5]) as len;


-- ARRAY_CONCAT_AGG: concatenates the elements of an array column across rows
SELECT first_name, ARRAY_CONCAT_AGG(phonenumbers) AS all_phonenumbers
FROM demo.employee
GROUP BY first_name;

-- ARRAY_CONCAT: concatenates arrays with the same data type into one single array
SELECT ARRAY_CONCAT([1, 3, 5], [2, 4, 6]) as example;

-- ARRAY_TO_STRING: concatenation of STRING or BYTES array elements
-- ignore null values
SELECT ARRAY_TO_STRING(['apple','peach', null, 'orange'], '/') AS text; -- apple/peach/orange

-- replact null with NA
SELECT ARRAY_TO_STRING(['apple','peach', null, 'orange'], '/', 'NA') AS text; -- apple/peach/NA/orange

-- ARRAY_REVERSE: returns the array with elements in reversed order
SELECT ARRAY_REVERSE([1, 2, 3, 4]) AS reverse_arr;


-- create employee table
CREATE TABLE IF NOT EXISTS demo.employee (
  id STRING,
  first_name STRING,
  last_name STRING,
  phonenumbers
    ARRAY<
      STRUCT<
        type STRING,
        phone_number STRING
      >
    >,
  address
      STRUCT<
        street STRING,
        city STRING,
        province STRING,
        postal_code STRING
      >
) OPTIONS (
    description = 'Employee information table');


-- insert data to the table
-- use [] for array, use () for struct
INSERT demo.employee
VALUES('00001', 'John', 'Smith', [('home', '123-456-7891'), ('cell', '123-456-7892')], ('magic street', 'Vancouver', 'BC', 'V6T 1Z4')),
      ('00002', 'Mary', 'Cook', [('home', '123-456-7893'), ('cell', '123-456-7894')], ('magic street', 'Toronto', 'ON', 'M5S 1A1')),
      ('00003', 'Linda', 'Green', [('home', '123-456-7895'), ('cell', '123-456-7896')], ('magic street', 'Montréal', 'QC', 'H3A 0G4'));

-- select province='BC'
SELECT
  id,
  first_name,
  last_name,
  address
FROM
  demo.employee
WHERE
  address.province = 'BC'
ORDER BY id;

-- update individual field of a struct column
UPDATE demo.employee
SET address.street = 'John new street'
WHERE first_name='John';

SELECT address 
FROM demo.employee 
WHERE first_name='John';

-- update all fields of a struct column
UPDATE demo.employee
SET address = ('magic street', 'London', 'ON', 'N6A 3K7')
WHERE first_name='John';


-- select by index, start with 0 (0-based)
SELECT
  id,
  first_name,
  last_name,
  phonenumbers[OFFSET(0)] as phonenumber
FROM
  demo.employee
ORDER BY id;

-- select by ordinal, start with 1 (1-based)
SELECT
  id,
  first_name,
  last_name,
  phonenumbers[ORDINAL(1)] as phonenumber
FROM
  demo.employee
ORDER BY id;

-- select home phone numbers
SELECT
  id,
  first_name,
  last_name,
  p.type,
  p.phone_number
FROM
  demo.employee CROSS JOIN UNNEST(phonenumbers) AS p
WHERE
  p.type = 'home'
ORDER BY id;

-- update array field
-- UPDATE ... SET does not support array modification with [] 
UPDATE demo.employee
SET phonenumbers[offset(0)].phone_number = '987-654-1234'
WHERE first_name='John';

UPDATE demo.employee
SET phonenumbers[offset(0)] = ('home1', '987-654-1234')
WHERE first_name='John';

-- add a new phonenumber: 'emergency'
UPDATE demo.employee
SET phonenumbers = ARRAY(
  SELECT p FROM UNNEST(phonenumbers) AS p
  UNION ALL
  SELECT ('emergency', '987-654-1234')
)
WHERE first_name='John';

UPDATE demo.employee
SET phonenumbers = ARRAY_CONCAT(phonenumbers,[('emergency', '987-654-1234')])
WHERE first_name='John';

SELECT phonenumbers 
FROM demo.employee 
WHERE first_name='John';

-- update 'emergency' phone number
UPDATE demo.employee
SET phonenumbers = ARRAY(
    SELECT (type, IF(type = 'emergency', '987-654-4321' , phone_number)) 
    FROM UNNEST(phonenumbers)
  ) 
WHERE first_name='John';

-- delete 'emergency' phone number
UPDATE demo.employee
SET phonenumbers = ARRAY(
  SELECT p FROM UNNEST(phonenumbers) AS p
  WHERE p.type!='emergency'
)
WHERE first_name='John';


-- Array of Arrays
-- this will give you an error: nested arrays are not supported
WITH arrs AS
  (SELECT [1, 3, 4] AS arr
   UNION ALL SELECT [2, 4, 6] AS arr
   UNION ALL SELECT [0, 9, 7] AS arr)
SELECT ARRAY(
  SELECT arr
  FROM arrs)
  AS arr_of_arrs;

-- have to create STRUCT containing the array field
WITH arrs AS
  (SELECT [1, 3, 4] AS arr
   UNION ALL SELECT [2, 4, 6] AS arr
   UNION ALL SELECT [0, 9, 7] AS arr)
SELECT ARRAY(
  SELECT STRUCT(arr)
  FROM arrs)
  AS arr_of_arrs;


