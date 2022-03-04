set SQL_SAFE_UPDATES = 0;
create database lr2;
use lr2;

create table students
(
	student_id int primary key auto_increment,
    student_name varchar(50) not null,
    student_surname varchar(50) not null,
    student_sex varchar(50) not null,
    student_average_score float not null,
    student_number int unique,
    student_learning_form varchar(50) not null,
    student_scholarship int not null,
    student_edu_cost int not null,
    student_hometown varchar(50) not null
);

insert into students(student_name, student_surname, student_sex, student_average_score, student_number, student_learning_form, student_scholarship, student_edu_cost,  student_hometown)
 values ("Roman", "Korostelev", "male", 7.7, 2022087, "budget", 140, 0, "Molodechno"),
 ("Oleg", "Astreiko", "male", 5, 21232133, "budget", 120, 0, "Minsk"),
 ("Evgeniy", "Kaskevich", "male", 7, 2134213, "budget", 140, 0, "Minsk"),
 ("Yan", "Suchodolski", "male", -1, 666666, "paid", 0, 100, "Minsk"),
 ("Alina", "Gerasimova", "female", 12, 1234567, "budget", 300, 0, "Gomel");

/*1.1*/
alter table students
change student_sex student_gender enum("male", "female") after student_average_score;

alter table students
change student_learning_form student_edu_form enum("budget", "paid") after student_edu_cost;

alter table students
change student_number student_id_number float after student_scholarship;

select * from students;

/*1.2*/

update students
set student_edu_cost = 1.15*student_edu_cost,
student_scholarship = 1.1*student_scholarship;

select * from students;

/*1.3*/
insert into students(student_name, student_surname, student_gender, student_average_score, student_id_number, student_edu_form, student_scholarship, student_edu_cost,  student_hometown)
 values ("Roman", "Korostelevaaaaaaaa", "male", 7.7, 202208733, "budget", 140, 0, "Molodechno");


update students
set student_scholarship = student_scholarship*1.2
where length(regexp_replace(student_surname, "[qwrtplkjhgfdszxcvbnmQWRTPLKJHGFDSZXCVBNM]", "")) > length(regexp_replace(student_surname, "[aeiouyAEIOUY]", ""));

select * from students;

/*1.3.1*/

update students
set student_scholarship = student_scholarship*(1 + (30 - day(now()))/100);

/*1.4*/

create table boys
(
	boy_id int primary key auto_increment,
    boy_name varchar(50) not null,
    boy_surname varchar(50) not null
);

create table girls
(
	girl_id int primary key auto_increment,
    girl_name varchar(50) not null,
    girl_surname varchar(50) not null
);

insert into boys(boy_name, boy_surname) 
select student_name, student_surname from students
where student_gender="male";

insert into girls(girl_name, girl_surname) 
select student_name, student_surname from students
where student_gender="female";

select * from boys;
select * from girls;

/*1.5*/

use greenpeace;

alter table actions
modify action_name varchar(55) not null;

alter table actions
change action_name action_nickname text;

alter table managment
drop column director_surname;

alter table managment 
add column director_surname varchar(50) not null;

alter table managment
add column director_height int default(100) first;

/*1.5.2*/

update managment
set director_name = "me";

update actions
set action_nickname = "show";

/*1.5.1*/

insert into actions(action_nickname, action_date) values 
("circus", "2020-09-02"), ("theatre", "2003-03-11");

update actions
set action_date = DATE_ADD(action_date, INTERVAL (IF(dayofweek(action_date) < 4, 4 - dayofweek(action_date), 11 - dayofweek(action_date))) DAY);

/*1.5.3*/ 

