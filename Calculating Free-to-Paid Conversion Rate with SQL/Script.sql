USE db_course_conversions;
SHOW TABLES;
DESCRIBE student_info;
DESCRIBE student_engagement;
DESCRIBE student_purchases;

SELECT 
  -- Conversion rate: Percentage of students who watched and then purchased
    ROUND(COUNT(a.first_date_purchased) / COUNT(a.first_date_watched) * 100, 2) AS conversion_rate,

    -- Average duration between registration and first engagement
    ROUND(SUM(a.days_diff_reg_watch) / COUNT(a.days_diff_reg_watch), 2) AS av_reg_watch,

    -- Average duration between first engagement and first purchase
    ROUND(SUM(a.days_diff_watch_purch) / COUNT(a.days_diff_watch_purch), 2) AS av_watch_purch
FROM 
    (
        SELECT 
            i.student_id,
            i.date_registered,
            MIN(e.date_watched) AS first_date_watched,
            MIN(p.date_purchased) AS first_date_purchased,
            DATEDIFF(MIN(e.date_watched), i.date_registered) AS days_diff_reg_watch,
            DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS days_diff_watch_purch
        FROM 
            student_info i
        LEFT JOIN 
            student_engagement e ON i.student_id = e.student_id
        LEFT JOIN 
            student_purchases p ON i.student_id = p.student_id
        GROUP BY 
            i.student_id, i.date_registered
        HAVING 
            first_date_watched <= first_date_purchased OR first_date_purchased IS NULL
    ) AS a;
