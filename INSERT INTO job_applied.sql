INSERT INTO job_applied
        (job_id, 
        application_sent_date, 
        custom_resume, 
        resume_file_name, 
        cover_letter_file_name, 
        status)
VALUES
        (1, '2024-01-15', TRUE, 'resume_software_engineer.pdf', 'cover_letter_software_engineer.pdf', 'Applied'),
        (2, '2024-01-20', FALSE, 'resume_generic.pdf', NULL, 'Applied'),
        (3, '2024-01-25', TRUE, 'resume_data_analyst.pdf', 'cover_letter_data_analyst.pdf', 'Interview Scheduled'),
        (4, '2024-02-01', FALSE, 'resume_generic.pdf', NULL, 'Rejected'),
        (5, '2024-02-05', TRUE, 'resume_product_manager.pdf', 'cover_letter_product_manager.pdf', 'Applied');
        
        SELECT * FROM job_applied;