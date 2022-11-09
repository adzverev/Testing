
--1.Вывести имена всех когда-либо обслуживаемых пассажиров авиакомпаний
SELECT name
from Passenger;

--2.Вывести названия всеx авиакомпаний
SELECT name
from company;

--3.Вывести все рейсы, совершенные из Москвы
SELECT *
from trip
where town_from = 'Moscow';

--4.Вывести имена людей, которые заканчиваются на "man"
SELECT name
from Passenger
where name like '%man';

--5.Вывести количество рейсов, совершенных на TU-134
SELECT count (*) as count
from trip
where plane = 'TU-134';

--6.Какие компании совершали перелеты на Boeing
SELECT distinct name
FROM company
  join trip on (company.id = Trip.company)
where plane = 'Boeing';

--7.Вывести все названия самолётов, на которых можно улететь в Москву (Moscow)
select DISTINCT plane
from Trip
where town_to = 'Moscow';

--8.В какие города можно улететь из Парижа (Paris) и сколько времени это займёт?
SELECT town_to,
  TIMEDIFF(time_in, time_out) as flight_time
from Trip
WHERE town_from = 'Paris';

--9.Какие компании организуют перелеты с Владивостока (Vladivostok)?
SELECT name
FROM Company c
  JOIN Trip t on (c.id = t.company)
where town_from = 'Vladivostok';

--10.Вывести вылеты, совершенные с 10 ч. по 14 ч. 1 января 1900 г.
SELECT *
from Trip
where time_out BETWEEN '1900-01-01T10:00:00.000Z' and '1900-01-01T14:00:00.000Z';

--11.Вывести пассажиров с самым длинным именем
SELECT name
from Passenger
where LENGTH(name) in (
    SELECT max(LENGTH(name))
    FROM Passenger);

--12.Вывести id и количество пассажиров для всех прошедших полётов
SELECT trip,
  count(*) as count
from Pass_in_trip
GROUP BY trip;


--13.Вывести имена людей, у которых есть полный тёзка среди пассажиров
SELECT name
FROM Passenger
GROUP by name
having count(name) > 1;

--14.В какие города летал Bruce Willis
SELECT town_to
from Passenger p
  join Pass_in_trip pr on (p.id = pr.Passenger)
  join Trip t ON (pr.trip = t.id)
where name = 'Bruce Willis';


--15.Во сколько Стив Мартин (Steve Martin) прилетел в Лондон (London)
SELECT time_in
from Trip
where id in (
    SELECT trip
    from Passenger p
      join Pass_in_trip pr on (p.id = pr.Passenger)
    WHERE name = 'Steve Martin'
  )
  and town_to = 'london';

--16.Вывести отсортированный по количеству перелетов (по убыванию) и имени (по возрастанию) список пассажиров, совершивших хотя бы 1 полет.
SELECT name,
  count(trip) as count
from Pass_in_trip pr
  join Passenger p on (pr.passenger = p.id)
group by name
having count(Trip) >= 1
ORDER BY COUNT(trip) DESC, name

--17.Определить, сколько потратил в 2005 году каждый из членов семьи
SELECT member_name,
  status,
  sum(unit_price * amount) as costs
from FamilyMembers f
  join Payments p on (f.member_id = p.family_member)
where payment_id in (
    SELECT payment_id
    from Payments
    where YEAR(date) = 2005
  )
group by member_name, status

--18.Узнать, кто старше всех в семьe
SELECT member_name
from FamilyMembers
where birthday in (
    SELECT min(birthday)
    FROM FamilyMembers);

--19.Определить, кто из членов семьи покупал картошку (potato)
SELECT distinct status
from FamilyMembers f
  join Payments p on (f.member_id = p.family_member)
  join Goods g on (p.good = g.good_id)
where good_name = 'potato';

--20.Сколько и кто из семьи потратил на развлечения (entertainment). Вывести статус в семье, имя, сумму
SELECT status,
  member_name,
  sum(amount * unit_price) as costs
from FamilyMembers f
  join Payments p on (f.member_id = p.family_member)
  join goods g on (p.good = g.good_id)
  join GoodTypes gt on (g.type = gt.good_type_id)
where good_type_name = 'entertainment'
GROUP by status, member_name;

--21.Определить товары, которые покупали более 1 раза
select distinct good_name
from Goods g
  join Payments p on (g.good_id = p.good)
GROUP by good_name
HAVING count (amount) > 1;

--22.Найти имена всех матерей (mother)
select member_name
from FamilyMembers
where status = 'mother';

