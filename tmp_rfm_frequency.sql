--tmp_rfm_frequency.sql

CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);

--frec
insert into analysis.tmp_rfm_frequency
with closed_orders as --создание промежуточной таблицы с только закрытыми заказами
(select o.user_id,count(distinct order_id) as orders_cnt
from analysis.orders o
inner join analysis.orderstatuses os 
on o.status=os.id and key='Closed'
group by o.user_id)
select o.user_id,
--orders_cnt,row_number() over (order by orders_cnt nulls first) as user_rank,
ceil((row_number() over (order by orders_cnt nulls first))::numeric/(select count(distinct user_id) from analysis.orders)::numeric*5)
from (select distinct user_id from analysis.orders) o --таблица с уникальными юзерами
left join closed_orders on  o.user_id =closed_orders.user_id;
