-- ============================================================
-- Smart Campus Event & Digital Certificate Management System
-- Stage 1: Database & Table Creation (DDL)
-- Engine: PostgreSQL
-- ============================================================

-- Run this first line alone (from psql or pgAdmin), then connect
-- to the new database before running the rest of the script.
-- CREATE DATABASE smart_campus_events;
-- \c smart_campus_events

-- ------------------------------------------------------------
-- 1. ORGANIZER
-- ------------------------------------------------------------
CREATE TABLE ORGANIZER (
    organizer_id    SERIAL PRIMARY KEY,
    organizer_name  VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE
);

-- Multivalued attribute (organizer can have multiple contact numbers)
CREATE TABLE ORGANIZER_CONTACT (
    organizer_id    INT NOT NULL,
    contact_no      VARCHAR(15) NOT NULL,
    PRIMARY KEY (organizer_id, contact_no),
    FOREIGN KEY (organizer_id) REFERENCES ORGANIZER(organizer_id)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 2. STUDENT
-- ------------------------------------------------------------
CREATE TABLE STUDENT (
    student_id      SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(15),
    department      VARCHAR(50),
    academic_year   INT CHECK (academic_year BETWEEN 1 AND 5),
    gender          VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other'))
);

-- ------------------------------------------------------------
-- 3. EVENT
-- ------------------------------------------------------------
CREATE TABLE EVENT (
    event_id         SERIAL PRIMARY KEY,
    event_name       VARCHAR(150) NOT NULL,
    event_type       VARCHAR(50) NOT NULL,   -- Workshop, Seminar, Hackathon, Cultural, etc.
    event_date       DATE NOT NULL,
    venue            VARCHAR(100),
    max_participants INT DEFAULT 0 CHECK (max_participants >= 0),
    organizer_id     INT NOT NULL,
    FOREIGN KEY (organizer_id) REFERENCES ORGANIZER(organizer_id)
        ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 4. REGISTRATION
-- ------------------------------------------------------------
CREATE TABLE REGISTRATION (
    registration_id     SERIAL PRIMARY KEY,
    student_id          INT NOT NULL,
    event_id            INT NOT NULL,
    registration_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    registration_status VARCHAR(15) DEFAULT 'Confirmed'
        CHECK (registration_status IN ('Pending', 'Confirmed', 'Cancelled')),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id)   REFERENCES EVENT(event_id)   ON DELETE CASCADE,
    UNIQUE (student_id, event_id)
);

-- ------------------------------------------------------------
-- 5. ATTENDANCE
-- ------------------------------------------------------------
CREATE TABLE ATTENDANCE (
    attendance_id     SERIAL PRIMARY KEY,
    student_id        INT NOT NULL,
    event_id          INT NOT NULL,
    attendance_date   DATE NOT NULL,
    attendance_status VARCHAR(10) NOT NULL
        CHECK (attendance_status IN ('Present', 'Absent')),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id)   REFERENCES EVENT(event_id)   ON DELETE CASCADE,
    UNIQUE (student_id, event_id)
);

-- ------------------------------------------------------------
-- 6. FEEDBACK
-- ------------------------------------------------------------
CREATE TABLE FEEDBACK (
    feedback_id     SERIAL PRIMARY KEY,
    student_id      INT NOT NULL,
    event_id        INT NOT NULL,
    rating          INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments        VARCHAR(500),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id)   REFERENCES EVENT(event_id)   ON DELETE CASCADE,
    UNIQUE (student_id, event_id)
);

-- ------------------------------------------------------------
-- 7. CERTIFICATE
-- ------------------------------------------------------------
CREATE TABLE CERTIFICATE (
    certificate_id   SERIAL PRIMARY KEY,
    student_id       INT NOT NULL,
    event_id         INT NOT NULL,
    issue_date       DATE NOT NULL,
    certificate_type VARCHAR(15) DEFAULT 'Participation'
        CHECK (certificate_type IN ('Participation', 'Winner', 'Runner-up', 'Excellence')),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id)   REFERENCES EVENT(event_id)   ON DELETE CASCADE,
    UNIQUE (student_id, event_id)
);

