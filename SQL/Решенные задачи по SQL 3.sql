--1.  Выведите в одном репорте информацию о суммах з/п групп, объединённых по id менеджера, по job_id, по id департамента. Репорт должен содержать 4 столбца: id менеджера, job_id, id департамента, суммированная з/п.
select manager_id, to_char(null) job_id, to_number(null) department_id, sum(salary)
from employees
group by manager_id
union
select to_number(null), job_id, to_number(null) , sum(salary)
from employees
group by job_id
union
select to_number(null), to_char(null), department_id, sum(salary)
from employees
group by department_id;

--2. Выведите id тех департаментов, где работает менеджер № 100 и не работают менеджеры № 145, 201
select department_id  
from employees
where manager_id=100
minus
select department_id  
from employees
where manager_id in (145, 201);

--3. Используя SET операторы и не используя логические операторы, выведите уникальную информацию о именах, фамилиях и з/п сотрудников, второй символ в именах которых буква «а», и фамилия содержит букву «s» вне зависимости от регистра. Отсортируйте результат по з/п по убыванию.
select first_name, last_name, salary 
from employees
where first_name like '_a%'
INTERSECT
select first_name, last_name, salary
from employees
where lower(first_name) like '%s%'
order by salary desc;

--4.  Используя SET операторы и не используя логические операторы, выведите информацию о id локаций, почтовом коде и городе для локаций, которые находятся в Италии или Германии. А также для локаций, почтовый код которых содержит цифру «9».
select location_id, postal_code, city
from locations
where country_id in (select country_id from countries
                    where country_name in ('Italy', 'Germany'))
union all
select location_id, postal_code, city
from locations 
where postal_code like '%9%';

--5.  Используя SET операторы и не используя логические операторы, выведите всю уникальную информацию для стран, длина имён которых больше 8 символов. А также для стран, которые находятся не в европейском регионе. Столбцы аутпута должны называться id, country, region. Аутпут отсортируйте по названию стран по убывающей
select country_id id, country_name country, region_id region
from countries
where length(country_name)>8
union
select country_id, country_name, region_id
from countries
where region_id != (select region_id from regions
                     where region_name = 'Europe')
order by country desc;

--6. Перепишите и запустите данный statemenet для создания таблицы locations2, которая будет содержать такие же столбцы, что и locations:
CREATE TABLE locations2 AS (SELECT * FROM locations WHERE 1=2);

--7.  Добавьте в таблицу locations2 2 строки с информацией о id локации, адресе, городе, id страны. Пусть данные строки относятся к стране Италия.
insert into locations2 (location_id, street_address, city, country_id)
values (1, 'test_address', 'italy_cities', 'IT');

insert into locations2 (location_id, street_address, city, country_id)
values (2, 'test_address2', 'milan', 'IT');
--8. Совершите commit
commit;

--9.  Добавьте в таблицу locations2 ещё 2 строки, не используя перечисления имён столбцов, в которые заносится информация. Пусть данные строки относятся к стране Франция. При написании значений, где возможно, используйте функции.
insert into locations2
values (3, initcap('qpefkg'), '999-888-666', initcap('paris'), 'Test province', upper('fr'));

insert into locations2
values (4, initcap('Parmentsl'), '999-888-666', initcap('mexico'), 'Testing', upper('fr'));
--10. Совершите commit
commit;

--11.  Добавьте в таблицу locations2 строки из таблицы locations, в которых длина значения столбца state_province больше 9
insert into locations2 (location_id, street_address, postal_code, city, state_province, country_id)
(select location_id, street_address, postal_code, city, state_province, country_id
from locations
where length(state_province) >9);

--12. Совершите commit
commit;

--13.  Перепишите и запустите данный statemenet для создания таблицы locations4europe, которая будет содержать такие же столбцы, что и locations:
CREATE TABLE locations4europe AS (SELECT * FROM locations WHERE 1=2);

