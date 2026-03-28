/* 
OVERVIEW:
This query analyzes seasonal hiring trends for Data Analysts in the United States.
It extracts the month name (e.g., 'January') from job postings to identify 
peak hiring windows. 

To ensure the data is professional-grade, I have applied strict filters for 
full-time roles and excluded leadership outliers. The results are ordered 
chronologically to support a clear "Trend Line" visualization in Tableau.
*/

SELECT 
    -- Converting the timestamp to a full month name for better readability.
    -- Note: TO_CHAR is a standard PostgreSQL function for date-to-string conversion.
    TO_CHAR(job_postings_fact.job_posted_date, 'Month') AS month_name,
    COUNT(job_postings_fact.job_id) AS job_posted_count
FROM 
    job_postings_fact
WHERE 
    job_postings_fact.job_title_short = 'Data Analyst' AND 
    job_postings_fact.job_country = 'United States' AND 
    job_postings_fact.job_schedule_type = 'Full-time' AND
    -- Consistent seniority exclusions to keep the focus on professional analyst roles [3, 4].
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
    -- Grouping by the raw month number to keep the chronological order intact [5, 6].
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date)
ORDER BY 
    EXTRACT(MONTH FROM job_postings_fact.job_posted_date);