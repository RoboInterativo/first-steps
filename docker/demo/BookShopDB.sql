--============================ THE CALCULATION GRAPHICAL WORK  ===============--------------------
-- rgr - это типо расчетно графическая работа

/* use master
 drop database rgr_1
GO */

CREATE DATABASE rgr_1
ON PRIMARY
(
    NAME = N'rgr_1',
    FILENAME = N'/var/opt/mssql/data/rgr_1.mdf',  -- Путь к файлу базы данных внутри контейнера
    SIZE = 8192KB,
    FILEGROWTH = 65536KB
)
LOG ON
(
    NAME = N'rgr_1_log',
    FILENAME = N'/var/opt/mssql/data/rgr_1_log.ldf',  -- Путь к файлу лога
    SIZE = 8192KB,
    FILEGROWTH = 65536KB
)
COLLATE Cyrillic_General_CS_AS;
GO

 use [rgr_1]
 go




/*Создаем схемы базы данных*/
CREATE SCHEMA BookSchema
GO

CREATE SCHEMA OrderSchema
GO

---Создание таблицы GENRE - жанры
CREATE TABLE BookSchema.genre
(
		genre_id   BIGINT PRIMARY KEY IDENTITY(1,1),
		name_genre NVARCHAR(30),
);


---Создание таблицы BOOK - книги
CREATE TABLE BookSchema.book
(
		book_id   BIGINT PRIMARY KEY IDENTITY(1,1),
		title     NVARCHAR(30),
		price     DECIMAL(8, 2),
		amount    INT,
);


---Создание таблицы BOOK-GENRE - жанры
CREATE TABLE BookSchema.book_genre
(
    genre_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    CONSTRAINT PK_book_genre PRIMARY KEY (genre_id, book_id),  -- Указан составной первичный ключ
    CONSTRAINT FK_book_genre_GENRE
        FOREIGN KEY (genre_id) REFERENCES BookSchema.genre(genre_id)
            ON DELETE CASCADE,
    CONSTRAINT FK_book_genre_BOOK
        FOREIGN KEY (book_id) REFERENCES BookSchema.book(book_id)
            ON DELETE CASCADE
);
/* CREATE TABLE BookSchema.book_genre
(
		genre_id   BIGINT,
		book_id    BIGINT,
		CONSTRAINT "FK_book_genre_GENRE"
			FOREIGN KEY (genre_id) REFERENCES BookSchema.genre(genre_id)
					ON DELETE CASCADE,
		CONSTRAINT "FK_book_genre_BOOK"
			FOREIGN KEY (book_id) REFERENCES BookSchema.book(book_id)
					ON DELETE CASCADE
); */

---Создание таблицы AUTHOR
CREATE TABLE BookSchema.author
(
    author_id       BIGINT PRIMARY KEY IDENTITY(1,1),
    name_author     NVARCHAR(20),
    surname_author  NVARCHAR(20),
    othc_author     NVARCHAR(20) DEFAULT NULL
);

---Создание таблицы AUTHORS AND BOOKS
CREATE TABLE BookSchema.book_author
(
    author_id   BIGINT NOT NULL,
    book_id     BIGINT NOT NULL,

    CONSTRAINT [FK_book_author_AUTHOR]
        FOREIGN KEY (author_id) REFERENCES BookSchema.author(author_id)
            ON DELETE CASCADE,

    CONSTRAINT [FK_book_author_BOOK]
        FOREIGN KEY (book_id) REFERENCES BookSchema.book(book_id)
            ON DELETE CASCADE
);

---Создание таблицы CITY - города в которых живут клиенты
CREATE TABLE OrderSchema.city
(
    city_id       BIGINT PRIMARY KEY IDENTITY(1,1),
    name_city     NVARCHAR(30)
);

---Создание таблицы STREET - улицы
CREATE TABLE OrderSchema.street
(
    street_id       BIGINT PRIMARY KEY IDENTITY(1,1),
    street_name     NVARCHAR(30)
);

