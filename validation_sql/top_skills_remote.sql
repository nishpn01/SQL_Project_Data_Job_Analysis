/*This SQL query identifies the top 10 skills that are most frequently required in remote 
job postings.*/
WITH remote_skills_job AS (
SELECT 
    skill_id,
    count(*) AS skill_count
FROM
    skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS job_postings ON skills_to_job.job_id = job_postings.job_id
WHERE
    job_postings.job_work_from_home = TRUE
GROUP BY skill_id
)
/*Join the remote_skills_job CTE with the skills_dim table to get the 
skill names along with their counts, and limit the results to the top 10. */
SELECT 
    skills.skill_id,
    skills,
    skill_count
FROM remote_skills_job
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_skills_job.skill_id
Limit 10;

