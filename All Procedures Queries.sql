--Three main stored procedures

--Generate Exam
ALTER PROC [dbo].[Generate_Exam] @course_name VARCHAR(10), @no_of_mcq INT, @no_of_t_or_f INT
	AS	
	if @no_of_mcq + @no_of_t_or_f = 10
	begin
		DECLARE @viewedExam TABLE
				(quesID INT, question VARCHAR(1000), choice1 VARCHAR(700), choice2 VARCHAR(700), choice3 VARCHAR(700), choice4 VARCHAR(700))
					INSERT INTO @viewedExam
				SELECT * from
					(SELECT TOP (@no_of_mcq) q.ID, q.content AS QUESTION,q.[Choice A], q.[Choice B], q.[Choice C], q.[Choice D]
						FROM Question q, Course c
							WHERE q.type = 'MCQ' AND q.cr_id = c.ID AND c.name = @course_name
								ORDER BY NEWID()) MCQ
				UNION ALL
				SELECT * from
					(SELECT TOP (@no_of_t_or_f) q.ID, q.content AS QUESTION,q.[Choice A], q.[Choice B], q.[Choice C], q.[Choice D]
						FROM Question q, Course c
							WHERE q.type = 'T&F' AND q.cr_id = c.ID AND c.name = @course_name
								ORDER BY NEWID()) TrueFalse 
             
				begin try
					DECLARE @examId INT
					SELECT @examId = NEXT VALUE FOR mySeq
					INSERT INTO Exam (ID, Duration, Date, Start_Time, cr_id)
					VALUES (@examId, 120, Convert(date, getdate()), cast(getdate() as time(0)), (SELECT ID FROM Course WHERE name = @course_name));
								INSERT INTO exam_questions (ex_id, q_id)
					SELECT TOP 10 (@examId), quesID FROM @viewedExam
			
					SELECT question, choice1, choice2, choice3, choice4 FROM @viewedExam
				end try
				begin catch
					select 'Course name is wrong'
				end catch
	end
	else 
		begin
			select 'Number of questions must be 10 only'
		END
	----------------------------------------------------------------------
	--Exam Corrretion
	ALTER procedure [dbo].[correctExam](@Std_SSN bigint, @Ex_Id int)
as
	declare @table table (q_id int, correct nchar(1), std_anwser nchar(1))
	insert into @table
	select q.id, q.correct_answer, sx.std_anwser
	from question q, exam_questions eq, Student_Exam sx
	where q.id = eq.q_id and q.id = sx.q_id and eq.ex_id = @ex_id and sx.std_ssn = @std_ssn
	declare @correct nchar(1), @std_anwser nchar(1)

	declare @i int = 0, @grade int = 0
	while @i < 10
		begin
			select top(@i) @correct = correct, @std_anwser = std_anwser
			from @table
			if(@correct = @std_anwser)
				begin
					set @grade += 1
				end
			set @i += 1
		end
	begin try
		declare @cr_id int 
		select @cr_id = cr_id
		from exam
		where id = @ex_id
		insert into student_courses (std_ssn, cr_id, grade)
		values (@Std_SSN, @cr_id, @grade)
	end try
	begin catch
		select 'The Exam Id or Student SSN not found', error_message()
	end CATCH
	--------------------------------------------------------------------------------------
	--Exam Answers
	ALTER procedure [dbo].[Exam_Answers] (@Std_SSN bigint, @Ex_Id int ,@std_answer nchar(19))
as
	begin try
		declare @table1 table (JoiningID1 INT IDENTITY(1,1), anwser nchar(1))
		insert into @table1
		SELECT value
			FROM STRING_SPLIT(@std_answer, ',')

		declare @table2 table (JoiningID2 INT IDENTITY(1,1), q_id int)
		insert into @table2
		select q_id
		from exam_questions eq
		where eq.ex_id = @Ex_Id
		
		insert into student_exam (std_ssn, ex_id, q_id, std_anwser)
		select @std_ssn, @ex_id, t2.q_id, t1.anwser
		from @table1 t1, @table2 t2
		where JoiningID2 = JoiningID1

	end try
	begin catch
		select 'There is a problem', error_message()
	end catch