---Создание таблицы DELIVERY POINT
CREATE TABLE OrderSchema.delivery_point
(
    delivery_point_id BIGINT PRIMARY KEY IDENTITY(1,1),
    street_id         BIGINT,
    city_id           BIGINT,
    home_number       INT,

    CONSTRAINT [FK_delivery_point_CITY]
        FOREIGN KEY (city_id) REFERENCES OrderSchema.city(city_id)
            ON DELETE CASCADE,

    CONSTRAINT [FK_delivery_point_STREET]
        FOREIGN KEY (street_id) REFERENCES OrderSchema.street(street_id)
            ON DELETE CASCADE
);

---Создание таблицы DELIVERY TYPE создание способа доставки
CREATE TABLE OrderSchema.delivery_type
(
    delivery_type_id   BIGINT PRIMARY KEY IDENTITY(1,1),
    delivery_type_name NVARCHAR(30)
);

---Создание таблицы CLIENT
CREATE TABLE OrderSchema.client
(
    client_id         BIGINT PRIMARY KEY IDENTITY(1,1),
    name_client       NVARCHAR(20),
    surname_client    NVARCHAR(20),
    email_client      NVARCHAR(30),
    phone_client      NVARCHAR(15),
    password_client   NVARCHAR(50),
    client_discount   INT DEFAULT 0,
    city_id           BIGINT,
    street_id         BIGINT,

    CONSTRAINT [FK_client_CITY]
        FOREIGN KEY (city_id) REFERENCES OrderSchema.city(city_id)
            ON DELETE CASCADE,

    CONSTRAINT [FK_client_STREET]
        FOREIGN KEY (street_id) REFERENCES OrderSchema.street(street_id)
            ON DELETE CASCADE
);

---Создание таблицы ORDERS
CREATE TABLE OrderSchema.orders
(
    order_id          BIGINT PRIMARY KEY IDENTITY(1,1),
    order_comment     NVARCHAR(255),
    client_id         BIGINT,
    order_price       INT,
    delivery_type_id  BIGINT,
    delivery_point_id BIGINT,
    payment_date      DATE,
    client_discount   INT DEFAULT 0,

    CONSTRAINT [FK_orders_client]
        FOREIGN KEY (client_id) REFERENCES OrderSchema.client (client_id),

    CONSTRAINT [FK_orders_delivery_type_id]
        FOREIGN KEY (delivery_type_id) REFERENCES OrderSchema.delivery_type (delivery_type_id),

    CONSTRAINT [FK_orders_delivery_point_id]
        FOREIGN KEY (delivery_point_id) REFERENCES OrderSchema.delivery_point (delivery_point_id)
);

---Создание таблицы BOOK_ORDER - заказы книг
CREATE TABLE OrderSchema.book_order
(
    order_id         BIGINT,
    book_id          BIGINT,
    amount           INT,
    price            INT,
    product_discount INT DEFAULT NULL,

    CONSTRAINT [FK_order_book_order]
        FOREIGN KEY (order_id) REFERENCES OrderSchema.orders (order_id),

    CONSTRAINT [FK_order_book_from_book]
        FOREIGN KEY (book_id) REFERENCES BookSchema.book (book_id),

    CONSTRAINT PK_book_order PRIMARY KEY (order_id, book_id)
);

---Создание таблицы STEP
CREATE TABLE OrderSchema.step
(
    step_id   BIGINT PRIMARY KEY IDENTITY(1,1),
    name_step NVARCHAR(30)
);

---Создание таблицы ORDER_STEP - шаги заказа
CREATE TABLE OrderSchema.order_step
(
    order_id         BIGINT,
    step_id          BIGINT,
    order_start_date DATE,
    order_end_date   DATE,

    CONSTRAINT [FK_order_step_order]
        FOREIGN KEY (order_id) REFERENCES OrderSchema.orders (order_id),

    CONSTRAINT [FK_order_step_step]
        FOREIGN KEY (step_id) REFERENCES OrderSchema.step (step_id),

    CONSTRAINT PK_order_step PRIMARY KEY (order_id, step_id)
);


