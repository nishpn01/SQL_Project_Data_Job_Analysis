/* This SQL query retrieves the top 10 highest paying Data Analyst job postings in the 
United States for full-time positions. It calculates a standardized yearly salary by converting
 hourly rates to an annual equivalent and compares it against the market median salary for Data 
 Analysts in the US. The query also excludes senior-level and leadership positions to focus 
 on professional analyst roles. The results include the job title, location, schedule type, 
 standardized salary, market median salary, posted date, and company name. */    

WITH market_median AS (
    -- This Common Table Expression calculates the 50th percentile (median) salary 
    -- for Data Analysts in the US to serve as a market baseline.
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ROUND(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080), 0)) AS us_median_salary
    FROM job_postings_fact
    WHERE 
        job_postings_fact.job_title_short = 'Data Analyst' AND 
        job_postings_fact.job_country = 'United States' AND 
        job_postings_fact.job_schedule_type = 'Full-time' AND
        (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
        -- Filter out leadership and senior-level keywords to get a true professional analyst median.
        job_postings_fact.job_title NOT LIKE '%Senior%' AND
        job_postings_fact.job_title NOT LIKE '%Director%' AND
        job_postings_fact.job_title NOT LIKE '%Principal%' AND
        job_postings_fact.job_title NOT LIKE '%Lead%' AND
        job_postings_fact.job_title NOT LIKE '%Manager%' AND
        job_postings_fact.job_title NOT LIKE '%Head%' AND
        job_postings_fact.job_title NOT LIKE '%VP%' AND
        job_postings_fact.job_title NOT LIKE '%Chief%'
)

SELECT	
    job_postings_fact.job_id,
    job_postings_fact.job_title,
    job_postings_fact.job_location,
    job_postings_fact.job_schedule_type,
    -- Standardizing salary by converting hourly rates to a yearly equivalent of 2080 hours.
    ROUND(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080), 0) AS standardized_yearly_salary,
    market_median.us_median_salary, -- Including the calculated market baseline for comparison.
    company_dim.name AS company_name
FROM
    job_postings_fact
-- Joining with the company table to retrieve the actual company names.
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
-- Cross Joining the single median value so it is available on every row for Tableau visualization.
CROSS JOIN market_median
WHERE
    job_postings_fact.job_title_short = 'Data Analyst' AND 
    job_postings_fact.job_country = 'United States' AND 
    job_postings_fact.job_schedule_type = 'Full-time' AND
    company_dim.name NOT LIKE '%Test%' AND -- Excluding internal test entries to protect data integrity.
    (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
    -- Applying seniority exclusions to the main results for a focused "Data Analyst" view.
    job_postings_fact.job_title NOT LIKE '%Senior%' AND
    job_postings_fact.job_title NOT LIKE '%Director%' AND
    job_postings_fact.job_title NOT LIKE '%Principal%' AND
    job_postings_fact.job_title NOT LIKE '%Lead%' AND
    job_postings_fact.job_title NOT LIKE '%Manager%' AND
    job_postings_fact.job_title NOT LIKE '%Head%' AND
    job_postings_fact.job_title NOT LIKE '%VP%' AND
    job_postings_fact.job_title NOT LIKE '%Chief%'
ORDER BY
    standardized_yearly_salary DESC
LIMIT 10;