----================================================ course--------------------
----------------------------------- insert----------------------------------------
create proc insertCourse (
@ID int,
@Name varchar(50),
@Duration int)
as
  begin try
   insert into Course
   Values(@ID,@Name,@Duration)
  end try
  begin catch
		select 'QueryError, Nothing Has Executed'
  end catch
  Go
  	-- proc Execution 
	insertCourse 7,"Dm", 3
  ----------------------------------- select------------------------------------------------

 --select command
 create proc selectCourse @ID int
 as 
  begin try
    select * from Course
	where ID=@ID
  end try
  begin catch
		select 'QueryError, Nothing Has Executed'
  end catch
  -- proc Execution 
  selectCourse 7
----------------------------------- update------------------------------------------------

 --update command
 create proc updateCourseName @ID int,@Name varchar(50)
 as 
 begin try
    update Course
	set Name=@Name
	where ID=@ID
 end try
  begin catch
		select 'QueryError, Nothing Has Executed'
  end catch
 
 Go


   -- proc Execution 
  updateCourseName 7,"uml"
 ----------------------------------- delete ------------------------------------------------

 --delete command
create proc deleteCourse @ID int
 as 
 begin try
    delete Course
	where ID=@ID
end try
 begin catch
		select 'QueryError, Nothing Has Executed'
  end catch
 Go
    -- proc Execution 
	deleteCourse 7







	--================================================ Exam Table======================================================
-----------------------------------insert------------------------------------------------


create proc insertExam 
(
@ID int,
@Date date,
@Start_Time time(7),
@Duration float ,
@Cr_id int
)
as
   begin try
   insert into Exam
   Values(@ID,@Date,@Start_Time,@Duration,@Cr_id)
   end try
   begin catch
		select 'QueryError, Nothing Has Executed'
   end catch
  Go

      -- proc Execution  //////////
	insertExam    9,2023-02-26,23:54:03.6000000,120,1
	-------------------------------select-------------

	create proc selectexam @ID int
 as 
  begin try
    select * from Exam
	where ID=@ID
  end try
  begin catch
		select 'QueryError, Nothing Has Executed'
  end catch
  -- proc Execution 
  selectexam 7
	

 ----------------------------------- update-----------------------------------------------

 --update command

create proc updateExam @ID int,@Duration float
 as 
 begin try
    update Exam
	set Duration=@Duration
	where ID=@ID
 end try
 begin catch
			select 'QueryError, Nothing Has Executed'
 end catch
 Go
 
  -- proc Execution
  updateExam 7, 110
 ----------------------------------- delete------------------------------------------------

 --delete command
create proc deleteExam @ID int
 as 
 begin try
    delete Exam
	where ID=@ID
 end try
 begin catch
			select 'QueryError, Nothing Has Executed'
 end catch
 Go
  -- proc Execution
  deleteExam 7
















-------------------DEPARTMENT TABLE------------------

------------------Insertion----------------
create proc insertDepartment
(
@Dept_Id int,
@Name varchar(50),
@M_SSN bigint
)
as
	begin try
		insert into Department
		values(@Dept_Id,@Name,@M_SSN)
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch

	-- proc Execution          //
insertDepartment  8,"Cross",29610171500045

-------------SELECTION BY  Name---------------------
create proc selectDepartment @Name varchar(50)
as
	begin try
		select * from Department where Name=@Name
 	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch

-- proc Execution 
		selectDepartment "SD"

--=========Selction ALL===============
create proc selectAllDepartments
as
	begin try
		select Name as Department_Name,M_SSN as Department_M_SSN from Department
 	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch
	-- proc Execution 
	selectAllDepartments
 
-------------UPDATING-----------------
create proc updateDepartmentName (
@Dept_Id int, @Name varchar(50)
)
as 
	begin try
		update Department
		set Name=@Name
		where Dept_Id=@Dept_Id
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch
		-- proc Execution 

		updateDepartmentName 7,"Cross"


		-------------------DELETE-----------------
create proc deleteDeparment @Name varchar(20)
as
	begin try
		delete from Department 
		where Name=@Name
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch
		-- proc Execution
deleteDeparment "Cross"















-----------------------INSTRUCTORS---------------------------
-- -----------Insertion------------
create proc insertInstructor
(
    @SSN bigint,
    @Fname varchar(50),
	@Lname varchar(50),
	@Age int,

	@Gender nchar(1),
	@City varchar(50),
	@Street varchar(50),
	@Building int,
	@Phone int,
    @Dept_Id int
)
as
	begin try
		insert into Instructor
		values(@SSN,@Fname,@Lname,@Age,@Gender,@City,@Street,@Building,@Phone,@Dept_Id)
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch
	-- proc Execution
	insertInstructor 27610171500046,"MOHAMED","Abdelmonem",46,'M',"Biyala","Alahram",1,01012293070,5


