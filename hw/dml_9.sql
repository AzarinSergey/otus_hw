--##############################################################################################################

--  Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти.

--  ЗАДАЧА: Найти все билеты оформленные на имена пассажиров где:
--  имя начинается с символов E ИЛИ F ИЛИ G 
--  И фамилия и имя разделены 1 пробелом
--  И первая буква фамилии не B
--  И фамилия оканчивается на OV ИЛИ OVA
--  И фамилия не длиннее 6 символов
--  ОТВЕТ:
select *
	from bookings.Tickets
	
	where passenger_name ~ '^[E-G]\w{1,}\s{1}[AC-Z]\w{1,3}(OV|OVA)$'
	
	order by passenger_name;

--##############################################################################################################

--  Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?
--  ЗАДАЧА: Посчитать сумму которая была оплачена за перелеты, где пассажиры не явились на посадку.
--  ОТВЕТ: 
select sum(s.Amount)  -- 5.
from (
	select t.ticket_no, tfl.Amount
	from bookings.Tickets t -- 1.
	
	left join bookings.Boarding_passes p on t.ticket_no = p.ticket_no -- 2.

	right join bookings.Ticket_flights tfl on tfl.ticket_no = t.ticket_no -- 3.

	where p.ticket_no is null -- 4.
) s
--  1. Выбираем все билеты
--  2. Присоединяем к билетам посадочные. При левом соединении выведутся ВСЕ билеты (слева), даже те, для которых посадочный не будет найден. 
--      Тут также можно использовать inner join не боясь получить дубли т.к. связь между таблицами 1 к 1. Тогда в п. 3 должен быть строго right join для получения недостающих записей, где нет посадочных.
--  3. Присоединяем к билетам перелеты. При правом выведутся ВСЕ перелеты (справа), даже те, для которых билета нет, что невозможно, т.к. ticket_no Not NULL by design. 
--      Поэтому в данном случае можно использовать как left, так и right соединение.
--  4. Выбираем только те записи для которых не существует посадочный талон.
--  5. Суммируем стоимости всех билетов и выбираем результат. 7228473400.00
--  Второй вариант с таким же результатом как в первом:
select sum(s.Amount)  -- 5.
from (
	select t.ticket_no, tfl.Amount
	from bookings.Tickets t -- 1.
	
	inner join bookings.Boarding_passes p on t.ticket_no = p.ticket_no -- 2.

	right join bookings.Ticket_flights tfl on tfl.ticket_no = t.ticket_no -- 3.

	where p.ticket_no is null -- 4.
) s

--##############################################################################################################

--  Напишите запрос на добавление данных с выводом информации о добавленных строках.
insert into bookings.Aircrafts_data (aircraft_code, model, range) values
	(555 
	,'{
		"en": "Airbus A320-neo",
		"ru": "Аэробус A320-neo"
	}'
 	, 10200)
	returning aircraft_code, model, range

--##############################################################################################################

--  Напишите запрос с обновлением данные используя UPDATE FROM.
insert into bookings.Aircrafts_data (aircraft_code, model, range) 
    select '777', model, '10300' from bookings.Aircrafts_data
    where aircraft_code = 'CN1'
returning aircraft_code, model, range

--##############################################################################################################

--  Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.
delete
 from bookings.boarding_passes b
using bookings.ticket_flights f
where b.ticket_no = f.ticket_no
and f.ticket_no = '0005432000987'
