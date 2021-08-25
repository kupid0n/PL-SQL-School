drop function portfolio_status_report;
/

create or replace function portfolio_status_report (
       date_report         date
       )
return table_report pipelined
as
       status_report table_report;
begin
  
select
        report_st
        (
           pc.num_dog                              --"№ Договора"
         , c.cl_name                               --"ФИО клиента"
         , pc.summa_dog                            --"Сумма договора"
         , pc.date_begin                           --"Дата начала договора"
         , pc.date_end                             --"Дата окончания договора"
         , cast(pc.summa_dog - 
                summ_pay_fact (pc.collect_fact, 'Погашение кредита', date_report) as numeric (10, 2))  --"Остаток ссудной задолженности на &date_report"
         , cast(summ_pay_plan (pc.collect_plan, 'Погашение процентов', null) - 
                summ_pay_fact (pc.collect_fact, 'Погашение процентов', date_report) as numeric (10, 2))--"Сумма предстоящих процентов к погашению"
         )
bulk collect into status_report
from client c
join pr_cred pc
     on c.id = pc.id_client
where pc.date_begin <= date_report
order by pc.id
;
DBMS_OUTPUT.PUT_LINE('Дата формирования отчета: '||sysdate);
DBMS_OUTPUT.PUT_LINE('Всего в кредитном портфеле на '||date_report||' клиентов: '||status_report.count);

for i in 1..status_report.count loop
pipe row (report_st
     ( status_report(i).num_dog
     , status_report(i).cl_name
     , status_report(i).summa_dog
     , status_report(i).date_begin
     , status_report(i).date_end
     , status_report(i).debt_loan
     , status_report(i).int_arr
     ));
end loop;
return;

end;
/