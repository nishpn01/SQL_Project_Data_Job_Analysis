# **Data Market Intelligence: 2023 Job Market Analysis**
## **Project Overview**
This repository documents a rigorous, SQL-driven investigation into the **2023 data science job market**. Using a local **PostgreSQL** environment, I architected a series of complex queries to extract actionable intelligence on compensation ceilings, lucrative technical "skill-stacks," and seasonal hiring rhythms. While **Tableau** was utilized to visualize the results of these queries, the core of this project demonstrates high-level proficiency in **Relational Database Management (RDBMS)**, **ETL processes**, and **Exploratory Data Analysis (EDA)**.
## **Business Problem**
In a saturated tech market, job seekers often lack the data-driven insights needed to optimize their career strategy. This project solves that by answering:
1. Which roles represent the absolute **"Salary Ceiling"** for practitioners?
2. What specific **"Technical Recipes"** are required by elite AI and tech firms?
3. Which **"Hidden Gems"** (niche skills) offer the highest pay with the lowest competition?
4. When are the **peak hiring windows** for strategic application timing?
## **Dataset Description**
The analysis is grounded in a relational dataset of **2023 Data Science Job Postings**, structured into four tables:
- **`job_postings_fact`**: The central fact table containing job IDs, titles, standardized salaries, and timestamps.
- **`skills_dim`**: Metadata for 200+ technical skills.
- **`company_dim`**: Dimensional data for hiring firms.
- **`skills_job_dim`**: A join table mapping specific skills to unique job postings.
## **Project Structure**
The repository is organized to ensure reproducibility and a clear separation between raw data cleaning and final analytical outputs.
```text
├── SQL_Project_Data_Job_Analysis/ # Main analytical workspace
│   ├── query_output/              # CSV exports of results
│   ├── 1_top_paying_jobs.sql      # Salary ceiling analysis
│   ├── 2_skills_for_top_paying_jobs.sql
│   ├── 3_market_saturation_vs_oppty.sql
│   ├── 4_seasonal_hiring_strategy.sql
│   ├── 5_comp_quantity_vs_quality.sql
│   └── 6_global_skill_portability.sql
├── sql_load/                   # DDL and DML scripts for DB setup
├── .gitignore                     # Data integrity protection
└── README.md                      # Technical documentation
└── validation_sql/               #scripts for draft EDA. Ignore
```
## **Analysis Workflow**
### **1. Environment Setup & ETL**
- **Database Initialization:** Initialized a local **PostgreSQL** instance to host the analysis.
- **Schema Engineering:** Managed the database using **DDL** (`CREATE TABLE`) and **DML** (`COPY`, `INSERT INTO`) to ingest raw CSV data into structured relational tables.
- **Performance Optimization:** Created **Indexes** on join keys (e.g., `job_id`, `skill_id`) to accelerate query execution across thousands of rows.
### **2. Exploratory Data Analysis (EDA)**
Before running the core queries, I performed a systematic EDA to ensure data health:
- **Data Validation:** Utilized **`COUNT(DISTINCT column_name)`** to profile the unique footprint of job titles and skills.
- **Statistical Profiling:** Ran **`AVG`**, **`MIN`**, and **`MAX`** on salary columns to identify market spreads and detect outliers.
- **Null Analysis:** Employed **`IS NOT NULL`** filters to ensure all compensation benchmarks were based on complete records.
### **3. Technical Implementation Highlights**
My SQL implementation utilizes advanced analytical features:
- **Common Table Expressions (CTEs):** Used `WITH` statements to create multi-stage temporary result sets for complex aggregations.
- **Benchmarking via Set Theory:** Engineered a **US Market Median ($81,312)** using `PERCENTILE_CONT(0.5)` to provide a constant baseline for pay-premium analysis.
- **Temporal Extraction:** Transformed raw timestamps using **`TO_CHAR`** and **`EXTRACT`** to perform time-series analysis.
---
## **Detailed SQL Analysis & Insights**
### **Query 1: Identifying the Salary Ceiling**
Establishes the market cap by isolating the top 10 highest-paying Data Analyst roles. I applied strict seniority filters to focus on high-performing practitioner roles.
```sql
SELECT job_id, job_title, company_dim.name AS company_name,
ROUND(COALESCE(salary_year_avg, salary_hour_avg * 2080), 0) AS standardized_yearly_salary
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst' AND job_country = 'United States'
AND salary_year_avg IS NOT NULL AND job_title NOT LIKE '%Senior%' -- (Other seniority filters)
ORDER BY standardized_yearly_salary DESC LIMIT 10;
```
![](/Assets/q1_top10_paying_jobs.png "width=3822 | height=2090")
> ***Insights:** Top-tier compensation ranges from **$232,423 to $350,000**, with elite pay driven by AI firms like **Anthropic** and **OpenAI**.*
### **Query 2: Technical Requirements of Elite Roles**
Maps the specific skill clusters required for the six-figure roles identified in Query 1.
```sql
WITH top_paying_jobs AS ( -- Logic from Query 1 )
SELECT top_paying_jobs.*, skills_dim.skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id;
```
![](/Assets/q2_skills_for_top10_jobs.png "width=3816 | height=2086")
> **Insights:** **SQL** and **Python** are the foundational anchors, appearing in ~80% of top roles, often paired with libraries like **Pandas** or tools like **Flow, sheets, Hadoop.**
### **Query 3: Hidden Gems (Niche Skill Analysis)**
Identifies high-reward skills with low competition, defined as skills appearing in **less than 5% of the total market**.
```sql
SELECT skills_dim.skills AS skill_name, COUNT(skills_job_dim.job_id) AS demand_count,
ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact -- Joins and Seniority filters applied
GROUP BY skill_name
HAVING COUNT(skills_job_dim.job_id) > 10 AND COUNT(skills_job_dim.job_id) < (total_jobs * 0.05)
ORDER BY avg_salary DESC;
```
![](/Assets/q3_the_hidden_gems.png "width=3824 | height=2076")
> **Insights: PyTorch** ($127,148) and **Kafka** ($118,639) offer massive pay premiums ($40k+ above median) with minimal competition.
### **Query 4: Seasonal Hiring Strategy**
Uncovers the seasonal rhythm of the market to optimize application timing.
```sql
SELECT TO_CHAR(job_posted_date, 'Month') AS month_name, COUNT(job_id) AS job_posted_count
FROM job_postings_fact -- Filters applied
GROUP BY month_name, EXTRACT(MONTH FROM job_posted_date)
ORDER BY EXTRACT(MONTH FROM job_posted_date);
```
![](/Assets/q4_seasonal_hiring_strategy.png "width=3776 | height=2084")
> **Insights:** A definitive "Q1 Surge" peaks in January (6,672 postings), offering 2.3x more opportunity than the December (2,856) low.
### **Query 5: Company Quality vs. Quantity**
Distinguishes between high-volume staffing firms and high-paying niche employers.
```sql
SELECT company_dim.name AS company_name, COUNT(job_id) AS job_count,
ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact -- Joins applied
GROUP BY company_name HAVING COUNT(job_id) > 10
ORDER BY avg_salary DESC;
```
![](/Assets/q5_Company_Quality%20_quantity.png "width=3810 | height=2084")
> **Insights:** **TikTok** ($145,912) represents the high-quality/lower-volume bracket, while **Robert Half** (132 jobs) represents mass-market volume with pay closer to the median.
### **Query 6: Global Skill Portability**
Identifies "Lifetime Skills" that remain portable across Analyst, Scientist, and Engineer roles from entry-level to executive.
```sql
SELECT skills_dim.skills AS skill_name, COUNT(DISTINCT job_title_short) AS role_count,
COUNT(job_id) AS total_demand, ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact -- Filters for DA, DS, DE roles
GROUP BY skill_name HAVING COUNT(DISTINCT job_title_short) = 3;
```
![](/Assets/q6_global_skill_portability.png "width=3816 | height=2088")
> **Insights:** **SQL** (8,289) and **Python** (7,708) are universal anchors. **Kafka** ($145,436) and **Spark** ($138,723) represent the "Portability Peak" for high-value career flexibility.
---
## **Visualizing the Results**
I utilized Tableau to create six distinct visual assets to verify and communicate my findings:
1. **Top 10 Salaries Bar Chart:** Highlighting the $375k ceiling.
2. **Top Skills Bubble Cluster:** Visualizing the technical "Recipe" for elite roles.
3. **Hidden Gems Scatter Plot:** Mapping pay vs. demand.
4. **Hiring Rhythm Area Chart:** Documenting the Q1 hiring surge.
5. **Market Map Scatter Plot:** Categorizing hirers into quality vs. quantity quadrants.
6. **Global Portability Treemap:** Identifying universal technical anchors.

