USE AdventureWorks2012;
GO


/* get a list of customers, with each customer's addresses, sales, and sales items as nested arrays on each customer

  (I want to test performance difference if any of replacing inline correlated subqueries with scalar UDFs to
  reduce code duplication. Tried to do this with an inline TVF, but that didn't yield the desired nesting
  because FOR JSON pathing is finicky.)
*/

WITH cte_Data AS (
	-- This query defines the data we want for each JSON document & includes any nested JSON objects needed based on subqueries.
	SELECT	TOP 2
			PersonID	=	Person.BusinessEntityID
		,	FirstName	=	Person.FirstName
		,	LastName	=	Person.LastName
		,	AddressList	=	(	-- nested array with one element for each address.
								SELECT	a.AddressLine1
									,	a.AddressLine2
									,	a.PostalCode
								FROM	Person.BusinessEntityAddress AS bea
										INNER JOIN Person.Address AS a ON a.AddressID = bea.AddressID
								WHERE	bea.BusinessEntityID = Person.BusinessEntityID
								FOR JSON AUTO
							)
		,	SaleList	=	(	-- nested array with one element for each sale. 
								SELECT	SalesOrderID		=	soh.SalesOrderID
									,	SalesOrderNumber	=	soh.SalesOrderNumber
									,	SaleItemList		=	(	-- nested SaleItemList array for each element within SaleList array
																	SELECT	sod.SalesOrderID
																		,	sod.ProductID
																		,	UnitPrice	=	(	-- complex object, can't get this to not be an array and also avoid outer FOR JSON escaping JSON characters
																								SELECT	Amount			=	sod.UnitPrice
																									,	CurrencyUnit	=	'USD'
																								FOR JSON PATH
																							)
																		,	sod.OrderQty
																		,	sod.LineTotal
																	FROM	Sales.SalesOrderDetail AS sod
																	WHERE SalesOrderID = soh.SalesOrderID
																	FOR JSON AUTO
																)
								FROM	Sales.Customer AS c
										INNER JOIN Sales.SalesOrderHeader AS soh ON soh.CustomerID = c.CustomerID
								WHERE	c.PersonID = Person.BusinessEntityID
								FOR JSON AUTO
							) 
	FROM	Person.Person
)
-- Next, we need to select from the CTE both the main JSON document itself, as well as construct the ES bulk API meta rows for each.
-- '{ "index" : { "_index" : "test", "_type" : "type1", "_id" : "1" } }'
SELECT *
FROM cte_Data
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER