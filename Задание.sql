--Укажите количество клиентов магазина?
SELECT COUNT(name)
FROM clients;

--Укажите количество клиентов, электронная почта которых зарегистрирована в домене mail.ru?
SELECT count(*)
FROM clients
WHERE email like '%@mail.ru';

/*
Для каждого населенного пункта рассчитать количество клиентов, зарегистрованных в нем. 
Отсортируйте результат по убыванию количества клиентов. 
Укажите населенный пункт, занимающий второе место по количеству клиентов?
*/

SELECT city, 
       COUNT(*)
FROM clients
GROUP by city
ORDER BY COUNT(*) DESC LIMIT 1,1;

/*
Для каждого населенного пункта рассчитать процент клиентов, зарегистрованных в нем. 
Для населенного пункта «клх Новочеркасск» укажите процент клиентов, 
зарегистрированных в нем?
*/
SELECT city, (COUNT(*) * 100.0 / x.cnt) AS  cnt
FROM clients, (SELECT COUNT(*) as cnt FROM clients) as x
WHERE city LIKE 'клх Новочеркасск'
GROUP BY city;

/*
Укажите общую, минимальную, максимальную и выборочную среднюю стоимость товаров.
При необходимости результат округлите до 2 знаво после запятой
*/
SELECT SUM(cost),
       MIN(cost),
       MAX(cost),
       ROUND(AVG(cost),2)
FROM products 

/*
Укажите кол-во товаров,
стоимость которых строго больше выборочной средней стоимости
*/
SELECT COUNT(*)
FROM products
WHERE cost > (SELECT AVG(cost) 
              FROM products)
              
/* Укажите для каждой категории общее кол-во товаров, а также общую, минимальную,
максимальную и выборочную среднюю стоимость товаров. При необходимости результат
округлите до 2 знаков после запятой. Отсортируйте таблицу по выборочной средней 
стоимости. Укажите группу, находящуюся на втором месте
*/
SELECT category,
       SUM(cost) AS 'Общая стоимость',
       MIN(cost) AS 'Минимальная стоимость',
       MAX(cost) AS 'Максимальная стоимость',
       ROUND(AVG(cost),2) AS 'Средняя стоимость'
FROM products
GROUP BY category
ORDER BY AVG(cost) LIMIT 1,1;

--Укажите ФИО клиента, совершившего больше всего заказов
SELECT c.name AS ФИО, COUNT(o.id) AS 'Количество Заказов'
FROM clients c, orders o
WHERE c.id = o.client_id
GROUP BY c.name
ORDER BY COUNT(o.id) DESC LIMIT 1;

/*
Сколько клиентов сделали заказ в населенный пункт,
не совпадающий с населенным пунктом проживания
*/
SELECT SUM(IIF(clients.city=orders.city, 0, 1))
FROM clients
INNER JOIN orders 
ON clients.id = orders.client_id

/*
Укажите населенный пункт, в котором проживают клиенты,
совершившие больше всего заказов в другие населенные пункты
*/
SELECT c.city, COUNT(c.city)
FROM clients c 
INNER JOIN orders o
ON c.id=o.client_id AND
   c.city != o.city
GROUP BY c.city
ORDER BY COUNT(c.city) DESC

--Укажите год, в котором совершили больше всего заказов
SELECT t.year_order, 
       count(t.year_order) 
FROM (SELECT date,
             strftime('%Y', date) year_order
      FROM clients
      INNER JOIN orders 
      ON clients.id = orders.client_id) AS t
GROUP BY t.year_order
ORDER BY COUNT(t.year_order) DESC

--Укажите день, в который совершено 3 заказа
WITH t(id, day)  
AS (SELECT id,
           strftime('%Y-%m-%d', date)
    FROM orders)
SELECT t.day,
       COUNT(t.id) AS cnt
FROM t
GROUP BY t.day
HAVING cnt = 3

--Укажите дату первого и последнего заказов
SELECT MIN(t.date_order) AS 'Дата первого заказа',
       MAX(t.date_order) AS 'Дата последнего заказа'
FROM (SELECT orders.id ord_id,
             date,
             strftime('%Y-%m-%d', date) date_order
      FROM clients
      INNER JOIN orders 
      ON clients.id = orders.client_id) AS t
      
--Укажите количество заказов, совершенных с 2022-01-01 по 2022-06-01 включительно
SELECT COUNT(*)
FROM (SELECT orders.id ord_id,
             date,
             strftime('%Y-%m-%d', date) date_order
      FROM clients
      INNER JOIN orders 
      ON clients.id = orders.client_id) AS t
WHERE t.date_order BETWEEN '2022-01-01' AND '2022-06-01' 

--Укажите максимальную стоимость заказа с учетом скидки
SELECT orders.id,
       SUM(products.cost * positions.number - (products.cost * positions.number*positions.sale/100)) AS max_cost   
FROM clients
INNER JOIN orders 
ON clients.id = orders.client_id
INNER JOIN positions 
ON positions.order_id = orders.id
INNER JOIN products 
ON positions.product_id = products.id
GROUP BY orders.id
ORDER BY max_cost DESC LIMIT 1;

--Укажите наиболее продаваемый товар по количеству штук
SELECT products.name product_name, 
       SUM(positions.number)
FROM clients
INNER JOIN orders 
ON clients.id = orders.client_id
INNER JOIN positions 
ON positions.order_id = orders.id
INNER JOIN products 
ON positions.product_id = products.id
GROUP BY products.name 
ORDER BY SUM(positions.number) DESC LIMIT 1;

--Сколько штук "Скакалка спортивная MVRX" продано за весь период
SELECT products.name product_name, 
       SUM(positions.number)
FROM clients
INNER JOIN orders 
ON clients.id = orders.client_id
INNER JOIN positions 
ON positions.order_id = orders.id
INNER JOIN products 
ON positions.product_id = products.id
WHERE products.name = 'Скакалка спортивная MVRX'
