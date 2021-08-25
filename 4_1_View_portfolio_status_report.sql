--Создание представления "Отчет о состоянии кредитного портфеля на заданную дату"
create or replace view portfolio_status_report as
    
    select  pc.num_dog "№ Договора"
          , c.cl_name "ФИО клиента"
          , pc.summa_dog "Сумма договора"
          , pc.date_begin "Дата начала договора"
          , pc.date_end "Дата окончания договора"
          , cast(pc.summa_dog - 
                  summ_pay_fact (pc.collect_fact, 'Погашение кредита', '&date_report') as numeric (10, 2)) "Остаток ссудной задолженности на &date_report"
          , cast(summ_pay_plan (pc.collect_plan, 'Погашение процентов', null) - 
                  summ_pay_fact (pc.collect_fact, 'Погашение процентов', '&date_report') as numeric (10, 2)) "Сумма предстоящих процентов к погашению"
          , to_char(sysdate, 'dd.mm.yy hh24:mi:ss') "Дата-время формирования отчета"
    from client c
    join pr_cred pc
    on c.id = pc.id_client
    where pc.date_begin <= '&date_report'
    order by pc.id;
/
            
select * from portfolio_status_report;