/* 
OVERVIEW:
This query identifies "Hidden Gem" skills by using a dynamic 5% threshold.
Instead of an arbitrary range, it calculates the total number of available 
Data Analyst jobs in the US and filters for skills that appear in less than 
5% of those postings, identifying high-paying niche opportunities.
*/

WITH job_total_count AS (
    -- This CTE calculates the total number of jobs meeting our specific criteria [1, 3].
    SELECT 
        COUNT(job_postings_fact.job_id) AS total_jobs
    FROM job_postings_fact
    WHERE 
        job_postings_fact.job_title_short = 'Data Analyst' AND 
        job_postings_fact.job_country = 'United States' AND 
        job_postings_fact.job_schedule_type = 'Full-time' AND
        (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL)
),

market_median AS (
    -- Calculates the 50th percentile (median) salary for Data Analysts in the US [64, Conversation History].
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ROUND(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080), 0)) AS us_median_salary
    FROM job_postings_fact
    WHERE 
        job_postings_fact.job_title_short = 'Data Analyst' AND 
        job_postings_fact.job_country = 'United States' AND 
        job_postings_fact.job_schedule_type = 'Full-time' AND
        (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
        -- Seniority Filter: Ensures the baseline is not skewed by executive pay [4].
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
    skills_dim.skills AS skill_name,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080)), 0) AS avg_salary,
    market_median.us_median_salary
FROM 
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
-- We cross join both the median and the total count to perform our dynamic calculations [5].
CROSS JOIN market_median
CROSS JOIN job_total_count
WHERE 
    job_postings_fact.job_title_short = 'Data Analyst' AND
    job_postings_fact.job_country = 'United States' AND
    job_postings_fact.job_schedule_type = 'Full-time' AND
    company_dim.name NOT LIKE '%Test%' AND
    (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
    -- Exclude leadership to keep the "Gems" relevant to professional analysts [54, Conversation History].
    job_postings_fact.job_title NOT LIKE '%Senior%' AND
    job_postings_fact.job_title NOT LIKE '%Director%' AND
    job_postings_fact.job_title NOT LIKE '%Principal%' AND
    job_postings_fact.job_title NOT LIKE '%Lead%' AND
    job_postings_fact.job_title NOT LIKE '%Manager%' AND
    job_postings_fact.job_title NOT LIKE '%Head%' AND
    job_postings_fact.job_title NOT LIKE '%VP%' AND
    job_postings_fact.job_title NOT LIKE '%Chief%'
GROUP BY 
    skills_dim.skills,
    market_median.us_median_salary,
    job_total_count.total_jobs
HAVING 
    -- DYNAMIC LOGIC: Skills must have more than 10 postings but appear in less than 5% of the total market [67, User Query].
    COUNT(skills_job_dim.job_id) > 10 AND 
    COUNT(skills_job_dim.job_id) < (job_total_count.total_jobs * 0.05)
ORDER BY 
    avg_salary DESC
LIMIT 25;