--23.Найдите самый дорогой деликатес (delicacies) и выведите его стоимость
SELECT good_name,
  unit_price
from Goods g
  join GoodTypes gt on (g.type = gt.good_type_id)
  join Payments p on (p.good = g.good_id)
where good_type_name = 'delicacies'
  and unit_price = (
    SELECT max(unit_price)
    from Payments p
      join Goods g on(p.good = g.good_id)
      join GoodTypes gt on (g.type = gt.good_type_id)
    where good_type_name = 'delicacies');

--24.Определить кто и сколько потратил в июне 2005
SELECT member_name,
  sum(unit_price * amount) as costs
from Payments p
  join FamilyMembers f on (p.family_member = f.member_id)
WHERE payment_id in (
    SELECT payment_id
    from Payments
    where DATE_FORMAT(date, '%b-%Y') = 'Jun-2005')
GROUP by member_name;

--25.Определить, какие товары не покупались в 2005 году
select good_name
from Goods
where good_id not in (
    select good
    from Payments
    where YEAR(date) = 2005);

--26.Определить группы товаров, которые не приобретались в 2005 году
SELECT distinct good_type_name
from GoodTypes gt
WHERE good_type_id not in (
    select type
    from goods g
      join Payments p on (g.good_id = p.good)
    where YEAR(date) = 2005);

--27.Узнать, сколько потрачено на каждую из групп товаров в 2005 году. Вывести название группы и сумму
SELECT good_type_name,
  sum(unit_price * amount) as costs
from Payments p
  JOIN goods g on(p.good = g.good_id)
  join GoodTypes gt on (g.type = gt.good_type_id)
WHERE YEAR(date) = 2005
group by good_type_name;

--28.Сколько рейсов совершили авиакомпании с Ростова (Rostov) в Москву (Moscow) ?
SELECT count(id) as count
from trip
WHERE town_from = 'Rostov'
  and town_to = 'Moscow';

--29.Выведите имена пассажиров улетевших в Москву (Moscow) на самолете TU-134
SELECT distinct name
from passenger p
  join Pass_in_trip pt on (p.id = pt.passenger)
where trip in (
    select id
    from trip
    where plane = 'TU-134'
      and town_to = 'Moscow');

--30.Выведите нагруженность (число пассажиров) каждого рейса (trip). Результат вывести в отсортированном виде по убыванию нагруженности.
select trip, count (name) as count
from passenger p
  join Pass_in_trip pt on (p.id = pt.passenger)
GROUP by trip
ORDER by 2 desc;

--31.Вывести всех членов семьи с фамилией Quincey.
select *
from FamilyMembers
where member_name like '% Quincey';

--32.Вывести средний возраст людей (в годах), хранящихся в базе данных. Результат округлите до целого в меньшую сторону.
SELECT FLOOR (avg(TIMESTAMPDIFF(YEAR, birthday, now()))) as age
from FamilyMembers;

--33.Найдите среднюю стоимость икры. В базе данных хранятся данные о покупках красной (red caviar) и черной икры (black caviar).
SELECT avg(unit_price) as cost
from Payments p
  join Goods g on (p.good = g.good_id)
where good_name in ('red caviar', 'black caviar');


--34.Сколько всего 10-ых классов
select count(name) as count
from class
where name like '10 %';

--35.Сколько различных кабинетов школы использовались 2.09.2019 в образовательных целях ?
SELECT count(classroom) as count
from Schedule
where date = '2019-09-02';

--36.Выведите информацию об обучающихся живущих на улице Пушкина (ul. Pushkina)?
select *
from student
WHERE address like 'ul. Pushkina%';

--37.Сколько лет самому молодому обучающемуся ?
SELECT TIMESTAMPDIFF (YEAR, max(birthday), now()) as year
from student;

--38.Сколько Анн (Anna) учится в школе ?
SELECT count(id) as count
FROM Student
where first_name = 'Anna';

--39.Сколько обучающихся в 10 B классе ?
select count(student) as count
from Student_in_class s
  join class c on (s.class = c.id)
where name like '10 B';

--40.Выведите название предметов, которые преподает Ромашкин П.П. (Romashkin P.P.) ?
select name as subjects
from subject s  
join Schedule sc
on (s.id=sc.subject)
join Teacher t
on (sc.teacher=t.id)
where last_name = 'Romashkin';

--41.Во сколько начинается 4-ый учебный предмет по расписанию ?
select start_pair
from Timepair
where id = 4;

