/* 
OVERVIEW:
This query analyzes 'Global Skill Portability' by identifying technical skills 
shared across the three primary data roles (Analyst, Scientist, Engineer) 
at ALL levels of seniority. 

By removing leadership filters, we are identifying the 'Lifetime Skills' 
that stay relevant from entry-level to executive positions. This provides 
a roadmap for long-term career resilience in the US Full-time market.
*/

SELECT 
    skills_dim.skills AS skill_name,
    -- Portability Metric: Count of distinct roles (out of the 3 specified) requiring the skill.
    COUNT(DISTINCT job_postings_fact.job_title_short) AS role_count,
    -- Market Volume: Total demand across all roles and all seniority levels.
    COUNT(job_postings_fact.job_id) AS total_demand,
    -- Lifetime Value: Average salary across the full career spectrum (including leadership).
    ROUND(AVG(COALESCE(job_postings_fact.salary_year_avg, job_postings_fact.salary_hour_avg * 2080)), 0) AS avg_salary
FROM 
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE 
    -- Analyzing the three core pillars of the data industry.
    job_postings_fact.job_title_short IN ('Data Analyst', 'Data Scientist', 'Data Engineer') AND
    job_postings_fact.job_country = 'United States' AND
    job_postings_fact.job_schedule_type = 'Full-time' AND
    company_dim.name NOT LIKE '%Test%' AND -- Protecting data integrity.
    (job_postings_fact.salary_year_avg IS NOT NULL OR job_postings_fact.salary_hour_avg IS NOT NULL)
    -- SENIORITY FILTERS REMOVED: Capturing skills for 'Lead', 'Principal', and 'Chief' roles.
GROUP BY 
    skills_dim.skills
HAVING 
    -- Targeting skills that provide a bridge between at least two major career paths.
    COUNT(DISTINCT job_postings_fact.job_title_short) >= 2
ORDER BY 
    role_count DESC, 
    total_demand DESC
LIMIT 25;