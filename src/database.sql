------------------------------------------------------------------------------------------------------
-- 3 task

drop schema if exists project cascade;
create schema project;

set search_path = project;

drop table if exists membership cascade;
create table membership(
    membership_id   serial,
    description     text check ( description > '' ),
    days_amt        int check ( days_amt in (30, 60, 90) ),
    visits_amt      int check ( visits_amt in (8, 16, 30) or (visits_amt = 999 and is_unlimited) ),
    is_unlimited    boolean default false,
    membership_cost numeric(6, 2) check ( membership_cost > 2999 ),

    primary key (membership_id)
);

drop table if exists client cascade;
create table client(
    client_id     serial,
    first_name    varchar(255) not null,
    last_name     varchar(255) not null,
    email         varchar(255) not null,
    birth_date    date not null,
    phone_number  text check (phone_number ~ '^(\+7|7|8)?[\s\-]?\(?[489][0-9]{2}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$'),
    valid_from    date default current_date,
    valid_to      date check( valid_from <= valid_to ),

    primary key (client_id, valid_from)
);

drop table if exists sales cascade;
create table sales(
    client_id     int not null,
    membership_id int not null,
    start_date    date default current_date,
    end_date      date check (start_date <= end_date),

    primary key (client_id, membership_id),
    foreign key (membership_id) references membership(membership_id) on delete cascade
);

drop table if exists training cascade;
create table training(
    training_id    serial primary key,
    training_name  varchar(255) not null,
    duration       int check ( duration between 45 and 80 ),
    training_level varchar(255) default 'beginner'
);

drop table if exists membership_x_training cascade;
create table membership_x_training(
    membership_id int not null,
    training_id   int not null,

    foreign key (membership_id) references membership(membership_id) on delete cascade,
    foreign key (training_id) references training(training_id) on delete cascade,
    primary key (membership_id, training_id)
);

drop table if exists trainer cascade;
create table trainer(
    trainer_id   serial,
    first_name   varchar(255) not null,
    last_name    varchar(255) not null,
    phone_number text check (phone_number ~ '^(\+7|7|8)?[\s\-]?\(?[489][0-9]{2}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$'),

    primary key (trainer_id)
);

drop table if exists trainer_x_training cascade;
create table trainer_x_training(
    trainer_id  int not null,
    training_id int not null,

    foreign key (trainer_id) references trainer(trainer_id) on delete cascade,
    foreign key (training_id) references training(training_id) on delete cascade,
    primary key (training_id, trainer_id)
);

drop table if exists registration cascade;
create table registration(
    registration_id   serial not null,
    trainer_id        int not null,
    training_id       int not null,
    membership_id     int not null,
    client_id         int not null,
    registration_dttm timestamp not null,

    primary key (registration_id),
    foreign key (trainer_id, training_id) references trainer_x_training(trainer_id, training_id) on delete cascade,
    foreign key (membership_id, training_id) references membership_x_training(membership_id, training_id) on delete cascade,
    foreign key (client_id, membership_id) references sales(client_id, membership_id) on delete cascade
);

------------------------------------------------------------------------------------------------------
-- 4 task

insert into membership(membership_id, description, days_amt, visits_amt, is_unlimited, membership_cost) values
    (1, 'gym', 90, 30, false, 7500),
    (2, 'gym', 60, 999, true, 6000),
    (3, 'box', 30, 999, true, 3000),
    (4, 'box', 90, 30, false, 9000),
    (5, 'freestyle wrestling', 60, 16, false, 5500),
    (6, 'freestyle wrestling', 30, 999, true, 3000);

