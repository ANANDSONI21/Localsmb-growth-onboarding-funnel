```sql
-- ============================================================================
-- LocalSMB Onboarding & Funnel Analytics (MySQL)
-- Purpose: Track activation drop-offs, Time-to-First-Campaign, and Retention
-- ============================================================================

CREATE DATABASE IF NOT EXISTS localsmb_analytics;
USE localsmb_analytics;

-- 1. Create SMB Onboarding Funnel Table
CREATE TABLE smb_onboarding_events (
    business_id VARCHAR(20) PRIMARY KEY,
    business_category VARCHAR(50),
    city VARCHAR(50),
    signup_completed TINYINT(1),
    gbp_connected TINYINT(1),
    ai_template_generated TINYINT(1),
    first_campaign_launched TINYINT(1),
    time_to_launch_mins INT,
    leads_generated_week1 INT,
    day7_active TINYINT(1)
);

-- 2. Query 1: Overall Stage-by-Stage Onboarding Funnel Conversion Rate
SELECT 
    COUNT(business_id) AS total_signups,
    SUM(gbp_connected) AS step2_gbp_linked,
    ROUND(SUM(gbp_connected) * 100.0 / COUNT(business_id), 2) AS gbp_conversion_pct,
    SUM(ai_template_generated) AS step3_template_previewed,
    ROUND(SUM(ai_template_generated) * 100.0 / COUNT(business_id), 2) AS template_conversion_pct,
    SUM(first_campaign_launched) AS step4_campaign_live,
    ROUND(SUM(first_campaign_launched) * 100.0 / COUNT(business_id), 2) AS activation_rate_pct
FROM smb_onboarding_events
WHERE signup_completed = 1;

-- 3. Query 2: Funnel Performance & Average Time-to-Value by Business Category
SELECT 
    business_category,
    COUNT(business_id) AS total_businesses,
    ROUND(SUM(first_campaign_launched) * 100.0 / COUNT(business_id), 2) AS activation_rate_pct,
    ROUND(AVG(time_to_launch_mins), 1) AS avg_time_to_launch_mins,
    ROUND(AVG(leads_generated_week1), 1) AS avg_week1_leads
FROM smb_onboarding_events
GROUP BY business_category
ORDER BY activation_rate_pct DESC;

-- 4. Query 3: Impact of First Campaign Launch on Day-7 Retention
SELECT 
    first_campaign_launched,
    COUNT(business_id) AS total_users,
    SUM(day7_active) AS retained_day7_users,
    ROUND(SUM(day7_active) * 100.0 / COUNT(business_id), 2) AS day7_retention_pct
FROM smb_onboarding_events
GROUP BY first_campaign_launched;
