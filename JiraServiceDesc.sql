--CONTENT OF PROJECT--

--PROCEDURES--

[DB_BOARD].[CREATE_NEW_USER] @first = 'Vusal', @last = 'Rahimli', @password = 'v123456'

[DB_BOARD].[CREATE_NEW_TASK] @rep = 4, @ass = 2, @title = 'TITLE', @descr = 'DESCRIPTION', @imp = 1

[DB_BOARD].[CHANGE_STATUS] @userid = 3, @taskid = 7, @old = 1, @new = 6

[DB_BOARD].[CLOSE_TASK] @userid = 2, @taskid = 4

[DB_BOARD].[REOPEN_CLOSED_TASK] @userid = 4, @taskid = 4, @newstatus = 1

[DB_BOARD].[SHARE_TASK_WITH_USER] @user1 = 1, @taskid = 2, @user2 = 5

[DB_BOARD].[ASSIGN_TASK_ANY_USER] @userid = 3, @taskid = 3, @assigned = 4

[DB_BOARD].[ADD_COMMENT_TO_TASK] @userid = 4, @taskid = 4, @comment = 'comment'

[DB_BOARD].[ALL_TASK_COMMENTS] @task = 4

[DB_BOARD].[ADD_FILE_TO_TASK] @userid = 5, @taskid = 4, @file = 'FILE'

[DB_BOARD].[ALL_TASK_FILES] @task = 4

------------------------------------------------------------------------------------------

--FUNCTIONS--

--Table_Valued--

select * from [DB_BOARD].[GET_USER_ALL_ACTIVITY] (1)


--Scalar_Valued--

select [DB_BOARD].[USER_CREATED_TASK_COUNT] (1) as Tasks_Count

------------------------------------------------------------------------------------------

--TABLES--

select * from [dbo].[USERS]
select * from [DB_BOARD].[JIRATASKS]
select * from [DB_BOARD].[COMMENTS]
select * from [DB_BOARD].[FILES]
select * from [DB_BOARD].[IMPORTANCE]
select * from [DB_BOARD].[STATUSES]
select * from [DB_BOARD].[SHAREDWITH]

------------------------------------------------------------------------------------------

--VIEWs--

select * from [DB_BOARD].[ALL_ACTIVITIES_FRONT]
select * from [DB_BOARD].[TASK_ASSIGNED]
select * from [DB_BOARD].[MAX_SOLVED_TASK_USER]
select * from [DB_BOARD].[TASK_REPORTER]
select * from [DB_BOARD].[USER_INFO]
select * from [DB_BOARD].[TASK_SHW]
select * from [dbo].[ALL_BOARD]


------------------------------------------------------------------------------------------


--START-->


create schema AGILE_BOARD
create schema ANALYST_BOARD
create schema DB_BOARD
create schema Users
create schema IT_EXTERNAL_BOARD
create schema IT_INTERNAL_BOARD
create schema SYS_BOARD


select s.name as schema_name from sys.schemas s
inner join
sys.sysusers u 
on u.uid = s.principal_id
where s.name not in 
(
	'db_accessadmin',
	'db_backupoperator',
	'db_datareader',
	'db_datawriter',
	'db_ddladmin',
	'db_denydatareader',
	'db_denydatawriter',
	'db_owner',
	'db_securityadmin',
	'dbo',
	'guest',
	'INFORMATION_SCHEMA',
	'sys'
)

begin tran

create table DB_BOARD.JIRATASKS
(
	TASKID int primary key identity(1,1),
	REPORTER int,
	ASSIGNED int,
	SHW int,
	STATUS_ int,
	CREATEDATE datetime,
	CLOSEDDATE datetime,
	LASTUPDATE datetime,
	TITLE varchar(200),
	DESCR varchar(200),
	IMPORTANCE int,
	COMMENTNUM int,
	FILENUM int,
)



save tran tran1


create table USERS
(
	USERID int primary key identity(1,1),
	FULLNAME varchar(50),
	USERNAME varchar(50),
	AVATAR varchar(50),
	GROUPS varchar(50),
	PASSWORD_ varchar(50),
	email varchar(50)
)


save tran tran2