insert into client(client_id, first_name, last_name, email, birth_date, phone_number, valid_from, valid_to) values
    (1, 'alexandr', 'bondarenko', 'rgrgw@mail.ru', '2001-11-21', '+7-964-345-8941', '2021-02-10', '2021-06-15'),
    (2, 'igor', 'lyadov', 'iglya@hse.ru', '2003-02-24', '+7-975-322-6127', '2021-02-14', '5999-01-01'),
    (3, 'vladimir', 'smirnov', 'timakkaq@mango.com', '1996-04-13', '+7-951-737-8283', '2021-03-17', '2021-08-15'),
    (4, 'nikolay', 'bobrov', '@zylker.com', '1998-07-29', '+7-987-951-8795', '2021-05-02', '5999-01-01'),
    (5, 'fedor', 'golovlev', 'cliffchiboston@convoy.com', '2004-01-01', '+7-984-594-8941', '2021-09-15', '5999-01-01'),
    (1, 'alexandr', 'bondarenko', 'party@college.edu', '2001-11-21', '+7-964-338-9335', '2021-06-15', '5999-01-01'),
    (3, 'vladimir', 'smirnov', 'ironman@timgarage.com', '1996-04-13', '+7-999-777-3071', '2021-08-15', '5999-01-01'),
    (6, 'ivan', 'gurnov', 'jamesbond@xyzdetectiveagency.com', '2002-06-04', '+7-921-571-7960', '2021-09-17', '5999-01-01');

insert into sales(client_id, membership_id, start_date, end_date) values
    (1, 1, '2021-02-15', '2021-02-15'::date + interval '90 days'),
    (1, 3, '2021-06-25', '2021-06-25'::date + interval '30 days'),
    (2, 2, '2021-02-16', '2021-02-16'::date + interval '60 days'),
    (3, 4, '2021-03-20', '2021-03-20'::date + interval '90 days'),
    (3, 1, '2021-08-17', '2021-08-17'::date + interval '90 days'),
    (4, 3, '2021-05-10', '2021-05-10'::date + interval '30 days'),
    (5, 5, '2021-09-15', '2021-09-15'::date + interval '60 days'),
    (6, 2, '2021-09-18', '2021-09-18'::date + interval '60 days');

insert into training(training_id, training_name, duration, training_level) values
    (1, 'box', 60, 'beginner'),
    (2, 'freestyle wrestling', 60, 'beginner'),
    (3, 'leg training', 45, 'medium'),
    (4, 'arm training', 45, 'beginner'),
    (5, 'yoga', 45, 'beginner'),
    (6, 'yoga', 80, 'medium');

insert into membership_x_training(membership_id, training_id) values
    (1, 3), (1, 4), (1, 5), (1, 6),
    (2, 3), (2, 4), (2, 5), (2, 6),
    (3, 1),
    (4, 1),
    (5, 2),
    (6, 2);

insert into trainer(trainer_id, first_name, last_name, phone_number) values
    (1, 'ivan', 'pirogov', '+7-996-975-1353'),
    (2, 'igor', 'milshin', '+7-931-452-2213'),
    (3, 'alexandr', 'rogachev', '+7-943-769-4289'),
    (4, 'anastasiya', 'gorbacheva', '+7-981-348-3186'),
    (5, 'temirlan', 'zverev', '+7-931-563-9348'),
    (6, 'roman', 'dushin', '+7-943-739-4472');

insert into trainer_x_training(trainer_id, training_id) values
    (1, 1), (1, 2),
    (2, 1),
    (3, 3), (3, 4),
    (4, 5), (4, 6),
    (5, 1), (5, 2),
    (6, 1), (6, 5), (6, 6);

insert into registration(trainer_id, training_id, membership_id, client_id, registration_dttm) values
    (3, 3, 1, 1, '2021-02-16 10:00'),
    (3, 3, 2, 2, '2021-02-16 10:00'),
    (2, 1, 3, 1, '2021-02-19 9:00'),
    (3, 4, 2, 2, '2021-02-19 9:00'),
    (6, 1, 4, 3, '2021-04-16 12:00'),
    (4, 6, 2, 2, '2021-04-16 12:00'),
    (5, 1, 3, 4, '2021-10-16 21:00'),
    (5, 2, 5, 5, '2021-10-16 21:00'),
    (6, 5, 2, 6, '2021-10-16 21:00');

------------------------------------------------------------------------------------------------------
-- 5 task

-- выберем таблицы trainer и  registration и сделаем для них crud-запросы.