--42.Сколько времени обучающийся будет находиться в школе, учась со 2-го по 4-ый уч. предмет ?
SELECT distinct TIMEDIFF ('11:50:00', '09:20:00') as time
from Timepair;

--43.Выведите фамилии преподавателей, которые ведут физическую культуру (Physical Culture). Отcортируйте преподавателей по фамилии.
SELECT last_name
from Teacher t
  join Schedule s ON (t.id = s.teacher)
where subject in (
    select id
    from subject
    where name = 'Physical Culture')
ORDER BY last_name;

--44.Найдите максимальный возраст (колич. лет) среди обучающихся 10 классов ?
select max(YEAR(now()) - YEAR(birthday)) as max_year
from student s
  join Student_in_class st on (s.id = st.student)
where st.class in (
    select id
    from class
    where name like '10 %');

--45.Какой(ие) кабинет(ы) пользуются самым большим спросом?
SELECT classroom
FROM Schedule
GROUP by classroom
having count (classroom) = (
    SELECT count (classroom)
    from Schedule
    group by classroom
    ORDER by 1 desc
    limit 1);

--46.В каких классах введет занятия преподаватель "Krauze" ?
SELECT DISTINCT name
from teacher t
  join Schedule s on (t.id = s.teacher)
  join class c on (c.id = s.class)
where last_name = 'Krauze';

--47.Сколько занятий провел Krauze 30 августа 2019 г.?
select count (subject) as count
from Schedule s
  join Teacher t on (s.teacher = t.id)
where date = '2019-08-30'
  and last_name = 'Krauze';

--48.Выведите заполненность классов в порядке убывания
select name,
  count (student) as count
from Class c
  join Student_in_class st on (c.id = st.class)
GROUP BY name
order by count desc;

--49.Какой процент обучающихся учится в 10 A классе ?
SELECT (count(student) * 100 / (select count(student)
                                from Student_in_class)) as percent
from Class c
  join Student_in_class st on (c.id = st.class)
where name = '10 A';

--50.Какой процент обучающихся родился в 2000 году? Результат округлить до целого в меньшую сторону.
SELECT FLOOR((COUNT(id) * 100 /(SELECT COUNT(id)
                                from Student))) as percent
FROM Student
WHERE YEAR(birthday) = '2000';

--51.Добавьте товар с именем "Cheese" и типом "food" в список товаров (Goods).
INSERT INTO Goods (good_id, good_name, type)
VALUES (17, 'Cheese', 2);

--52.Добавьте в список типов товаров (GoodTypes) новый тип "auto".
INSERT into GoodTypes (good_type_id, good_type_name)
values (9, 'auto');

--53.Измените имя "Andie Quincey" на новое "Andie Anthony".
update FamilyMembers
set member_name = 'Andie Anthony'
where member_name = 'Andie Quincey';

--54.Удалить всех членов семьи с фамилией "Quincey".
DELETE from FamilyMembers
where member_name like '% Quincey';

--55.Удалить компании, совершившие наименьшее количество рейсов.
DELETE from Company
where name in (
    WITH t1 as (
      select name,
        count (t.id) qrt
      from Company c
        join trip t on (c.id = t.company)
      group by name
    )
    select name
    from t1
    where qrt = (
        select min (qrt)
        from t1
      )
  );

--56.Удалить все перелеты, совершенные из Москвы (Moscow).
DELETE from Trip
where town_from = 'Moscow';

--57.Перенести расписание всех занятий на 30 мин. вперед.
update Timepair
SET 
start_pair=start_pair + interval +30 MINUTE,
end_pair =end_pair + interval +30 MINUTE;

--58.Добавить отзыв с рейтингом 5 на жилье, находящиеся по адресу "11218, Friel Place, New York", от имени "George Clooney"
INSERT into reviews 
SEt id = (select count(*)+1 
          from reviews as a),
rating=5,
reservation_id = (select r.id 
                  from reservations  r
                  join rooms ro
                  on (r.room_id=ro.id)
                  join users u
                  on (r.user_id=u.id)
                  where address= '11218, Friel Place, New York'
                  and name = 'George Clooney');

--59.Вывести пользователей,указавших Белорусский номер телефона ? Телефонный код Белоруссии +375.
select *
from Users
WHERE phone_number like '+375%';

--60.Выведите идентификаторы преподавателей, которые хотя бы один раз за всё время преподавали в каждом из одиннадцатых классов.
select teacher
from Schedule s
JOIN class c
on (s.class=c.id)
where name like '11%'
group by teacher
HAVING count (DISTINCT name)>=2;

