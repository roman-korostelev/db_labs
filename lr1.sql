create database greenpeace;
use greenpeace;

create table regions
(
	region_id int primary key auto_increment,
    region_name varchar(45) not null
);

create table subdivisions
(
	subdivision_id int primary key auto_increment,
    subdivision_name varchar(45) not null
);

create table managment
(
	director_id int primary key auto_increment,
    director_name varchar(45) not null,
    director_surname varchar(45) not null,
    director_region_id int not null,
    director_subdivision_id int not null,
    constraint cn1 foreign key (director_region_id) references regions(region_id),
    constraint cn2 foreign key (director_subdivision_id) references subdivisions(subdivision_id)
);

create table actions
(
	action_id int primary key auto_increment,
    action_name varchar(45) not null,
    action_date date not null
);

create table actions_regions
(
	action_id int,
    region_id int,
    primary key(action_id, region_id),
    constraint cn3 foreign key (action_id) references actions(action_id),
    constraint cn4 foreign key (region_id) references regions(region_id)
);

create table structure
(
	participant_id int primary key auto_increment, 
    participant_name varchar(45) not null,
    participant_surname varchar(45) not null,
    participant_parent int,
    constraint cn6 foreign key (participant_parent) references structure(participant_id)
); 

create table actions_participants 
(
	action_id int,
    participant_id int,
    primary key(action_id, participant_id),
    constraint cn5 foreign key (action_id) references actions(action_id),
    constraint cn7 foreign key (participant_id) references structure(participant_id)
);

drop table structure;
insert into structure
(participant_id, participant_name, participant_surname, participant_parent)
values
(1, "roma", "romashe4ka", null),
(2, "km", "km", 1);
insert into structure
(participant_id, participant_name, participant_surname, participant_parent)
values
(4, "321", "31", 8);
select * from structure;