SELECT * FROM CERTIFICATE
-- ============================================================
-- End of Stage 1
-- ============================================================

-- ============================================================
-- Smart Campus Event & Digital Certificate Management System
-- Stage 2: Sample Data (INSERT statements)
-- Engine: PostgreSQL
-- Run this AFTER 01_schema_ddl.sql, in the same database
-- ============================================================
 
-- ------------------------------------------------------------
-- 1. ORGANIZER
-- ------------------------------------------------------------
INSERT INTO ORGANIZER (organizer_name, email) VALUES
('Dept. of Computer Science',        'cs.events@college.edu'),
('Dept. of Electronics',             'ece.events@college.edu'),
('Student Cultural Committee',       'cultural@college.edu'),
('Entrepreneurship Cell',            'ecell@college.edu'),
('Sports Committee',                 'sports@college.edu');
 
INSERT INTO ORGANIZER_CONTACT (organizer_id, contact_no) VALUES
(1, '9876543210'),
(1, '9876543211'),   -- CS dept has two contact numbers
(2, '9876500001'),
(3, '9876511111'),
(4, '9876522222'),
(5, '9876533333');
 
-- ------------------------------------------------------------
-- 2. STUDENT
-- ------------------------------------------------------------
INSERT INTO STUDENT (first_name, last_name, email, phone, department, academic_year, gender) VALUES
('Aarav',   'Sharma',  'aarav.sharma@college.edu',  '9000000001', 'CSE', 3, 'Male'),
('Diya',    'Patel',   'diya.patel@college.edu',    '9000000002', 'CSE', 2, 'Female'),
('Kabir',   'Nair',    'kabir.nair@college.edu',    '9000000003', 'ECE', 3, 'Male'),
('Ishita',  'Rao',     'ishita.rao@college.edu',    '9000000004', 'IT',  1, 'Female'),
('Vivaan',  'Iyer',    'vivaan.iyer@college.edu',   '9000000005', 'CSE', 4, 'Male'),
('Ananya',  'Gupta',   'ananya.gupta@college.edu',  '9000000006', 'ECE', 2, 'Female'),
('Reyansh', 'Verma',   'reyansh.verma@college.edu', '9000000007', 'MECH',3, 'Male'),
('Saanvi',  'Joshi',   'saanvi.joshi@college.edu',  '9000000008', 'IT',  2, 'Female'),
('Arjun',   'Kumar',   'arjun.kumar@college.edu',   '9000000009', 'CSE', 1, 'Male'),
('Myra',    'Singh',   'myra.singh@college.edu',    '9000000010', 'ECE', 4, 'Female');
 
-- ------------------------------------------------------------
-- 3. EVENT
-- ------------------------------------------------------------
INSERT INTO EVENT (event_name, event_type, event_date, venue, max_participants, organizer_id) VALUES
('AI & Machine Learning Workshop', 'Workshop',   '2026-09-05', 'Seminar Hall A',   80,  1),
('Smart India Hackathon Prep',     'Hackathon',  '2026-09-10', 'CS Lab 2',        60,  1),
('IoT Seminar',                    'Seminar',    '2026-09-08', 'ECE Auditorium',  50,  2),
('Cultural Fest - Rhythm 2026',    'Cultural',   '2026-09-15', 'Main Ground',    500,  3),
('Startup Pitch Day',              'Workshop',   '2026-09-12', 'Conference Room', 40,  4),
('Inter-Dept Sports Meet',         'Sports',     '2026-09-20', 'Sports Complex', 200,  5);
 
