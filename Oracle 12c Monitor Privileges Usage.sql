-- Author: 	Hussain refaa
-- creation Date: 	2016
-- Last Updated: 	0000-00-00
-- Control Number:	xxxx-xxxx-xxxx-xxxx
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: hus244@gmail.com

 Database user get more privilege than actually required. 
 This could be security loophole which may result in unauthorised database access. 
 More over excessive privileges violate the basic security principle of least privilege.
In Oracle 12c we have new database package, DBMS_PRIVLEGE_CAPTURE helps us on capture and analyse the privileges usage.
On basic of analysis we can determine the privileges that can be revoked for normal operations. 
This package will generate information of privileges usage between time the capture is enabled and the capture is disabled.

CAPTURE_ADMIN role should be granted to the user for executing package DBMS_PRIVLEGE_CAPTURE.
Following are the procedures available on the package.

create_capture: Creates a policy that specifies the conditions for analyzing privilege use.
enable_capture: Starts the recording of privilege analysis for a specified privilege analysis policy.
disable_capture: Stops the recording of privilege use for a specified privilege analysis policy
generate_result: Populates the privilege analysis data dictionary views with data
drop_capture: Removes a privilege analysis policy together with the data recorded.

1-
Create_capture procedure creates the policy to analyse privilege usage. Privileges can be
analysed on following level.
G_DATABASE : Analyse the privilege usage on database level for all the users except SYS
G_ROLE : Analyse the privilege usage for specific role(s). ROLE_NAME_LIST need to be used for the roles list.
G_CONTEXT : Analyse the privilege whenever the condition specified get matched and returns TRUE.
G_ROLE_AND_CONTEXT : Analyse the privileges whenever the role and the condition get matched and returns TRUE.

Create capture at database level.
begin
DBMS_PRIVILEGE_CAPTURE.create_capture(
name => 'db_capture',
type => DBMS_PRIVILEGE_CAPTURE.g_database
);
end;
/

2-
Create capture at role level.
begin
DBMS_PRIVILEGE_CAPTURE.create_capture(
name => 'rl_capture',
type=> DBMS_PRIVILEGE_CAPTURE.g_role,
roles => role_name_list('CONNECT','RL_DILLI')
);
end;
/
3-
Create capture at context level.
begin
DBMS_PRIVILEGE_CAPTURE.create_capture(
name => 'cont_capture',
type => DBMS_PRIVILEGE_CAPTURE.g_context,
condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') = ''DILLI'''
);
end;
/
4-
Create capture on role and context combined.
begin
DBMS_PRIVILEGE_CAPTURE.create_capture(
name => 'rl_cont_capture',
type => DBMS_PRIVILEGE_CAPTURE.g_role_and_context,
roles => role_name_list('RL_DILLI'),
condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') IN (''SCOTT'',''DILLI'')'
);
end;
/
5-
View captured lists.
We can view the list of the capture and its details using DBA_PRIV_CAPTURES data dictionary views.
desc DBA_PRIV_CAPTURES;
sql> select name,type,enabled,roles,context from dba_priv_captures;

6-
Enable the captures created earlier.
ENABLE_CAPTURE procedure is used to enable capture. Basically it will start capturing. Typically only one capture can be enabled at one time. Exception is that we can enable one database  level capture and another none database level at same time.

begin
DBMS_PRIVILEGE_CAPTURE.enable_capture('cont_capture');
DBMS_PRIVILEGE_CAPTURE.enable_capture('rl_cont_capture');
end;
/

8-
We can enable one db level capture and another none db level capture at once.
begin
DBMS_PRIVILEGE_CAPTURE.enable_capture('db_capture');
DBMS_PRIVILEGE_CAPTURE.enable_capture('rl_cont_capture');
end;
/

9-
Disable capture is used to disable capture. Basically it stop capture of the policy specified.

begin
DBMS_PRIVILEGE_CAPTURE.disable_capture('db_capture');
DBMS_PRIVILEGE_CAPTURE.disable_capture('rl_cont_capture');
end;
/
10-
Finally we need to use GENERATE_RESULTS procedure to generate report on basic of the
capture.
begin
DBMS_PRIVILEGE_CAPTURE.generate_result('rl_cont_capture');
DBMS_PRIVILEGE_CAPTURE.generate_result('db_capture');
end;
/
=====================================================================================
Following data dictionary views are available to get the details on the privilege capture result.

DBA_PRIV_CAPTURES
DBA_USED_OBJPRIVS
DBA_USED_OBJPRIVS_PATH
DBA_USED_PRIVS
DBA_USED_PUBPRIVS
DBA_USED_SYSPRIVS
DBA_USED_SYSPRIVS_PATH
DBA_USED_USERPRIVS
DBA_USED_USERPRIVS_PATH
DBA_UNUSED_OBJPRIVS
DBA_UNUSED_OBJPRIVS_PATH
DBA_UNUSED_PRIVS
DBA_UNUSED_SYSPRIVS
DBA_UNUSED_SYSPRIVS_PATH
DBA_UNUSED_USERPRIVS
DBA_UNUSED_USERPRIVS_PATH
-----------------------------------------------------------------------------------------------------
Accessing dba_used_privs to view all the privileges used during enable and disable capture.

col capture for a16
col USED_ROLE for a30
col SYS_PRIV for a30
set linesize 200
col username for a30

sql> select capture,username,used_role,sys_priv from dba_used_privs;

------------------------------------------------------------------------------------------------------
Accessing dba_unused_privs to view all the privileges not used during enable and disable capture.

col capture for a16
col rolename for a30
col SYS_PRIV for a30
set linesize 200
col username for a30

sql> select capture,username,rolename,sys_priv from dba_unused_privs;
===============================================================================================================
On basic on above data we can revoke unnecessary privileges granted to the user SCOTT.

DROP_CAPTURE is used to drop all the captures created.

begin
DBMS_PRIVILEGE_CAPTURE.drop_capture(name => 'db_capture');
DBMS_PRIVILEGE_CAPTURE.drop_capture(name => 'rl_capture');
DBMS_PRIVILEGE_CAPTURE.drop_capture(name => 'cont_capture');
DBMS_PRIVILEGE_CAPTURE.drop_capture(name => 'rl_cont_capture');
end;
/

-------------------------------------------------------------------------------------------------------------------

