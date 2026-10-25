-- Задание 3.1.
SELECT st.full_name,
    gr.name  AS "group",
    ROUND(AVG(g.grade), 2) AS student_avg,
    ROUND(ga.group_avg, 2) AS group_avg
FROM students st
    JOIN groups gr ON gr.group_id = st.group_id
    JOIN grades g ON g.student_id = st.student_id
    JOIN (SELECT s2.group_id, AVG(g2.grade) AS group_avg
            FROM grades g2
                JOIN students s2 ON s2.student_id = g2.student_id
            GROUP BY s2.group_id) ga ON ga.group_id = st.group_id
GROUP BY st.student_id, st.full_name, gr.name, ga.group_avg
HAVING AVG(g.grade) > ga.group_avg
ORDER BY gr.name, student_avg DESC;

-- Задание 3.2.
SELECT t.full_name, COALESCE(t.academic_degree, 'нет степени') AS academic_degree
FROM teachers t
WHERE EXISTS (SELECT 1
                FROM teacher_departments td
                    JOIN course_offerings co ON co.teacher_department_id = td.teacher_department_id
                    JOIN grades g ON g.offering_id = co.offering_id
                WHERE td.teacher_id = t.teacher_id
                    AND g.grade = 2)
ORDER BY t.full_name;

-- Задание 3.3.
SELECT st.full_name, gr.name AS "group", st.enrollment_date
FROM students st
    JOIN groups gr ON gr.group_id = st.group_id
WHERE st.status = 'active'
    AND NOT EXISTS (SELECT 1
                    FROM grades g
                        JOIN course_offerings co ON co.offering_id = g.offering_id
                    WHERE g.student_id = st.student_id
                        AND co.academic_year = '2025/2026')
ORDER BY gr.name, st.full_name;

-- Задание 3.4.
SELECT st.full_name,
    gr.name AS "group",
    (SELECT ROUND(AVG(g.grade), 2)
     FROM grades g
     WHERE g.student_id = st.student_id) AS avg_grade,
    (SELECT g.grade
     FROM grades g
     WHERE g.student_id = st.student_id
     ORDER BY g.grade_date DESC, g.offering_id DESC
     LIMIT 1) AS last_grade,
    (SELECT MAX(g.grade_date)
     FROM grades g
     WHERE g.student_id = st.student_id) AS last_grade_date
FROM students st
    JOIN groups gr ON gr.group_id = st.group_id
WHERE (SELECT g.grade
       FROM grades g
       WHERE g.student_id = st.student_id
       ORDER BY g.grade_date DESC, g.offering_id DESC
       LIMIT 1)
       < (SELECT AVG(g.grade)
          FROM grades g
          WHERE g.student_id = st.student_id)
ORDER BY gr.name, st.full_name;