INSERT INTO BookSchema.author(surname_author, name_author, othc_author)
VALUES ('Булгаков',    'Михаил',   'Афанасьевич'),
       ('Достоевский', 'Фёдор',    'Михайлович'),
	   ('Есенин',      'Сергей',   'Александрович'),
	   ('Пастернак',   'Борис',    'Леонидович'),
	   ('Лермонтов',   'Михаил',   'Юрьевич'),
	   ('Лондон',      'Джек',      null),
	   ('Пушкин',      'Александр', 'Сергеевич'),
	   ('Джейн',       'Остин',     null),
	   ('Пауло',       'Коэльо',    null);


INSERT INTO BookSchema.genre(name_genre)
VALUES ('Роман'),
       ('Поэзия'),
       ('Приключения'),
	   ('Фантастика'),
	   ('Деловая литература'),
	   ('Художественная литература'),
	   ('Наука'),
	   ('Сказки'),
	   ('Проза'),
	   ('Детская литература'),
	   ('Учебники');


INSERT INTO BookSchema.book(title, price, amount)
VALUES ('Мастер и Маргарита', 670.99, 3),
       ('Белая гвардия', 540.50, 5),
       ('Идиот', 460.00, 10),
       ('Братья Карамазовы', 799.01, 2),
       ('Игрок', 480.50, 10),
       ('Стихотворения и поэмы', 650.00, 15),
       ('Черный человек', 570.20, 6),
       ('Лирика', 518.99, 2),
	   ('Победитель остается один', 2133, 100),
	   ('Алхимик', 2666, 24),
	   ('Встречи. Ежедневник на 2021', 5336, 14),
	   ('Манускрипт, найденный в Акко', 1438, 33),
	   ('Книга воина света', 1438, 22),
	   ('Валькирии', 1438, 7),
	   ('Алеф', 2354, 48),
	   ('Морфий', 766, 108),
	   ('Собачье сердце', 1054, 66),
	   ('Белая гвардия', 731, 47),
	   ('Евгений Онегин', 755, 32),
	   ('Станционный смотритель', 428, 28),
	   ('Капитанская дочка', 4186, 25),
	   ('Дубровский', 1120, 98),
	   ('Герой нашего времени', 1338, 33),
	   ('Малое собрание сочинений', 2038, 24),
	   ('Маленькие трагедии', 502, 12),
	   ('Метель', 428, 46),
	   ('Медный всадник', 901, 10),
	   ('Руслан и Людмила', 715, 9),
	   ('Гордость и предубеждение', 930, 60);


INSERT INTO OrderSchema.step(name_step)
VALUES ('Оплата'),
       ('Упаковка'),
       ('Транспортировка'),
       ('Доставка');


---Создание таблицы BOOK-GENRE - жанры
INSERT INTO BookSchema.book_genre (book_id, genre_id)
VALUES  (1, 1),
		(2, 1),
		(3, 1),
		(4, 1),
		(5, 1),
		(6, 2),
		(7, 2),
		(8, 2),
		(9, 9),
		(10, 9),
		(11, 9),
		(12, 9),
		(13, 9),
		(14, 9),
		(15, 9),
		(16, 6),
		(17, 6),
		(18, 6),
		(19, 6),
		(20, 9),
		(21, 9),
		(22, 9),
		(23, 9),
		(24, 6),
		(25, 6),
		(26, 6),
		(27, 9),
		(28, 2),
		(29, 6);


INSERT INTO BookSchema.book_author(book_id, author_id)
VALUES  (1, 1),
		(2, 1),
		(3, 2),
		(4, 2),
		(5, 2),
		(6, 3),
		(7, 3),
		(8, 3),
		(9, 9),
		(10, 9),
		(11, 9),
		(12, 9),
		(13, 9),
		(14, 9),
		(15, 9),
		(16, 1),
		(17, 1),
		(18, 1),
		(19, 7),
		(20, 7),
		(21, 7),
		(22, 7),
		(23, 7),
		(24, 7),
		(25, 7),
		(26, 7),
		(27, 7),
		(28, 7),
		(29, 8);


