CREATE OR REPLACE VIEW v_grade_sheet AS
SELECT
    g.student_id,
    st.full_name AS student_name,
    st.status AS student_status,
    gr.name AS group_name,
    g.offering_id,
    c.name AS course_name,
    t.full_name AS teacher_name,
    co.academic_year,
    co.semester,
    g.grade,
    g.grade_date
FROM grades g
    JOIN students st ON st.student_id = g.student_id
    JOIN groups gr ON gr.group_id = st.group_id
    JOIN course_offerings co ON co.offering_id = g.offering_id
    JOIN courses c ON c.course_id = co.course_id
    JOIN teacher_departments td ON td.teacher_department_id = co.teacher_department_id
    JOIN teachers t ON t.teacher_id = td.teacher_id;

SELECT student_id, student_name, group_name, course_name, teacher_name, grade, grade_date
FROM v_grade_sheet
ORDER BY group_name, student_name, grade_date
LIMIT 10;

SELECT student_name, course_name, grade
FROM v_grade_sheet
WHERE student_id = 6 AND offering_id = 1;

BEGIN;

UPDATE grades
SET grade = 5
WHERE student_id = 6 AND offering_id = 1;

SELECT student_name, course_name, grade
FROM v_grade_sheet
WHERE student_id = 6 AND offering_id = 1;

ROLLBACK;

SELECT student_name, course_name, grade
FROM v_grade_sheet
WHERE student_id = 6 AND offering_id = 1;



CREATE OR REPLACE VIEW v_student_group_rating AS
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
    group_id,
    group_name,
    student_id,
    full_name,
    status,
    grades_count,
    avg_grade,
    RANK() OVER (
        PARTITION BY group_id
        ORDER BY avg_grade DESC NULLS LAST
    ) AS place_in_group
FROM student_averages;

SELECT group_name, place_in_group, full_name, avg_grade, grades_count
FROM v_student_group_rating
WHERE place_in_group <= 3
    AND grades_count > 0
ORDER BY group_name, place_in_group, full_name;

SELECT group_name,
    COUNT(*) AS students_total,
    COUNT(avg_grade) AS students_with_grades,
    ROUND(AVG(avg_grade), 2) AS avg_of_student_averages
FROM v_student_group_rating
GROUP BY group_name
ORDER BY group_name;



CREATE OR REPLACE VIEW v_active_students AS
SELECT
    student_id,
    full_name,
    birth_date,
    email,
    phone,
    group_id,
    enrollment_date,
    status
FROM students
WHERE status = 'active'
WITH CHECK OPTION;

SELECT student_id, full_name, phone, status
FROM v_active_students
ORDER BY student_id
LIMIT 10;

BEGIN;

UPDATE v_active_students
SET phone = '+7-900-999-99-99'
WHERE student_id = 3;

SELECT student_id, full_name, phone, status
FROM v_active_students
WHERE student_id = 3;

SELECT student_id, full_name, phone, status
FROM students
WHERE student_id = 3;

ROLLBACK;

UPDATE v_active_students
SET status = 'expelled'
WHERE student_id = 3;

