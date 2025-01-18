use master

CREATE DATABASE [lab_6]
	CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'lab_6', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DEV\MSSQL\DATA\lab_6.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'lab_6_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DEV\MSSQL\DATA\lab_6_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 COLLATE Cyrillic_General_CS_AS
 GO

 use lab_6
 go

/* StudySchema (таблицы Группы, Студенты, Предметы SUBJECT, Учебный план STUDY и Успеваемость PROGRESS) */
CREATE SCHEMA StudySchema
GO

/* DekanatSchema (таблицы Кафедры и Преподаватели) */
CREATE SCHEMA DekanatSchema
GO

/* Таблица ГРУППЫ СТУДЕНТОВ */
CREATE TABLE StudySchema.GROUPS (
	group_ID bigint IDENTITY (1,1) PRIMARY KEY,
	group_NAME nvarchar(20) NOT NULL,
	group_KOLSTUD int NULL default 1,
	group_COURSE int NOT NULL,
);

/* Таблица СПЕЦИАЛЬНОСТЬ СТУДЕНТОВ */
CREATE TABLE StudySchema.SPECIALITY (
	speciality_ID bigint IDENTITY (1,1) PRIMARY KEY,
	speciality_NAME nvarchar(20) NOT NULL,
);

/* Таблица ПРЕДМЕТЫ СТУДЕНТОВ */
CREATE TABLE StudySchema.SUBJECTS ( 
	 subject_ID bigint IDENTITY (1,1) NOT NULL PRIMARY KEY,
	 subject_NAME nvarchar(40) NOT NULL,

);


---- Создаем таблицу СТРАНЫ ----
create table [StudySchema].[COUNTRY] (
	country_ID bigint IDENTITY (1,1) NOT NULL PRIMARY KEY,
	country_NAME nvarchar(50),
);
---- Создаем таблицу ГОРОДА ----
create table [StudySchema].[CITY] (
	city_ID bigint IDENTITY (1,1) NOT NULL PRIMARY KEY,
	city_NAME nvarchar(50),
	country_ID bigint,

	CONSTRAINT FK_COUNTRY FOREIGN KEY (country_ID) REFERENCES [StudySchema].[COUNTRY] (country_ID),
)

/* Таблица СТУДЕНТ */
CREATE TABLE StudySchema.STUDENT (

	student_ID bigint IDENTITY (1,1) PRIMARY KEY,
	student_NAME nvarchar(20) NOT NULL,
	student_SURNAME nvarchar(20) NOT NULL,
	student_OTCH nvarchar(20),
	student_DATE date NOT NULL DEFAULT(getdate()),
	student_ADDRESS nvarchar(30) NOT NULL,
	student_male int NOT NULL,
	student_STAR bigint,

	group_ID bigint NOT NULL FOREIGN KEY REFERENCES StudySchema.GROUPS(group_ID) ON DELETE CASCADE,
	speciality_ID bigint NOT NULL FOREIGN KEY REFERENCES StudySchema.SPECIALITY(speciality_ID) ON DELETE CASCADE,
	city_ID bigint,
	stipendia_value bigint NULL DEFAULT 20000,

	CONSTRAINT FK_Student_Student FOREIGN KEY (student_STAR) REFERENCES StudySchema.STUDENT (student_ID),
	CONSTRAINT FK_student_city_id FOREIGN KEY (city_ID) REFERENCES StudySchema.CITY(city_ID)
);


/* Таблица НОМЕРА ТЕЛЕфОНОВ СТУДЕНТОВ */
CREATE TABLE StudySchema.STUDENT_PHONES ( 
	 phone_NUMBER bigint PRIMARY KEY,
	 student_ID bigint NOT NULL FOREIGN KEY REFERENCES StudySchema.STUDENT(student_ID) ON DELETE CASCADE,
	 
	 phone_owner nvarchar(30) DEFAULT N'Студент',
);

/* Таблица ХОББИ СТУДЕНТОВ */
CREATE TABLE StudySchema.HOBBY ( 
	 hobby_ID bigint IDENTITY (1,1) PRIMARY KEY,
	 hobby_NAME varchar(30) NOT NULL,
);


/* Таблица КРУЖКИ (КЛУБЫ) СТУДЕНТОВ */
CREATE TABLE StudySchema.CLUBS ( 
	 hobby_ID bigint NOT NULL FOREIGN KEY REFERENCES StudySchema.HOBBY(hobby_ID) ON DELETE CASCADE,
	 student_ID bigint NOT NULL FOREIGN KEY REFERENCES StudySchema.STUDENT(student_ID) ON DELETE CASCADE,

	 CONSTRAINT PK_CLUBS PRIMARY KEY (hobby_ID, student_ID),
);


/* Таблица КАфЕДРЫ */
CREATE TABLE DekanatSchema.CHAIR (

	chair_ID bigint IDENTITY (1,1) NOT NULL PRIMARY KEY,
	chair_NAME nvarchar(20) NOT NULL,
	chair_PHONE varchar(10) NOT NULL,
	chair_CHIEF nvarchar(50) NOT NULL,

);

/* Таблица ПРЕПОДОВАТЕЛИ */
CREATE TABLE DekanatSchema.TEACHER (

	teacher_ID bigint IDENTITY (1,1) NOT NULL PRIMARY KEY,
	teacher_SURNAME nvarchar(20) NOT NULL,
	teacher_NAME nvarchar(20) NOT NULL,
	teacher_OTCH nvarchar(20) NOT NULL,
	teacher_POSITION nvarchar(20) NOT NULL,
	teacher_STEPEN nvarchar(15) NOT NULL,
	chair_ID bigint NOT NULL,

	CONSTRAINT FK_CHAIR FOREIGN KEY (chair_ID) REFERENCES DekanatSchema.CHAIR (chair_ID),
);

/* Таблица УЧЕБНЫЙ ПЛАН */
CREATE TABLE StudySchema.STUDY ( 
	group_ID bigint NOT NULL FOREIGN KEY REFERENCES StudySchema.GROUPS(group_ID) ON DELETE CASCADE,
	subject_ID bigint NOT NULL FOREIGN KEY REFERENCES StudySchema.SUBJECTS (subject_ID),
	teacher_ID bigint NOT NULL FOREIGN KEY REFERENCES DekanatSchema.TEACHER(teacher_ID) ON DELETE CASCADE,
	kredit_cnt int,
	total_hours int NOT NULL,
	lection_hours int NOT NULL,
	practice_hours int NOT NULL,
	labor_hours int,

	CONSTRAINT PK_STUDY PRIMARY KEY (group_ID, subject_ID, teacher_ID),
);

/* Таблица УСПЕВАЕМОСТЬ СТУДЕНТОВ */
CREATE TABLE StudySchema.PROGRESS ( 
	student_ID bigint NOT NULL 	FOREIGN KEY REFERENCES StudySchema.STUDENT (student_ID),

	subject_ID bigint NOT NULL,
	teacher_ID bigint NOT NULL,
	group_ID bigint NOT NULL,

	pr_date date NULL DEFAULT(getdate()),
	ocenka int NOT NULL CHECK (ocenka in (0,1,2,3,4,5,6,7,8,9,10)) DEFAULT(0),

	CONSTRAINT FK_PROGRESS FOREIGN KEY (group_ID, subject_ID,teacher_ID ) REFERENCES StudySchema.STUDY (group_ID, subject_ID, teacher_ID ),
	CONSTRAINT PK_PROGRESS PRIMARY KEY (student_ID, group_ID, teacher_ID, subject_ID),
);


/* Изменяем стобец Номер телефона на 12 символов так как не вмещается +7 */
ALTER TABLE DekanatSchema.CHAIR ALTER COLUMN chair_PHONE varchar(12);
ALTER TABLE DekanatSchema.CHAIR ALTER COLUMN chair_NAME nvarchar(70);
ALTER TABLE DekanatSchema.CHAIR ALTER COLUMN chair_CHIEF nvarchar(70);


INSERT INTO DekanatSchema.CHAIR(chair_NAME, chair_PHONE,chair_CHIEF) VALUES
(N'Кафедра алгебры и геометрии', '77437013276', N'Некрасов Дональд Данилович'),
(N'Кафедра безопасности информационных систем', '77649333157', N'Мартынов Валерий Станиславович'),
(N'Кафедра высшей математики', '77399308302', N'Гущин Яков Андреевич'),
(N'Кафедра дифференциальных уравнений и теории управления', '77496284664', N'Богданов Нелли Адольфович'),
(N'Кафедра информатики и вычислительной математики', '77371994315', N'Жуков Мартын Витальевич'),
(N'Кафедра математического моделирования в механике', '77861280428', N'Капустин Георгий Натанович'),
(N'Кафедра функционального анализа и теории функций', '77816222179', N'Юдин Елисей Онисимович'),
(N'Кафедра геоинформатики и информационной безопасности', '77561595652', N'Михеев Августин Тимурович'),
(N'Кафедра информационных систем и технологий', '77115396275', N'Терентьев Рудольф Георгиевич'),
(N'Кафедра прикладных математики и физики', '77700209813', N'Семёнов Казимир Никитевич'),
(N'Кафедра программных систем', '77391302753', N'Андреев Аверкий Владимирович'),
(N'Кафедра технической кибернетики', '77470433591', N'Третьяков Терентий Парфеньевич'),
(N'Кафедра конструирования и технологии электронных систем и устройств', '77932603270', N'Дементьев Ибрагил Феликсович'),
(N'Кафедра лазерных и биотехнических систем', '77886108666', N'Лыткин Агафон Еремеевич'),
(N'Кафедра наноинженерии', '77379298962', N'Мамонтов Вилли Фролович'),
(N'Кафедра радиотехники', '77937789609', N'Фомичёв Ермолай Федорович'),
(N'Кафедра электротехники', '77449590254', N'Петров Валерий Эдуардович'),
(N'Кафедра социологии и культурологии', '77369776353', N'Юдин Степан Ростиславович'),
(N'Кафедра социологии политических и региональных процессов', '77658218629', N'Белоусов Глеб Владленович'),
(N'Кафедра теории и технологии социальной работы', '77485373335', N'Горбунов Тарас Арсеньевич');


INSERT INTO DekanatSchema.TEACHER (teacher_SURNAME, teacher_NAME, teacher_OTCH, teacher_POSITION, teacher_STEPEN, chair_ID) VALUES
(N'Титов', N'Лазарь', N'Евсеевич', N'Ассистент', N'Лаборант', '3'),
(N'Ефремов', N'Осип', N'Оскарович', N'Ассистент', N'Лаборант', '17'),
(N'Горшков', N'Иосиф', N'Альвианович', N'Ассистент', N'Магистр', '10'),
(N'Кулагин', N'Август', N'Альвианович', N'Аспирант', N'Доцент', '3'),
(N'Рыбаков', N'Афанасий', N'Игнатьевич', N'Преподаватель', N'Магистр', '12'),
(N'Фадеев', N'Аристарх', N'Ярославович', N'Аспирант', N'Магистр', '7'),
(N'Цветков', N'Вениамин', N'Николаевич', N'Профессор', N'Лаборант', '19'),
(N'Кириллов', N'Аркадий', N'Евгеньевич', N'Ассистент', N'Магистр', '5'),
(N'Борисов', N'Алексей', N'Фролович', N'Стажер', N'Доцент', '10'),
(N'Русаков', N'Иван', N'Максович', N'Профессор', N'Доцент', '9'),
(N'Красильников', N'Исак', N'Мэлсович', N'Аспирант', N'Докторант', '10'),
(N'Журавлёв', N'Аввакуум', N'Данилович', N'Доцент', N'Лаборант', '12'),
(N'Ермаков', N'Кондратий', N'Анатольевич', N'Преподаватель', N'Доцент', '17'),
(N'Алексеев', N'Гаянэ', N'Мэлсович', N'Докторант', N'Докторант', '11'),
(N'Третьяков', N'Нисон', N'Альвианович', N'Аспирант', N'Доцент', '14'),
(N'Гришин', N'Вилен', N'Антонович', N'Докторант', N'Профессор', '18'),
(N'Марков', N'Любовь', N'Геннадиевич', N'Докторант', N'Лаборант', '7'),
(N'Воронцов', N'Вячеслав', N'Еремеевич', N'Стажер', N'Профессор', '7'),
(N'Богданов', N'Валентин', N'Геласьевич', N'Преподаватель', N'Докторант', '1'),
(N'Доронин', N'Остап', N'Эльдарович', N'Доцент', N'Магистр', '20');


insert into DekanatSchema.TEACHER
([teacher_SURNAME],[teacher_NAME],[teacher_OTCH],[teacher_POSITION], [teacher_STEPEN],[chair_ID] ) 
values
('Некрасов', 'Дональд', 'Данилович', 'Доцент', 'Зав.кафедры', 1),
('Мартынов', 'Валерий', 'Станиславович', 'Профессор', 'Зав.кафедры', 2),
('Гущин', 'Яков', 'Андреевич', 'Профессор', 'Зав.кафедры', 3),
('Богданов', 'Нелли', 'Адольфович', 'Профессор', 'Зав.кафедры', 4),
('Жуков', 'Мартын', 'Витальевич', 'Профессор', 'Зав.кафедры', 5),
('Капустин', 'Георгий', 'Натанович', 'Профессор', 'Зав.кафедры', 6),
('Юдин', 'Елисей', 'Онисимович', 'Доцент', 'Зав.кафедры', 7),
('Михеев', 'Августин', 'Тимурович', 'Доцент', 'Зав.кафедры', 8),
('Терентьев', 'Рудольф', 'Георгиевич', 'Доцент', 'Зав.кафедры', 9),
('Семёнов', 'Казимир', 'Никитевич', 'Профессор', 'Зав.кафедры', 10),
('Андреев', 'Аверкий', 'Владимирович', 'Профессор', 'Зав.кафедры', 11),
('Третьяков', 'Терентий', 'Парфеньевич', 'Доцент', 'Зав.кафедры', 12),
('Дементьев', 'Ибрагил', 'Феликсович', 'Доцент', 'Зав.кафедры', 13),
('Лыткин', 'Агафон', 'Еремеевич', 'Профессор', 'Зав.кафедры', 14),
('Мамонтов', 'Вилли', 'Фролович', 'Профессор', 'Зав.кафедры', 15),
('Фомичёв', 'Ермолай', 'Федорович', 'Доцент', 'Зав.кафедры', 16),
('Петров', 'Валерий', 'Эдуардович', 'Доцент', 'Зав.кафедры', 17),
('Юдин', 'Степан', 'Ростиславович', 'Доцент', 'Зав.кафедры', 18),
('Белоусов', 'Глеб', 'Владленович', 'Доцент', 'Зав.кафедры', 19),
('Горбунов', 'Тарас', 'Арсеньевич', 'Профессор', 'Зав.кафедры', 20);


