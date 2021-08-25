SET ECHO OFF
SET VERIFY OFF
SET TRIMSPOOL ON
SET HEADING ON
SET LINESIZE 500
SET TRIMOUT ON
SET PAGESIZE 100
SET FEEDBACK OFF
SET TIMING OFF
SET VERIFY OFF
SET TERMOUT ON
SET COLSEP ";"
SET SERVEROUTPUT ON

ACCEPT date_report CHAR PROMPT 'Input date report: '

DEFINE spool_file = 'C:\report_storage\&date_report..csv'
SPOOL &spool_file

begin
	for i in (select * from portfolio_status_report(to_date('&date_report', 'dd.mm.yyyy'))
     ) loop
 
  DBMS_OUTPUT.PUT_LINE(
                   i.num_dog
           ||';'|| i.cl_name
           ||';'|| i.summa_dog
           ||';'|| i.date_begin
           ||';'|| i.date_end
           ||';'|| i.debt_loan
           ||';'|| i.int_arr
  );
end loop;
end;
/
SPOOL OFF

quit