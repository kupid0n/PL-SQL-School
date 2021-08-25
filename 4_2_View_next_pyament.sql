--Создание представления "Отчет о предостоящих платежах"

create or replace view upcoming_payments as
select cl.cl_name
     , pc.num_dog
     , po.p_date
     , sum(po.p_summa)
from plan_oper po
   , pr_cred pc
   , client cl
   , (select po.collection_id, min(po.p_date) popd
        from plan_oper po 
       where p_date not in 
                    (select distinct f_date 
                       from fact_oper)
                      group by po.collection_id) pd
where po.collection_id = pd.collection_id
  and po.p_date = pd.popd
  and pc.collect_plan = po.collection_id
  and pc.id_client = cl.id
group by cl.cl_name
       , pc.num_dog
       , po.p_date
order by cl.cl_name;
/