update actions
set action_nickname = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(action_nickname, 'a', 'D'), 'b', 'E'), 'c', 'F'), 'd', 'G'), 'e', 'H'), 'f', 'I'), 'g', 'J'), 'h', 'K'), 'i', 'L'), 'j', 'M'), 'k', 'N'), 'l', 'O'), 'm', 'P'), 'n', 'Q'), 'o', 'R'), 'p', 'S'), 'q', 'T'), 'r', 'U'), 's', 'V'), 't', 'W'), 'u', 'X'), 'v', 'Y'), 'w', 'Z'), 'x', 'A'), 'y', 'B'), 'z', 'C'), 'A', 'a'), 'B', 'b'), 'C', 'c'), 'D', 'd'), 'E', 'e'), 'F', 'f'), 'G', 'g'), 'H', 'h'), 'I', 'i'), 'J', 'j'), 'K', 'k'), 'L', 'l'), 'M', 'm'), 'N', 'n'), 'O', 'o'), 'P', 'p'), 'Q', 'q'), 'R', 'r'), 'S', 's'), 'T', 't'), 'U', 'u'), 'V', 'v'), 'W', 'w'), 'X', 'x'), 'Y', 'y'), 'Z', 'z');

/*1.6*/

use lr2;
drop table student_cities;
create table cities
(
	city_id int primary key auto_increment,
    city_name varchar(50) not null 
);

alter table cities
modify city_name varchar(50) not null unique;

insert into cities(city_name) 
select distinct student_hometown from students;

update students
set student_hometown = (select city_id from cities where city_name = student_hometown);

use lr2;
select * from students;
select * from students;

update students
set student_name = concat_ws('.', student_name, (select city_name from cities where city_id = student_hometown));

update students
set student_name = replace(replace(student_name, (select city_name from cities where city_id = student_hometown), ''), '.', '');

/*обрезает города оставляет только имя*/
/*2.1*/

create table sales
(
	sale_id int primary key auto_increment,
    first_author varchar(50) not null,
    selcond_author varchar(50),
    title varchar(50) not null,
    isbn varchar(50) ,
    price float,
    cust_name varchar(50),
    cust_adress varchar(50),
    purch_date varchar(50)
);


insert into sales
values
(1, "David Sklar", "Adam Trachtenberg", "PHP Cookbook", "0596101015", 44.99, "Emma Brown", "1565 Rainbow Road, Los Angeles", "Mar 03 2009");
insert into sales
values
(2, "Danny Goodman", "", "Dynamic HTML", "0596527403", 59.99, "Darren Ryder", "4758 Emily Drive, Richmond, VA 23219", "Dec 19 2008"),
(3, "Hugh E. Williams", "David Lane", "PHP and MySQL", "0596005436", 44.95, "Earl B. Thurston", "862 Gregory Lane, Frankfort, KY 40601", "Jun 22 2009"),
(4, "David Sklar", "Adam Trachtenberg", "PHP Cookbook", "0596101015", 44.99, "Darren Ryder", "4758 Emily Drive, Richmond, VA 23219", "Dec 19 2008"),
(5, "Rasmus Lerdorf", "Kevin Tatroe & Peter MacIntyre", "Programming PHP", "0596006815", 39.99, "David Miller", "3647 Cedar Lane, Waltham, MA 02154", "Jan 16 2009");


create table books
(
	book_id int primary key auto_increment not null,
    book_title varchar(50) not null,
    book_isbn varchar(50) unique,
    book_price float
);

select * from authors;
create table authors
(
	author_id int primary key auto_increment,
    author_name varchar(50) not null unique
);

drop table authors;
insert into authors(author_name)
select distinct first_author from sales;


select * from authors;
create table books_authors
(
	book_id int not null,
    author_id int not null,
    primary key(book_id, author_id),
    constraint cn61 foreign key (book_id) references books(book_id),
    constraint cn62 foreign key (author_id) references authors(author_id)
);

select * from authors;

insert into books_authors
select distinct (select distinct book_id from books where title = book_title), (select distinct author_id from authors where substring_index(selcond_author, '&' , -1) = author_name) sub from sales where selcond_author != "" and replace(selcond_author, '&', "") != selcond_author;

select author_id from authors where replace( "Kevin Tatroe & Peter MacIntyre", author_name,  "Kevin Tatroe & Peter MacIntyre") !=  "Kevin Tatroe & Peter MacIntyre" and  "Kevin Tatroe & Peter MacIntyre" != "";
insert into books(book_title, book_isbn, book_price)
select distinct title, isbn, price from sales;

