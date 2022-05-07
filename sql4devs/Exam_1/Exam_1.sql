/*HW1*/

SELECT CustomerId, COUNT(OrderId) AS OrderCount 
FROM [Order] 
WHERE (YEAR(OrderDate) BETWEEN '2017' AND '2018') AND ShippedDate IS NULL 
GROUP BY CustomerId 
HAVING COUNT(OrderId) >= 2



/*HW2*/

DECLARE @TableName nvarchar(1000)
SET @TableName = (SELECT 'Product_' + convert(varchar(500), GetDate(),112))
EXECUTE('Select * into '+ @TableName+ ' from Product where ModelYear !=' +'2016');

EXECUTE('UPDATE '+ @TableName + '
set
ListPrice =
case
when (BrandId = 3 OR BrandId = 7) then ListPrice+( (ListPrice*20) /100 )
else ListPrice+( (ListPrice*10) /100 )
end ;'
);
