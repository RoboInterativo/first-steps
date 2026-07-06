

## БЛОК ТЕОРИИ + ПРИМЕРЫ ЗАПРОСОВ (Northwind)

---

### ТЕМА 1. БАЗОВЫЙ СИНТАКСИС

#### 1.1 SELECT, WHERE, ORDER BY

**Синтаксис:**
```sql
SELECT колонки
FROM таблица
WHERE условие
ORDER BY колонка ASC/DESC;
```

**Пример 1.1.1 — Выборка с фильтром:**
```sql
-- Вывести заказы за 1997 год
SELECT 
    order_id,
    order_date,
    customer_id
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 1997
ORDER BY order_date DESC;
```

**Пример 1.1.2 — Фильтрация текста и чисел:**
```sql
-- Найти клиентов из Германии с контактным лицом, начинающимся на 'A'
SELECT 
    company_name,
    contact_name,
    country
FROM customers
WHERE country = 'Germany' 
  AND contact_name LIKE 'A%';
```

**Пример 1.1.3 — Использование BETWEEN и IN:**
```sql
-- Товары с ценой от 20 до 50, исключая категории 1 и 2
SELECT 
    product_name,
    unit_price,
    category_id
FROM products
WHERE unit_price BETWEEN 20 AND 50
  AND category_id NOT IN (1, 2);
```

---

#### 1.2 JOIN (INNER, LEFT, RIGHT, FULL)

**Синтаксис:**
```sql
SELECT колонки
FROM таблица_A
[INNER | LEFT | RIGHT | FULL] JOIN таблица_B
    ON таблица_A.ключ = таблица_B.ключ;
```

| Тип JOIN | Что делает |
| :--- | :--- |
| **INNER JOIN** | Только совпадающие записи в обеих таблицах |
| **LEFT JOIN** | Все записи из левой таблицы + совпадающие из правой (NULL, если нет) |
| **RIGHT JOIN** | Все записи из правой таблицы + совпадающие из левой (NULL, если нет) |
| **FULL JOIN** | Все записи из обеих таблиц (NULL, если нет совпадений) |

**Пример 1.2.1 — INNER JOIN (только клиенты с заказами):**
```sql
-- Вывести клиентов и даты их заказов
SELECT 
    c.company_name,
    o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;
```

**Пример 1.2.2 — LEFT JOIN (все клиенты, даже без заказов):**
```sql
-- Все клиенты и количество их заказов
SELECT 
    c.company_name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.company_name
ORDER BY order_count DESC;
```

**Пример 1.2.3 — Тройной JOIN:**
```sql
-- Клиенты → Заказы → Товары (полная информация о продажах)
SELECT 
    c.company_name,
    o.order_date,
    p.product_name,
    od.quantity,
    od.unit_price
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE o.order_date >= '1997-01-01'
ORDER BY o.order_date DESC;
```

---

#### 1.3 GROUP BY, HAVING, агрегатные функции

**Основные агрегатные функции:**
- `COUNT()` — количество строк
- `SUM()` — сумма
- `AVG()` — среднее
- `MIN()` / `MAX()` — минимум/максимум

**Синтаксис:**
```sql
SELECT 
    колонка_для_группировки,
    АГРЕГАТНАЯ_ФУНКЦИЯ(колонка) AS псевдоним
FROM таблица
WHERE условие
GROUP BY колонка_для_группировки
HAVING условие_на_агрегат;
```

**Пример 1.3.1 — Базовая группировка:**
```sql
-- Количество заказов по странам доставки
SELECT 
    ship_country,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY ship_country
ORDER BY order_count DESC;
```

**Пример 1.3.2 — Группировка с несколькими колонками:**
```sql
-- Продажи по категориям и годам
SELECT 
    c.category_name,
    EXTRACT(YEAR FROM o.order_date) AS year,
    SUM(od.quantity * od.unit_price) AS total_sales
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
GROUP BY c.category_name, EXTRACT(YEAR FROM o.order_date)
ORDER BY c.category_name, year;
```

**Пример 1.3.3 — HAVING (фильтр по агрегатам):**
```sql
-- Только страны с количеством заказов > 50
SELECT 
    ship_country,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY ship_country
HAVING COUNT(order_id) > 50
ORDER BY order_count DESC;
```

