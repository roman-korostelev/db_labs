set global log_bin_trust_function_creators = 1;
set SQL_SAFE_UPDATES = 0;
use bankDB;

/*задание 1*/


insert into person(person_name, person_surname, person_address, person_status, person_date)
values
("Roman", "Korostelev", "ul. Oktyabrskaya 10a", "non-worker", "2021-12-22"),
("Valeriy", "Kursov", "ul. Nezavisimosti 4", "worker", "2021-12-22");

create table person (
	person_id int auto_increment primary key,
    person_name varchar(30) not null,
    person_surname varchar(30) not null,
    person_address varchar(50) not null,
    person_status enum('worker', 'non-worker'),
    person_date date not null
);

drop table appointment;
drop table account;
insert into `account`
values
(aes_encrypt("3132332232329099", 'pas'), "debit", 100, "2021-12-22", 1),
(aes_encrypt("3132332232329090", 'pas'), "debit", 1000, "2021-12-22", 2);


create table `account` (
	acc_number varbinary(50) primary key,
    acc_type enum('credit', 'debit'),
    acc_balance double,
    acc_start_date datetime not null,
    acc_owner int,
    constraint cn1 foreign key (acc_owner) references person(person_id)
);

create table operations (
	op_id int auto_increment primary key,
    op_type enum('put', 'get', 'transfer')
);

insert into operations(op_type)
values
('put'),
('get'),
('transfer');

create table appointment (
	app_id int auto_increment primary key,
    app_op int,
    app_sender varbinary(50),
    app_recipient varbinary(50),
    app_time datetime not null,
    app_value double not null,
    app_contr_number double not null,
    constraint cn2 foreign key (app_sender) references `account`(acc_number),
    constraint cn3 foreign key (app_op) references operations(op_id)
);


/*задание 1.1*/

delimiter //
create function get_control_number(num varchar(50))
returns int
begin
	declare ans int default 0;
    declare i int default 1;
    loop1 : LOOP
		if mod(i, 2) = mod(length(num) - 1, 2)
        then
		set ans = ans + if(substring(num, i, 1)*2 > 9, substring(num, i, 1)*2 - 9, substring(num, i, 1)*2);
        else 
        set ans = ans + substring(num, i, 1);
        end if;
        set i = i + 1;
        if i = length(num)  then leave loop1;
        end if;
    end loop loop1;
	return mod(ans, 10);
end//
delimiter ;

select cast(aes_decrypt(acc_number, 'pas') as char), account.* from account;

call transfer('3132332232329099','3132332232329090', 'dsad');

drop function get_control_number;
drop procedure put;
use bankDB;

drop procedure transfer;

delimiter //
create procedure transfer(in sender varchar(50), in rec varchar(50), in sum1 varchar(50))
begin
	start transaction;
    if check_all_digit(sum1) = 1 then 
    update `account`
    set acc_balance = acc_balance-sum1
    where aes_decrypt(acc_number, 'pas')  = sender and acc_balance >= sum1;
    if row_count()>0 and sender != rec and sum1 > 0 then 
		update `account`
        set acc_balance=acc_balance+sum1
        where aes_decrypt(acc_number, 'pas') = rec;
        if row_count()>0
			then
            insert into appointment
            (app_op, app_sender, app_recipient, app_time, app_value, app_contr_number)
            values
            (3, aes_encrypt(sender, 'pas'), aes_encrypt(rec, 'pas'), now(), sum1, get_control_number(rec) + get_control_number(sender));
            commit;
	else rollback;
end if;
else rollback;
end if;
end if;
end//
delimiter ;

use bankDB;
delimiter //
create function check_all_digit(str varchar(50))
returns bool
begin
	return str REGEXP '^[[:digit:]]+$';
end//
delimiter ;

select get_control_number("5578843370294880");
/*задание 1.2*/