create table DB_BOARD.SHAREDWITH
(
	TASKID int, 
	USERID int,
	foreign key (TASKID) REFERENCES DB_BOARD.JIRATASKS (TASKID),
	foreign key (USERID) REFERENCES USERS (USERID)
)

save tran tran3


create table DB_BOARD.FILES
(
	TASKID int,
	FILE_ varchar(200),
	USERID int,
	foreign key (TASKID) REFERENCES DB_BOARD.JIRATASKS (TASKID)
)


save tran tran4


create table DB_BOARD.IMPORTANCE
(
	ID int primary key identity(1,1),
	TYPE_ varchar(50)
)

insert DB_BOARD.IMPORTANCE values ('Low'), ('Medium'), ('High')


save tran tran5



create table DB_BOARD.COMMENTS
(
	TASKID int,
	USERID int,
	CREATEDATE datetime,
	COMMENT varchar(200),
	foreign key (TASKID) REFERENCES DB_BOARD.JIRATASKS (TASKID)
)


save tran tran6


create table DB_BOARD.STATUSES
(
	ID int primary key identity(1,1),
	TYPE varchar(50)
)

insert [DB_BOARD].[STATUSES] values
('Backlog'),('In Development'),('Testing'),('Deploy to PreProduct'),('Deploy to Product'),('Done')

save tran tran7


alter table DB_BOARD.JIRATASKS add 
foreign key (IMPORTANCE) REFERENCES DB_BOARD.IMPORTANCE (ID),
foreign key (STATUS_) REFERENCES DB_BOARD.STATUSES (ID)

save tran tran8


create table DB_BOARD.ALL_ACTIVITY
(
	USERID int,
	UPDATE_DATE datetime,
	UPDATE_HISTORY varchar(200)
)

save tran tran9

commit


--PROCEDURES--
--PROC1--


create proc [DB_BOARD].CREATE_NEW_USER @first varchar(50), @last varchar(50), @password varchar(50)
as
begin
insert [dbo].[USERS] values (@first +' ' + @last, '@' + @first + @last, null, null, @password, lower(@first + @last + '@bootcamp.org'))
end



---------------------------------------------------------------------------------------

--PROC2--

create proc [DB_BOARD].CREATE_NEW_TASK @rep int, @ass int, 
@title varchar(200), @descr varchar(200), @imp int
as
begin
insert [DB_BOARD].[JIRATASKS] values (@rep, @ass, null, 1, 
getdate(), null, getdate(), @title, @descr, @imp, null, null)
insert [DB_BOARD].[ALL_ACTIVITY] values(@rep, getdate(),(SELECT FULLNAME FROM dbo.USERS WHERE @rep=USERID) + ' created task')
end


---------------------------------------------------------------------------------------


--PROC3--


create proc [DB_BOARD].ADD_COMMENT_TO_TASK @userid int, @taskid int, @comment varchar(200)
as
begin
insert [DB_BOARD].[COMMENTS] values (@taskid, @userid, getdate(), @comment)
update [DB_BOARD].[JIRATASKS] set COMMENTNUM = (select count(COMMENT) from [DB_BOARD].[COMMENTS] where TASKID = @taskid) where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set LASTUPDATE = getdate() where TASKID = @taskid
insert [DB_BOARD].[ALL_ACTIVITY] values(@userid, getdate(),(SELECT FULLNAME FROM dbo.USERS WHERE @userid=USERID) + ' added new comment')

end


---------------------------------------------------------------------------------------


--PROC4--


create proc [DB_BOARD].ADD_FILE_TO_TASK  @userid int, @taskid int, @file varchar(200)
as
begin
insert [DB_BOARD].[FILES] values (@taskid, @file, @userid)
update [DB_BOARD].[JIRATASKS] set FILENUM = (select count(FILE_) from [DB_BOARD].FILES where TASKID = @taskid) where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set LASTUPDATE = getdate() where TASKID = @taskid
insert [DB_BOARD].[ALL_ACTIVITY] values(@userid, getdate(),(SELECT FULLNAME FROM dbo.USERS WHERE @userid=USERID) + ' added new file')

end



-----------------------------------------------------------------------


