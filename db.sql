-- Recruitment & Placement Management System
-- MySQL 8.0+ | Based on the supplied database specification
CREATE DATABASE IF NOT EXISTS recruitment_placement;
USE recruitment_placement;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS activity_logs, placements, offers, interview_feedback,
 interview_rounds, application_history, applications, job_skills, jobs,
 companies, candidate_skills, skills, candidates, users, roles,
 qualifications, locations;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE roles (
 role_id INT PRIMARY KEY AUTO_INCREMENT,
 role_code VARCHAR(30) NOT NULL UNIQUE,
 role_name VARCHAR(80) NOT NULL,
 is_active TINYINT(1) DEFAULT 1,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
 user_id INT PRIMARY KEY AUTO_INCREMENT,
 username VARCHAR(80) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 full_name VARCHAR(120) NOT NULL,
 email VARCHAR(150) UNIQUE,
 role_id INT,
 status VARCHAR(20) DEFAULT 'ACTIVE',
 last_login_at DATETIME NULL,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE candidates (
 candidate_id INT PRIMARY KEY AUTO_INCREMENT,
 candidate_code VARCHAR(30) NOT NULL UNIQUE,
 full_name VARCHAR(150) NOT NULL,
 email VARCHAR(150) NOT NULL UNIQUE,
 mobile VARCHAR(20) NOT NULL UNIQUE,
 date_of_birth DATE NULL,
 gender VARCHAR(20) NULL,
 qualification VARCHAR(80) NOT NULL,
 college VARCHAR(180) NULL,
 university VARCHAR(180) NULL,
 passing_year SMALLINT NOT NULL,
 percentage DECIMAL(5,2) NULL,
 cgpa DECIMAL(4,2) NULL,
 backlog_count INT DEFAULT 0,
 primary_technology VARCHAR(80) NULL,
 current_location VARCHAR(100) NULL,
 preferred_location VARCHAR(100) NULL,
 profile_status VARCHAR(20) DEFAULT 'ACTIVE',
 placement_status VARCHAR(20) DEFAULT 'NOT_PLACED',
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 CHECK (percentage IS NULL OR percentage BETWEEN 0 AND 100),
 CHECK (backlog_count >= 0)
);

CREATE TABLE skills (
 skill_id INT PRIMARY KEY AUTO_INCREMENT,
 skill_name VARCHAR(100) NOT NULL UNIQUE,
 category VARCHAR(60) NULL,
 is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE candidate_skills (
 candidate_skill_id INT PRIMARY KEY AUTO_INCREMENT,
 candidate_id INT NOT NULL,
 skill_id INT NOT NULL,
 proficiency_level VARCHAR(20) NULL,
 years_experience DECIMAL(4,1) DEFAULT 0,
 is_primary TINYINT(1) DEFAULT 0,
 UNIQUE(candidate_id, skill_id),
 FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
 FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);

CREATE TABLE companies (
 company_id INT PRIMARY KEY AUTO_INCREMENT,
 company_code VARCHAR(30) NOT NULL UNIQUE,
 company_name VARCHAR(180) NOT NULL,
 industry VARCHAR(100) NULL,
 website VARCHAR(200) NULL,
 location VARCHAR(120) NULL,
 company_type VARCHAR(30) NULL,
 hr_name VARCHAR(120) NULL,
 hr_email VARCHAR(150) NULL,
 hr_mobile VARCHAR(20) NULL,
 status VARCHAR(20) DEFAULT 'ACTIVE',
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE jobs (
 job_id INT PRIMARY KEY AUTO_INCREMENT,
 job_code VARCHAR(40) NOT NULL UNIQUE,
 company_id INT NOT NULL,
 job_title VARCHAR(150) NOT NULL,
 employment_type VARCHAR(30) DEFAULT 'FULL_TIME',
 location VARCHAR(120) NOT NULL,
 openings INT NOT NULL,
 min_package_lpa DECIMAL(6,2) NULL,
 max_package_lpa DECIMAL(6,2) NULL,
 min_percentage DECIMAL(5,2) NULL,
 min_passing_year SMALLINT NULL,
 max_passing_year SMALLINT NULL,
 max_backlogs INT DEFAULT 0,
 experience_min_years DECIMAL(4,1) DEFAULT 0,
 qualification_rule VARCHAR(255) NULL,
 posted_date DATE NOT NULL,
 application_deadline DATE NOT NULL,
 status VARCHAR(20) DEFAULT 'OPEN',
 created_by INT NULL,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (company_id) REFERENCES companies(company_id),
 FOREIGN KEY (created_by) REFERENCES users(user_id),
 CHECK (openings > 0),
 CHECK (min_package_lpa IS NULL OR max_package_lpa IS NULL OR min_package_lpa <= max_package_lpa),
 CHECK (application_deadline >= posted_date)
);

CREATE TABLE job_skills (
 job_skill_id INT PRIMARY KEY AUTO_INCREMENT,
 job_id INT NOT NULL,
 skill_id INT NOT NULL,
 minimum_level VARCHAR(20) NULL,
 mandatory_flag TINYINT(1) DEFAULT 1,
 UNIQUE(job_id, skill_id),
 FOREIGN KEY (job_id) REFERENCES jobs(job_id),
 FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);

CREATE TABLE applications (
 application_id INT PRIMARY KEY AUTO_INCREMENT,
 application_code VARCHAR(40) NOT NULL UNIQUE,
 candidate_id INT NOT NULL,
 job_id INT NOT NULL,
 applied_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 eligibility_status VARCHAR(20) DEFAULT 'PENDING',
 eligibility_reason VARCHAR(500) NULL,
 application_status VARCHAR(30) DEFAULT 'APPLIED',
 source VARCHAR(50) NULL,
 assigned_recruiter_id INT NULL,
 updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE(candidate_id, job_id),
 FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
 FOREIGN KEY (job_id) REFERENCES jobs(job_id),
 FOREIGN KEY (assigned_recruiter_id) REFERENCES users(user_id)
);

CREATE TABLE application_history (
 history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 application_id INT NOT NULL,
 old_status VARCHAR(30) NULL,
 new_status VARCHAR(30) NOT NULL,
 remarks VARCHAR(500) NULL,
 changed_by INT NOT NULL,
 changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (application_id) REFERENCES applications(application_id),
 FOREIGN KEY (changed_by) REFERENCES users(user_id)
);

CREATE TABLE interview_rounds (
 interview_id INT PRIMARY KEY AUTO_INCREMENT,
 application_id INT NOT NULL,
 round_number INT NOT NULL,
 round_type VARCHAR(50) NOT NULL,
 scheduled_date DATE NOT NULL,
 scheduled_time TIME NULL,
 mode VARCHAR(20) NOT NULL,
 interviewer_name VARCHAR(120) NULL,
 meeting_or_location VARCHAR(255) NULL,
 status VARCHAR(20) DEFAULT 'SCHEDULED',
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 UNIQUE(application_id, round_number),
 FOREIGN KEY (application_id) REFERENCES applications(application_id)
);

CREATE TABLE interview_feedback (
 feedback_id INT PRIMARY KEY AUTO_INCREMENT,
 interview_id INT NOT NULL UNIQUE,
 technical_rating DECIMAL(3,1) NULL,
 communication_rating DECIMAL(3,1) NULL,
 problem_solving_rating DECIMAL(3,1) NULL,
 overall_rating DECIMAL(3,1) NULL,
 recommendation VARCHAR(30) NOT NULL,
 remarks TEXT NULL,
 submitted_by INT NOT NULL,
 submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (interview_id) REFERENCES interview_rounds(interview_id),
 FOREIGN KEY (submitted_by) REFERENCES users(user_id),
 CHECK (technical_rating IS NULL OR technical_rating BETWEEN 0 AND 5),
 CHECK (communication_rating IS NULL OR communication_rating BETWEEN 0 AND 5),
 CHECK (problem_solving_rating IS NULL OR problem_solving_rating BETWEEN 0 AND 5),
 CHECK (overall_rating IS NULL OR overall_rating BETWEEN 0 AND 5)
);

CREATE TABLE offers (
 offer_id INT PRIMARY KEY AUTO_INCREMENT,
 offer_code VARCHAR(40) NOT NULL UNIQUE,
 application_id INT NOT NULL UNIQUE,
 designation VARCHAR(120) NOT NULL,
 offered_package_lpa DECIMAL(6,2) NOT NULL,
 offer_date DATE NOT NULL,
 expected_joining_date DATE NULL,
 offer_status VARCHAR(20) DEFAULT 'OFFERED',
 remarks VARCHAR(500) NULL,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (application_id) REFERENCES applications(application_id)
);

CREATE TABLE placements (
 placement_id INT PRIMARY KEY AUTO_INCREMENT,
 candidate_id INT NOT NULL,
 company_id INT NOT NULL,
 job_id INT NOT NULL,
 offer_id INT NOT NULL UNIQUE,
 designation VARCHAR(120) NOT NULL,
 final_package_lpa DECIMAL(6,2) NOT NULL,
 expected_joining_date DATE NULL,
 actual_joining_date DATE NULL,
 joining_status VARCHAR(20) DEFAULT 'PENDING',
 placement_status VARCHAR(20) DEFAULT 'ACTIVE',
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
 FOREIGN KEY (company_id) REFERENCES companies(company_id),
 FOREIGN KEY (job_id) REFERENCES jobs(job_id),
 FOREIGN KEY (offer_id) REFERENCES offers(offer_id)
);

CREATE TABLE activity_logs (
 log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id INT NULL,
 module_name VARCHAR(60) NOT NULL,
 action_name VARCHAR(80) NOT NULL,
 record_id VARCHAR(60) NULL,
 description VARCHAR(500) NULL,
 logged_at DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Optional master tables mentioned in the specification
CREATE TABLE qualifications (
 qualification_id INT PRIMARY KEY AUTO_INCREMENT,
 qualification_name VARCHAR(100) NOT NULL UNIQUE,
 is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE locations (
 location_id INT PRIMARY KEY AUTO_INCREMENT,
 location_name VARCHAR(120) NOT NULL UNIQUE,
 is_active TINYINT(1) DEFAULT 1
);

-- Recommended indexes
CREATE INDEX idx_candidates_technology ON candidates(primary_technology);
CREATE INDEX idx_candidates_passing_year ON candidates(passing_year);
CREATE INDEX idx_candidates_placement_status ON candidates(placement_status);
CREATE INDEX idx_candidate_skills_candidate ON candidate_skills(candidate_id);
CREATE INDEX idx_candidate_skills_skill ON candidate_skills(skill_id);
CREATE INDEX idx_companies_name ON companies(company_name);
CREATE INDEX idx_companies_status ON companies(status);
CREATE INDEX idx_jobs_company ON jobs(company_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_deadline ON jobs(application_deadline);
CREATE INDEX idx_jobs_location ON jobs(location);
CREATE INDEX idx_applications_status ON applications(application_status);
CREATE INDEX idx_applications_recruiter ON applications(assigned_recruiter_id);
CREATE INDEX idx_history_application ON application_history(application_id);
CREATE INDEX idx_history_changed_at ON application_history(changed_at);
CREATE INDEX idx_interviews_date ON interview_rounds(scheduled_date);
CREATE INDEX idx_interviews_status ON interview_rounds(status);
CREATE INDEX idx_feedback_recommendation ON interview_feedback(recommendation);
CREATE INDEX idx_offers_status ON offers(offer_status);
CREATE INDEX idx_placements_candidate ON placements(candidate_id);
CREATE INDEX idx_placements_company ON placements(company_id);
CREATE INDEX idx_placements_joining ON placements(joining_status);
CREATE INDEX idx_logs_user ON activity_logs(user_id);
CREATE INDEX idx_logs_module ON activity_logs(module_name);
CREATE INDEX idx_logs_time ON activity_logs(logged_at);

-- ============================================================
-- REPORTING QUERIES (the 10 required reports from the document)
-- ============================================================

-- 1. Candidate count by primary technology
SELECT primary_technology, COUNT(*) AS candidate_count
FROM candidates
GROUP BY primary_technology
ORDER BY candidate_count DESC;

-- 2. Open jobs by company
SELECT c.company_name, j.job_id, j.job_code, j.job_title, j.location,
       j.openings, j.application_deadline
FROM jobs j
JOIN companies c ON c.company_id = j.company_id
WHERE j.status = 'OPEN'
ORDER BY c.company_name, j.application_deadline;

-- 3. Applications by status
SELECT application_status, COUNT(*) AS application_count
FROM applications
GROUP BY application_status
ORDER BY application_count DESC;

-- 4. Recruitment funnel
SELECT
 COUNT(*) AS total_applications,
 SUM(application_status = 'APPLIED') AS applied,
 SUM(application_status = 'ELIGIBILITY_VERIFIED') AS eligibility_verified,
 SUM(application_status = 'SHORTLISTED') AS shortlisted,
 SUM(application_status IN ('INTERVIEW_SCHEDULED','INTERVIEWED')) AS interview_stage,
 SUM(application_status = 'SELECTED') AS selected,
 SUM(application_status = 'REJECTED') AS rejected,
 SUM(application_status = 'OFFERED') AS offered,
 SUM(application_status = 'JOINED') AS joined
FROM applications;

-- 5. Company-wise placements
SELECT c.company_name, COUNT(p.placement_id) AS placed_count
FROM placements p
JOIN companies c ON c.company_id = p.company_id
WHERE p.joining_status = 'JOINED' AND p.placement_status = 'ACTIVE'
GROUP BY c.company_id, c.company_name
ORDER BY placed_count DESC;

-- 6. Technology-wise placements
SELECT ca.primary_technology, COUNT(p.placement_id) AS placed_count
FROM placements p
JOIN candidates ca ON ca.candidate_id = p.candidate_id
WHERE p.joining_status = 'JOINED' AND p.placement_status = 'ACTIVE'
GROUP BY ca.primary_technology
ORDER BY placed_count DESC;

-- 7. Recruiter performance
SELECT u.user_id, u.full_name AS recruiter_name,
       COUNT(a.application_id) AS assigned_applications,
       SUM(a.application_status = 'SELECTED') AS selected_count,
       SUM(a.application_status = 'OFFERED') AS offered_count,
       SUM(a.application_status = 'JOINED') AS joined_count
FROM users u
LEFT JOIN applications a ON a.assigned_recruiter_id = u.user_id
GROUP BY u.user_id, u.full_name
ORDER BY assigned_applications DESC;

-- 8. Pending interviews
SELECT ir.interview_id, ir.application_id, ca.full_name,
       j.job_title, ir.round_number, ir.round_type,
       ir.scheduled_date, ir.scheduled_time, ir.mode, ir.status
FROM interview_rounds ir
JOIN applications a ON a.application_id = ir.application_id
JOIN candidates ca ON ca.candidate_id = a.candidate_id
JOIN jobs j ON j.job_id = a.job_id
WHERE ir.status = 'SCHEDULED'
ORDER BY ir.scheduled_date, ir.scheduled_time;

-- 9. Offer-to-joining conversion
SELECT
 COUNT(DISTINCT o.offer_id) AS total_offers,
 COUNT(DISTINCT CASE WHEN o.offer_status = 'ACCEPTED' THEN o.offer_id END) AS accepted_offers,
 COUNT(DISTINCT CASE WHEN p.joining_status = 'JOINED' THEN p.placement_id END) AS joined_count,
 ROUND(100.0 * COUNT(DISTINCT CASE WHEN p.joining_status = 'JOINED' THEN p.placement_id END)
       / NULLIF(COUNT(DISTINCT o.offer_id), 0), 2) AS offer_to_joining_percent
FROM offers o
LEFT JOIN placements p ON p.offer_id = o.offer_id;

-- 10. Job aging in days
SELECT job_id, job_code, job_title, status, posted_date,
       DATEDIFF(CURDATE(), posted_date) AS job_age_days
FROM jobs
ORDER BY job_age_days DESC;

-- ============================================================
-- ADDITIONAL USEFUL CRUD / SEARCH QUERIES
-- ============================================================

-- View all candidates
SELECT * FROM candidates;

-- Search candidates by name
SELECT * FROM candidates WHERE full_name LIKE '%name%';

-- Search candidates by technology
SELECT * FROM candidates WHERE primary_technology = 'Java';

-- Candidates meeting percentage and backlog criteria
SELECT * FROM candidates
WHERE percentage >= 60 AND backlog_count = 0 AND profile_status = 'ACTIVE';


-- Useful checks
SHOW TABLES;
DESCRIBE candidates;
SELECT * FROM applications WHERE application_status = 'SHORTLISTED';
SELECT * FROM offers WHERE offer_status = 'ACCEPTED';
SELECT * FROM placements WHERE joining_status = 'JOINED';
