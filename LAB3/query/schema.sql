-- Факультеты
CREATE TABLE faculties(
    faculty_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    dean_full_name VARCHAR(150) NOT NULL,
    CONSTRAINT uq_faculties_name UNIQUE (name)
);

-- Кафедры - зависят от факультета
CREATE TABLE departments(
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    faculty_id INT NOT NULL REFERENCES faculties(faculty_id) ON DELETE RESTRICT,
    head_full_name VARCHAR(150) NOT NULL,
    CONSTRAINT uq_departments_name UNIQUE (name)
);

-- Учебные группы - зависят от кафедры
CREATE TABLE groups(
    group_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    department_id INT NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
    admission_year INT NOT NULL,
    CONSTRAINT uq_groups_name UNIQUE (name),
    CONSTRAINT chk_groups_admission_year CHECK (admission_year BETWEEN 2000 AND 2100)
);

-- Преподаватели (атрибуты, зависящие только от самого преподавателя)
CREATE TABLE teachers(
    teacher_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    academic_degree VARCHAR(50),
    hire_date DATE NOT NULL,
    CONSTRAINT uq_teachers_email UNIQUE (email),
    CONSTRAINT chk_teachers_hire_date CHECK (hire_date <= CURRENT_DATE)
);

-- Работа преподавателя на кафедре (многие ко многим + период + должность)
CREATE TABLE teacher_departments(
    teacher_department_id SERIAL PRIMARY KEY,
    teacher_id INT NOT NULL REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    department_id INT NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
    position VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT chk_td_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Студенты - зависят от группы
CREATE TABLE students(
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    group_id INT NOT NULL REFERENCES groups(group_id) ON DELETE RESTRICT,
    enrollment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT uq_students_email UNIQUE (email),
    CONSTRAINT chk_students_status CHECK (status IN ('active', 'academic_leave', 'expelled', 'graduated')),
    CONSTRAINT chk_students_birth_before_enrollment CHECK (birth_date < enrollment_date)
);

-- Дисциплины
CREATE TABLE courses(
    course_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    credits SMALLINT NOT NULL,
    hours_total SMALLINT NOT NULL,
    CONSTRAINT uq_courses_name UNIQUE (name),
    CONSTRAINT chk_courses_credits CHECK (credits > 0),
    CONSTRAINT chk_courses_hours CHECK (hours_total > 0)
);

-- Дисциплины для учебных групп
-- Преподаватель и кафедра определяются через teacher_department_id
CREATE TABLE course_offerings(
    offering_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL REFERENCES courses(course_id) ON DELETE RESTRICT,
    teacher_department_id INT NOT NULL REFERENCES teacher_departments(teacher_department_id) ON DELETE RESTRICT,
    group_id INT NOT NULL REFERENCES groups(group_id) ON DELETE RESTRICT,
    academic_year VARCHAR(9) NOT NULL,
    semester SMALLINT NOT NULL,
    CONSTRAINT chk_offerings_semester CHECK (semester IN (1, 2)),
    CONSTRAINT uq_offering UNIQUE (course_id, group_id, academic_year, semester)
);

-- Оценки студентов за дисциплины
CREATE TABLE grades(
    student_id INT NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    offering_id INT NOT NULL REFERENCES course_offerings(offering_id) ON DELETE CASCADE,
    grade SMALLINT NOT NULL,
    grade_date DATE NOT NULL,
    PRIMARY KEY (student_id, offering_id),
    CONSTRAINT chk_grades_value CHECK (grade BETWEEN 2 AND 5)
);