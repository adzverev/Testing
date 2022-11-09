--11.Найдите среднюю скорость ПК.
select avg (speed)
from pc;

--12.Найдите среднюю скорость ПК-блокнотов, цена которых превышает 1000 дол.
select avg(speed)
from laptop
where price >1000;

--13.Найдите среднюю скорость ПК, выпущенных производителем A.
select avg (speed)
from pc p
join product pr
on (p.model=pr.model)
where maker = 'A';

--14.Найдите класс, имя и страну для кораблей из таблицы Ships, имеющих не менее 10 орудий.
select s.class, name, country
from ships s
join classes c
on (s.class=c.class)
where numGuns>=10;

--15.Найдите размеры жестких дисков, совпадающих у двух и более PC.
select hd
from pc
group by hd
having count(hd)>=2;

--16.Найдите пары моделей PC, имеющих одинаковые скорость и RAM. В результате каждая пара указывается только один раз, т.е. (i,j), но не (j,i), Порядок вывода: модель с большим номером, модель с меньшим номером, скорость и RAM.
select distinct p.model, p2.model, p.speed, p.ram
from pc p, pc p2
where p.speed=p2.speed
and p.ram=p2.ram
and p.model>p2.model;

--17.Найдите модели ПК-блокнотов, скорость которых меньше скорости каждого из ПК.
select distinct  type, l.model, speed
from  laptop l
join  product pr
on (l.model=pr.model)
where speed <all (select speed from pc);

--18.Найдите производителей самых дешевых цветных принтеров. Вывести: maker, price
select distinct  maker, price
from printer p
join product pr
on (p.model=pr.model)
where price in (select min (price) from printer where color = 'y')
and color = 'y';

--19.Для каждого производителя, имеющего модели в таблице Laptop, найдите средний размер экрана выпускаемых им ПК-блокнотов.Вывести: maker, средний размер экрана.
select maker, avg(screen)
from laptop l
join product pr
on (l.model=pr.model)
group by maker;

--20.Найдите производителей, выпускающих по меньшей мере три различных
select maker, count (pr.model)
from product pr
where type = 'pc'
group by maker
having count (pr.model)>=3;

--21.Найдите максимальную цену ПК, выпускаемых каждым производителем, у которого есть модели в таблице PC.
select distinct maker, max(price)
from product pr
join pc p
on (pr.model=p.model)
where type = 'PC'
group by maker;

--22.Для каждого значения скорости ПК, превышающего 600 МГц, определите среднюю цену ПК с такой же скоростью. Вывести: speed, средняя цена.
select speed, avg (price)
from pc
where speed>600
group by speed;


--23.Найдите производителей, которые производили бы как ПК со скоростью не менее 750 МГц, так и ПК-блокноты со скоростью не менее 750 МГц.
select maker
from product pr
join pc p
on (pr.model=p.model)
where type = 'PC'
and speed >=750
intersect 
select maker
from product pr
join laptop l
on (pr.model=l.model)
where type = 'laptop'
and speed >=750;

--24.Перечислите номера моделей любых типов, имеющих самую высокую цену по всей имеющейся в базе данных продукции.
with t1 as (select model, price 
from pc
union
select model, price
from laptop
union
select model, price
from printer)

select model 
from t1
where price in (select max(price) from t1);


--25.Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM и с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM. Вывести: Maker
with model_pc as (select model 
from pc 
where ram in (select min(ram) from pc)
and speed in (select max(speed) from pc where ram in (select min(ram) from pc)))

select distinct maker
from product pr
where model in (select * from model_pc)
and maker in (select maker from product where type = 'printer');

--26.Найдите среднюю цену ПК и ПК-блокнотов, выпущенных производителем A (латинская буква). Вывести: одна общая средняя цена.
with prices as (select price
from pc
join product pr
on (pc.model=pr.model)
where maker = 'A'
union all
select price
from laptop l
join product pr
on (l.model=pr.model)
where maker = 'A')

select avg(price)
from prices

--27.Найдите средний размер диска ПК каждого из тех производителей, которые выпускают и принтеры. Вывести: maker, средний размер HD.
with  makers as (select maker
from product
where type = 'pc'
intersect
select maker
from product
where type = 'printer'
)
select maker, avg (hd)
from pc
join product pr
on (pc.model=pr.model)
where maker in (select maker from makers)
group by maker

--28.Используя таблицу Product, определить количество производителей, выпускающих по одной модели.
with t1 as  (select maker
from product
group by maker
having count (model)=1
)
select count(maker)
from t1

--29.В предположении, что приход и расход денег на каждом пункте приема фиксируется не чаще одного раза в день [т.е. первичный ключ (пункт, дата)], написать запрос с выходными данными (пункт, дата, приход, расход). Использовать таблицы Income_o и Outcome_o.
select o.point, o.date, inc, out
from Outcome_o o
left join  Income_o  i
on(o.point=i.point)
and (o.date=i.date)
union
select i.point, i.date, inc, out
from Income_o i
left join Outcome_o o
on(i.point=o.point)
and (i.date=o.date)


