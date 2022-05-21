/*HW1*/
Select P.ProductName, SUM(OI.Quantity) as 'TotalQuantity'
from OrderItem OI
inner join Product P on P.ProductId= OI.ProductId
where OrderId in (select O.OrderId from [Order] O 
inner join Customer C on O.CustomerId = C.CustomerId
where C.State = 'TX')
group By(P.ProductName)
having SUM(OI.Quantity) > 10 
order by SUM(OI.Quantity) desc

/*HW2*/
select 
REPLACE (C.CategoryName COLLATE Latin1_General_BIN, 'Bikes' ,'Bicycles'), Sum(OI.Quantity) as 'TotalQuantity' from OrderItem OI
inner join Product P on P.ProductId = OI.ProductId
inner join Category C on C.CategoryId = P.CategoryId
group by C.CategoryName
order by SUM(OI.Quantity) desc

/*HW3*/
WITH HW1 (ProductName,TotalQuantity) as (
SELECT P.ProductName, SUM(OI.Quantity) as 'TotalQuantity'
from OrderItem OI
inner join Product P on P.ProductId= OI.ProductId
where OrderId in (select O.OrderId from [Order] O 
inner join Customer C on O.CustomerId = C.CustomerId
where C.State = 'TX')
group By(P.ProductName)
having SUM(OI.Quantity) > 10 
),
HW2 (CategoryName,TotalQuantity) as (
select 
REPLACE (C.CategoryName COLLATE Latin1_General_BIN, 'Bikes' ,'Bicycles'), Sum(OI.Quantity) as 'TotalQuantity' from OrderItem OI
inner join Product P on P.ProductId = OI.ProductId
inner join Category C on C.CategoryId = P.CategoryId
group by C.CategoryName
)

(SELECT CategoryName,TotalQuantity FROM HW2)
UNION ALL
(SELECT ProductName, TotalQuantity FROM HW1)
order by TotalQuantity desc

/*HW4*/
WITH q1 (OrderYear, OrderMonth, ProductName, TotalQuantity, [Rank])
AS
( Select Year(o.OrderDate) as 'OrderYear' , Month(o.OrderDate) as 'OrderMonth', p.ProductName, SUM(oi.Quantity) as 'TotalQuantity',
RANK() OVER(PARTITION BY Year(o.OrderDate), Month(o.OrderDate) ORDER BY SUM(oi.Quantity) desc) 'Rank'
from OrderItem oi
inner join [Order] o on oi.OrderId = o.OrderId
inner join Product p on p.ProductId = oi.ProductId
group by Year(o.OrderDate), MONTH(o.OrderDate), p.ProductName )

select OrderYear, OrderMonth, ProductName, TotalQuantity from q1 where [Rank] = 1