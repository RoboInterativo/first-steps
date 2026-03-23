## Полная теория SQL для Data Analyst (на базе Northwind)

---

### 1. Базовые SELECT запросы

#### Теория
**SELECT** — основа всех запросов в SQL. Позволяет выбирать данные из таблиц.

```sql
SELECT столбцы FROM таблица WHERE условия;
```

#### Ключевые элементы

| Элемент | Описание | Пример |
|---------|----------|--------|
| `SELECT *` | Выбрать все столбцы | `SELECT * FROM customers` |
| `SELECT column1, column2` | Выбрать конкретные столбцы | `SELECT company_name, country FROM customers` |
| `SELECT DISTINCT` | Убрать дубликаты | `SELECT DISTINCT country FROM customers` |
| `WHERE` | Фильтрация строк | `WHERE country = 'USA'` |
| `AND/OR` | Логические операторы | `WHERE country = 'USA' AND city = 'Portland'` |
| `IN` | Проверка на вхождение | `WHERE country IN ('USA', 'Canada', 'UK')` |
| `BETWEEN` | Диапазон значений | `WHERE unit_price BETWEEN 10 AND 50` |
| `LIKE` | Поиск по шаблону | `WHERE product_name LIKE '%Chai%'` |
| `IS NULL` | Проверка на NULL | `WHERE region IS NULL` |
| `ORDER BY` | Сортировка | `ORDER BY order_date DESC` |
| `LIMIT` | Ограничение количества строк | `LIMIT 10` |

#### LIKE операторы
| Оператор | Значение |
|----------|----------|
| `%` | Любое количество символов |
| `_` | Один символ |
| `[a-z]` | Диапазон символов (не во всех СУБД) |
| `[^a-z]` | Исключение (не во всех СУБД) |

#### Примеры
```sql
-- Все продукты с ценой от 20 до 100
SELECT product_name, unit_price
FROM products
WHERE unit_price BETWEEN 20 AND 100;

-- Клиенты с email на gmail (если есть поле email)
SELECT company_name
FROM customers
WHERE contact_name LIKE '%@gmail.com';

-- Сотрудники, нанятые в 1993 году
SELECT first_name, last_name
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 1993;
```

---

### 2. Агрегирующие функции и GROUP BY

#### Теория
Агрегирующие функции выполняют вычисления над набором строк и возвращают одно значение.

| Функция | Описание | Пример |
|---------|----------|--------|
| `COUNT(*)` | Количество строк | `COUNT(*)` |
| `COUNT(column)` | Количество не-NULL значений | `COUNT(region)` |
| `COUNT(DISTINCT column)` | Количество уникальных значений | `COUNT(DISTINCT country)` |
| `SUM(column)` | Сумма значений | `SUM(unit_price * quantity)` |
| `AVG(column)` | Среднее значение | `AVG(unit_price)` |
| `MAX(column)` | Максимальное значение | `MAX(order_date)` |
| `MIN(column)` | Минимальное значение | `MIN(unit_price)` |

#### GROUP BY
Группирует строки с одинаковыми значениями для агрегации.

**Важное правило:** Все неагрегированные столбцы в SELECT должны быть в GROUP BY.

```sql
SELECT
    category_id,
    COUNT(*) as products_count,
    AVG(unit_price) as avg_price,
    MIN(unit_price) as min_price,
    MAX(unit_price) as max_price
FROM products
GROUP BY category_id;
```

#### Примеры
```sql
-- Количество заказов по сотрудникам
SELECT
    employee_id,
    COUNT(order_id) as orders_count,
    SUM(freight) as total_freight
FROM orders
GROUP BY employee_id
ORDER BY orders_count DESC;

-- Средняя сумма заказа по клиентам
SELECT
    customer_id,
    COUNT(order_id) as order_count,
    AVG(freight) as avg_freight
FROM orders
GROUP BY customer_id;
```

---

### 3. JOIN операции

#### Теория
**JOIN** объединяет данные из двух или более таблиц на основе связанных столбцов.

