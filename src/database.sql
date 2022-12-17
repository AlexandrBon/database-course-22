-- 3 task

drop schema if exists project cascade;
create schema project;

set SEARCH_PATH = project;

DROP TABLE IF EXISTS membership CASCADE;
CREATE TABLE membership(
    membership_id   serial primary key,
    description     text check ( description > '' ),
    days_amt        int check ( days_amt in (30, 60, 90) ),
    visits_amt      int check ( visits_amt in (8, 16, 30) or (visits_amt = 999 and is_unlimited) ),
    is_unlimited    boolean default FALSE,
    membership_cost numeric(6, 2) default 5000
);

DROP TABLE IF EXISTS client CASCADE;
CREATE TABLE client(
    client_id     serial,
    first_name    varchar(255) not null,
    last_name     varchar(255) not null,
    birth_date    date not null,
    phone_number  text check (phone_number ~ '^(\+7|7|8)?[\s\-]?\(?[489][0-9]{2}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$'),
    valid_from    date default current_date,
    valid_to      date check( valid_from <= client.valid_to ),

    primary key (client_id, valid_from)
);

DROP TABLE IF EXISTS sales CASCADE;
CREATE TABLE sales(
    client_id     int not null,
    valid_from    date not null,
    membership_id int not null,
    start_date    date default current_date check ( start_date >= valid_from ),
    end_date      date check (start_date <= end_date),

    primary key (client_id, valid_from, membership_id),
    foreign key (membership_id) references membership(membership_id),
    foreign key (client_id, valid_from) references client(client_id, valid_from) on delete  cascade
);

DROP TABLE IF EXISTS training CASCADE;
CREATE TABLE training(
    training_id    serial primary key,
    training_name  varchar(255) not null,
    duration       int check ( duration > 0),
    training_level varchar(255) default 'beginner'
);

DROP TABLE IF EXISTS client_x_training CASCADE;
CREATE TABLE client_x_training(
    training_id int not null,
    client_id   int not null,
    valid_from  date not null,

    foreign key (training_id) references training(training_id) on delete cascade,
    foreign key (client_id, valid_from) references client(client_id, valid_from) on delete cascade,
    primary key (client_id, valid_from, training_id)
);

DROP TABLE IF EXISTS trainer CASCADE;
CREATE TABLE trainer(
    trainer_id   serial primary key,
    first_name   varchar(255) not null,
    last_name    varchar(255) not null,
    phone_number text check (phone_number ~ '^(\+7|7|8)?[\s\-]?\(?[489][0-9]{2}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$')
);

DROP TABLE IF EXISTS training_x_trainer CASCADE;
CREATE TABLE training_x_trainer(
    trainer_id  int not null,
    training_id int not null,

    foreign key (trainer_id) references trainer(trainer_id) on delete cascade,
    foreign key (training_id) references training(training_id) on delete cascade,
    primary key (training_id, trainer_id)
);

DROP TABLE IF EXISTS registration CASCADE;
CREATE TABLE registration(
    registration_id   serial primary key,
    trainer_id        int not null,
    training_id       int not null,
    registration_dttm timestamp check ( registration_dttm >= valid_from ),
    client_id         int not null,
    valid_from        date not null,

    foreign key (trainer_id, training_id) references training_x_trainer(trainer_id, training_id) on delete cascade,
    foreign key (client_id, valid_from, training_id) references client_x_training(client_id, valid_from, training_id) on delete cascade
);

-- 4 task

insert into membership(membership_id, description, days_amt, visits_amt, is_unlimited, membership_cost) values (1, 'gym', 90, 30, FALSE, 7500);
insert into membership(membership_id, description, days_amt, visits_amt, is_unlimited, membership_cost) values (2, 'gym', 60, 999, TRUE, 6000);
insert into membership(membership_id, description, days_amt, visits_amt, is_unlimited, membership_cost) values (3, 'box', 30, 999, TRUE, 3000);
insert into membership(membership_id, description, days_amt, visits_amt, is_unlimited, membership_cost) values (4, 'box', 90, 30, FALSE, 9000);
insert into membership(membership_id, description, days_amt, visits_amt, is_unlimited, membership_cost) values (5, 'freestyle wrestling', 60, 16, FALSE, 5500);
insert into membership(membership_id, description, days_amt, visits_amt, is_unlimited, membership_cost) values (6, 'freestyle wrestling', 30, 999, TRUE, 3000);

