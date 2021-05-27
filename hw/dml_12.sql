--1.Создать индекс к какой-либо из таблиц вашей БД
--Прислать текстом результат команды explain, в которой используется данный индекс

--ЗАДАЧА: найти рейсы с максимально заполненным бизнесс классом и вывести 
--число занятых мест, номер рейса, города и названия аэропортов на английском from(dep)-to(arr)

--ЗАПРОС:
with 
fl_count as (
    select bfl.flight_id, count(*) as counter from
    (
        select flight_id, fare_conditions from bookings.ticket_flights
        where fare_conditions = 'Business'
    ) bfl
    group by bfl.flight_id
), 
fl_count_max as ( 
    select max(fl_count.counter) as maximum from fl_count 
)

select 
fl_count.counter, 
fl_count.flight_id, 
air_from.airport_name -> 'en' as from_airport,
air_from.city -> 'en' as from_city,
air_to.airport_name -> 'en' as to_airport,
air_to.city -> 'en' as to_city
from fl_count
right join fl_count_max _m on _m.maximum = fl_count.counter
inner join bookings.flights fl on fl_count.flight_id = fl.flight_id 
inner join bookings.airports_data air_from on air_from.airport_code = fl.departure_airport
inner join bookings.airports_data air_to on air_to.airport_code = fl.arrival_airport

--ОТВЕТ: Без индекса в 44 строке Seq scan: (322)

--"Nested Loop  (cost=19238.95..19643.13 rows=76 width=140)"
--"  CTE fl_count"
--"    ->  Finalize HashAggregate  (cost=18741.68..18894.50 rows=15282 width=12)"
--"          Group Key: ticket_flights.flight_id"
--"          ->  Gather  (cost=15379.64..18588.86 rows=30564 width=12)"
--"                Workers Planned: 2"
--"                ->  Partial HashAggregate  (cost=14379.64..14532.46 rows=15282 width=12)"
--"                      Group Key: ticket_flights.flight_id"
--"                      ->  Parallel Seq Scan on ticket_flights  (cost=0.00..14161.49 rows=43630 width=4)"
--"                            Filter: ((fare_conditions)::text = 'Business'::text)"
--"  ->  Nested Loop  (cost=344.31..735.68 rows=76 width=126)"
--"        ->  Nested Loop  (cost=344.17..723.50 rows=76 width=20)"
--"              ->  Hash Join  (cost=343.88..690.48 rows=76 width=12)"
--"                    Hash Cond: (fl_count.counter = (max(fl_count_1.counter)))"
--"                    ->  CTE Scan on fl_count  (cost=0.00..305.64 rows=15282 width=12)"
--"                    ->  Hash  (cost=343.86..343.86 rows=1 width=8)"
--"                          ->  Aggregate  (cost=343.84..343.85 rows=1 width=8)"
--"                                ->  CTE Scan on fl_count fl_count_1  (cost=0.00..305.64 rows=15282 width=8)"
--"              ->  Index Scan using flights_pkey on flights fl  (cost=0.29..0.43 rows=1 width=12)"
--"                    Index Cond: (flight_id = fl_count.flight_id)"
--"        ->  Index Scan using airports_data_pkey on airports_data air_from  (cost=0.14..0.16 rows=1 width=114)"
--"              Index Cond: (airport_code = fl.departure_airport)"
--"  ->  Index Scan using airports_data_pkey on airports_data air_to  (cost=0.14..0.16 rows=1 width=114)"
--"        Index Cond: (airport_code = fl.arrival_airport)"

--Добавим индекс

CREATE INDEX my_first_index ON bookings.ticket_flights (fare_conditions)

-- Его использование видим в 73 строке

--"Nested Loop  (cost=12216.68..12620.86 rows=76 width=140)"
--"  CTE fl_count"
--"    ->  HashAggregate  (cost=11719.40..11872.22 rows=15282 width=12)"
--"          Group Key: ticket_flights.flight_id"
--"          ->  Bitmap Heap Scan on ticket_flights  (cost=1171.94..11195.84 rows=104712 width=4)"
--"                Recheck Cond: ((fare_conditions)::text = 'Business'::text)"
--"                ->  Bitmap Index Scan on my_first_index  (cost=0.00..1145.76 rows=104712 width=0)"
--"                      Index Cond: ((fare_conditions)::text = 'Business'::text)"
--"  ->  Nested Loop  (cost=344.31..735.68 rows=76 width=126)"
--"        ->  Nested Loop  (cost=344.17..723.50 rows=76 width=20)"
--"              ->  Hash Join  (cost=343.88..690.48 rows=76 width=12)"
--"                    Hash Cond: (fl_count.counter = (max(fl_count_1.counter)))"
--"                    ->  CTE Scan on fl_count  (cost=0.00..305.64 rows=15282 width=12)"
--"                    ->  Hash  (cost=343.86..343.86 rows=1 width=8)"
--"                          ->  Aggregate  (cost=343.84..343.85 rows=1 width=8)"
--"                                ->  CTE Scan on fl_count fl_count_1  (cost=0.00..305.64 rows=15282 width=8)"
--"              ->  Index Scan using flights_pkey on flights fl  (cost=0.29..0.43 rows=1 width=12)"
--"                    Index Cond: (flight_id = fl_count.flight_id)"
--"        ->  Index Scan using airports_data_pkey on airports_data air_from  (cost=0.14..0.16 rows=1 width=114)"
--"              Index Cond: (airport_code = fl.departure_airport)"
--"  ->  Index Scan using airports_data_pkey on airports_data air_to  (cost=0.14..0.16 rows=1 width=114)"
--"        Index Cond: (airport_code = fl.arrival_airport)"

