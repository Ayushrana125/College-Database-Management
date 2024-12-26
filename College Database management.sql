use college_db;

-- Finding the names of students who are enrolled in course ID 5.

Select s.first_name, s.last_name
From tbl_students s 
Left join tbl_enrollment e on s.student_id = e.student_id
Left join tbl_courses c on e.course_id = c.course_id
where c.course_id = 5
Group by s.first_name, s.last_name;


-- Finding courses that have more than 5 students enrolled.

Select c.course_name, COUNT(s.student_id) as total_students
From tbl_courses c
Left join tbl_enrollment e on e.course_id = c.course_id
Left join tbl_students s on e.student_id = s.student_id
Group by c.course_name
Having total_students > 5;

-- Retrieving the department name where professor ID 110 works.

Select d.department_name, p.professor_id
from tbl_department d
Left join tbl_professors p on p.department_id = d.department_id
where p.professor_id = 110;

-- Getting names of professors who teach at least one course in department ID 3 (Nested subquery)

Select first_name, last_name
from tbl_professors where professor_id In 
	(Select professor_id from tbl_course_proffessor where course_id In 
		(Select course_id from tbl_courses where department_id = 3));



-- Finding the average credits of courses offered in department ID 2.

Select c.course_name, AVG(c.credits) as Average_credits
From tbl_courses c
Left join tbl_department d on d.department_id = c.department_id
where d.department_id = 2
group by c.course_name;

-- Listing the first name and last name of students and the names of the courses they are enrolled in.

Select s.first_name, s.last_name, c.course_name 
From tbl_students s
Left join tbl_enrollment e on e.student_id = s.student_id
Left join tbl_courses c on e.course_id = c.course_id
Group by s.first_name, s.last_name, c.course_name;


-- Retrieving the names of professors and the names of the courses they teach.

Select p.first_name, p.last_name, c.course_name
from tbl_professors p
Left join tbl_course_proffessor cp on cp.professor_id = p.professor_id
Left join tbl_courses c on c.course_id = cp.course_id
Group by p.first_name, p.last_name, c.course_name;


-- Showing all departments with the names of students in each department.

Select d.department_name, s.first_name, s.last_name
from tbl_department d
Left join tbl_students s on s.department_id = d.department_id
Group by d.department_name, s.first_name, s.last_name;


-- Finding the courses and the number of students enrolled in each course.

Select c.course_name, COUNT(e.student_id) as Total_students
from tbl_courses c 
Left join tbl_enrollment e on e.course_id = c.course_id
Group by c.course_name;


--  Listing the names of professors and their departments.

Select p.first_name, p.last_name, d.department_name
from tbl_professors p
Left join tbl_department d on d.department_id = p.department_id
Group by p.first_name, p.last_name, d.department_name;


-- Listing all departments and any students associated with them, including departments with no students.

Select d.department_name, s.first_name, s.last_name
from tbl_department d
Left join tbl_students s on s.department_id = d.department_id
Group by d.department_name, s.first_name, s.last_name;

-- Showing all courses and any students enrolled in them, including courses with no students enrolled.

Select c.course_name, s.first_name, s.last_name
from tbl_courses c 
Left join tbl_enrollment e on e.course_id = c.course_id
Left join tbl_students s on e.student_id = s.student_id
Group by c.course_name, s.first_name, s.last_name;




-- Created a stored procedure add_student that inserts a new student into the Students table if exists or else update the record.

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_student`(
	IN s_student_id int,
    IN s_first_name varchar(100),
    IN s_last_name varchar(100),
    IN s_email text,
    IN s_department_id int
)
BEGIN

	IF s_student_id is NULL then

		INSERT INTO tbl_students(first_name, last_name, email, department_id)
        VALUES (s_first_name, s_last_name, s_email, s_department_id);
		
	ELSE
		
		UPDATE tbl_students
		SET first_name = s_first_name,
			last_name = s_last_name,
			email = s_email,
			department_id = s_department_id
			where student_id = s_student_id;
		
	END IF;
		
END

CALL add_student(NULL, "Ayush2", "Rana", "ayushrana193@gmail.com", 4);



-- Created a stored procedure add_professor that inserts a new professor into the Professors table if exists or else update the record.

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_professor`(
	IN p_professor_id int,
    IN p_first_name varchar(100),
    IN p_last_name varchar(100),
    IN p_email text,
    IN p_department_id int
)
BEGIN

	IF p_professor_id is NULL then

		INSERT INTO tbl_professors(first_name, last_name, email, department_id)
        VALUES (p_first_name, p_last_name, p_email, p_department_id);
		
	ELSE
		
		UPDATE tbl_professors
		SET first_name = p_first_name,
			last_name = p_last_name,
            email = p_email,
			department_id = p_department_id
			where professor_id = p_professor_id;
		
	END IF;
		
END

Call add_professor(NULL, "Ayushhh","Rana","ayushranagmail.com", 7);



-- Writing a BEFORE INSERT trigger to modify the email field for the Students table.

DELIMITER //
CREATE TRIGGER before_student_insert
BEFORE INSERT ON tbl_students
FOR EACH ROW
BEGIN
	Set NEW.email = CONCAT(NEW.first_name, '.', NEW.last_name, '@domain.com');
END //
DELIMITER;


-- Writing an AFTER INSERT trigger to assign professors to departments when a new professor is added. << 

DELIMITER //
CREATE TRIGGER before_professor_insert 
BEFORE INSERT ON tbl_professors
FOR EACH ROW
BEGIN
	IF NEW.department_id IS NULL THEN
		SET NEW.department_id = (SELECT department_id FROM tbl_department WHERE department_name = 'Data Analytics');
	END IF;
END //
DELIMITER ;

Insert into tbl_professors values (NULL, "Ayushhh", "Ranaaa", "ayushrana12@gmail.com", NULL);


-- Creating an Event to Handle Expiring Enrollments

   DELIMITER //
   CREATE EVENT cleanup_old_enrollments
   ON SCHEDULE EVERY 1 DAY
   DO
   BEGIN
       DELETE FROM tbl_enrollments
       WHERE enrollment_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

       -- we can send a notification to students and professors (hypothetical)
   END;
      DELIMITER ;



