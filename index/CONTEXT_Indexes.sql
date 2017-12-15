-- Author: 	Hussain refaa
-- creation Date: 	10-12-2017
-- Last Updated: 	0000-00-00
-- Control Number:	xxxx-xxxx-xxxx-xxxx
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: refaa.hussain@gmail.com

Domain Indexes -- 1 : CONTEXT Indexes
A CONTEXT Index is one of a class of Domain Indexes.  It is used to build text-retrieval application.
Instead of a regular B-Tree index that captures the entire text of a VARCHAR2 column as a key, you can build an index that consists of "Tokens", words extracted from a long-ish text in the database column.  Searching the index is based on the CONTAINS operator.

Here is a quick demo in 11.2.0.4 :

First I setup a new user for this demo.  I could have used an existing user but my "HUSSAIN" user has DBA privileges and I want to demonstrate CONTEXT without such privileges.
Here the key grant is "CTXAPP" that is granted to the user.

SQL> create user ctxuser identified by ctxuser default tablespace users;

User created.

SQL> grant create session, create table to ctxuser;

Grant succeeded.

SQL> grant ctxapp to ctxuser;

Grant succeeded.

SQL> alter user ctxuser quota unlimited on users; 

User altered.

SQL> 



Next, this user creates the demonstration table and index :

SQL> connect ctxuser/ctxuser
Connected.
SQL> create table my_text_table 
  2  (id_column number primary key,
  3  my_text varchar2(2000));

Table created.

SQL> create index my_text_index
  2  on my_text_table(my_text)
  3  indextype is ctxsys.context;

Index created.

SQL> 
SQL> insert into my_text_table
  2  values (1,'This is a long piece of text written by HUSSAIN');

1 row created.

SQL> insert into my_text_table
  2  values (2,'Another long text to be captured by the index');

1 row created.

SQL> commit;

Commit complete.

SQL> 
SQL> -- this update to the index would be a regular background job
SQL> exec ctx_ddl.sync_index('MY_TEXT_INDEX');

PL/SQL procedure successfully completed.

SQL> 



Note the call to CTX_DDL.SYNC_INDEX.  Unlike a regular B-Tree index, the CONTEXT (Domain) Index is, by default, *not* updated in real-time when DML occurs against the base table.  (Hopefully, in a future post, I may demonstrate real-time updates to a CTXCAT index, different from a CONTEXT Index).
Only remember that this CONTEXT index is not automatically updated.  If new rows are added to the table, they are not visible through the index until a SYNC_INDEX operation is performed.  The SYNC_INDEX can be scheduled as a job with another call to DBMS_JOB or DBMS_SCHEDULER or itself as part of the CREATE INDEX statement.

Now, let me demonstrate usage of the Index with the CONTAINS operator.

SQL> select id_column as id,
  2  my_text
  3  from my_text_table
  4  where contains (my_text, 'written by HUSSAIN') > 0
  5  /

 ID
----------
MY_TEXT
--------------------------------------------------------------------------------
         1
This is a long piece of text written by HUSSAIN


SQL> select my_text
  2  from my_text_table
  3  where contains (my_text, 'Another long') > 0
  4  /

MY_TEXT
--------------------------------------------------------------------------------
Another long text to be captured by the index

SQL> 



Yes, the CONTAINS operator is a bit awkward.  It will be some time before you (or your developers) get used to the syntax !

Besides CTX_DDL, there are a number of other packages in the prebuilt CTXSYS schema that are available :
 CTX_CLS
 CTX_DDL
 CTX_DOC
 CTX_OUTPUT
 CTX_QUERY
 CTX_REPORT
 CTX_THES
 CTX_ULEXER

Since I have created a separate database user, I can also demonstrate the additional objects that are created when the INDEXTYPE IS CTXSYS.CONTEXT.

SQL> select object_type, object_name, to_char(created,'DD-MON-RR HH24:MI') Crtd
  2  from user_objects
  3  order by object_type, object_name
  4  /

OBJECT_TYPE         OBJECT_NAME                    CRTD
------------------- ------------------------------ ------------------------
INDEX               DR$MY_TEXT_INDEX$X             10-DEC-17 16:48
INDEX               DRC$MY_TEXT_INDEX$R            10-DEC-17 16:48
INDEX               MY_TEXT_INDEX                  10-DEC-17 16:48
INDEX               SYS_C0017472                   10-DEC-17 16:48
INDEX               SYS_IL0000045133C00006$$       10-DEC-17 16:48
INDEX               SYS_IL0000045138C00002$$       10-DEC-17 16:48
INDEX               SYS_IOT_TOP_45136              10-DEC-17 16:48
INDEX               SYS_IOT_TOP_45142              10-DEC-17 16:48
LOB                 SYS_LOB0000045133C00006$$      10-DEC-17 16:48
LOB                 SYS_LOB0000045138C00002$$      10-DEC-17 16:48
TABLE               DR$MY_TEXT_INDEX$I             10-DEC-17 16:48
TABLE               DR$MY_TEXT_INDEX$K             10-DEC-17 16:48
TABLE               DR$MY_TEXT_INDEX$N             10-DEC-17 16:48
TABLE               DR$MY_TEXT_INDEX$R             10-DEC-17 16:48
TABLE               MY_TEXT_TABLE                  10-DEC-17 16:48

15 rows selected.

SQL> 
SQL> select table_name, constraint_name, index_name
  2  from user_constraints
  3  where constraint_type = 'P'
  4  order by table_name, constraint_name
  5  /

TABLE_NAME                     CONSTRAINT_NAME
------------------------------ ------------------------------
INDEX_NAME
------------------------------
DR$MY_TEXT_INDEX$K             SYS_IOT_TOP_45136
SYS_IOT_TOP_45136

DR$MY_TEXT_INDEX$N             SYS_IOT_TOP_45142
SYS_IOT_TOP_45142

DR$MY_TEXT_INDEX$R             DRC$MY_TEXT_INDEX$R
DRC$MY_TEXT_INDEX$R

MY_TEXT_TABLE                  SYS_C0017472
SYS_C0017472


SQL> 



Yes, that is a large number of database objects besides MY_TEXT_TABLE and MY_TEXT_INDEX.  SYS_C0017472 is, of course, the Primary Key Index on MY_TEXT_TABLE (on the ID_COLUMN column).  The others are interesting.

The "Tokens" I mentioned in the first paragraph are, for the purpose of this table MY_TEXT_TABLE, in the DR$MY_TEXT_INDEX$I.

SQL> desc DR$MY_TEXT_INDEX$I
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 TOKEN_TEXT                                NOT NULL VARCHAR2(64)
 TOKEN_TYPE                                NOT NULL NUMBER(10)
 TOKEN_FIRST                               NOT NULL NUMBER(10)
 TOKEN_LAST                                NOT NULL NUMBER(10)
 TOKEN_COUNT                               NOT NULL NUMBER(10)
 TOKEN_INFO                                         BLOB

SQL> select token_text, token_count
  2  from dr$my_text_index$i
  3  /

TOKEN_TEXT                                                       TOKEN_COUNT
---------------------------------------------------------------- -----------
ANOTHER                                                                    1
CAPTURED                                                                   1
HUSSAIN                                                                     1
INDEX                                                                      1
LONG                                                                       2
PIECE                                                                      1
TEXT                                                                       2
WRITTEN                                                                    1

8 rows selected.

SQL> 
