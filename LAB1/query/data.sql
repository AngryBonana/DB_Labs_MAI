-- Факультеты
INSERT INTO faculties(name, dean_full_name)
VALUES
    ('Факультет информационных технологий', 'Иванов Иван Иванович'),
    ('Экономический факультет', 'Петрова Мария Сергеевна');

-- Кафедры
INSERT INTO departments(name, faculty_id, head_full_name)
VALUES
    ('Кафедра программной инженерии', 1, 'Сидоров Пётр Николаевич'),
    ('Кафедра информационной безопасности', 1, 'Кузнецова Анна Викторовна'),
    ('Кафедра финансов и кредита', 2, 'Смирнов Дмитрий Олегович');

-- Группы
INSERT INTO groups(name, department_id, admission_year)
VALUES
    ('ПИ-21-1', 1, 2021),
    ('ИБ-22-1', 2, 2022),
    ('ФК-23-1', 3, 2023);

-- Преподаватели
INSERT INTO teachers(full_name, email, department_id, academic_degree, position, hire_date)
VALUES
    ('Егоров Сергей Викторович', 'egorov@university.ru', 1, 'к.т.н.', 'доцент', '2015-09-01'),
    ('Морозова Ольга Павловна', 'morozova@university.ru', 1, 'д.т.н.', 'профессор', '2010-09-01'),
    ('Волков Андрей Игоревич', 'volkov@university.ru', 2, NULL, 'старший преподаватель', '2018-02-15'),
    ('Никитина Елена Александровна', 'nikitina@university.ru', 3, 'к.э.н.', 'доцент', '2012-09-01');

-- Студенты
INSERT INTO students(full_name, birth_date, email, phone, group_id, enrollment_date, status)
VALUES
    ('Алексеев Максим Дмитриевич', '2003-05-14', 'alekseev@student.ru', '+79001112233', 1, '2021-09-01', 'active'),
    ('Белова Дарья Игоревна', '2003-11-02', 'belova@student.ru', '+79001112234', 1, '2021-09-01', 'active'),
    ('Громов Кирилл Андреевич', '2002-01-20', 'gromov@student.ru', NULL, 1, '2021-09-01', 'academic_leave'),
    ('Дмитриева Валерия Олеговна', '2004-03-09', 'dmitrieva@student.ru', '+79001112235', 2, '2022-09-01', 'active'),
    ('Ефимов Артём Русланович', '2004-07-30', 'efimov@student.ru', NULL, 2, '2022-09-01', 'active'),
    ('Жукова Полина Сергеевна', '2005-02-17', 'zhukova@student.ru', '+79001112236', 3, '2023-09-01', 'active'),
    ('Зайцев Роман Викторович', '2005-06-25', 'zaitsev@student.ru', NULL, 3, '2023-09-01', 'expelled');

-- Дисциплины
INSERT INTO courses(name, credits, hours_total)
VALUES
    ('Базы данных', 5, 144),
    ('Программирование на Python', 4, 128),
    ('Информационная безопасность', 3, 96),
    ('Экономическая теория', 4, 128);

-- Предложения дисциплин
INSERT INTO course_offerings(course_id, teacher_id, group_id, academic_year, semester)
VALUES
    (1, 1, 1, '2025/2026', 1),
    (2, 2, 1, '2025/2026', 1),
    (3, 3, 2, '2025/2026', 1),
    (4, 4, 3, '2025/2026', 1),
    (1, 1, 2, '2025/2026', 2);

-- Оценки
INSERT INTO grades(student_id, offering_id, grade, grade_date)
VALUES
    (1, 1, 5, '2026-01-20'),
    (2, 1, 4, '2026-01-20'),
    (3, 1, 3, '2026-01-22'),
    (1, 2, 4, '2026-01-25'),
    (2, 2, 5, '2026-01-25'),
    (4, 3, 5, '2026-01-18'),
    (5, 3, 4, '2026-01-18'),
    (6, 4, 3, '2026-01-19'),
    (4, 5, 4, '2026-06-15');