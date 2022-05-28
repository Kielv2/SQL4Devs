/*Q1*/
SELECT S.StoreId, S.StoreName
FROM [Store] S
LEFT JOIN [Order] O
on S.StoreId = O.storeid
WHERE Orderdate IS NULL

/*Q2*/
SELECT P.ProductId, P.ProductName, B.BrandName, C.CategoryName, S.Quantity
FROM Product P
LEFT JOIN Stock S ON S.ProductId = P.ProductId
LEFT JOIN Store ST ON st.StoreId = S.StoreId
LEFT JOIN Category C ON p.CategoryId = C.CategoryId
LEFT JOIN Brand B ON P.BrandId = B.BrandId
WHERE P.ModelYear IN ('2017','2018') AND ST.StoreId = 2
ORDER BY S.Quantity DESC, P.ProductName, B.BrandName, C.CategoryName

/*Q3*/
select S.StoreName, Year(OrderDate) as OrderYear, count(S.StoreName) as OrderCount 
from [Order] O
inner join [Store] S on S.StoreId = O.StoreId
group by S.StoreName, year(OrderDate)
order by StoreName, OrderYear desc

/*Q4*/

;with cte1 as  
(  
    SELECT BrandId, ProductId, ProductName, ListPrice, 
    Row_number () over(  PARTITION BY BrandId order by ListPrice desc ) AS ranks
    from Product p
)  
 
SELECT B.BrandName, ProductId, ProductName, ListPrice  FROM cte1 C
inner join Brand B on B.BrandId= C.BrandId
where ranks <=5

/*Q5*/
declare @StoreName varchar(100)
declare @OrderDate varchar(100)
declare @OrderCount varchar(10)

declare cur cursor for
	select S.StoreName, Year(OrderDate) as OrderYear, count(S.StoreName) as OrderCount 
	from [Order] O
	inner join [Store] S on S.StoreId = O.StoreId
	group by S.StoreName, year(OrderDate)
	order by StoreName, OrderYear desc

open cur
if @@CURSOR_ROWS > 0
	begin 
		fetch next from cur into @StoreName, @OrderDate, @OrderCount
		
		while @@FETCH_STATUS=0
			begin
			print @StoreName + ' ' + @OrderDate + ' ' + @OrderCount

			fetch next from cur into @StoreName, @OrderDate, @OrderCount
		end
end

close cur
deallocate cur

/*Q6*/
DECLARE @count int = 1;
DECLARE @counter int = 0;
DECLARE @x int = 1;

WHILE @count < 11
BEGIN
    WHILE @x < 11
    BEGIN
        SET @counter = @count * @x
        PRINT ''+ CAST(@count as varchar) + ' x ' + CAST(@x as varchar) + ' = ' + CAST(@counter as varchar)
        SET @x = @x + 1;
    END
        
    SET @x = 1;
    SET @count = @count + 1;
END

/*Q7*/
SELECT YEAR(o.OrderDate) [Year], MONTH(o.OrderDate) [Month], (SUM(oi.ListPrice) * SUM(oi.Quantity)) as Sales
FROM [Order] o
INNER JOIN OrderItem oi ON o.OrderId = oi.OrderId
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY YEAR(o.OrderDate), MONTH(o.OrderDate)