--61.Выведите список комнат, которые были зарезервированы в течение 12 недели 2020 года.
SELECT Rooms.*
FROM Rooms
  JOIN Reservations re 
  ON (Rooms.id = re.room_id)
WHERE WEEK(start_date, 1) = 12
  OR WEEK(end_date, 1) = 12;

--62.Вывести в порядке убывания популярности доменные имена 2-го уровня, используемые пользователями для электронной почты. Полученный результат необходимо дополнительно отсортировать по возрастанию названий доменных имён.
SELECT SUBSTRING(email, LOCATE('@', email)) as domain,
count (*) as count
from Users
group by domain
order by count DESC, domain asc;

--63.Выведите отсортированный список (по возрастанию) имен студентов в виде Фамилия.И.О.
select concat (last_name, '.',
SUBSTRING(first_name, 1, 1), '.', 
SUBSTRING(middle_name, 1, 1), '.') as name
from Student
order by last_name, first_name;

--64.Вывести количество бронирований по каждому месяцу каждого года, в которых было хотя бы 1 бронирование. Результат отсортируйте в порядке возрастания даты бронирования.
select YEAR(start_date) as year, MONTH(start_date) as month,
COUNT(*) as amount
from Reservations
GROUP by 1, 2
having count (*)>=1
ORDER by 1, 2;

--65.Необходимо вывести рейтинг для комнат, которые хоть раз арендовали, как среднее значение рейтинга отзывов округленное до целого вниз.
SELECT room_id, FLOOR(AVG(rating)) as rating
from Reviews re
join Reservations r
on (re.reservation_id=r.id)
GROUP by room_id 

--66.Вывести список комнат со всеми удобствами (наличие ТВ, интернета, кухни и кондиционера), а также общее количество дней и сумму за все дни аренды каждой из таких комнат.
SELECT home_type, address, 
ifnull (sum(DATEDIFF (end_date, start_date)), 0) as days,
ifnull (sum(total), 0) as total_fee
from Rooms r
LEFT JOIN Reservations re
on(r.id=re.room_id)
where has_tv = 1
and has_internet = 1
and has_kitchen = 1
and has_air_con = 1
GROUP by r.id;

--67.Вывести время отлета и время прилета для каждого перелета в формате "ЧЧ:ММ, ДД.ММ - ЧЧ:ММ, ДД.ММ", где часы и минуты с ведущим нулем, а день и месяц без.
SELECT concat(DATE_FORMAT(time_out, '%H:%i, %e.%c' ), '-', 
DATE_FORMAT(time_in, '%H:%i, %e.%c')) as flight_time
from Trip;

--68.Для каждой комнаты, которую снимали как минимум 1 раз, найдите имя человека, снимавшего ее последний раз, и дату, когда он выехал
with get_data as (
select room_id,
max(end_date) as end_date
from Reservations
group by room_id
having count(*) >= 1
)
select rs.room_id,
u.name,
rs.end_date
from Reservations as rs
join get_data as gd on gd.room_id = rs.room_id
and gd.end_date = rs.end_date
join users as u on u.id = rs.user_id

--69.Вывести идентификаторы всех владельцев комнат, что размещены на сервисе бронирования жилья и сумму, которую они заработали
SELECT owner_id, ifnull (sum(re.total), 0) as total_earn
from Rooms r
left join Reservations re
on (r.id=re.room_id )
group by owner_id;

--70.Необходимо категоризовать жилье на economy, comfort, premium по цене соответственно <= 100, 100 < цена < 200, >= 200. В качестве результата вывести таблицу с названием категории и количеством жилья, попадающего в данную категорию
select (case
when price <=100 then 'economy'
when price >100
and price <200 then 'comfort'
when price >=200 then 'premium'
end ) as category, COUNT(id) as count
from Rooms
group by category;

--71.Найдите какой процент пользователей, зарегистрированных на сервисе бронирования, хоть раз арендовали или сдавали в аренду жилье. Результат округлите до сотых.
WITH  t1 AS (
SELECT DISTINCT user_id
FROM Reservations
UNION
SELECT DISTINCT owner_id
FROM Rooms r
JOIN Reservations re
ON (r.id = re.room_id) 
)

SELECT ROUND(
    (
        (SELECT COUNT(*) FROM active) / COUNT(*) * 100), 2
    ) AS percent
FROM Users;