**Важно:** `WHERE` фильтрует строки ДО группировки, `HAVING` — ПОСЛЕ группировки.

---

### ТЕМА 2. ПОДЗАПРОСЫ

**Подзапрос** — это запрос внутри другого запроса. Бывает:
- **Скалярный** — возвращает одно значение
- **Строчный** — возвращает одну строку
- **Табличный** — возвращает таблицу
- **Коррелирующий** — ссылается на внешний запрос

---

#### 2.1 Подзапрос в WHERE (сравнение с одним значением)

**Пример 2.1.1 — Найти товары дороже средней цены:**
```sql
SELECT 
    product_name,
    unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products);
```

**Пример 2.1.2 — Использование ANY/SOME:**
```sql
-- Товары, цена которых больше хотя бы одного товара из категории 1
SELECT 
    product_name,
    unit_price
FROM products
WHERE unit_price > ANY (SELECT unit_price FROM products WHERE category_id = 1);
```

**Пример 2.1.3 — Использование ALL:**
```sql
-- Товары, цена которых больше всех товаров из категории 1
SELECT 
    product_name,
    unit_price
FROM products
WHERE unit_price > ALL (SELECT unit_price FROM products WHERE category_id = 1);
```

---

#### 2.2 Подзапрос в WHERE (проверка наличия — EXISTS/NOT EXISTS)

**Пример 2.2.1 — Клиенты, у которых были заказы:**
```sql
SELECT 
    company_name
FROM customers c
WHERE EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);
```

**Пример 2.2.2 — Товары, которые никогда не заказывали:**
```sql
SELECT 
    product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM order_details od 
    WHERE od.product_id = p.product_id
);
```

**Почему EXISTS лучше, чем IN?**
- `EXISTS` останавливается на первом совпадении (быстрее)
- `IN` собирает все значения в подзапросе (медленнее на больших данных)

---

#### 2.3 Коррелирующие подзапросы

**Коррелирующий подзапрос** ссылается на колонку из внешнего запроса.

**Пример 2.3.1 — Товары дороже средней цены в своей категории:**
```sql
SELECT 
    product_name,
    unit_price,
    category_id
FROM products p
WHERE unit_price > (
    SELECT AVG(unit_price) 
    FROM products 
    WHERE category_id = p.category_id  -- Ссылка на внешнюю таблицу!
);
```

**Пример 2.3.2 — Клиенты с суммой заказов выше средней:**
```sql
SELECT 
    c.company_name,
    (SELECT SUM(od.quantity * od.unit_price) 
     FROM orders o 
     JOIN order_details od ON o.order_id = od.order_id
     WHERE o.customer_id = c.customer_id) AS total_spent
FROM customers c
WHERE (SELECT SUM(od.quantity * od.unit_price) 
       FROM orders o 
       JOIN order_details od ON o.order_id = od.order_id
       WHERE o.customer_id = c.customer_id) > 5000;
```

---

#### 2.4 Подзапрос в FROM (табличный подзапрос)

**Пример 2.4.1 — Использование подзапроса как таблицы:**
```sql
-- Средний чек по каждой стране
SELECT 
    country,
    AVG(order_total) AS avg_order_total
FROM (
    SELECT 
        c.country,
        o.order_id,
        SUM(od.quantity * od.unit_price * (1 - od.discount)) AS order_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.country, o.order_id
) AS order_totals
GROUP BY country
ORDER BY avg_order_total DESC;
```

---

### ТЕМА 3. CTE (WITH ... AS)

**CTE (Common Table Expression)** — это временная таблица, которая существует только в рамках одного запроса.

**Синтаксис:**
```sql
WITH имя_cte AS (
    -- Ваш запрос
)
SELECT * FROM имя_cte;
```

**Преимущества CTE:**
1. Делает запрос читаемым
2. Можно использовать несколько CTE в одном запросе
3. CTE может ссылаться на другие CTE
4. Рекурсивные CTE (для иерархий)

---

#### 3.1 Базовая CTE

