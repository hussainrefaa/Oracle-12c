-- Author: 	Hussain refaa
-- creation Date: 	2016
-- Last Updated: 	0000-00-00
-- Control Number:	xxxx-xxxx-xxxx-xxxx
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: hus244@gmail.com
 -- Till Oracle 11g character data types like varchar2,
 -- nvarchar2 supports only 4000 bytes where as RAW supports only 2000 bytes.
 -- From Oracle 12c, Oracle has extended these datatypes length to 32Kbytes (32767 bytes).
 -- For the extended datatype support we need to configure it.
1- 
sqlplus / as sysdba
2- 
Shutdown database and startup on upgrade mode.
shutdown immediate
startup upgrade
3-
Modify system parameter max_string_size to extended.
alter system set max_string_size=extended;
4-
Execute the sql file that is located under rdbms/admin directory.
@?/rdbms/admin/utl32k.sql
@C:\app\OracleHomeUser1\product\12.1.0\dbhome_1\RDBMS\ADMIN\utl32k.sql
5-
After completing the execution of above sql command startup database in normal mode.
shutdown immediate
startup
6-
Enabling the extended datatype support on cdb Oracle 12c database. In my case cdb1 is cdb database with 3 pluggable database: pdb1, pdb2, pdb3.
On root container database execute the following commands
. oraenv
sqlplus / as sysdba
7-
Modify system parameter max_string_size to extended.
alter system set max_string_size=extended scope=spfile;
8-
Shutdown database and startup on upgrade mode.
shutdown immediate
startup upgrade
9-
Open all pluggable database on upgrade mode.
alter pluggable database all open upgrade;
10-
Login to the cdb, shutdown the database and start database in the normal mode.
sqlplus / as sysdba
shutdown immediate
startup;
alter pluggable database all open;
11-
Using extended datatypes
Create sequence seq_id;

Create table that use extended datatype.
Create table tbl_memo (
id number default seq_id.nextval,
notes varchar2(32767),
enabled char default 'Y',
primary key(id));
