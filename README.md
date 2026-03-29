# Readme
This GitHub README provides a technical breakdown of your **Data Market Intelligence** project, emphasizing the SQL engineering and the specific insights derived from the 2023 job market dataset.
---
# **Data Market Intelligence: 2023 Job Market Analysis**
## **Project Overview**
This repository documents a deep-dive analysis of the **2023 data science job market**. The primary objective was to use **PostgreSQL** to extract actionable intelligence regarding high-paying roles, lucrative skill sets, and hiring trends. While **Tableau** was utilized to visualize the results of these queries, the core of the project lies in the SQL-driven ETL and data-shaping processes. 
## **Project Structure**
The project is organized to maintain a clear separation between raw data, analytical scripts, and visual outputs, as structured in the local development environment.
```text
├── data_jobs_analysis/
│   ├── query_output/              # CSV exports of query results
│   ├── 1_top_paying_jobs.sql      # Core analysis scripts
│   ├── 2_skills_for_top_paying_jobs.sql
│   ├── 3_market_saturation_vs_oppty.sql
│   ├── 4_seasonal_hiring_strategy.sql
│   ├── 5_comp_quantity_vs_quality.sql
│   └── 6_global_skill_portability.sql
├── sql_load/                      # Database initialization and loading scripts
├── .gitignore                     # Data integrity protection
├── README.md
└── assets/                        # Visualizations of query outputs
```
## **Detailed SQL Analysis & Insights**
### **1. Identifying the Salary Ceiling**
This query establishes the "Market Cap" by isolating the top 10 highest-paying Data Analyst roles in the U.S. It filters for full-time positions and excludes seniority outliers to focus on high-level practitioner roles.
```sql
SELECT	
    job_id,
    job_title,
    ROUND(COALESCE(salary_year_avg, salary_hour_avg * 2080), 0) AS standardized_yearly_salary,
    company_dim.name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst' 
    AND job_country = 'United States' 
    AND job_schedule_type = 'Full-time'
    AND salary_year_avg IS NOT NULL
ORDER BY standardized_yearly_salary DESC
LIMIT 10;
```
- **Insights:** The top tier of the remote market offers salaries between **$232,423 and $350,000**.
- **Key Players:** Elite compensation is driven by AI-research firms like **Anthropic** and **OpenAI**.
### **2. Technical Requirements of Elite Roles**
This query identifies the "Technical Recipe" for the six-figure roles identified in Query 1, mapping specific skill requirements to the highest payers.
```sql
WITH top_paying_jobs AS (
    -- CTE isolates the top 10 jobs from Query 1 logic
)
SELECT top_paying_jobs.*, skills_dim.skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id;
```
- **Insights:** **SQL and Python** are the foundational anchors, appearing in nearly 80% of top-paying roles [85, User CSV].
- **Skill Clusters:** High-paying roles often bundle SQL/Python with niche libraries like **Pandas** or workflow tools like **Flow** [89, User CSV].
### **3. Market Saturation vs. Opportunity (Hidden Gems)**
This analysis identifies the "Sweet Spot" of the market: skills that pay well above the median but appear in less than **5% of the total market**.
```sql
SELECT 
    skills_dim.skills AS skill_name,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
-- Joins and Filters applied
GROUP BY skills_dim.skills
HAVING COUNT(skills_job_dim.job_id) > 10 
    AND COUNT(skills_job_dim.job_id) < (total_jobs * 0.05)
ORDER BY avg_salary DESC;
```
- **Insights:** **PyTorch ($127,148)** and **Kafka ($118,639)** provide massive pay premiums (up to $45k above median) with very low market competition.
### **4. Seasonal Hiring Trends**
Identifying the "Strategic Launch Window" by extracting temporal data from job posting timestamps.
```sql
SELECT 
    TO_CHAR(job_posted_date, 'Month') AS month_name,
    COUNT(job_id) AS job_posted_count
FROM job_postings_fact
GROUP BY month_name, EXTRACT(MONTH FROM job_posted_date)
ORDER BY EXTRACT(MONTH FROM job_posted_date);
```
- **Insights:** A definitive **"Q1 Surge"** occurs in **January (6,672 postings)**, offering 2.3x more opportunities than the **December (2,856)** cooling period.
### **5. Company Quality vs. Quantity**
Distinguishing "Staffing Giants" from "Premium Niche Employers" by comparing posting volume to average compensation levels.
```sql
SELECT 
    company_dim.name AS company_name,
    COUNT(job_id) AS job_count,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
-- Joins and Seniority filters applied
GROUP BY company_name
HAVING COUNT(job_id) > 10 
ORDER BY avg_salary DESC;
```
- **Insights:** **TikTok ($145,912)** represents a high-quality payer, while **Robert Half (132 jobs)** represents a high-quantity market presence with pay closer to the median.
### **6. Global Skill Portability**
Removing all seniority filters to identify "Lifetime Skills"—tools that remain relevant from entry-level to executive roles across Analyst, Scientist, and Engineer career paths.
```sql
SELECT 
    skills_dim.skills AS skill_name,
    COUNT(DISTINCT job_title_short) AS role_count,
    COUNT(job_id) AS total_demand,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
-- Joins applied; Seniority filters removed
GROUP BY skill_name
HAVING COUNT(DISTINCT job_title_short) = 3;
```
- **Insights:** **SQL (8,289)** and **Python (7,708)** are the most portable anchors. **Kafka ($145,436)** represents the "Portability Peak"—a universal skill with the highest average lifetime earnings.
## **Visualizing the Results**
To better communicate the findings of these six queries, static visualizations were created for each query output:
- **Q1:** Top 10 Salaries Bar Chart.
- **Q2:** Top Skills Bubble Cluster.
- **Q3:** The Hidden Gems Scatter Plot.
- **Q4:** Seasonal Hiring Area Chart.
- **Q5:** Company Quality vs. Quantity Scatter Plot.
- **Q6:** Global Skill Portability Treemap.
## **Roadmap & Future Enhancements**
While the current project focuses on SQL-driven analysis and static visualizations, future development includes:
- **Detailed Tableau Dashboard:** Developing a fully interactive, multi-view dashboard to allow stakeholders to filter by role and region dynamically.
- **Real-Time Data Ingestion:** Transitioning from static CSVs to an automated API-based pipeline for real-time market tracking.
## **Tools Used**
- **PostgreSQL:** Primary RDBMS for hosting and querying market data.
- **SQL:** Complex ETL, temporal extraction, and multi-layered aggregation.
- **Tableau:** Visual verification and data storytelling of query results.
- **VS Code & Git:** Development environment and version control.
---
*This analysis provides a data-driven blueprint for career strategy, identifying where technical demand meets maximum financial return.*