delimiter //
create procedure put(in rec varchar(50), in sum1 int)
begin
	start transaction;
    update `account`
    set acc_balance=acc_balance+sum1
    where aes_decrypt(acc_number, 'pas') =rec;
    if row_count()>0 and sum1 > 0 
		then 
        insert into appointment
        (app_op, app_recipient, app_time, app_value, app_contr_number)
        values
        (1, aes_encrypt(rec, 'pas'), now(), sum1, get_control_number(rec));
	else rollback;
    end if;
end//
delimiter ;

delimiter //
create procedure get1(in sender varchar(50), in sum1 int)
begin
	start transaction;
    update `account`
    set acc_balance=acc_balance-sum1 
    where aes_decrypt(acc_number, 'pas') = sender and acc_balance >= sum1;
    if row_count()>0 and sum1 > 0 
		then 
        insert into appointment
        (app_op, app_sender, app_time, app_value, app_contr_number)
        values
        (2, aes_encrypt(sender, 'pas'), now(), sum1, get_control_number(sender));
	else rollback;
    end if;
end//
delimiter ;

alter table appointment
modify column app_sender varchar(50) default("cash"),
modify column app_recipient varchar(50) default("cash");

/*задание 1.3*/
create database bankDB1;
use bankDB1;


delimiter //
create procedure transfer(in sender varchar(50), in rec varchar(50), in sum1 double)
begin
	start transaction;
    update `account`
    set acc_balance = acc_balance-sum1
    where acc_number=sender;
    if row_count()>0  then
		update `account`
        set acc_balance=acc_balance+sum1
        where acc_number=rec;
        if row_count()>0
			then
            insert into appointment
            (app_op, app_sender, app_recipient, app_time, app_value, app_contr_number)
            values
            (3, sender, rec, time1, sum1, get_control_number(rec) + get_control_number(sender));
            commit;
	else rollback;
end if;
else rollback;
end if;
end//
delimiter ;


delimiter //
create procedure put(in rec varchar(50), in sum1 int)
begin
	start transaction;
    update `account`
    set acc_balance=acc_balance+sum1
    where acc_number=rec;
    if row_count()>0
		then 
        insert into appointment
        (app_op, app_recipient, app_time, app_value, app_contr_number)
        values
        (1, rec, now(), sum1, get_control_number(rec));
	else rollback;
    end if;
end//
delimiter ;

delimiter //
create procedure get1(in sender varchar(50), in sum1 int)
begin
	start transaction;
    update `account`
    set acc_balance=acc_balance-sum1 
    where acc_number=rec;
    if row_count()>0
		then 
        insert into appointment
        (app_op, app_sender, app_time, app_value, app_contr_number)
        values
        (2, sender, now(), sum1, get_control_number(sender));
	else rollback;
    end if;
end//
delimiter ;

alter table appointment
modify column app_sender varchar(50) default("cash"),
modify column app_recipient varchar(50) default("cash");

delimiter //
create trigger test 
before insert on appointment
for each row
begin
	if new.app_sender = new.app_recipient 
    or new.app_contr_number != 0 
    or if(new.app_sender != "cash" and new.app_value > (select acc_balance from `account` where acc_number = new.app_sender), 0, 1) = 0
    or new.app_contr_number != 0
    then 
    SIGNAL SQLSTATE '45000'   
       SET MESSAGE_TEXT = 'Ошибочка вышла(';
	end if;
end//
delimiter ;

/*1.4*/

use bankDB;
drop table account;


select * from account;
drop procedure transfer;
call transfer("3132332232329090", "3132332232329099", -150);

select * from account;


/*1.5*/

delimiter // 
create function get_acc() returns varbinary(50)
begin
return @acc_number;
end//

create function get_start() returns date
begin
return @start_date;
end//

create function get_end() returns date
begin
return @end_date;
end//
delimiter ;

set @acc_number = aes_encrypt("3132332232329099", 'pas');
set @start_date = cast("2021-12-10" as date);
set @end_date = cast("2021-12-30" as date);

