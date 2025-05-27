# pr13
## Практическая работа 13. План запроса.
## Цель:


## Задачи:
13.1 Создайте таблицу table1.

13.2 Создайте таблицу table2 со следующими параметрами: возьмите набор полей table1 с помощью директивы LIKE.

13.3 Проверить, какое количество внешних таблиц присутствует в бд.

13.4 Сгенерируйте данные и вставьте их в таблицы(табл1-200.000, табл2-400.000 данных).

13.5 С помощью директивы EXPLAIN просмотрите план соединения таблиц table1 и table2 по ключу id1.

13.6 Используя таблицы table1 и table2 реализовать план запроса: -План запроса встроенного инструмента dbeaver; -С помощью директивы EXPLAIN.

13.7 Реализовать запросы с использованием объединений, группировки, вложенного подзапроса. Экспортировать план в файл, используя psql -qAt -f explain.sql > analyze.json

13.8 Сравните полученные результаты в пункте 13.6 локально с результатом на сайте https://tatiyants.com/pev/#f/plans/new и сделайте вывод.

## Выполнение практической работы


## 13.1 Создайте таблицу table1 

````
CREATE TABLE table1 (
    id1 INT,
    id2 INT,
    gen1 TEXT,
    gen2 TEXT,
    PRIMARY KEY (id1, id2, gen1)
);
````
## 13.2 Создайте таблицу table2 со следующими параметрами: возьмите набор полей table1 с помощью директивы LIKE.
````
CREATE TABLE table2 (LIKE table1 INCLUDING ALL);
````
## Результат создания 
![image](https://github.com/user-attachments/assets/0cc654aa-8c82-4e7e-afb3-10100782ff97)


## 13.3 Проверить, какое количество внешних таблиц присутствует в бд.
````
SELECT count(*) AS foreign_table_count
FROM pg_foreign_table;
````
## Результат проверки
![image](https://github.com/user-attachments/assets/21b2facf-681a-4601-b8cf-f9282cf85e8d)


## 13.4 Сгенерируйте данные и вставьте их в таблицы(табл1-200.000, табл2-400.000 данных).
Данные для первой таблицы
````
INSERT INTO table1 (id1, id2, gen1, gen2)
SELECT 
    gen AS id1,
    (gen + 1000000) AS id2, -- делаем id2 уникальным
    ('spec' || (gen % 10 + 1)) AS gen1, -- ограничим число вариантов специальностей
    (gen::TEXT || '_info') AS gen2
FROM generate_series(1, 200000) AS gen;
````
Данные для второй таблицы
````
INSERT INTO table2 (id1, id2, gen1, gen2)
SELECT 
    gen AS id1,
    (gen + 2000000) AS id2,
    ('spec' || (gen % 10 + 1)) AS gen1,
    (gen::TEXT || '_info') AS gen2
FROM generate_series(1, 400000) AS gen;
````
Коды для проверки
````
SELECT COUNT(*) FROM table1;
````
````
SELECT COUNT(*) FROM table2; 
````
## Результаты проверки
![image](https://github.com/user-attachments/assets/4e467381-ef3d-45a4-a909-ab0ccd885187)
![image](https://github.com/user-attachments/assets/78c6fcdc-5052-4cc5-bfe6-afee925a9460)

## 13.5 С помощью директивы EXPLAIN просмотрите план соединения таблиц table1 и table2 по ключу id1.
````
EXPLAIN
SELECT *
FROM table1 t1
JOIN table2 t2 ON t1.id1 = t2.id1;

````
## Результат
![image](https://github.com/user-attachments/assets/d1d00993-a04d-46b5-bcee-09237b747aa4)


## 13.6 Используя таблицы table1 и table2 реализовать план запроса: -План запроса встроенного инструмента dbeaver; -С помощью директивы EXPLAIN.
Первый метод

![image](https://github.com/user-attachments/assets/3bc44f05-3e8c-4ee0-8c3f-cdfcb9c0cf3d)

![image](https://github.com/user-attachments/assets/a4ae8942-3c54-4277-ba25-c6212d02852e)

![image](https://github.com/user-attachments/assets/7e9f3c05-c9ad-4384-9c67-300fc79e26d1)


Второй метод
````
EXPLAIN ANALYZE
SELECT t1.id1, t1.gen1, t2.gen2
FROM table1 t1
JOIN table2 t2 ON t1.id1 = t2.id1;
````
## Результат
![image](https://github.com/user-attachments/assets/fbc67e90-02e9-43b9-a41a-b7e494a5c67b)

## 13.7 Реализовать запросы с использованием объединений, группировки, вложенного подзапроса. Экспортировать план в файл, используя psql -qAt -f explain.sql > analyze.json

````
SELECT t1.id1, t1.gen1, t2.gen2
FROM table1 t1
JOIN table2 t2 ON t1.id1 = t2.id1;
````
## Результат JOIN
![image](https://github.com/user-attachments/assets/ce6fd7c7-1278-4593-aed4-814fcb0f1588)


````
SELECT gen1, COUNT(*) AS total
FROM table1
GROUP BY gen1;
````
## Результат GROUP BY
![image](https://github.com/user-attachments/assets/0f0d4457-7deb-4538-b127-c4e3a1c2b2dc)

````
SELECT *
FROM table1
WHERE id1 IN (
    SELECT id1
    FROM table2
    WHERE id2 > 1000
);
````
## Результат подзапроса
![image](https://github.com/user-attachments/assets/e87119a5-ab90-4e3f-9f5d-b54c39c46a0c)

## Выводы