INSERT INTO [StudySchema].[SUBJECTS] ([subject_NAME]) VALUES
(N'Английский язык'),
(N'Русский язык'),
(N'Безопасность жизнедеятельности'),
(N'Политология'),
(N'Биология'),
(N'География'),
(N'Гражданское право'),
(N'Немецуий язык'),
(N'Журналистика'),
(N'Информатика'),
(N'История'),
(N'Культурология'),
(N'Литература'),
(N'Маркетинг'),
(N'Математика'),
(N'Медицина'),
(N'Менеджмент'),
(N'Педагогика'),
(N'Программирование'),
(N'ПО'),
(N'Проектирование'),
(N'Психология'),
(N'Сельское хозяйство'),
(N'Дискретная математика'),
(N'Социология'),
(N'Строительство'),
(N'Туризм'),
(N'Физика'),
(N'Философия'),
(N'Финансы'),
(N'Химия'),
(N'Экономика');



ALTER TABLE [StudySchema].[SPECIALITY] ALTER COLUMN speciality_NAME nvarchar(50) NOT NULL;
INSERT INTO [StudySchema].[SPECIALITY] (speciality_NAME) VALUES
(N'Государственное и муниципальное управление'),
(N'Менеджмент'),
(N'Экономика'),
(N'Бизнес-информатика'),
(N'Юриспруденция'),
(N'Реклама и связи с общественностью'),
(N'Международные отношения'),
(N'Управление персоналом'),
(N'Информатика и вычислительная техника'),
(N'Экономическая безопасность'),
(N'Лечебное дело'),
(N'Гостиничное_дело '),
(N'Туризм '),
(N'Таможенное дело');


ALTER TABLE [StudySchema].[HOBBY] ALTER COLUMN [hobby_NAME] nvarchar(30) NOT NULL;
INSERT INTO [StudySchema].[HOBBY] ([hobby_NAME]) VALUES 
(N'Теннис'),
(N'Фокусы'),
(N'Фотография'),
(N'Футбол'),
(N'Рыбалка'),
(N'Паркур'),
(N'Музыка'),
(N'Кулинария'),
(N'Йога'),
(N'Боулинг'),
(N'Автомобили'),
(N'Граффити'),
(N'Головоломки');


--Добавляем ограничение к таблице группы уникальность для атрибута group_NAME
ALTER TABLE [StudySchema].[GROUPS] ADD CONSTRAINT UK_Grup UNIQUE (group_NAME);

INSERT INTO [StudySchema].[GROUPS] ([group_NAME], [group_COURSE]) VALUES 
(N'ГИМУ 21-8', 1),
(N'М 19-3', 3),
(N'Э 19-8', 3),
(N'Б 19-3', 3),
(N'Ю 18-4', 4),
(N'РИССО 21-1', 1),
(N'МО 19-1', 3),
(N'УП 18-5', 4),
(N'ИИВТ 18-5', 4),
(N'ЭБ 19-2', 3),
(N'ЛД 18-8', 4),
(N'ГД 21-7', 1),
(N'Т 19-8', 3),
(N'ТД 18-6', 4);


--Добавляем к таблице студента stund_GRANT - есть или нет гранта
ALTER TABLE [StudySchema].[STUDENT] ADD stund_GRANT nvarchar(5) DEFAULT 'yes';

/* Изменяем type of пол студента на nvarchar */
ALTER TABLE StudySchema.STUDENT ALTER COLUMN student_male nvarchar(1) NOT NULL;

/* Проверка для пола, ввод только М или Ж */
ALTER TABLE [StudySchema].[STUDENT] ADD CHECK ([student_male]=N'М' OR [student_male]=N'Ж');

/* Увеличиваем адрес до 50 символов */
ALTER TABLE StudySchema.STUDENT ALTER COLUMN student_ADDRESS nvarchar(50);


INSERT INTO [StudySchema].[STUDENT] 
([student_SURNAME], [student_NAME], [student_OTCH], [student_ADDRESS], [student_male], [student_STAR], [group_ID], [speciality_ID]) VALUES 
(N'Зиновьев', N'Аристарх',N'Агафонович',N'20 июня, улица (ШАНЫРАК-1)',N'М', 1, 1, 4),
(N'Давыдов', N'Эрик',N'Константинович',N'40 лет Победы, переулок (КАРАСУ)',N'М', 1, 1, 6),
(N'Туров', N'Касьян',N'Григорьевич',N'10а мкр.',N'М', 1, 1, 5),
(N'Красильников', N'Корней',N'Георгьевич',N'2-я Пчеловодная, улица',N'М', 1, 1, 1),
(N'Данилов', N'Эдуард',N'Геннадиевич',N'16-я линия, улица, ныне — Катаева улица',N'М', 1, 1, 11),
(N'Суворов', N'Лука',N'Платонович',N'22-я линия, улица',N'М', 1, 1, 4),
(N'Сафонов', N'Любовь',N'Тарасович',N'2-я Братская, улица',N'М', 1, 2, 9),
(N'Ефимов', N'Влас',N'Егорович',N'3-я Вишневского, улица',N'М', 1, 2, 9),
(N'Емельянов', N'Даниил',N'Николаевич',N'2-я Гончарная, улица',N'М', 1, 2, 2),
(N'Аксёнова', N'Дебора',N'Максимовна',N'20 июня, улица (ШАНЫРАК-1)',N'Ж', 1, 2, 3),
(N'Лукина', N'Диша',N'Авксентьевна',N'2-я Пчеловодная, улица',N'Ж', 1, 2, 5),
(N'Щербакова', N'Тала',N'Данииловна',N'8-я линия, улица',N'Ж', 1, 3, 11),
(N'Пахомова', N'Клавдия',N'Глебовна',N'2-я Гончарная, улица',N'Ж', 1, 3, 10),
(N'Крюкова', N'Доминика',N'Филатовна',N'2 мкр.',N'Ж', 1, 3, 13),
(N'Одинцова', N'София',N'Еремеевна',N'4-я Кирпичнозаводская, улица',N'Ж', 1, 3, 12),
(N'Суханова', N'Ксения',N'Пётровна',N'21-я линия, улица, с 1999 г. — Егизбаева улица',N'Ж', 1, 3, 7),
(N'Волкова', N'Лиза',N'Прокловна',N'2-я Братская, улица',N'Ж', 1, 4, 13),
(N'Фокина', N'Магдалина',N'Протасьевна',N'1-я линия, улица, ныне — Мирзояна улица',N'Ж', 1, 4, 3),
(N'Калинина', N'Береслава',N'Онисимовна',N'22-я линия, улица',N'Ж', 1, 4, 2);



---- ЗАПОЛНЯЕМ ДАТУ РОЖДЕНИЯ ----
update StudySchema.STUDENT set student_DATE='19910516' where student_ID=1;
update StudySchema.STUDENT set student_DATE='19991020' where student_ID=2;
update StudySchema.STUDENT set student_DATE='19991108' where student_ID=3;
update StudySchema.STUDENT set student_DATE='19960512' where student_ID=4;
update StudySchema.STUDENT set student_DATE='19900714' where student_ID=5;
update StudySchema.STUDENT set student_DATE='19980518' where student_ID=6;
update StudySchema.STUDENT set student_DATE='19920527' where student_ID=7;
update StudySchema.STUDENT set student_DATE='20021109' where student_ID=8;
update StudySchema.STUDENT set student_DATE='19970911' where student_ID=9;
update StudySchema.STUDENT set student_DATE='20030723' where student_ID=10;
update StudySchema.STUDENT set student_DATE='19940825' where student_ID=11;
update StudySchema.STUDENT set student_DATE='19950302' where student_ID=12;
update StudySchema.STUDENT set student_DATE='19960722' where student_ID=13;
update StudySchema.STUDENT set student_DATE='20030627' where student_ID=14;
update StudySchema.STUDENT set student_DATE='19960118' where student_ID=15;
update StudySchema.STUDENT set student_DATE='20031124' where student_ID=16;
update StudySchema.STUDENT set student_DATE='20000320' where student_ID=17;
update StudySchema.STUDENT set student_DATE='19971120' where student_ID=18;
update StudySchema.STUDENT set student_DATE='19940819' where student_ID=19;
update StudySchema.STUDENT set student_DATE='20000812' where student_ID=20;


INSERT INTO [StudySchema].[CLUBS] ([hobby_ID], [student_ID]) VALUES 
(5, 5),
(13, 3),
(11, 13),
(1, 12),
(12, 17),
(11, 7),
(12, 13),
(10, 16),
(2, 6),
(2, 19),
(5, 6),
(6, 2),
(7, 19),
(6, 14),
(9, 12),
(2, 11),
(8, 8),
(11, 3),
(4, 12),
(4, 14);


-- По умолчанию владелец телефона это Студент
INSERT INTO [StudySchema].[STUDENT_PHONES] ([phone_NUMBER], [student_ID]) VALUES 
('77772218308', 3),
('77304724937', 6),
('77536705021', 17),
('77315646698', 10),
('77404387452', 2),
('77422520371', 19),
('77226800879', 19),
('77393404783', 6),
('77707646657', 14),
('77362114252', 3),
('77603447213', 3),
('77457423206', 14),
('77959495811', 4),
('77922814442', 6),
('77523201894', 12),
('77595103126', 2),
('77273444468', 12),
('77188515398', 10),
('77569990106', 16),
('77180520784', 11);


ALTER TABLE [StudySchema].[STUDY] ADD CONSTRAINT study_default_kredits_cnt DEFAULT 5 for kredit_cnt;
ALTER TABLE [StudySchema].[STUDY] ADD CONSTRAINT study_default_total_hours DEFAULT 45 for [total_hours];
ALTER TABLE [StudySchema].[STUDY] ADD CONSTRAINT study_default_lection_hours DEFAULT 15 for [lection_hours];
ALTER TABLE [StudySchema].[STUDY] ADD CONSTRAINT study_default_practice_hours DEFAULT 15 for [practice_hours];

INSERT INTO [StudySchema].[STUDY] ([group_ID], [subject_ID], [teacher_ID]) VALUES 
(1, 30, 1),
(1, 29, 2),
(1, 28, 3),
(1, 27, 4),
(1, 26, 5),
(1, 25, 6),
(2, 1, 1),
(2, 2, 2),
(2, 3, 3),
(2, 4, 4),
(3, 5, 1),
(3, 2, 2),
(3, 3, 3),
(3, 4, 4),
(3, 1, 5),
(4, 2, 6),
(4, 3, 7),
(4, 4, 8);



-- ЗАПОЛНЯЕМ ТАБЛИЦУ ПРОГРЕСС ПО ТАБЛИЦЕ STUDY
select * from [StudySchema].[PROGRESS] order by group_ID
select * from [StudySchema].STUDY order by group_ID

INSERT INTO StudySchema.PROGRESS([student_ID], [group_ID], [subject_ID], [teacher_ID]) 
-- где такой то атрибут берется из таблицы в качестве такого то атрибута
SELECT student_ID as student_ID, StudySchema.STUDY.group_ID as group_ID, 
StudySchema.STUDY.subject_ID as  subject_ID,
StudySchema.STUDY.teacher_ID as teacher_ID
-- из объеденения столбцов заданных таблиц откуда берется информация
FROM StudySchema.STUDENT INNER JOIN StudySchema.STUDY
-- где идентификатор группы студента равен идентификатору группы из таблицы группы
ON StudySchema.STUDENT.group_ID = StudySchema.STUDY.group_ID



select * from StudySchema.STUDENT where student_male=N'М'



update DekanatSchema.TEACHER set teacher_STEPEN=N'Профессор' where  teacher_ID=1

update StudySchema.PROGRESS set ocenka=9 where subject_ID>=5 and subject_ID <= 15
select * from StudySchema.PROGRESS where ocenka=9

--Всем у кого оценка ocenka>=9, поставить сумму стипендии раную 30 000
update StudySchema.STUDENT set stipendia_value=30000
where student_ID IN (SELECT student_ID from StudySchema.PROGRESS WHERE ocenka>=9 group by student_ID having count(*)=1 )

--Всем у кого оценка менбьше двух, поставить сумму стипендии раную нулю
update StudySchema.STUDENT set stipendia_value=0
where student_ID IN (SELECT student_ID from StudySchema.PROGRESS WHERE ocenka<=2)

-- Посмотреть у кого стипенди 30 000 или 0
select student_ID, student_NAME, student_SURNAME, stipendia_value  
from StudySchema.STUDENT  where stipendia_value=30000 or stipendia_value=0 
-- Cортировка от наибольшей стипендии
ORDER BY stipendia_value DESC


-- Cоздаем таблицу читатели
CREATE TABLE StudySchema.READER (
	ticket_ID bigint,
	reader_SURNAME nvarchar(20) NOT NULL,
	reader_NAME nvarchar(15),
	reader_OTCH nvarchar(15),
	reader_GRUP bigint,
	reader_YEAR int 
);

--drop table  StudySchema.READER


-- Вставить объекты в таблицу читателей в такими то атрибутами 
INSERT INTO StudySchema.READER(ticket_ID, reader_SURNAME, reader_NAME, reader_OTCH, reader_GRUP, reader_YEAR)
-- где такой то атрибут берется из таблицы в качестве такого то атрибута
SELECT student_ID as ticket_ID, student_SURNAME as reader_SURNAME, 
student_NAME as reader_NAME, student_OTCH as reader_OTCH,
StudySchema.GROUPS.group_ID as reader_GRUP, YEAR(student_DATE) as reader_YEAR 
-- из объеденения столбцов заданных таблиц откуда берется информация
FROM StudySchema.STUDENT INNER JOIN StudySchema.GROUPS 
-- где идентификатор группы студента равен идентификатору группы из таблицы группы
ON StudySchema.STUDENT.group_ID=StudySchema.GROUPS.group_ID

select * from StudySchema.STUDENT


---------------------------  LAB WORK 4 -------------------------------------------
-- Запрос выполнится: НО лучше задавать AS - явным образом указывать - в качестве
select stipendia_value 'СТИПЕНДИЯ' from  StudySchema.STUDENT;


