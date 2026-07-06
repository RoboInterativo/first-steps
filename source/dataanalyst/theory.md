

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
-- Вывести заказы за 1997 год с суммой > 1000
SELECT 
    OrderID,
    OrderDate,
    CustomerID
FROM Orders
WHERE EXTRACT(YEAR FROM OrderDate) = 1997
ORDER BY OrderDate DESC;
```

**Пример 1.1.2 — Фильтрация текста и чисел:**
```sql
-- Найти клиентов из Германии с контактным лицом, начинающимся на 'A'
SELECT 
    CompanyName,
    ContactName,
    Country
FROM Customers
WHERE Country = 'Germany' 
  AND ContactName LIKE 'A%';
```

**Пример 1.1.3 — Использование BETWEEN и IN:**
```sql
-- Товары с ценой от 20 до 50, исключая категории 1 и 2
SELECT 
    ProductName,
    UnitPrice,
    CategoryID
FROM Products
WHERE UnitPrice BETWEEN 20 AND 50
  AND CategoryID NOT IN (1, 2);
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
    c.CompanyName,
    o.OrderDate
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER BY o.OrderDate DESC;
```

**Пример 1.2.2 — LEFT JOIN (все клиенты, даже без заказов):**
```sql
-- Все клиенты и количество их заказов
SELECT 
    c.CompanyName,
    COUNT(o.OrderID) AS OrderCount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName
ORDER BY OrderCount DESC;
```

**Пример 1.2.3 — Тройной JOIN:**
```sql
-- Клиенты → Заказы → Товары (полная информация о продажах)
SELECT 
    c.CompanyName,
    o.OrderDate,
    p.ProductName,
    od.Quantity,
    od.UnitPrice
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN "Order Details" od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE o.OrderDate >= '1997-01-01'
ORDER BY o.OrderDate DESC;
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
    ShipCountry,
    COUNT(OrderID) AS OrderCount
FROM Orders
GROUP BY ShipCountry
ORDER BY OrderCount DESC;
```

**Пример 1.3.2 — Группировка с несколькими колонками:**
```sql
-- Продажи по категориям и годам
SELECT 
    c.CategoryName,
    EXTRACT(YEAR FROM o.OrderDate) AS Year,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN "Order Details" od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY c.CategoryName, EXTRACT(YEAR FROM o.OrderDate)
ORDER BY c.CategoryName, Year;
```

**Пример 1.3.3 — HAVING (фильтр по агрегатам):**
```sql
-- Только страны с количеством заказов > 50
SELECT 
    ShipCountry,
    COUNT(OrderID) AS OrderCount
FROM Orders
GROUP BY ShipCountry
HAVING COUNT(OrderID) > 50
ORDER BY OrderCount DESC;
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
    ProductName,
    UnitPrice
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products);
```

**Пример 2.1.2 — Использование ANY/SOME:**
```sql
-- Товары, цена которых больше хотя бы одного товара из категории 1
SELECT 
    ProductName,
    UnitPrice
FROM Products
WHERE UnitPrice > ANY (SELECT UnitPrice FROM Products WHERE CategoryID = 1);
```

**Пример 2.1.3 — Использование ALL:**
```sql
-- Товары, цена которых больше всех товаров из категории 1
SELECT 
    ProductName,
    UnitPrice
FROM Products
WHERE UnitPrice > ALL (SELECT UnitPrice FROM Products WHERE CategoryID = 1);
```

---

#### 2.2 Подзапрос в WHERE (проверка наличия — EXISTS/NOT EXISTS)

**Пример 2.2.1 — Клиенты, у которых были заказы:**
```sql
SELECT 
    CompanyName
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID
);
```

**Пример 2.2.2 — Товары, которые никогда не заказывали:**
```sql
SELECT 
    ProductName
FROM Products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM "Order Details" od 
    WHERE od.ProductID = p.ProductID
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
    ProductName,
    UnitPrice,
    CategoryID
FROM Products p
WHERE UnitPrice > (
    SELECT AVG(UnitPrice) 
    FROM Products 
    WHERE CategoryID = p.CategoryID  -- Ссылка на внешнюю таблицу!
);
```

**Пример 2.3.2 — Клиенты с суммой заказов выше средней:**
```sql
SELECT 
    c.CompanyName,
    (SELECT SUM(od.Quantity * od.UnitPrice) 
     FROM Orders o 
     JOIN "Order Details" od ON o.OrderID = od.OrderID
     WHERE o.CustomerID = c.CustomerID) AS TotalSpent
FROM Customers c
WHERE (SELECT SUM(od.Quantity * od.UnitPrice) 
       FROM Orders o 
       JOIN "Order Details" od ON o.OrderID = od.OrderID
       WHERE o.CustomerID = c.CustomerID) > 5000;