-- trainer:
insert into trainer(trainer_id, first_name, last_name, phone_number) values (7, 'alexey', 'makov', '+7-991-093-9001');
select first_name, last_name from trainer;
update trainer set phone_number = '8-994-001-4012' where trainer_id = 7;
delete from trainer where trainer_id = 7;

-- client:
insert into registration(trainer_id, training_id, membership_id, client_id, registration_dttm) values
    (5, 1, 3, 4, '2022-10-16 19:00');

-- выводим всех клиетов, их тренировки и уровень. вывод в отсортированном (asc) по имени порядке
select c.first_name, c.last_name, t.training_name, t.training_level
from client c
inner join sales s on s.client_id = c.client_id
inner join membership_x_training mt on s.membership_id = mt.membership_id
inner join training t on t.training_id = mt.training_id
where c.valid_to = '5999-01-01'
order by c.first_name;

update registration set registration_dttm = '2021-12-16 10:00' where registration_id = 8;
delete from registration where registration_id = 10;

------------------------------------------------------------------------------------------------------
-- 6 task

-- 1
-- запрос выводит всех клиентов в убывающем лексикографически по фамилии порядке, которые занимаются боксом.
-- формат вывода: id клиента, имя клиента, фамилия клиента

select c.client_id, c.first_name, c.last_name
from client c
inner join sales s on s.client_id = c.client_id
inner join membership_x_training mt on mt.membership_id = s.membership_id
inner join training t on mt.training_id = t.training_id
where training_name = 'box'
group by c.client_id, c.first_name, c.last_name
order by c.first_name desc;

-- 2

-- запрос выводит наростающим итогом сумму покупок. сначала сортируем по абонементу, потом по id клиента.

-- формат вывода: id абонемента, его описание, кол-во дней, кол-во посещений, id клиента, сумма, следующая сумма и предыдущая сумма.

select
    membership_id, client_id, first_name, last_name, summa,
    lead(summa) over() next_summa,
    lag(summa) over() prev_summa
from
    (select
        m.membership_id, c.client_id, c.first_name, c.last_name,
        sum(m.membership_cost) over(order by m.membership_id, c.client_id) as summa
    from client c
    inner join sales s on c.client_id = s.client_id and c.valid_to = '5999.01.01'
    inner join membership m on m.membership_id = s.membership_id
    group by m.membership_id, c.client_id, c.first_name, c.last_name) s;

-- 3

-- запрос выводит тренеров и тренировки, которые они когда либо проводили(ориентируемся на таблицу с записями).
-- сортировка по id тренера, при равенстве - по id тренировки (asc).
-- вывод: id тренера, id тренировки

select r.trainer_id, r.training_id
from registration r
where r.registration_dttm < now()
order by trainer_id, training_id;

-- 4

-- запрос выводит все клиентов, которые посещали/посетят тернировки только уровня "beginner".
-- сортировка по id клиента (desc).
-- вывод: id клиента

select distinct c.client_id
from client c

except

select c.client_id
from registration r
inner join client c on r.client_id = c.client_id
inner join training t on r.training_id = t.training_id
where t.training_level != 'beginner'
order by client_id desc;

-- 5

-- запрос выводит для каждого тренера кол-во тренировок, которые он провел, а также разницу с максимальным кол-вом тренировок,
-- проведенных одним тренером. отсортированно по убыванию кол-ва тренировок, при равенстве по id тренера.
-- вывод: first_name тренера, last_name тренера, кол-во тренировок, разница(diff)

select first_name, last_name, count,
       first_value(count) over () - count as diff
from
    (select t.first_name, t.last_name,
        count(registration_id) as count
    from trainer t
    left join registration r on t.trainer_id = r.trainer_id
    group by r.trainer_id, t.first_name, t.last_name
    order by count(registration_id) desc, r.trainer_id) c;


-- 6
-- запрос выводит среднюю стоимость абонементов, которые совпадают по описанию(по сути предоставляют одни и те же тренировки)
-- также выводится разница между текущим и предыдущим значениями. сортируется по возрастанию avg.
-- вывод: description абонемента, средняя стоимость за предоставляемые тренировки, разница

