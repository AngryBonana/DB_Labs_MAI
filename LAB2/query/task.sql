-- За указанный учебный год и семестр вывести: имя преподавателя, предмет,
-- количество групп, количество студентов с выставленной оценкой и среднюю оценку.
SELECT t.full_name,
    c.name,
    COUNT(DISTINCT co.group_id) AS cnt_group,
    COUNT(g.grade) AS cnt_grade,
    ROUND(AVG(g.grade), 2) AS avg_grage
FROM teachers t
    INNER JOIN teacher_departments td ON t.teacher_id = td.teacher_id
    INNER JOIN course_offerings co ON td.teacher_department_id = co.teacher_department_id
    INNER JOIN courses c ON co.course_id = c.course_id
    INNER JOIN grades g ON co.offering_id = g.offering_id
WHERE co.academic_year = '2025/2026' AND co.semester = 1
GROUP BY t.full_name, c.name
ORDER BY COUNT(DISTINCT co.group_id); 