insert into client(client_id, first_name, last_name, birth_date, phone_number, valid_from, valid_to) values (1, 'Alexandr', 'Bondarenko', '2001-11-21', '+7-964-345-8941', '2021-02-10', '2021-06-15');
insert into client(client_id, first_name, last_name, birth_date, phone_number, valid_from, valid_to) values (2, 'Igor', 'Lyadov', '2003-02-24', '+7-975-322-6127', '2021-02-14', '5999-01-01');
insert into client(client_id, first_name, last_name, birth_date, phone_number, valid_from, valid_to) values (3, 'Vladimir', 'Smirnov', '1996-04-13', '+7-951-737-8283', '2021-03-17', '2021-08-15');
insert into client(client_id, first_name, last_name, birth_date, phone_number, valid_from, valid_to) values (4, 'Nikolay', 'Bobrov', '1998-07-29', '+7-987-951-8795', '2021-05-02', '5999-01-01');
insert into client(client_id, first_name, last_name, birth_date, phone_number, valid_from, valid_to) values (5, 'Fedor', 'Golovlev', '2004-01-01', '+7-984-594-8941', '2021-09-15', '5999-01-01');
insert into client(client_id, first_name, last_name, birth_date, phone_number, valid_from, valid_to) values (1, 'Alexandr', 'Bondarenko', '2001-11-21', '+7-964-338-9335', '2021-06-15', '5999-01-01');
insert into client(client_id, first_name, last_name, birth_date, phone_number, valid_from, valid_to) values (3, 'Vladimir', 'Smirnov', '1996-04-13', '+7-999-777-3071', '2021-08-15', '5999-01-01');
insert into client(client_id, first_name, last_name, birth_date, phone_number, valid_from, valid_to) values (6, 'Ivan', 'Gurnov', '2002-06-04', '+7-921-571-7960', '2021-09-17', '5999-01-01');

insert into sales(client_id, valid_from, membership_id, start_date, end_date) values (1, '2021-02-10', 1, '2021-02-15', '2021-02-15'::date + interval '90 days');
insert into sales(client_id, valid_from, membership_id, start_date, end_date) values (2, '2021-02-14', 2, '2021-02-16', '2021-02-16'::date + interval '60 days');
insert into sales(client_id, valid_from, membership_id, start_date, end_date) values (1, '2021-06-15', 3, '2021-06-25', '2021-06-25'::date + interval '30 days');
insert into sales(client_id, valid_from, membership_id, start_date, end_date) values (3, '2021-03-17', 4, '2021-03-20', '2021-03-20'::date + interval '90 days');
insert into sales(client_id, valid_from, membership_id, start_date, end_date) values (3, '2021-08-15', 1, '2021-08-17', '2021-08-17'::date + interval '90 days');
insert into sales(client_id, valid_from, membership_id, start_date, end_date) values (4, '2021-05-02', 3, '2021-05-10', '2021-05-10'::date + interval '30 days');
insert into sales(client_id, valid_from, membership_id, start_date, end_date) values (5, '2021-09-15', 5, '2021-09-15', '2021-09-15'::date + interval '60 days');
insert into sales(client_id, valid_from, membership_id, start_date, end_date) values (6, '2021-09-17', 2, '2021-09-18', '2021-09-18'::date + interval '60 days');

insert into training(training_id, training_name, duration, training_level) values (1, 'box', 60, 'beginner');
insert into training(training_id, training_name, duration, training_level) values (2, 'freestyle wrestling', 60, 'beginner');
insert into training(training_id, training_name, duration, training_level) values (3, 'leg training', 45, 'medium');
insert into training(training_id, training_name, duration, training_level) values (4, 'arm training', 45, 'beginner');
insert into training(training_id, training_name, duration, training_level) values (5, 'yoga', 45, 'beginner');
insert into training(training_id, training_name, duration, training_level) values (6, 'yoga', 80, 'medium');

insert into client_x_training(training_id, client_id, valid_from) values (1, 1, '2021-02-10');
insert into client_x_training(training_id, client_id, valid_from) values (1, 1, '2021-06-15');
insert into client_x_training(training_id, client_id, valid_from) values (2, 2, '2021-02-14');
insert into client_x_training(training_id, client_id, valid_from) values (1, 2, '2021-02-14');
insert into client_x_training(training_id, client_id, valid_from) values (2, 3, '2021-03-17');
insert into client_x_training(training_id, client_id, valid_from) values (2, 3, '2021-08-15');
insert into client_x_training(training_id, client_id, valid_from) values (3, 4, '2021-05-02');
insert into client_x_training(training_id, client_id, valid_from) values (5, 5, '2021-09-15');
insert into client_x_training(training_id, client_id, valid_from) values (6, 6, '2021-09-17');
insert into client_x_training(training_id, client_id, valid_from) values (4, 6, '2021-09-17');
insert into client_x_training(training_id, client_id, valid_from) values (3, 1, '2021-06-15');
insert into client_x_training(training_id, client_id, valid_from) values (5, 2, '2021-02-14');

