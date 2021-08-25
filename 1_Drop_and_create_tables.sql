--Удаляем созданные ранее таблицы проекта
drop table fact_oper;
drop table plan_oper;
drop table pr_cred;
drop table client;

--Создаем таблицу "Клиенты"
create table client
       (
         ID           number
       , CL_NAME      varchar(100)
       , DATE_BIRTH   date
       );

--Создаем индекс
create unique index indx_client_id
       on client (id);

--Создаем ключи в таблице "Клиенты"
alter table client
      add
      ( 
        constraint client_id_pk 
                    primary key(id)
      );
      
--Создаем таблицу "Кредитные договоры"
create table pr_cred
       (
        ID           number
       ,NUM_DOG      varchar2(10)
       ,SUMMA_DOG    number
       ,DATE_BEGIN   date
       ,DATE_END     date
       ,ID_CLIENT    number
       ,COLLECT_PLAN number
       ,COLLECT_FACT number
       );
       
--Создаем индекс
create unique index indx_pr_cred_id
    on pr_cred (id);

--Создаем ключи в таблице "Кредитные договоры"
alter table pr_cred
    add
     ( constraint pr_cred_id_pk 
                   primary key (ID)
     , constraint pr_cred_id_cl_fk
                   foreign key (ID_CLIENT)
                           references client(ID)
     , constraint pr_cred_c_p_fk
                   unique (COLLECT_PLAN)
     , constraint pr_cred_c_f_fk
                   unique (COLLECT_FACT)                      
     );
     
--Создаем таблицу "Плановые операции"
create table plan_oper
       (
         COLLECTION_ID number
       , P_DATE        date
       , P_SUMMA       number
       , TYPE_OPER     varchar2(40)
       );

--Создаем индекс
create index indx_plan_oper_collection_id
    on plan_oper (collection_id);
create index indx_plan_oper_p_date
    on plan_oper (p_date);

--Создаем ключи в таблице "Плановые операции"
alter table plan_oper
    add
     (constraint plan_oper_col_id_fk
                   foreign key (collection_id)
                           references pr_cred(collect_plan)
     );
     
--Создаем таблицу "Фактические операции"
create table fact_oper
       (
         COLLECTION_ID number
       , F_DATE        date
       , F_SUMMA       number
       , TYPE_OPER     varchar2(40)
       );

--Создаем индекс
create index indx_fact_oper_collection_id
    on fact_oper (collection_id);
create index indx_plan_oper_f_date
    on fact_oper (f_date);

--Создаем ключи в таблице "Фактические операции"
alter table fact_oper
    add
     (constraint fact_oper_col_id_fk
                   foreign key (collection_id)
                           references pr_cred(collect_fact)
     );