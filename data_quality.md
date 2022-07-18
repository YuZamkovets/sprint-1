# 1.3. Качество данных

## Оцените, насколько качественные данные хранятся в источнике.

Схема production содержит 6 таблиц:

## orderitems - товары в заказе, всего 47369 строк (и столько же уникальных id - связок id товара и id заказа), 21 - уникальых товара и 10000 уникальных заказов.

Запрос для проверки:

select count(*),count(distinct id),count(distinct product_id),count(distinct order_id)
from production.orderitems;

## orders - информация о заказах, всего содержится 10000 строк (и 10000 уникальных заказов), 1000 уникальных пользователей. Интервал дат создания заказов: с 2022-02-12 02:41:28 по 2022-03-14 02:38:26.

Запрос для проверки: 
select count(*),count(distinct order_id),count(distinct user_id),min(order_ts),max(order_ts) 
from production.orders;

В таблице orders и orderitems содержатся одни и те же идентифкаторы заказов.

Запрос для проверки:
select count(*) from (
select order_id from production.orderitems
union 
select order_id from production.orders) t_union;

## orderstatuses - справочник статусов заказов (всего 5 строк, 5 статусов)

## orderstatuslog - таблица с движением статусов заказов (всего 29982 строк и 29982 уникальных идентификаторов перехода статуса, 10000 уникальных заказов)

Запрос для проверки:
select count(*),count(distinct id),count(distinct order_id) from production.orderstatuslog;

## products - таблица-справочник товаров (всего 21 строка и 21 уникальный товар)

Запрос для проверки:
select count(*),count(distinct id),count(distinct name) from production.products;

## users - таблица пользователей, всего 1000 строк и 1000 уникальных пользователей

Запрос для проверки:
select count(*),count(distinct id),count(distinct name) from production.users;

## Укажите, какие инструменты обеспечивают качество данных в источнике.

