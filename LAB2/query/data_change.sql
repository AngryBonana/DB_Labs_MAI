-- 1) INSERT
INSERT INTO teachers(full_name, email, academic_degree, hire_date)
VALUES ('Григорьев Роман Артёмович', 'r.grigorev@university.edu', 'к.ф.-м.н.', '2025-09-01');

INSERT INTO teacher_departments(teacher_id, department_id, position, start_date)
SELECT t.teacher_id, d.department_id, 'Доцент', DATE '2025-09-01'
FROM teachers t, departments d
WHERE t.email = 'r.grigorev@university.edu'
    AND d.name = 'Кафедра прикладной математики';

INSERT INTO courses(name, credits, hours_total)
VALUES ('Машинное обучение', 5, 144);

INSERT INTO course_offerings(course_id, teacher_department_id, group_id, academic_year, semester)
SELECT c.course_id, td.teacher_department_id, g.group_id, '2026/2027', 2
FROM courses c
    JOIN teachers t ON t.email = 'r.grigorev@university.edu'
    JOIN teacher_departments td ON td.teacher_id = t.teacher_id
    JOIN groups g ON g.name = 'ПМ-24'
WHERE c.name = 'Машинное обучение';

-- 2) UPDATE
UPDATE students
SET status = 'active'
WHERE full_name = 'Макаров Ярослав Игоревич'
    AND status = 'academic_leave'
RETURNING student_id, full_name, status;

-- 3) Массовый UPDATE
UPDATE students
SET status = 'graduated'
WHERE status = 'active'
    AND group_id IN (SELECT group_id FROM groups WHERE admission_year <= 2022)
RETURNING student_id, full_name, status;

-- 4) DELETE
DO $$
BEGIN
    DELETE FROM courses WHERE name = 'Машинное обучение';
    RAISE NOTICE 'Удаление выполнено';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Удаление дисциплины запрещено: на неё ссылаются занятия (ON DELETE RESTRICT)';
END $$;

DELETE FROM course_offerings
WHERE course_id = (SELECT course_id FROM courses WHERE name = 'Машинное обучение');

DELETE FROM courses
WHERE name = 'Машинное обучение'
RETURNING course_id, name;

-- 5) ROLLBACK
SELECT (SELECT COUNT(*) FROM students) AS students_before,
    (SELECT COUNT(*) FROM grades) AS grades_before,
    (SELECT ROUND(AVG(grade), 2) FROM grades) AS avg_grade_before;

BEGIN;

UPDATE grades
SET grade = 2
WHERE offering_id IN (SELECT offering_id FROM course_offerings
WHERE academic_year = '2025/2026' AND semester = 1);

DELETE FROM students WHERE status = 'expelled';

SELECT (SELECT COUNT(*) FROM students) AS students_in_tx,
(SELECT COUNT(*) FROM grades) AS grades_in_tx,
(SELECT ROUND(AVG(grade), 2) FROM grades) AS avg_grade_in_tx;

ROLLBACK;

SELECT (SELECT COUNT(*) FROM students) AS students_after,
    (SELECT COUNT(*) FROM grades) AS grades_after,
    (SELECT ROUND(AVG(grade), 2) FROM grades) AS avg_grade_after;
