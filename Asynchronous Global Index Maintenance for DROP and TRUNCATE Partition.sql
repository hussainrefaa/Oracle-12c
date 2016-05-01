-- Author: 	Hussain refaa
-- creation Date: 	2016
-- Last Updated: 	0000-00-00
-- Control Number:	xxxx-xxxx-xxxx-xxxx
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: hus244@gmail.com

Asynchronous Global Index Maintenance for DROP and TRUNCATE Partition in Oracle Database 12c Release 1
=============================================================================================================================
Setup

The following code creates and populates a partitioned table with global indexes.

-- Create a partitioned table with some global indexes.
DROP TABLE t1 PURGE;

CREATE TABLE t1
(id            NUMBER,
 description   VARCHAR2(50),
 created_date  DATE)
PARTITION BY RANGE (created_date)
(PARTITION part_2014 VALUES LESS THAN (TO_DATE('01/01/2015', 'DD/MM/YYYY')) TABLESPACE users,
 PARTITION part_2015 VALUES LESS THAN (TO_DATE('01/01/2016', 'DD/MM/YYYY')) TABLESPACE users);

ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY (id);

CREATE INDEX t1_idx ON t1 (created_date);


-- Populate it so segments are created.
INSERT /*+ APPEND */ INTO t1
SELECT level,
       'Description for ' || level,
       CASE
         WHEN MOD(level,2) = 0 THEN TO_DATE('01/07/2014', 'DD/MM/YYYY')
         ELSE TO_DATE('01/07/2015', 'DD/MM/YYYY')
       END
FROM   dual
CONNECT BY level <= 10000;
COMMIT;

EXEC DBMS_STATS.gather_table_stats(USER, 't1');


-- Check the indexes.
COLUMN table_name FORMAT A20
COLUMN index_name FORMAT A20

SElECT table_name,
       index_name,
       status
FROM   user_indexes
ORDER BY 1,2;

TABLE_NAME           INDEX_NAME           STATUS
-------------------- -------------------- --------
T1                   T1_IDX               VALID
T1                   T1_PK                VALID

============================================================================================
Asynchronous Global Index Maintenance

-- Truncate a partition.
ALTER TABLE t1 TRUNCATE PARTITION part_2014 DROP STORAGE UPDATE INDEXES;
-- ALTER TABLE t1 DROP PARTITION part_2014 UPDATE INDEXES;


-- Check the status of the indexes.
SElECT table_name,
       index_name,
       status
FROM   user_indexes
ORDER BY 1,2;

TABLE_NAME           INDEX_NAME           STATUS
-------------------- -------------------- --------
T1                   T1_IDX               VALID
T1                   T1_PK                VALID


The new ORPHANED_ENTRIES column in the USER_INDEXES view shows the index maintenance has not been done yet.

-- Check if index maintenance is needed.
SELECT index_name,
       orphaned_entries
FROM   user_indexes
ORDER BY 1;

INDEX_NAME           ORP
-------------------- ---
T1_IDX               YES
T1_PK                YES

If we manually trigger the index maintenance, we can see the change reflected in the ORPHANED_ENTRIES column.

	-- Manually trigger the index maintenance.
EXEC DBMS_PART.cleanup_gidx(USER, 't1');


-- Check if index maintenance is needed.
SELECT index_name,
       orphaned_entries
FROM   user_indexes
ORDER BY 1;

INDEX_NAME           ORP
-------------------- ---
T1_IDX               NO
T1_PK                NO