--PROC5--

create proc [DB_BOARD].ALL_TASK_COMMENTS @task int
as 
begin
select COMMENT from [DB_BOARD].[COMMENTS] where TASKID = @task
end


-----------------------------------------------------------------------

--PROC6--

create proc [DB_BOARD].ALL_TASK_FILES @task int
as 
begin
select FILE_ from [DB_BOARD].[FILES] where TASKID = @task
end


-----------------------------------------------------------------------


--PROC7--

create proc [DB_BOARD].ASSIGN_TASK_ANY_USER @userid int,@taskid int, @assigned int
as
begin
update [DB_BOARD].[JIRATASKS] set ASSIGNED = @assigned where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set LASTUPDATE = getdate() where TASKID = @taskid
insert [DB_BOARD].[ALL_ACTIVITY] values(@userid, getdate(),(SELECT FULLNAME FROM dbo.USERS WHERE @userid=USERID) + ' assign  task to '
+(SELECT FULLNAME FROM dbo.USERS WHERE @assigned=USERID))

end

-----------------------------------------------------------------------

--PROC8--


create proc [DB_BOARD].CHANGE_STATUS @userid int, @taskid int, @old int, @new int
as 
begin
update [DB_BOARD].[JIRATASKS] set [STATUS_] = @new where @taskid = TASKID
update [DB_BOARD].[JIRATASKS] set LASTUPDATE = getdate() where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set CLOSEDDATE = getdate() where STATUS_ = @new
insert [DB_BOARD].[ALL_ACTIVITY] values(@userid, getdate(),(SELECT FULLNAME FROM dbo.USERS WHERE @userid=USERID) + 
' change status task no'+ CAST(@taskid AS VARCHAR))
end





-----------------------------------------------------------------------


--PROC9--

create proc [DB_BOARD].CLOSE_TASK @userid int , @taskid int
as
begin
update [DB_BOARD].[JIRATASKS] set [CLOSEDDATE] = getdate() where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set STATUS_ = 6 where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set LASTUPDATE = getdate() where TASKID = @taskid
insert [DB_BOARD].[ALL_ACTIVITY] values(@userid, getdate(), (SELECT FULLNAME FROM dbo.USERS WHERE @userid=USERID) + 
' closed task No' + CAST(@taskid AS VARCHAR))

end


-----------------------------------------------------------------------


--PROC10--


create proc [DB_BOARD].REOPEN_CLOSED_TASK @userid int, @taskid int, @newstatus int
as
begin
update [DB_BOARD].[JIRATASKS] set STATUS_ = @newstatus where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set CLOSEDDATE = null where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set LASTUPDATE = getdate() where TASKID = @taskid
insert [DB_BOARD].[ALL_ACTIVITY] values(@userid, getdate(),(SELECT FULLNAME FROM dbo.USERS WHERE @userid=USERID) + ' open closed task No' + 
CAST(@taskid AS VARCHAR))

end




-----------------------------------------------------------------------


--PROC11--


create proc [DB_BOARD].SHARE_TASK_WITH_USER @user1 int ,@taskid int, @user2 int
as
begin
update [DB_BOARD].[JIRATASKS] set SHW = @user2 where TASKID = @taskid
update [DB_BOARD].[JIRATASKS] set LASTUPDATE = getdate() where TASKID = @taskid
insert [DB_BOARD].[ALL_ACTIVITY] values(@user1, getdate(),(SELECT FULLNAME FROM dbo.USERS WHERE @user1=USERID) + 
' shared task to '+(SELECT FULLNAME FROM dbo.USERS WHERE @user2=USERID))
insert [DB_BOARD].[SHAREDWITH] values (@taskid, @user2)

end


--VIEWs--

--view1--

create view [dbo].ALL_BOARD as

select s.name as schema_name from sys.schemas s
inner join
sys.sysusers u 
on u.uid = s.principal_id
where s.name not in 
(
	'db_accessadmin',
	'db_backupoperator',
	'db_datareader',
	'db_datawriter',
	'db_ddladmin',
	'db_denydatareader',
	'db_denydatawriter',
	'db_owner',
	'db_securityadmin',
	'dbo',
	'guest',
	'INFORMATION_SCHEMA',
	'sys'
)

