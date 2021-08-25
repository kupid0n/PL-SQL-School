create or replace package get_report as
     type report_st is record
     ( 
       num_dog             varchar2(10)
     , cl_name             varchar2(100)
     , summa_dog           number
     , date_begin          date 
     , date_end            date
     , debt_loan           number
     , int_arr             number
     );

    type table_report is table of report_st;
    
    function portfolio_status_report (date_report in date) 
      return table_report;
    
    function summ_pay_plan 
      (id_plan_oper           in number
     , type_operation         in varchar2
     , date_report            in date)
     return number;
    
    function summ_pay_fact 
      (id_plan_oper           in number
     , type_operation         in varchar2
     , date_report            in date)
     return number;
    
end get_report;
/