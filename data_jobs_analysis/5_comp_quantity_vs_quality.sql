/* 
OVERVIEW:
This query analyzes companies based on the "Quality" of their compensation 
(average salary) versus the "Quantity" of their job postings (demand count). 

It identifies firms with a consistent market presence (at least 10 postings) 
and compares their average pay to the US Market Median. This helps job seekers 
distinguish between high-volume hirers and high-paying niche employers.
*/

WITH market_median AS (
    -- Calculates the 50th percentile (median) salary for Data Analysts in the US.
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ROUND(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080), 0)) AS us_median_salary
    FROM job_postings_fact
    WHERE 
        job_postings_fact.job_title_short = 'Data Analyst' AND 
        job_postings_fact.job_country = 'United States' AND 
        job_postings_fact.job_schedule_type = 'Full-time' AND
        (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
        -- Consistent Seniority Filter: Focusing on professional analyst roles.
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
    company_dim.name AS company_name,
    -- QUANTITY: Total number of job postings for this company.
    COUNT(job_postings_fact.job_id) AS job_count,
    -- QUALITY: Average standardized yearly salary for the company's roles.
    ROUND(AVG(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080)), 0) AS avg_salary,
    market_median.us_median_salary
FROM 
    job_postings_fact
-- Joining with company dimension to retrieve the actual company names.
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
CROSS JOIN market_median
WHERE 
    job_postings_fact.job_title_short = 'Data Analyst' AND
    job_postings_fact.job_country = 'United States' AND
    job_postings_fact.job_schedule_type = 'Full-time' AND
    company_dim.name NOT LIKE '%Test%' AND -- Excluding internal test data.
    (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
    -- Applying seniority exclusions to keep the analysis focused on professional analysts.
    job_postings_fact.job_title NOT LIKE '%Senior%' AND
    job_postings_fact.job_title NOT LIKE '%Director%' AND
    job_postings_fact.job_title NOT LIKE '%Principal%' AND
    job_postings_fact.job_title NOT LIKE '%Lead%' AND
    job_postings_fact.job_title NOT LIKE '%Manager%' AND
    job_postings_fact.job_title NOT LIKE '%Head%' AND
    job_postings_fact.job_title NOT LIKE '%VP%' AND
    job_postings_fact.job_title NOT LIKE '%Chief%'
GROUP BY 
    company_dim.name,
    market_median.us_median_salary
HAVING 
    -- Statistical Significance: Ensuring the company has a consistent hiring footprint.
    COUNT(job_postings_fact.job_id) > 10 
ORDER BY 
    avg_salary DESC
--LIMIT 20;