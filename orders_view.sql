--orders_view.sql

drop view if exists analysis.orders;

create view analysis.orders as
select orders.order_id, orders.order_ts, orders.user_id, orders.bonus_payment, orders.payment, orders."cost", orders.bonus_grant,
orderstatuslog.status 
from production.orders 
left join
(select distinct order_id,
max(status_id) over(partition by order_id order by dttm desc) as status
from production.orderstatuslog) orderstatuslog 
on orders.order_id=orderstatuslog.order_id;