---------------Selction ALL-----------
create proc selectAllInstructors
as
	begin try
		select ins.SSN,ins.Fname,ins.Lname,ins.Age,ins.Gender,ins.City,ins.Street,ins.Building,ins.Phone,ins.Phone,dept.Name
		from Instructor as ins,Department as dept
		where ins.Dept_Id=dept.Dept_Id

 	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch

	-- proc Execution
	selectAllInstructors

----------------SELECTION BY SSN-----------------
create proc selectInstructor @SSNI bigint
as
	begin try
		select SSN,Fname,Lname,Age,Gender,City,Street,Building,Phone,Phone,dept.Name
		from Instructor as ins,Department as dept
		where SSN = @SSNI
		and  ins.Dept_Id =dept.Dept_Id
 	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch

	-- proc Execution
	selectInstructor 27610171500046

	--------------UPDATING----------------
create proc updateInstructorCity @SSNI bigint,@City varchar(50)
as
	begin try
		update Instructor
		set City=@City
		where SSN=@SSNI
	end try
	begin catch
			select 'QueryError, Nothing Has Executed'
	end catch

	-- proc Execution
	updateInstructorCity 27610171500046, "KAFRELSHIKH"


----------------------DELETE-----------------------
create proc deleteInstructor @SSNI bigint
as
	begin try
		delete from Instructor 
		where SSN=@SSNI
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch

	-- proc Execution
	deleteInstructor  27610171500046 

	--================================================ Question Table======================================================
-----------------------------------insert command------------------------------------------------


  -- insertQuetions
create proc insetQuestion
(
@ID INT,
@Type varchar(50),
@Content varchar(1000),
@Cr_Id int,
@Correct_Answer varchar(700),
@Choice_A varchar(700),
@Choice_B varchar(700),
@Choice_C varchar(700),
@Choice_D varchar(700)
)
 as
 begin try
  insert into Question
  Values(@ID,@Type,@Content,@Cr_Id,@Correct_Answer,@Choice_A,@Choice_B,@Choice_C,@Choice_D)
  end try
  begin catch
		select 'QueryError, Nothing Has Executed'
  end catch


  Go
  ----------------------------------- select command------------------------------------------------


create proc SelectQuetions @Cr_Id int
as
begin try
select * from Question
where Cr_Id=@Cr_Id
end try
 begin catch
		select 'QueryError, Nothing Has Executed'
  end catch

Go
  ----------------------------------- update command------------------------------------------------

-- update Quetion
create proc updateQuetions @Content varchar(1000),@ID int
as
begin try
	update Question
	set Content=@Content
	where ID=@ID
end try
begin catch
		select 'QueryError, Nothing Has Executed'
  end catch

Go
----------------------------------- delete command------------------------------------------------

 -- delete Quetions
 create  proc deleteQuetion @ID int
 as
 begin try
   delete 
   from Question
   where ID=@ID
   end try
   begin catch
		select 'QueryError, Nothing Has Executed'
   end catch
   Go

--------------- Student----------
----Insertion----------------
create proc insertStudent 
(
   @SSN bigint,
	@Fname varchar(50),
	@Lname varchar(50),
	@Age int,
	@Faculty varchar(50),
	@Gender nchar(1),
	@City varchar(50),
	@Street varchar(50),
	@Building int,
	@Phone int
)
as
	begin try
		insert into Student
		values(@SSN,@Fname,@Lname,@Age,@Faculty,@Gender,@City,@Street,@Building,@Phone)
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch
	-- proc Execution
	insertStudent 29610171500046,"Esraa","Abdelmonem",26,"Sharia",'f',"Biyala","Alahram",1,01012293070
	

-------------------Select ALL STUDENTS-------------------------
create proc selectAllStudents
as
	begin try
	select s.*
		from Student as s, Department as dept
		where s.SSN=dept.M_SSN
 	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch
	-- proc Execution
	selectAllStudents
	-------------------------SELECTION BY SSN---------------