### Типы JOIN
| Тип | Описание | Диаграмма Венна |
|-----|----------|-----------------|
| `INNER JOIN` | Только совпадающие строки в обеих таблицах | Пересечение |
| `LEFT JOIN` | Все строки из левой + совпадающие из правой | Левая + пересечение |
| `RIGHT JOIN` | Все строки из правой + совпадающие из левой | Правая + пересечение |
| `FULL OUTER JOIN` | Все строки из обеих таблиц | Объединение |
| `CROSS JOIN` | Декартово произведение | Все комбинации |

#### Синтаксис
```sql
SELECT t1.column, t2.column
FROM table1 t1
[INNER | LEFT | RIGHT | FULL] JOIN table2 t2
    ON t1.key = t2.key;
```

#### Примеры
```sql
-- INNER JOIN: только заказы с клиентами
SELECT o.order_id, c.company_name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- LEFT JOIN: все продукты, даже те, что не продавались
SELECT p.product_name, SUM(od.quantity) as total_sold
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_name;

-- Множественные JOIN
SELECT
    o.order_id,
    c.company_name,
    e.first_name || ' ' || e.last_name as employee_name,
    s.company_name as shipper_name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN employees e ON o.employee_id = e.employee_id
INNER JOIN shippers s ON o.ship_via = s.shipper_id;
```

---

### 4. Подзапросы (Subqueries)

#### Теория
**Подзапрос** — это запрос внутри другого запроса SQL.

#### Типы подзапросов

| Тип | Место использования | Пример |
|-----|---------------------|--------|
| Скалярный | SELECT | `SELECT (SELECT COUNT(*) FROM orders) as total_orders` |
| Строковый | FROM | `SELECT * FROM (SELECT ...) as sub` |
| Табличный | WHERE/HAVING | `WHERE column IN (SELECT ...)` |
| Коррелированный | WHERE/EXISTS | `WHERE EXISTS (SELECT 1 FROM ... WHERE ...)` |

#### Примеры
```sql
-- Подзапрос в WHERE: продукты дороже среднего
SELECT product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products);

-- Подзапрос с IN: клиенты из стран с заказами
SELECT company_name, country
FROM customers
WHERE country IN (
    SELECT DISTINCT ship_country
    FROM orders
);

-- Коррелированный подзапрос: сотрудники с заказами > среднего
SELECT
    employee_id,
    COUNT(order_id) as order_count
FROM orders o1
GROUP BY employee_id
HAVING COUNT(order_id) > (
    SELECT AVG(order_count)
    FROM (SELECT COUNT(*) as order_count
          FROM orders
          GROUP BY employee_id) as avg_orders
);

-- EXISTS: клиенты, которые делали заказы
SELECT company_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

#### Коррелированные vs Некоррелированные

| Тип | Описание | Производительность |
|-----|----------|-------------------|
| Некоррелированный | Выполняется один раз | Лучше |
| Коррелированный | Выполняется для каждой строки внешнего запроса | Хуже |

---

### 5. Оконные функции (Window Functions)

#### Теория
Оконные функции выполняют вычисления над набором строк, связанных с текущей строкой, **без группировки** (сохраняют все строки).

#### Синтаксис
```sql
Функция() OVER (
    [PARTITION BY column1, column2]  -- Разбиение на группы
    [ORDER BY column3, column4]       -- Порядок внутри группы
    [ROWS | RANGE между строками]     -- Определение окна
)
```

#### Классификация оконных функций

##### 1. Ранжирующие функции
| Функция | Описание |
|---------|----------|
| `ROW_NUMBER()` | Уникальный номер строки (1,2,3,4,5) |
| `RANK()` | Ранг с пропусками при связях (1,2,2,4,5) |
| `DENSE_RANK()` | Ранг без пропусков (1,2,2,3,4) |
| `NTILE(n)` | Разбивает на n групп |

##### 2. Агрегирующие оконные функции
| Функция | Описание |
|---------|----------|
| `SUM() OVER()` | Накопительная сумма |
| `AVG() OVER()` | Скользящее среднее |
| `COUNT() OVER()` | Накопительный счетчик |
| `MAX()/MIN() OVER()` | Максимум/минимум в окне |

##### 3. Функции смещения
| Функция | Описание |
|---------|----------|
| `LAG(column, offset)` | Доступ к предыдущей строке |
| `LEAD(column, offset)` | Доступ к следующей строке |
| `FIRST_VALUE(column)` | Первое значение в окне |
| `LAST_VALUE(column)` | Последнее значение в окне |

#### Примеры
```sql
-- Ранжирование продуктов по цене в категории
SELECT
    product_name,
    category_id,
    unit_price,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY unit_price DESC) as row_num,
    RANK() OVER (PARTITION BY category_id ORDER BY unit_price DESC) as rank,
    DENSE_RANK() OVER (PARTITION BY category_id ORDER BY unit_price DESC) as dense_rank
