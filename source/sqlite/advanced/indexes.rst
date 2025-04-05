.. _sqlite-indexes:

1. Работа с индексами в SQLite
==============================

Индексы - это специальные объекты базы данных, которые ускоряют поиск и сортировку данных.

Создание и удаление индексов
----------------------------

**Создание индекса:**

.. code-block:: sql

    -- Простой индекс для одного столбца
    CREATE INDEX idx_customer_name ON customers(customerName);

    -- Уникальный индекс
    CREATE UNIQUE INDEX idx_unique_email ON employees(email);

    -- Составной индекс (по нескольким столбцам)
    CREATE INDEX idx_city_country ON customers(city, country);

**Удаление индекса:**

.. code-block:: sql

    DROP INDEX idx_customer_name;

Оптимизация запросов с помощью индексов
--------------------------------------

Индексы особенно полезны для:

1. Ускорения поиска по условиям WHERE
2. Оптимизации JOIN-операций
3. Ускорения сортировки (ORDER BY)

**Примеры эффективного использования:**

.. code-block:: sql

    -- Этот запрос использует индекс idx_customer_name
    SELECT * FROM customers
    WHERE customerName = 'Atelier graphique';

    -- Использование составного индекса
    SELECT * FROM customers
    WHERE city = 'Paris' AND country = 'France';

**Когда индексы не помогают:**
- При обработке небольших таблиц
- Если условие использует функции (WHERE UPPER(name) = 'SMITH')
- При неселективных условиях (WHERE status IN ('active', 'inactive'))

EXPLAIN QUERY PLAN - анализ выполнения запросов
----------------------------------------------

Команда EXPLAIN QUERY PLAN показывает как SQLite выполняет запрос:

.. code-block:: sql

    EXPLAIN QUERY PLAN
    SELECT c.customerName, o.orderDate
    FROM customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    WHERE c.country = 'USA';

**Пример вывода:**

===========  ===========  =============  =================================
`order`      `from`       `detail`       `description`
===========  ===========  =============  =================================
0            0           0               SCAN TABLE customers AS c
0            1           1               SEARCH TABLE orders AS o USING INDEX idx_customer (customerNumber=?)
===========  ===========  =============  =================================

**Ключевые термины:**
- `SCAN TABLE` - полный перебор таблицы (медленно)
- `SEARCH TABLE` - поиск по индексу (быстро)
- `USING INDEX` - указывает на используемый индекс

Практические рекомендации
------------------------

1. Создавайте индексы для часто используемых условий WHERE
2. Для JOIN-операций индексируйте поля связи
3. Используйте составные индексы для часто совместно запрашиваемых полей
4. Избегайте избыточных индексов - они замедляют INSERT/UPDATE
5. Анализируйте запросы с EXPLAIN QUERY PLAN
6. Для текстового поиска используйте FTS (Full Text Search)

**Пример создания оптимального индекса:**

.. code-block:: sql

    -- Перед созданием индекса анализируем запрос
    EXPLAIN QUERY PLAN
    SELECT * FROM orders
    WHERE orderDate BETWEEN '2023-01-01' AND '2023-12-31'
    AND status = 'Shipped';

    -- Создаем индекс для ускорения
    CREATE INDEX idx_order_date_status ON orders(orderDate, status);

    -- Проверяем использование индекса
    EXPLAIN QUERY PLAN
    SELECT * FROM orders
    WHERE orderDate BETWEEN '2023-01-01' AND '2023-12-31'
    AND status = 'Shipped';