create proc selectStudent @SSN bigint
as
	begin try
		select s.SSN,s.Fname,s.Lname,s.Age,s.Faculty,s.Gender,s.City,s.Street,s.Building,s.Phone
		from Student as s,Department as dept
		where s.SSN=@SSN
		and s.SSN=dept.M_SSN
 	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch
	-- proc Execution
	selectStudent 29908091200777
	----------------UPDATING----------------
create proc updateStudentFaculty @SSN bigint,@Faculty varchar(50)
as
	begin try
		update Student 
		set Faculty=@Faculty
		where SSN=@SSN
	end try
	begin catch
			select 'QueryError, Nothing Has Executed'
	end catch
	-- proc Execution
	updateStudentFaculty 29610171500046,"Comparative jurisprudence"
	------------------DELETE----------------
create proc deleteStudent @SSN bigint
as
	begin try
		delete from Student 
		where SSN=@SSN
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch

-- proc Execution
	deleteStudent 29610171500046



	-----------------------

	--================= INSTRUCTOR_COUSE TABLE ======================

-- ========Insertion==========

create proc insertInstructorCrs
(
@In_SSN BIGint,
@Cr_Id varchar(20)
)
as
	begin try
		insert into Instructor_Courses
		select(select SSN from Instructor where SSN= @In_SSN ),
		(select ID from Course where ID= @Cr_Id)
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch


--=========SELECTION ALL Course WITH INST NID===============
create proc viewInstructorsCoursec 
as
	begin try
		select Concat(ins.Fname,' ',ins.Lname) as Instructor_Name, cr.Name as Course_Name
		from Course as cr,Instructor as ins,Instructor_Courses as inscr
		where  cr.ID=inscr.Cr_Id and ins.SSN=inscr.In_SSN 
 	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch

--===========DELETE============
create proc deleteInstCrsRelation  @In_SSN bigint,@Cr_Id int
as
	begin try
		delete from Instructor_Courses
		where In_SSN=(select SSN from Instructor where In_SSN=@In_SSN)
		And
		Cr_Id =(select ID from Course where Cr_Id=@Cr_Id)
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch

--======== INSTRUCTOR Course==================
create proc updateInstructorCrs @In_SSN bigint,@oldCrs varchar(50),@newCrs varchar(50) 
as
	begin try
	update Instructor_Courses
	set Cr_Id=(select ID from Course where Name=@newCrs)
	where In_SSN=(select SSN from Instructor where In_SSN=@In_SSN)
	and
	Cr_Id=(select ID from Course where Name=@oldCrs)
	end try
	begin catch
		select 'QueryError, Nothing Has Executed'
	end catch


	--------------------Reports----------------------
	------ 1•Report that returns the students information according to Department No parameter.
Alter PROC Students_info_in_Department
@Department_Id INT
AS
BEGIN
    BEGIN TRY
	declare @departmen_name varchar(50)
	SELECT @departmen_name = name
	FROM Department WHERE Dept_Id = @Department_Id
        IF @departmen_name is not null
			BEGIN
					IF EXISTS (
						SELECT s.*
						FROM Student s
						WHERE s.Dept_ID = @Department_Id
					) 
						BEGIN
							SELECT @departmen_name as [Department Name], s.*
							FROM Student s
							WHERE s.Dept_ID = @Department_Id
						END
					ELSE 
						BEGIN
							select'This department has no students' as Error
						END
			ENd
        ELSE
			BEGIN
				SELECT 'The department id does not exist' as Error
			END
    END TRY
    BEGIN CATCH
        SELECT 'An error occurred while processing the request' as Error
    END CATCH
END

EXECUTE Students_info_in_Department 1

-- 2•Report that takes the student ID and returns the grades of the student in all courses. %
Alter PROC Student_Grades_in_each_course
@St_Id BIGINT
AS
BEGIN
	BEGIN TRY
	declare @Student_Name varchar(100)
		SELECT @Student_Name = (s.Fname + ' ' + s.Lname) 
		FROM student s 
		WHERE ssn = @St_Id
        IF @student_Name is not null
			BEGIN
				--DECLARE @St_Id BIGINT = 29802021200916
				SELECT @student_Name as [Student Name], c.Name as [Course Name], sc.Grade
				FROM Student_Courses sc INNER JOIN Course c
				ON   sc.Cr_Id = c.ID
				WHERE sc.Std_SSN = @St_Id
			END
		ELSE
			BEGIN
				SELECT 'This student does not exist' as Error
			END
	END TRY 
	BEGIN CATCH
		SELECT 'An error occurred while processing the request' as Error
	END CATCH
