-- 3 task

drop schema if exists project cascade;
create schema project;

set SEARCH_PATH = project;

DROP TABLE IF EXISTS membership CASCADE;
CREATE TABLE membership(
    membership_id serial primary key,
    visits_amt    int check ( visits_amt = 5 or visits_amt = 10 or visits_amt = 20 or is_unlimited ),
    start_date    date not null,
    end_date      date check ( end_date >= start_date ),
    is_unlimited  boolean default FALSE
);

DROP TABLE IF EXISTS client CASCADE;
CREATE TABLE client(
    client_id     serial,
    membership_id int not null,
    first_name    varchar(255) not null,
    last_name     varchar(255) not null,
    birth_date    date not null,
    phone_number  text check (phone_number ~ '^\+7-\d{3}-\d{3}-\d{4}$'),
    valid_from    date default now(),
    valid_to      date check ( valid_from <= valid_to ),

    foreign key (membership_id) references membership(membership_id) on delete cascade,
    primary key (client_id, valid_from)
);

DROP TABLE IF EXISTS gym CASCADE;
CREATE TABLE gym(
    gym_id       serial primary key,
    gym_name     varchar(255) not null,
    gym_location varchar(255),
    capacity     int check ( capacity > 0 )
);

DROP TABLE IF EXISTS training CASCADE;
CREATE TABLE training(
    training_id    serial primary key,
    gym_id         int not null,
    training_name  varchar(255) not null,
    duration       int check ( duration > 0),
    training_level varchar(255) default 'beginner',

    foreign key (gym_id) references gym(gym_id) on delete cascade
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
    phone_number text check (phone_number ~ '^\+7-\d{3}-\d{3}-\d{4}$')
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
    gym_id            int not null,
    trainer_id        int not null,
    registration_date timestamp check ( now() <= registration_date ),
    client_id         int not null,
    valid_from        date not null,

    foreign key (gym_id) references gym(gym_id) on delete cascade,
    foreign key (trainer_id) references trainer(trainer_id) on delete cascade,
    foreign key (client_id, valid_from) references client(client_id, valid_from) on delete cascade
);