alter table books
drop column book_first_author,
drop column book_second_author;

select * from books;
/* разделить имя*/
create table customers
(
	cust_id int primary key auto_increment not null,
    cust_name varchar(50),
    cust_adress varchar(50)
);

insert into customers(cust_name, cust_adress)
select distinct cust_name, cust_adress from sales;

create table sales1
(
    sale_date varchar(50),
    sale_cust int,
    sale_book int,
    primary key(sale_book, sale_cust),
    constraint cn1 foreign key (sale_cust) references customers(cust_id),
    constraint cn2 foreign key (sale_book) references books(book_id)
);
drop table customers;
select * from authors;
/*отдельную таблу для авторов*/





/*2.2*/

create table peoples
(
	emp_id int primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    children_names varchar(50) not null,
    children_birthdays varchar(50) not null
);

insert into peoples(emp_id, first_name, last_name, children_names, children_birthdays)
values (1001, "Jane", "Doe", "Mary,Sam", "1/1/92,5/15/94"),
	   (1002, "John", "Doe", "Mary,Sam", "1/1/92,5/15/94"),
       (1003, "Jane", "Smith", "John,Pat,Lee,Mary", "10/5/94,10/12/90,6/6/96,8/21/94"),
       (1004, "John", "Smith", "Michael", "7/4/96"),
       (1005, "Jane", "Jones", "Edward,Martha", "10/21/95,10/15/89");

create table employees
(
	emp_id int primary key,
    emp_first_name varchar(50) not null,
    emp_second_name varchar(50) not null
);

select * from parent_childs;
create table children
(
	child_id int primary key auto_increment,
    child_name varchar(50) not null,
    child_date varchar(50) not null
);

insert into employees
select emp_id, first_name, last_name from peoples;

create table parent_childs
(
    child_name varchar(50) not null,
    child_date varchar(50) not null,
    parent_id int not null,
    primary key(child_name, parent_id),
	constraint cn4 foreign key (parent_id) references employees(emp_id)
);
 
insert into parent_childs(child_name, child_date, parent_id)
SELECT
     SUBSTRING_INDEX(children_names, ',', 1) AS child_name,
     SUBSTRING_INDEX(children_birthdays, ',', 1) AS child_date,
     emp_id
FROM peoples;

select * from parent_childs;

insert into parent_childs(child_name, child_date, parent_id)
select child_name, child_date, emp_id from(
SELECT
	  @num_children_names_lines := 1 + LENGTH(children_names) - LENGTH(REPLACE(children_names, ',', '')) AS num_children_names_lines,
      if(@num_children_names_lines > 1, SUBSTRING_INDEX(SUBSTRING_INDEX(children_names, ',', 2), ',', -1), '') AS child_name,
      if(@num_children_names_lines > 1, SUBSTRING_INDEX(SUBSTRING_INDEX(children_birthdays, ',', 2), ',', -1), '') AS child_date,
      emp_id
FROM peoples) sub where child_name != '';

insert into parent_childs(child_name, child_date, parent_id)
select child_name, child_date, emp_id from(
SELECT
	  @num_children_names_lines := 1 + LENGTH(children_names) - LENGTH(REPLACE(children_names, ',', '')) AS num_children_names_lines,
      if(@num_children_names_lines > 3, SUBSTRING_INDEX(SUBSTRING_INDEX(children_names, ',', 4), ',', -1), '') AS child_name,
      if(@num_children_names_lines > 3, SUBSTRING_INDEX(SUBSTRING_INDEX(children_birthdays, ',', 4), ',', -1), '') AS child_date,
      emp_id
FROM peoples) sub where child_name != '';