END

	EXECUTE Student_Grades_in_each_course 29908091200777

-- 3•Report that takes the instructor ID and returns the name of the courses that he teaches and the number of student per course.

Alter PROC courses_info_for_instrucor
@Ins_Id BIGINT
AS
BEGIN
	BEGIN TRY
        IF EXISTS(SELECT * FROM Instructor i WHERE i.SSN= @Ins_Id)
			BEGIN
				declare @Instructor_Name varchar(100) 
				select @Instructor_Name = (i.Fname + ' ' +i.Lname)
				from instructor i
				where i.SSN = @Ins_Id

				SELECT @Instructor_Name as [Instructor Name], c.Name as [Course Name] , COUNT(sc.Std_SSN) AS 'Number of students'
				FROM Course c INNER JOIN Instructor_Courses ic
				ON c.ID = ic.Cr_Id  AND  ic.In_SSN = @Ins_Id
								INNER JOIN Student_Courses sc
								ON c.ID = sc.Cr_Id
								GROUP BY c.Name
			END
		ELSE
			BEGIN
				SELECT 'This instructor does not exist' as Error
			END
	END TRY 
	BEGIN CATCH
		SELECT 'An error occurred while processing the request' as Error
	END CATCH
END


EXECUTE courses_info_for_instrucor 29908091200444

--4•Report that takes course ID and returns its topics  
Alter procedure Course_Topics (@CrId int)
as
	declare @Course_Name varchar(50)
	select @Course_Name = name
		from course
		where id = @crid
	if @Course_Name is not null
		begin
			select @Course_Name as [Course Name] , Name as Topics_Name
			from topics
			where cr_id = @CrId
		end
	else
		begin
			select 'This couse is not found' as Error
		end

Course_Topics 1

--5-•Report that takes exam number and returns the Questions in it and chocies [freeform report]
CREATE SEQUENCE Counter_Questions
start with 1
increment by 1
minvalue 1
maxvalue 10
cycle;

alter PROC Print_Exam_questions
@Exam_Id BIGINT
AS
BEGIN
	BEGIN TRY
		--DECLARE @Exam_Id INT = 5
		--SELECT * FROM Exam e  WHERE e.ID= @Exam_Id
        IF EXISTS(SELECT * FROM Exam e  WHERE e.ID= @Exam_Id)
			BEGIN
		
			SELECT c.name as [Course Name], e.date, e.start_time, e.duration, NEXT VALUE FOR Counter_Questions as [Counter Questions],Type, q.Content AS [Question Content] , q.[Choice A],q.[Choice B],q.[Choice C],q.[Choice D]
				FROM Exam_Questions eq, Question q, exam e, course c
				where eq.ex_id = @exam_id and e.id = @exam_id and eq.q_id = q.id and c.id = e.cr_id

			END
		ELSE
			BEGIN
				SELECT 'This exam does not exist' as Error
			END
	END TRY 
	BEGIN CATCH
		SELECT 'An error occurred while processing the request' as Error
	END CATCH
END
	
EXECUTE Print_Exam_questions 6

--6•Report that takes exam number and the student ID then returns the Questions in this exam with the student answers. 
Alter PROC Exam_Questions_And_Student_Answers
(@ExamID INT , @Stu_Id BIGINT)
AS
BEGIN
	BEGIN TRY
		declare @Student_Name varchar(100)
			SELECT @Student_Name = (s.Fname + ' ' + s.Lname)
			FROM Student s, Student_Exam se
			WHERE s.SSN= @Stu_Id 
				AND 
				se.Ex_ID = @ExamID 
				and 
				s.SSN = se.Std_SSN
        IF @Student_Name is not null
			BEGIN
				SELECT @Student_Name as [Student Name] ,q.Content, se.Std_Anwser
				FROM Student_Exam se INNER JOIN Question q
						ON se.Q_ID = q.ID
				WHERE se.Ex_ID = @ExamID AND se.Std_SSN = @Stu_Id
			END
		ELSE
			BEGIN
				SELECT 'This exam or this student does not exist' as Error
			END
	END TRY 
	BEGIN CATCH
		SELECT 'An error occurred while processing the request' as Error
	END CATCH
END
	
EXECUTE Exam_Questions_And_Student_Answers 5, 29908091200777

correctExam 29908091200777, 5