------------------------- ПРИМЕР 2 задание таблиц в запросе
select teacher_ID, teacher_SURNAME, teacher_NAME from DekanatSchema.TEACHER;

select teacher_ID, teacher_SURNAME, teacher_NAME from DekanatSchema.TEACHER ORDER BY teacher_ID desc;

select * from StudySchema.STUDENT;

-- Столбцы также можно переставить в порядке
select student_SURNAME, student_NAME, student_ID, student_ADDRESS from StudySchema.STUDENT;


select student_ID from StudySchema.PROGRESS;
-- Для получения списка без дупликатов - DISTINCT
select distinct student_ID from StudySchema.PROGRESS;


---------------------ПРИМЕР 3--------
-- список студентов и стипендии отсортированной в алфавитном порядке по фамилии
select student_ID, student_SURNAME, stipendia_value, stipendia_value / 2 as 'Пол стипендии'
from StudySchema.STUDENT 
order by student_SURNAME

-- Выбрать такие столбцы из таблицы студента, 
-- отсортированные по group_ID (индекс 1) и по третьей колоне (student_SURNAME)
select group_ID, student_ID, student_SURNAME from StudySchema.STUDENT
order by 1 DESC,3;


---------------- ПРИМЕР 4 Ограничение строк таблицы ---------------

-- Вывести фамилии и имена всех студентов у которых отчетсво Владиславович 
select student_SURNAME, student_NAME from StudySchema.STUDENT 
where student_OTCH='Владиславович';

-- Вывести всех студентов у которых стипендия равна 30 000
select * from StudySchema.STUDENT where stipendia_value = 30000;

-- Посчитать сумму стипендии которую получают студенты первой группы
select sum(stipendia_value) as 'Сумма стипендии' from StudySchema.STUDENT where group_ID=2;


---- ПРИМЕР 5 Операции в условиях отбора данных ----

-- Студенты у которых стипендия больше 15 000
select * from StudySchema.STUDENT where stipendia_value > 15000;

-- Студенты где имя равно такому и адрес равен такому
select * from StudySchema.STUDENT where student_NAME = 'Лиза' and student_ADDRESS = '2-я Братская, улица';


----------------------- ПРИМЕР 6 Специальные операторы

-- Найти только тех студентов чьи имена найдены в заданном списке
select * from StudySchema.STUDENT where student_NAME in ('Лиза', 'София');

-- Найти только те записи где оценка между 0 и 5
select * from StudySchema.PROGRESS where ocenka between 0 and 5;

-- Найти студентов, чьи имена начинаются с буквы А
select * from StudySchema.STUDENT where student_NAME like 'А%';

-- Найти студентов, чьи имена начинаются с буквы А
select * from StudySchema.STUDENT where student_NAME like '%Н';

-- Где стипендия равна нулю, присвоим значение null
update StudySchema.STUDENT set stipendia_value=null where stipendia_value = 0;

-- Найти тех студентов, у кого стипендия равна нулю
select * from StudySchema.STUDENT where stipendia_value IS NULL;



----------------  ПРИМЕР 7 Использование стандартных функций ----------

-- Математические 
select ABS(-10) as 'Модуль от числа';
select SQRT(16)  as 'Квадратный корень';
select ROUND(125.75, 0) as 'Округление ';
select POWER(2, 4) as 'Возведение в степень ';
select 28 % 5 as 'Деление по модулю';

-- Строковые
select ASCII('A') as 'convert to ASCII'
select LOWER('A') as 'convert to lower case'
select Right('ABCDE', 3) as 'CHAR FROM RIGHT SIDE'
select Reverse('world') as 'REVERSED'

-- Даты 

select dateadd(day, 5, '20211020') as 'added date';
select datediff(dd,'20211020', '20211028') as 'difference of 5 days';
select datename(mm,'20211020') as 'month name';
select datename(DW,'20211020') as 'day of week #1';
select datename(weekday,GETDATE()) as 'day of week #2';
select datepart(mm, '20211020') as 'The part month';


-- Конвертирование типов
-- CAST для форматирования к типу
select 'middle stipendia = ' + cast(avg(stipendia_value) as char(15)) 
from StudySchema.STUDENT;

-- работа с заменой значения null при выборке - coalesce
select student_SURNAME as 'Фамилия', student_NAME as 'Имя', 
coalesce (cast(stipendia_value as char(10)), 'платник') as 'Стипендия' 
from StudySchema.STUDENT



--------------ПРИМЕР 8 Агрегатные функции----------------------------
-- Cредняя стипендия студентов
select avg(stipendia_value) from StudySchema.STUDENT;

-- Средняя минимальная и максимальная оценка в таблице прогресс
select avg(ocenka), min(ocenka), max(ocenka) from StudySchema.PROGRESS;

-- Подсчет количества строк в таблице
select count (*) from StudySchema.STUDENT;

-- group by для поиска подмножества значений, которые имеют одинаковый student_ID
select student_ID, MIN(ocenka) as 'min_ocenka' from StudySchema.PROGRESS group by student_ID;

-- найти среднюю стипендию для каждой группы 
select group_ID, AVG(stipendia_value)
from StudySchema.STUDENT group by group_ID ;

-- строки с номерами студентов и макс оценки полученные на каждую дату
select student_ID, pr_date, max(ocenka) from StudySchema.PROGRESS 
group by student_ID, pr_date;

-- информация о кол-ве студентов в каждой группе
select group_ID, count(*) from StudySchema.STUDENT group by group_ID;

-- строки с номерами студентов и макс оценки полученные на каждую дату
-- где оценки больше нуля
select student_ID, pr_date, max(ocenka) from StudySchema.PROGRESS 
group by student_ID, pr_date
having max(ocenka) > 0; 

-- Группы где больше 3-ех человек
select group_ID, count(*) from StudySchema.STUDENT group by group_ID
having count(*) >= 3;


----------------ПРИМЕР 9 --------------------------
-- cписок самых молодых студентов из 1 и второй группы
select a.student_ID, a.student_SURNAME, a.student_NAME, year(a.DDDD)
from (select top(1) student_ID, student_SURNAME, student_NAME, year(student_DATE) DDDD
from StudySchema.STUDENT where group_ID=1
order by year(student_DATE)asc) as a

union all 

select b.student_ID, b.student_SURNAME, b.student_NAME, year(b.DDDD)
from (select top(1) student_ID, student_SURNAME, student_NAME, year(student_DATE) DDDD
from StudySchema.STUDENT where group_ID=2
order by year(student_DATE)asc) as b

-- выбор 20 процентов студентов
select top(20)percent student_ID, student_SURNAME, student_NAME 
from StudySchema.STUDENT order by student_ID desc;

-- также вывод строк, которые аналогины последней по значению
select top(3) with ties student_ID, student_SURNAME, student_NAME, stipendia_value
from StudySchema.STUDENT order by stipendia_value desc;

-- ПРИМЕР 10 построение вычисляемых полей и выборка записей по дате
select student_NAME, stipendia_value, 4*(stipendia_value-100) as 'changed_stipendia' 
from StudySchema.STUDENT;

-- Объединение фио и вычисление годовой стипендии
select group_ID, student_SURNAME + ' ' + Left(student_NAME, 1) + '.' +
Left(student_OTCH, 1) + '.' as 'Ф.И.О.', stipendia_value * 12 as YEAR_STIP
from StudySchema.STUDENT;

-- Выбрать год и месяц рождения студента
select student_SURNAME, year(student_DATE) as 'YEAR',
month(student_DATE) as 'MONTH' from StudySchema.STUDENT;


-----------------------------------------------------------------------------------------///

---- ЗАДАНИЕ 1 - список преподователей с должностями в алфавитном порядке
select teacher_SURNAME+' '+teacher_NAME AS 'Инициалы', teacher_POSITION as 'Должность' 
from DekanatSchema.TEACHER order by (teacher_SURNAME);

---- ЗАДАНИЕ 2 - Название кафедр с фамилиями заведующих
select chair_NAME AS 'Кафедра', chair_CHIEF as 'Заведующий' 
from DekanatSchema.CHAIR;

---- ЗАДАНИЕ 3 - список студентов с различными фамилиями в группе
select distinct student_SURNAME from StudySchema.STUDENT where group_ID=1;

---- ЗАДАНИЕ 4 - Где стипендия больше 20 000
select * from StudySchema.STUDENT where stipendia_value > 20000;


---- ЗАДАНИЕ 5 - Список студентов проживающих в Астане и Караганде


---- Заполняем таблицу страны ----
INSERT INTO [StudySchema].[COUNTRY] (country_NAME) VALUES 
(N'Казахстан'),
(N'Россия'),
(N'Франция'),
(N'Германия'),
(N'Швейцария'),
(N'Америка');

---- Заполняем таблицу ГОРОДА ----
INSERT INTO [StudySchema].[CITY] (city_NAME, country_ID) VALUES 
(N'Алматы', 1),
(N'Астана', 1),
(N'Караганда', 1),
(N'Орал', 1),
(N'Актау', 1),
(N'Атырау', 1),
(N'Жезказган', 1),
(N'Жанаозен', 1),
(N'Актобе', 1);



update StudySchema.STUDENT set city_ID=4 where student_ID=1;
update StudySchema.STUDENT set city_ID=3 where student_ID=2;
update StudySchema.STUDENT set city_ID=4 where student_ID=3;
update StudySchema.STUDENT set city_ID=4 where student_ID=4;
update StudySchema.STUDENT set city_ID=4 where student_ID=5;
update StudySchema.STUDENT set city_ID=1 where student_ID=6;
update StudySchema.STUDENT set city_ID=3 where student_ID=7;
update StudySchema.STUDENT set city_ID=4 where student_ID=8;
update StudySchema.STUDENT set city_ID=6 where student_ID=9;
update StudySchema.STUDENT set city_ID=6 where student_ID=10;
update StudySchema.STUDENT set city_ID=2 where student_ID=11;
update StudySchema.STUDENT set city_ID=4 where student_ID=12;
update StudySchema.STUDENT set city_ID=5 where student_ID=13;
update StudySchema.STUDENT set city_ID=1 where student_ID=14;
update StudySchema.STUDENT set city_ID=8 where student_ID=15;
update StudySchema.STUDENT set city_ID=4 where student_ID=16;
update StudySchema.STUDENT set city_ID=5 where student_ID=17;
update StudySchema.STUDENT set city_ID=6 where student_ID=18;
update StudySchema.STUDENT set city_ID=2 where student_ID=19;
update StudySchema.STUDENT set city_ID=6 where student_ID=20;


select * from StudySchema.STUDENT where city_ID in 
(select city_ID from StudySchema.CITY where city_NAME = N'Астана' or city_NAME = N'Караганда');


---- ЗАДАНИЕ 6 - Список студентов у кого нету стипендии
select * from StudySchema.STUDENT where stipendia_value is null;

---- ЗАДАНИЕ 7 - Список студентов третьей группы, фамилии начинаются на Е
select * from StudySchema.STUDENT 
where (group_ID=3 and student_SURNAME like N'Д%');

---- ЗАДАНИЕ 8 - Список студентов которые родились в 1996 году
select * from StudySchema.STUDENT where year(student_DATE)=1996;

---- ЗАДАНИЕ 9 - средняя стипендия второй группы
select avg(stipendia_value) from StudySchema.STUDENT where group_ID=2;

---- ЗАДАНИЕ 10 - среднее число лекционных часов по всем предметам
select subject_ID, avg(lection_hours) from StudySchema.STUDY group by subject_ID ;

---- ЗАДАНИЕ 11 - Кол-во стулентов в базе 
select count(*) as 'Кол-во студентов' from StudySchema.STUDENT;

---- ЗАДАНИЕ 12 - Вся информация о предметах
select * from StudySchema.SUBJECTS;

---- ЗАДАНИЕ 13 - Студенты которые НЕ проживают в Алматы
select * from StudySchema.STUDENT where city_ID <> (select city_ID from StudySchema.CITY where city_NAME = N'Алматы');

---- ЗАДАНИЕ 14 - Список студентов чьи дни рождения в мае
select * from StudySchema.STUDENT where datename(mm, student_DATE)=N'Май';

---- ЗАДАНИЕ 15 - Номера студентов с минимальной оценкой из ведомости успеваемости
select student_ID, MIN(ocenka) as 'min_ocenka' from StudySchema.PROGRESS group by student_ID;

---- ЗАДАНИЕ 16 - Номера студентов с минимальной оценкой из ведомости успеваемости
select student_ID, max(ocenka) as 'max_ocenka' from StudySchema.PROGRESS group by student_ID;

---- ЗАДАНИЕ 17 - Список студентов и их возвраст
select student_ID, student_SURNAME, student_NAME, student_DATE, datediff(year, student_DATE, getdate()) as 'YEARS'
from StudySchema.STUDENT;


select student_ID, student_SURNAME, student_NAME, student_DATE, datediff(MONTH, student_DATE, getdate()) as 'YEARS' 
from StudySchema.STUDENT;


select * from StudySchema.STUDENT where stipendia_value is null;


-- работа с заменой значения null при выборке - coalesce
select student_SURNAME as 'Фамилия', student_NAME as 'Имя', 
coalesce (cast(stipendia_value as char(10)), N'Нет стипендии') as 'Стипендия' 
from StudySchema.STUDENT

--
select group_ID, avg(stipendia_value), sum(stipendia_value) / count(*) as middle_stip 
from StudySchema.STUDENT group by group_ID having sum(stipendia_value) is null; 

select student_SURNAME+' '+student_NAME+' '+student_OTCH + ' ' + cast(student_DATE as nvarchar(10)) from StudySchema.STUDENT ;

--================================== LAB 5 ====================================
-- имена студентов и их группы
select s.student_SURNAME, s.student_NAME, g.group_NAME 
from StudySchema.STUDENT as s inner join StudySchema.GROUPS as g
on s.group_ID = g.group_ID
order by g.group_NAME


select s.student_SURNAME, s.student_NAME, g.group_NAME 
from StudySchema.STUDENT as s, StudySchema.GROUPS as g
where s.group_ID = g.group_ID
order by g.group_NAME

----FULL JOIN
-- показывает студентов без групп или групп без студентов
select a.student_ID, a.student_SURNAME, g.group_NAME 
from StudySchema.STUDENT a full join StudySchema.GROUPS g
on a.group_ID=g.group_ID

