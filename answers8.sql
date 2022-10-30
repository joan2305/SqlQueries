CREATE VIEW ShowCustomer AS
SELECT
	CustomerID,
	CustomerName
FROM MsCustomer
GO
SELECT * FROM ShowCustomer
GO

--ALTER
ALTER VIEW ShowCustomer AS
SELECT
	CustomerID,
	CustomerName,
	CustomerGender
FROM MsCustomer
GO
SELECT * FROM ShowCustomer

GO

--UPDATE
UPDATE ShowCustomer
SET CustomerName = CONCAT('Mr. ', CustomerName)
WHERE CustomerID = 'CU001'
SELECT * FROM MsCustomer

--DROP

DROP VIEW ShowCustomer
GO

--DCL, data control language
-- GRANT --> kasih izin ke orang untuk akses
--QUERYNYA : GRANT SELECT ON MsCustomer TO Manager
-- GRANT SELECT, INSERT, UPDATE, DELETE ON MsCustomer TO Manager

--REVOKE --> hapus izin ke orang untuk akses
--QUERYNYA : REVOKE SELECT ON MsCustomer FROM Manager



-- Nomor 1

CREATE VIEW ViewFemaleCoupon AS
SELECT 
	CustomerName,
	STUFF(CustomerID,1,2,'#') AS [Coupon]
FROM MsCustomer
WHERE YEAR(CustomerDOB) LIKE 2020 AND CustomerGender LIKE 'Female'
GO

--Nomor 2

CREATE VIEW ViewCustomerMembership AS 
SELECT
	CustomerName AS [Name],
	CustomerGender AS [Gender],
	SUBSTRING(CustomerEmail, 1, CHARINDEX('@',CustomerEmail)) + 'fmania.com' AS [Email],
	CustomerAddress AS [Address]
FROM MsCustomer
WHERE 
	CustomerAddress LIKE '[0-9][0-9] %'
GO

--Nomor 3
CREATE VIEW ViewTuna AS
SELECT
	FishName,
	FishTypeName AS [FishType],
	'$' + CAST(FishPrice AS VARCHAR) AS [Price]

FROM MsFish mf
JOIN MsFishType mft ON mf.FishTypeID = mft.FishTypeID
WHERE 
	FishPrice BETWEEN 12 AND 16 AND
	FishTypeName LIKE 'Tuna'

-- Nomor 4
GO

CREATE VIEW ViewCustomerTransaction AS 
SELECT
	CustomerName,
	COUNT(TransactionID) AS [NumberOfTransaction]
FROM 
	TransactionHeader th JOIN MsCustomer mc
	ON th.CustomerID = mc.CustomerID
WHERE 
	CustomerGender LIKE 'Male'
GROUP BY CustomerName

GO

--Nomor 5
SELECT * FROM TransactionDetail
GO
CREATE VIEW ViewMostExpensiveTransaction AS
SELECT TOP 3
	th.TransactionID,
	CustomerName,
	TransactionDate,
	SUM(Quantity*FishPrice) AS [MoneySpent]
FROM 
	TransactionHeader th JOIN MsCustomer mc
	ON th.CustomerID = mc.CustomerID JOIN
	TransactionDetail td ON th.TransactionID = td.TransactionID 
	JOIN MsFish mf ON td.FishID = mf.FishID 
GROUP BY
	th.TransactionID,
	CustomerName,
	TransactionDate
ORDER BY
	SUM(Quantity*FishPrice) DESC
GO
--Nomor 6
CREATE VIEW ViewYearlyIncomePerTypeIn2020 AS
SELECT
	YEAR(TransactionDate) AS [Year],
	FishTypeName,
	SUM(Quantity*FishPrice) AS [Income]
FROM 
	TransactionHeader th JOIN TransactionDetail td
	ON th.TransactionID = td.TransactionID JOIN 
	MsFish mf ON td.FishID = mf.FishID JOIN
	MsFishType mft ON mf.FishTypeID = mft.FishTypeID
WHERE 
	YEAR(TransactionDate) LIKE '2020'
GROUP BY
	YEAR(TransactionDate),
	FishTypeName
GO

--Nomor 7
CREATE VIEW ViewNonGrouperTransaction AS 
SELECT
	CustomerName,
	COUNT(TransactionID) AS [NumberOfTransaction]
FROM 
	TransactionHeader th JOIN MsCustomer mc on
	th.CustomerID = mc.CustomerID 
WHERE TransactionID NOT IN (
	SELECT TransactionID
	FROM TransactionDetail td JOIN  
		MsFish mf ON td.FishID = mf.FishID
		JOIN MsFishType mft ON mf.FishTypeID = mft.FishTypeID
	WHERE FishTypeName = 'Grouper'
)
GROUP BY 
	CustomerName

GO
CREATE VIEW ViewNonGrouperTransaction2 AS 
SELECT 
	CustomerName,
	COUNT(TransactionID) AS [NumberOfTransaction]
FROM MsCustomer mc
	JOIN TransactionHeader TH on mc.CustomerID = th.CustomerID
WHERE TransactionID NOT IN (
	SELECT TransactionID
	FROM 
		TransactionDetail td JOIN MsFish mf ON td.FishID = mf.FishID
		JOIN MsFishType mft ON mf.FishTypeID = mft.FishTypeID
	WHERE FishTypeName = 'Grouper'
)
GROUP BY CustomerName

GO
--Nomor 8
CREATE VIEW ViewVIPCustomer AS
SELECT DISTINCT
	A.CustomerName,
	A.total AS [MoneySpent]
FROM 
(
	SELECT CustomerName,[total] = SUM(FishPrice*Quantity) 
	FROM TransactionHeader th JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
	JOIN MsFish mf ON td.FishID = mf.FishID JOIN MsCustomer mc
	ON th.CustomerID = mc.CustomerID
	GROUP BY CustomerName
)as A,
(
	SELECT avege = AVG(A.[total])
	FROM 
	(
		SELECT CustomerName,[total] = SUM(FishPrice*Quantity) 
		FROM TransactionHeader th JOIN TransactionDetail td ON th.TransactionID = td.TransactionID
		JOIN MsFish mf ON td.FishID = mf.FishID JOIN MsCustomer mc
		ON th.CustomerID = mc.CustomerID
		GROUP BY CustomerName
	)as A
)as alias
WHERE A.total>=alias.avege

--Nomor 9
GO

CREATE VIEW ViewFavoriteFishType AS
SELECT
	FishTypeName,
	A.totalFish AS [TotalTransaction]
FROM 
(
	SELECT
		FishTypeName,
		totalFish = COUNT(DISTINCT td.TransactionID)
	FROM TransactionDetail td 
	JOIN MsFish mf ON td.FishID = mf.FishID
	JOIN MsFishType mft ON mf.FishTypeID = mft.FishTypeID
	GROUP BY FishTypeName
)as A,
(
	SELECT avege = AVG(A.totalFish)
	FROM
	(
		SELECT
			FishTypeName,
			totalFish = COUNT(DISTINCT td.TransactionID)
		FROM TransactionDetail td 
		JOIN MsFish mf ON td.FishID = mf.FishID
		JOIN MsFishType mft ON mf.FishTypeID = mft.FishTypeID
		GROUP BY FishTypeName
	)as A
)as B
WHERE A.totalFish >= B.avege

GO
--Nomor 10
BEGIN TRAN
DROP VIEW ViewYearlyIncomePerTypeIn2020
ROLLBACK