--##############################################################################################################

--2. Реализовать индекс для полнотекстового поиска
-- Будем искать пассажиров по ФИ.

-- ВАРИАНТ 1
-- Т.к. интересующая колонка типа "текст" при создании индекса используем 
-- to_tsvector функцию с кофигом english и указываем колонку. 
-- Конфиг можно и simple, т.к. нету грамматических изысков в ФИ
CREATE INDEX passenger_name_eng_search_index ON bookings.tickets
    USING gin(to_tsvector('english', passenger_name));

-- Поиск с использованием индекса:

explain
select * from bookings.tickets 
where 
to_tsvector('english', passenger_name) 
@@ to_tsquery('english','NATALYA & ! KONOVALOVA & ! BELOVA');

-- Выведет всех NATALYA кроме тех у кого фамилия KONOVALOVA или BELOVA.
-- Explain:
--"Bitmap Heap Scan on tickets  (cost=46.07..4442.24 rows=1815 width=104)"
--"  Recheck Cond: (to_tsvector('english'::regconfig, passenger_name) @@ '''natalya'' & !''konovalova'' & !''belova'''::tsquery)"
--"  ->  Bitmap Index Scan on passenger_name_eng_search_index  (cost=0.00..45.62 rows=1815 width=0)"
--"        Index Cond: (to_tsvector('english'::regconfig, passenger_name) @@ '''natalya'' & !''konovalova'' & !''belova'''::tsquery)"

-- ВАРИАНТ 2
-- Нечеткий поиск
-- Добавим экстеншен:
CREATE EXTENSION pg_trgm;

-- Создадим индекс
CREATE INDEX passenger_name_eng_trgm_index ON bookings.tickets
  USING gin (passenger_name gin_trgm_ops);

-- Посмотрим что там у нас в индексе
SELECT show_trgm(passenger_name) FROM bookings.tickets LIMIT 10;

-- Установим уровень точночти совпадения, результаты выше которого будут выводиться
SELECT show_limit(), set_limit(0.4);

-- Выполняем запросы и смотрим уровень совпадения
select passenger_name, similarity(title, 'panov') from bookings.tickets 
where passenger_name % 'panov'

--##############################################################################################################

--3. Реализовать индекс на часть таблицы или индекс на поле с функцией
-- Добавим поле с функцией: сумма с учетем скидки в 5%.
alter table bookings.ticket_flights add column 
amount_with_discount numeric(10,2) generated always as (amount - (5*amount/100)) stored
-- Добавим индекс чтобы фильтровать по сумме со скидкой:
create index amount_with_discount ON bookings.ticket_flights using btree (amount_with_discount);
-- Выполняем запрос 
select * from bookings.ticket_flights 
where amount_with_discount > 9000
and amount_with_discount < 12000
-- Проверяем использование индекса:
--"Bitmap Heap Scan on ticket_flights  (cost=114.02..8461.77 rows=5229 width=48)"
--"  Recheck Cond: ((amount_with_discount > '9000'::numeric) AND (amount_with_discount < '12000'::numeric))"
--"  ->  Bitmap Index Scan on amount_with_discount  (cost=0.00..112.71 rows=5229 width=0)"
--"        Index Cond: ((amount_with_discount > '9000'::numeric) AND (amount_with_discount < '12000'::numeric))"

--##############################################################################################################

--4. Создать индекс на несколько полей - не интересно, согласен на минус балл

--##############################################################################################################

--5. Написать комментарии к каждому из индексов - DONE

--##############################################################################################################

--6. Описать что и как делали и с какими проблемами столкнулись
  
  -- Как делал:
  -- 1. Пытался смотреть лекцию на тему раза 3, до конца ни разу не удалось досмотреть. 
  -- Читать всеже быстрее и удобнее. перешел к выполнению задачи.
  -- 2. Читал задачу по занятию.
  -- 3. Поскольку задачи по занятию АБСТРАКТНЫЕ - придумывал себе задачу на тестовой БД
  -- 4. Решал задачу с использованием гугла и  https://postgrespro.ru/docs/

  -- Основная проблема и самая утомительная часть с которой столкнулся - 
  -- выдумать для себя задачу на основе абстрактной постановки используя тестовую БД... Это беда...
  -- Остальное - не проблемы, а процесс изучения =).