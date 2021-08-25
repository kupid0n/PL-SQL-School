drop procedure payment_received;

--Процедура получения очередной оплаты,
--корректирующая график платежей при досрочном погашении
create or replace procedure payment_received (
       number_dog      in varchar2
     , payment_sum     in number
    -- , payment_purpose in boolean
     )

as
     int_rate            number; --процентная ставка клиента                     
     date_prev_pay       date;   --дата предыдущего фактического платежа          
     date_next_pay       date;   --дата следующего планируемого платежа          
     count_day_bet       number; --количество дней между платежами               
     plan_col_id         number; --id планируемой операции                      
     fact_col_id         number; --id фактической операции                       
     per_left            number; --количество оставшихся периодов оплаты         
     summa_dog           number; --сумма кредита по договору                    
     new_od              number; --новый долг по кредиту (тело)                  
     old_od              number; --старый долг по кредиту (тело)                  
     payment_body        number; --часть ежемесячного платежа, идущего на погашение тела кредита
     payment_proc        number; --часть ежемесячного платежа, идущего на погашение процентов по кредиту 
     new_annuit          number; --новый аннуитентный платеж, после внесения переплаты
     mon_proc_pay        number; --ежемесячные выплаты процентов, в зависимости от суммы долга
     mon_body_pay        number; --ежемясячные выплаты тела кредита
     total_debt          number; --общая задолженность
begin
     int_rate := get_int_rate (number_dog);
     
     select pc.collect_plan             
          , pc.collect_fact             
          , pc.summa_dog                
          , max(fo.f_date)
          , pc.summa_dog - sum(case when fo.type_oper = 'Погашение кредита'  then fo.f_summa else 0 end) 
          into plan_col_id, fact_col_id, summa_dog, date_prev_pay, old_od
     from pr_cred pc
     join fact_oper fo
          on pc.collect_fact = fo.collection_id
     where pc.num_dog =  number_dog   
     group by  pc.num_dog
             , pc.collect_plan
             , pc.collect_fact
             , pc.summa_dog;
        
     select 
             min(po.p_date)               
           , count(distinct po.p_date)   
           , sum(po.p_summa)
           into date_next_pay, per_left, total_debt
     from 
              plan_oper po
     where po.collection_id = plan_col_id
       and po.p_date > date_prev_pay
     group by collection_id;    
     
    if payment_sum > total_debt
       then
         GOTO too_much;
       else
         GOTO norm_pay;
     end if;     

<<too_much>>
     insert into fact_oper
     select fact_col_id
          , po.p_date
          , po.p_summa
          , po.type_oper 
     from plan_oper po
     where po.collection_id = plan_col_id
       and po.p_date > date_prev_pay;
     commit;
     dbms_output.put_line ('Слишком большой платеж, заберите '||(payment_sum - total_debt)||' р. назад на мороженое.');
     return;

<<norm_pay>>
     count_day_bet := date_next_pay - date_prev_pay;
     mon_proc_pay  := old_od * count_day_bet * int_rate / (365*100);
     payment_body  := payment_sum - mon_proc_pay;
     new_od        := old_od - payment_body;
     new_annuit    := new_od*(int_rate/100/12+int_rate/100/12/(power(1+int_rate/100/12,per_left-1)-1));
     
     insert into fact_oper
     values (fact_col_id, date_next_pay, round(mon_proc_pay, 2), 'Погашение процентов');
     
     insert into fact_oper
     values (fact_col_id, date_next_pay, round(payment_body, 2), 'Погашение кредита');
     commit;
     
     for i in 1..per_left loop
       
         if i = per_left
            then mon_body_pay := payment_body+new_od;
            else mon_body_pay := payment_body; 
         end if;
         
         update plan_oper
                set p_summa = round(mon_proc_pay, 2)
                where collection_id = plan_col_id
                  and p_date        = date_next_pay
                  and type_oper     = 'Погашение процентов';
         
         update plan_oper
                set p_summa = round(mon_body_pay, 2)
                where collection_id = plan_col_id
                  and p_date        = date_next_pay
                  and type_oper     = 'Погашение кредита';
         commit;
                  
         date_prev_pay := date_next_pay;
         select min(po.p_date) into date_next_pay
                from plan_oper po
                where po.p_date > date_next_pay
                  and po.collection_id = plan_col_id;
         
         count_day_bet := date_next_pay - date_prev_pay;
         mon_proc_pay  := new_od * count_day_bet * int_rate / (100*365);        
         payment_body  := new_annuit - mon_proc_pay;
         new_od        := new_od - payment_body;
         
     end loop;  

exception
    when no_data_found then
    dbms_output.put_line('Все платежи по этому кредиту внесены.');
end;
/