```

---

#### 2.4 Подзапрос в FROM (табличный подзапрос)

**Пример 2.4.1 — Использование подзапроса как таблицы:**
```sql
-- Средний чек по каждой стране
SELECT 
    Country,
    AVG(OrderTotal) AS AvgOrderTotal
FROM (
    SELECT 
        c.Country,
        o.OrderID,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS OrderTotal
    FROM Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN "Order Details" od ON o.OrderID = od.OrderID
    GROUP BY c.Country, o.OrderID
) AS OrderTotals
GROUP BY Country
ORDER BY AvgOrderTotal DESC;
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
WITH ExpensiveProducts AS (
    SELECT 
        ProductName,
        UnitPrice
    FROM Products
    WHERE UnitPrice > 50
    ORDER BY UnitPrice DESC
    LIMIT 10
)
SELECT * FROM ExpensiveProducts;
```

**Пример 3.1.2 — Несколько CTE:**
```sql
WITH 
CustomerSales AS (
    SELECT 
        c.CustomerID,
        c.CompanyName,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSpent
    FROM Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN "Order Details" od ON o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CompanyName
),
AverageSales AS (
    SELECT AVG(TotalSpent) AS AvgSpent FROM CustomerSales
)
SELECT 
    cs.CompanyName,
    cs.TotalSpent,
    ROUND(cs.TotalSpent / av.AvgSpent, 2) AS RatioToAvg
FROM CustomerSales cs
CROSS JOIN AverageSales av
WHERE cs.TotalSpent > av.AvgSpent
ORDER BY cs.TotalSpent DESC;
```

---

#### 3.2 Рекурсивная CTE (для иерархий)

**Пример 3.2.1 — Иерархия сотрудников (кто кому подчиняется):**
```sql
WITH RECURSIVE EmployeeHierarchy AS (
    -- Базовый случай: топ-менеджеры
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        ReportsTo,
        0 AS Level
    FROM Employees
    WHERE ReportsTo IS NULL
    
    UNION ALL
    
    -- Рекурсивный случай: подчиненные
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.ReportsTo,
        eh.Level + 1
    FROM Employees e
    JOIN EmployeeHierarchy eh ON e.ReportsTo = eh.EmployeeID
)
SELECT 
    EmployeeID,
    FirstName || ' ' || LastName AS EmployeeName,
    Level
FROM EmployeeHierarchy
ORDER BY Level, EmployeeName;
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
    CustomerID,
    OrderID,
    OrderDate,
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS OrderNumber
FROM Orders
ORDER BY CustomerID, OrderDate;
```

**Пример 4.1.2 — Разница между RANK и DENSE_RANK:**
```sql
-- Ранжирование товаров по цене
SELECT 
    ProductName,
    UnitPrice,
    RANK() OVER (ORDER BY UnitPrice DESC) AS RankRank,
    DENSE_RANK() OVER (ORDER BY UnitPrice DESC) AS DenseRank
FROM Products
WHERE CategoryID = 1
ORDER BY UnitPrice DESC;
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
    CustomerID,
    OrderID,
    OrderDate,
    LAG(OrderDate, 1) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PrevOrderDate,
    OrderDate - LAG(OrderDate, 1) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS DaysBetween
FROM Orders
ORDER BY CustomerID, OrderDate;
```

**Пример 4.2.2 — Сравнение с предыдущим товаром (по алфавиту):**
```sql
SELECT 
    ProductName,
    UnitPrice,
    LAG(UnitPrice, 1) OVER (ORDER BY ProductName) AS PrevPrice,
    UnitPrice - LAG(UnitPrice, 1) OVER (ORDER BY ProductName) AS PriceDiff
FROM Products
ORDER BY ProductName;
```

---

#### 4.3 SUM() OVER() — Кумулятивные суммы

**Пример 4.3.1 — Накопительный итог по датам:**
```sql
SELECT 
    OrderDate,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) 
        OVER (ORDER BY o.OrderDate) AS CumulativeTotal
FROM Orders o
JOIN "Order Details" od ON o.OrderID = od.OrderID
ORDER BY o.OrderDate;
```

**Пример 4.3.2 — Скользящее среднее за 3 дня:**
```sql
SELECT 
    OrderDate,
    DailyTotal,
    AVG(DailyTotal) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg3Days