-- список всех возможных сочетаний stud_ID group_id
select s.student_ID, g.group_ID 
from StudySchema.STUDENT as s cross join StudySchema.GROUPS as g 
	order by s.student_ID, g.group_ID 

-- LEFT JOIN - ищет всех студентов и подходящие для них группы

select s.student_SURNAME, s.student_NAME, g.group_NAME 
from StudySchema.STUDENT as s left join StudySchema.GROUPS as g
on s.group_ID = g.group_ID
order by g.group_NAME


-- RIGHT JOIN - показывает пустые группы

select s.student_SURNAME, s.student_NAME, g.group_NAME 
from StudySchema.STUDENT as s right join StudySchema.GROUPS as g
on s.group_ID = g.group_ID
order by g.group_NAME


-- SELF JOIN

select a.student_SURNAME, b.student_SURNAME 
from StudySchema.STUDENT as a left join StudySchema.STUDENT as b
on a.student_STAR = b.student_ID


-- РАНДОМНО СГЕНЕРИРОВАТЬ ЧИСЛО ОТ 1 до 100 включительно ----------
SELECT FLOOR(RAND()*(100))+1

-- cast для преобразования, newid - unique identifier
select  cast (rand(cast( newid() as varbinary(16)))*10+1 as int )

-- У нас были выставлены оценки в качестве нуля, поставим на них рандомные значения в таблице прогресс
update StudySchema.PROGRESS 
set ocenka=cast (rand(cast( newid() as varbinary(16)))*10+1 as int ) where ocenka=6;
-- Вывод
select ocenka from StudySchema.PROGRESS;

-- Теперь спокойно можем вывести фамилии, названия предметов и оценки
select s.student_SURNAME, sub.subject_NAME, p.ocenka
from StudySchema.STUDENT as s 
join StudySchema.PROGRESS as p on s.student_ID = p.student_ID 
join StudySchema.SUBJECTS as sub on sub.subject_ID=p.subject_ID


-----------------ИСПОЛЬЗОВАНИЕ ПОДЗАПРОСОВ----------------

-- знаем фамилию, но незнаем его айдишки, хотим найти все его оценки
select * from StudySchema.PROGRESS
where student_ID = (select student_ID from StudySchema.STUDENT 
				    where student_SURNAME=N'Туров')

-- Это выведет даже оценки однофамильцев
select * from StudySchema.PROGRESS
where student_ID in ( select student_ID from StudySchema.STUDENT
					  where student_SURNAME = 'Туров')


-- Все оценки для предмета политология
select p.ocenka from StudySchema.PROGRESS as p
where p.subject_ID = (select subject_ID from StudySchema.SUBJECTS where subject_NAME=N'Политология')

-- Это выведет с названием предмета
select sb.subject_NAME, p.ocenka  from StudySchema.PROGRESS as p join StudySchema.SUBJECTS as sb
on p.subject_ID=sb.subject_ID
where p.subject_ID = (select subject_ID from StudySchema.SUBJECTS where subject_NAME=N'Политология')


select sb.subject_NAME, p.ocenka from StudySchema.SUBJECTS as sb join StudySchema.PROGRESS as p
on sb.subject_ID = p.subject_ID
where subject_NAME=N'Политология'


select * from StudySchema.PROGRESS

-- количество студентов получивших такие оценки выше среднего полсе заданного числа
select ocenka, count(distinct student_ID) as N'Получило студентов' 
from StudySchema.PROGRESS
group by ocenka 
having ocenka > 
(select avg(ocenka) from StudySchema.PROGRESS 
where pr_date = '20211028' ) -- YYYYMMDD


--------------------------СВЯЗАННЫЕ ПОДЗАПРОСЫ -------------------------------

select student_ID from StudySchema.PROGRESS as p 
where pr_date = '20211026'

-- Все студенты сдавшие экзамен 1 марта
select * from StudySchema.STUDENT as s 
where '20211028' in (select p.pr_date from StudySchema.PROGRESS as p 
					 where s.student_ID = p.student_ID)


--- Найти студентов с баллом выше среднего
select * from StudySchema.PROGRESS as s
where s.ocenka > (select avg(p.ocenka) 
from StudySchema.PROGRESS as p where s.student_ID = p.student_ID)


-- найти группы в которых учится как минимум один студент
select g.group_NAME from StudySchema.GROUPS as g
where exists (select * from StudySchema.STUDENT as s 
where s.group_ID = g.group_ID)

-- Способ поиска студента сдавшего экзамен
select * from StudySchema.STUDENT 
where student_ID = ANY (select student_ID from StudySchema.PROGRESS)

-- ЗАДАЕМ СТИПЕНДИЮ от 10 000 до 40 000- до этого у всех NULL
update StudySchema.STUDENT 
set stipendia_value=cast (rand(cast( newid() as varbinary(16)))*100000+1 as int )%30000+10000 where stipendia_value is null;
-- Вывод
select stipendia_value from StudySchema.STUDENT;


-- студенты у которых стипендия больше 1500
select * from StudySchema.STUDENT
	where stipendia_value > all(
		select stipendia_value from StudySchema.STUDENT
			where stipendia_value < 1500)


---------------- Использование подзапроса в предложении form

--Подсчет мальчиков и девочек по группам
select g.group_NAME as 'GROUP',
	(select count(s.student_ID) from StudySchema.STUDENT as s 
	where s.group_ID = g.group_ID and s.student_male = N'Ж') 
	as 'female',

	(select count(s.student_ID) from StudySchema.STUDENT as s
	where s.group_ID = g.group_ID and s.student_male=N'М')
	as 'male'

from StudySchema.GROUPS as g


-- Выбрать группы где только девочки
select g.group_NAME from StudySchema.GROUPS as g where 
	(select count(*) from StudySchema.STUDENT as s2 
		where s2.group_ID = g.group_ID) = 
	(select count(*) from StudySchema.STUDENT as s2 
		where s2.group_ID = g.group_ID and student_male=N'Ж') and 
	(select count(*) from StudySchema.STUDENT as s 
		where g.group_ID = s.group_ID) > 0


-- Выбрать группы где есть и мальчики и девочки
select 
	A.group_ID, A.male, B.female, StudySchema.GROUPS.group_NAME
	from   (select count(student_ID) as 'male', s.group_ID
			from StudySchema.STUDENT s where s.student_male=N'М'
			group by s.group_ID) as A
			join
			(select count(student_ID) as 'female', s.group_ID 
			from StudySchema.STUDENT s where s.student_male=N'Ж'
			group by s.group_ID) as B
	on B.group_ID = A.group_ID
	join
	StudySchema.GROUPS on 
	StudySchema.GROUPS.group_ID = B.group_ID

-- Разница между стипендией студента и средней стипендией в группе	
select student_ID, group_ID, stipendia_value, 
	(select avg(s2.stipendia_value) from StudySchema.STUDENT as s2
	 where s2.group_ID = s1.group_ID
	 group by s2.group_ID 
	) as 'Средняя стипендия для группы',

	abs((select avg(s2.stipendia_value) from StudySchema.STUDENT as s2
	 where s2.group_ID = s1.group_ID
	 group by s2.group_ID 
	) - stipendia_value) as 'Разность стипендий'

from StudySchema.STUDENT as s1


select sum(stipendia_value) as 'Стипендия', count(*) as 'кол-во студентов', 
	sum(stipendia_value) /  count(*) as 'Среднее' 
from StudySchema.STUDENT where group_ID=1

-- Разница между стипендией студента и средней стипендией в группе	
select S1.group_ID, student_SURNAME + ' ' + student_NAME as 'FIO', qwe as 'Middle stip for group', abs(qwe-S1.stipendia_value) as difference 
from StudySchema.STUDENT as S1
	inner join
	(select G.group_ID, count(*) as we, avg(stipendia_value) as qwe 
	from StudySchema.STUDENT as S, StudySchema.GROUPS as G
	where S.group_ID=G.group_ID group by G.group_ID) as B
on B.group_ID = S1.group_ID


--Выводит всех студентов и преподователей чьи фамилии между К и С
select student_SURNAME from StudySchema.STUDENT
	where student_SURNAME between N'К' and N'С'
union all
select teacher_SURNAME from DekanatSchema.TEACHER
	where teacher_SURNAME between N'К' and N'С'
GO

-- Добавим колону с зарплатой
alter table DekanatSchema.TEACHER add salary bigint;
GO
update DekanatSchema.TEACHER set salary=100000;

select student_ID as 'user ID' ,student_SURNAME as 'SURNAME', stipendia_value as 'Payment', 'student' from StudySchema.STUDENT
union all
select teacher_ID, teacher_SURNAME, salary, 'teacher' from DekanatSchema.TEACHER


select student_SURNAME from StudySchema.STUDENT 
union all 
select teacher_SURNAME from DekanatSchema.TEACHER


-------------------LAB 5--------------------

-- 1 Список преподавателей ведущих дисциплины Информатика и Физика
select st.teacher_ID, t.teacher_NAME + ' ' + t.teacher_SURNAME as 'ФИО', 
	(select s.subject_NAME from StudySchema.SUBJECTS as s where subject_ID=st.subject_ID) as subject_NAME
from StudySchema.STUDY as st, DekanatSchema.TEACHER as t
	where st.subject_ID in (select subject_ID from StudySchema.SUBJECTS 
							where subject_NAME in (N'Философия', N'Физика' )) 
		  and st.teacher_ID = t.teacher_ID
 

 -- 2 Список студентов имеющих неуд оценки
 select  pr.student_ID, s.student_SURNAME+' '+ s.student_NAME as 'FIO',  
		 (select subject_NAME from StudySchema.SUBJECTS as sb where sb.subject_ID = pr.subject_ID) as subject, pr.ocenka 
		 from StudySchema.PROGRESS as pr join StudySchema.STUDENT as s
 on pr.student_ID = s.student_ID
 where pr.ocenka < 3


-- 3 Список студентов не сдавших экзамен по Политологии -- такого студента нету в таблице прогресс
select s.student_ID, s.student_NAME + ' ' + s.student_SURNAME as 'FIO', N'Не сдали' as  N'Политология' from StudySchema.STUDENT as s
where not exists (select * from StudySchema.PROGRESS as pr where pr.student_ID = s.student_ID 
	  and pr.subject_ID=(select subject_ID from StudySchema.SUBJECTS where subject_NAME = N'Политология') )


-- 4 список преподователей кафедры алгебры и геометрии
select teacher_SURNAME + ' ' + teacher_NAME as 'ФИО преподователя', 
		(select chair_NAME from DekanatSchema.CHAIR as ch where chair_NAME = N'Кафедра алгебры и геометрии') as chair 
			from DekanatSchema.TEACHER as t 
		where chair_ID = (select chair_ID from DekanatSchema.CHAIR as ch where chair_NAME = N'Кафедра алгебры и геометрии')

-- 5 Списки кафедр с указанием заведую фамилий щих кафедр
select chair_NAME, SUBSTRING(chair_CHIEF,0,CHARINDEX(' ',chair_CHIEF)) as 'surname' from DekanatSchema.CHAIR

-- 6 Списки названий групп с указанием старосты

-- ИСПРАВИТЬ
update StudySchema.STUDENT set student_STAR=null

update StudySchema.STUDENT
	set student_STAR = (select top 1 student_ID from StudySchema.STUDENT as s where s.group_ID = StudySchema.STUDENT.group_ID)
go

select g.group_ID, g.group_NAME, (select s.student_STAR from StudySchema.STUDENT as s where g.group_ID = s.group_ID and s.student_STAR=s.student_ID ) as star
from StudySchema.GROUPS as g
where (select s.student_STAR from StudySchema.STUDENT as s where g.group_ID = s.group_ID and s.student_STAR=s.student_ID ) is not NULL


-- 7 Списки студентов каждой группы с их оценками по всем предметам
select 
	s.student_ID, s.group_ID,
	student_SURNAME+' '+student_NAME as 'FIO', 
	(select avg(p.ocenka) from StudySchema.PROGRESS as p where s.student_ID = p.student_ID) as 'middle mark'
from StudySchema.STUDENT as s

select pr.group_ID, 
	(select s.student_SURNAME+' '+ s.student_NAME from StudySchema.STUDENT as s where pr.student_ID = s.student_ID) as FIO, 
	(select s.subject_NAME from StudySchema.SUBJECTS as s where pr.subject_ID = s.subject_ID) as SUBJECTS, 
	pr.ocenka 
from StudySchema.PROGRESS as pr


-- 8 В Каких группах проводятся занятия по предмету Философия
-- Через подзапрос
select * from StudySchema.SUBJECTS where  subject_ID=2

select s.group_ID, g.group_NAME from StudySchema.STUDY as s, StudySchema.GROUPS as g 
where subject_ID in (select subject_ID from StudySchema.SUBJECTS where subject_NAME=N'Русский язык')
and g.group_ID = s.group_ID

select st.subject_ID, st.group_ID, g.group_NAME
	from StudySchema.STUDY as st join StudySchema.GROUPS as g
		on g.group_ID=st.group_ID 
			where st.subject_ID in (
				select subject_ID from StudySchema.SUBJECTS 
				where subject_NAME=N'Русский язык')

-- 9 Какие виды занятий по информатике (Философия) проводятся в первой группе
-- ПРОСМОТР все предметы проходящие в первой группе
select group_ID, teacher_ID, subject_ID,
(select subject_NAME from StudySchema.SUBJECTS as sb where sb.subject_ID = s.subject_ID ) as 'SUBJECT'
from StudySchema.STUDY as s 
where group_ID=1

select s.group_ID, s.subject_ID, sub.subject_NAME, s.practice_hours, s.labor_hours, s.lection_hours from StudySchema.STUDY as s, StudySchema.SUBJECTS as sub
where group_ID=1 and 
	  s.subject_ID=(select subject_ID from StudySchema.SUBJECTS where subject_NAME=N'Философия')
	  and s.subject_ID = sub.subject_ID

-- 10 Сколько часов занятий по каждому предмету в каждой группе проводится в семестре
select  s.subject_ID, 
	(select subject_NAME from StudySchema.SUBJECTS as sb where sb.subject_ID = s.subject_ID ) as 'SUBJECT', 
	s.group_ID, s.lection_hours + s.practice_hours as 'total hours'
from StudySchema.STUDY as s 
order by s.subject_ID


