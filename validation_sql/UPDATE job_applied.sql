UPDATE job_applied
SET contact = 'John Doe'
WHERE job_id = 1;

UPDATE job_applied
SET contact = 'Jane Smith'
WHERE job_id = 2;

UPDATE job_applied
SET contact = 'Emily Johnson'
WHERE job_id = 3;           

UPDATE job_applied
SET contact = 'Michael Brown'
WHERE job_id = 4; 

UPDATE job_applied
SET contact = 'Sarah Davis'
WHERE job_id = 5;

SELECT * FROM job_applied;