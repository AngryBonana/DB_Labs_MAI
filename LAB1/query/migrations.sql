CREATE TABLE department_teacher(
    employee_id SERIAL PRIMARY KEY,
    department_id INT NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
    teacher_id INT NOT NULL REFERENCES teachers(teacher_id) ON DELETE RESTRICT,
    position VARCHAR(50)
);



ALTER TABLE course_offerings
ADD COLUMN employee_id INT REFERENCES department_teacher(employee_id);


-- Перенести данные
INSERT INTO department_teacher(department_id, teacher_id)
SELECT department_id, teacher_id
FROM teachers INNER JOIN departments USING(department_id);

UPDATE course_offerings co
SET employee_id = dt.employee_id
FROM department_teacher dt
WHERE co.teacher_id = dt.teacher_id;

ALTER TABLE course_offerings DROP COLUMN teacher_id;