-- 11 Список студентов и среднюю оценку его обучения
select p.student_ID, 
	(select s.student_SURNAME+' '+s.student_NAME from StudySchema.STUDENT as s where s.student_ID = p.student_ID) as 'FIO',
	avg(p.ocenka) as 'Оценка', 'В трад. формате'=
		case
			when avg(p.ocenka) between 7 and 9 then N'Отличник'
			when avg(p.ocenka) between 4 and 6 then N'Ударник'
			when avg(p.ocenka) between 0 and 5 then N'Неуд.'
		end
from StudySchema.PROGRESS as p 
group by p.student_ID;


-- Выдать список студентов, у кооторых стипендия больше, чем среднеяя стипендия в группе, 
-- АТРИБУТЫ: ФИО, название группы, стипендия и средняя стипендия группы
-- и показать пустые стипендии

select S1.group_ID, (select group_NAME from StudySchema.GROUPS where group_ID=S1.group_ID) as GROUPS, 
	   student_SURNAME + ' ' + student_NAME as 'FIO', qwe as 'Middle stip for group', 
	   S1.stipendia_value as self_stipendia, abs(qwe-S1.stipendia_value) as N'Стипендия выше на тг'
from StudySchema.STUDENT as S1
	  join
		(select G.group_ID, count(*) as we, avg(stipendia_value) as qwe 
		 from StudySchema.STUDENT as S, StudySchema.GROUPS as G
		 where S.group_ID=G.group_ID group by G.group_ID) as B
on B.group_ID = S1.group_ID and (S1.stipendia_value - qwe > 0) -- стипендия больше чем сред стипендия в группе
 
--select student_ID, stipendia_value from StudySchema.STUDENT


-- Замена всех NULL значений в столбце 'Middle stip for group' и вывод -меньше средней- где стипендия меньше средней
select S1.group_ID, (select group_NAME from StudySchema.GROUPS where group_ID=S1.group_ID) as GROUPS, 
	   student_SURNAME + ' ' + student_NAME as 'FIO', 
	   coalesce(cast(abs(qwe) as bigint), (select avg(s3.stipendia_value) from StudySchema.STUDENT as s3 where s3.group_ID=S1.group_ID)) as 'Middle stip for group', 
	   S1.stipendia_value as self_stipendia, 
	   coalesce (cast(abs(qwe-S1.stipendia_value) as char(10)), N'меньше средней' ) as N'Стипендия выше на тг'
from StudySchema.STUDENT as S1
	 left join
		(select G.group_ID, count(*) as we, avg(stipendia_value) as qwe 
		 from StudySchema.STUDENT as S, StudySchema.GROUPS as G
		 where S.group_ID=G.group_ID group by G.group_ID) as B
on B.group_ID = S1.group_ID and (S1.stipendia_value - qwe > 0) -- стипендия больше чем сред стипендия в группе

-- 11 Список студентов и среднюю оценку его обучения
select p.student_ID, 
	(select s.student_SURNAME+' '+s.student_NAME from StudySchema.STUDENT as s where s.student_ID = p.student_ID) as 'FIO',
	DATEDIFF(m, '20020728', GETDATE())/12 as 'Years',
	DATEDIFF(m, '20020728', GETDATE())%12 as 'Month',
	(DATEDIFF(d, '20020728', GETDATE()) - DATEDIFF(m, '20020728', GETDATE())/12*365.25)   as 'Days',
	avg(p.ocenka) as 'Оценка', 'В трад. формате'=
		case
			when avg(p.ocenka) between 7 and 9 then N'Отличник'
			when avg(p.ocenka) between 4 and 6 then N'Ударник'
			when avg(p.ocenka) between 0 and 5 then N'Неуд.'
		end
from StudySchema.PROGRESS as p 
group by p.student_ID;


update StudySchema.STUDENT set student_DATE='2020-11-6' where student_ID=1


---------------- ПОЛНЫЙ ВОЗВРАСТ ЧЕЛОВЕКА -------------
Select student_SURNAME + ' ' + student_NAME as 'FIO', student_DATE, 
		cast((DATEDIFF(m, student_DATE, GETDATE())/12) as varchar) + ' Years ' + 
        cast((DATEDIFF(m, student_DATE, GETDATE())%12) as varchar) + ' Month '  +
	    cast((DATEDIFF(day,
								dateadd(month, (DATEDIFF(m, student_DATE, GETDATE())%12),
									dateadd(year, (DATEDIFF(m, student_DATE, GETDATE())/12), student_DATE)
							), GETDATE()
					  )		
			    ) 
				as varchar) + ' Days '
		as full_years
from StudySchema.STUDENT

----------------------------------------------------------------


Select student_SURNAME + ' ' + student_NAME as 'FIO', student_DATE, 
		
		cast (datediff(day, student_DATE,  getdate()) / 365.25 as int) as ' Years ',
		case
			when DATEPART(MONTH, GETDATE()) - DATEPART(MONTH, student_DATE) = 0 then 0
			when DATEPART(MONTH, GETDATE()) - DATEPART(MONTH, student_DATE) > 0 then DATEPART(MONTH, GETDATE()) - DATEPART(MONTH, student_DATE) - 1
			when DATEPART(MONTH, GETDATE()) - DATEPART(MONTH, student_DATE) < 0 then DATEPART(MONTH, GETDATE()) - DATEPART(MONTH, student_DATE)
		end as 'Month',
		case
			when DATEPART(day, GETDATE()) - DATEPART(day, student_DATE) = 0 then 0
			when DATEPART(day, GETDATE()) - DATEPART(day, student_DATE) > 0 then DATEPART(day, GETDATE()) - DATEPART(day, student_DATE) - 1
			when DATEPART(day, GETDATE()) - DATEPART(day, student_DATE) < 0 then DATEPART(day, GETDATE()) - DATEPART(day, student_DATE) + 29
		end as 'Days'

from StudySchema.STUDENT


---------------- ПОЛНЫЙ ВОЗВРАСТ ЧЕЛОВЕКА -------------

DECLARE @date datetime, @tmpdate datetime, @years int, @months int, @days int
SELECT @date = '19991108'

SELECT @tmpdate = @date

SELECT @years = DATEDIFF(yy, @tmpdate, GETDATE()) - CASE WHEN (MONTH(@date) > MONTH(GETDATE())) OR (MONTH(@date) = MONTH(GETDATE()) AND DAY(@date) > DAY(GETDATE())) THEN 1 ELSE 0 END
SELECT @tmpdate = DATEADD(yy, @years, @tmpdate)
SELECT @months = DATEDIFF(m, @tmpdate, GETDATE()) - CASE WHEN DAY(@date) > DAY(GETDATE()) THEN 1 ELSE 0 END
SELECT @tmpdate = DATEADD(m, @months, @tmpdate)
SELECT @days = DATEDIFF(d, @tmpdate, GETDATE())

SELECT @years, @months, @days

/*=================================*/

create table Reating(
	student_ID bigint,
	student_SURNAME nvarchar(20),
	student_NAME nvarchar(30),
	student_OTCH nvarchar(30),
	group_NAME nvarchar(30),
	sr_ball char(10)
);

--Запрос MERGE 
Merge into Reating as r --Целевая таблица
using (
	select distinct s.student_ID, s.student_SURNAME, s.student_NAME, s.student_OTCH, 
			g.group_NAME, avg(ocenka) as 'sr_ball'
		from StudySchema.STUDENT as s 
		inner join  StudySchema.GROUPS as g on g.group_ID = s.group_ID
		right join StudySchema.PROGRESS as p on p.student_ID = s.student_ID --Таблицы источники - СТУДЕНТ ГРУППЫ И ПРОГРЕСС
where p.student_ID in (select student_ID from StudySchema.PROGRESS where student_ID <> 0)
	group by  s.student_ID, s.student_SURNAME, s.student_NAME, s.student_OTCH, group_NAME) s
on (r.student_ID = s.student_ID) --Условие объединения - где совпадают уникальные идентификаторы
WHEN MATCHED THEN --Если истина и доп. условие отработало (UPDATE)
	update
		set r.sr_ball = s.sr_ball,
		r.student_ID = s.student_ID,
		r.student_SURNAME = s.student_SURNAME,
		r.student_NAME = s.student_NAME,
		r.student_OTCH = s.student_OTCH,
		r.group_NAME = s.group_NAME
when not matched then  --Если НЕ истина (INSERT)
	insert
	(student_ID, student_SURNAME, student_NAME, student_OTCH, group_NAME, sr_ball)
	values
	(s.student_ID, s.student_SURNAME, s.student_NAME, s.student_OTCH, s.group_NAME, s.sr_ball);

select * from Reating


insert into Reating
	(student_ID, student_SURNAME, student_NAME, student_OTCH, group_NAME, sr_ball)
values
	(22, 'test', 'test', 'test', 'test', 12);

select * from Reating

--Запрос MERGE 
Merge into Reating as r --Целевая таблица
using (
	select distinct s.student_ID, s.student_SURNAME, s.student_NAME, s.student_OTCH, 
			g.group_NAME, avg(ocenka) as 'sr_ball'
		from StudySchema.STUDENT as s 
		inner join  StudySchema.GROUPS as g on g.group_ID = s.group_ID
		right join StudySchema.PROGRESS as p on p.student_ID = s.student_ID --Таблицы источники - СТУДЕНТ ГРУППЫ И ПРОГРЕСС
where p.student_ID in (select student_ID from StudySchema.PROGRESS where student_ID <> 0)
	group by  s.student_ID, s.student_SURNAME, s.student_NAME, s.student_OTCH, group_NAME) s
on (r.student_ID = s.student_ID) --Условие объединения - где совпадают уникальные идентификаторы
WHEN MATCHED THEN --Если истина и доп. условие отработало (UPDATE)
	update
		set r.sr_ball = s.sr_ball,
		r.student_ID = s.student_ID,
		r.student_SURNAME = s.student_SURNAME,
		r.student_NAME = s.student_NAME,
		r.student_OTCH = s.student_OTCH,
		r.group_NAME = s.group_NAME
WHEN NOT MATCHED BY SOURCE -- Если таких записей нету в первоисточнике (таблица откуда берутся изначальные данные)
THEN DELETE                -- то удаляем
when not matched then  --Если НЕ истина (INSERT)
	insert
	(student_ID, student_SURNAME, student_NAME, student_OTCH, group_NAME, sr_ball)
	values
	(s.student_ID, s.student_SURNAME, s.student_NAME, s.student_OTCH, s.group_NAME, s.sr_ball);

select * from Reating


-- Добавляем столбец
alter table StudySchema.STUDENT add in_obshejitie nvarchar(3) null
go

-- Все кто не живет в общаге, добавим В общежитии
update StudySchema.STUDENT set in_obshejitie='Да' where city_ID <> (select city_ID from StudySchema.CITY where city_NAME = 'Алматы');
go


--=======================================================ЛР №7 ПРЕДСТАВЛЕНИЯ ================================
-- Задание 1 Список групп и старост этих групп
use lab_6
go

create view show_group_stars as 
(
	select group_NAME as 'Группа', student_SURNAME + ' ' + student_NAME as 'Староста'
		from StudySchema.GROUPS as g
			inner join StudySchema.STUDENT as s 
				on s.group_ID = g.group_ID
	where s.student_STAR = s.student_ID
	)
go
select * from show_group_stars
go

--TASK 2 Список студентов не сдавших экзамен по предмету -- Тут по первому предмету - Англ яз

create view not_passed_english as 

(		
	select s.student_ID, s.student_SURNAME, s.student_NAME from StudySchema.STUDENT as s
	where student_ID not in (
	-- Если этот юзер не найден в прогрессе, значит он не сдавал экз
	select distinct p.student_ID from StudySchema.PROGRESS as p 
		where p.subject_ID = (  select subject_ID 
									from StudySchema.SUBJECTS 
								where subject_NAME='Английский язык' )
	)
)
go
select * from not_passed_english
go

-- TASK 3 Содержимое таблицы успеваемость без идентификаторов
create view show_full_progress as
(
	select  sb.subject_NAME                          as 'Предмет', 
			t.teacher_SURNAME + ' ' + t.teacher_NAME as 'Преподователь', 
			g.group_NAME                             as 'Группа',
			s.student_SURNAME + ' ' + s.student_NAME as 'Студент',
			p.pr_date                                as 'Дата сдачи экзамена', 
			p.ocenka	                                 as 'Оценка'
	from StudySchema.PROGRESS as p

	inner join StudySchema.STUDENT as s
		on s.student_ID = p.student_ID

	inner join StudySchema.SUBJECTS as sb
		on sb.subject_ID = p.subject_ID

	inner join StudySchema.GROUPS as g
		on g.group_ID = p.group_ID

	inner join DekanatSchema.TEACHER as t
		on t.teacher_ID = p.teacher_ID

) 
go
select * from show_full_progress
go

create view show_full_progress_ocenka_9 as (
	select * from show_full_progress
	where Оценка = 9
)
go
-- Подпретставление задания Е 
select * from show_full_progress_ocenka_9
go

-- TASK D - список студентов живущих в общежитии


create view show_live_in_obshejitie as (
	select s.student_SURNAME, s.student_NAME, s.student_OTCH, c.city_NAME
		from StudySchema.STUDENT as s
			inner join StudySchema.CITY as c
				on c.city_ID = s.city_ID
			where s.in_obshejitie='Да'
)
go

select * from show_live_in_obshejitie
go

-- TASK E - Список студентов и их группа
create view students_and_groups as (
	select	s.student_SURNAME + ' ' + 
			substring(s.student_NAME, 1, 1) + '. ' + 
			substring(s.student_OTCH, 1, 1) + '. (' + 
			g.group_NAME + ')' as 'ФИО и Группа студента'

	from StudySchema.STUDENT as s
	inner join StudySchema.GROUPS as g
		on s.group_ID = g.group_ID
)
go
select * from students_and_groups
go

-- TASK F Список преподователей, предметы и группы
create view show_group_teachers_and_subjects as (
	select	g.group_NAME                as 'Группа',
			sb.subject_NAME             as 'Предмет',
			t.teacher_SURNAME + ' ' + 
			SUBSTRING(t.teacher_NAME,1,1) + '. ' + 
			SUBSTRING(teacher_OTCH,1,1) as 'Преподователь'

	from StudySchema.STUDY as s

	inner join StudySchema.SUBJECTS as sb
		on sb.subject_ID = s.subject_ID

	inner join StudySchema.GROUPS as g
		on g.group_ID = s.group_ID

	inner join DekanatSchema.TEACHER as t
		on t.teacher_ID = s.teacher_ID
)
go
select * from show_group_teachers_and_subjects
go