SELECT
     @num_children_names_lines := 1 + LENGTH(children_names) - LENGTH(REPLACE(children_names, ',', '')) AS num_children_names_lines,
     SUBSTRING_INDEX(children_names, ',', 1) AS children_names1,
     IF(@num_children_names_lines > 1, SUBSTRING_INDEX(SUBSTRING_INDEX(children_names, ',', 2), ',', -1), '') AS children_names2,
     IF(@num_children_names_lines > 2, SUBSTRING_INDEX(SUBSTRING_INDEX(children_names, ',', 3), ',', -1), '') AS children_names3,
	 IF(@num_children_names_lines > 3, SUBSTRING_INDEX(SUBSTRING_INDEX(children_names, ',', 4), ',', -1), '') AS children_names4
 FROM peoples;


/*3.1*/

use lr2;
create table autos1
(
	auto_number varchar(50) primary key,
    auto_model varchar(50) not null,
    auto_year int not null,
    auto_price int not null,
    auto_specs varchar(50)
);

insert into autos1 
values
("АФ 1233 ФА", "Mercedes-Benz G-400", 2002, 28000, "Автомат, дизель, 4.0 л."),
("FG 67 SPV", "Mercedes-Benz G-400 AMG", 2002, 38500, "Типтроник, дизель, 4.0 л."),
("АО 1234 ОА", "Toyota Sequoira", 2012, 32500, "Автомат, бензин, 5.7 л."),
("АО 4254 АО", "Toyota Avalon", 2015, 21000, "Автомат, бензин, 3.5 л."),
("ТТ 777 МН", "Subaru Forester", 2016, 18800, "Автомат, бензин, 2.5 л."),
("SS 908 KLV", "Suzuki SX4", 2020, 19000, "Механическая, бензин, 1.6 л.");


alter table autos1
add column auto_fabr varchar(50) after auto_number,
add column auto_box varchar(50) after auto_price,
add column auto_fuel varchar(50) after auto_box,
add column auto_volume varchar(50) after auto_fuel;

update autos1
set 
auto_fabr = substring_index(auto_model, ' ', 1),
auto_model = replace(auto_model, substring_index(auto_specs, ' ', 1), ''),
auto_box = substring_index(auto_specs, ',', 1),
auto_fuel = substring_index(substring_index(auto_specs, ',', -2), ',' , 1),
auto_volume = substring_index(auto_specs, ',', -1);

alter table autos1
drop column auto_specs;

select * from autos1;

/*3.2*/

create table films2
(
	film_id int primary key auto_increment,
    film_title varchar(50) not null,
    film_star varchar(50) not null,
    film_producer varchar(50) not null
);

insert into films2(film_title, film_star, film_producer)
values
("Great Film", "Lovely Lady", "Money Bags"),
("Great Film", "Handsome Man", "Money Bags"),
("Great Film", "Lovely Lady", "Helen Pursestrings"),
("Great Film", "Handsome Man", "Helen Pursestrings"),
("Boring Movie", "Lovely Lady", "Helen Pursestrings"),
("Boring Movie", "Precocious Child", "Helen Pursestrings");

create table stars
(
	star_id int primary key auto_increment,
    star_name varchar(50) not null
);

create table producers
(
	producer_id int primary key auto_increment,
    producer_name varchar(50) not null
);

create table films
(
	film_id int primary key auto_increment,
    film_name varchar(50) not null
);

insert into stars(star_name)
select distinct film_star from films2;

 
insert into films(film_name)
select distinct film_title from films2;

insert into producers(producer_name)
select distinct film_producer from films2;

create table film_star
(
	film_id int not null,
    star_id int not null,
    primary key(film_id, star_id),
    constraint cn11 foreign key (film_id) references films(film_id),
    constraint cn12 foreign key (star_id) references stars(star_id)
);

create table film_producer
(
	film_id int not null,
    producer_id int not null,
    primary key(film_id, producer_id),
    constraint cn21 foreign key (film_id) references films(film_id),
    constraint cn22 foreign key (producer_id) references producers(producer_id)
);

insert into film_star
select distinct (select film_id from films where film_name = films2.film_title) sub1, (select star_id from stars where star_name = films2.film_star) sub from films2;  

