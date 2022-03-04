
set global log_bin_trust_function_creators = 1;
create database mmf2021;
use mmf2021;

create table studs
(
	st_id int primary key auto_increment,
    st_name varchar(50) not null,
    st_surname varchar(50) not null,
    st_speciality enum("km", "web", "peds", "mob", "mechanics", "constructors"),
    st_form enum("budget", "paid"),
    st_value float not null
);

create table subjects
(
		sub_id int primary key auto_increment,
        sub_name varchar(50) not null,
        sub_teacher varchar(20) not null,
        sub_hours int not null
);

create table exams
(
	exam_id int primary key auto_increment,
    ref_sub_id int not null,
    ref_st_id int not null,
    exam_date datetime not null,
    exam_mark int,
    constraint cn1 foreign key (ref_sub_id) references subjects(sub_id) on update cascade, 
    constraint cn2 foreign key (ref_st_id) references studs(st_id) on update cascade
);

insert into studs(st_name, st_surname, st_speciality, st_form, st_value)
values
("Roman", "Korostelev", "km", "budget", 7.7),
("Ilya", "Mazur", "peds", "paid", 6.9),
("Alexei", "Slonski", "web", "budget", 6.7),
("Alina", "Gerasimova", "km", "budget", 10.1),
("Oleg", "Astreilo", "mob", "budget", 3.9);

insert into subjects
values
(1, "Math Analysis", "Gromak", 1000),
(2, "Database", "Kushnerov", 2000),
(3, "PSA", "Atrohov", 100);
 
insert into exams
values
(1, 1, 1, "2021-01-03", 2),
(2, 2, 2, "2021-01-04", 3),
(3, 3, 3, "2021-01-05", 4),
(4, 1, 1, "2021-01-06", 5),
(5, 2, 2, "2021-01-07", 6);

/*2.1*/
create table marks
(
	mark_id int primary key auto_increment,
    mark_value int not null,
    ref_st_id int not null,
    ref_lesson_id int not null,
    constraint cn4 foreign key (ref_st_id) references studs(st_id) on update cascade,
    constraint cn3 foreign key (ref_lesson_id) references lessons(lesson_id) on update cascade
);

select * from studs;
select * from lessons;
insert into lessons
values
(2, 2, "2021-11-23", "km"),
(3, 3, "2022-02-11", "mob");
select * from subjects;
insert into marks(mark_value, ref_st_id, ref_lesson_id)
values
(4, 1, 2),
(5, 3, 2),
(10, 1, 3); 

use mmf2021;
create table teachers
(
	teacher_id int primary key auto_increment,
    teacher_surname varchar(50) not null
);
insert into teachers(teacher_surname)
select sub_teacher from subjects;
drop table teachers;

/*время добавить, ссылка на лессон*/
select * from marks;
/*2.2*/

create table lessons
(
	lesson_id int primary key auto_increment,
    lesson_sub int not null,
    lesson_date date not null,
    constraint cn5 foreign key (lesson_sub) references subjects(sub_id) on update cascade
);

create table lesson_student
(
	lesson_id int not null,
    st_id int not null,
    primary key(lesson_id, st_id),
    constraint cn6 foreign key (lesson_id) references lessons(lesson_id) on update cascade,
    constraint cn7 foreign key (st_id) references studs(st_id) on update cascade
);

alter table lesson_student
add column pretence bool default(true);

alter table studs
add column st_sick enum("healthy", "corona", "orvi") default("healthy");

/*2.3*/

create table activity 
(
	activity_id int primary key auto_increment,
    activity_name varchar(50) not null
);

create table activity_student
(
	activity_id int not null,
    st_id int not null,
    primary key (activity_id, st_id),
    constraint cn8 foreign key (activity_id) references activity(activity_id) on update cascade,
    constraint cn9 foreign key (st_id) references studs(st_id) on update cascade
);

/*2.4*/


alter table studs
add column st_instl_per_month float default(if(st_form = "paid" and st_installment = true, st_pay_value/12, null));
 
select * from studs;

/*детализацию рассрочки*/
alter table studs
add column st_instl_per_month float default(if(st_form = "paid" and st_installment = true, st_pay_value/12, null));

alter table studs
add column st_pay_value int default(null),
add column st_installment bool default(false);

create table installment 
(
	inst_id int primary key auto_increment,
    inst_value float not null,
    inst_value_per_month float default(inst_value/12),
    ref_st_id int not null,
    constraint cn13 foreign key (ref_st_id) references studs(st_id)
);