-- ------------------------------------------------------------
-- 4. REGISTRATION
-- ------------------------------------------------------------
INSERT INTO REGISTRATION (student_id, event_id, registration_date, registration_status) VALUES
(1, 1, '2026-08-25', 'Confirmed'),
(2, 1, '2026-08-26', 'Confirmed'),
(3, 1, '2026-08-26', 'Confirmed'),
(1, 2, '2026-08-28', 'Confirmed'),
(5, 2, '2026-08-28', 'Confirmed'),
(9, 2, '2026-08-29', 'Cancelled'),
(3, 3, '2026-08-27', 'Confirmed'),
(6, 3, '2026-08-27', 'Confirmed'),
(4, 4, '2026-09-01', 'Confirmed'),
(7, 4, '2026-09-01', 'Confirmed'),
(8, 4, '2026-09-02', 'Confirmed'),
(9, 5, '2026-08-30', 'Confirmed'),
(10,5, '2026-08-30', 'Pending'),
(1, 4, '2026-09-01', 'Confirmed'),
(2, 4, '2026-09-01', 'Confirmed');
 
-- ------------------------------------------------------------
-- 5. ATTENDANCE  (only for students who actually attended)
-- ------------------------------------------------------------
INSERT INTO ATTENDANCE (student_id, event_id, attendance_date, attendance_status) VALUES
(1, 1, '2026-09-05', 'Present'),
(2, 1, '2026-09-05', 'Present'),
(3, 1, '2026-09-05', 'Absent'),
(1, 2, '2026-09-10', 'Present'),
(5, 2, '2026-09-10', 'Present'),
(3, 3, '2026-09-08', 'Present'),
(6, 3, '2026-09-08', 'Present'),
(4, 4, '2026-09-15', 'Present'),
(7, 4, '2026-09-15', 'Present'),
(8, 4, '2026-09-15', 'Absent'),
(1, 4, '2026-09-15', 'Present'),
(2, 4, '2026-09-15', 'Present');
 
-- ------------------------------------------------------------
-- 6. FEEDBACK  (only from students who attended)
-- ------------------------------------------------------------
INSERT INTO FEEDBACK (student_id, event_id, rating, comments) VALUES
(1, 1, 5, 'Excellent session, very practical examples'),
(2, 1, 4, 'Good pace, could use more hands-on time'),
(1, 2, 5, 'Great hackathon prep, learned a lot'),
(5, 2, 4, 'Well organized'),
(3, 3, 3, 'Content was a bit too theoretical'),
(6, 3, 5, 'Loved the live demo'),
(4, 4, 5, 'Amazing cultural performances'),
(7, 4, 4, 'Great energy throughout'),
(1, 4, 5, 'Best event of the semester');
 
-- ------------------------------------------------------------
-- 7. CERTIFICATE  (only for students marked Present)
-- ------------------------------------------------------------
INSERT INTO CERTIFICATE (student_id, event_id, issue_date, certificate_type) VALUES
(1, 1, '2026-09-06', 'Participation'),
(2, 1, '2026-09-06', 'Participation'),
(1, 2, '2026-09-11', 'Winner'),
(5, 2, '2026-09-11', 'Runner-up'),
(3, 3, '2026-09-09', 'Participation'),
(6, 3, '2026-09-09', 'Participation'),
(4, 4, '2026-09-16', 'Excellence'),
(7, 4, '2026-09-16', 'Participation'),
(1, 4, '2026-09-16', 'Participation'),
(2, 4, '2026-09-16', 'Participation');
 
-- ============================================================
-- End of Stage 2
-- ============================================================

-- ============================================================
-- Smart Campus Event & Digital Certificate Management System
-- Stage 3: SQL Queries (Required Database Operations)
-- Engine: PostgreSQL
-- Run this AFTER 01_schema_ddl.sql and 02_sample_data.sql
-- ============================================================
 
 
-- ============================================================
-- A. SIMPLE RETRIEVAL QUERIES
-- ============================================================
 
-- A1. List all upcoming events with organizer name
SELECT e.event_name, e.event_type, e.event_date, e.venue, o.organizer_name
FROM EVENT e
JOIN ORGANIZER o ON e.organizer_id = o.organizer_id
ORDER BY e.event_date;
 
-- A2. List all students from the CSE department
SELECT student_id, first_name, last_name, email, academic_year
FROM STUDENT
WHERE department = 'CSE';
 
