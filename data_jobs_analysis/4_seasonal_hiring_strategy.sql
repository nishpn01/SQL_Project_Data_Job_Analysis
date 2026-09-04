/* 
OVERVIEW:
This query summarizes monthly posting volume for US full-time Data Analyst roles in the 2023 dataset.
It excludes several seniority and leadership-title keywords, groups postings by month, and orders the result chronologically for Tableau.

The output describes the pattern in this dataset; it is not a universal rule about the best time to apply for jobs.
*/

SELECT 
    -- Convert the timestamp to a full month name for readability.
    TO_CHAR(job_postings_fact.job_posted_date, 'Month') AS month_name,
    COUNT(job_postings_fact.job_id) AS job_posted_count
FROM 
    job_postings_fact
WHERE 
    job_postings_fact.job_title_short = 'Data Analyst' AND 
    job_postings_fact.job_country = 'United States' AND 
    job_postings_fact.job_schedule_type = 'Full-time' AND
    -- Apply the same title exclusions used in the related Data Analyst analyses.
    job_postings_fact.job_title NOT LIKE '%Senior%' AND
    job_postings_fact.job_title NOT LIKE '%Director%' AND
    job_postings_fact.job_title NOT LIKE '%Principal%' AND
    job_postings_fact.job_title NOT LIKE '%Lead%' AND
    job_postings_fact.job_title NOT LIKE '%Manager%' AND
    job_postings_fact.job_title NOT LIKE '%Head%' AND
    job_postings_fact.job_title NOT LIKE '%VP%' AND
    job_postings_fact.job_title NOT LIKE '%Chief%'
GROUP BY 
    month_name,
    -- Group by the raw month number to preserve chronological order.
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date)
ORDER BY 
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date);