create view otlichniki as (
	select  g.group_NAME as 'Группа' , 
			s.subject_NAME as 'Предмет', 
			count(p.ocenka) as 'Кол-во отличников' 
	from StudySchema.PROGRESS as p
	
	join StudySchema.GROUPS as g
		on g.group_ID = p.group_ID
	join StudySchema.SUBJECTS as s
		on s.subject_ID = p.subject_ID
	where p.ocenka in (8, 9)
	group by g.group_NAME, s.subject_NAME
);
go

select * from otlichniki
go

create view Teacher_chair as (
	select left(t.teacher_NAME, 1) +'.' + left(t.teacher_OTCH, 1) + '.' + left(t.teacher_SURNAME, 15)
			+ '(' + left(t.teacher_POSITION, 10) + ')' as 'Dekanat_Teacher', c.chair_NAME as 'Dekanat_Chair', c.chair_CHIEF
	from DekanatSchema.TEACHER as t, DekanatSchema.CHAIR as c
	where c.chair_ID = t.chair_ID
);
go
select * from Teacher_chair
go

 --===============================================8 ЛАБ РАБОТА===================================================================
 -- процедура для вывода всех студентов
create procedure all_students as 
	begin
		select * from StudySchema.STUDENT
	end;

exec all_students
-- drop procedure all_students
go
 -- Процедура для перевода студентов на след курс
create procedure new_course as
begin
	update StudySchema.GROUPS
		set group_COURSE = group_COURSE + 1;
end;

exec new_course;
select * from StudySchema.GROUPS 
-- drop procedure new_course
go

-- Процедура добавления нового студента в группу
create procedure new_group
(
	@group_NAME NVARCHAR(10),
	@GROUP_KOLSTUD INT,
	@GROUP_COURSE INT 
) AS
BEGIN
	INSERT INTO StudySchema.GROUPS
		VALUES (
			@group_NAME,
			@GROUP_KOLSTUD,
			@GROUP_COURSE )
END;

EXEC new_group 'СИБп 19-10', 1, 3;
SELECT * FROM StudySchema.GROUPS

go
create procedure new_Teacher
(
	@teacher_SURNAME nvarchar(20), 
	@teacher_NAME nvarchar(20), 
	@teacher_OTCH nvarchar(20), 
	@teacher_POSITION nvarchar(20), 
	@teacher_STEPEN   nvarchar(20), 
	@chair_ID bigint,
	@salary bigint
	
) as 
begin
	insert into DekanatSchema.TEACHER
	values (@teacher_SURNAME, @teacher_NAME, 
			@teacher_OTCH, @teacher_POSITION, 
			@teacher_STEPEN, @chair_ID, @salary
	);
end;

exec new_Teacher 'Горбунова', 'Алла', 'Арсеньевна','Профессор', 'Зав.кафедры',	20,	100000
select * from DekanatSchema.TEACHER
go

-- Процедура для добавления нового предмета если он не существует

create procedure add_new_subject
(
	@subject_NAME nvarchar(20),
	@lection_hours int,
	@practice_hours int,
	@labor_hours int
) as
BEGIN
	declare @subject_ID int
	declare @total_hours int
	-- Если предмета не существует то добавляем его
	if not exists (select subject_NAME from StudySchema.SUBJECTS where @subject_NAME = subject_NAME)
	begin
		set @subject_ID = (select max(@subject_ID) from StudySchema.SUBJECTS) + 1
		set @total_hours = @lection_hours + @labor_hours + @practice_hours

		insert into StudySchema.SUBJECTS
		values
		(  @subject_NAME )
	end
END;

exec add_new_subject 'test2', 10, 10, 10;
select subject_NAME from StudySchema.SUBJECTS

go
--1. Отчислить/Зачислить студента.
create procedure add_new_student (
	@student_name nvarchar(20),
	@student_fam nvarchar(20),
	@student_otch nvarchar(20),
	@student_date date,
	@student_addr nvarchar(50),
	@student_male nvarchar(1),
	@speciality_name nvarchar(20),
	@group_name nvarchar(20),
	@course int = 1,
	@student_star int = null,
	@stipendia_value bigint = null,
	@grant nvarchar(3) = null,
	@city_id bigint = null,
	@in_obshejitie nvarchar(3) = null
) as
BEGIN
	declare @group_ID bigint
	declare @spec_ID bigint

	if @group_name not in (select group_NAME from StudySchema.GROUPS where @group_name = group_NAME)
		begin
			insert into StudySchema.GROUPS
				values (@group_name, 1, @course)
		end

	set @group_ID = (select group_ID from StudySchema.GROUPS where @group_name = group_NAME)
	set @spec_ID  = (select speciality_ID from StudySchema.SPECIALITY where @speciality_name = speciality_NAME)
	insert into StudySchema.STUDENT (student_NAME, student_SURNAME, student_OTCH, student_DATE, student_ADDRESS, student_male, student_STAR, group_ID, speciality_ID, stipendia_value, stund_GRANT, city_ID, in_obshejitie)
		values
		( @student_name, @student_fam, 
		@student_otch, @student_date, 
		@student_addr, @student_male, 
		@student_star, @group_ID, 
		@spec_ID, @stipendia_value, 
		@grant, @city_id, @in_obshejitie);
END;
GO

-- Процедура для удаления студента
create procedure delete_student (
	@student_ID bigint
) as
BEGIN
	delete from StudySchema.PROGRESS
		where student_ID = @student_ID;
	delete from StudySchema.STUDENT 
		where student_ID = @student_ID;
END;
GO

-- select * from StudySchema.STUDENT
exec add_new_student 'testname', 'testsurname', 'testotch', '20081212', 'Street', 'М', 'Экономика','testgrup';
-- exec delete_student 20

select * from StudySchema.STUDENT -- Добавился новый студент
--delete from StudySchema.STUDENT where student_NAME='testname'
select * from StudySchema.GROUPS  -- Добавилась новая группа
GO
--drop procedure add_new_student


--2. Увеличить суммы стипендий всех студентов на 15%.
create procedure add_percent_to_stipendia (
	@percent int
) as 
BEGIN
	update StudySchema.STUDENT 
	set stipendia_value = stipendia_value+(stipendia_value * @percent / 100);
END;

select student_ID, stipendia_value from StudySchema.STUDENT
exec add_percent_to_stipendia 15
select student_ID, stipendia_value from StudySchema.STUDENT
GO

--3. Ставить студентам оценки за различные виды работ (практика,
--контрольная, семестровая, курсовой проект, экзамен) по различным
--предметам.
--- ииспрравить
create procedure add_mark_to_student (
	@student_id bigint,
	@teacher_id bigint,
	@subject_id nvarchar(30),
	@ocenka     int
) as 
BEGIN
	declare @pr_date    date
	declare	@group_id   bigint

	set @pr_date = getdate()
	set @group_id = (select group_ID from StudySchema.STUDENT where student_ID = @student_id)

	insert into StudySchema.PROGRESS values
		(@student_id, @subject_id, @teacher_id, @group_id, @pr_date, @ocenka)
END

exec add_mark_to_student 21, 25, 29, 10
select * from StudySchema.PROGRESS

--delete from StudySchema.PROGRESS where student_ID=22
--drop procedure add_mark_to_student

select * from StudySchema.STUDY
GO

--4. Найти неуспевающих студентов.

create procedure show_students_with_low_mark  as
BEGIN
	select  pr.student_ID, s.student_SURNAME+' '+ s.student_NAME as 'FIO',  
			 (select subject_NAME from StudySchema.SUBJECTS as sb where sb.subject_ID = pr.subject_ID) as subject, pr.ocenka 
		from StudySchema.PROGRESS as pr join StudySchema.STUDENT as s
			on pr.student_ID = s.student_ID
	where pr.ocenka < 5
	order by subject_ID, ocenka;
END;

exec show_students_with_low_mark
GO

--5. Объединить две группы в одну.
create procedure join_groups_to_first_group  (
	@group_id1 bigint, -- Первая группа в какую объединить
	@group_id2 bigint
)  as
BEGIN
	update StudySchema.STUDENT 
		set group_ID = @group_id1 
			where group_ID = @group_id2;
	-- Из таблицы обучение удаляем
	delete from StudySchema.STUDY  where group_ID = @group_id2;
	-- Удаляем объединенную группу из таблицы групп
	delete from StudySchema.GROUPS where group_ID = @group_id2;
END;

select * from StudySchema.GROUPS
select student_NAME, group_ID from StudySchema.STUDENT
exec join_groups_to_first_group 4, 16
select student_NAME, group_ID from StudySchema.STUDENT
go
--6. Закрепление преподавателя по предмету за определенными группами, у которых преподаватель ведет предмет (Ввод информации в
--таблицу Study).

create procedure add_new_teacher_and_subject_to_group (
	@group_name     nvarchar(30),
	@subject_name   nvarchar(30),
	@teacher_FIO    nvarchar(50),
	@kredit_cnt     int,
	@lection_hours  int,
	@practice_hours int,
	@labor_hours    int
) as
begin
	declare @group_id   int = (select group_ID   from StudySchema.GROUPS    where group_NAME = @group_name)
	declare @subject_id int = (select subject_ID from StudySchema.SUBJECTS  where subject_NAME = @subject_name)
	declare @teacher_id int = (select teacher_ID from DekanatSchema.TEACHER  where teacher_SURNAME+ ' ' + teacher_NAME + ' ' + teacher_OTCH = @teacher_FIO)
	declare @total_hour int = 	@lection_hours  + @practice_hours + @labor_hours  

	insert into StudySchema.STUDY (group_ID, subject_ID, teacher_ID, kredit_cnt, total_hours, lection_hours, practice_hours, labor_hours) 
		values (
		@group_id,  @subject_id, 
		@teacher_id, @kredit_cnt, 
		@total_hour, @lection_hours, 
		@practice_hours, @labor_hours)
end;

exec add_new_teacher_and_subject_to_group 'ГИМУ 21-8', 'Философия', 'Жуков Мартын Витальевич', 5,10,15,15;
go
select * from StudySchema.STUDY
GO
--drop procedure add_new_teacher_and_subject_to_group

--7. Создать функцию, возвращающую количество студентов в конкретной группе.
create procedure show_amount_of_students_in_group (@show_empty_groups int = 1) as 
BEGIN
	IF  @show_empty_groups = 1
		begin
			(select  g.group_ID as 'Код группы', 
					g.group_NAME as 'Название группы', 
					count(s.student_ID) as 'Кол-во студентов'
				from StudySchema.GROUPS as g
				inner join StudySchema.STUDENT as s on s.group_ID = g.group_ID
			group by g.group_ID, g.group_NAME)
		end
	ELSE
		begin
			(select  g.group_ID as 'Код группы', 
					g.group_NAME as 'Название группы', 
					count(s.student_ID) as 'Кол-во студентов'
				from StudySchema.GROUPS as g
				left join StudySchema.STUDENT as s on s.group_ID = g.group_ID
			group by g.group_ID, g.group_NAME)
		end
END;

exec show_amount_of_students_in_group 0
-- drop procedure show_amount_of_students_in_group
GO

create function get_studnets_amount_in_group(@group_ID bigint)
returns int
as
	begin
	declare @student_id bigint
		 select @student_id = count(*) from StudySchema.STUDENT where group_ID = @group_ID
	return @student_id
	end;
go
select dbo.get_studnets_amount_in_group(1) 

select group_NAME, dbo.get_studnets_amount_in_group(group_ID) as 'Кол-во студентов'
	from StudySchema.GROUPS
	order by 2 desc
GO

--8. Создать функцию, возвращающую количество грантников на
--конкретной специальности.

create function count_grants(@spec_NAME nvarchar(20)) 
returns int
as
	begin
		declare @spec_ID bigint = (select speciality_ID from StudySchema.SPECIALITY where speciality_NAME = @spec_NAME)
			select @spec_ID = count(*) from StudySchema.STUDENT where speciality_ID = @spec_ID and stund_GRANT='yes'
	
		return @spec_ID
	end

go

select speciality_NAME                   as 'Специальность', 
	   dbo.count_grants(speciality_NAME) as 'Кол-во грантников'

from StudySchema.SPECIALITY
order by 2 desc

update StudySchema.PROGRESS
	set ocenka = ABS(CHECKSUM(NEWID()) % 11)
go
--drop function count_grants

go
---------------=========================ЗАДАНИЕ====================================
-- Считаем коливество предметов в группе
create function count_subjects_in_group(@group_id bigint)
returns int
as
BEGIN
	declare @students_count int =
		(select count(*) from StudySchema.GROUPS as g
		inner join StudySchema.STUDY as s on s.group_ID = g.group_ID
		inner join StudySchema.SUBJECTS as sub on s.subject_ID = sub.subject_ID
			where g.group_ID = @group_id)

	return @students_count
END
go

--По идентификатору берет название группы
create function get_group_name(@group_id bigint)
returns NVARCHAR(20)
as
BEGIN
	declare @group_NAME NVARCHAR(20) =
		(select group_NAME from StudySchema.GROUPS as g
			where g.group_ID = @group_id)
	return @group_NAME
END
go


GO
--По идентификатору берет название Предмета
create function get_subject_name(@subject_id bigint)
returns NVARCHAR(20)
as
BEGIN
	declare @subject_NAME NVARCHAR(20) =
		(select subject_NAME from StudySchema.SUBJECTS as s
			where s.subject_ID = @subject_id)
	return @subject_NAME
END
go
-- select dbo.get_group_name(1);
-- select dbo.get_subject_name(1);
-- select dbo.count_subjects_in_group(1)
GO
create function print_students_full_name (@student_ID BIGINT)
returns NVARCHAR(50) 
as
BEGIN
	declare @full_name NVARCHAR(50);
	set @full_name = (select student_SURNAME + ' ' + student_NAME + ' ' + student_OTCH from StudySchema.STUDENT where student_ID = @student_ID)
	return @full_name
END
GO


create function print_teachers_full_name (@teacher_ID BIGINT)
returns NVARCHAR(50) 
as
BEGIN
	declare @full_name NVARCHAR(50);
	set @full_name = (select teacher_SURNAME + ' ' + teacher_NAME + ' ' + teacher_OTCH from DekanatSchema.TEACHER where teacher_ID = @teacher_ID)
	return @full_name
END
GO
-- select dbo.print_students_full_name(1)