**Пример 3.1.1 — Простая CTE:**
```sql
-- Топ-10 самых дорогих товаров
WITH expensive_products AS (
    SELECT 
        product_name,
        unit_price
    FROM products
    WHERE unit_price > 50
    ORDER BY unit_price DESC
    LIMIT 10
)
SELECT * FROM expensive_products;
```

**Пример 3.1.2 — Несколько CTE:**
```sql
WITH 
customer_sales AS (
    SELECT 
        c.customer_id,
        c.company_name,
        SUM(od.quantity * od.unit_price * (1 - od.discount)) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, c.company_name
),
average_sales AS (
    SELECT AVG(total_spent) AS avg_spent FROM customer_sales
)
SELECT 
    cs.company_name,
    cs.total_spent,
    ROUND(cs.total_spent / av.avg_spent, 2) AS ratio_to_avg
FROM customer_sales cs
CROSS JOIN average_sales av
WHERE cs.total_spent > av.avg_spent
ORDER BY cs.total_spent DESC;
```

---

#### 3.2 Рекурсивная CTE (для иерархий)

**Пример 3.2.1 — Иерархия сотрудников (кто кому подчиняется):**
```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Базовый случай: топ-менеджеры
    SELECT 
        employee_id,
        first_name,
        last_name,
        reports_to,
        0 AS level
    FROM employees
    WHERE reports_to IS NULL
    
    UNION ALL
    
    -- Рекурсивный случай: подчиненные
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.reports_to,
        eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.reports_to = eh.employee_id
)
SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    level
FROM employee_hierarchy
ORDER BY level, employee_name;
```

---

### ТЕМА 4. ОКОННЫЕ ФУНКЦИИ

**Оконные функции** выполняют вычисления по набору строк, связанных с текущей строкой, но **не сворачивают результат** в одну группу.

**Синтаксис:**
```sql
ФУНКЦИЯ() OVER (
    [PARTITION BY колонка]   -- Группировка
    [ORDER BY колонка]       -- Сортировка внутри окна
    [ROWS/RANGE BETWEEN ...] -- Рамка окна
)
```

---

#### 4.1 ROW_NUMBER(), RANK(), DENSE_RANK()

| Функция | Описание |
| :--- | :--- |
| `ROW_NUMBER()` | Уникальный номер каждой строки внутри окна (1,2,3,4...) |
| `RANK()` | Ранг с пропусками при одинаковых значениях (1,2,2,4) |
| `DENSE_RANK()` | Ранг без пропусков (1,2,2,3) |

**Пример 4.1.1 — Нумерация заказов клиента:**
```sql
SELECT 
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_number
FROM orders
ORDER BY customer_id, order_date;
```

**Пример 4.1.2 — Разница между RANK и DENSE_RANK:**
```sql
-- Ранжирование товаров по цене
SELECT 
    product_name,
    unit_price,
    RANK() OVER (ORDER BY unit_price DESC) AS rank_rank,
    DENSE_RANK() OVER (ORDER BY unit_price DESC) AS dense_rank
FROM products
WHERE category_id = 1
ORDER BY unit_price DESC;
```

---

#### 4.2 LAG(), LEAD() — Соседние строки

| Функция | Описание |
| :--- | :--- |
| `LAG(колонка, смещение)` | Значение из предыдущей строки |
| `LEAD(колонка, смещение)` | Значение из следующей строки |

**Пример 4.2.1 — Разница между соседними заказами:**
```sql
SELECT 
    customer_id,
    order_id,
    order_date,
    LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
    order_date - LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_between
FROM orders
ORDER BY customer_id, order_date;
```

**Пример 4.2.2 — Сравнение с предыдущим товаром (по алфавиту):**
```sql
SELECT 
    product_name,
    unit_price,
    LAG(unit_price, 1) OVER (ORDER BY product_name) AS prev_price,
    unit_price - LAG(unit_price, 1) OVER (ORDER BY product_name) AS price_diff
FROM products
ORDER BY product_name;
```

---

#### 4.3 SUM() OVER() — Кумулятивные суммы

**Пример 4.3.1 — Накопительный итог по датам:**
```sql
SELECT 
    o.order_date,
    o.order_id,
    SUM(od.quantity * od.unit_price * (1 - od.discount)) 
        OVER (ORDER BY o.order_date) AS cumulative_total
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
ORDER BY o.order_date;
```