[[View the Interactive Tableau Dashboard Here - Click Me]](https://public.tableau.com/views/JobMarketAnalysis_17745897577470/Top10Salary?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
## **Major Discoveries & Strategic Insights**
The multi-layered SQL analysis of the data job market yielded five primary insights for career optimization and market intelligence:
1. **The Practitioner Salary Ceiling is High:** The top tier of the US Data Analyst market for high-performing practitioners reaches between $232,423 and $375,000. These roles are primarily driven by elite AI research firms like Anthropic and OpenAI.
2. "**Hidden Gems" Offer Strategic Advantages:** While common skills have high competition, niche technical specializations like PyTorch ($127,148), Kafka($118,639), and TensorFlow ($116,869) command massive pay premiums, often $40,000+ above the market median, despite appearing in less than 5% of total job postings
3. **The Q1 Hiring Surge:** Market volume is highly seasonal. A definitive "Q1 Surge" occurs in January (6,672 postings), which offers nearly 2.3x more opportunity than the seasonal low in December (2,856 postings)
4. **The "Quality vs. Quantity" Employer Divide:** The market is bifurcated between "Staffing Giants" like Robert Half (132 jobs), which provide high volume but pay closer to the median, and "Premium Payers" like TikTok ($145,912), which offer elite compensation with a smaller market footprint
5. **Universal Anchors vs. Portability Peaks:** SQL (8,289 demand) and Python (7,708 demand) are the absolute technical anchors, remaining portable across Analyst, Scientist, and Engineer roles
However, skills like Kafka ($145,436) and Scala($140,511) represent the "Portability Peak", they are universal across the data lifecycle yet command the highest average lifetime earnings in the industry.
## What I Learned
1. **Complex Data Shaping:** Mastering Multi-layered CTEs and Subqueries to break down large-scale market data into manageable "temporary result sets" for refined analysis.
2. **Temporal Engineering:** Learning to use `TO_CHAR` and `EXTRACT` to transform raw timestamps into a chronological hiring roadmap.
3. **Market Benchmarking:** Implementing Set Theory and Standardization (2,080-hour multiplier) to create "apples-to-apples" comparisons between hourly and yearly salary data.
4. **Data Storytelling Workflow:** Executing high-performance queries on a local PostgreSQL instance, exporting optimized result sets to CSV, and utilizing Tableau Public for visual discovery.
### **Future Roadmap**
While this project focuses on query-driven insights and static visual reporting, future development includes:
- **Interactive Tableau Dashboard & Data Story:** Developing a comprehensive and highly customizable Tableau dashboard and data story utilizing the entire raw dataset. This future iteration will move beyond the scope of the initial six queries, empowering stakeholders to dynamically explore the market through custom filters for job roles, specific titles, and salary ranges to uncover personalized insights
- **Automated Data Pipeline:** Scaling the ETL process to ingest real-time market data via API integration.
## **Tools Used**
- **PostgreSQL:** Primary RDBMS for hosting and querying market data.
- **SQL:** Complex ETL, temporal extraction, and multi-layered aggregation.
- **DBeaver:** Professional database tool used for managing the PostgreSQL environment and executing analytical scripts
- **Tableau:** Visual analysis and data storytelling of query results.
- **VS Code & Git:** Integrated development and version control.
## **Full Case Study Link**
For a detailed narrative of the methodology and strategic discovery process, view the **[[[Full Data Market Case Study]](https://beta.eden.so/public-access/item/896f9c07-9d25-4ff1-8fdb-79c70a6bfc1e)]**