delimiter //
create procedure get_history()
begin
create or replace view history_acc
as select (select op_type from operations where op_id = app_op) as op_type, app_time, app_value*if(app_op = 1 or app_recipient = get_acc(), 1, -1) as `value` 
from appointment 
where (app_time between get_start() and get_end()) and (app_sender = get_acc() or app_recipient = get_acc());
select * from history_acc;
end//	
delimiter ;

drop procedure get_history;
call get_history();


/*1.6*/

create table credit (
	credit_id int auto_increment primary key,
    credit_value double,
    credit_term int,
    credit_percent double default 0.002,
    credit_payment double default(credit_value*(1 + credit_percent*credit_term)/credit_term),
    acc_number varbinary(50),
    constraint cn123 foreign key (acc_number) references account(acc_number)
);

drop table credit;
insert into credit(credit_value, credit_term, acc_number)
values
(1000, 12, aes_encrypt("3132332232329099", 'pas'));

select * from credit;

/*1.7*/

create table credit_payment
(
	credit_id int, 
    payment_time date default(now()),
    payment_value double not null
);

delimiter //
create procedure take_credit(in acc_num varbinary(50), in val double, in term int, in percent double)
begin
	insert into credit(credit_value, credit_term, acc_number, credit_percent)
	values
    (val, term, acc_num, percent);
    call put(acc_num, val);
end//
delimiter ;

delimiter //
create procedure make_payment(in cr_id int, in val double)
begin
	declare acc_num varbinary(50);
    select acc_number into acc_num from credit where credit_id = cr_id;
    call get1(acc_num, val);
    update credit
    set credit_value = credit_value - val
    where credit_id = cr_id;
end// 
delimiter ;

delimiter //
create trigger check_credit
after update on credit
for each row 
begin
	if new.credit_value <= 0 then 
    delete from credit where credit_id = new.credit_id;
    end if;
end//
delimiter ;

/*2*/

create database trading;
use trading;

create table warehouse
(
	warehouse_id int primary key auto_increment,
    warehouse_adress varchar(50)
);

insert into warehouse
values
(1, "ul. Nezavisimosti 4");

create table product
(
	product_id int primary key auto_increment,
    product_name varchar(50) not null,
    product_price float not null,
    pruduct_quantity int default 10,
    ref_market int not null,
    foreign key (ref_market) references market(market_id)
);

insert into product
values
(1, "peresdacha", 0.99, 10, 1);

create table market
(
	market_id int primary key auto_increment,
    market_adress varchar(50) not null,
    ref_warehouse int not null,
    foreign key (ref_warehouse) references warehouse(warehouse_id)
);

insert into market
values
(1, "ul. Nezavisimosti 4", 1);

create table sellers
(
	sellers_id int primary key auto_increment,
    seller_name varchar(50) not null,
    seller_market int not null,
    foreign key (seller_market) references market(market_id)
);

insert into sellers
values
(1, "Databases", 1);

create table customer
(
	customer_id int primary key auto_increment,
    customer_name varchar(50) not null,
    customer_bonus double default 0,
    customer_buys int default 0,
    customer_money double default 10
);


insert into customer(customer_id, customer_name)
values
(1, "Roman Korostelev");

create table sales
(
	sales_id int primary key auto_increment,
    quantity int not null,
    product_id int not null,
    seller_id int not null,
    customer_id int not null,
	
    foreign key (product_id) references product(product_id),
    foreign key (seller_id) references sellers(sellers_id),
    foreign key (customer_id) references customer(customer_id)
);

/*2.1*/

delimiter //
create procedure buy(in cust_id int, in seller_id int, in product_id int, in qua int)
begin
	start transaction;
	insert into sales(quantity, product_id, seller_id, customer_id)
    values
    (qua, product_id, seller_id, cust_id);
	update product
    set pruduct_quantity = pruduct_quantity - qua
    where product.product_id = product_id and pruduct_quantity - qua >= 0;
    if row_count() > 0 then
		update customer
        set 
        customer_buys = customer_buys + 1,
        customer_money = customer_money - (select product_price from product where product.product_id = product_id)*qua*(1 - customer_bonus)
        where customer.customer_id = customer_id;
	else rollback;
	end if;