INSERT INTO OrderSchema.city(name_city)
VALUES ('Алматы'),
       ('Астана'),
	   ('Шымкент'),
	   ('Тараз'),
	   ('Талдыкорган'),
	   ('Кызылорда'),
       ('Караганда'),
	   ('Актау'),
	   ('Атырау'),
	   ('Семей');


INSERT INTO OrderSchema.street(street_name)
VALUES ('Талапты'),
       ('Ынтымак'),
	   ('Достык'),
	   ('Шевченко'),
	   ('Жандосова'),
	   ('Тимирязева'),
       ('Саина'),
	   ('Байтурсынова'),
	   ('Самал-3'),
	   ('микрорайон-3'),
	   ('микрорайон-1'),
	   ('микрорайон-2'),
	   ('микрорайон-4'),
	   ('микрорайон-5'),
	   ('микрорайон-6');



INSERT INTO OrderSchema.delivery_point(city_id, street_id, home_number)
VALUES  (1, 6, 34),
		(1, 7, 34),
		(2, 3, 15),
		(2, 2, 15),
		(3, 2, 15),
		(3, 8, 15),
		(4, 9, 15),
		(5, 1, 15),
		(6, 1, 15),
		(4, 2, 15),
		(3, 2, 15),
		(2, 6, 15),
		(7, 4, 15),
		(8, 3, 15),
		(4, 7, 15),
		(3, 7, 15),
		(1, 8, 15),
		(1, 2, 15),
		(2, 9, 15);

---Создание таблицы DELIVERY TYPE создание способа доставки
INSERT INTO  OrderSchema.delivery_type (delivery_type_name)

VALUES  ('Доставка'),
	    ('Самовывоз'),
		('Почта');


INSERT INTO OrderSchema.client
(name_client, surname_client, email_clinet, phone_client, password_client, client_discount, city_id, street_id)
VALUES ('Павел', 'Никитин',  'baranov@test', '77776453524', 'password', NULL, 1, 2),
	   ('Катя', 'Ян', 'abramova@test', '77776445524', 'password', NULL, 2, 2),
	   ('Иван', 'Лопатков', 'semenov@test', '77776445524', 'password', NULL, 3, 5),
	   ('Галина', 'Сервеевна', 'galin@test', '77776445524', 'password', NULL, 4, 6),
	   ('Алина', 'Андреева', 'nikitovna@test', '77776445524', 'password', NULL, 1, 7),
	   ('Никита', 'Андреев', 'nikita@test', '77776445524', 'password', NULL, 2, 1),
	   ('Анастасия', 'Васильевна', 'anastasiya@test', '77776445524', 'password', NULL, 2, 1),
	   ('Ксения', 'Веселькова', 'kcenya@test', '77776445524', 'password', NULL, 5, 2),
	   ('Варвара', 'Барышева', 'varvara@test', '77776445524', 'password', NULL, 6, 4),
	   ('Ирина', 'irina@test', 'irinka@test', '77776445524', 'password', NULL, 3, 3),
	   ('Алла', 'Андреева',  'allochka04@test', '77776445524', 'password', NULL, 2, 5),
	   ('Екатерина', 'Шелкова',  'pavel@test', '77776555524', 'password', NULL, 1, 1),
	   ('Арина', 'Махмудина',  'arinka@test', '77776499524', 'password', NULL, 1, 1),
	   ('Павел', 'Никитин',  'baranov@test', '777777453524', 'password', NULL, 1, 2),
	   ('Катя', 'Ян', 'abramova@test', '77776441124', 'password', NULL, 2, 2),
	   ('Иван', 'Лопатков', 'semenov@test', '77976445524', 'password', NULL, 3, 5),
	   ('Галина', 'Сервеевна', 'galin@test', '77976445524', 'password', NULL, 4, 6),
	   ('Алина', 'Андреева', 'nikitovna@test', '77796445524', 'password', NULL, 1, 7),
	   ('Никита', 'Андреев', 'nikita@test', '77776495524', 'password', NULL, 2, 1),
	   ('Анастасия', 'Васильевна', 'anastasiya@test', '77776445524', 'password', NULL, 2, 1),
	   ('Ксения', 'Веселькова', 'kcenya@test', '77776445524', 'password', NULL, 5, 2),
	   ('Варвара', 'Барышева', 'varvara@test', '5555555555', 'password', NULL, 6, 4),
	   ('Ирина', 'irina@test', 'irinka@test', '77776466524', 'password', NULL, 3, 3),
	   ('Алла', 'Андреева',  'allochka04@test', '77976445524', 'password', NULL, 2, 5),
	   ('Екатерина', 'Шелкова',  'pavel@test', '97776445524', 'password', NULL, 1, 1),
	   ('Арина', 'Махмудина',  'arinka@test', '77766445524', 'password', NULL, 1, 1);