/*2.5*/

alter table studs
modify column st_health enum("main", "prepairing", "special", "free");



/*автоматические энки при короне*/
delimiter //
create function check_health(stud_id int)
returns bool
begin
	return ((select st_sick from studs where st_id = stud_id) = "healthy");
end//
delimiter;


delimiter //
create trigger check_corona 
before insert on lesson_student
for each row
begin
	if (select st_sick from studs where st_id = new.st_id) = "corona" then
		set new.pretence = false;
	end if;
end//
delimiter ;
/*прожать*/

/*2.6*/
/*поменял в таблицах*/
/*2.7*/

alter table studs
add constraint cn10 check(st_value >= 3.8);

/*3*/

create table credits
(
	credit_id int primary key auto_increment,
    ref_sub_id int not null,
    ref_st_id int not null,
    credit_date datetime not null,
    credit_mark enum("accepted", "not accepted"),
    constraint cn11 foreign key (ref_sub_id) references subjects(sub_id) on update cascade, 
    constraint cn12 foreign key (ref_st_id) references studs(st_id) on update cascade
);

delimiter //
create procedure passexam(in stud_id int, in subj varchar(50), in ex_date datetime, in ex_mark int)
begin
	declare id, qua int;
    select sub_id into id from subjects
    where sub_name=subj;
    select count(*) into qua from studs
    where st_id=stud_id;
    if (qua=1 && id>0) then
		insert into exams
        (ref_sub_id, ref_st_id, exam_date, exam_mark)
        values
        (id, stud_id, ex_date, ex_mark);
	else
		select null;
	end if;
end//
delimiter ;

delimiter //
create procedure passcredit(in stud_id int, in subj varchar(50), in cr_date datetime, in cr_mark enum("accepted", "not accepted"))
begin
	declare id, qua int;
    select sub_id into id from subjects
    where sub_name=subj;
    select count(*) into qua from studs
    where st_id=stud_id;
    if (qua=1 && id>0) then
		insert into credits
        (ref_sub_id, ref_st_id, credit_date, credit_mark)
        values
        (id, stud_id, cr_date, cr_mark);
	else
		select null;
	end if;
end//
delimiter ;

set @fails=0;

alter table studs
add column st_debt int default(0);

delimiter //
create trigger retake_exam after insert on exams
for each row 
begin
	if new.exam_mark < 4 then
		update studs
        set st_debt = st_debt + 1
        where st_id = new.ref_sub_id;
	end if;
    if (select st_debt from studs where new.ref_sub_id = st_id) = 3 then
		call expulsion(new.ref_sub_id);
	end if;
end//
delimiter ;

delimiter //
create trigger retake_credit after insert on credits
for each row 
begin
	if new.credit_mark = "not accepted" then
		update studs
        set st_debt = st_debt + 1
        where st_id = new.ref_sub_id;
	end if;
    if (select st_debt from studs where new.ref_sub_id = st_id) = 3 then
		call expulsion(new.ref_sub_id);
	end if;
end//
delimiter ;

delimiter //
create procedure expulsion(in stud_id int)
begin
	delete from studs where st_id = stud_id;
end//
delimiter ;

/*4.1*/


alter table studs
add column st_scholarship double default(if(st_form = "budget", 100, 0));
select * from studs;

delimiter //
create procedure up_scholarship(in pers double)
begin 
	update studs
    set st_scholarship = st_scholarship * (100 + pers) / 100;
end//
delimiter ;

drop procedure up_scholarship;
set SQL_SAFE_UPDATES = 0;
call up_scholarship(56);

/*4.2*/

delimiter //
create function get_avg_mark(teacher varchar(50))
returns float
begin
	declare ans float;
	select avg(exam_mark) into ans from exams where ref_sub_id = (select sub_id from subjects where sub_teacher = "Kushnerov");
    return ans;
end//
delimiter ;
/*4.3*/

delimiter //
create function fib_q(n int)
returns bool
begin
	return (pow(sqrt(5*n*n - 4),2) = 5*n*n - 4 and pow(sqrt(5*n*n + 4),2) = 5*n*n + 4);
end//
delimiter ;

delimiter //
create procedure give_money()
begin 
	update studs
    set st_scholarship = st_sholarship*1.2
    where fib_q(st_id);
end//
delimiter ;

/*4.4*/

delimiter //
create function get_activity(stud_id int)
returns int
begin
	return (select count(activity_id) from activity_student where st_id = stud_id);
end//
delimiter ;


