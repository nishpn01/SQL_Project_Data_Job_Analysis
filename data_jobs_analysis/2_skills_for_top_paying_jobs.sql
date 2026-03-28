WITH market_median AS (
    -- Calculates the 50th percentile (median) salary for Data Analysts in the US [64, Conversation History].
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ROUND(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080), 0)) AS us_median_salary
    FROM job_postings_fact
    WHERE 
        job_postings_fact.job_title_short = 'Data Analyst' AND 
        job_postings_fact.job_country = 'United States' AND 
        job_postings_fact.job_schedule_type = 'Full-time' AND
        (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
        job_postings_fact.job_title NOT LIKE '%Senior%' AND
        job_postings_fact.job_title NOT LIKE '%Director%' AND
        job_postings_fact.job_title NOT LIKE '%Principal%' AND
        job_postings_fact.job_title NOT LIKE '%Lead%' AND
        job_postings_fact.job_title NOT LIKE '%Manager%' AND
        job_postings_fact.job_title NOT LIKE '%Head%' AND
        job_postings_fact.job_title NOT LIKE '%VP%' AND
        job_postings_fact.job_title NOT LIKE '%Chief%'
),

top_paying_jobs AS (
    -- Identifies the top 10 highest-paying Data Analyst roles based on  salary logic.
    SELECT	
        job_postings_fact.job_id,
        job_postings_fact.job_title,
        ROUND(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080), 0) AS standardized_yearly_salary,
        company_dim.name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_postings_fact.job_title_short = 'Data Analyst' AND 
        job_postings_fact.job_country = 'United States' AND 
        job_postings_fact.job_schedule_type = 'Full-time' AND
        company_dim.name NOT LIKE '%Test%' AND 
        (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL) AND
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
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills_dim.skills,
    market_median.us_median_salary
FROM top_paying_jobs
-- Inner joining to provide only the skills associated with these specific top 10 jobs.
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
-- Cross joining the median to allow for comparative visualization in Tableau.
CROSS JOIN market_median
ORDER BY
    standardized_yearly_salary DESC;