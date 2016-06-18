USE AdventureWorks2012;
GO


/* get a list of customers, with each customer's addresses, sales, and sales items as nested arrays on each customer */

SELECT	TOP 10
		Person.BusinessEntityID
	,	Person.FirstName
	,	Person.LastName
	,	(
			SELECT	a.AddressLine1
				,	a.AddressLine2
				,	a.PostalCode
			FROM	Person.BusinessEntityAddress AS bea
					INNER JOIN Person.Address AS a ON a.AddressID = bea.AddressID
			WHERE	bea.BusinessEntityID = Person.BusinessEntityID
			FOR JSON AUTO
		) AS AddressList
	,	(
			SELECT	soh.SalesOrderNumber
				,	(
						SELECT	sod.SalesOrderID
							,	sod.ProductID
							,	sod.UnitPrice
							,	sod.OrderQty
							,	sod.LineTotal
						FROM	Sales.SalesOrderDetail AS sod
						WHERE SalesOrderID = soh.SalesOrderID
						FOR JSON AUTO
					) AS SaleItemList -- nested SaleItemList array for each element within SaleList array
			FROM	Sales.Customer AS c
					INNER JOIN Sales.SalesOrderHeader AS soh ON soh.CustomerID = c.CustomerID
			WHERE	c.PersonID = Person.BusinessEntityID
			FOR JSON AUTO
		) AS SaleList -- nested array with one element for each sale. could replace with scalar function, but don't think inline TVF can yield desired nesting because FOR JSON pathing is finicky
FROM	Person.Person
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER