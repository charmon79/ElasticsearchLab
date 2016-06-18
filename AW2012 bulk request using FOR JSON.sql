USE AdventureWorks2012;
GO


/* get a list of customers, with each customer's addresses, sales, and sales items as nested arrays on each customer */
--WITH cteData AS (
SELECT
		p.BusinessEntityID AS 'BusinessEntityID'
	,	p.FirstName AS 'FirstName'
	,	p.LastName AS 'LastName'

	--,	PhoneList.PhoneNumber
	,	SaleList.SalesOrderNumber AS 'SaleList.SalesOrderNumber'
	,	SaleList.ProductID AS 'SaleList.ProductID'
	,	SaleList.UnitPrice AS 'SaleList.UnitPrice'
	,	SaleList.OrderQty AS 'SaleList.OrderQty'
	,	SaleList.LineTotal AS 'SaleList.LineTotal'
	,	AddressList.AddressLine1 AS 'AddressList.AddressLine1'
	,	AddressList.AddressLine2 AS 'AddressList.AddressLine2'
	,	AddressList.PostalCode AS 'AddressList.PostalCode'
FROM	Person.Person AS p
		LEFT JOIN (
			SELECT	bea.BusinessEntityID
				,	a.AddressLine1
				,	a.AddressLine2
				,	a.PostalCode
			FROM	Person.BusinessEntityAddress AS bea
					INNER JOIN Person.Address AS a ON a.AddressID = bea.AddressID
		) AS AddressList ON AddressList.BusinessEntityID = p.BusinessEntityID
		LEFT JOIN (
			SELECT	c.PersonID
				,	soh.SalesOrderNumber
				,	SaleItemList.ProductID
				,	SaleItemList.UnitPrice
				,	SaleItemList.OrderQty
				,	SaleItemList.LineTotal
			FROM	Sales.Customer AS c
					INNER JOIN Sales.SalesOrderHeader AS soh ON soh.CustomerID = c.CustomerID
					INNER JOIN (
						SELECT	sod.SalesOrderID
							,	sod.ProductID
							,	sod.UnitPrice
							,	sod.OrderQty
							,	sod.LineTotal
						FROM	Sales.SalesOrderDetail AS sod
					) AS SaleItemList ON SaleItemList.SalesOrderID = soh.SalesOrderID
		) AS SaleList ON SaleList.PersonID = p.BusinessEntityID
WHERE	p.BusinessEntityID IN 
		(
			SELECT TOP 10 c.PersonID
			FROM Sales.SalesOrderHeader soh
			join sales.Customer c on c.CustomerID = soh.CustomerID
			group by c.PersonID having count(1) > 1
		)
FOR JSON PATH--, WITHOUT_ARRAY_WRAPPER
--)
--SELECT
--		BusinessEntityID
--	,	'{ "index" : { "_index" : "test", "_type" : "type1", "_id" : "1" } }'
--	,	'{ "index" : '
--		+	(
--				SELECT	'test' AS [_index]
--					,	'person' AS [_type]
--					,	BusinessEntityID AS [_id]
--				FROM	cteData
--				WHERE	BusinessEntityID = d.BusinessEntityID
--				FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
--			)
--		+	' }'
--			AS BulkHeader
--	,	(
--			SELECT	*
--			FROM	cteData
--			WHERE	BusinessEntityID = d.BusinessEntityID
--			FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
--		) AS BulkData
--FROM cteData AS d