FROM products;

-- Накопительная сумма (running total)
SELECT
    order_date,
    freight,
    SUM(freight) OVER (ORDER BY order_date) as running_total
FROM orders;

-- Скользящее среднее за 3 дня
SELECT
    order_date,
    freight,
    AVG(freight) OVER (ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg_3
FROM orders;

-- LAG/LEAD: сравнение с предыдущим заказом
SELECT
    order_id,
    order_date,
    freight,
    LAG(freight, 1) OVER (ORDER BY order_date) as prev_freight,
    freight - LAG(freight, 1) OVER (ORDER BY order_date) as freight_diff
FROM orders;

-- Процент от общего
SELECT
    category_id,
    SUM(unit_price) as category_sum,
    SUM(unit_price) / SUM(SUM(unit_price)) OVER() * 100 as pct_of_total
FROM products
GROUP BY category_id;
```

#### Оконные функции vs GROUP BY

| Характеристика | GROUP BY | Оконные функции |
|----------------|----------|-----------------|
| Количество строк | Уменьшается | Сохраняется |
| Использование | Простая агрегация | Сложные аналитические расчеты |
| Пример | Среднее по категориям | Ранжирование, скользящее среднее |

---

### 6. Работа с датами

#### Теория
Функции для работы с датами различаются в разных СУБД.

#### PostgreSQL

| Функция | Описание | Пример |
|---------|----------|--------|
| `EXTRACT(field FROM date)` | Извлечение части даты | `EXTRACT(YEAR FROM order_date)` |
| `DATE_TRUNC('unit', date)` | Округление даты | `DATE_TRUNC('month', order_date)` |
| `AGE(date1, date2)` | Разница между датами | `AGE(CURRENT_DATE, birth_date)` |
| `date1 - date2` | Разница в днях | `order_date - ship_date` |
| `date + INTERVAL` | Добавление интервала | `order_date + INTERVAL '30 days'` |
| `CURRENT_DATE` | Текущая дата | `CURRENT_DATE` |
| `NOW()` | Текущие дата и время | `NOW()` |

#### MySQL

| Функция | Описание | Пример |
|---------|----------|--------|
| `YEAR(date)` | Год | `YEAR(order_date)` |
| `MONTH(date)` | Месяц | `MONTH(order_date)` |
| `DAY(date)` | День | `DAY(order_date)` |
| `DATE_ADD(date, INTERVAL)` | Добавление интервала | `DATE_ADD(order_date, INTERVAL 30 DAY)` |
| `DATEDIFF(date1, date2)` | Разница в днях | `DATEDIFF(order_date, ship_date)` |
| `DATE_FORMAT(date, format)` | Форматирование | `DATE_FORMAT(order_date, '%Y-%m')` |

#### Примеры
```sql
-- Извлечение частей даты
SELECT
    order_id,
    order_date,
    EXTRACT(YEAR FROM order_date) as year,
    EXTRACT(MONTH FROM order_date) as month,
    EXTRACT(DOW FROM order_date) as day_of_week,
    EXTRACT(QUARTER FROM order_date) as quarter
FROM orders;

-- Группировка по месяцам
SELECT
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as orders_count
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Разница в днях
SELECT
    order_id,
    order_date,
    shipped_date,
    shipped_date - order_date as days_to_ship
FROM orders
WHERE shipped_date IS NOT NULL;

-- Возраст сотрудников
SELECT
    first_name,
    last_name,
    birth_date,
    AGE(CURRENT_DATE, birth_date) as age_interval,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) as age_years
