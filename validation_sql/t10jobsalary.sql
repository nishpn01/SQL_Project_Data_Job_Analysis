--Ignore this file, this sql file was my scratchpad for testing and refining the logic for the final query.


/*This SQL query retrieves the top 10 highest paying Data Analyst
 job postings that are available for remote work (Anywhere) and 
 have a non-null average yearly salary. The results are ordered 
 by the average yearly salary in descending order, 
 while also filtering out senior/leadership roles for a 
 cleaner analyst view. */

SELECT	
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND 
    job_location = 'Anywhere' AND 
    salary_year_avg IS NOT NULL AND
    -- Logic Extension: Filter out senior/leadership roles for a cleaner analyst view
    job_title NOT LIKE '%Senior%' AND
    job_title NOT LIKE '%Director%' AND
    job_title NOT LIKE '%Principal%' AND
    job_title NOT LIKE '%Lead%'
ORDER BY
    salary_year_avg DESC
LIMIT 10;


SELECT *
FROM job_postings_fact
limit 50;

SELECT *
FROM company_dim
limit 50;

WITH market_median AS (
    -- CTE to calculate the baseline median for professional Data Analysts in the US
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ROUND(COALESCE(salary_year_avg, salary_hour_avg * 2080), 0)) AS us_median_salary
    FROM job_postings_fact
    WHERE 
        job_title_short = 'Data Analyst' AND 
        job_country = 'United States' AND 
        job_schedule_type = 'Full-time' AND
        (salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL) AND
        -- Seniority Filter: Ensures the median reflects the professional analyst
        -- market, not leadership
        job_title NOT LIKE '%Senior%' AND
        job_title NOT LIKE '%Director%' AND
        job_title NOT LIKE '%Principal%' AND
        job_title NOT LIKE '%Lead%' AND
        job_title NOT LIKE '%Manager%' AND
        job_title NOT LIKE '%Head%' AND
        job_title NOT LIKE '%VP%' AND
        job_title NOT LIKE '%Chief%'
)

/*Enhanced Query: This version of the query includes a more robust logic for calculating the standardized 
yearly salary, allowing for cases where only hourly salary data is available. It also refines the filters 
to focus on  Data Analyst roles in the United States with full-time schedules, while excluding test 
companies and ensuring that at least one form of salary data is present. 
Additionally, it excludes senior/leadership roles for a cleaner analyst view.*/        
SELECT	
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    -- Robust Logic: Use yearly salary if available, otherwise calculate from hourly (2080 hours/year)
    ROUND(COALESCE(salary_year_avg, salary_hour_avg * 2080), 0) AS standardized_yearly_salary,
    job_posted_date,
    name AS company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
CROSS JOIN market_median m -- Attaching the single median value to every result row
WHERE
/*Refined Filters: Focus on Data Analyst roles in the 
United States with full-time schedules, while excluding test companies 
and ensuring salary data is present */
    job_title_short = 'Data Analyst' AND 
    job_country = 'United States' AND 
    job_schedule_type = 'Full-time' AND
    company_dim.name NOT LIKE '%Test%' AND
    -- Filter: Ensure at least one form of salary data exists
    (salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL) AND
    -- Seniority Filter: Exclude leadership roles for a cleaner analyst view
    job_title NOT LIKE '%Senior%' AND
    job_title NOT LIKE '%Director%' AND
    job_title NOT LIKE '%Principal%' AND
    job_title NOT LIKE '%Lead%' AND
    job_title NOT LIKE '%Manager%' AND
    job_title NOT LIKE '%Head%' AND
    job_title NOT LIKE '%VP%' AND
    job_title NOT LIKE '%Chief%'
ORDER BY
    standardized_yearly_salary DESC
LIMIT 10;

--