--30.В предположении, что приход и расход денег на каждом пункте приема фиксируется произвольное число раз (первичным ключом в таблицах является столбец code), требуется получить таблицу, в которой каждому пункту за каждую дату выполнения операций будет соответствовать одна строка.
--Вывод: point, date, суммарный расход пункта за день (out), суммарный приход пункта за день (inc). Отсутствующие значения считать неопределенными (NULL).
with dohod as(select point, date, sum(out) out , null inc
from Outcome
group by point, date 
union 
select point, date, null out, sum(inc) inc
from Income
group by point, date)

select point, date, sum(out) out, sum(inc) inc
from dohod
group by point, date

--31.Для классов кораблей, калибр орудий которых не менее 16 дюймов, укажите класс и страну.
Select class, country
From classes c
Where bore>=16;

--32.Одной из характеристик корабля является половина куба калибра его главных орудий (mw). С точностью до 2 десятичных знаков определите среднее значение mw для кораблей каждой страны, у которой есть корабли в базе данных.
with t1 as (select country, name, bore
from classes c
join ships s
on (c.class=s.class)
union
select country, ship, bore
from classes c
join outcomes o
on (c.class=o.ship))

select distinct country, CAST(avg((bore*bore*bore)/2) AS numeric(6,2)) weight 
from t1
group by country;

--33.Укажите корабли, потопленные в сражениях в Северной Атлантике (North Atlantic). Вывод: ship.
select ship
from outcomes
where result = 'sunk'
and battle in ('North Atlantic');

--34.По Вашингтонскому международному договору от начала 1922 г. запрещалось строить линейные корабли водоизмещением более 35 тыс.тонн. Укажите корабли, нарушившие этот договор (учитывать только корабли c известным годом спуска на воду). Вывести названия кораблей.
select distinct name
from ships s
join classes c
on (s.class=c.class)
where launched >=1922
and displacement>35000
and type = 'bb';

--35.В таблице Product найти модели, которые состоят только из цифр или только из латинских букв (A-Z, без учета регистра). Вывод: номер модели, тип модели. В таблице Product найти модели, которые состоят только из цифр или только из латинских букв (A-Z, без учета регистра). Вывод: номер модели, тип модели.
select model, type
from product
where upper (model) not  like '%[^0-9]%'
or upper (model) not  like '%[^A-Z]%';

--36.Перечислите названия головных кораблей, имеющихся в базе данных (учесть корабли в Outcomes).
select name
from ships s
join classes c
on (s.name=c.class)
union
select ship
from outcomes o
join classes c
on (o.ship=c.class);

--37.Найдите классы, в которые входит только один корабль из базы данных (учесть также корабли в Outcomes).
with shipes as (select c.class, name
from ships s
join classes c
on (c.class=s.class)
union
select c.class, ship
from Outcomes o
join classes c
on (c.class=o.ship)
)

select class
from shipes
group by class
having count (name)=1;

--38.Найдите страны, имевшие когда-либо классы обычных боевых кораблей ('bb') и имевшие когда-либо классы крейсеров ('bc').
select country
from classes
where type = 'bb'
INTERSECT
select country
from classes
where type = 'bc';

--39.Найдите корабли, `сохранившиеся для будущих сражений`; т.е. выведенные из строя в одной битве (damaged), они участвовали в другой, произошедшей позже.
select distinct ship
from outcomes o
join battles b
on (o.battle=b.name)
where ship in (select ship 
from outcomes o
join battles ba
on (o.battle=ba.name)
where b.date <ba.date)
and result = 'damaged'

--40.Найти производителей, которые выпускают более одной модели, при этом все выпускаемые производителем модели являются продуктами одного типа. Вывести: maker, type
select maker, max(type) type
from product
group by maker
having count(model)>1
and count(distinct type)=1;

--41. Для каждого производителя, у которого присутствуют модели хотя бы в одной из таблиц PC, Laptop или Printer, определить максимальную цену на его продукцию.
--Вывод: имя производителя, если среди цен на продукцию данного производителя присутствует NULL, то выводить для этого производителя NULL, иначе максимальную цену.
with t1 as (select model, price
           from pc  union
select model, price from laptop
union
select model, price from printer)

select distinct p.maker,
case
when max(case when t1.price is null then 1 else 0 end)=0 then max(t1.price)
end
from product p
right join t1
on (p.model=t1.model)
group by maker;


--42. Найдите названия кораблей, потопленных в сражениях, и название сражения, в котором они были потоплены.
select ship, battle
from outcomes
where result = 'sunk';

--43.Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.
select name
from battles
where DATEPART(YEAR, date) not in (select DATEPART(yy, date)
from battles join ships on DATEPART(yy, date)=launched);

--44. Найдите названия всех кораблей в базе данных, начинающихся с буквы R.
select name
from ships
where name like 'R%'
union
select ship
from outcomes
where ship like 'R%';

