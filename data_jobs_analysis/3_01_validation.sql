/* 
OVERVIEW:
This discovery query calculates the total demand count for every skill in the database.
By identifying the 'Market Ceiling' (the skills with the highest volume), we can 
set more informed thresholds for our 'Hidden Gem' analysis.
*/

SELECT 
    skills_dim.skills AS skill_name,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM 
    skills_dim
-- Joining the skills dimension to the link table to count job occurrences [3-5].
INNER JOIN skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
GROUP BY 
    skills_dim.skills
ORDER BY 
    demand_count DESC
--LIMIT 10;