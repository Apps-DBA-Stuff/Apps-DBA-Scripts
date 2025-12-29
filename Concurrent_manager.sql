-- ***************************************************************************************
-- ** File Name 	: concurrent_manager.sql
-- ** Description 	: Bunch of SQL Selects Statements useful to find information about CCM
-- ** Requirement	: Access to Database with APPS privileges.
-- ** Modified		: 2022-11-01
-- ***************************************************************************************

-- **
-- ** Find concurrent requests has been running for more than one hour this week.
-- **

select 
	count(1) 
from fnd_concurrent_requests
where nvl(actual_completion_date, sysdate) - actual_start_date > 1/24
and	request_date > trunc(sysdate, 'DAY');

-- **
-- ** Find jobst for today that had to wait 10 minutes or longer to running
-- **

select 
	count(1) 
from  fnd_concurrent_requests
where actual_start_date - greatest(request_date, requested_start_date) > 10/(24*60*60)
and request_date > trunc(sysdate); 

-- **
-- ** Find the amount of job that completed normaly for a specific date.
-- **

select 
	count(1)
from fnd_concurrent_requests
where phase_code = 'C'
and status_code = 'C'
and actual_completion_date like '2025-12-29' -- Change the date according to needs.

-- **
-- ** Longest 10 running jobs the last 3 days in status completed.
-- ** 

select * from 
(
select 
   request_id "Request id", 
   fcptls.user_concurrent_program_name "User CCM Name",
   fre.responsibility_name "Responsibility",
   fu.user_name "User",
   actual_start_date "Start Time", 
   actual_completion_date "Completion Time" ,
   round(24*3600 *(nvl(actual_completion_date,sysdate)-actual_start_date)) "Run Time (seconds)",
   round(24*60 *(nvl(actual_completion_date,sysdate)-actual_start_date),2) "Run Time (minutes)",
   round(24*60 *(nvl(actual_completion_date,sysdate)-actual_start_date)/60,2) "Run Time (hours)",
   fcqtl.user_concurrent_queue_name  "Queue",
   decode(fcr.phase_code,'C','Completed','P','Pending/Inactive','R','Running') "Phase",
   decode(fcr.status_code ,'C','Normal','G','Warning','E','Error','W','Paused','R','Running','Q','Scheduled','I','On Hold','X','Terminated') "Status"
from 
   fnd_concurrent_requests fcr
   , fnd_concurrent_programs fcp
   , fnd_concurrent_programs_tl fcptls
   , fnd_concurrent_programs_tl fcptlus   
   , fnd_user fu
   , fnd_responsibility_tl fre
   , fnd_concurrent_processes fcproc
   , fnd_concurrent_queues_tl fcqtl   
where 
   fcr.concurrent_program_id               = fcp.concurrent_program_id 
   and fcr.requested_by                    = fu.user_id
   and fcr.program_application_id          = fcp.application_id 
   and fcr.concurrent_program_id           = fcptls.concurrent_program_id 
   and fcr.program_application_id          = fcptls.application_id 
   and fcr.concurrent_program_id           = fcptlus.concurrent_program_id 
   and fcr.program_application_id          = fcptlus.application_id    
   and fcr.controlling_manager             =  fcproc.concurrent_process_id 
   and fcqtl.concurrent_queue_id           = fcproc.concurrent_queue_id 
   and fcr.responsibility_id               = fre.responsibility_id
   and fcqtl.language                       ='US'   
   and fcptls.language                     = 'US' 
   and fcptlus.language                    = 'US'    
   and fcr.phase_code                      = 'C' 
   and status_code                         != 'X'
   and trunc(actual_start_date)            = trunc(sysdate-3)
   and  fcptls.user_concurrent_program_name not in ('Request Set Stage','Report Set')
order by 8 desc
)
where rownum <= 10;


