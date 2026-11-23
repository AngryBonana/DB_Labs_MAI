WITH student_averages AS (
    SELECT
        s.student_id,
        s.full_name,
        s.status,
        gr.group_id,
        gr.name AS group_name,
        ROUND(AVG(g.grade), 2) AS avg_grade,
        COUNT(g.grade) AS grades_count
    FROM students s
        JOIN groups gr ON gr.group_id = s.group_id
        LEFT JOIN grades g ON g.student_id = s.student_id
    GROUP BY s.student_id, s.full_name, s.status, gr.group_id, gr.name
)
SELECT
    group_name,
    full_name,
    status,
    grades_count,
    avg_grade,
    RANK() OVER (
        PARTITION BY group_id
        ORDER BY avg_grade DESC NULLS LAST
    ) AS place_in_group
FROM student_averages
ORDER BY group_name, place_in_group, full_name;


WITH ordered_grades AS (
    SELECT
        g.student_id,
        st.full_name,
        g.offering_id,
        c.name AS course_name,
        g.grade,
        g.grade_date,
        ROW_NUMBER() OVER (
            PARTITION BY g.student_id
            ORDER BY g.grade_date, g.offering_id
        ) AS event_number,
        LAG(g.grade_date) OVER (
            PARTITION BY g.student_id
            ORDER BY g.grade_date, g.offering_id
        ) AS previous_date,
        LAG(g.grade) OVER (
            PARTITION BY g.student_id
            ORDER BY g.grade_date, g.offering_id
        ) AS previous_grade,
        LAG(c.name) OVER (
            PARTITION BY g.student_id
            ORDER BY g.grade_date, g.offering_id
        ) AS previous_course
    FROM grades g
        JOIN students st ON st.student_id = g.student_id
        JOIN course_offerings co ON co.offering_id = g.offering_id
        JOIN courses c ON c.course_id = co.course_id
)
SELECT
    student_id,
    full_name AS student,
    event_number,
    course_name,
    grade,
    grade_date,
    COALESCE(previous_course, '—') AS previous_course,
    previous_grade,
    previous_date,
    grade_date - previous_date AS days_since_previous,
    grade - previous_grade AS grade_change,
    CASE
        WHEN previous_date IS NULL THEN 'первая оценка'
        ELSE 'есть предыдущая'
    END AS note
FROM ordered_grades
ORDER BY student_id, event_number;



SELECT
    t.full_name AS teacher,
    co.academic_year,
    co.semester,
    c.name AS course_name,
    gr.name AS group_name,
    c.credits,
    SUM(c.credits) OVER (
        PARTITION BY t.teacher_id
    ) AS teacher_total_credits,
    ROUND(
        100.0 * c.credits / SUM(c.credits) OVER (PARTITION BY t.teacher_id),
        1
    ) AS share_in_teacher_load_pct
FROM course_offerings co
    JOIN courses c ON c.course_id = co.course_id
    JOIN groups gr ON gr.group_id = co.group_id
    JOIN teacher_departments td ON td.teacher_department_id = co.teacher_department_id
    JOIN teachers t ON t.teacher_id = td.teacher_id
WHERE co.academic_year = '2025/2026'
ORDER BY t.full_name, co.semester, c.name, gr.name;