insert into film_producer
select distinct (select film_id from films where film_name = films2.film_title) sub1, (select producer_id from producers where producer_name = films2.film_producer) sub from films2;  

select * from film_producer;

/*3.3*/

create table tutors
(
	book_id int primary key auto_increment,
    tutor_surname varchar(50) not null,
    tutor_course varchar(50) not null,
    tutor_title varchar(50) not null
); 

insert into tutors(tutor_surname, tutor_course, tutor_title)
values
("А", "Информатика", "Информатика"),
("А", "Сети ЭВМ", "Информатика"),
("А", "Информатика", "Сети ЭВМ"),
("А", "Сети ЭВМ", "Сети ЭВМ"),
("В", "Программирование", "Программирование"),
("В", "Программирование", "Теория алгоритмов");

create table teachers
(
	teacher_id int primary key auto_increment,
    teacher_name varchar(50) not null
);

create table courses
(
	course_id int primary key auto_increment,
    course_name varchar(50) not null
);

create table manuals
(
	manual_id int primary key auto_increment,
    manual_name varchar(50) not null
);

insert into teachers(teacher_name)
select distinct tutor_surname from tutors;

 
insert into courses(course_name)
select distinct tutor_course from tutors;

insert into manuals(manual_name)
select distinct tutor_title from tutors;

create table teacher_course
(
	teacher_id int not null,
    course_id int not null,
    primary key(teacher_id, course_id),
    constraint cn31 foreign key (teacher_id) references teachers(teacher_id),
    constraint cn32 foreign key (course_id) references courses(course_id)
);

create table teacher_manual
(
	teacher_id int not null,
    manual_id int not null,
    primary key(teacher_id, manual_id),
    constraint cn41 foreign key (teacher_id) references teachers(teacher_id),
    constraint cn42 foreign key (manual_id) references manuals(manual_id)
);

insert into teacher_course
select distinct (select teacher_id from teachers where teacher_name = tutors.tutor_surname) sub1, (select course_id from courses where course_name = tutors.tutor_course) sub from tutors;  

insert into teacher_manual
select distinct (select teacher_id from teachers where teacher_name = tutors.tutor_surname) sub1, (select manual_id from manuals where manual_name = tutors.tutor_title) sub from tutors;  

select * from teacher_course;
select * from teacher_manual;

/*3.4*/

create table parking
(
	parking_id int primary key auto_increment,
    parking_number int not null,
    parking_start_time varchar(50) not null,
    parking_end_time varchar(50) not null,
    parking_tariff varchar(50) not null
);

insert into parking(parking_number, parking_start_time, parking_end_time, parking_tariff)
values
(1, "9:30", "10:30", "Бережливый"),
(1, "11:00", "12:00", "Бережливый"),
(1, "14:00", "15:30", "Стандар"),
(2, "10:00", "11:30", "Премиум-В"),
(2, "11:30", "13:30", "Премиум-В"),
(2, "15:00", "16:30", "Премиум-А");

create table tariffs
(
	tarriff_name varchar(50) primary key,
    tariff_parking_number int not null,
    tariff_premium bool not null
);

create table booking
(
	booking_tariff varchar(50) not null,
    booking_start_time varchar(50) not null,
    booking_end_time varchar(50) not null,
    primary key(booking_tariff, booking_start_time, booking_end_time),
    constraint cn51 foreign key  (booking_tariff) references tariffs(tarriff_name)
);

select * from booking;
insert into tariffs
select distinct parking_tariff, parking_number, substr(parking_tariff, 7) = "Премиум" from parking;

insert into booking
select parking_tariff, parking_start_time, parking_end_time from parking;

select * from booking;

/*доменно-ключевая нормальная форма сделать пример*/

use lr2;
create table domain_key
(
	worker_id varchar(50) primary key,
    worker_name varchar(50) not null,
    worker_age int not null,
    constraint cn71 check (length(worker_id) = 4)
);

insert into domain_key
values
('0123', 'petya', 12),
('2132', 'vanya', 43);

insert into domain_key
values
('123', 'vasya', 31);