-- Этой командой авторизируется имя пользователя [DESKTOP-B32C0H6\test1], проверенное 
-- компьютером, чтобы получить доступ к экземпляру SQL Server. 
/*CREATE LOGIN [DESKTOP-B32C0H6\test1]
	 FROM WINDOWS 
	 WITH DEFAULT_DATABASE = lab_6; 
GO



-- Задание 1 - команда на создание логина SQL Server с именем и паролем

CREATE LOGIN test1 WITH PASSWORD='p@ssword1',
	DEFAULT_DATABASE=lab_6

CREATE LOGIN test2 WITH PASSWORD='p@ssword2',
	DEFAULT_DATABASE=lab_6
	-- Остановились на 11 стр --

	*/
USE lab_6;
GO

--  предоставляем пользователям test1, test2 доступ к базе данных LAB6 
CREATE USER test1 FOR LOGIN [DESKTOP-B32C0H6\test1]
CREATE USER test2 FOR LOGIN [DESKTOP-B32C0H6\test2]
GO
-- Создадим схему Accounting с владельцем test1
CREATE SCHEMA Accounting AUTHORIZATION test1;
GO

-- Добавление роли Managers
EXEC sp_addrole Managers;

--  роли баз данных вы можете создавать самостоятельно
CREATE ROLE DBRole1;

-- Добавление пользователя test1 в роль Managers
EXEC sp_addrolemember Managers, test1

----------------------3.2.1.5 Удаление ролей, учетных записей -----------------

-- процедура sp_droprolemember вычеркивает участника test1 из роли Managers
-- EXEC sp_droprolemember Managers, test1

-- sp_revokedbaccess (и ее устаревший аналог sp_dropuser) удаляет пользователя базы данных
-- sp_droplogin удаляет учетную запись из реестра сервера СУБД


--------------------- 3.2.1.6 Просмотр информации об учетных записях, ролях, привилегиях --------------------
-- получения отчета обо всех разрешениях, которые может предоставить участник, владеющий базой данных (dbo)
EXEC sp_helprotect NULL, NULL, dbo;  

-- Список разрешений для пользователя
EXEC sp_helprotect null, 'test1'; 

EXEC sp_helprotect @name = N'connect';  


EXEC sp_helprotect NULL, NULL, NULL, 's';   


EXEC sp_addrolemember Managers, test1;

--пользователю дать разрешения на создание таблиц
grant create table to test1

-- возможность просматривать данные в таблице
grant select on dbo.Reating to test1

-- Лишить ранее предоставленного права
revoke create table from test1
revoke select on dbo.Reating from test1

-- Запретить пользователю Student разрешение DELETE на таблицу Progress независимо от того, какие разрешения этот пользователь мог унаследовать от роли:

deny create table to test1
deny delete on StudySchema.PROGRESS to test1

-- разрешения SELECT и UPDATE пользователю Student определенные столбцы таблицы Progress
grant select, update (student_ID, ocenka) on StudySchema.PROGRESS to test1

grant select on DekanatSchema.TEACHER (teacher_SURNAME) to test2


-- отозвать доступ к отдельным столбцам при помощи  REVOKE.
revoke update (ocenka) on StudySchema.PROGRESS to test1

-- не допустить получения пользователем разрешения, необходимо использовать инструкцию DENY

-- revoke IMPERSONATE on LOGIN::Teacherlogin  to Studentlogin
-- revoke IMPERSONATE on LOGIN::Studentlogin  to Teacherlogin

exec sp_helpuser 
SELECT SUSER_NAME(), USER_NAME();  -- Сначала от имени владельца бд

-- 4. Для работы с базой данных будут использованы две роли – studentXX и teacherXX (XX – номер компьютера, за которым сидит исполнитель работы). 
-- Назначить роли teacherXX полный доступ ко всем объектам базы данных на просмотр таблиц и выполнение запросов SELECT, но не на создание новых таблиц и не на изменение данных в таблицах. Назначить роли studentXX доступ 
-- владельца базы данных, т.е. полный доступ на чтение и на изменение любых 
-- объектов базы данных. Составьте план выполнения необходимых хранимых 
-- процедур для того, чтобы выполнить такие действия, на бумаге.
/*
CREATE ROLE teacherXX;
CREATE ROLE studentXX;

grant select to teacherXX
deny create table to teacherXX


ALTER ROLE teacherXX     ADD MEMBER Teacher11;
ALTER ROLE db_datareader ADD MEMBER Teacher11;

ALTER ROLE studentXX     ADD MEMBER Student11;

grant connect to studentXX
deny select to studentXX


exec sp_helpuser teacherXX
exec sp_helprole teacherXX

--======================== ПОКАЗАТЬ ПРАВА РОЛИ В БАЗЕ ДАННЫХ =========================
SELECT DB_NAME() AS 'lab_6'
      ,p.[name] AS 'PrincipalName'
      ,p.[type_desc] AS 'PrincipalType'
      ,p2.[name] AS 'GrantedBy'
      ,dbp.[permission_name]
      ,dbp.[state_desc]
      ,so.[Name] AS 'ObjectName'
      ,so.[type_desc] AS 'ObjectType'
  FROM [sys].[database_permissions] dbp LEFT JOIN [sys].[objects] so
    ON dbp.[major_id] = so.[object_id] LEFT JOIN [sys].[database_principals] p
    ON dbp.[grantee_principal_id] = p.[principal_id] LEFT JOIN [sys].[database_principals] p2
    ON dbp.[grantor_principal_id] = p2.[principal_id]

WHERE p.[name] = 'teacherXX'
--==============================================================================================

--5. Пусть к данной базе данных будут иметь доступ два пользователя роли 
--teacherXX (teach1XX, teach2XX) и один пользователь роли studentXX
--(stud1XX). Составьте план выполнения необходимых хранимых процедур для 
--того, чтобы выполнить такие действия, на бумаге.

ALTER ROLE teacherXX ADD MEMBER test1;
EXECUTE AS user = 'test1';  
SELECT SUSER_NAME(), USER_NAME();  
select * from StudySchema.PROGRESS
revert;

ALTER ROLE studentXX ADD MEMBER test2;
EXECUTE AS user = 'test2';  
--select * from StudySchema.progress -- это будет запрещено 
revert;

*/
--6. Задайте от одной до трех учетных записей для доступа к серверу. 
--Составьте план выполнения необходимых хранимых процедур для того, чтобы 
--выполнить такие действия, на бумаге.

-- Этой командой авторизируется имя пользователя [DESKTOP-B32C0H6\test1], проверенное 
-- компьютером, чтобы получить доступ к экземпляру SQL Server. 
/*
CREATE LOGIN [DESKTOP-B32C0H6\test1]
	 FROM WINDOWS 
	 WITH DEFAULT_DATABASE = lab_6; 
GO

CREATE LOGIN [DESKTOP-B32C0H6\test2]
	 FROM WINDOWS 
	 WITH DEFAULT_DATABASE = lab_6; 
GO
CREATE USER test1 FOR LOGIN [DESKTOP-B32C0H6\test1]
CREATE USER test2 FOR LOGIN [DESKTOP-B32C0H6\test2]
*/

grant connect, select, update, insert to test1 --  Рарешаем юзеру1 доступ к базе


grant connect, select, update, insert to test2 --  Рарешаем юзеру2 доступ к базе
revoke select on dbo.Reating from test2          -- Но запрещаем селект с таблицы Рейтинг


exec sp_helprotect null, test1
exec sp_helprotect null, test2



PRINT '--------------------------РАБОТА С КУРСОРАМИ-----------------------'
PRINT ' '

-- Объявление переменных
DECLARE @group_ID BIGINT, @subject_ID BIGINT, @student_ID BIGINT, @teacher_ID BIGINT, @ocenka int;

-- Объявление курсора
DECLARE grup_cursor CURSOR FOR   
	SELECT group_ID FROM StudySchema.GROUPS
	where dbo.count_subjects_in_group(group_ID) >= 1

-- Открываем курсор
OPEN grup_cursor

-- Извлечь строку из курсора в переменные
FETCH NEXT FROM grup_cursor
	INTO @group_ID;

-- СНАЧАЛО ПО ГРУППАМ
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT cast(dbo.get_group_name(@group_ID) as nchar(10))  + 'кол-во предметов ' + cast(dbo.count_subjects_in_group(@group_ID) as nchar(30))		
		
	---- ПОТОМ ПО ПРЕДМЕТАМ
	DECLARE subject_cursor CURSOR FOR   
		SELECT subject_ID, teacher_ID FROM StudySchema.STUDY
			where group_ID = @group_ID

	OPEN subject_cursor
	FETCH NEXT FROM subject_cursor INTO @subject_ID, @teacher_ID;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT '		' + dbo.get_subject_name(@subject_ID) + ', ' +  dbo.print_teachers_full_name(@teacher_ID)


			---- ПОТОМ ПО ПРЕДМЕТАМ
			DECLARE progress_cursor CURSOR FOR   
				SELECT student_ID, ocenka FROM StudySchema.PROGRESS
					where group_ID = @group_ID and subject_ID = @subject_ID

			OPEN progress_cursor
				FETCH NEXT FROM progress_cursor
					INTO @student_ID, @ocenka;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT '				' +  cast(dbo.print_students_full_name(@student_ID) as nchar(30)) + ' ' +  cast(@ocenka as nchar(10));
					FETCH NEXT FROM progress_cursor
					INTO @student_ID, @ocenka;
				END
			CLOSE progress_cursor;  
			DEALLOCATE progress_cursor;

			FETCH NEXT FROM subject_cursor INTO @subject_ID, @teacher_ID;
		END

	CLOSE subject_cursor;  
	DEALLOCATE subject_cursor;
	-------------------------------------
	FETCH NEXT FROM grup_cursor
	INTO @group_ID;
	PRINT ''
END
CLOSE grup_cursor;  
DEALLOCATE grup_cursor;

