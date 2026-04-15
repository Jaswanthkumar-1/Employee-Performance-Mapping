-- ============================================================
-- SCIENCEQTECH EMPLOYEE PERFORMANCE MAPPING
-- Course-End Project | All 17 SQL Queries
-- ============================================================

-- ============================================================
-- Q1: Create database and import tables
-- ============================================================
CREATE DATABASE IF NOT EXISTS employee;
USE employee;

-- Import CSV files via MySQL Workbench:
-- Table Wizard > emp_record_table.csv
-- Table Wizard > proj_table.csv
-- Table Wizard > data_science_team.csv

-- ============================================================
-- Q2: ER Diagram (see ER_Diagram.png in Docs/)
-- Relationships:
--   emp_record_table.EMP_ID    -> data_science_team.EMP_ID
--   emp_record_table.PROJ_ID   -> proj_table.PROJECT_ID
--   emp_record_table.MANAGER_ID -> emp_record_table.EMP_ID
-- ============================================================

-- ============================================================
-- Q3: Fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
-- ============================================================
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    DEPT
FROM emp_record_table;

-- Output: 19 rows — all employees with department info

-- ============================================================
-- Q4: Fetch employees based on EMP_RATING conditions
-- ============================================================

-- 4a: EMP_RATING less than 2
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING < 2;
-- Output: 3 employees (Dorothy Wilson, Claire Brennan, Katrina Allen)

-- 4b: EMP_RATING greater than 4
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING > 4;
-- Output: 4 employees with rating = 5

-- 4c: EMP_RATING between 2 and 4
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING BETWEEN 2 AND 4;
-- Output: 12 employees

-- ============================================================
-- Q5: Concatenate FIRST_NAME and LAST_NAME for Finance dept
-- ============================================================
SELECT
    CONCAT(FIRST_NAME, ' ', LAST_NAME) AS NAME
FROM emp_record_table
WHERE DEPT = 'FINANCE';

-- Output: Eric Hoffman | Emily Grove | Steve Hoffman

-- ============================================================
-- Q6: Employees who have someone reporting to them
-- ============================================================
SELECT
    e.EMP_ID,
    e.FIRST_NAME,
    e.LAST_NAME,
    COUNT(r.EMP_ID) AS NUM_REPORTERS
FROM emp_record_table e
JOIN emp_record_table r
    ON e.EMP_ID = r.MANAGER_ID
GROUP BY e.EMP_ID
HAVING COUNT(r.EMP_ID) > 0;

-- Output: 6 managers (Arthur Black leads with 5 reporters)

-- ============================================================
-- Q7: Healthcare and Finance employees using UNION
-- ============================================================
SELECT EMP_ID, FIRST_NAME, LAST_NAME, DEPT
FROM emp_record_table
WHERE DEPT = 'HEALTHCARE'
UNION
SELECT EMP_ID, FIRST_NAME, LAST_NAME, DEPT
FROM emp_record_table
WHERE DEPT = 'FINANCE';

-- Output: 7 employees (4 Healthcare + 3 Finance)

-- ============================================================
-- Q8: Employee details grouped by dept with max dept rating
-- ============================================================
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    ROLE,
    DEPT,
    EMP_RATING,
    MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS MAX_DEPT_RATING
FROM emp_record_table
ORDER BY DEPT;

-- Output: 19 rows with each employee's rating vs dept max

-- ============================================================
-- Q9: Minimum and maximum salary per role
-- ============================================================
SELECT
    ROLE,
    MIN(SALARY) AS MIN_SALARY,
    MAX(SALARY) AS MAX_SALARY
FROM emp_record_table
GROUP BY ROLE;

-- Output:
-- PRESIDENT            16500   16500
-- LEAD DATA SCIENTIST   8500    9000
-- SENIOR DATA SCIENTIST 5500    7700
-- MANAGER               8500   11000
-- ASSOCIATE DATA SCIENT 4000    5000
-- JUNIOR DATA SCIENTIST 2800    3000

