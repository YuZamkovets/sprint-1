
--tmp_rfm_recency.sql

CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

--recency
insert into analysis.tmp_rfm_recency
with closed_orders as --создание промежуточной таблицы с только закрытыми заказами
(select o.user_id,max(order_ts) as max_date
from analysis.orders o
inner join analysis.orderstatuses os 
on o.status=os.id and key='Closed'
group by o.user_id)
select o.user_id,
--max_date,row_number () over (order by max_date nulls first) as user_rank,
ceil((row_number() over (order by max_date nulls first))::numeric/(select count(distinct user_id) from analysis.orders)::numeric*5)
from (select distinct user_id from analysis.orders) o --таблица с уникальными юзерами
left join closed_orders on  o.user_id =closed_orders.user_id;