end//
delimiter ;


/*2.2*/

delimiter //
create trigger test_quantity
before update on product
for each row
begin
	if new.pruduct_quantity = 0 then
    set new.pruduct_quantity = 10;
    end if;
end //
delimiter ;

/*2.3*/

delimiter //
create trigger give_bonus
before update on customer
for each row
begin
	set new.customer_bonus = 0.01*(new.customer_buys div 10);
end//
delimiter ;

/*3.1*/

use greenpeace;

set global validate_password.policy=LOW;
SELECT user,host,plugin FROM mysql.user;
create user admin_user@'localhost' identified by "AaBdsd2dadsa_";
create user base_user1@'localhost' identified by '12345678';
grant select on greenpeace.* to admin_user;
grant update on greenpeace.* to base_user;

/*3.2*/

delimiter //
create procedure get_participant(in act_id int)
begin
	start transaction;
    insert into actions_participants
    values
    (act_id, floor(rand((select max(participant_id) from structure))*10));
    if row_count = 0 then rollback;
    end if;
end //
delimiter ;

delimiter //
create procedure get_action(in part_id int)
begin
	start transaction;
    insert into actions_participants
    values
    (part_id, floor(rand((select max(action_id) from actions))*10));
    if row_count = 0 then rollback;
    end if;
end //
delimiter ;


/*3.3*/

create index myInd on actions(action_name(2));

/*3.4*/

alter table actions 
modify action_name varbinary(50);

update actions 
set action_name = aes_encrypt(action_name, "bd");

/*4*/

create database litDB;
use litDB;

create table quotes (
	quote_id int auto_increment primary key,
    author varchar(50) not null,
    quote_text text not null
);