-- A3. Find all contact numbers of a given organizer (multivalued attribute)
SELECT o.organizer_name, oc.contact_no
FROM ORGANIZER o
JOIN ORGANIZER_CONTACT oc ON o.organizer_id = oc.organizer_id
WHERE o.organizer_name = 'Dept. of Computer Science';
 
 
-- ============================================================
-- B. JOIN QUERIES (multi-table)
-- ============================================================
 
-- B1. Full registration list: which student registered for which event
SELECT s.first_name || ' ' || s.last_name AS student_name,
       e.event_name,
       r.registration_date,
       r.registration_status
FROM REGISTRATION r
JOIN STUDENT s ON r.student_id = s.student_id
JOIN EVENT e   ON r.event_id   = e.event_id
ORDER BY e.event_name, student_name;
 
-- B2. Attendance sheet for a specific event
SELECT s.first_name || ' ' || s.last_name AS student_name,
       s.department,
       a.attendance_status
FROM ATTENDANCE a
JOIN STUDENT s ON a.student_id = s.student_id
WHERE a.event_id = 1
ORDER BY a.attendance_status, student_name;
 
-- B3. Certificates issued, with student & event details
SELECT c.certificate_id,
       s.first_name || ' ' || s.last_name AS student_name,
       e.event_name,
       c.certificate_type,
       c.issue_date
FROM CERTIFICATE c
JOIN STUDENT s ON c.student_id = s.student_id
JOIN EVENT e   ON c.event_id   = e.event_id
ORDER BY c.issue_date;
 
-- B4. Students who registered but were marked ABSENT (or never attended)
SELECT s.first_name || ' ' || s.last_name AS student_name,
       e.event_name,
       r.registration_status
FROM REGISTRATION r
JOIN STUDENT s ON r.student_id = s.student_id
JOIN EVENT e   ON r.event_id   = e.event_id
LEFT JOIN ATTENDANCE a ON a.student_id = r.student_id AND a.event_id = r.event_id
WHERE a.attendance_id IS NULL OR a.attendance_status = 'Absent';
 
 
-- ============================================================
-- C. AGGREGATE FUNCTIONS & GROUP BY
-- ============================================================
 
-- C1. Total number of registrations per event
SELECT e.event_name, COUNT(r.registration_id) AS total_registrations
FROM EVENT e
LEFT JOIN REGISTRATION r ON e.event_id = r.event_id
GROUP BY e.event_name
ORDER BY total_registrations DESC;
 
-- C2. Average feedback rating per event
SELECT e.event_name,
       ROUND(AVG(f.rating), 2) AS avg_rating,
       COUNT(f.feedback_id)    AS num_feedbacks
FROM EVENT e
JOIN FEEDBACK f ON e.event_id = f.event_id
GROUP BY e.event_name
ORDER BY avg_rating DESC;
 
-- C3. Attendance rate (%) per event: present / total registered
SELECT e.event_name,
       COUNT(DISTINCT r.student_id) AS registered,
       COUNT(DISTINCT CASE WHEN a.attendance_status = 'Present' THEN a.student_id END) AS present,
       ROUND(
         100.0 * COUNT(DISTINCT CASE WHEN a.attendance_status = 'Present' THEN a.student_id END)
         / NULLIF(COUNT(DISTINCT r.student_id), 0), 2
       ) AS attendance_rate_pct
FROM EVENT e
LEFT JOIN REGISTRATION r ON e.event_id = r.event_id
LEFT JOIN ATTENDANCE a   ON a.event_id = r.event_id AND a.student_id = r.student_id
GROUP BY e.event_name
ORDER BY attendance_rate_pct DESC;
 
-- C4. Number of certificates issued per student, ranked
SELECT s.first_name || ' ' || s.last_name AS student_name,
       COUNT(c.certificate_id) AS certificates_earned
FROM STUDENT s
JOIN CERTIFICATE c ON s.student_id = c.student_id
GROUP BY student_name
ORDER BY certificates_earned DESC;
 
-- C5. Event type popularity (count of events + total registrations by type)
SELECT e.event_type,
       COUNT(DISTINCT e.event_id)      AS num_events,
       COUNT(r.registration_id)        AS total_registrations
