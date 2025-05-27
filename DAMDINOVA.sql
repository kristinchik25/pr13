--13.1 Создайте таблицу table1
CREATE TABLE table1 (
    id1 INT,
    id2 INT,
    gen1 TEXT,
    gen2 TEXT,
    PRIMARY KEY (id1, id2, gen1)
);

--13.2 Создайте таблицу table2 со следующими параметрами:
--Возьмите набор полей table1 с помощью директивы LIKE.
CREATE TABLE table2 (LIKE table1 INCLUDING ALL);

--13.3 Проверить, какое количество внешних таблиц присутствует в бд
SELECT count(*) AS foreign_table_count
FROM pg_foreign_table;

-- 13.4 Сгенерируйте данные и вставьте их в таблицы
-- Для table1
INSERT INTO table1 (id1, id2, gen1, gen2)
SELECT 
    gen AS id1,
    (gen + 1000000) AS id2, -- делаем id2 уникальным
    ('spec' || (gen % 10 + 1)) AS gen1, -- ограничим число вариантов специальностей
    (gen::TEXT || '_info') AS gen2
FROM generate_series(1, 200000) AS gen;

-- Для table2
INSERT INTO table2 (id1, id2, gen1, gen2)
SELECT 
    gen AS id1,
    (gen + 2000000) AS id2,
    ('spec' || (gen % 10 + 1)) AS gen1,
    (gen::TEXT || '_info') AS gen2
FROM generate_series(1, 400000) AS gen;

--Проверка количества данных
SELECT COUNT(*) FROM table1; 
SELECT COUNT(*) FROM table2; 

--13.5 С помощью директивы EXPLAIN просмотрите план соединения таблиц table1 и table2 по ключу id1.
EXPLAIN
SELECT *
FROM table1 t1
JOIN table2 t2 ON t1.id1 = t2.id1;

--QUERY PLAN                                                                                 |
-------------------------------------------------------------------------------------------+
--Merge Join  (cost=1.24..22038.17 rows=200000 width=50)                                     |
--  Merge Cond: (t1.id1 = t2.id1)                                                            |
--  ->  Index Scan using table1_pkey on table1 t1  (cost=0.42..9470.98 rows=200000 width=25) |
--  ->  Index Scan using table2_pkey on table2 t2  (cost=0.42..18944.67 rows=400000 width=25)|


--13.6 Используя таблицы table1 и table2 реализовать план запроса: -План запроса встроенного инструмента dbeaver;  -С помощью директивы EXPLAIN.
EXPLAIN analyze
SELECT t1.id1, t1.gen1, t2.gen2
FROM table1 t1
JOIN table2 t2 ON t1.id1 = t2.id1;

--QUERY PLAN                                                                                                                                     
-----------------------------------------------------------------------------------------------------------------------------------------------
--Merge Join  (cost=1.24..18655.60 rows=200000 width=21) (actual time=0.030..157.801 rows=200000 loops=1)                                        
--  Merge Cond: (t1.id1 = t2.id1)                                                                                                                
--  ->  Index Only Scan using table1_pkey on table1 t1  (cost=0.42..6088.42 rows=200000 width=10) (actual time=0.013..32.310 rows=200000 loops=1)
--        Heap Fetches: 0                                                                                                                        
--  ->  Index Scan using table2_pkey on table2 t2  (cost=0.42..18944.67 rows=400000 width=15) (actual time=0.013..43.783 rows=200001 loops=1)    
--Planning Time: 0.318 ms                                                                                                                        
--Execution Time: 168.563 ms

--13.7 Реализовать запросы с использованием объединений, группировки, вложенного подзапроса. 
--Экспортировать план в файл, используя psql -qAt -f explain.sql > analyze.json

SELECT t1.id1, t1.gen1, t2.gen2
FROM table1 t1
JOIN table2 t2 ON t1.id1 = t2.id1;


SELECT gen1, COUNT(*) AS total
FROM table1
GROUP BY gen1;


SELECT *
FROM table1
WHERE id1 IN (
    SELECT id1
    FROM table2
    WHERE id2 > 1000
);

-- Для отчета
--Вывести первые 20 значений из таблиц 
SELECT *
FROM table1
limit 20

SELECT *
FROM table2
limit 20
