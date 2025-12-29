-- **************************************************************************
-- ** File Name 	: System_Profile_Options.sql
-- ** Description 	: Bunch of SQL Selects Statements for profile options.
-- ** Requirement	: Access to Database with APPS privileges.
-- ** Modified		: 2022-10-22
-- **************************************************************************

-- **
-- ** Profile Option Level Value Mappings (FND_PROFILE_OPTION_VALUES.LEVEL_ID => LEVEL_VALUE
-- **

10001 => 'Site'
10002 => 'Application'
10003 => 'Responsibility'
10004 => 'User'

-- **
-- ** Get the ID | Name for a profile option where the name is fully known.
-- **

select 
	distinct a.profile_option_id, 
	a.profile_option_name
from 
	fnd_profile_options a, fnd_profile_options_tl b
where 
	a.profile_option_name in 
	  ('ECE_IN_FILE_PATH');

-- **
-- ** Getting information about values for profile values. (BASE US LANG)
-- ** The only known information to use this query is "User Profile Option Name".
-- ** The query will only return information if the Profile Option has a value on any level
-- **

select 
    a.profile_option_id, 
    a.profile_option_name, 
    c.user_profile_option_name, 
    b.profile_option_value, 
    decode (b.level_id, 10001, 'Site (10001)', 10002, 'Application (10002)', 10003, 'Responsibility (10003)', 10004, 'User (10004)', NULL) AS "LEVEL_ID",
    b.level_value  
from 
    fnd_profile_options a,
    fnd_profile_option_values b,
    fnd_profile_options_tl c
where 
    c.user_profile_option_name in 
    (select user_profile_option_name from fnd_profile_options_tl where user_profile_option_name like '&1')
and a.profile_option_id = b.profile_option_id
and a.profile_option_name = c.profile_option_name
and a.language = 'US'
order by a.profile_option_id, b.level_id;


-- **
-- ** Getting information on Profile options set on site level => 10001. (BASE US LANG) where the PROFILE_OPTION_NAME is partly known.
-- ** 

select 
	a.profile_option_name, 
	a.user_profile_option_name, 
	c.profile_option_value, 
	c.level_id, b.profile_option_id 
from 
	fnd_profile_options_tl a, 
	fnd_profile_options b, 
	fnd_profile_option_values c
where 
	a.profile_option_name = b.profile_option_name
and b.profile_option_id = c.profile_option_id
and a.language = 'US'
and c.level_id = 10001
and b.profile_option_id in 
  (select profile_option_id from fnd_profile_option_values where profile_option_value like '%&1%');
  
  

