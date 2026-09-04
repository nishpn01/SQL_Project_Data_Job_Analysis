/* 
OVERVIEW:
This query compares employers using two descriptive measures: qualifying posting volume and average standardized salary.
It includes employers with more than 10 matching postings and compares their average listed salary with the US market median.

These measures do not represent overall employer or job quality; they describe posting volume and average listed compensation in this dataset.
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
        -- Use the same seniority-title exclusions as the main employer comparison.
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
    -- Posting volume for this employer within the filtered dataset.
    COUNT(job_postings_fact.job_id) AS job_count,
    -- Average standardized yearly salary for the employer's matching postings.
    ROUND(AVG(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080)), 0) AS avg_salary,
    market_median.us_median_salary
FROM 
    job_postings_fact
-- Join company_dim to retrieve employer names.
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
CROSS JOIN market_median
WHERE 
    job_postings_fact.job_title_short = 'Data Analyst' AND
    job_postings_fact.job_country = 'United States' AND
    job_postings_fact.job_schedule_type = 'Full-time' AND
    company_dim.name NOT LIKE '%Test%' AND -- Exclude test records.
    (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
    -- Apply seniority-title exclusions to the employer comparison.
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
    -- Require more than 10 matching postings so the comparison is not based on only a few rows.
    COUNT(job_postings_fact.job_id) > 10 
ORDER BY 
    avg_salary DESC
--LIMIT 20;