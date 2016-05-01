-- Author: 	Hussain refaa
-- creation Date: 	2016
-- Last Updated: 	0000-00-00
-- Control Number:	xxxx-xxxx-xxxx-xxxx
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: hus244@gmail.com
---------------------------------------------------------------------------------------------------
Connecting to a Container Database (CDB)

Connecting to the root of a container database is the same as that of any previous database instance. 
On the database server you can use OS Authentication.

$ export ORACLE_SID=cdb1
$ sqlplus / as sysdba

SQL*Plus: Release 12.1.0.2.0 Production on Mon Aug 26 15:29:49 2013

Copyright (c) 1982, 2014, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Partitioning, OLAP, Advanced Analytics and Real Application Testing options

SQL>
========================================================================================================================

You can connect to other common users in similar way.
SQL> CONN system/password
Connected.
SQL>
=========================================================================================================================
The V$SERVICES views can be used to display available services from the database.
COLUMN name FORMAT A30

SELECT name, pdb
FROM   v$services
ORDER BY name;

NAME			       PDB
------------------------------ ------------------------------
SYS$BACKGROUND                 CDB$ROOT
SYS$USERS                      CDB$ROOT
cdb1                           CDB$ROOT
cdb1XDB                        CDB$ROOT
pdb1                           PDB1
pdb2                           PDB2

6 rows selected.

SQL>
===========================================================================================================================
Connections using services are unchanged from previous versions.

SQL> -- EZCONNECT
SQL> CONN system/password@//localhost:1521/cdb1
Connected.
SQL>

SQL> -- tnsnames.ora
SQL> CONN system/password@cdb1
Connected.
SQL>
==========================================================================================================================
The connection using a TNS alias requires an entry in the "$ORACLE_HOME/network/admin/tnsnames.ora" file,
 such as the one shown below.

CDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ol6-121.localdomain)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cdb1)
    )
  )
=============================================================================================================================
Displaying the Current Container

The SHOW CON_NAME and SHOW CON_ID commands in SQL*Plus display the current container name and ID respectively.

SQL> SHOW CON_NAME

CON_NAME
------------------------------
CDB$ROOT
SQL>

SQL> SHOW CON_ID

CON_ID
------------------------------
1
SQL>
=============================================================================================================================
They can also be retrieved using the SYS_CONTEXT function.

SELECT SYS_CONTEXT('USERENV', 'CON_NAME')
FROM   dual;

SYS_CONTEXT('USERENV','CON_NAME')
--------------------------------------------------------------------------------
CDB$ROOT

SQL>


SELECT SYS_CONTEXT('USERENV', 'CON_ID')
FROM   dual;

SYS_CONTEXT('USERENV','CON_ID')
--------------------------------------------------------------------------------
1

SQL>
===================================================================================================================================
Switching Between Containers

When logged in to the CDB as an appropriately privileged user, 
the ALTER SESSION command can be used to switch between containers within the container database.

SQL> ALTER SESSION SET container = pdb1;

Session altered.

SQL> SHOW CON_NAME

CON_NAME
------------------------------
PDB1
SQL> ALTER SESSION SET container = cdb$root;

Session altered.

SQL> SHOW CON_NAME

CON_NAME
------------------------------
CDB$ROOT
SQL>
======================================================================================================================================
Connecting to a Pluggable Database (PDB)

Direct connections to pluggable databases must be made using a service. 
Each pluggable database automatically registers a service with the listener. 
This is how any application will connect to a pluggable database, 
as well as administrative connections.

SQL> -- EZCONNECT
SQL> CONN system/password@//localhost:1521/pdb1
Connected.
SQL>

SQL> -- tnsnames.ora
SQL> CONN system/password@pdb1
Connected.
SQL>
====================================================================================================================================
The connection using a TNS alias requires an entry in the "$ORACLE_HOME/network/admin/tnsnames.ora" file, 
such as the one shown below.

PDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ol6-121.localdomain)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = pdb1)
    )
  )
=====================================================================================================================================
PDB users with the SYSDBA, SYSOPER, SYSBACKUP, or SYSDG privilege can connect to a closed PDB. 
All other PDB users can only connect when the PDB is open. As with regular databases, 
the PDB users require the CONNECT SESSION privilege to enable connections.

JDBC Connections to PDBs

It has already been mentioned that you must connect to a PDB using a service. 
This means that by default many JDBC connect strings will be broken. 
Valid JDBC connect strings for Oracle use the following format.

# Syntax
jdbc:oracle:thin:@[HOST][:PORT]:SID
jdbc:oracle:thin:@[HOST][:PORT]/SERVICE

# Example
jdbc:oracle:thin:@ol6-121:1521:pdb1
jdbc:oracle:thin:@ol6-121:1521/pdb1
======================================================================================================================================
When attempting to connect to a PDB using the SID format, you will receive the following error.

ORA-12505, TNS:listener does not currently know of SID given in connect descriptor
Ideally, you would correct the connect string to use services instead of SIDs, 
but if that is a problem the USE_SID_AS_SERVICE_listener_name listener parameter can be used.

Edit the "$ORACLE_HOME/network/admin/listener.ora" file, adding the following entry, with the "listener" name matching that used by your listener.

USE_SID_AS_SERVICE_listener=on
Reload or restart the listener.

$ lsnrctl reload
Now both of the following connection attempts will be successful as any SIDs will be treated as services.

jdbc:oracle:thin:@ol6-121:1521:pdb1
jdbc:oracle:thin:@ol6-121:1521/pdb1