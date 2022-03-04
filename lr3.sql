use world;

select city.Name, country.Continent, country.Region from (city inner join country on country.Code = city.CountryCode) as sub where country.Continent = "Europe"
/*variant 6*/

/*1 task*/

select country.Code, country.Name from country where country.Code = substr(upper(country.Name), 1, 3);
/*переделать*/
/*2 task*/

select * from country;
select count(country.Name) from country where GNP > (select GNP from country where Name = "Belarus") + (select GNP from country where Name = "Ukraine");
 
 
 /*3 task*/
 
 select * from country;
 
 set @position = 1;
 
 create or replace view city1
 (city, pos) as
 select Name, (row_number() over (order by Population desc)) as pos from city;
 
 /*разобраться что такое оконные функции в mysql и привести 10 примеров*/
/* CUME_DIST 	
DENSE_RANK 	
FIRST_VALUE 
LAG 	
LAST_VALUE 
LEAD 	
NTH_VALU
NTILE 	
PERCENT_RANK 	
RANK 
ROW_NUMBER*/
 select city from city1 where pos > 199 and pos < 2035;
 
 /*4 task*/
 
 select count(city), region from (select city.Name as city, country.Region as region from country 
 inner join city
 on city.CountryCode = country.Code
 where Continent = "Europe") as tb1
 group by region;
 
 /*5 task*/
 
 select count(Name), Continent  from country
 group by Continent;
 
 select sum(tb1.pop) > sum(tb2.pop) from (select sum(Population) as pop, Continent from country
where Continent = "Europe" or Continent = "Asia" or Continent = "North America" group by Continent  ) as tb1, (select sum(Population) as pop, Continent from country
where Continent = "South America" or Continent = "Africa" or Continent = "Oceania" group by Continent  ) as tb2;

/* вывести страны , в которых количество городов или кол-во языков является числом фибонначи*/
select * from countryLanguage;
use world;
select Name, @cities := (select count(ID) from city where CountryCode = Code),@langs := (select count(Language) from countryanguage where CountryCode = Code) from country
where ((pow(sqrt(5*@cities*@cities - 4),2) = 5*@cities*@cities - 4 and pow(sqrt(5*@cities*@cities + 4),2) = 5*@cities*@cities + 4) or (pow(sqrt(5*@langs*@langs - 4),2) = 5*@langs*@langs - 4 and pow(sqrt(5*@langs*@langs + 4),2) = 5*@langs*@langs + 4)) = 1; 

select tb1.pop/(select sum(Population) from country) *100, Continent  from  (select sum(Population) as pop, Continent from country
group by Continent) as tb1;
/* доделать*/

/*task 3*/

use bar;

/*a*/

select contract_id, product_id, sell_id, employee_id from contracts, products, sells, staff;

/*b*/

select sum(product_price), product_type from products group by product_type;

select count(sell_id) from sells group by barman_id;

select sum(sell_amount) from sells group by barman_id;

select avg(employee_years) from staff group by employee_position;

select count(employee_name) from staff group by employee_position;

/*c*/

select (select employee_name from staff where employee_id = sells.barman_id) from sells;

select (select employee_surname from staff where employee_id = sells.barman_id) from sells;

select (select employee_birthday from staff where employee_id = sells.barman_id) from sells;

/*d*/

(select  contracts.* from contracts 
inner join staff
on contract_id = employee_id
where staff.employee_position = "barman")
union
(select  contracts.* from contracts 
inner join staff
on contract_id = employee_id
where staff.employee_position  = "cook");

/*e*/

set SQL_SAFE_UPDATES = 0;
update contracts, staff
set contracts.salary = contracts.salary + staff.employee_years*10
where contracts.contract_id = staff.employee_id;


/*4*/

create or replace view barman
(name, surname, years) as 
select employee_name, employee_surname, employee_years
from staff
where employee_position = "barman";
/*апдейт на представлении*/
select * from barman;

create or replace view cook
(name, surname, years) as 
select employee_name, employee_surname, employee_years
from staff
where employee_position = "cook";

select * from cook;

select *, row_number() over() as row_num from city order by Population desc