/* 4.1 */
insert into quotes
	(author, quote_text)
		values
	('Слава КПСС', 'Ну так что, стадионный рэпер? Куда ты идешь? Ты не рубишь на запад окно, ты, блядь, гамельнский крысолов, ты всех тащишь на самое дно.'),
	('Слава КПСС', 'Я помню чувство, блядь, когда твои фанаты на всю хату включили альбом, будто я ассенизатор, которому за год выдали всю зарплату говном.'),
	('Слава КПСС', 'Че, так болел за Россию, что на нервах терял ганглии? Но пока тут проходили митинги, где ты сидел? В Англии!'),
	('Слава КПСС', 'Здесь жили Достоевский, Гоголь и Хан Замай. Но я считаю, в наше время только конченый пидор может называть себя поэтом. Если это не Хан Замай, конечно!'),
	('Слава КПСС', 'На хуй тебя и на хуй Versus, вместе с вашей послушной толпой, лучше я сдохну ебучим ноунеймом, чем прославлюсь и стану тобой.'),
	('Слава КПСС', 'Если рэпер не читает про то, что у него самый огромный хуй в этой вселенной, я его рэпером не считаю.'),
	('Эрих Мария Ремарк', 'Нет, — быстро сказал он. — Только не это. Остаться друзьями? Развести огородик на остывшей лаве угасших чувств? Нет, это не для нас с тобой. Так бывает только после маленьких интрижек, да и то получается довольно фальшиво. Любовь не пятнают дружбой. Конец есть конец'),
	('Туве Янссон', 'Можно лежать на мосту и смотреть, как течет вода. Или бегать, или бродить по болоту в красных сапожках, или же свернуться клубочком и слушать, как дождь стучит по крыше. Быть счастливой очень легко.'),
	('Франц Кафка', 'Радости этой жизни суть не ее радости, а наш страх пред восхождением в высшую жизнь; муки этой жизни суть не ее муки, а наше самобичевание из-за этого страха.'),
	('Франц Кафка', 'Зло бывает порой в руке, как орудие; узнанное или неузнанное, оно, не переча, позволяет отложить себя в сторону, если есть воля на то.'),
	('Франц Кафка', 'Леопарды врываются в храм и выпивают до дна содержимое жертвенных сосудов; это повторяется снова и снова, и в конце концов это может быть предусмотрено и становится частью обряда.'),
	('Франц Кафка', 'Кто в мире любит своего ближнего, совершает не большую и не меньшую несправедливость, чем тот, кто любит в мире себя самого. Остается только вопрос, возможно ли первое.'),
	('Франц Кафка', 'В этом месте я еще ни разу не был: иначе дышится, ослепительнее, чем солнце, сияет с ним рядом звезда.'),
	('Франц Кафка', 'Во избежание словесной ошибки: что следует деятельно разрушить, то надо сперва крепко схватить; что крошится, то крошится, но разрушить это нельзя.'),
	('Пушкин', 'Я, конечно, презираю отечество мое с головы до ног — но мне досадно, если иностранец разделяет со мной это чувство.'),
	('Пушкин', 'Я далёк от того, чтобы восхищаться всем, что вижу вокруг себя; как писатель я огорчён…, многое мне претит, но клянусь вам моей честью – ни за что в мире я не хотел бы переменить Родину, или иметь иную историю, чем история наших предков, как её нам дал Бог.'),
	('Пушкин', 'Воспитатель должен себя так вести, что6ы каждое движение его воспитывало, и всегда должен знать, чего он хочет в данный момент и чего он не хочет. Если воспитатель не знает этого, кого он может воспитывать?'),
	('Пушкин', 'Мысль! Великое слово! Что же и составляет величие человека, как не мысль! Да будет же она свободна, как должен быть свободен человек…'),
	('Пушкин', 'Говорят, что несчастие хорошая школа; может быть. Но счастие есть лучший университет. Оно довершает воспитание души, способной к доброму и прекрасному.'),
	('Пушкин', 'Толпа жадно читает исповеди, записи etc., потому что в подлости своей радуется унижению высокого, слабостям могущего. При открытии всякой мерзости она в восхищении. Он мал, как мы, он мерзок, как мы! Врете, подлецы: он и мал и мерзок не так, как вы, — иначе!'),
	('Пушкин', 'Никогда не делай долгов; лучше терпи нужду; поверь, она не так ужасна, как кажется, и, во всяком случае, она лучше неизбежности вдруг оказаться бесчестным или прослыть таковым.'),
	('Пушкин', 'Если средства или обстоятельства не позволяют тебе блистать, не старайся скрывать лишений; скорее избери другую крайность: цинизм своей резкостью импонирует суетному мнению света, между тем как мелочные ухищрения тщеславия делают человека смешным и достойным презрения.'),
	('Лермонтов', 'Моё завещание: положите камень; и – пускай на нём ничего не будет написано, если одного имени моего не довольно будет доставить ему бессмертие!'),
	('Лермонтов', 'Уважения заслуживают те люди, которые независимо от ситуации, времени и места, остаются такими же, какие они есть на самом деле.'),
	('Лермонтов', 'Стыдить лжеца, шутить над дураком И спорить с женщиной — все то же, Что черпать воду решетом От сих троих избавь нас, боже!'),
	('Лермонтов', 'Обида такая пилюля, которую не всякий с покойным лицом проглотить может; некоторые глотают, разжевав наперед; тут пилюля еще горче.'),
	('Лермонтов', 'Делись со мною тем, что знаешь, И благодарен буду я. Но душу ты мне предлагаешь На кой мне черт душа твоя!..'),
	('Лермонтов', 'Гений, прикованный к чиновничьему столу, должен умереть или сойти с ума, точно так же, как человек с могучим телосложением при сидячей жизни и скромном поведении умирает от апоплексического удара.'),
	('Лермонтов', 'Ужасно стариком быть без седин; Он равных не находит; за толпою Идет, хоть с ней не делится душою; Он меж людьми ни раб, ни властелин, И все, что чувствует, он чувствует один!'),
	('Толстой', 'Люди как реки: вода во всех одинакая и везде одна и та же, но каждая река бывает то узкая, то быстрая, то широкая, то тихая, то чистая, то холодная, то мутная, то теплая. Так и люди. Каждый человек носит в себе зачатки всех свойств людских и иногда проявляет одни, иногда другие и бывает часто совсем непохож на себя, оставаясь все между тем одним и самим собою.'),
	('Толстой', 'Нет того негодяя, который, поискав, не нашел бы негодяев в каком-нибудь отношении хуже себя и который поэтому не мог бы найти повода гордиться и быть довольным собой.'),
	('Толстой', 'Осуждение другого всегда неверно, потому что никто никогда не может знать того, что происходило и происходит в душе того, кого осуждаешь.'),
	('Толстой', 'Волей-неволей человек должен признать, что жизнь его не ограничивается его личностью от рождения и до смерти и что цель, сознаваемая им, есть цель достижимая и что в стремлении к ней — в сознании большей и большей своей греховности и в большем и большем осуществлении всей истины в своей жизни и в жизни мира и состоит и состояло и всегда будет состоять дело его жизни, неотделимой от жизни всего мира'),
	('Толстой', 'Толстое дерево началось с тонкого прута. Девятиэтажная башня началась с кладки малых кирпичей. Путешествие в тысячу верст начинается с одного шага. Будьте внимательны к своим мыслям — они начало поступков.'),
	('Толстой', 'Есть такие минуты, когда мужчина говорит женщине больше того, что ей следует знать о нем. Он сказал — и забыл. А она помнит…'),
	('Толстой', 'Одно из самых обычных заблуждений состоит в том, чтобы считать людей добрыми, злыми, глупыми, умными. Человек течет, и в нем есть все возможности: был глуп, стал умен, был зол, стал добр, и наоборот. В этом величие человека. И от этого нельзя судить человека. Какого? Ты осудил, а он уже другой. Нельзя и сказать: не люблю. Ты сказал, а оно другое..'),
	('Толстой', 'Я испытываю чувство уничтожения перед ней. Она так невозможно чиста и хороша и цельна для меня. Я не владею ею потому, что не смею, не чувствую себя достойным. Что-то мучает меня. Ревность к тому человеку, который стоил бы ее. Я не стою.'),
	('Толстой', 'Мы часто повторяем, что о человеке судят по его делам, но забываем иногда, что слово тоже поступок. Речь человека — зеркало его самого. Всё фальшивое и лживое, пошлое и вульгарное, как бы мы ни пытались скрыть это от других, вся пустота, чёрствость или грубость прорываются в речи с такой же силой и очевидностью, с какой проявляются искренность и благородство, глубина и тонкость мыслей и чувств.'),
	('Бродский', 'Для того, чтоб понять по-настоящему, что есть та или иная страна или то или иное место, туда надо ехать зимой, конечно. Потому что зимой жизнь более реальна, больше диктуется необходимостью. Зимой контуры чужой жизни более отчетливы. Для путешественника это — бонус.'),
	('Бродский', 'Не выходи из комнаты; считай, что тебя продуло. Что интересней на свете стены и стула? Зачем выходить оттуда, куда вернешься вечером таким же, каким ты был, тем более — изувеченным?'),
	('Бродский', 'Навсегда расстаёмся с тобой, дружок. Нарисуй на бумаге простой кружок. Это буду я: ничего внутри. Посмотри на него — и потом сотри.'),
	('Бродский', 'Старайтесь быть добрыми к своим родителям. Если вам необходимо бунтовать, бунтуйте против тех, кто не столь легко раним. Родители — слишком близкая мишень; дистанция такова, что вы не можете промахнуться.'),
	('Бродский', 'Всячески избегайте приписывать себе статус жертвы. Из всех частей тела наиболее бдительно следите за вашим указательным пальцем, ибо он жаждет обличать. Указующий перст есть признак жертвы — в противоположность поднятым в знаке Victoria среднему и указательному пальцам, он является синонимом капитуляции. Каким бы отвратительным ни было ваше положение, старайтесь не винить в этом внешние силы: историю, государство, начальство, расу, родителей, фазу луны, детство, несвоевременную высадку на горшок и т. д. Меню обширное и скучное, и сами его обширность и скука достаточно оскорбительны, чтобы восстановить разум против пользования им. В момент, когда вы возлагаете вину на что-то, вы подрываете собственную решимость что-нибудь изменить.'),
	('Бродский', 'Вот, смотрите, кот. Коту совершенно наплевать, существует ли общество «Память». Или отдел идеологии при ЦК. Так же, впрочем, ему безразличен президент США, его наличие или отсутствие. Чем я хуже этого кота?'),
	('Бродский', 'Старайтесь не обращать внимания на тех, кто попытается сделать вашу жизнь несчастной. Таких будет много — как в официальной должности, так и самоназначенных. Терпите их, если вы не можете их избежать, но как только вы избавитесь от них, забудьте о них немедленно.'),
	('Бродский', 'Приезжай, попьём вина, закусим хлебом. Или сливами. Расскажешь мне известья. Постелю тебе в саду под чистым небом и скажу, как называются созвездья.'),
	('Бродский', 'Самая надежная защита против зла состоит в крайнем индивидуализме, оригинальности мышления, причудливости, даже — если хотите — эксцентричности. То есть в чем-то таком, что невозможно подделать, сыграть, имитировать; в том, что не под силу даже прожженному мошеннику.'),
	('Бродский', 'Жизнь — так, как она есть, — не борьба между Плохим и Хорошим, но между Плохим и Ужасным. И человеческий выбор на сегодняшний день лежит не между Добром и Злом, а скорее между Злом и Ужасом. Человеческая задача сегодня сводится к тому, чтобы остаться добрым в царстве Зла, а не стать самому его, Зла, носителем.'),
	('Бродский', 'Люди вышли из того возраста, когда прав был сильный. Для этого на свете слишком много слабых. Единственная правота — доброта. От зла, от гнева, от ненависти — пусть именуемых праведными — никто не выигрывает. Мы все приговорены к одному и тому же: к смерти. Умру я, пишущий эти строки, умрете Вы, их читающий. Останутся наши дела, но и они подвергнутся разрушению. Поэтому никто не должен мешать друг другу делать его дело. Условия существования слишком тяжелы, чтобы их еще усложнять.'),
	('Бродский', 'Старайтесь быть добрыми к своим родителям… старайтесь не восставать против них, ибо, по всей вероятности, они умрут раньше вас, так что вы можете избавить себя по крайней мере от этого источника вины, если не горя.'),
	('Паша Техник', 'Благословен час, когда встречаем поэта. Поэт брат дервишу. Он не имеет ни отечества, ни благ земных; и между тем как мы, бедные, заботимся о славе, о власти, о сокровищах, он стоит наравне с властелинами земли и ему поклоняются.');
	
