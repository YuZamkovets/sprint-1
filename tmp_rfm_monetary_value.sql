--tmp_rfm_monetary_value.sql

CREATE TABLE analysis.tmp_rfm_monetary_value (
user_id INT NOT NULL PRIMARY KEY,
monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);


--mon
insert into analysis.tmp_rfm_monetary_value
with closed_orders as --создание промежуточной таблицы с только закрытыми заказами
(select o.user_id,sum(payment) as payment_sum
from analysis.orders o
inner join analysis.orderstatuses os 
on o.status=os.id and key='Closed'
group by o.user_id)
select o.user_id,
--payment_sum,row_number() over (order by payment_sum nulls first) as user_rank,
ceil((row_number() over (order by payment_sum nulls first))::numeric/(select count(distinct user_id) from analysis.orders)::numeric*5)
from (select distinct user_id from analysis.orders) o --таблица с уникальными юзерами
left join closed_orders on  o.user_id =closed_orders.user_id;