FROM employees;

-- Фильтрация по дате
SELECT *
FROM orders
WHERE order_date BETWEEN '1997-01-01' AND '1997-12-31';

-- Добавление интервала
SELECT
    order_date,
    required_date,
    order_date + INTERVAL '7 days' as plus_7_days
FROM orders;
```

---

### 7. CASE выражения

#### Теория
**CASE** — условная логика в SQL (аналог IF-ELSE).

#### Синтаксис
```sql
CASE
    WHEN условие1 THEN результат1
    WHEN условие2 THEN результат2
    ELSE результат_по_умолчанию
END
```

#### Простой vs Поисковый CASE

| Тип | Синтаксис | Когда использовать |
|-----|-----------|-------------------|
| Простой | `CASE column WHEN value1 THEN result1` | Равенство одному столбцу |
| Поисковый | `CASE WHEN условие1 THEN result1` | Сложные условия |

#### Примеры
```sql
-- Классификация по цене
SELECT
    product_name,
    unit_price,
    CASE
        WHEN unit_price < 10 THEN 'Low'
        WHEN unit_price BETWEEN 10 AND 50 THEN 'Medium'
        WHEN unit_price > 50 THEN 'High'
        ELSE 'Unknown'
    END as price_category
FROM products;

-- Создание бакетов (группировка)
SELECT
    CASE
        WHEN EXTRACT(YEAR FROM AGE(birth_date)) < 30 THEN 'Junior'
        WHEN EXTRACT(YEAR FROM AGE(birth_date)) BETWEEN 30 AND 45 THEN 'Middle'
        ELSE 'Senior'
    END as age_group,
    COUNT(*) as employees_count
FROM employees
GROUP BY age_group;

-- Простой CASE
SELECT
    order_id,
    ship_country,
    CASE ship_country
        WHEN 'USA' THEN 'Domestic'
        WHEN 'Canada' THEN 'North America'
        WHEN 'Mexico' THEN 'North America'
        ELSE 'International'
    END as region
FROM orders;

-- PIVOT через CASE (транспонирование)
SELECT
    EXTRACT(YEAR FROM order_date) as year,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 1 THEN freight ELSE 0 END) as jan,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 2 THEN freight ELSE 0 END) as feb,
    SUM(CASE WHEN EXTRACT(MONTH FROM order_date) = 3 THEN freight ELSE 0 END) as mar
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date);

-- CASE в ORDER BY
SELECT
    product_name,
    units_in_stock,
    discontinued
FROM products
ORDER BY
    CASE discontinued
        WHEN 1 THEN 1
        ELSE 0
    END,
    units_in_stock DESC;
```

---

### 8. CTE (Common Table Expressions)

#### Теория
**CTE (WITH)** — временный именованный набор результатов, существующий только в рамках одного запроса.

#### Синтаксис
```sql
WITH cte_name AS (
    SELECT ...
)
SELECT * FROM cte_name;
```

#### Преимущества CTE
| Преимущество | Описание |
|--------------|----------|
| **Читаемость** | Разбивает сложные запросы на логические блоки |
| **Многократное использование** | Можно использовать CTE несколько раз в запросе |
| **Рекурсия** | Поддержка рекурсивных запросов |
| **Альтернатива подзапросам** | Часто понятнее вложенных подзапросов |

#### Примеры
```sql
-- Базовое CTE
WITH high_value_orders AS (
    SELECT
        order_id,
        customer_id,
        SUM(unit_price * quantity * (1 - discount)) as order_total
    FROM orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_id, customer_id
    HAVING SUM(unit_price * quantity * (1 - discount)) > 1000
)
SELECT
    c.company_name,
    COUNT(hvo.order_id) as high_value_orders_count
FROM high_value_orders hvo
INNER JOIN customers c ON hvo.customer_id = c.customer_id
GROUP BY c.company_name
ORDER BY high_value_orders_count DESC;