/* 4.2 */
create fulltext index key_word on quotes(quote_text);

select *, match(quote_text) against ('*час*' in boolean mode) from quotes
where match(quote_text) against ('*час*' in boolean mode);

/*6*/

 CREATE TABLE scores (
    name VARCHAR(20) PRIMARY KEY,
    score INT NOT NULL
);

INSERT INTO
	scores(name, score)
VALUES
	('Smith',81),
	('Jones',55),
	('Williams',55),
	('Taylor',62),
	('Brown',62),
	('Davies',84),
	('Evans',87),
	('Wilson',72),
	('Thomas',72),
	('Johnson',100);
    
SELECT
	name,
    score,
    ROW_NUMBER() OVER (ORDER BY score) row_num,
    CUME_DIST() OVER (ORDER BY score) cume_dist_val,
    DENSE_RANK() OVER (order by score) dense_rank_,
    first_value(score) OVER (order by score) first_value_,
    lag(1) OVER (order by score) lag_,
    last_value(score) OVER (order by score) last_value_,
    lead(3) OVER (order by score) lead_,
    nth_value(1,1) OVER (order by score) nth,
    ntile(3) OVER (order by score) ntile_,
    percent_rank() OVER (order by score) percent_rank_,
    rank() OVER (order by score) percent_rank_
FROM
	scores;