INSERT INTO OrderSchema.orders (order_comment, client_id, order_price, delivery_type_id, delivery_point_id, payment_date, client_discount)
VALUES ('Доставка только вечером',               1, 0, 1, 1, getdate(), 0),
       ('Упаковать каждую книгу по отдельности', 2, 0, 2, 4, getdate(), 0),
       (NULL,                                    3, 0, 1, 3, getdate(), 10),
       ('Чем быстрее тем лучше',                 4, 0, 1, 5, getdate(), 5);


INSERT INTO OrderSchema.book_order(order_id, book_id, amount)
VALUES (1, 1, 1),
       (1, 7, 2),
       (2, 8, 2),
       (3, 3, 2),
       (3, 2, 1),
       (3, 1, 1),
       (4, 5, 1),
	   (4, 9, 3),
	   (4, 1, 2),
	   (4, 15, 2),
	   (4, 7, 1),
	   (4, 2, 1),
       (4, 4, 1),
       (4, 3, 1),
	   (4, 29, 2),
	   (4, 6, 1);


INSERT INTO OrderSchema.order_step(order_id, step_id, order_start_date, order_end_date)
VALUES (1, 1, '2020-02-20', '2020-02-20'),
       (1, 2, '2020-02-20', '2020-02-21'),
       (1, 3, '2020-02-22', '2020-03-07'),
       (1, 4, '2020-03-08', '2020-03-08'),
       (2, 1, '2020-02-28', '2020-02-28'),
       (2, 2, '2020-02-29', '2020-03-01'),
       (2, 3, '2020-03-02', NULL),
       (2, 4, NULL, NULL),
       (3, 1, '2020-03-05', '2020-03-05'),
       (3, 2, '2020-03-05', '2020-03-06'),
       (3, 3, '2020-03-06', '2020-03-10'),
       (3, 4, '2020-03-11', NULL),
       (4, 1, '2020-03-20', NULL),
       (4, 2, NULL, NULL),
       (4, 3, NULL, NULL),
       (4, 4, NULL, NULL);


	   /* ДОБАВЛЯЕМ ПРЕДСТАВЛЕНИЯ */

GO
-- 1.	Посчитать, сколько раз была заказана каждая книга.
CREATE VIEW show_book_orders_amount
AS
    select bo.book_id, count(*) as 'Продано', b.title
        from OrderSchema.book_order as bo
            inner join BookSchema.book as b
                on b.book_id = bo.book_id

    group by bo.book_id, b.title
GO

-- select * from dbo.show_book_orders_amount

-- 2.	Вывести города, в которых живут клиенты магазина
CREATE VIEW show_clients_cities
AS
    select name_client, surname_client, name_city
        from OrderSchema.client as cl
            inner join OrderSchema.city as c
                on c.city_id = cl.city_id

GO

--select * from dbo.show_clients_cities

-- 3.	Вывести информацию об ждущих оплату заказах

