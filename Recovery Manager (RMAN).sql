-- Author: 	Hussain refaa
-- creation Date: 	2016
-- Last Updated: 	0000-00-00
-- Control Number:	Recovery Manager (RMAN) Table Point In Time Recovery (PITR) in Oracle Database 12c Release 1 (12.1)
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: hus244@gmail.com

Setup
====================================
CONN / AS SYSDBA

CREATE USER test IDENTIFIED BY test
  QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE TO test;

CONN test/test

CREATE TABLE t1 (id NUMBER);
INSERT INTO t1 VALUES (1);
COMMIT;
===========================================================
1- Check the current SCN.


CONN / AS SYSDBA

SELECT DBMS_FLASHBACK.get_system_change_number FROM dual;

GET_SYSTEM_CHANGE_NUMBER
------------------------
                 1853267
===================================================================================================
2- Add some more data since the SCN was checked.
CONN test/test

INSERT INTO t1 VALUES (2);
COMMIT;

SELECT * FROM t1;

        ID
----------
         1
         2
==================================================================================================
Exit from SQL*Plus and log in to RMAN as a root user with SYSDBA or SYSBACKUP privilege.

3- Table Point In Time Recovery (PITR)

Log in to RMAN as a user with SYSDBA or SYSBACKUP privilege.
$ rman target=/

RECOVER TABLE 'TEST'.'T1'
  UNTIL SCN 1853267
  AUXILIARY DESTINATION '/u01/aux'  
  REMAP TABLE 'TEST'.'T1':'T1_PREV';
 ===============================================================================================
 sqlplus test/test

SELECT * FROM t1_prev;

	ID
----------
	 1
================================================================================================
Table Point In Time Recovery (PITR) to Dump File

RECOVER TABLE 'TEST'.'T1'
  UNTIL SCN 1853267
  AUXILIARY DESTINATION '/u01/aux'
  DATAPUMP DESTINATION '/u01/export'
  DUMP FILE 'test_t1_prev.dmp'
  NOTABLEIMPORT;
  
  ==============================================================================================
  $ ls -al /u01/export
total 120
drwxr-xr-x. 2 oracle oinstall   4096 Dec 26 17:33 .
drwxrwxr-x. 5 oracle oinstall   4096 Dec 26 12:30 ..
-rw-r-----. 1 oracle oinstall 114688 Dec 26 17:34 test_t1_prev.dmp
$