**Пример 4.3.2 — Скользящее среднее за 3 дня:**
```sql
SELECT 
    order_date,
    daily_total,
    AVG(daily_total) OVER (ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3days
FROM (
    SELECT 
        order_date,
        SUM(od.quantity * od.unit_price) AS daily_total
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date
) AS daily_sales
ORDER BY order_date;
```

---

#### 4.4 FIRST_VALUE(), LAST_VALUE() — Крайние значения

**Пример 4.4.1 — Самая дешевая цена в категории:**
```sql
SELECT 
    product_name,
    category_id,
    unit_price,
    FIRST_VALUE(product_name) OVER (PARTITION BY category_id ORDER BY unit_price) AS cheapest_product,
    FIRST_VALUE(unit_price) OVER (PARTITION BY category_id ORDER BY unit_price) AS cheapest_price
FROM products
ORDER BY category_id, unit_price;
```

**Пример 4.4.2 — Разница между текущей ценой и минимальной в категории:**
```sql
SELECT 
    product_name,
    category_id,
    unit_price,
    MIN(unit_price) OVER (PARTITION BY category_id) AS min_in_category,
    unit_price - MIN(unit_price) OVER (PARTITION BY category_id) AS diff_from_min
FROM products
ORDER BY category_id, unit_price;
```

---

### ТЕМА 5. РАБОТА С ДАТАМИ (PostgreSQL)

#### 5.1 Извлечение частей даты

**Функция EXTRACT:**
```sql
SELECT 
    order_date,
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(DAY FROM order_date) AS day,
    EXTRACT(DOW FROM order_date) AS day_of_week,  -- 0=Воскресенье
    EXTRACT(DOY FROM order_date) AS day_of_year  -- День в году (1-366)
FROM orders
LIMIT 10;
```

**Пример 5.1.1 — Продажи по месяцам:**
```sql
SELECT 
    DATE_TRUNC('month', order_date) AS month_start,
    SUM(od.quantity * od.unit_price) AS total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month_start;
```

---

#### 5.2 Арифметика с датами

**Операции с датами:**
```sql
SELECT 
    order_date,
    shipped_date,
    shipped_date - order_date AS delivery_days,      -- Разница в днях
    order_date + INTERVAL '30 days' AS plus_month,  -- Добавить дни
    order_date - INTERVAL '1 year' AS minus_year    -- Вычесть год
FROM orders
WHERE shipped_date IS NOT NULL
LIMIT 10;
```

**Пример 5.2.1 — Задержки доставки:**
```sql
SELECT 
    order_id,
    order_date,
    required_date,
    shipped_date,
    (shipped_date - required_date) AS delay_days,
    CASE 
        WHEN shipped_date > required_date THEN 'Задержка'
        WHEN shipped_date = required_date THEN 'В срок'
        ELSE 'Раньше срока'
    END AS delivery_status
FROM orders
WHERE shipped_date IS NOT NULL
ORDER BY delay_days DESC;
```

---

#### 5.3 Фильтрация по датам

**Пример 5.3.1 — Заказы за последние 30 дней:**
```sql
SELECT *
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days';
```

**Пример 5.3.2 — Заказы за 1997 год (оптимально с индексом):**
```sql
SELECT *
FROM orders
WHERE order_date BETWEEN '1997-01-01' AND '1997-12-31';
```

**Пример 5.3.3 — Дни рождения сотрудников:**
```sql
SELECT 
    first_name,
    last_name,
    birth_date,
    EXTRACT(MONTH FROM birth_date) AS birth_month,
    EXTRACT(DAY FROM birth_date) AS birth_day
FROM employees
WHERE EXTRACT(MONTH FROM birth_date) = EXTRACT(MONTH FROM CURRENT_DATE)
ORDER BY birth_date;
```

---

### ТЕМА 6. ОПТИМИЗАЦИЯ И ТИПЫ ДАННЫХ

---

#### 6.1 Типы данных в PostgreSQL