CREATE VIEW wait_payment_orders
AS
	select os.order_id, os.step_id, os.order_start_date, os.order_end_date, st.name_step from OrderSchema.order_step as os
		inner join OrderSchema.step as st
			on os.step_id = st.step_id
				where st.step_id =
					(select step_id
						from OrderSchema.step
							where name_step = 'Оплата') and os.order_end_date is null
GO
--select * from dbo.wait_payment_orders

-- 4.	Вывести информацию о движении каждого заказа.

CREATE VIEW show_order_details
AS
select os.order_id, os.order_start_date as 'Дата исполнения',
	(select name_step from OrderSchema.step
			where step_id = os.step_id) as steps , o.order_comment
				from OrderSchema.order_step as os
					inner join OrderSchema.orders as o
						on os.order_id = o.order_id

GO

-- select * from dbo.show_order_details

-- 5.	ПРОЦЕДУРА Вывести клиентов, которые заказывали книги определенного автора.

CREATE PROCEDURE show_order_by_author_surname(@author_surname NVARCHAR(50))
AS
BEGIN
	select oo.order_id, b.title, oo.client_id, ba.author_id
		from OrderSchema.orders as oo

		inner join OrderSchema.book_order as ob
				on oo.order_id = ob.order_id

		inner join BookSchema.book as b
				on ob.book_id = b.book_id

		inner join BookSchema.book_author as ba
				on ob.book_id = ba.book_id

		where ba.author_id = (select aa.author_id
								from BookSchema.author as aa
									  where aa.surname_author = @author_surname)
END
GO
-- exec show_order_by_author_surname 'Булгаков'


--6. ПРОЦЕДУРА Сравнить выручку за текущий и прошлый год или месяц.

CREATE PROCEDURE show_earning_by_month (@month1 INT, @month2 INT)
AS
BEGIN
	select o.client_id, bo.book_id, b.price, bo.amount,  bo.amount * b.price as full_book_price, os.order_start_date, os.order_end_date from OrderSchema.book_order as bo
		inner join BookSchema.book as b
			on b.book_id = bo.book_id
		inner join OrderSchema.orders as o
			on o.order_id = bo.order_id
		inner join OrderSchema.order_step as os
			on os.order_id = o.order_id and os.step_id=4  -- 4 айдишка для доставленных заказов
		where os.order_start_date is not null and  month(os.order_start_date) between @month1 and @month2


	select sum(bo.amount * b.price) as 'Полная сумма заказа' from OrderSchema.book_order as bo
		inner join BookSchema.book as b
			on b.book_id = bo.book_id
		inner join OrderSchema.orders as o
			on o.order_id = bo.order_id
		inner join OrderSchema.order_step as os
			on os.order_id = o.order_id and os.step_id=4 and month(os.order_start_date) between @month1 and @month2  -- Промежуток в 1 месяц из базы
END

-- drop procedure show_earning_by_month
exec show_earning_by_month 3, 4


GO
--select * from BookSchema.author

CREATE PROCEDURE add_new_author(@name NVARCHAR(50), @surname NVARCHAR(50), @otch NVARCHAR(50)) AS
BEGIN
	INSERT INTO BookSchema.author (name_author, surname_author, othc_author)
	VALUES
	(@name, @surname, @otch);
END

GO

-- select * from BookSchema.genre
CREATE PROCEDURE add_new_genre(@name_genre NVARCHAR(50)) AS
BEGIN
	INSERT INTO BookSchema.genre(name_genre)
	VALUES      (@name_genre);
END

GO

CREATE PROCEDURE add_new_book (@title NVARCHAR(50), @price INT, @amount INT, @genre_id BIGINT, @author_id BIGINT) AS
BEGIN
	INSERT INTO BookSchema.book (title, price, amount)
	VALUES
	(@title, @price, @amount);

	DECLARE @book_id BIGINT
	set @book_id = (select max(book_id) from BookSchema.book)

	INSERT INTO BookSchema.book_author(book_id, author_id)
	VALUES
	(@book_id, @author_id);

	INSERT INTO BookSchema.book_genre(book_id, genre_id)
	VALUES
	(@book_id, @author_id);
