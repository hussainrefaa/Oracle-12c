-- Author: 	Hussain refaa
-- creation Date: 	2016
-- Last Updated: 	0000-00-00
-- Control Number:	xxxx-xxxx-xxxx-xxxx
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: hus244@gmail.com


Data Redaction is new security features on Oracle 12c that will help us hiding the data from unauthorised user.
 It has a lot of different options and control over the Oracle masking features that was introduced with oracle 10g.
 DBMS_REDACT is the package that is used for data redaction and has greater level of control and protection for the data.

1-
 Grant execute object level privilege on package dbms_redact to the user.
sqlplus / as sysdba
grant execute on dbms_redact to scott;
2-
Connect as user scott and describe table emp
conn scott
desc EMP;
3-
Execute select command to display empno and sal column.

select empno,sal from emp;
4-
Applying redaction policy without Filtering. i.e expression => '1=1'. It means this redaction policy will be applied to all the users and roles.
begin
 dbms_redact.add_policy(
 object_schema => 'SCOTT', 
 object_name => 'EMP', 
 column_name => 'SAL',
 policy_name => 'SCOTT_EMP_REDACT',
 function_type => DBMS_REDACT.full,
 expression => '1=1');
end;
/
5- select empno, sal from emp
Once again select EMPNO and SAL column from emp table and verify the change. All data on SAL column will be displayed as 0.

6-
We can view the default redact value for the numeric data and other data type. Use SQL command below to view.
desc redaction_values_for_type_full;
select NUMBER_VALUE from redaction_values_for_type_full;

7-

We can update the default redact value with the following command. In this case we have replaced default numeric reduction value from 0 to 6.

EXEC DBMS_REDACT.UPDATE_FULL_REDACTION_VALUES (number_val => 6);

Restart the database instance to get the change into effect.

8-

We can use following data dictionaries to view the details of redaction.
desc redaction_policies
desc redaction_columns

set linesize 250
col OBJECT_OWNER for a30
col OBJECT_NAME for a30
col POLICY_NAME format a32
col EXPRESSION format a20
col POLICY_DESCRIPTION for a20

select * from redaction_policies;

9-
col OBJECT_OWNER for a20
col OBJECT_NAME for a32
col COLUMN_NAME for a30
col FUNCTION_PARAMETERS for a20
col REGEXP_PATTERN for a20
col REGEXP_REPLACE_STRING for a20
col REGEXP_POSITION for a20
col REGEXP_OCCURRENCE for a25
col REGEXP_MATCH_PARAMETER for a20
col COLUMN_DESCRIPTION for a10

select * from redaction_columns;


10-

Modify an Existing policy.
We need to use ALTER_POLICY procedure to modify existing redaction policy. Instead of 
displaying salary as 6 we can hide some digits from the whole column. 
As per modification below SAL column value will be displayed as 9 for 2 digits from left.
 If someones salary is 2500 then it will be displayed as 9900. The first 2 digits will be converted to 9.

begin
dbms_redact.alter_policy(
object_schema => 'SCOTT',
object_name => 'EMP',
policy_name => 'SCOTT_EMP_REDACT',
action => DBMS_REDACT.modify_column,
column_name => 'SAL',
function_type => DBMS_REDACT.partial,
function_parameters => '9,1,2'
);
end;
/


11-
Execute following command to verify the changes.
select empno,sal from emp;

12-
We can add additional column to protect additional columns. 
We are adding hiredate column it will display month as JAN and day as 01 and year as 01(RR value)

begin
dbms_redact.alter_policy(
object_schema => 'SCOTT',
object_name => 'EMP',
policy_name => 'SCOTT_EMP_REDACT',
action => DBMS_REDACT.add_column,
column_name => 'hiredate',
function_type => DBMS_REDACT.partial,
function_parameters => 'm1d1y01'
);
end;
/

13-
Select columns to verify the change
select empno, sal,hiredate from emp;

14-
We can use expression to control redaction policy to certain user or roles.
begin
dbms_redact.alter_policy(
object_schema => 'SCOTT',
object_name => 'EMP',
policy_name => 'SCOTT_EMP_REDACT',
action => DBMS_REDACT.add_column,
column_name => 'JOB',
expression => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') != ''SCOTT'''
);
end;
/

15-
Execute following SQL statement as user SCOTT.
select empno, sal,hiredate,job  from emp;

16-
Execute same SQL statement as different user. In case below we executed following statement as user DILLI.
select empno, sal,hiredate,job  from scott.emp;

17-
Drop column from the redaction policy. 
begin
dbms_redact.alter_policy(
object_schema => 'SCOTT',
object_name => 'EMP',
policy_name => 'SCOTT_EMP_REDACT',
action => DBMS_REDACT.drop_column,
column_name => 'JOB'
);
end;
/

18-
Drop redaction policy using drop_policy procedure.
begin
dbms_redact.drop_policy(
object_schema => 'SCOTT',
object_name => 'EMP',
policy_name => 'SCOTT_EMP_REDACT');
end;
/

19-