FROM (
    SELECT 
        OrderDate,
        SUM(od.Quantity * od.UnitPrice) AS DailyTotal
    FROM Orders o
    JOIN "Order Details" od ON o.OrderID = od.OrderID
    GROUP BY OrderDate
) AS DailySales
ORDER BY OrderDate;
```

---

#### 4.4 FIRST_VALUE(), LAST_VALUE() — Крайние значения

**Пример 4.4.1 — Самая дешевая цена в категории:**
```sql
SELECT 
    ProductName,
    CategoryID,
    UnitPrice,
    FIRST_VALUE(ProductName) OVER (PARTITION BY CategoryID ORDER BY UnitPrice) AS CheapestProduct,
    FIRST_VALUE(UnitPrice) OVER (PARTITION BY CategoryID ORDER BY UnitPrice) AS CheapestPrice
FROM Products
ORDER BY CategoryID, UnitPrice;
```

**Пример 4.4.2 — Разница между текущей ценой и минимальной в категории:**
```sql
SELECT 
    ProductName,
    CategoryID,
    UnitPrice,
    MIN(UnitPrice) OVER (PARTITION BY CategoryID) AS MinInCategory,
    UnitPrice - MIN(UnitPrice) OVER (PARTITION BY CategoryID) AS DiffFromMin
FROM Products
ORDER BY CategoryID, UnitPrice;
```

---

### ТЕМА 5. РАБОТА С ДАТАМИ (PostgreSQL)

#### 5.1 Извлечение частей даты

**Функция EXTRACT:**
```sql
SELECT 
    OrderDate,
    EXTRACT(YEAR FROM OrderDate) AS Year,
    EXTRACT(QUARTER FROM OrderDate) AS Quarter,
    EXTRACT(MONTH FROM OrderDate) AS Month,
    EXTRACT(DAY FROM OrderDate) AS Day,
    EXTRACT(DOW FROM OrderDate) AS DayOfWeek,  -- 0=Воскресенье
    EXTRACT(DOY FROM OrderDate) AS DayOfYear  -- День в году (1-366)
FROM Orders
LIMIT 10;
```

**Пример 5.1.1 — Продажи по месяцам:**
```sql
SELECT 
    DATE_TRUNC('month', OrderDate) AS MonthStart,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM Orders o
JOIN "Order Details" od ON o.OrderID = od.OrderID
GROUP BY DATE_TRUNC('month', OrderDate)
ORDER BY MonthStart;
```

---

#### 5.2 Арифметика с датами

**Операции с датами:**
```sql
SELECT 
    OrderDate,
    ShippedDate,
    ShippedDate - OrderDate AS DeliveryDays,      -- Разница в днях
    OrderDate + INTERVAL '30 days' AS PlusMonth,  -- Добавить дни
    OrderDate - INTERVAL '1 year' AS MinusYear    -- Вычесть год
FROM Orders
WHERE ShippedDate IS NOT NULL
LIMIT 10;
```

**Пример 5.2.1 — Задержки доставки:**
```sql
SELECT 
    OrderID,
    OrderDate,
    RequiredDate,
    ShippedDate,
    (ShippedDate - RequiredDate) AS DelayDays,
    CASE 
        WHEN ShippedDate > RequiredDate THEN 'Задержка'
        WHEN ShippedDate = RequiredDate THEN 'В срок'
        ELSE 'Раньше срока'
    END AS DeliveryStatus
FROM Orders
WHERE ShippedDate IS NOT NULL
ORDER BY DelayDays DESC;
```

---

#### 5.3 Фильтрация по датам

**Пример 5.3.1 — Заказы за последние 30 дней:**
```sql
SELECT *
FROM Orders
WHERE OrderDate >= CURRENT_DATE - INTERVAL '30 days';
```

**Пример 5.3.2 — Заказы за 1997 год (оптимально с индексом):**
```sql
SELECT *
FROM Orders
WHERE OrderDate BETWEEN '1997-01-01' AND '1997-12-31';
```

**Пример 5.3.3 — Дни рождения сотрудников:**
```sql
SELECT 
    FirstName,
    LastName,
    BirthDate,
    EXTRACT(MONTH FROM BirthDate) AS BirthMonth,
    EXTRACT(DAY FROM BirthDate) AS BirthDay