END
GO

-- Выводим полное имя автора ФИО
CREATE FUNCTION show_full_author_name (@author_ID BIGINT)
	RETURNS NVARCHAR(50)
BEGIN
	DECLARE @full_name NVARCHAR(50)
	SET @full_name = (select LEFT(surname_author, 1) + '. ' + LEFT(name_author, 1)  + '. ' + othc_author from BookSchema.author where author_id = @author_ID)
	IF @full_name is NULL
		SET @full_name = (select surname_author + ' ' + name_author  from BookSchema.author where author_id = @author_ID)

	RETURN @full_name
END
GO
--  select dbo.show_full_author_name(author_id) from BookSchema.author
GO

-- Для установки цены по количеству заказанных книг
--select * from OrderSchema.book_order
create trigger book_order_price_trigger on OrderSchema.book_order
	AFTER insert, update, delete
	as declare  @book_id    BIGINT,
				@amount     INT,
				@book_price INT,
				@product_discount INT,
				@order_id   BIGINT

	update OrderSchema.book_order
		set price = amount * (select price from BookSchema.book where book_id = OrderSchema.book_order.book_id),
			product_discount = 0 where product_discount is null

	select
		@book_id = I.book_id,
		@amount  = I.amount,
		@order_id = I.order_id,
		@product_discount = I.product_discount
	from inserted I

	IF @product_discount is NULL
	BEGIN
		SET @product_discount = 0
	END

	SET @book_price = (select price from BookSchema.book where book_id = @book_id) - (select price from BookSchema.book where book_id = @book_id) * @product_discount / 100
	print 'Цена книги за единицу ' + cast(@book_price as nvarchar(5))
	update OrderSchema.book_order
		set price = (@book_price * @amount), product_discount = @product_discount
				where order_id = @order_id and  book_id = @book_id


-- drop trigger OrderSchema.book_order_price_trigger
-- select * from BookSchema.book

select * from OrderSchema.book_order

update OrderSchema.book_order
	set amount =  ABS(CHECKSUM(NEWID()) % 11) + 1 where price is null -- (select top 1 student_ID from StudySchema.STUDENT as s where s.group_ID = StudySchema.GROUPS.group_ID)
go


update OrderSchema.book_order
	set amount = 10, product_discount=10 where order_id = 1 and 7 = book_id


select * from OrderSchema.book_order
select * from OrderSchema.orders

GO
create function calculate_orders_sum(@order_id bigint, @client_discount int)
-- Считает сумму книг из book_order
returns int
BEGIN
	declare @order_price		 BIGINT
	set @order_price = (select sum(price) from OrderSchema.book_order where OrderSchema.book_order.order_id = @order_id)
		                   - (select sum(price) from OrderSchema.book_order where OrderSchema.book_order.order_id = @order_id) * @client_discount / 100 -- Минус скидка
	return @order_price
END
--  select dbo.calculate_orders_sum(1, 0)

GO

CREATE TRIGGER CALCULATE_FINAL_SUM on OrderSchema.orders
-- Триггер для учета полной стоимости заказа
	AFTER insert, update, delete
		as
		update OrderSchema.orders
			set order_price = dbo.calculate_orders_sum(order_id, OrderSchema.orders.client_discount) where order_id =  OrderSchema.orders.order_id

-- drop trigger OrderSchema.CALCULATE_FINAL_SUM


select * from OrderSchema.orders

update OrderSchema.orders
	set client_discount = 10

select * from OrderSchema.orders
select * from OrderSchema.book_order where order_id =2

GO

create table user_orders_journal (
	operation_type nvarchar(150) null,
	username		   nvarchar(20) null,
	action_date    date      null,
);
go


-- drop table dbo.user_actions_journal
-- Триггер на аудит
create trigger user_actions_trigger
	ON [OrderSchema].[orders]
	AFTER UPDATE, INSERT, DELETE AS
