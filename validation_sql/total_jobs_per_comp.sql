-- This SQL query calculates the total number of job postings for each company and lists them in descending order.
WITH company_job_counts AS (
    SELECT 
        company_id,
        COUNT(*) AS total_jobs
    FROM 
        job_postings_fact
    GROUP BY company_id
)

-- Join the company_dim table with the company_job_counts CTE to get the company names along with their total job counts.
SELECT
    company_dim.name AS company_name,
    company_job_counts.total_jobs
FROM
    company_dim
LEFT JOIN company_job_counts ON company_dim.company_id = company_job_counts.company_id
ORDER BY company_job_counts.total_jobs DESC;