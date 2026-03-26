--This SQL file is not required, this is just to check if the table populates
SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS posted_date, -- Convert to Eastern Time
    EXTRACT(MONTH FROM job_posted_date) AS date_month, -- Extract month from the posted date
    EXTRACT(YEAR FROM job_posted_date) AS date_year -- Extract year from the posted date
FROM
    job_postings_fact
LIMIT 10;


SELECT 
    job_title_short,
    ROUND(AVG(salary_year_avg), 0) AS avg_yearly_salary,
    ROUND(AVG(salary_hour_avg), 2) AS avg_hourly_salary
FROM 
    job_postings_fact
--WHERE 
  --  salary_year_avg IS NOT NULL AND 
    --salary_hour_avg IS NOT NULL
GROUP BY 
    job_title_short
ORDER BY 
    avg_yearly_salary DESC;

--More robust query that accounts for null values in either salary column
SELECT 
    job_title_short,
    -- If yearly is null, multiply hourly by 2080. If both exist, it takes yearly.
    ROUND(AVG(COALESCE(salary_year_avg, salary_hour_avg * 2080)), 0) AS avg_yearly_salary,
    
    -- If hourly is null, divide yearly by 2080.
    ROUND(AVG(COALESCE(salary_hour_avg, salary_year_avg / 2080)), 2) AS avg_hourly_salary
FROM 
    job_postings_fact
WHERE 
    -- Ensure we only include rows that have at least one form of salary data
    salary_year_avg IS NOT NULL OR 
    salary_hour_avg IS NOT NULL
GROUP BY 
    job_title_short
ORDER BY 
    avg_yearly_salary DESC;

SELECT *
FROM february_jobs;