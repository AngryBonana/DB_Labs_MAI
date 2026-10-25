-- Запрос 2.1.1.
SELECT st.full_name AS student,
    gr.name AS "group",
    c.name AS course,
    co.academic_year || ', сем. ' || co.semester AS period,
    t.full_name AS teacher,
    td.position,
    d.name AS teacher_department,
    g.grade,
    g.grade_date
FROM grades g
    JOIN students st ON st.student_id = g.student_id
    JOIN groups gr ON gr.group_id = st.group_id
    JOIN course_offerings co ON co.offering_id = g.offering_id
    JOIN courses c ON c.course_id = co.course_id
    JOIN teacher_departments td ON td.teacher_department_id = co.teacher_department_id
    JOIN teachers t ON t.teacher_id = td.teacher_id
    JOIN departments d ON d.department_id = td.department_id
WHERE co.academic_year = '2025/2026'
ORDER BY gr.name, st.full_name, g.grade_date;

-- Запрос 2.1.2.
SELECT t.full_name,
    COALESCE(t.academic_degree, 'нет степени') AS academic_degree,
    COALESCE(d.name, '— не назначен на кафедру —') AS department,
    COALESCE(td.position, '—') AS position
FROM teachers t
    LEFT JOIN teacher_departments td ON td.teacher_id = t.teacher_id
        AND td.end_date IS NULL
    LEFT JOIN departments d ON d.department_id = td.department_id
    LEFT JOIN course_offerings co ON co.teacher_department_id = td.teacher_department_id
WHERE co.offering_id IS NULL
ORDER BY t.full_name;

-- Запрос 2.1.3.
SELECT st.full_name AS student,
    gr.name AS "group",
    gd.name AS group_department,
    c.name AS course,
    t.full_name AS teacher,
    td_d.name AS teacher_department,
    g.grade
FROM students st
    JOIN groups gr ON gr.group_id = st.group_id
    JOIN departments gd ON gd.department_id = gr.department_id
    JOIN grades g ON g.student_id = st.student_id
    JOIN course_offerings co ON co.offering_id = g.offering_id
    JOIN courses c ON c.course_id = co.course_id
    JOIN teacher_departments td ON td.teacher_department_id = co.teacher_department_id
    JOIN teachers t ON t.teacher_id = td.teacher_id
    JOIN departments td_d ON td_d.department_id = td.department_id
WHERE st.status = 'active'
    AND co.academic_year = '2025/2026'
    AND g.grade <= 3
    AND td.department_id <> gr.department_id
ORDER BY g.grade, st.full_name;



-- Запрос 2.2.1.
SELECT gr.name AS "group",
    d.name AS department,
    COUNT(DISTINCT st.student_id) AS students_cnt,
    COUNT(DISTINCT g.student_id) AS students_with_grades,
    COUNT(g.grade) AS grades_cnt,
    COALESCE(ROUND(AVG(g.grade), 2)::text, 'нет оценок') AS avg_grade,
    MIN(g.grade) AS min_grade,
    MAX(g.grade) AS max_grade
FROM groups gr
    JOIN departments d ON d.department_id = gr.department_id
    LEFT JOIN students st ON st.group_id = gr.group_id
    LEFT JOIN grades g ON g.student_id = st.student_id
GROUP BY gr.group_id, gr.name, d.name
ORDER BY gr.name;

-- Запрос 2.2.2.
SELECT t.full_name AS teacher,
    COUNT(DISTINCT co.offering_id) AS offerings_cnt,
    COUNT(g.grade) AS grades_cnt,
    ROUND(AVG(g.grade), 2) AS avg_grade,
    SUM(CASE WHEN g.grade = 2 THEN 1 ELSE 0 END) AS fails_cnt,
    MIN(g.grade) AS min_grade
FROM teachers t
    JOIN teacher_departments td ON td.teacher_id = t.teacher_id
    JOIN course_offerings co ON co.teacher_department_id = td.teacher_department_id
    JOIN grades g ON g.offering_id = co.offering_id
GROUP BY t.teacher_id, t.full_name
HAVING COUNT(g.grade) >= 6
    AND (AVG(g.grade) <= 4.0 OR MIN(g.grade) = 2)
ORDER BY avg_grade;

-- Запрос 2.2.3.
SELECT f.name AS faculty,
    COUNT(g.grade) FILTER (WHERE co.semester = 1) AS grades_sem1,
    COUNT(g.grade) FILTER (WHERE co.semester = 2) AS grades_sem2,
    ROUND(AVG(g.grade) FILTER (WHERE co.semester = 1), 2) AS avg_sem1,
    ROUND(AVG(g.grade) FILTER (WHERE co.semester = 2), 2) AS avg_sem2,
    ROUND(AVG(g.grade) FILTER (WHERE co.semester = 2)
    - AVG(g.grade) FILTER (WHERE co.semester = 1), 2) AS avg_change,
    MIN(g.grade) AS min_grade
FROM grades g
    JOIN course_offerings co ON co.offering_id = g.offering_id
    JOIN groups gr ON gr.group_id = co.group_id
    JOIN departments d ON d.department_id = gr.department_id
    JOIN faculties f ON f.faculty_id = d.faculty_id
WHERE co.academic_year = '2025/2026'
GROUP BY f.faculty_id, f.name
ORDER BY f.name;