-- Множественные CTE
WITH
monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) as month,
        SUM(freight) as total_freight
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
monthly_growth AS (
    SELECT
        month,
        total_freight,
        LAG(total_freight) OVER (ORDER BY month) as prev_month_freight
    FROM monthly_sales
)
SELECT
    month,
    total_freight,
    prev_month_freight,
    ROUND((total_freight - prev_month_freight) / prev_month_freight * 100, 2) as growth_pct
FROM monthly_growth
WHERE prev_month_freight IS NOT NULL;

-- Рекурсивное CTE (иерархия сотрудников)
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor: базовый уровень
    SELECT
        employee_id,
        first_name || ' ' || last_name as employee_name,
        reports_to,
        0 as level
    FROM employees
    WHERE reports_to IS NULL

    UNION ALL

    -- Recursive: подчиненные
    SELECT
        e.employee_id,
        e.first_name || ' ' || e.last_name,
        e.reports_to,
        eh.level + 1
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.reports_to = eh.employee_id
)
SELECT
    LPAD(' ', level * 2) || employee_name as indented_name,
    level
FROM employee_hierarchy
ORDER BY level, employee_name;
```

#### CTE vs Подзапрос

| Критерий | CTE | Подзапрос |
|----------|-----|-----------|
| **Читаемость** | Высокая | Снижается при вложенности |
| **Многократное использование** | Да | Нет (только копированием) |
| **Рекурсия** | Да | Нет |
| **Область видимости** | Только в запросе | В родительском запросе |

---

### 9. HAVING vs WHERE

#### Теория
| Ключевое слово | Когда применяется | Что фильтрует |
|----------------|-------------------|---------------|
| `WHERE` | До `GROUP BY` | Отдельные строки |
| `HAVING` | После `GROUP BY` | Группы строк |

#### Порядок выполнения запроса
```
1. FROM / JOIN
2. WHERE          ← фильтрация строк
3. GROUP BY       ← группировка
4. HAVING         ← фильтрация групп
5. SELECT
6. ORDER BY
7. LIMIT
```

### Примеры
```sql
-- WHERE фильтрует до группировки
SELECT
    country,
    COUNT(*) as customers_count
FROM customers
WHERE country IN ('USA', 'Canada', 'UK')  -- фильтруем строки
GROUP BY country
HAVING COUNT(*) > 2;  -- фильтруем группы

-- Ошибка: нельзя использовать агрегацию в WHERE
-- WHERE COUNT(*) > 2  -- ОШИБКА!

-- Практический пример: продукты с ценой > 20,
-- у которых общая выручка > 5000
SELECT
    p.product_name,
    SUM(od.unit_price * od.quantity) as total_revenue
FROM products p
INNER JOIN order_details od ON p.product_id = od.product_id
WHERE p.unit_price > 20  -- фильтруем продукты ДО агрегации
GROUP BY p.product_name
HAVING SUM(od.unit_price * od.quantity) > 5000;  -- фильтруем после агрегации
```

---

### 10. Производительность запросов

#### Теория
Оптимизация SQL запросов критически важна для работы с большими объемами данных.

#### Индексы

**Индекс** — структура данных, ускоряющая поиск строк.

```sql
-- Создание индекса
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);

-- Составной индекс
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Уникальный индекс
CREATE UNIQUE INDEX idx_customers_email ON customers(email);
```

**Правила создания индексов:**
| Поле | Индексировать | Не индексировать |
|------|---------------|------------------|
| `JOIN` | Да | - |
| `WHERE` | Да | - |
| `ORDER BY` | Да | - |
| `GROUP BY` | Да | - |
| Мало уникальных значений | - | Нет (например, boolean) |
| Часто обновляемые | - | Нет (замедляет UPDATE) |

#### Анализ запросов

```sql
-- PostgreSQL: анализ плана выполнения
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 'ALFKI';

-- Включение таймингов
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT * FROM orders WHERE customer_id = 'ALFKI';
```

#### Проблемные паттерны

| Паттерн | Проблема | Решение |
|---------|----------|---------|
| `SELECT *` | Избыточные данные | Указывать только нужные столбцы |
| `LIKE '%text'` | Не использует индекс | Избегать ведущего % |
| `OR` в условиях | Может не использовать индекс | Использовать `UNION` или `IN` |
| `NOT IN` с NULL | Неожиданные результаты | Использовать `NOT EXISTS` |
| Функции в WHERE | Не использует индекс | `WHERE DATE(order_date) = '2023-01-01'` → `WHERE order_date >= ...` |

#### Пример оптимизации

```sql
-- Медленный запрос
SELECT *
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.country = 'USA'
  AND EXTRACT(YEAR FROM o.order_date) = 1997
  AND o.freight > 50;

