DROP TABLE IF EXISTS registrations;
DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    available_slots INT NOT NULL
);

CREATE TABLE registrations (
    reg_id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    course_id INT REFERENCES courses(course_id),
    status VARCHAR(20) NOT NULL
);
INSERT INTO courses (course_name, available_slots)
VALUES
('Database Systems', 3),
('Operating Systems', 2),
('Machine Learning', 0);
CREATE OR REPLACE PROCEDURE register_course(p_student VARCHAR, p_course INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_slots INT;
BEGIN
    SELECT available_slots INTO v_slots
    FROM courses
    WHERE course_id = p_course;

    IF v_slots > 0 THEN
        UPDATE courses
        SET available_slots = available_slots - 1
        WHERE course_id = p_course;

        INSERT INTO registrations(student_number, course_id, status)
        VALUES (p_student, p_course, 'Registered');

        RAISE NOTICE 'Student % registered for course % successfully', p_student, p_course;
    ELSE
        RAISE NOTICE 'Course % is full. Registration failed.', p_course;
    END IF;
END;
$$;
CALL register_course('STU001', 1); -- Database Systems
CALL register_course('STU002', 2); -- Operating Systems
CALL register_course('STU003', 3); -- Machine Learning (fails, no slots)
SELECT * FROM courses;
SELECT * FROM registrations;