drop type table_report;
/
drop type report_st;
/
-- Создаем типы данных для формирования отчета из функции
create or replace type report_st as object ( 
       num_dog             varchar2(10)
     , cl_name             varchar2(100)
     , summa_dog           number
     , date_begin          date 
     , date_end            date
     , debt_loan           number
     , int_arr             number
     );
/
create or replace type table_report as table of report_st;
/