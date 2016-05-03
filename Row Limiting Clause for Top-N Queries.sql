-- Author: 	Hussain refaa
-- creation Date: 	2016
-- Last Updated: 	0000-00-00
-- Control Number:	Row Limiting Clause for Top-N Queries in Oracle Database 12c Release 1 (12.1)
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: hus244@gmail.com

A Top-N query is used to retrieve the top or bottom N rows from an ordered set.
Combining two Top-N queries gives you the ability to page through an ordered set. 
This concept is not a new one. In fact, Oracle already provides multiple ways to perform Top-N queries,
Like MySQL uses a LIMIT clause to page through an ordered result set.	
================================================================================================================================
1-
SELECT * 
FROM   my_table 
ORDER BY column_1
LIMIT 0 , 40

Oracle 12c has introduced the row limiting clause to simplify Top-N queries and paging through ordered result sets.
Setup

To be consistent, we will use the same example table used in the Top-N Queries article.

Create and populate a test table.

DROP TABLE rownum_order_test;

CREATE TABLE rownum_order_test (
  val  NUMBER
);

INSERT ALL
  INTO rownum_order_test
  INTO rownum_order_test
SELECT level
FROM   dual
CONNECT BY level <= 10;

COMMIT;
===================================================================================================================================
The following query shows we have 20 rows with 10 distinct values.
SELECT val
FROM   rownum_order_test
ORDER BY val;

       VAL
----------
         1
         1
         2
         2
         3
         3
         4
         4
         5
         5
         6

       VAL
----------
         6
         7
         7
         8
         8
         9
         9
        10
        10

20 rows selected.
=========================================================================================================
Top-N Queries
SELECT val
FROM   rownum_order_test
ORDER BY val DESC
FETCH FIRST 5 ROWS ONLY;

       VAL
----------
        10
        10
         9
         9
         8

5 rows selected.
=========================================================================================================
Paging Through Data

SELECT val
FROM   (SELECT val, rownum AS rnum
        FROM   (SELECT val
                FROM   rownum_order_test
                ORDER BY val)
        WHERE rownum <= 8)
WHERE  rnum >= 5;
========================================================================================================
With the row limiting clause we can achieve the same result using the following query.

SELECT val
FROM   rownum_order_test
ORDER BY val
OFFSET 4 ROWS FETCH NEXT 4 ROWS ONLY;
==========================================================================================================
The starting point for the FETCH is OFFSET+1.

The OFFSET is always based on a number of rows, but this can be combined with a FETCH using a PERCENT.

SELECT val
FROM   rownum_order_test
ORDER BY val
OFFSET 4 ROWS FETCH NEXT 20 PERCENT ROWS ONLY;
==========================================================================================================
Not surprisingly, the offset, rowcount and percent can, and probably should, be bind variables.

VARIABLE v_offset NUMBER;
VARIABLE v_next NUMBER;

BEGIN
  :v_offset := 4;
  :v_next   := 4;
END;
/

SELECT val
FROM   rownum_order_test
ORDER BY val
OFFSET :v_offset ROWS FETCH NEXT :v_next ROWS ONLY;
============================================================================================================
