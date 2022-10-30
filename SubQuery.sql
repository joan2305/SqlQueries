--Subquery

--IN
SELECT *

FROM MsFish
WHERE FishID IN (
	SELECT FishID FROM TransactionDetail 
	WHERE Quantity>20 
)


--Exists -> return true/false ketika query di dalam exists ada result -> true
SELECT *
FROM MsCustomer mc
WHERE EXISTS (
	SELECT *
	FROM TransactionHeader th
	WHERE mc.CustomerID = th.CustomerID
)

--Any/Some --> >, <, >=, <=
SELECT * 
FROM MsFish
WHERE FishPrice > ANY(SELECT TOP 3 FishPrice FROM MsFish)

SELECT * 
FROM MsFish
WHERE FishPrice > SOME(SELECT TOP 3 FishPrice FROM MsFish)

--ALL

SELECT * 
FROM MsFish
WHERE FishPrice > ALL(SELECT TOP 3 FishPrice FROM MsFish)

--Alias Subquery
SELECT *
FROM MsFish, (
	SELECT avege =AVG(FishPrice)
	FROM MsFish
)AS alias
WHERE FishPrice > alias.avege

--ANSWERS

-- Nomor 1

SELECT
	FishermanID,
	FishermanName

FROM MsFisherman
WHERE
	FishermanID IN('FS001','FS003','FS011')

-- Nomor 2
SELECT
	FishName,
	FishPrice
FROM MsFish
WHERE FishTypeID IN (
	SELECT FishTypeID
	FROM MsFishType
	WHERE FishTypeName NOT IN ('Marlin','Grouper', 'Bass')
)

-- Nomor 3
SELECT
	CustomerName,
	CustomerEmail
FROM MsCustomer
WHERE CustomerGender = 'male'
AND
CustomerID NOT IN (
	SELECT CustomerID
	FROM TransactionHeader
)

--Nomor 4
SELECT
	FishTypeName,
	FishName,
	FishPrice
FROM MsFish mf JOIN MsFishType mft ON mf.FishTypeID = mft.FishTypeID
WHERE FishID IN (
	SELECT FishID
	FROM TransactionDetail
	WHERE TransactionID IN (
		SELECT TransactionID
		FROM TransactionHeader
		WHERE CustomerID IN (
			SELECT CustomerID
			FROM MsCustomer
			WHERE CustomerGender = 'female'
		)
		AND
		DATENAME(QUARTER,TransactionDate) = 2
		AND
		YEAR(TransactionDate) = 2020
	)
)

--ATAU
SELECT
	FishTypeName,
	FishName,
	FishPrice
FROM MsFish mf JOIN MsFishType mft ON mf.FishTypeID = mft.FishTypeID
WHERE FishID IN (
	SELECT FishID
	FROM TransactionDetail td JOIN TransactionHeader th
	ON td.TransactionID = th.TransactionID JOIN MsCustomer mc
	ON mc.CustomerID = th.CustomerID
	WHERE CustomerGender = 'female'
	AND
	DATENAME(QUARTER,TransactionDate) = 2
	AND
	YEAR(TransactionDate) = 2020
		
)
	
--Nomor 5
SELECT
	CustomerName,
	 [TransactionDate]
FROM MsCustomer mc JOIN TransactionHeader th
ON th.CustomerID = mc.CustomerID
WHERE EXISTS(
	SELECT *
	FROM TransactionDetail td JOIN MsFish mf
	ON mf.FishID = td.FishID
	WHERE FishPrice > 35
	AND 
	th.TransactionID = td.TransactionID
)

-- Nomor 6
SELECT
	CustomerName,
	CustomerGender,
	CustomerEmail
FROM
	MsCustomer mc
WHERE EXISTS (
	SELECT *
	FROM TransactionHeader th JOIN MsFisherman mf
	ON mf.FishermanID = th.FishermanID
	WHERE
	FishermanGender = 'female'
	AND
	LEFT(FishermanName,1) IN ('L','R')
	AND
	mc.customerID = th.CustomerID
)

--Nomor 7
SELECT
	CustomerID,
	CustomerName
FROM MsCustomer mc
WHERE CustomerGender = 'male' AND
CustomerID IN (
	SELECT CustomerID
	FROM TransactionHeader th
	WHERE NOT EXISTS(
		SELECT *
		FROM TransactionDetail td JOIN MsFish mf
		ON td.FishID = mf.FishID
		JOIN MsFishType mft ON mft.FishTypeID = mf.FishTypeID
		WHERE FishTypeName = 'Tuna'	
		AND
		th.TransactionID = td.TransactionID
	)
)

--Not exists customer yg tidak melakukan transaksi sama skali ikut ditampilin


-- Nomor 8
SELECT
	FishName,
	FishTypeName,
	FishPrice
FROM MsFish mf JOIN MsFishType mft
ON mf.FishTypeID = mft.FishTypeID, (
	SELECT avege = AVG(FishPrice)
	FROM MsFish
)as alias
WHERE FishPrice > alias.avege

-- Nomor 9
SELECT FishName, FishPrice
FROM MsFish, (
	SELECT mak = MAX(FishPrice), men = MIN(FishPrice)
	FROM MsFish
)as alias
WHERE FishPrice IN (alias.mak, alias.men)

-- Nomor 10
SELECT
	CustomerName,
	CustomerEmail,
	[Fish Type Variant]
FROM MsCustomer mc JOIN TransactionHeader th ON mc.CustomerID = th.CustomerID,
(
	SELECT TransactionID, [Fish Type Variant] = COUNT(DISTINCT mft.FishTypeID)
	FROM TransactionDetail td JOIN MsFish mf
	ON mf.FishID = td.FishID
	JOIN MsFishType mft ON mft.FishTypeID = mf.FishTypeID
	GROUP BY TransactionID
)as A,
(
	SELECT lowestTotalNumber = MIN(A.[Fish Type Variant])
	FROM 
	(
	SELECT TransactionID, [Fish Type Variant] = COUNT(DISTINCT mft.FishTypeID)
	FROM TransactionDetail td JOIN MsFish mf
	ON mf.FishID = td.FishID
	JOIN MsFishType mft ON mft.FishTypeID = mf.FishTypeID
	GROUP BY TransactionID
	)as A
)as B
WHERE [Fish Type Variant] = B.lowestTotalNumber
AND A.TransactionID = th.TransactionID

--Agregat gabisa dilakukan pada ekspreksi agregat
