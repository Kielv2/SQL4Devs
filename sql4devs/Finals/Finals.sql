/** Q1 **/
USE SQL4DevsDb;
GO
CREATE PROCEDURE CreateNewBrandAndMoveProducts  
	@NewBrandName nvarchar(250), 
	@OldBrandId int
AS
	BEGIN TRY
	BEGIN TRAN
	
		INSERT INTO Brand (BrandName) VALUES (@NewBrandName)

		UPDATE Product SET BrandId = (SELECT BrandId FROM Brand WHERE BrandName = @NewBrandName ) WHERE BrandId = @OldBrandId

		DELETE FROM Brand WHERE BrandId = @OldBrandId

		SELECT * FROM Product WHERE BrandId = (SELECT BrandId FROM Brand WHERE BrandName = @NewBrandName)

	COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH

GO

/** Q2 **/

/** Q1 **/
USE SQL4DevsDb;
GO
CREATE PROCEDURE GetListOfProducts  
	@Start int = 1,
    @Length int = 10,
    @ProductName varchar(100) = null,
    @BrandId int = null,
    @CategoryId int = null,
    @ModelYear int = null
AS

;WITH FINAL AS (
    SELECT 
        p.ProductId,
        p.ProductName,
        b.BrandId,
        b.BrandName,
        c.CategoryId,
        c.CategoryName,
        p.ModelYear,
        p.ListPrice
    FROM Product p 
    LEFT JOIN Brand  b ON p.BrandId = b.BrandId
    LEFT JOIN Category c ON p.CategoryId = c.CategoryId

),
 Records_CTE AS (
        SELECT
        T.*,
        COUNT(*) OVER() AS TotalRecords FROM FINAL T            
    )
    SELECT R.*,
        ROW_NUMBER() OVER (ORDER BY R.ProductId DESC) AS RowNo
    FROM Records_CTE R
    WHERE 
    (@ProductName IS NULL OR R.ProductName LIKE  @ProductName + '%') AND 
    (@BrandId IS NULL OR  R.BrandId = @BrandId) AND
    (@CategoryId IS NULL OR R.CategoryId = @CategoryId) AND
    (@ModelYear IS NULL OR R.ModelYear = @ModelYear) 
    ORDER BY R.ModelYear,R.ListPrice,R.ProductName
    OFFSET (@Start-1)*@Length ROWS
    FETCH NEXT @Length ROWS ONLY

/** Q3 **/

/** Q4 **/
CREATE TABLE Ranking (
    Id int NOT NULL IDENTITY,
    Description varchar(255) NOT NULL,
    PRIMARY KEY (Id)
);

INSERT INTO Ranking (Description) VALUES ('Inactive'), ('Bronze'), ('Silver'), ('Gold'), ('Planitum')

Alter TABLE Customer
	ADD
		RankingId INT FOREIGN KEY REFERENCES Ranking(Id)

USE SQL4DevsDb;
GO
CREATE PROCEDURE uspRankCustomers  
AS
	BEGIN TRY
	BEGIN TRAN
	
	Update Customer
		set RankingId = (
			CASE 
				WHEN q.Total = 0 THEN 1
				WHEN q.Total > 0 and q.Total < 1000 THEN 2
				WHEN q.total >= 1000 and q.Total < 2000 THEN 3
				WHEN q.total >= 2000 and q.Total < 3000 THEN 4
				WHEN q.total > 3000 then 5
				END	
		)
		
		FROM 
			Customer C 
			INNER JOIN 
			(select 
				s.CustomerId, 
				ROUND(SUM(s.TotalPurchase), 2) as Total
				from
					(select 
						oi.OrderId,
						sum((ListPrice * Quantity)/ (1+Discount)) as TotalPurchase,
						O.CustomerId 
					from 
						OrderItem oi inner join [Order] O on oi.OrderId = O.OrderId
					group by oi.OrderId, O.customerId
					) S
				Group By s.CustomerId
			) q 
			on q.CustomerId=c.CustomerId

	COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH

GO

CREATE VIEW vwCustomerOrders AS

Select 
	C.CustomerId,
	FirstName, 
	LastName,
	q.Total as TotalAmount,
	r.Description as CustomerRanking
from
	Customer C 	inner Join  Ranking r on c.RankingId = r.Id

	inner Join 
	(select 
		s.CustomerId, 
		ROUND(SUM(s.TotalPurchase), 2) as Total
		from
			(select 
				oi.OrderId,
				sum((ListPrice * Quantity)/ (1+Discount)) as TotalPurchase,
				O.CustomerId 
			from 
				OrderItem oi inner join [Order] O on oi.OrderId = O.OrderId
			group by oi.OrderId, O.customerId
			) S
		Group By s.CustomerId
	) q on q.CustomerId = c.CustomerId

	
/** Q5 **/
WITH EmployeeCTE
     AS (SELECT StaffId,
                concat(FirstName , ' ', LastName) as FullName,
                ManagerId,
                CAST( concat(FirstName , ' ', LastName) AS VARCHAR(8000)) AS [Employee Hierarchy]
         FROM   Staff
         WHERE  ManagerId IS NULL
         UNION ALL
         SELECT s.StaffId,
                concat(FirstName , ' ', LastName),
                s.ManagerId,
                CAST(P.[Employee Hierarchy] +  ',' + concat(s.FirstName, ' ' , s.LastName)  AS VARCHAR(8000))
         FROM   Staff S
                JOIN EmployeeCTE p
                  ON s.ManagerId = p.StaffId)

SELECT StaffId, FullName, [Employee Hierarchy]
FROM   EmployeeCTE order by StaffId

