--написать запрос суммы очков с группировкой и сортировкой по годам
	select year_game, sum(points) from statistic
	group by year_game
    order by year_game desc

--##############################################################################################################

--написать cte показывающее тоже самое
with q as (
	select year_game, sum(points) from statistic
	group by year_game
)
select * from q
order by year_game desc

--##############################################################################################################

--используя функцию LAG вывести кол-во очков по всем игрокам за текущий код и за предыдущий.
with q as (
	select year_game, sum(points) as curr from statistic
	group by year_game
)
select 
	q.* 
	,lag(curr, 1) over (order by year_game) as prev
from q
order by year_game desc
limit 2