--14.  Одним statement-ом добавьте в таблицу locations2 всю информациюдля всех строк из таблицы locations, а в таблицу locations4europeдобавьте информацию о id локации, адресе, городе, id страны только для тех строк из таблицы locations, где города находятся в Европе. 
insert ALL
when 1=1 then
into locations2
values (location_id, street_address, postal_code, city, state_province, country_id)
when country_id in (select country_id from countries where region_id=1) then
into locations4europe (location_id, street_address, city, country_id)
values (location_id, street_address, city, country_id)
select * from locations;

--15. Совершите commit
commit;

--16.  В таблице locations2 измените почтовый код на любое значение в тех строках, где сейчас нет информации о почтовом коде.
update locations2
set postal_code= 'test_code'
where postal_code is null;

--17. Совершите rollback.--
rollback;

--18.  В таблице locations2 измените почтовый код в тех строках, где сейчас нет информации о почтовом коде. Новое значение должно быть кодом из таблицы locations для строки с id 2600.

update locations2
set postal_code= (select postal_code from locations where location_id=2600)
where postal_code is null;

--19. Совершите commit
commit;

--20.  Удалите строки из таблицы locations2, где id страны «IT».
delete from locations2
where country_id = 'IT';

--21.  Создайте первый savepoint.
savepoint  ggg1;

--22.  В таблице locations2 измените адрес в тех строках, где id локации больше 2500. Новое значение должно быть «Sezam st. 18»
update locations2 set street_address = 'Sezam st. 18'
where location_id>2500;

--23.  Создайте второй savepoint.
savepoint ggg2;

--24.  Удалите строки из таблицы locations2, где адрес равен «Sezam st. 18».
delete from locations2 where street_address = 'Sezam st. 18';

--25.  Откатите изменения до первого savepoint.
rollback to savepoint ggg1;

--26 Совершите commit
commit;

--27.  Создать таблицу friends с помощью subquery так, чтобы она после создания содержала значения следующих столбцов из таблицы employees: employee_id, first_name, last_name для тех строк, где имеются комиссионные. Столбцы в таблице friends должны называться id, name, surname .
create table friends as 
select employee_id, first_name name, last_name surname
from employees
where commission_pct is not null;

--28. Добавить в таблицу friends новый столбец email .
alter table friends
add (email varchar (25));

--29. Изменить столбец email так, чтобы его значение по умолчанию было  «no email».
alter table friends
modify (email varchar (25) default 'no email');

--30. Изменить название столбца с id на friends_id .
alter table friends
rename column employee_id to friend_id;


--31. Удалить таблицу friends
drop table friends;

--32. Создать таблицу friends со следующими столбцами: id, name, surname, email, salary, city, birthday. У столбцов salary и birthday должны быть значения по умолчанию.
create table frineds (
id int, 
name varchar(25),
surname varchar(25),
email varchar(25),
salary number  (9,3) default 10000,
city varchar(25),
birthday date default to_date ('15-JUN-1999', 'DD-MON-YYYY'));

--33. Добавить 1 строку в таблицу friends со всеми значениями.
insert into frineds 
values (1, 'kekeke', 'kekekelov', 'kekekek@ehflad.com', 1000, 'moscow', to_date('19-JUN-1999', 'DD-MON-YYYY'));

--34. Добавить 1 строку в таблицу friends со всеми значениями кроме salary и birthday.
insert into frineds (id, name, surname, email, city) 
values (2, 'memmem', 'mememelov', 'asddghg@asdazzd.com', 'moscow');

--35. Совершите commit
commit;

--36. Удалить столбец salary.
alter table friends 
drop column salary;

--37. Сделать столбец email неиспользуемым (unused).
alter table friends 
set unused column email;

--38. Сделать столбец birthday неиспользуемым (unused).
alter table friends 
set unused column birthday;


--39. Удалить из таблицы friends неиспользуемые столбцы
alter table friends 
drop unused columns;