delimiter //
create procedure top_success()
begin
	declare s_name,s_surname varchar(50);
	declare is_end int default 0;
    declare cur cursor for select st_name, st_surname from studs order by st_scholarship desc limit 5;
    declare continue handler for not found set is_end = 1;
    drop table if exists top_success_students;
    create table top_success_students
    (
		st_place int primary key auto_increment,
        st_name varchar(50) not null,
        st_surname varchar(50) not null
    );
    open cur;
    curs : loop
		fetch cur into s_name, s_surname;
        if is_end then
			leave curs;
		end if;
        insert into top_success_students(st_name, st_surname)
        values
        (s_name, s_surname);
	end loop curs;
    close cur;
    select * from top_success_students;
end//
delimiter ;

delimiter //
create procedure top_bad()
begin
	declare s_name,s_surname varchar(50);
	declare is_end int default 0;
    declare cur cursor for select st_name, st_surname from studs order by st_value asc limit 5;
    declare continue handler for not found set is_end = 1;
    drop table if exists top_bad_students;
    create table top_bad_students
    (
		st_place int primary key auto_increment,
        st_name varchar(50) not null,
        st_surname varchar(50) not null
    );
    open cur;
    curs : loop
		fetch cur into s_name, s_surname;
        if is_end then
			leave curs;
		end if;
        insert into top_bad_students(st_name, st_surname)
        values
        (s_name, s_surname);
	end loop curs;
    close cur;
    select * from top_bad_students;
end//
delimiter ;

delimiter //
create procedure top_activity()
begin
	declare s_name,s_surname varchar(50);
	declare is_end int default 0;
    declare cur cursor for select st_name, st_surname from studs order by get_activity(st_id) desc limit 5;
    declare continue handler for not found set is_end = 1;
    drop table if exists top_activity_students;
    create table top_activity_students
    (
		st_place int primary key auto_increment,
        st_name varchar(50) not null,
        st_surname varchar(50) not null
    );
    open cur;
    curs : loop
		fetch cur into s_name, s_surname;
        if is_end then
			leave curs;
		end if;
        insert into top_activity_students(st_name, st_surname)
        values
        (s_name, s_surname);
	end loop curs;
    close cur;
    select * from top_activity_students;
end//
delimiter ;

/*4.5*/

/*было реализовано в рамках задания 3*/

/*4.6*/
insert into marks
values
(1,10, 1, 1),
(2,10, 1, 1),
(3, 5, 1, 1);

delimiter //
create function get_most_popular_mark()
returns int
begin
	return (select mark from (select mark_value as mark, count(mark_value) as mark_count from marks group by mark order by mark_count desc limit 1) sub);
end//
delimiter ;

select get_most_popular_mark();

/*4.7*/

alter table lessons
add column lesson_group enum("km", "web", "peds", "mob", "mechanics", "constructors") default("peds");
delimiter //
create function get_group_count(groupp enum("km", "web", "peds", "mob", "mechanics", "constructors"))
returns int
begin
	return (select count(st_id) from studs where st_speciality = groupp);
end//
delimiter ;


delimiter //
create function get_group_lessons(groupp enum("km", "web", "peds", "mob", "mechanics", "constructors"))
returns int
begin
	return (select count(lesson_id) from studs where lesson_group = groupp);
end//
delimiter ;

select count(st_id) from lesson_student where "ped" = (select st_speciality from studs where st_id = lesson_student.st_id);
delimiter //
create procedure get_passed_lessons(in groupp enum("km", "web", "peds", "mob", "mechanics", "constructors"))
begin
	declare a int;
    select count(st_id) into a from lesson_student where "ped" = (select st_speciality from studs where st_id = lesson_student.st_id);
	select a/get_group_lessons(groupp)/get_group_count(groupp); 
end//
delimiter ;

/*4.8*/

delimiter //
create procedure get_teachers()
begin
	declare a, b varchar(50);
    select sub_teacher into a from subjects order by get_avg_mark(sub_teacher) desc limit 1;
    select sub_teacher into b from subjects order by get_avg_mark(sub_teacher) asc limit 1;
    select a as the_most_loyal_teacher, b as the_most_disloyal_teacher;
end//
delimiter ;

/*4.9*/

alter table studs
add column st_birthday datetime default("2003-03-11");


delimiter //
create procedure get_bonuses(in start_date date, in end_date date)
begin
	update studs
    set st_scholarship = st_scholarship + datediff(st_birthday, start_date)
    where st_birthday between start_date and end_date;
end//
delimiter ;