| Тип | Когда использовать |
| :--- | :--- |
| **INTEGER / BIGINT** | Для ID, счетчиков, количеств |
| **DECIMAL(p, s)** | Для денег, точных величин (p — точность, s — масштаб) |
| **REAL / FLOAT** | Для научных расчетов (допустимы погрешности) |
| **VARCHAR(n)** | Для строк с ограничением длины |
| **TEXT** | Для длинных текстов без ограничения |
| **DATE** | Только дата (без времени) |
| **TIMESTAMP** | Дата + время |
| **BOOLEAN** | Логические значения (TRUE/FALSE) |

**Пример 6.1.1 — Создание таблицы с правильными типами:**
```sql
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    customer_id VARCHAR(5) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity INTEGER CHECK (quantity > 0),
    unit_price REAL CHECK (unit_price > 0),
    discount REAL DEFAULT 0.00
);
```

**Почему DECIMAL, а не FLOAT?**
```sql
-- Ошибка округления в FLOAT:
SELECT 0.1::FLOAT + 0.2::FLOAT = 0.3::FLOAT;  -- false!

-- DECIMAL дает точный результат:
SELECT 0.1::DECIMAL(10,2) + 0.2::DECIMAL(10,2) = 0.3::DECIMAL(10,2);  -- true
```

---

#### 6.2 Индексы (Зачем и когда)

**Индекс** — это структура данных, которая ускоряет поиск.

| Тип индекса | Когда использовать |
| :--- | :--- |
| **B-tree (по умолчанию)** | Для обычных сравнений (=, <, >, BETWEEN, LIKE 'abc%') |
| **Hash** | Только для точного сравнения (=) |
| **GIN** | Для полнотекстового поиска, массивов, JSON |
| **GiST** | Для геоданных |

**Пример 6.2.1 — Создание индекса:**
```sql
-- Обычный индекс на колонку
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Составной индекс (порядок важен!)
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Уникальный индекс
CREATE UNIQUE INDEX idx_unique_product_name ON products(product_name);
```

**Пример 6.2.2 — Когда индекс НЕ поможет:**
```sql
-- !!! Индекс по customer_id не поможет
SELECT * FROM orders WHERE UPPER(customer_id) = 'ALFKI';

-- !!! Индекс по order_date не поможет
SELECT * FROM orders WHERE EXTRACT(YEAR FROM order_date) = 1997;

-- !!! Индекс по product_name не поможет
SELECT * FROM products WHERE product_name LIKE '%Apple%';
```

---

#### 6.3 EXPLAIN — Анализ запросов

**Синтаксис:**
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) 
SELECT * FROM orders WHERE customer_id = 'ALFKI';
```

**Как читать EXPLAIN:**
```
Seq Scan on orders  (cost=0.00..142.00 rows=6 width=80)
                    (actual time=0.023..1.234 rows=6 loops=1)
  Filter: ((customer_id)::text = 'ALFKI'::text)
  Rows Removed by Filter: 829
Planning Time: 0.124 ms
Execution Time: 1.456 ms
```

**Что означают цифры:**
- **cost=0.00..142.00** — оценка стоимости (первая строка..все строки)
- **rows=6** — примерное количество строк
- **actual time=0.023..1.234** — реальное время выполнения (мс)
- **Seq Scan** — полный просмотр таблицы (плохо на больших таблицах)
- **Index Scan** — поиск по индексу (хорошо)
- **Bitmap Heap Scan** — комбинированный поиск (тоже хорошо)

**Пример 6.3.1 — Оптимизация медленного запроса:**

**Медленный запрос:**
```sql
SELECT * FROM orders 
WHERE customer_id = 'ALFKI' AND order_date BETWEEN '1997-01-01' AND '1997-12-31';
```
План: `Seq Scan` на 10000 строк.

**Создаем индекс:**
```sql
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
```

**Теперь план:** `Index Scan using idx_orders_customer_date` — скорость выросла в 100 раз.

---

### ТЕМА 7. РЕГУЛЯРНЫЕ ВЫРАЖЕНИЯ В SQL

**В PostgreSQL есть поддержка регулярных выражений через `~`:**

| Оператор | Описание |
| :--- | :--- |
| `~` | Строка соответствует regex |
| `~*` | Строка соответствует regex (без учета регистра) |
| `!~` | Строка НЕ соответствует regex |
| `!~*` | Строка НЕ соответствует regex (без учета регистра) |

**Пример 7.1 — Поиск email-адресов:**
```sql
SELECT 
    contact_name,
    contact_title