-- ============================================================
-- Q10: Rank employees based on experience
-- ============================================================
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    EXP,
    RANK() OVER (ORDER BY EXP DESC) AS EXP_RANK
FROM emp_record_table;

-- Output: Arthur Black (20 yrs) ranked #1, Jenifer Jhones (1 yr) ranked #19

-- ============================================================
-- Q11: View — employees with salary > 6000
-- ============================================================
CREATE VIEW high_salary_employees AS
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    COUNTRY,
    SALARY
FROM emp_record_table
WHERE SALARY > 6000;

SELECT * FROM high_salary_employees;

-- Output: 12 employees earning above $6,000

-- ============================================================
-- Q12: Nested query — employees with EXP > 10 years
-- ============================================================
SELECT *
FROM emp_record_table
WHERE EMP_ID IN (
    SELECT EMP_ID
    FROM emp_record_table
    WHERE EXP > 10
);

-- Output: 8 employees with more than 10 years experience

-- ============================================================
-- Q13: Stored procedure — employees with EXP > 3 years
-- ============================================================
DELIMITER $$
CREATE PROCEDURE get_experienced_employees()
BEGIN
    SELECT *
    FROM emp_record_table
    WHERE EXP > 3;
END $$
DELIMITER ;

CALL get_experienced_employees();

-- Output: All employees with more than 3 years of experience

-- ============================================================
-- Q14: Stored function — check job profile standard
-- Standard:
--   EXP <= 2          -> JUNIOR DATA SCIENTIST
--   EXP 2 to 5        -> ASSOCIATE DATA SCIENTIST
--   EXP 5 to 10       -> SENIOR DATA SCIENTIST
--   EXP 10 to 12      -> LEAD DATA SCIENTIST
--   EXP 12 to 16      -> MANAGER
-- ============================================================
DELIMITER $$
CREATE FUNCTION get_expected_role(exp_years INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE expected VARCHAR(50);
    IF exp_years <= 2 THEN
        SET expected = 'JUNIOR DATA SCIENTIST';
    ELSEIF exp_years <= 5 THEN
        SET expected = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF exp_years <= 10 THEN
        SET expected = 'SENIOR DATA SCIENTIST';
    ELSEIF exp_years <= 12 THEN
        SET expected = 'LEAD DATA SCIENTIST';
    ELSE
        SET expected = 'MANAGER';
    END IF;
    RETURN expected;
END $$
DELIMITER ;

SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    EXP,
    ROLE                       AS ASSIGNED_ROLE,
    get_expected_role(EXP)     AS EXPECTED_ROLE,
    IF(ROLE = get_expected_role(EXP), 'MATCH', 'MISMATCH') AS STATUS
FROM data_science_team;

-- Output: All 13 data science team employees — ALL MATCH ✓

-- ============================================================
-- Q15: Index on FIRST_NAME for improved query performance
-- ============================================================
-- Check execution plan BEFORE index
EXPLAIN SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';

-- Create index
CREATE INDEX idx_first_name ON emp_record_table(FIRST_NAME);

-- Check execution plan AFTER index (type changes from ALL to ref)
EXPLAIN SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';

-- ============================================================
-- Q16: Calculate bonus for all employees
-- Formula: 5% of salary * EMP_RATING
-- ============================================================
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    SALARY,
    EMP_RATING,
    ROUND(0.05 * SALARY * EMP_RATING, 2) AS BONUS
FROM emp_record_table;

-- Output: Arthur Black earns highest bonus $4,125
--         Katrina Allen earns lowest bonus $150

-- ============================================================
-- Q17: Average salary by continent and country
-- ============================================================
SELECT
    CONTINENT,
    COUNTRY,
    ROUND(AVG(SALARY), 2) AS AVG_SALARY
FROM emp_record_table
GROUP BY CONTINENT, COUNTRY
ORDER BY CONTINENT, COUNTRY;

-- Output: North America/USA leads with avg $9,440
--         South America/Colombia lowest at avg $5,600