BEGIN
	DECLARE @operation_type  NVARCHAR (150)

	-- update
	IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		SET @operation_type = 'UPDATE'
	END

	-- insert
	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
	BEGIN
		SET @operation_type = 'INSERT'
	END

	-- delete
	IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
	BEGIN
		SET @operation_type = 'DELETE'
	END
	SET @operation_type = 'DELETE ' + 'from [OrderSchema].[orders]'
	insert into user_orders_journal
		VALUES (@operation_type , current_user, getdate());
END;

GO

select * from user_orders_journal


-- Создаем логины для хода в БД

create login AdminLogin with password='P@ssw0rd1'
create login UserLogin with password='P@ssw0rd2'

 go
create user admin_user for login AdminLogin
create user user_user for login UserLogin



grant connect, select, update, insert, delete to admin_user --  Рарешаем admin_user доступ к базе

grant select to user_user

revoke select on [OrderSchema].[orders] from user_user       -- Но запрещаем селект с таблицы Заказов


exec sp_helprotect null, admin_user
exec sp_helprotect null, user_user


exec sp_helplogins AdminLogin
exec sp_helplogins UserLogin


GO
-- функция
CREATE FUNCTION print_authors_full_name(@author_id bigint)
returns nvarchar(50)
as
BEGIN
	declare @full_name NVARCHAR(50)
	set @full_name = (select name_author + ' ' + surname_author from BookSchema.author where author_id = @author_id)
	IF ((select othc_author from BookSchema.author where author_id = @author_id) is not null)
	BEGIN
		set @full_name = (select name_author + ' ' + surname_author + ' ' + othc_author from BookSchema.author where author_id = @author_id)
	END
	return @full_name
END
GO

-- Считает кол-во книг автора
CREATE FUNCTION print_authors_books_cnt(@author_id bigint)
returns int
as
BEGIN
	declare @cnt int
	set @cnt = (select count(*) from BookSchema.book_author where author_id = @author_id)

	return @cnt
END
GO

-- Берет название книги по айдишке
CREATE FUNCTION get_book_title(@book_id bigint)
returns NVARCHAR(50)
as
BEGIN
	declare @full_name NVARCHAR(50)
	set @full_name = (select title from BookSchema.book where book_id = @book_id)
	return @full_name
END
GO

-- drop function dbo.get_book_title
--SELECT dbo.get_book_title(book_id) FROM BookSchema.book
--SELECT dbo.print_authors_full_name(author_id) FROM BookSchema.author


-- КУРСОР ДЛЯ ВЫВОДА АВТОРОВ И КОЛ-ВА КНИГ
-- Объявление переменных
DECLARE @book_id BIGINT, @title NVARCHAR(50), @price INT, @author_id BIGINT;

DECLARE author_cursor CURSOR FOR
	SELECT author_id FROM [BookSchema].author

	-- Открываем курсор
	OPEN author_cursor

	-- Извлечь строку из курсора в переменные
	FETCH NEXT FROM author_cursor
		INTO @author_id;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT dbo.print_authors_full_name(@author_id) + ' кол-во книг ' + CAST(dbo.print_authors_books_cnt(@author_id)  as nchar(15));
		-- По айдишкам книг
			DECLARE book_author_cursor CURSOR FOR
			SELECT book_id FROM [BookSchema].book_author
			where author_id = @author_id
			OPEN book_author_cursor

			FETCH NEXT FROM book_author_cursor
				INTO @book_id;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT '        ' + dbo.get_book_title(@book_id);

				FETCH NEXT FROM book_author_cursor
				INTO @book_id;
			END
			CLOSE book_author_cursor;
			DEALLOCATE book_author_cursor;
		-- К след айдишке автора
		FETCH NEXT FROM author_cursor
		INTO @author_id;
	END
-- Дроп курсра
CLOSE author_cursor;
DEALLOCATE author_cursor;

GO
select * from BookSchema.book