-- Оптимизированный запрос
SELECT
    o.order_id,
    o.order_date,
    o.freight,
    c.company_name,
    c.contact_name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.country = 'USA'
  AND o.order_date >= '1997-01-01'
  AND o.order_date < '1998-01-01'
  AND o.freight > 50;

-- Создание индексов для оптимизации
CREATE INDEX idx_customers_country ON customers(country);
CREATE INDEX idx_orders_date_freight ON orders(order_date, freight);
```

---

### 11. Нормализация базы данных

#### Теория
**Нормализация** — процесс организации данных для уменьшения избыточности и зависимостей.

#### Нормальные формы

| НФ | Определение | Нарушение | Решение |
|----|-------------|-----------|---------|
| **1NF** | Атомарные значения, уникальные строки | Массив в ячейке | Вынести в отдельную таблицу |
| **2NF** | Нет частичных зависимостей (зависимость от части составного ключа) | `(order_id, product_id) → product_name` | Вынести в отдельную таблицу |
| **3NF** | Нет транзитивных зависимостей (зависимость от неключевого поля) | `product_id → category_id → category_name` | Вынести категории в отдельную таблицу |

#### Пример Northwind (3NF)

```
customers (customer_id PK)
    ↓
orders (order_id PK, customer_id FK)
    ↓
order_details (order_id PK, product_id PK)
    ↓
products (product_id PK, category_id FK, supplier_id FK)
    ↓                    ↓
categories (category_id PK)  suppliers (supplier_id PK)
```

#### Денормализация
Иногда для производительности намеренно нарушают нормализацию:
- Создание витрин данных
- Дублирование часто запрашиваемых полей
- Предварительная агрегация

---

### 12. Типы данных в SQL

#### Основные типы

| Категория | PostgreSQL | MySQL | Описание |
|-----------|------------|-------|----------|
| **Числовые** | `SMALLINT`, `INTEGER`, `BIGINT` | `TINYINT`, `INT`, `BIGINT` | Целые числа |
| | `DECIMAL(p,s)`, `NUMERIC` | `DECIMAL(p,s)`, `NUMERIC` | Точные десятичные |
| | `REAL`, `DOUBLE PRECISION` | `FLOAT`, `DOUBLE` | Приближенные |
| **Строковые** | `CHAR(n)`, `VARCHAR(n)` | `CHAR(n)`, `VARCHAR(n)` | Фиксированная/переменная длина |
| | `TEXT` | `TEXT` | Длинный текст |
| **Дата/Время** | `DATE`, `TIME`, `TIMESTAMP` | `DATE`, `TIME`, `DATETIME` | Дата, время, метка времени |
| | `INTERVAL` | - | Интервалы |
| **Булевы** | `BOOLEAN` | `BOOLEAN`, `TINYINT(1)` | TRUE/FALSE |
| **Бинарные** | `BYTEA` | `BLOB` | Бинарные данные |

#### Выбор типа данных
```sql
-- Правильно
customer_id   VARCHAR(5)    -- Фиксированный формат
unit_price    DECIMAL(10,2) -- Деньги требуют точности
quantity      SMALLINT      -- Не может быть отрицательным
order_date    DATE          -- Только дата, без времени
is_active     BOOLEAN       -- Только два значения