|	Таблицы	|	Объект	|	Инструмент	|	Для чего используется	|
|	production.orderitems	|	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY, CONSTRAINT orderitems_pkey PRIMARY KEY (id),	|	Первичный ключ	|	Обеспечивает уникальность записей о пользователях 	|
|	production.orderitems	|	product_id int4 NOT NULL, CONSTRAINT orderitems_order_id_product_id_key UNIQUE (order_id, product_id), CONSTRAINT orderitems_product_id_fkey FOREIGN KEY (product_id) REFERENCES production.products(id)	|	Ограничение, внешний ключ	|	Ограничение обеспечивает уникальность связки ид товара - ид заказа, внешний ключ ссылается на таблицу products	|
|	production.orderitems	|	order_id int4 NOT NULL, CONSTRAINT orderitems_order_id_product_id_key UNIQUE (order_id, product_id), CONSTRAINT orderitems_order_id_fkey FOREIGN KEY (order_id) REFERENCES production.orders(order_id),	|	Ограничение, внешний ключ	|	Ограничение обеспечивает уникальность связки ид товара - ид заказа, внешний ключ ссылается на таблицу orders	|
|	production.orderitems	|	"name" varchar(2048) NOT NULL,	|	Ограничение	|	Наименование не может быть NULL	|
|	production.orderitems	|	price numeric(19, 5) NOT NULL DEFAULT 0, CONSTRAINT orderitems_price_check CHECK ((price >= (0)::numeric)),	|	Ограничение	|	Цена должна быть больше или равна 0	|
|	production.orderitems	|	discount numeric(19, 5) NOT NULL DEFAULT 0, CONSTRAINT orderitems_check CHECK (((discount >= (0)::numeric) AND (discount <= price))),	|	Ограничение	|	Скидка дорлжна быть больше или равна 0 и меньше или равна цене	|
|	production.orderitems	|	quantity int4 NOT NULL, CONSTRAINT orderitems_quantity_check CHECK ((quantity > 0)),	|	Ограничение	|	Количество должно быть больше 0	|
|	production.orders	|	order_id int4 NOT NULL, CONSTRAINT orders_pkey PRIMARY KEY (order_id)	|	Первичный ключ	|	Обеспечивает уникальность номеров заказов	|
|	production.orders	|	order_ts timestamp NOT NULL,	|	Ограничение	|	Не может быть NULL	|
|	production.orders	|	user_id int4 NOT NULL,	|	Ограничение	|	Не может быть NULL	|
|	production.orders	|	bonus_payment numeric(19, 5) NOT NULL DEFAULT 0,	|	Ограничение	|	Не может быть NULL, по умолчанию 0	|
|	production.orders	|	payment numeric(19, 5) NOT NULL DEFAULT 0,	|	Ограничение	|	Не может быть NULL, по умолчанию 0	|
|	production.orders	|	"cost" numeric(19, 5) NOT NULL DEFAULT 0, CONSTRAINT orders_check CHECK ((cost = (payment + bonus_payment))),	|	Ограничение	|	Не может быть NULL, по умолчанию 0, равно сумме оплаты и оплаты бонусами	|
|	production.orders	|	bonus_grant numeric(19, 5) NOT NULL DEFAULT 0,	|	Ограничение	|	Не может быть NULL, по умолчанию 0	|
|	production.orders	|	status int4 NOT NULL,	|	Ограничение	|	Не может быть NULL	|
|	production.orderstatuses	|	id int4 NOT NULL, CONSTRAINT orderstatuses_pkey PRIMARY KEY (id)	|	Первичный ключ	|	Обеспечивает уникальность записей в справочнике статусов заказов	|
|	production.orderstatuses	|	"key" varchar(255) NOT NULL,	|	Ограничение	|	Не может быть NULL	|
|	production.orderstatuslog	|	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY, CONSTRAINT orderstatuslog_pkey PRIMARY KEY (id),	|	Первичный ключ	|	Обеспечивает уникальность записей о сменах статусов заказов	|
|	production.orderstatuslog	|	order_id int4 NOT NULL, CONSTRAINT orderstatuslog_order_id_status_id_key UNIQUE (order_id, status_id), CONSTRAINT orderstatuslog_order_id_fkey FOREIGN KEY (order_id) REFERENCES production.orders(order_id),	|	Ограничение, внешний ключ	|	Ограничение обеспечивает уникальность связки статус - ид заказа, внешний ключ ссылается на таблицу orders	|
|	production.orderstatuslog	|	status_id int4 NOT NULL, CONSTRAINT orderstatuslog_order_id_status_id_key UNIQUE (order_id, status_id), CONSTRAINT orderstatuslog_status_id_fkey FOREIGN KEY (status_id) REFERENCES production.orderstatuses(id)	|	Ограничение, внешний ключ	|	Ограничение обеспечивает уникальность связки статус - ид заказа, внешний ключ ссылается на таблицу orderstatuses	|
|	production.orderstatuslog	|	dttm timestamp NOT NULL,	|	Ограничение	|	Не может быть NULL	|
|	production.products	|	id int4 NOT NULL, CONSTRAINT products_pkey PRIMARY KEY (id),	|	Первичный ключ	|	Обеспечивает уникальность записей о товарах	|
|	production.products	|	"name" varchar(2048) NOT NULL,	|	Ограничение	|	Не может быть NULL	|
|	production.products	|	price numeric(19, 5) NOT NULL DEFAULT 0, CONSTRAINT products_price_check CHECK ((price >= (0)::numeric))	|	Ограничение	|	Не может быть NULL, по умолчанию 0, больше или равно 0	|
|	production.users	|	id int4 NOT NULL, CONSTRAINT users_pkey PRIMARY KEY (id)	|	Первичный ключ	|	Обеспечивает уникальность записей о пользователях 	|
|	production.users	|	"name" varchar(2048) NULL,	|	Отсутствует ограничение	|	Может быть NULL	|
|	production.users	|	login varchar(2048) NOT NULL,	|	Ограничение	|	Не может быть NULL	|