FROM EVENT e
LEFT JOIN REGISTRATION r ON e.event_id = r.event_id
GROUP BY e.event_type
ORDER BY total_registrations DESC;
 
 
-- ============================================================
-- D. SUBQUERIES
-- ============================================================
 
-- D1. Students who have never registered for any event
SELECT first_name, last_name, email
FROM STUDENT
WHERE student_id NOT IN (SELECT DISTINCT student_id FROM REGISTRATION);
 
-- D2. Events with above-average number of registrations
SELECT event_name, event_type
FROM EVENT
WHERE event_id IN (
    SELECT event_id
    FROM REGISTRATION
    GROUP BY event_id
    HAVING COUNT(*) > (
        SELECT AVG(reg_count)
        FROM (SELECT COUNT(*) AS reg_count FROM REGISTRATION GROUP BY event_id) sub
    )
);
 
-- D3. Student with the highest number of certificates (correlated subquery)
SELECT s.first_name || ' ' || s.last_name AS student_name,
       (SELECT COUNT(*) FROM CERTIFICATE c WHERE c.student_id = s.student_id) AS cert_count
FROM STUDENT s
ORDER BY cert_count DESC
LIMIT 1;
 
 
-- ============================================================
-- E. UPDATE QUERIES
-- ============================================================
 
-- E1. Mark a pending registration as confirmed
UPDATE REGISTRATION
SET registration_status = 'Confirmed'
WHERE student_id = 10 AND event_id = 5;
 
-- E2. Correct a student's phone number
UPDATE STUDENT
SET phone = '9000009999'
WHERE student_id = 4;
 
-- E3. Bulk update: increase max_participants for all Workshop events by 10
UPDATE EVENT
SET max_participants = max_participants + 10
WHERE event_type = 'Workshop';
 
 
-- ============================================================
-- F. DELETE QUERIES
-- ============================================================
 
-- F1. Cancel (delete) a specific registration
DELETE FROM REGISTRATION
WHERE student_id = 9 AND event_id = 2;
 
-- F2. Remove all feedback with rating below 2 (spam/low-quality filter example)
DELETE FROM FEEDBACK
WHERE rating < 2;
 
 
-- ============================================================
-- G. VIEWS (useful for the demo/output section)
-- ============================================================
 
-- G1. A consolidated view: student participation summary
CREATE OR REPLACE VIEW student_participation_summary AS
SELECT s.student_id,
       s.first_name || ' ' || s.last_name AS student_name,
       COUNT(DISTINCT r.event_id) AS events_registered,
       COUNT(DISTINCT CASE WHEN a.attendance_status = 'Present' THEN a.event_id END) AS events_attended,
       COUNT(DISTINCT c.certificate_id) AS certificates_earned
FROM STUDENT s
LEFT JOIN REGISTRATION r ON s.student_id = r.student_id
LEFT JOIN ATTENDANCE a   ON s.student_id = a.student_id AND a.event_id = r.event_id
LEFT JOIN CERTIFICATE c  ON s.student_id = c.student_id
GROUP BY s.student_id, student_name;
 
-- Usage:
-- SELECT * FROM student_participation_summary ORDER BY certificates_earned DESC;
 
-- G2. A view of upcoming events with seats remaining
CREATE OR REPLACE VIEW event_seats_remaining AS
SELECT e.event_id,
       e.event_name,
       e.max_participants,
       COUNT(r.registration_id) FILTER (WHERE r.registration_status = 'Confirmed') AS seats_filled,
       e.max_participants - COUNT(r.registration_id) FILTER (WHERE r.registration_status = 'Confirmed') AS seats_remaining
FROM EVENT e
LEFT JOIN REGISTRATION r ON e.event_id = r.event_id
GROUP BY e.event_id, e.event_name, e.max_participants;
 
-- Usage:
-- SELECT * FROM event_seats_remaining ORDER BY seats_remaining;
 
-- ============================================================
-- End of Stage 3
-- ============================================================

SELECT * FROM EVENT;
SELECT * FROM STUDENT;
SELECT * FROM CERTIFICATE;