--45. Найдите названия всех кораблей в базе данных, состоящие из трех и более слов (например, King George V). Считать, что слова в названиях разделяются единичными пробелами, и нет концевых пробелов.
select name
from ships
where name like '% % %'
union
select ship
from outcomes
where ship like '% % %';

--46. Для каждого корабля, участвовавшего в сражении при Гвадалканале (Guadalcanal), вывести название, водоизмещение и число орудий.
select o.ship, displacement, numGuns
from (
select name as class, displacement, numGuns
from Classes c
join ships s
on (c.class=s.class)
union
select ship, displacement, numGuns
from Classes c
join outcomes o
on (c.class=o.ship)
) t1
right join outcomes o
on (t1.class=o.ship)
where battle = 'Guadalcanal';


--48. Найдите классы кораблей, в которых хотя бы один корабль был потоплен в сражении.
select class
from classes c
join outcomes o
on (c.class=o.ship)
where result = 'sunk'
union
select class
from ships s
join outcomes o
on (s.name=o.ship)
where result = 'sunk';

--49. Найдите названия кораблей с орудиями калибра 16 дюймов (учесть корабли из таблицы Outcomes).
select name
from classes c
join ships s
on (c.class=s.class)
where bore = 16
union
select ship
from classes c
join outcomes o
on (c.class=o.ship)
where bore = 16;

--50. Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.
select distinct battle
from  outcomes b
join ships s
on (b.ship=s.name)
where class = 'Kongo';

--52. Определить названия всех кораблей из таблицы Ships, которые могут быть линейным японским кораблем, имеющим число главных орудий не менее девяти, калибр орудий менее 19 дюймов и водоизмещение не более 65 тыс.тонн
select name
from ships s
join classes c on (s.class=c.class)
WHERE country = 'JAPAN' 
AND (numguns>=9 or numguns is NULL) 
AND (bore < 19 OR bore IS NULL) 
AND (displacement <= 65000 OR displacement IS NULL) 
AND type = 'bb';

--53. Определите среднее число орудий для классов линейных кораблей. Получить результат с точностью до 2-х десятичных знаков.
select cast (avg (numguns*1.0) as numeric (6,2))
from classes c
where type = 'bb';

--54. С точностью до 2-х десятичных знаков определите среднее число орудий всех линейных кораблей (учесть корабли из таблицы Outcomes).
select cast(avg(numguns*1.0)  as numeric (6,2))
from (
select name, class
from ships
union
select ship, ship
from outcomes ) t1
join classes c 
on (t1.class=c.class)
where type = 'bb';

--55. Для каждого класса определите год, когда был спущен на воду первый корабль этого класса. Если год спуска на воду головного корабля неизвестен, определите минимальный год спуска на воду кораблей этого класса. Вывести: класс, год.
select c.class, min (launched) yer
from ships s
full join classes c
on (c.class=s.class)
group by c.class;


--61. Посчитать остаток денежных средств на всех пунктах приема для базы данных с отчетностью не чаще одного раза в день.
select sum(coalesce(inc, 0))-sum(coalesce(out, 0)) qty
from income_o i
full join outcome_o o
on (i.point=o.point)
and (i.date=o.date);

--83.Определить названия всех кораблей из таблицы Ships, которые удовлетворяют, по крайней мере, комбинации любых четырёх критериев из следующего списка:
--numGuns = 8
--bore = 15
--displacement = 32000
--type = bb
--launched = 1915
--class=Kongo
--country=USA
select name 
from ships s 
join Classes c
on (s.class=c.class)
WHERE 
CASE WHEN numGuns = 8 THEN 1 ELSE 0 END +
CASE WHEN bore = 15 THEN 1 ELSE 0 END +
CASE WHEN displacement = 32000 THEN 1 ELSE 0 END +
CASE WHEN type = 'bb' THEN 1 ELSE 0 END +
CASE WHEN launched = 1915 THEN 1 ELSE 0 END +
CASE WHEN c.class='Kongo' THEN 1 ELSE 0 END +
CASE WHEN country='USA' THEN 1 ELSE 0 END >=4;


--89. Найти производителей, у которых больше всего моделей в таблице Product, а также тех, у которых меньше всего моделей. Вывод: maker, число моделей
select maker, count(model) qty
from product
group by maker 
having count (model)>=all (select count(model) qty
                           from product
                           group by maker)
union
select maker, count(model) qty
from product
group by maker 
having count (model)<=all (select count(model) qty
                          from product
                          group by maker);

--103. Выбрать три наименьших и три наибольших номера рейса. Вывести их в шести столбцах одной строки, расположив в порядке от наименьшего к наибольшему.
--Замечание: считать, что таблица Trip содержит не менее шести строк.
select min (t.trip_no), min (tt. trip_no), min (ttt.trip_no), max (t.trip_no), max (tt.trip_no), max (ttt.trip_no)
from Trip t, trip tt, trip ttt
where t.trip_no<tt. trip_no
and tt. trip_no<ttt.trip_no;