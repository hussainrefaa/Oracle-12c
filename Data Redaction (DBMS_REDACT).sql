-- Author: 	Hussain refaa
-- creation Date: 	2016
-- Last Updated: 	0000-00-00
-- Control Number:	Data Redaction (DBMS_REDACT) in Oracle Database 12c Release 1 (12.1)
-- Version: 	0.0
-- Phone : +4915775148443
-- Email: hus244@gmail.com

Oracle 10g gave us to ability to perform column masking to prevent
 sensitive data from being displayed by applications. In Oracle 12c,
 and back-ported to 11.2.0.4, the data redaction feature uses the DBMS_REDACT package to 
 define redaction policies that give a greater level of control and protection over sensitive data.
 ===============================================================================================================
1-Setup

We need to make sure the test user has access to the DBMS_REDACT package.

CONN sys@pdb1 AS SYSDBA
GRANT EXECUTE ON sys.dbms_redact TO test;
================================================================================================================
2-
The example code in this article requires the following test table.

CONN test/test@pdb1

DROP TABLE payment_details PURGE;

CREATE TABLE payment_details (
  id          NUMBER       NOT NULL,
  customer_id NUMBER       NOT NULL,
  card_no     NUMBER       NOT NULL,
  card_string VARCHAR2(19) NOT NULL,
  expiry_date DATE         NOT NULL,
  sec_code    NUMBER       NOT NULL,
  valid_date  DATE,
  CONSTRAINT payment_details_pk PRIMARY KEY (id)
);

INSERT INTO payment_details VALUES (1, 4000, 1234123412341234, '1234-1234-1234-1234', TRUNC(ADD_MONTHS(SYSDATE,12)), 123, NULL);
INSERT INTO payment_details VALUES (2, 4001, 2345234523452345, '2345-2345-2345-2345', TRUNC(ADD_MONTHS(SYSDATE,12)), 234, NULL);
INSERT INTO payment_details VALUES (3, 4002, 3456345634563456, '3456-3456-3456-3456', TRUNC(ADD_MONTHS(SYSDATE,12)), 345, NULL);
INSERT INTO payment_details VALUES (4, 4003, 4567456745674567, '4567-4567-4567-4567', TRUNC(ADD_MONTHS(SYSDATE,12)), 456, NULL);
INSERT INTO payment_details VALUES (5, 4004, 5678567856785678, '5678-5678-5678-5678', TRUNC(ADD_MONTHS(SYSDATE,12)), 567, NULL);
COMMIT;

ALTER SESSION SET nls_date_format='DD-MON-YYYY';

COLUMN card_no FORMAT 9999999999999999

SELECT *
FROM   payment_details
ORDER BY id;

        ID CUSTOMER_ID           CARD_NO CARD_STRING         EXPIRY_DATE   SEC_CODE VALID_DATE
---------- ----------- ----------------- ------------------- ----------- ---------- -----------
         1        4000  1234123412341234 1234-1234-1234-1234 28-OCT-2015        123
         2        4001  2345234523452345 2345-2345-2345-2345 28-OCT-2015        234
         3        4002  3456345634563456 3456-3456-3456-3456 28-OCT-2015        345
         4        4003  4567456745674567 4567-4567-4567-4567 28-OCT-2015        456
         5        4004  5678567856785678 5678-5678-5678-5678 28-OCT-2015        567

5 rows selected.
================================================================================================================================
3-
Add a new Policy
The following example is about as simple as it gets. 
A full redaction policy is placed on the CARD_NO column with an expression of "1=1".
CONN test/test@pdb1

BEGIN
  DBMS_REDACT.add_policy(
    object_schema => 'test',
    object_name   => 'payment_details',
    column_name   => 'card_no',
    policy_name   => 'redact_card_info',
    function_type => DBMS_REDACT.full,
    expression    => '1=1'
  );
END;
/

ALTER SESSION SET nls_date_format='DD-MON-YYYY';
COLUMN card_no FORMAT 9999999999999999

SELECT *
FROM   payment_details
ORDER BY id;

        ID CUSTOMER_ID           CARD_NO CARD_STRING         EXPIRY_DATE   SEC_CODE VALID_DATE
---------- ----------- ----------------- ------------------- ----------- ---------- -----------
         1        4000                 0 1234-1234-1234-1234 28-OCT-2015        123
         2        4001                 0 2345-2345-2345-2345 28-OCT-2015        234
         3        4002                 0 3456-3456-3456-3456 28-OCT-2015        345
         4        4003                 0 4567-4567-4567-4567 28-OCT-2015        456
         5        4004                 0 5678-5678-5678-5678 28-OCT-2015        567

=========================================================================================================
4-
Alter an Existing Policy
 CONN test/test@pdb1

BEGIN
  DBMS_REDACT.alter_policy (
    object_schema       => 'test',
    object_name         => 'payment_details',
    policy_name         => 'redact_card_info',
    action              => DBMS_REDACT.modify_column,
    column_name         => 'card_no',
    function_type       => DBMS_REDACT.partial,
    function_parameters => '1,1,12'
  );
END;
/
   
ALTER SESSION SET nls_date_format='DD-MON-YYYY';
COLUMN card_no FORMAT 9999999999999999

SELECT *
FROM   payment_details
ORDER BY id;

        ID CUSTOMER_ID           CARD_NO CARD_STRING         EXPIRY_DATE   SEC_CODE VALID_DATE
---------- ----------- ----------------- ------------------- ----------- ---------- -----------
         1        4000  1111111111111234 1234-1234-1234-1234 28-OCT-2015        123
         2        4001  1111111111112345 2345-2345-2345-2345 28-OCT-2015        234
         3        4002  1111111111113456 3456-3456-3456-3456 28-OCT-2015        345
         4        4003  1111111111114567 4567-4567-4567-4567 28-OCT-2015        456
         5        4004  1111111111115678 5678-5678-5678-5678 28-OCT-2015        567
=======================================================================================================================================
5-
We can add another column to the redaction policy to protect the string representation of the card number.
BEGIN
  DBMS_REDACT.alter_policy (
    object_schema       => 'test',
    object_name         => 'payment_details',
    policy_name         => 'redact_card_info',
    action              => DBMS_REDACT.add_column,
    column_name         => 'card_string',
    function_type       => DBMS_REDACT.partial,
    function_parameters => 'VVVVFVVVVFVVVVFVVVV,VVVV-VVVV-VVVV-VVVV,#,1,12'
  );
END;
/

ALTER SESSION SET nls_date_format='DD-MON-YYYY';
COLUMN card_no FORMAT 9999999999999999

SELECT *
FROM   payment_details
ORDER BY id;

        ID CUSTOMER_ID           CARD_NO CARD_STRING         EXPIRY_DATE   SEC_CODE VALID_DATE
---------- ----------- ----------------- ------------------- ----------- ---------- -----------
         1        4000  1111111111111234 ####-####-####-1234 28-OCT-2015        123
         2        4001  1111111111112345 ####-####-####-2345 28-OCT-2015        234
         3        4002  1111111111113456 ####-####-####-3456 28-OCT-2015        345
         4        4003  1111111111114567 ####-####-####-4567 28-OCT-2015        456
         5        4004  1111111111115678 ####-####-####-5678 28-OCT-2015        567
