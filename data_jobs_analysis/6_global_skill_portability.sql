/* 
OVERVIEW:
This query measures skill overlap across three data-role categories: Data Analyst, Data Scientist, and Data Engineer.
It includes all seniority levels represented in the filtered postings and summarizes how many of the three role categories contain each skill, total posting demand, and average standardized salary.

This is a cross-role posting analysis. It does not measure lifetime earnings, career resilience, future relevance, or individual career progression.
*/

SELECT 
    skills_dim.skills AS skill_name,
    -- Number of distinct role categories, out of the three selected, in which the skill appears.
    COUNT(DISTINCT job_postings_fact.job_title_short) AS role_count,
    -- Total matching postings across the selected role categories.
    COUNT(job_postings_fact.job_id) AS total_demand,
    -- Average standardized salary across matching postings with salary data.
    ROUND(AVG(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080)), 0) AS avg_salary
FROM 
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE 
    -- Compare the three selected data-role categories.
    job_postings_fact.job_title_short IN ('Data Analyst', 'Data Scientist', 'Data Engineer') AND
    job_postings_fact.job_country = 'United States' AND
    job_postings_fact.job_schedule_type = 'Full-time' AND
    company_dim.name NOT LIKE '%Test%' AND -- Exclude test records.
    (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL)
    -- No seniority-title exclusions are applied in this query.
GROUP BY 
    skills_dim.skills
HAVING 
    -- Keep skills that appear in at least two of the three selected role categories.
    COUNT(DISTINCT job_postings_fact.job_title_short) >= 2
ORDER BY 
    role_count DESC, 
    total_demand DESC
LIMIT 25;