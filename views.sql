--Создание представлений для 5ти таблиц (в схеме analysis)

create view analysis.orderitems as
select * from production.orderitems;

create view analysis.orders as
select * from production.orders;

create view analysis.orderstatuses as
select * from production.orderstatuses;

create view analysis.products as
select * from production.products;

create view analysis.users as
select * from production.users;