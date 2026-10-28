CREATE DATABASE IF NOT EXISTS student_records;
USE student_records;

CREATE TABLE IF NOT EXISTS students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120),
    course VARCHAR(80) NOT NULL
);

-- Example records for a first run.
INSERT INTO students (name, email, course)
SELECT 'Aarav Sharma', 'aarav@example.com', 'Computer Science'
WHERE NOT EXISTS (SELECT 1 FROM students WHERE email = 'aarav@example.com');

INSERT INTO students (name, email, course)
SELECT 'Maya Patel', 'maya@example.com', 'Information Technology'
WHERE NOT EXISTS (SELECT 1 FROM students WHERE email = 'maya@example.com');

INSERT INTO students (name, email, course)
SELECT 'Noah Wilson', 'noah@example.com', 'Advanced Java'
WHERE NOT EXISTS (SELECT 1 FROM students WHERE email = 'noah@example.com');