-- Неправильно
customer_id   TEXT          -- Избыточно
unit_price    FLOAT         -- Проблемы с округлением
quantity      VARCHAR(10)   -- Нельзя суммировать
order_date    TIMESTAMP     -- Избыточная точность
is_active     VARCHAR(3)    -- Допускает 'yes', 'no', 'Y'...
```

---

### 13. Транзакции и ACID

#### Теория
**Транзакция** — последовательность операций, выполняемая как единое целое.

### ACID

| Свойство | Описание | Пример |
|----------|----------|--------|
| **Atomicity** (Атомарность) | Все операции выполняются или ни одна | Перевод денег: списание + зачисление |
| **Consistency** (Согласованность) | Данные остаются корректными | После перевода сумма не изменилась |
| **Isolation** (Изоляция) | Параллельные транзакции не влияют друг на друга | Два перевода не пересекаются |
| **Durability** (Долговечность) | Изменения сохраняются при сбое | После подтверждения данные не теряются |

#### Уровни изоляции

| Уровень | Dirty Read | Non-repeatable Read | Phantom Read |
|---------|------------|---------------------|--------------|
| READ UNCOMMITTED | ✅ | ✅ | ✅ |
| READ COMMITTED | ❌ | ✅ | ✅ |
| REPEATABLE READ | ❌ | ❌ | ✅ |
| SERIALIZABLE | ❌ | ❌ | ❌ |

#### Пример транзакции
```sql
BEGIN;

-- Создание заказа
INSERT INTO orders (customer_id, order_date, freight)
VALUES ('ALFKI', CURRENT_DATE, 20.00)
RETURNING order_id;

-- Добавление товаров в заказ
INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount)
VALUES (100, 1, 18.00, 2, 0);

-- Обновление остатков
UPDATE products
SET units_in_stock = units_in_stock - 2
WHERE product_id = 1;

-- Проверка
SELECT * FROM products WHERE product_id = 1;

COMMIT;  -- или ROLLBACK при ошибке
```

---

### 14. Управление доступом

#### Теория
Управление доступом определяет, кто может выполнять какие операции.

#### Основные привилегии

| Привилегия | Описание |
|------------|----------|
| `SELECT` | Чтение данных |
| `INSERT` | Добавление данных |
| `UPDATE` | Обновление данных |
| `DELETE` | Удаление данных |
| `CREATE` | Создание объектов |
| `DROP` | Удаление объектов |
| `ALTER` | Изменение структуры |
| `EXECUTE` | Выполнение функций |

#### Примеры
```sql
-- Создание пользователя
CREATE USER analyst WITH PASSWORD 'secure_password';

-- Предоставление прав на чтение
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

-- Предоставление прав на конкретные таблицы
GRANT SELECT, INSERT, UPDATE ON orders, order_details TO analyst;

-- Запрет на удаление
REVOKE DELETE ON orders FROM analyst;

-- Роли
CREATE ROLE data_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO data_analyst;
GRANT data_analyst TO analyst;
```

---

### 15. Распространенные ошибки на собеседовании

| Ошибка | Правильно |
|--------|----------|
| Использование `=` с NULL | `IS NULL` |
| Агрегация без GROUP BY | `SELECT category_id, COUNT(*) ... GROUP BY category_id` |
| Фильтрация агрегатов в WHERE | Использовать `HAVING` |
| Сравнение разных типов | `WHERE order_id = '123'` (int vs varchar) |
| `IN (SELECT ...)` с NULL | `NOT EXISTS` безопаснее |
| Пропуск `DISTINCT` | `COUNT(DISTINCT customer_id)` |

---

### Шпаргалка для собеседования

#### Топ-10 запросов для практики

1. **Средний чек по клиентам**
2. **Топ-10 продуктов по выручке**
3. **Динамика продаж по месяцам**
4. **RFM-анализ клиентов**
5. **Когортный анализ удержания**
6. **Скользящее среднее**
7. **Сравнение с предыдущим периодом (LAG)**
8. **Ранжирование внутри групп**
9. **Процент от общего**
10. **Иерархия сотрудников (рекурсивный CTE)**

#### Ключевые концепции
- `INNER JOIN` vs `LEFT JOIN`
- `WHERE` vs `HAVING`
- `RANK()` vs `DENSE_RANK()` vs `ROW_NUMBER()`
- `UNION` vs `UNION ALL`
- `EXISTS` vs `IN`
- CTE vs подзапрос
- Индексы и их влияние

---

Эта теория покрывает все необходимые темы для успешного прохождения собеседования на позицию Data Analyst. Удачи! 🚀