select * from [dbo].[ALL_BOARD]


--view2--

create view DB_BOARD.USER_INFO
as
select 
	USERID as ID,
	FULLNAME as Fullname,
	USERNAME as Username ,
	AVATAR as Avatar,
	GROUPS as Groups,
	(select stuff (Password_,2,LEN(PASSWORD_)-2,'*******')) AS Password_
from dbo.USERS

select * from DB_BOARD.USER_INFO



--view3--

create view [DB_BOARD].[TASK_REPORTER]
as
select
j.TASKID, i.TYPE_, j.TITLE,u.FULLNAME Reporter
from 
[DB_BOARD].[JIRATASKS] j
INNER JOIN [DB_BOARD].[IMPORTANCE] i ON j.IMPORTANCE = i.ID
INNER JOIN dbo.USERS u ON j.REPORTER=u.USERID



--view 4--
create view [DB_BOARD].[TASK_ASSIGNED]
AS
select
j.TASKID, i.TYPE_, j.TITLE,u.FULLNAME Reporter,usr.FULLNAME Assignee
from 
[DB_BOARD].[JIRATASKS] j
INNER JOIN [DB_BOARD].[IMPORTANCE] i ON j.IMPORTANCE = i.ID
INNER JOIN dbo.USERS u ON j.REPORTER=u.USERID
INNER  JOIN  dbo.USERS usr ON j.ASSIGNED=usr.USERID

select * from [DB_BOARD].TASK_REPORTER


--view 5--
create view [DB_BOARD].TASK_SHW
AS

select
j.TASKID ,j.TITLE as TaskName, u.FULLNAME  as Initial_Reporter, usr.FULLNAME as Reporter,urr.FULLNAME as Assignee 
from 
[DB_BOARD].[JIRATASKS] j
INNER JOIN dbo.USERS u ON j.REPORTER=u.USERID
INNER  JOIN  dbo.USERS usr ON j.ASSIGNED = usr.USERID
INNER JOIN dbo.USERS urr ON j.SHW=urr.USERID



--view 6--

---------------------------------------------------------------------------
---Max task solved user---
create view [DB_BOARD].[MAX_SOLVED_TASK_USER]
AS
with CTETABLE as
(
select top 3
usr.FULLNAME Assignee,
COUNT(s.TYPE) as Done 
from 
[DB_BOARD].[JIRATASKS] j
INNER  JOIN  dbo.USERS usr ON j.ASSIGNED=usr.USERID
INNER JOIN [DB_BOARD].[STATUSES] s ON j.STATUS_=S.ID
WHERE j.STATUS_=6
GROUP BY usr.FULLNAME ORDER BY Done DESC )

select 
Assignee,
case when
Done=(select Max(Done) from CTETABLE) then '*****'
when 
Done=(select Done from CTETABLE Where Done<(select Max(Done) from CTETABLE) and Done>(select Min(Done) from CTETABLE)) then '****'

when
Done=(select Min(Done) from CTETABLE) then '***'

end as liga
from CTETABLE

Select * from [DB_BOARD].[MAX_SOLVED_TASK_USER]

--view7--

create view [DB_BOARD].ALL_ACTIVITIES_FRONT as
select [UPDATE_DATE],  [UPDATE_HISTORY] from [DB_BOARD].[ALL_ACTIVITY]


--FUNCTION--
--TABLE VALUED--
create function [DB_BOARD].[GET_USER_ALL_ACTIVITY](@userid int)
returns table
as
return
select * from [DB_BOARD].[ALL_ACTIVITY] where @userid=USERID


select * from [DB_BOARD].[GET_USER_ALL_ACTIVITY] (1)


--SCALAR VALUED--

create function [DB_BOARD].[USER_CREATED_TASK_COUNT](@userid int)
returns int					   
begin									
return
(
select COUNT(TASKID) REPORTER_TASKS FROM [DB_BOARD].[JIRATASKS] WHERE REPORTER=@userid
)
end



select [DB_BOARD].[USER_CREATED_TASK_COUNT](1) as Task_Count


-->end



