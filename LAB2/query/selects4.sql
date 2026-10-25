WITH grade_facts AS (
    SELECT g.student_id,
        gr.department_id,
        d.faculty_id,
        g.grade
    FROM grades g
        JOIN course_offerings co ON co.offering_id = g.offering_id
        JOIN students st ON st.student_id = g.student_id
        JOIN groups gr ON gr.group_id = st.group_id
        JOIN departments d ON d.department_id = gr.department_id
    WHERE co.academic_year = '2025/2026'
),
student_metrics AS (
    SELECT student_id,
        department_id,
        faculty_id,
        COUNT(*) AS grades_cnt,
        AVG(grade) AS avg_grade,
        (MIN(grade) = 2) AS has_debt
    FROM grade_facts
    GROUP BY student_id, department_id, faculty_id
),
department_metrics AS (
    SELECT department_id,
        COUNT(*) AS students_cnt,
        ROUND(AVG(avg_grade), 2) AS dept_avg,
        COUNT(*) FILTER (WHERE has_debt) AS students_with_debt,
        ROUND(100.0 * COUNT(*) FILTER (WHERE has_debt) / COUNT(*), 1) AS debt_share
    FROM student_metrics
    GROUP BY department_id
),
faculty_metrics AS (
    SELECT faculty_id,
        ROUND(AVG(avg_grade), 2) AS faculty_avg
    FROM student_metrics
    GROUP BY faculty_id
)
SELECT f.name AS faculty,
    d.name AS department,
    dm.students_cnt,
    dm.dept_avg,
    fm.faculty_avg,
    ROUND(dm.dept_avg - fm.faculty_avg, 2) AS diff_from_faculty,
    dm.students_with_debt,
    dm.debt_share AS debt_share_pct,
    RANK() OVER (ORDER BY dm.dept_avg DESC NULLS LAST) AS university_rank,
    CASE
        WHEN dm.dept_avg IS NULL THEN 'Нет данных'
        WHEN dm.dept_avg < fm.faculty_avg AND dm.debt_share >= 25 THEN 'Требует внимания'
        WHEN dm.dept_avg < fm.faculty_avg THEN 'Ниже среднего по факультету'
        ELSE 'На уровне или выше среднего по факультету'
    END AS verdict
FROM departments d
    JOIN faculties f ON f.faculty_id = d.faculty_id
    LEFT JOIN department_metrics dm ON dm.department_id = d.department_id
    LEFT JOIN faculty_metrics fm ON fm.faculty_id = d.faculty_id
ORDER BY university_rank, d.name;