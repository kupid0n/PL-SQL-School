drop function summ_pay_fact;
drop function summ_pay_plan;
drop function get_int_rate;

--Функция, возвращающая сумму платежей на заданную дату в зависимости от типа фактической операции 
create or replace function summ_pay_fact(
    id_fact_oper           in number   --id операции
  , type_operation         in varchar2 --тип операции
  , date_report            in date)    --дата для формирования отчета
    return number
is
    summ_pay number := 0;
begin
    select sum(f.f_summa) into summ_pay
    from fact_oper f
    where f.collection_id = id_fact_oper
      and f.type_oper = type_operation
      and f.f_date <= case
                      when date_report is not null 
                      then 
                           to_date(date_report) 
                      else 
                           (select max(f_date) 
                            from fact_oper 
                            where collection_id = id_fact_oper 
                            group by collection_id)
                      end
    group by f.collection_id;
             
    return summ_pay; 
exception
    when no_data_found then
    return summ_pay;
end;
/

--Функция, возвращающая сумму платежей на заданную дату в зависимости от типа планируемой операции 
create or replace function summ_pay_plan(
    id_plan_oper           in number   --id операции
  , type_operation         in varchar2 --тип операции
  , date_report            in date)    --дата для формирования отчета
    return number
is
    summ_pay number := 0;
begin
    select sum(p.p_summa) into summ_pay
    from plan_oper p
    where p.collection_id = id_plan_oper
      and p.type_oper = type_operation
      and p.p_date <= case
                      when date_report is not null 
                      then 
                           to_date(date_report) 
                      else 
                           (select max(p_date) 
                            from plan_oper 
                            where collection_id = id_plan_oper 
                            group by collection_id)
                      end
    group by p.collection_id;
             
    return summ_pay; 
exception
    when no_data_found then
    return summ_pay;
end;
/

--Получение размера процентной ставки на уже существующий кредит
create or replace function get_int_rate (
       number_dog in varchar2
       )
       return number
is
       int_rate number :=0;
begin
       select 
               sum_pr.summ*100*365/((pc.date_end-pc.date_begin)*pc.summa_dog) into int_rate
         from 
               pr_cred pc,
              (select 
                      po.collection_id
		    , sum(po.p_summa) as summ 
               from
                      plan_oper po
               where po.type_oper = 'Погашение процентов'
               group by po.collection_id) sum_pr
        where pc.collect_plan = sum_pr.collection_id
          and pc.num_dog = number_dog;
         
return int_rate;             
end;
/