--40. Сделать таблицу friends пригодной только для чтения.
alter table friends read only;

--41. Проверить предыдущее действие любой DML командой.
insert into friends
values (3, 'dsfdsv', 'asdasd', 'asdsadas');

--42. Опустошить таблицу friends.
truncate table friends;

--43. Удалить таблицу friends
drop table friends;

--44. Создать таблицу address со следующими столбцами: id, country, city. При создании таблицы создайте на inline уровне unique constraint с именем ad_id_un на столбец id.
create table address (
id integer constraint id_un unique,
country varchar(25),
email varchar (25));

--45. Создать таблицу friends со следующими столбцами: id, name, email, address_id, birthday. При создании таблицы создайте на inline уровнеforeign key constraint на столбец address_id, который ссылается на столбец id из таблицы address, используйте опцию «on delete set null». Также при создании таблицы создайте на table уровне check constraint для проверки того, что длина имени должна быть больше 3-х.
create table friends (
id integer,
name varchar(25),
city varchar (25),
email varchar (25),
address_id integer references address(id) on delete set null,
birthday date,
check (length(name)>3)
);

--46.  Создайте уникальный индекс на столбец id из таблицы friends.
create unique index f_id_un on friends (id);

--47. С помощью функционала «add» команды «alter table» создайтеconstraint primary key с названием fr_id_pk на столбец id из таблицы friends.
alter table friends
add constraint fr_pk primary key (id);

--48. Создайте индекс с названием fr_email_in на столбец email из таблицы friends.
create unique index fr_em_in on friends (email);

--49. С помощью функционала «modify» команды «alter table» создайтеconstraint not null с названием fr_email_nn на столбец email из таблицы friends.
alter table friends
modify  (email constraint fr_email_nn not null);

--50. Удалите таблицу friends.
drop table friends;

--51. Удалите таблицу address.
drop table address;

--52. Создать таблицу emp1000 с помощью subquery так, чтобы она после создания содержала значения следующих столбцов из таблицы employees: first_name, last_name, salary, department_id. 
create table emp1000 as 
select first_name, last_name, salary, department_id from employees;


--53.  Создать view v1000 на основе select-а, который объединяет таблицы emp1000 и departments по столбцу department_id. View долженсодержать следующие столбцы: first_name, last_name, salary, department_name, city .
create force view  v1000 as 
select first_name, last_name, salary, department_name, e.city from emp1000 e
join departments d on (e.department_id=d.department_id);

--54.  Добавьте в таблицу emp1000 столбец city .
alter table emp1000
add (city varchar(25));

--55. Откомпилируйте view v1000
alter view v1000 compile;

--56.  Создайте синоним syn1000 для v1000
create synonym syn1000 for v1000;
 
--57.  Удалите v1000.
drop view v1000;

--58.  Удалите syn1000.
drop synonym syn1000;

--59.  Удалите emp1000.
drop table emp1000;

--60.  Создайте последовательность seq1000, которая начинается с 12, увеличивается на 4, имеет максимальное значение 200 и цикличность. 
create sequence seq1000
increment by 4 
start with 12 
maxvalue 200
cycle;

--61. Измените эту последовательность. Удалите максимальное значение и цикличность.
alter sequence seq1000
nomaxvalue
nocycle;

--62. .Добавьте 2 строки в таблицу employees, используя минимально возможное количество столбцов. Воспользуйтесь последовательностью seq1000 при добавлении значений в столбец employee_id.
insert into employees (employee_id, last_name, email, hire_date, job_id)
values (seq1000.nextval, 'norris', 'ASBCDE', sysdate, 'IT_PROG');

insert into employees (employee_id, last_name, email, hire_date, job_id)
values (seq1000.nextval, 'TESTTEST', 'ASBCDEFGG', sysdate, 'IT_PROG');

--63 Совершите commit
commit;