insert into trainer(trainer_id, first_name, last_name, phone_number) values (1, 'Ivan', 'Pirogov', '+7-996-975-1353');
insert into trainer(trainer_id, first_name, last_name, phone_number) values (2, 'Igor', 'Milshin', '+7-931-452-2213');
insert into trainer(trainer_id, first_name, last_name, phone_number) values (3, 'Alexandr', 'Rogachev', '+7-943-769-4289');
insert into trainer(trainer_id, first_name, last_name, phone_number) values (4, 'Anastasiya', 'Gorbacheva', '+7-981-348-3186');
insert into trainer(trainer_id, first_name, last_name, phone_number) values (5, 'Temirlan', 'Zverev', '+7-931-563-9348');
insert into trainer(trainer_id, first_name, last_name, phone_number) values (6, 'Roman', 'Dushin', '+7-943-739-4472');

insert into training_x_trainer(trainer_id, training_id) values (1, 2);
insert into training_x_trainer(trainer_id, training_id) values (2, 3);
insert into training_x_trainer(trainer_id, training_id) values (3, 1);
insert into training_x_trainer(trainer_id, training_id) values (4, 6);
insert into training_x_trainer(trainer_id, training_id) values (5, 4);
insert into training_x_trainer(trainer_id, training_id) values (6, 5);
insert into training_x_trainer(trainer_id, training_id) values (1, 3);
insert into training_x_trainer(trainer_id, training_id) values (4, 5);

insert into registration(registration_id, trainer_id, training_id, registration_dttm, client_id, valid_from) values (1, 3, 1, '2021-02-16 10:00', 1, '2021-02-10');
insert into registration(registration_id, trainer_id, training_id, registration_dttm, client_id, valid_from) values (2, 3, 1, '2021-02-16 10:00', 2, '2021-02-14');
insert into registration(registration_id, trainer_id, training_id, registration_dttm, client_id, valid_from) values (3, 1, 2, '2021-04-16 12:00', 3, '2021-03-17');
insert into registration(registration_id, trainer_id, training_id, registration_dttm, client_id, valid_from) values (4, 1, 2, '2021-04-16 12:00', 2, '2021-02-14');
insert into registration(registration_id, trainer_id, training_id, registration_dttm, client_id, valid_from) values (5, 1, 3, '2021-10-16 21:00', 4, '2021-05-02');
insert into registration(registration_id, trainer_id, training_id, registration_dttm, client_id, valid_from) values (6, 4, 5, '2021-10-16 21:00', 5, '2021-09-15');
insert into registration(registration_id, trainer_id, training_id, registration_dttm, client_id, valid_from) values (7, 4, 6, '2021-10-16 21:00', 6, '2021-09-17');

-- 5 task

-- Выберем таблицы trainer и  registration и сделаем для них CRUD-запросы.

-- trainer:
insert into trainer(trainer_id, first_name, last_name, phone_number) values (7, 'Alexey', 'Makov', '+7-991-093-9001');
select first_name, last_name from trainer;
update trainer set phone_number = '8-994-001-4012' where trainer_id = 2;
delete from trainer where trainer_id = 7;

-- client:
insert into registration(registration_id, trainer_id, training_id, registration_dttm, client_id, valid_from) values (8, 5, 4, '2021-12-16 9:00', 6, '2021-09-17');

-- выводим всех клиетов, их тренировки и уровень.
select c.first_name, c.last_name, t.training_name, t.training_level
from registration r
inner join client c on r.client_id = c.client_id
inner join client_x_training ct on r.client_id = ct.client_id
inner join training t on t.training_id = ct.training_id
group by c.client_id, c.first_name, c.last_name, t.training_name, t.training_level
order by c.first_name;

update registration set registration_dttm = '2021-12-16 10:00' where registration_id = 8;
delete from registration where registration_id = 8;

-- 6 task

-- Запрос выводит всех клиентов в убывающем лексикографически по фамилии порядке, которые занимаются боксом.
-- Формат вывода: id клиента, имя клиента, фамилия клиента
-- Ожидаемый вывод:
--  2 Igor     Lyadov
--  1 Alexandr Bondarenko

-- 1
select c.client_id, c.first_name, c.last_name
from client c
inner join client_x_training ct on c.valid_from = ct.valid_from
inner join training t on ct.training_id = t.training_id
where training_name = 'box'
group by c.client_id, c.first_name, c.last_name
order by c.first_name DESC;

