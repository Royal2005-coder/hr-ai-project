-- HR Analytics Database Schema
-- Initialization script for PostgreSQL

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE: hr_training_data
-- Bảng chứa dữ liệu huấn luyện từ IBM HR Analytics Dataset
-- =====================================================
CREATE TABLE IF NOT EXISTS hr_training_data (
    id SERIAL PRIMARY KEY,
    employee_number INTEGER UNIQUE NOT NULL,
    
    -- Demographics
    age INTEGER NOT NULL,
    gender VARCHAR(10) NOT NULL,
    marital_status VARCHAR(20) NOT NULL,
    education INTEGER CHECK (education BETWEEN 1 AND 5),
    education_field VARCHAR(50),
    
    -- Job Information
    department VARCHAR(50) NOT NULL,
    job_role VARCHAR(50) NOT NULL,
    job_level INTEGER CHECK (job_level BETWEEN 1 AND 5),
    job_involvement INTEGER CHECK (job_involvement BETWEEN 1 AND 4),
    job_satisfaction INTEGER CHECK (job_satisfaction BETWEEN 1 AND 4),
    
    -- Compensation
    monthly_income DECIMAL(10,2) NOT NULL,
    daily_rate INTEGER,
    hourly_rate INTEGER,
    monthly_rate INTEGER,
    percent_salary_hike INTEGER,
    stock_option_level INTEGER CHECK (stock_option_level BETWEEN 0 AND 3),
    
    -- Work Experience
    total_working_years INTEGER,
    years_at_company INTEGER,
    years_in_current_role INTEGER,
    years_since_last_promotion INTEGER,
    years_with_curr_manager INTEGER,
    num_companies_worked INTEGER,
    training_times_last_year INTEGER,
    
    -- Work-Life Balance
    business_travel VARCHAR(20),
    distance_from_home INTEGER,
    over_time VARCHAR(5),
    work_life_balance INTEGER CHECK (work_life_balance BETWEEN 1 AND 4),
    
    -- Satisfaction & Performance
    environment_satisfaction INTEGER CHECK (environment_satisfaction BETWEEN 1 AND 4),
    relationship_satisfaction INTEGER CHECK (relationship_satisfaction BETWEEN 1 AND 4),
    performance_rating INTEGER CHECK (performance_rating BETWEEN 1 AND 4),
    
    -- Target Variable
    attrition VARCHAR(5) NOT NULL, -- 'Yes' or 'No'
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: hr_predictions
-- Bảng chứa kết quả dự báo nghỉ việc
-- =====================================================
CREATE TABLE IF NOT EXISTS hr_predictions (
    id SERIAL PRIMARY KEY,
    employee_number INTEGER NOT NULL,
    prediction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prediction Results
    attrition_probability DECIMAL(5,4) NOT NULL, -- 0.0000 to 1.0000
    attrition_prediction VARCHAR(5) NOT NULL, -- 'Yes' or 'No'
    risk_level VARCHAR(20) NOT NULL, -- 'Low', 'Medium', 'High', 'Critical'
    
    -- Feature Importance Snapshot
    top_risk_factors JSONB,
    
    -- Model Info
    model_version VARCHAR(50),
    model_accuracy DECIMAL(5,4),
    
    -- Foreign Key
    CONSTRAINT fk_employee
        FOREIGN KEY (employee_number)
        REFERENCES hr_training_data(employee_number)
        ON DELETE CASCADE
);

-- =====================================================
-- TABLE: users (for future authentication)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'hr_analyst',
    department VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- =====================================================
-- INDEXES for performance optimization
-- =====================================================
CREATE INDEX idx_training_department ON hr_training_data(department);
CREATE INDEX idx_training_attrition ON hr_training_data(attrition);
CREATE INDEX idx_training_job_role ON hr_training_data(job_role);
CREATE INDEX idx_predictions_employee ON hr_predictions(employee_number);
CREATE INDEX idx_predictions_risk ON hr_predictions(risk_level);
CREATE INDEX idx_predictions_date ON hr_predictions(prediction_date);

-- =====================================================
-- VIEWS for common queries
-- =====================================================

-- View: High risk employees
CREATE OR REPLACE VIEW v_high_risk_employees AS
SELECT 
    t.employee_number,
    t.age,
    t.department,
    t.job_role,
    t.monthly_income,
    t.years_at_company,
    p.attrition_probability,
    p.risk_level,
    p.top_risk_factors
FROM hr_training_data t
INNER JOIN hr_predictions p ON t.employee_number = p.employee_number
WHERE p.risk_level IN ('High', 'Critical')
ORDER BY p.attrition_probability DESC;

-- View: Department attrition summary
CREATE OR REPLACE VIEW v_department_summary AS
SELECT 
    department,
    COUNT(*) as total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) as attrition_rate,
    ROUND(AVG(monthly_income), 2) as avg_income,
    ROUND(AVG(years_at_company), 1) as avg_tenure
FROM hr_training_data
GROUP BY department
ORDER BY attrition_rate DESC;

-- View: Age group analysis
CREATE OR REPLACE VIEW v_age_group_analysis AS
SELECT 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age < 35 THEN '25-34'
        WHEN age < 45 THEN '35-44'
        WHEN age < 55 THEN '45-54'
        ELSE '55+'
    END as age_group,
    COUNT(*) as total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) as attrition_rate
FROM hr_training_data
GROUP BY age_group
ORDER BY age_group;

-- =====================================================
-- COMMENTS for documentation
-- =====================================================
COMMENT ON TABLE hr_training_data IS 'Dữ liệu huấn luyện từ IBM HR Analytics Dataset - 1470 nhân viên';
COMMENT ON TABLE hr_predictions IS 'Kết quả dự báo nghỉ việc từ ML model';
COMMENT ON TABLE users IS 'Người dùng hệ thống HR AI';
COMMENT ON VIEW v_high_risk_employees IS 'Danh sách nhân viên có nguy cơ nghỉ việc cao';
COMMENT ON VIEW v_department_summary IS 'Thống kê tỷ lệ nghỉ việc theo phòng ban';

COMMIT;
