-- View: v_employee_actionable_insights
-- Purpose: Consolidate employee info with risk prediction and reasoning for AI Agent
-- JOINs hr_training_data (Facts) with hr_predictions (Insights)

DROP VIEW IF EXISTS v_employee_actionable_insights;

CREATE OR REPLACE VIEW v_employee_actionable_insights AS
SELECT 
    t.employee_number,
    t.age,
    t.gender,
    t.department,
    t.job_role,
    t.job_level,
    t.monthly_income,
    t.years_at_company,
    t.distance_from_home,
    t.over_time,
    t.work_life_balance,
    t.performance_rating,
    p.risk_level,
    p.attrition_probability,
    p.top_risk_factors::jsonb AS risk_factors_json,
    p.model_accuracy
FROM hr_training_data t
JOIN hr_predictions p ON t.employee_number = p.employee_number;

-- Test the view
SELECT * FROM v_employee_actionable_insights LIMIT 5;
