DROP MATERIALIZED VIEW IF EXISTS mv_offering_statistics;

CREATE MATERIALIZED VIEW mv_offering_statistics AS
SELECT
    co.offering_id,
    co.academic_year,
    co.semester,
    c.name AS course_name,
    gr.name AS group_name,
    t.full_name AS teacher_name,
    COUNT(g.grade) AS grades_count,
    SUM(g.grade) AS grade_sum,
    ROUND(AVG(g.grade), 2) AS avg_grade,
    MIN(g.grade) AS min_grade,
    MAX(g.grade) AS max_grade,
    COUNT(*) FILTER (WHERE g.grade = 5) AS grade_5_count,
    COUNT(*) FILTER (WHERE g.grade = 4) AS grade_4_count,
    COUNT(*) FILTER (WHERE g.grade = 3) AS grade_3_count,
    COUNT(*) FILTER (WHERE g.grade = 2) AS grade_2_count,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE g.grade >= 4)
        / NULLIF(COUNT(g.grade), 0),
        1
    ) AS success_rate_pct
FROM course_offerings co
    JOIN courses c ON c.course_id = co.course_id
    JOIN groups gr ON gr.group_id = co.group_id
    JOIN teacher_departments td ON td.teacher_department_id = co.teacher_department_id
    JOIN teachers t ON t.teacher_id = td.teacher_id
    LEFT JOIN grades g ON g.offering_id = co.offering_id
GROUP BY
    co.offering_id,
    co.academic_year,
    co.semester,
    c.name,
    gr.name,
    t.full_name;

CREATE UNIQUE INDEX idx_mv_offering_statistics_offering_id
    ON mv_offering_statistics (offering_id);

SELECT offering_id, course_name, group_name, teacher_name,
    grades_count, avg_grade, success_rate_pct
FROM mv_offering_statistics
WHERE academic_year = '2025/2026'
ORDER BY avg_grade DESC NULLS LAST, course_name, group_name;


SELECT group_name,
    COUNT(*) AS offerings_count,
    SUM(grades_count) AS grades_total,
    ROUND(
        SUM(grade_sum)::numeric / NULLIF(SUM(grades_count), 0),
        2
    ) AS weighted_avg_grade
FROM mv_offering_statistics
WHERE academic_year = '2025/2026'
GROUP BY group_name
ORDER BY group_name;