/*
create trigger teach_tr1
on DekanatSchema.TEACHER
	for insert as
	print 'СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР: !!!Вставка строк запрещена'
	ROLLBACK TRAN
go

-- exec new_Teacher 'Горбунова', 'Алла', 'Арсеньевна','Профессор', 'Зав.кафедры',	20,	100000
go

-- drop trigger teach_tr1

create trigger stipendia_trigger
on StudySchema.STUDENT
	for insert, update
	as
	declare @stip int -- Локальная переменная
	select @stip = U.stipendia_value  -- Информация о вставляемой записи
	from inserted U
	if @stip > 15000
	begin
	ROLLBACK TRAN  -- Для отмены транзакции
	RAISERROR('СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР:  Стипендия студента не может превышать 15000тг', 15, 15)
	end;
GO
--DROP TRIGGER [StudySchema].[stipendia_trigger]
-- exec add_percent_to_stipendia 20

go
create trigger insert_progress_trigger
	on StudySchema.PROGRESS
	for insert, update as
BEGIN
	-- описываем локальные переменные
	declare @nDayofMonth tinyint
	--- Определяется информация о вставляемых записях
	select @nDayofMonth = datepart(day, I.pr_date)
	from PROGRESS P, inserted I
		where P.student_ID = I.student_ID and P.ocenka = I.ocenka
	-- проверка условия вставки
	if @nDayofMonth > 15
	begin
	rollback tran
	raiserror('СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР: Вводить оценки полученные до 15го числа', 16, 10)
	end;
END;

 drop trigger StudySchema.insert_progress_trigger

select * from StudySchema.STUDY
select * from StudySchema.GROUPS
select * from StudySchema.STUDENT

insert into StudySchema.STUDY (group_ID, subject_ID, teacher_ID) values
(15, 29, 25)

--delete from StudySchema.STUDY where group_ID=15 and subject_ID=29 and teacher_ID=25
--delete from StudySchema.PROGRESS where group_ID=15 and subject_ID=29 and teacher_ID=25 and student_ID=20
insert into StudySchema.PROGRESS values
(20, 29, 25, 15,'20211115', 10)

-- select * from StudySchema.PROGRESS
-- select group_ID, subject_ID, teacher_ID from StudySchema.STUDY
-- select student_ID, group_ID from StudySchema.STUDENT

GO
create trigger add_student_trigger  -- Cоздать триггер при добавлении студента
on StudySchema.STUDENT              -- Для таблицы студент
for insert                          -- При добавлении значения
as declare @grup int					-- Локальная переменная идентификатора группы		
	select @grup = I.group_ID		-- Выборать группу равную введенной группе
	from inserted I                 -- Из введенных данных
		update StudySchema.GROUPS   -- Обновить значение в таблице группы
		set StudySchema.GROUPS.group_KOLSTUD = (select count(*) from StudySchema.STUDENT where group_ID = @grup)-- Увличить значение на единицу
			where StudySchema.GROUPS.group_ID = @grup    -- где идентификатор группы равен введенному идентификатору группы

go
--drop trigger  StudySchema.add_student_trigger
exec add_new_student 'test2name', 'test2fam', 'test2otch', '20001010', 'testaddr', 'М', 'Экономика', 'testgroup'
exec add_new_student 'test2name', 'test2fam', 'test2otch', '20001010', 'testaddr', 'М', 'Экономика', 'testgroup'

select * from StudySchema.STUDENT where group_ID=16
select * from StudySchema.GROUPS where group_ID=16
go

-- ДОБАВЛЯЕМ НОВЫЙ СТОЛБЕЦ В ТАБЛИЦУ ПРЕПОДОВАТЕЛЕЙ
alter table DekanatSchema.TEACHER add rab_date date;
go

-- РАНДОМНО ЗАПОЛНЯЕМ ДАТУ ПРИНЯТИЯ НА РАБОТУ
update DekanatSchema.TEACHER
	set rab_date = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3650), '2000-01-01')
go


CREATE TRIGGER mol_spec
	on StudySchema.STUDY
	for insert, update
	as 
	declare @hour int
	select @hour = (select sum(s.total_hours) from StudySchema.STUDY s, inserted i 
							where s.teacher_ID = i.teacher_ID)
	begin
	declare @staj datetime 
	set @staj = (select floor(DATEDIFF(day, t.rab_date, getdate()) / 365.25) 
					from DekanatSchema.TEACHER as t, inserted i
					where i.teacher_ID = t.teacher_ID)
	IF (@hour > 200 and @staj <= 5)
	begin
	ROLLBACK tran 
	raiserror ('СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР: МОЛОДОЦ СПЕЦИАЛИСТ не может взять более 200 часов занятий', 16, 10)
	end
	end;
GO
select * from DekanatSchema.TEACHER

-- Добавляем идендификатор старосты для таблицы группы 
alter table StudySchema.GROUPS add starosta_ID bigint
go

update StudySchema.GROUPS
	set starosta_ID = (select top 1 student_ID from StudySchema.STUDENT as s where s.group_ID = StudySchema.GROUPS.group_ID)
go

update StudySchema.STUDENT
	set student_STAR = (select top 1 student_ID from StudySchema.STUDENT as s where s.group_ID = StudySchema.STUDENT.group_ID)
go

select * from StudySchema.GROUPS
select * from StudySchema.STUDENT

--- Триггер для автоматического обновления старосты для группы
GO
create trigger update_starosta
	on StudySchema.GROUPS
AFTER UPDATE as 
IF (COLUMNS_UPDATED() > 0)
begin
	declare @stud_star bigint
	declare @group bigint
	
	select  @stud_star = I.starosta_ID, 
			@group =		 I.group_ID 
	from inserted as I  -- ПРИМЕНИТЬ ИЗМЕНЕНИЯ ИЗ ИЗМЕНЕННОЙ ТАБЛИЦЫ ПО ЗНАЧЕНИЯМ
	
	print @stud_star
	print @group

	update StudySchema.STUDENT
		set student_STAR = @stud_star
		where StudySchema.STUDENT.group_ID = @group
end;
GO

--drop trigger StudySchema.update_starosta

--== ДО
select group_ID, starosta_ID from StudySchema.GROUPS where group_ID = 1
select student_ID, group_ID, student_STAR from StudySchema.STUDENT where group_ID = 1
go

update StudySchema.GROUPS
	set starosta_ID = 3
	where group_ID = 1
go
--== ПОСЛЕ ОБНОВЛЕНИЯ
select group_ID, starosta_ID from StudySchema.GROUPS where group_ID = 1
select student_ID, group_ID, student_STAR from StudySchema.STUDENT where group_ID = 1


--- Таблица для журналирования изменений в базе данных
create table journ (
	mod_oper nvarchar(20),  -- тип выполняемой операции
	mod_datetime datetime,  -- Дата изменения
	mod_user nvarchar(30),  -- Пользователь БД
	mod_id int,             -- идентификатор студента
	mod_ocen int, -- измененная оценка студента
	old_ocen int 
)
GO
create trigger reg_oc
	on StudySchema.PROGRESS
	for update
	as
	declare @id bigint, 
			@ocenka int,
			@old_ocen int

	select  @old_ocen = P.ocenka, 
			@id = P.student_ID, 
			@ocenka = U.ocenka
	from StudySchema.PROGRESS P inner join Inserted U on U.student_ID = P.student_ID
	insert into journ
VALUES ('Обновлена', current_timestamp, current_user, @id, @ocenka, @old_ocen);
GO		
-- drop trigger StudySchema.reg_oc
update StudySchema.PROGRESS
	set ocenka = 9, pr_date='20211010' where student_ID=2 and subject_ID=30

select * from journ

go


create table audit_student (
	student_ID    bigint        null,
	user_name     nvarchar(20)  null,
	date          datetime      null,
	stud_stip_old int           null,
	stud_stip_new int           null
);

GO
create trigger modify_student
	on StudySchema.STUDENT after update as 
IF update(stipendia_value)
	begin
		declare @old_stip int
		declare @new_stip int
		declare @snumber  bigint

		select @old_stip = (select stipendia_value from deleted)
		select @new_stip = (select stipendia_value from inserted)
		select @snumber  = (select student_ID from inserted)
		insert into audit_student values

		(@snumber, USER_NAME(), getdate(), @old_stip, @new_stip)
	end;
go
-- drop trigger modify_student
update StudySchema.STUDENT 
	set stipendia_value = 14000        
		where student_ID=1;

select * from StudySchema.STUDENT  where student_ID=1
select * from audit_student

--=========================== 9 ЛАБОРАТОРНАЯ РАБОТА ===========================
-- Задание на лабораторную работу 

-- 1. В вузы на очную форму обучения принимаются абитуриенты моложе 35 лет. 
--	Создайте тригтер, позволяющий контролировать возраст студента 
--  при выполнении зачисления студента (ввода данных в таблицу Students).
GO
create trigger check_student_age_trigger 
	ON StudySchema.STUDENT FOR INSERT, update as
BEGIN
	declare @age int
	select  @age = (select (year(getdate()) - year(s.student_DATE)) from StudySchema.STUDENT s, inserted i 
							where s.student_ID = i.student_ID)
	IF (@age > 35)
	begin
		ROLLBACK tran 
		raiserror ('СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР => check_student_age_trigger: Абитурент не может быть старше 35 лет', 16, 10)
	end
END;
GO

update StudySchema.STUDENT
	set student_DATE = '19901010' where student_ID=1
-- drop trigger StudySchema.check_student_age_trigger

-- 2. Теоретически в БД можно ошибочно внести оценку студенту по предмету, который он не изучает вовсе. 
-- Задача: разработать тригтер, контролирующий (сумму) количество сданных предметов, 
-- которые не должны превышать количество предметов, изучаемых группой студента (таблицы Progress и Subject) с информацией о предметах, изучаемых студентами (таблица Study).
GO

create trigger check_given_mark 
	on StudySchema.PROGRESS
	FOR INSERT, UPDATE AS
BEGIN
	declare @subject_ID    bigint
	declare @stud_group_ID bigint
	declare @teacher_ID    bigint
	declare @student_ID    bigint

	select  @subject_ID = i.subject_ID,
			@stud_group_ID = i.group_ID,
			@teacher_ID    = i.teacher_ID,
			@student_ID    = i.student_ID 

	from inserted i

	print(@subject_ID)
	print(@stud_group_ID)
	print(@teacher_ID)
	print(@student_ID)

	-- Если студент не находится в группе по которой ставят оценки определенным студентам,
	-- в которой изучается этот предмет
	if @subject_ID not in (select subject_ID from StudySchema.STUDY	  where group_ID = @stud_group_ID)
	begin
		ROLLBACK tran 
		raiserror ('СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР => check_given_mark: ЭТОТ ПРЕДМЕТ НЕ ИЗУЧАЕТСЯ В ДАННОЙ ГРУППЕ', 16, 10)
	end

	if  @teacher_ID not in (select teacher_ID from StudySchema.STUDY	  where group_ID = @stud_group_ID)
	begin
		ROLLBACK tran 
		raiserror ('СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР => check_given_mark: ЭТОТ ПРЕПОДОВАТЕЛЬ НЕ ВЕДЕТ УРОКИ В ДАННОЙ ГРУППЕ', 16, 10)
	end

	if @student_ID not in (select student_ID from StudySchema.STUDENT where group_ID = @stud_group_ID)

	begin
		ROLLBACK tran 
		raiserror ('СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР => check_given_mark: Такого студента не существует либо он в другой группе', 16, 10)
	end

	if (select count(subject_ID) from StudySchema.PROGRESS where student_ID = @student_ID) 
		> (select count(subject_ID) from StudySchema.STUDY where group_ID = @stud_group_ID)
	begin
		ROLLBACK tran 
		raiserror ('СРАБОТАЛ ПОЛЬЗОВАТЕЛЬСКИЙ ТРИГГЕР => check_given_mark: Нельзя добавить больше оценок чем изучаемых предметов', 16, 10)
	end

END;	

select * from StudySchema.STUDY where group_ID = 1
select * from StudySchema.PROGRESS where student_ID = 1
 
-- drop trigger StudySchema.check_given_mark


select * from StudySchema.STUDY

insert into StudySchema.STUDY
values
(1, 22, 1, 5, 45, 15,15,15)


insert into StudySchema.PROGRESS
	values
	(7, 22, 1, 1, '20211010', 10)  -- 7ой студент не с первой группе

select * from StudySchema.PROGRESS where student_ID=7


-- 3. Создать триггер, который бы журналировал (отслеживал) действия определенного пользователя БД, 
-- производимые над какой-либо таблицей в определенный промежуток времени.

create table journ (
	mod_oper nvarchar(20),  -- тип выполняемой операции
	mod_datetime datetime,  -- Дата изменения
	mod_user nvarchar(30),  -- Пользователь БД
	mod_id int,             -- идентификатор студента
	mod_ocen int, -- измененная оценка студента
	old_ocen int 
)
GO
	

create table user_actions_journal (
	operation_type nvarchar(150) null,
	username		   nvarchar(20) null,
	action_date    date      null,
);
go
-- drop table dbo.user_actions_journal
create trigger user_actions_trigger 
	ON StudySchema.STUDY  
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
	SET @operation_type = 'DELETE ' + 'from StudySchema.PROGRESS'
	insert into user_actions_journal
		VALUES (@operation_type , current_user, getdate());
END;
go

select * from StudySchema.STUDENT where group_ID=15

insert into StudySchema.PROGRESS values (20, 29, 25, 15, '20211010', 10)
select * from StudySchema.PROGRESS where group_ID=15
select * from StudySchema.STUDY where group_ID=15

delete from StudySchema.PROGRESS where group_ID=15 -- Удаляем тестовую группу
delete from StudySchema.STUDY where group_ID=15    -- Удаляем тестовую группу

select * from user_actions_journal

-- drop trigger StudySchema.user_actions_trigger

-- 4. Теоретически в БД можно ошибочно ввести стипендию студенту, 
-- который закрыл сессию с удовлетворительными оценками. 
-- Задача: разработать триггер, контролирующий оценки, полученные студентом и наличие его стипендии.
go
create trigger check_stipendia 
	ON StudySchema.PROGRESS
	after insert, update as
BEGIN
	DECLARE @input_ocenka     int,
			@avg_ocenka       int,
			@student_ID       bigint,
			@stipendia_price  bigint

	select  @input_ocenka = I.ocenka, 
			@student_ID   =	I.student_ID 
	from inserted as I  -- ПРИМЕНИТЬ ИЗМЕНЕНИЯ ИЗ ИЗМЕНЕННОЙ ТАБЛИЦЫ ПО ЗНАЧЕНИЯМ

	set @avg_ocenka = (select avg(ocenka) from StudySchema.PROGRESS where student_ID = @student_ID);

	print 'student ID: '+ cast(@student_ID as nvarchar(10)) 
	print 'средняя оценка после добавления: ' + cast(@avg_ocenka as nvarchar(10)) 

	if @avg_ocenka >= 9
		begin
			set @stipendia_price = 15000;
		end
	else if @avg_ocenka >= 7
		begin
			set @stipendia_price = 10000;
		end
	else 
		begin
			set @stipendia_price = 0;
		end;

	update StudySchema.STUDENT
		set stipendia_value  = @stipendia_price
			where StudySchema.STUDENT.student_ID = @student_ID

END

select * from StudySchema.PROGRESS where student_ID=1
--drop trigger StudySchema.check_stipendia
update StudySchema.PROGRESS
	set ocenka = 10
		where StudySchema.PROGRESS.student_ID = 1 and subject_ID=27

select student_ID, stipendia_value from  StudySchema.STUDENT where student_ID=1

*/
--============================================КУРСОРЫ==================================
DECLARE one_stud CURSOR  
    FOR SELECT * FROM   StudySchema.STUDENT
OPEN one_stud  
FETCH NEXT FROM one_stud;  -- Получает определенную строку из серверного курсора дословно ФЕТЧ ЭТО ИЗВЛЕЧЬ

CLOSE one_stud;  -- Закрывает открытый курсор
DEALLOCATE one_stud;  -- Удаляет ссылку курсора. Когда удаляется последняя ссылка курсора, SQL Server освобождает структуры данных, составляющие курсор.


GO
-- Функция для вычисления полного возвраста 
create function full_age(@born_date date) 
returns nvarchar(50) as
BEGIN
	DECLARE @date datetime, @tmpdate datetime, @years int, @months int, @days int, @result nvarchar(50)
	SET @date = @born_date

	SET @tmpdate = @date

	SET @years = DATEDIFF(yy, @tmpdate, GETDATE()) - CASE WHEN (MONTH(@date) > MONTH(GETDATE())) OR (MONTH(@date) = MONTH(GETDATE()) AND DAY(@date) > DAY(GETDATE())) THEN 1 ELSE 0 END
	SET @tmpdate = DATEADD(yy, @years, @tmpdate)
	SET @months = DATEDIFF(m, @tmpdate, GETDATE()) - CASE WHEN DAY(@date) > DAY(GETDATE()) THEN 1 ELSE 0 END
	SET @tmpdate = DATEADD(m, @months, @tmpdate)
	SET @days = DATEDIFF(d, @tmpdate, GETDATE())

	SET @result = convert(nvarchar(4), @years) + ' лет ' +  convert(nvarchar(2), @months) + ' месяцев ' + convert(nvarchar(2), @days) + ' дней' 
	
	return @result
END

GO

PRINT '--------------------------РАБОТА С КУРСОРАМИ-----------------------'
PRINT ' '
PRINT '   ' + cast('ФАМИЛИЯ' as nchar(18)) + cast('ИМЯ' as nchar(15)) + ' ' + cast('ПОЛНЫЙ ВОЗВРАСТ' as nchar(30)) + ' ' + cast('АДРЕС' as nchar(60)) 
PRINT '------------------------------------------------------------------------------'

-- Объявление переменных
DECLARE @stud_surname NVARCHAR(50), @stud_name NVARCHAR(50), @born_date date, @address NVARCHAR(60), @cnt int;

-- Объявление курсора
DECLARE student_info_cursor CURSOR FOR   
	SELECT student_SURNAME, student_NAME, student_DATE, student_ADDRESS FROM StudySchema.STUDENT -- Который рабоатет с этими атрибутами
		order by student_DATE -- Отсортированные по дате рождения

-- Открываем курсор
OPEN student_info_cursor

-- Извлечь строку из курсора в переменные
FETCH NEXT FROM student_info_cursor
	INTO @stud_surname, @stud_name, @born_date, @address;

set @cnt = 1;

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT cast(@cnt as nchar(3)) + cast(@stud_surname as nchar(15)) + ' ' + cast(@stud_name as nchar(15)) + ' ' + cast(dbo.full_age(@born_date) as nchar(30)) + ' ' + @address
	set @cnt = @cnt + 1; -- Увеличиваем счетчик идентификатора на единицу
	FETCH NEXT FROM student_info_cursor
	INTO @stud_surname, @stud_name, @born_date, @address;
END


CLOSE student_info_cursor;  
DEALLOCATE student_info_cursor;





