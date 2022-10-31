SELECT * FROM Nashville

-- Remove the detail from the date
SELECT 
	ConvertedSaleDate,
	CONVERT(date, SaleDate)
FROM
	Nashville

ALTER TABLE Nashville
Add ConvertedSaleDate Date

UPDATE Nashville
SET ConvertedSaleDate = CONVERT(date, SaleDate)

--Change NULL PropertyAddress 
SELECT
	PropertyAddress
FROM NashvilleHousing
WHERE
	PropertyAddress is null
ORDER BY ParcelID

SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a JOIN Nashville b ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null

BEGIN TRAN
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	Nashville a JOIN Nashville b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null

COMMIT

-- Parse the property address from its address and its city
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) ) as Address
FROM
	Nashville

ALTER TABLE Nashville
ADD Address Nvarchar(255)

UPDATE Nashville
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville
ADD City Nvarchar(255)

UPDATE Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Parse the owneraddress
SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),1),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM Nashville

ALTER TABLE Nashville
ADD OwnerAddressSplit Nvarchar(255)

UPDATE Nashville
SET OwnerAddressSplit = 	PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville
ADD OwnerCitySplit Nvarchar(255)

UPDATE Nashville
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville
ADD OwnerStateSplit Nvarchar(255)

UPDATE Nashville
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N in SoldAsVacant column
SELECT Distinct
	SoldAsVacant,
	COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM
	Nashville

BEGIN TRAN
UPDATE Nashville
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

--Remove duplicates 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Nashville
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

--Deleting unused columns
ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
