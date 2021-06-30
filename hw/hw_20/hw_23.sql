--ЗАДАЧА: 
--Напишите запрос по своей базе с inner join
--Напишите запрос по своей базе с left join

--ОТВЕТ:
--вывести всех актеров которые снимались хотябы в 1 хорроре
SELECT DISTINCT a.*
FROM `film` as f

left join `film_category` fc on fc.film_id = f.film_id
left join `category` c on c.category_id = fc.category_id

left join `film_actor` as fa on fa.film_id = f.film_id  
left join `actor` as a on a.actor_id = fa.actor_id

where c.name = 'Horror'

order by a.actor_id

--показать актеров которые не снялись ни в 1 хорроре
select a.* from 
(
    SELECT DISTINCT a.*
    FROM `film` as f

    left join `film_category` fc on fc.film_id = f.film_id
    left join `category` c on c.category_id = fc.category_id

    left join `film_actor` as fa on fa.film_id = f.film_id
    left join `actor` as a on a.actor_id = fa.actor_id

    where c.name = 'Horror'
) as filter
right join `actor` as a on a.actor_id = filter.actor_id
where filter.actor_id is null

--ЗАМЕТКА: утомительно придумывать самому себе задания по выборке чтоб еще и интересно было...

--Задача: Напишите 5 запросов с WHERE с использованием разных операторов, опишите для чего вам в проекте нужна такая выборка данных
--ОТВЕТ: нет пока проекта, опять сидеть выдумывать 5 запросов с where "из воздуха" чтобы самому было интересно - время тратить только. 
--Список возможных операторов глянул https://dev.mysql.com/doc/refman/8.0/en/comparison-operators.html