FROM customers
WHERE contact_title ~ '^[A-Za-z]+ [A-Za-z]+$';
```

**Пример 7.2 — Очистка номеров телефонов:**
```sql
SELECT 
    phone,
    REGEXP_REPLACE(phone, '[^0-9+]', '', 'g') AS clean_phone
FROM customers
LIMIT 10;
```

**Пример 7.3 — Извлечение домена из email (если бы он был в таблице):**
```sql
SELECT 
    email,
    SUBSTRING(email FROM '@([^@]+)$') AS domain
FROM customers;
```

---

### ШПАРГАЛКА ПО ОКОННЫМ ФУНКЦИЯМ (Сводная таблица)

| Функция | Описание | Пример |
| :--- | :--- | :--- |
| `ROW_NUMBER()` | Номер строки в группе | `ROW_NUMBER() OVER (PARTITION BY cat ORDER BY price)` |
| `RANK()` | Ранг с пропусками | `RANK() OVER (ORDER BY sales DESC)` |
| `DENSE_RANK()` | Ранг без пропусков | `DENSE_RANK() OVER (ORDER BY sales DESC)` |
| `LAG(кол, n)` | Значение из предыдущей строки | `LAG(price, 1) OVER (ORDER BY date)` |
| `LEAD(кол, n)` | Значение из следующей строки | `LEAD(price, 1) OVER (ORDER BY date)` |
| `FIRST_VALUE(кол)` | Первое значение в окне | `FIRST_VALUE(name) OVER (PARTITION BY cat ORDER BY price)` |
| `LAST_VALUE(кол)` | Последнее значение в окне | `LAST_VALUE(name) OVER (PARTITION BY cat ORDER BY price)` |
| `SUM(кол) OVER()` | Накопительная сумма | `SUM(amount) OVER (ORDER BY date)` |
| `AVG(кол) OVER()` | Скользящее среднее | `AVG(amount) OVER (ORDER BY date ROWS 3 PRECEDING)` |
| `COUNT(*) OVER()` | Общее количество в окне | `COUNT(*) OVER (PARTITION BY cat)` |

---

### ИТОГОВЫЙ ТЕСТ ДЛЯ САМОПРОВЕРКИ

Попросите студента написать один большой запрос, который включает ВСЕ изученные темы:

**Задание:** Напишите запрос, который выводит:
1. Для каждого сотрудника — общую сумму продаж и средний чек
2. Ранг сотрудника по сумме продаж (используя DENSE_RANK)
3. Разницу между суммой продаж сотрудника и предыдущим сотрудником в рейтинге (LAG)
4. Только сотрудников, у которых сумма продаж выше средней по всем сотрудникам
5. За 1997 год
6. Отсортировать по убыванию суммы продаж

**Решение:**
```sql
WITH employee_sales AS (
    SELECT 
        e.employee_id,
        e.first_name || ' ' || e.last_name AS employee_name,
        SUM(od.quantity * od.unit_price * (1 - od.discount)) AS total_sales,
        AVG(od.quantity * od.unit_price * (1 - od.discount)) AS avg_check
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_details od ON o.order_id = od.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 1997
    GROUP BY e.employee_id, e.first_name, e.last_name
),
global_avg AS (
    SELECT AVG(total_sales) AS avg_all FROM employee_sales
),
ranked AS (
    SELECT 
        es.*,
        DENSE_RANK() OVER (ORDER BY es.total_sales DESC) AS sales_rank,
        LAG(es.total_sales, 1) OVER (ORDER BY es.total_sales DESC) AS prev_sales
    FROM employee_sales es
)
SELECT 
    r.employee_name,
    ROUND(r.total_sales, 2) AS total_sales,
    ROUND(r.avg_check, 2) AS avg_check,
    r.sales_rank,
    ROUND(r.total_sales - r.prev_sales, 2) AS diff_from_previous,
    ROUND((r.total_sales - ga.avg_all) / ga.avg_all * 100, 2) AS percent_above_avg
FROM ranked r
CROSS JOIN global_avg ga
WHERE r.total_sales > ga.avg_all
ORDER BY r.total_sales DESC;
```