FROM Employees
WHERE EXTRACT(MONTH FROM BirthDate) = EXTRACT(MONTH FROM CURRENT_DATE)
ORDER BY BirthDate;
```

---

### ТЕМА 6. ОПТИМИЗАЦИЯ И ТИПЫ ДАННЫХ

---

#### 6.1 Типы данных в PostgreSQL

| Тип | Когда использовать |
| :--- | :--- |
| **INTEGER / BIGINT** | Для ID, счетчиков, количеств |
| **DECIMAL(p, s)** | Для денег, точных величин (p — точность, s — масштаб) |
| **FLOAT / DOUBLE** | Для научных расчетов (допустимы погрешности) |
| **VARCHAR(n)** | Для строк с ограничением длины |
| **TEXT** | Для длинных текстов без ограничения |
| **DATE** | Только дата (без времени) |
| **TIMESTAMP** | Дата + время |
| **BOOLEAN** | Логические значения (TRUE/FALSE) |

**Пример 6.1.1 — Создание таблицы с правильными типами:**
```sql
CREATE TABLE Sales (
    SaleID SERIAL PRIMARY KEY,                    -- Автоинкремент
    ProductID INTEGER NOT NULL,
    CustomerID VARCHAR(5) NOT NULL,                -- У нас в Northwind 5 символов
    SaleDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Quantity INTEGER CHECK (Quantity > 0),         -- Не может быть отрицательным
    UnitPrice DECIMAL(10,2) CHECK (UnitPrice > 0), -- Деньги с 2 знаками
    Discount DECIMAL(3,2) DEFAULT 0.00,
    TotalPrice DECIMAL(12,2) GENERATED ALWAYS AS (Quantity * UnitPrice * (1 - Discount)) STORED
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
CREATE INDEX idx_orders_customerid ON Orders(CustomerID);

-- Составной индекс (порядок важен!)
CREATE INDEX idx_orders_customer_date ON Orders(CustomerID, OrderDate);

-- Уникальный индекс
CREATE UNIQUE INDEX idx_unique_productname ON Products(ProductName);
```

**Пример 6.2.2 — Когда индекс НЕ поможет:**
```sql
-- !!! Индекс по CustomerID не поможет
SELECT * FROM Orders WHERE UPPER(CustomerID) = 'ALFKI';

-- !!! Индекс по OrderDate не поможет
SELECT * FROM Orders WHERE EXTRACT(YEAR FROM OrderDate) = 1997;

-- !!! Индекс по ProductName не поможет
SELECT * FROM Products WHERE ProductName LIKE '%Apple%';
```

---

#### 6.3 EXPLAIN — Анализ запросов

**Синтаксис:**
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) 
SELECT * FROM Orders WHERE CustomerID = 'ALFKI';
```

**Как читать EXPLAIN:**
```
Seq Scan on orders  (cost=0.00..142.00 rows=6 width=80)
                    (actual time=0.023..1.234 rows=6 loops=1)
  Filter: ((customerid)::text = 'ALFKI'::text)
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
SELECT * FROM Orders 
WHERE CustomerID = 'ALFKI' AND OrderDate BETWEEN '1997-01-01' AND '1997-12-31';
```
План: `Seq Scan` на 10000 строк.

**Создаем индекс:**
```sql
CREATE INDEX idx_orders_customer_date ON Orders(CustomerID, OrderDate);
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
    ContactName,
    ContactTitle
FROM Customers
WHERE ContactTitle ~ '^[A-Za-z]+ [A-Za-z]+$';
```

**Пример 7.2 — Очистка номеров телефонов:**
```sql
SELECT 
    Phone,
    REGEXP_REPLACE(Phone, '[^0-9+]', '', 'g') AS CleanPhone
FROM Customers
LIMIT 10;
```

**Пример 7.3 — Извлечение домена из email (если бы он был в таблице):**
```sql
SELECT 
    email,
    SUBSTRING(email FROM '@([^@]+)$') AS Domain
FROM Customers;
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
WITH EmployeeSales AS (
    SELECT 
        e.EmployeeID,
        e.FirstName || ' ' || e.LastName AS EmployeeName,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSales,
        AVG(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS AvgCheck
    FROM Employees e
    JOIN Orders o ON e.EmployeeID = o.EmployeeID
    JOIN "Order Details" od ON o.OrderID = od.OrderID
    WHERE EXTRACT(YEAR FROM o.OrderDate) = 1997
    GROUP BY e.EmployeeID, e.FirstName, e.LastName
),
GlobalAvg AS (
    SELECT AVG(TotalSales) AS AvgAll FROM EmployeeSales
),
Ranked AS (
    SELECT 
        es.*,
        DENSE_RANK() OVER (ORDER BY es.TotalSales DESC) AS SalesRank,
        LAG(es.TotalSales, 1) OVER (ORDER BY es.TotalSales DESC) AS PrevSales
    FROM EmployeeSales es
)
SELECT 
    r.EmployeeName,
    ROUND(r.TotalSales, 2) AS TotalSales,
    ROUND(r.AvgCheck, 2) AS AvgCheck,
    r.SalesRank,
    ROUND(r.TotalSales - r.PrevSales, 2) AS DiffFromPrevious,
    ROUND((r.TotalSales - ga.AvgAll) / ga.AvgAll * 100, 2) AS PercentAboveAvg
FROM Ranked r
CROSS JOIN GlobalAvg ga
WHERE r.TotalSales > ga.AvgAll
ORDER BY r.TotalSales DESC;
```

