-- Факультет с таким названием уже существует
INSERT INTO faculties (name, dean_full_name)
VALUES ('Факультет информационных технологий', 'Другой Декан Декановна');

-- Количество зачетных единиц дисциплины должно быть > 0
INSERT INTO courses (name, credits, hours_total)
VALUES ('Философия', 0, 72);

-- Дата рождения должна быть раньше даты поступления
INSERT INTO students (full_name, birth_date, email, group_id, enrollment_date, status)
VALUES ('Фальшивый Студент', '2025-01-01', 'fake@student.ru', 1, '2021-09-01', 'active');

-- Оценка должна быть в диапазоне 2..5
INSERT INTO grades (student_id, offering_id, grade, grade_date)
VALUES (1, 3, 6, '2026-01-20');

-- Ссылка на несуществующую кафедру
INSERT INTO groups (name, department_id, admission_year)
VALUES ('НЕСУЩ-1', 999, 2024);

-- Дисциплина уже читается этой группе в этом семестре/году
INSERT INTO course_offerings (course_id, teacher_id, group_id, academic_year, semester)
VALUES (1, 1, 1, '2025/2026', 1);

-- Нельзя удалить факультет, пока у него есть кафедры
DELETE FROM faculties WHERE faculty_id = 1;