select description, avg,
       coalesce(abs(avg - lag(avg) over ()), 0) as diff
from
    (select
         description,
         avg(m.membership_cost) as avg
    from membership m
    group by m.description) s
group by description, avg
order by avg;

-- 7

-- запрос выводит кол-во клиентов, которые посещали/посещают "beginner" тренировки. а также кол-во клиентов,
-- которые на "medium" тренировках.
-- вывод: уровень тренировки, кол-во клиентов

select t.training_level, count(c.client_id)
from registration r
inner join client c on r.client_id = c.client_id and c.valid_to = '5999.01.01'
inner join training t on r.training_id = t.training_id
group by t.training_level
order by count(c.client_id) desc;

-- 8
-- запрос выводит для каждого клиента кол-во тренировок, которые он посетил/посетит
-- вывод: id клиента, first_name клинта, last_name клиента, кол-во тренирово.

select c.client_id, c.first_name, c.last_name, count(registration_id)
from client c
left join registration r on c.client_id = r.client_id and c.valid_to = '5999.01.01'
group by c.client_id, c.first_name, c.last_name
order by count(registration_id) desc;

------------------------------------------------------------------------------------------------------
-- 7 task

drop schema if exists views cascade;
create schema views;

-- 1 table

create or replace view views.membership_view as
  select description, days_amt, visits_amt, is_unlimited, membership_cost
from membership;

-- 2 table

create or replace view views.client_view as
  select
    regexp_replace(first_name, '.*', '****') as first_name,
    regexp_replace(last_name, '.*', '****') as last_name,
    regexp_replace(email, '(.*?)(@.*)', '****\2') as email,
    regexp_replace(birth_date::varchar, '.*', '****-**-**') as birth_date,
    regexp_replace(phone_number, '^(\+7|7|8)?.*', '\1-***-***-****') as phone_number
from client;

-- 3 table

create or replace view views.sales_view as
  select start_date, end_date
from sales;

-- 4 table

create or replace view views.training_view as
  select training_name, duration, training_level
from training;

-- 5 table

create or replace view views.membership_x_training_view as
  select
from membership_x_training;

-- 6 table

create or replace view views.trainer_view as
  select
    regexp_replace(first_name, '.*', '****') as first_name,
    regexp_replace(last_name, '.*', '****') as last_name,
    regexp_replace(phone_number, '^(\+7|7|8)?.*', '\1-***-***-****') as phone_number
from trainer;

-- 7 table

create or replace view views.trainer_x_training_view as
  select
from trainer_x_training;

-- 8 table

create or replace view views.registration_view as
  select
from trainer_x_training;

------------------------------------------------------------------------------------------------------
-- 8 task

-- 1) Представление содержит клиентов и их абонементы с описанием

create or replace view views.membership_client_view as
select c.client_id, c.first_name, c.last_name, c.email, c.phone_number, m.membership_id, m.description
from client c
inner join sales s on s.client_id = c.client_id and c.valid_to = '5999.01.01'
inner join membership m on m.membership_id = s.membership_id;

-- 2) Представление содержит клиентов и их записи(в прошлом)

create or replace view views.registration_client_view as
select c.client_id, first_name, last_name, registration_dttm
from registration r
inner join client c on r.client_id = c.client_id and c.valid_to = '5999.01.01'
where registration_dttm < now();

-- 3) Представление содержит тренеров и клиентов, которые когда-либо к ним записывались

create or replace view views.trainer_client_view as
select distinct t.trainer_id, t.first_name as t_first_name, t.last_name as t_last_name,
       c.client_id, c.first_name as c_first_name, c.last_name as c_last_name
from registration r
inner join client c on r.client_id = c.client_id and c.valid_to = '5999.01.01'
inner join trainer t on r.trainer_id = t.trainer_id
group by t.trainer_id, t.first_name, t.last_name, c.client_id, c.first_name, c.last_name;

