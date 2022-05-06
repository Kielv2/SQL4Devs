select * from [Order] where CustomerId = 21

SELECT CustomerId, COUNT(OrderId) AS OrderCount 
FROM [Order] 
WHERE (YEAR(OrderDate) BETWEEN '2017' AND '2018') AND ShippedDate IS NULL 
GROUP BY CustomerId 
HAVING COUNT(OrderId) >= 2