drop procedure get_bonuses;
select * from studs;
call get_bonuses("2003-02-11", "2003-04-11");
/*4.10*/

delimiter //
create procedure get_bonuses_special(in start_date date, in end_date date, in special_date date)
begin
	update studs
    set st_scholarship = st_scholarship + if(special_date != st_birthdate, datediff(st_birthday, start_date), 3*datediff(st_birthday, start_date))
    where st_birthday between start_date and end_date;
end//
delimiter ;

/*4.11*/

delimiter //
create procedure prognosis(in stud_id int, in teach_name varchar(50))
begin 
	select (get_avg_mark(teach_name) + st_scholarship % 10) / 2 from studs where st_id = stud_id;
end//
delimiter ;
drop procedure prognosis;
call prognosis(1, "Gromak");

/*5.1*/

select count(credit_id) from credits where ref_st_id = (select st_id from studs where st_speciality = "peds" limit 1);
delimiter //

/*dop*/
create function get_number_of_exams_and_credits(group1 varchar(50))
returns int
begin
	declare ans int default 0;
	set ans = ans + (select count(credit_id) from credits where ref_st_id = (select st_id from studs where st_speciality = group1 limit 1))
    + (select count(exam_id) from exams where ref_st_id = (select st_id from studs where st_speciality = group1 limit 1));
    return ans;
end//
delimiter ;

select get_number_of_exams_and_credits("km");
delimiter ;
alter table studs
add column st_pass int default 0;
 
drop trigger give_money;
delimiter //
create trigger give_money
	after insert 
	on studs for each row
	begin
		if new.st_value > 6 and new.st_pass = get_number_of_exams_and_credits(new.st_speciality) then
			update studs
            set st_value = 1.4*st_value
            where st_id = new.st_id;
		end if;
    end//
delimiter ;-- переделать! в конце сесиис

/*5.2*/

delimiter //
create trigger decrease_payment
	after insert 
	on studs for each row
	begin
		if new.st_value > 6 then
			update studs
            set st_pay_value = 0.6*st_value
            where st_id = new.st_id;
		end if;
    end//
delimiter ;

/*5.3*/

create table reminders
(
	reminder_id int primary key auto_increment,
    reminder_message varchar(50) not null
);

delimiter //
create trigger test1  
	after insert 
	on lesson_student for each row
	begin
		if new.lesson_id = 1 then
			insert into reminders(reminder_message)
            values
            ("Поставить посещение студенту");
		end if;
    end//
delimiter ;

insert lessons(lesson_sub, lesson_date, lesson_group)
values
(1, "2020-11-11", "peds");
insert into lesson_student
values
(1,1);

select * from reminders;

/*5.4*/

alter table studs
add column st_course int default(2);

delimiter //
create trigger next_course
	after insert 
	on studs for each row
	begin
		if new.st_value > 4 then
			update studs
            set st_course = st_course + 1
            where st_id = new.st_id;
		end if;
    end//
delimiter ;


/*5.5*/

alter table studs
add column st_fail bool default(false);

delimiter //
create trigger set_fail
	after insert 
	on studs for each row
	begin
		if new.st_value < 4 then
			update studs
            set st_fail = true
            where st_id = new.st_id;
		end if;
    end//
delimiter ;


/*5.6*/

delimiter //
create trigger check_fail
	after insert 
	on studs for each row
	begin
		if new.st_fail = true then
			update studs
            set st_course = st_course - 1
            where st_id = new.st_id;
		end if;
    end//
delimiter ;-- вероятностная оценка!


/*dop*/
delimiter //
create function get_future_mark1(teach_id int, stud_id int)
returns float
begin
	declare ans, temp float default 0;
    declare i int default 1;
    select st_value into ans from studs where st_id = stud_id;
	my_loop : loop
		if i = 11 then leave my_loop;
        end if;
        set temp = i*(select count(exam_mark) from exams where ref_teacher_id = teach_id and exam_mark = i)/(select count(exam_mark) from exams where ref_teacher_id = teach_id) + temp;
        set i = i + 1;
    end loop my_loop;
    return (ans + temp)/2;
end//
delimiter ;


drop function get_future_mark;
select get_future_mark1(1, 1);

alter table exams 
add column ref_teacher_id int,
add constraint cn23 foreign key (ref_teacher_id) references teachers(teacher_id);

update exams 
set ref_teacher_id = (select teacher_id from teachers where teacher_surname = (select sub_teacher from subjects where sub_id = ref_sub_id)); 


use mmf2021;