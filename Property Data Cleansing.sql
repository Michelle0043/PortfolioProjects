-- Cleasing Date in SQL Queries
SELECT *
FROM [SQL Learn].dbo.[NashvilleHousing]

-- Standarize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [SQL Learn].dbo.[NashvilleHousing]

-- Populate Property Address Data for nulls if have the same ParcelID
-- This needs to be done by a join
SELECT A.ParcelID, A.UniqueID, A.PropertyAddress, B.ParcelID, B.UniqueID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [SQL Learn].dbo.[NashvilleHousing] A
JOIN [SQL Learn].dbo.[NashvilleHousing] B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [SQL Learn].dbo.[NashvilleHousing] A
JOIN [SQL Learn].dbo.[NashvilleHousing] B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is null

-- Braking out Address into Individual fields (Address, City, State)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM [SQL Learn].dbo.[NashvilleHousing] 

ALTER TABLE [SQL Learn].dbo.[NashvilleHousing] 
Add PropertySplitAddress NVARCHAR(255);

Update [SQL Learn].dbo.[NashvilleHousing] 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [SQL Learn].dbo.[NashvilleHousing] 
Add PropertySplitCity NVARCHAR(255);

Update [SQL Learn].dbo.[NashvilleHousing] 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM [SQL Learn].dbo.[NashvilleHousing]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [SQL Learn].dbo.[NashvilleHousing]

ALTER TABLE [SQL Learn].dbo.[NashvilleHousing] 
Add OwnerSplitAddress NVARCHAR(255);

Update [SQL Learn].dbo.[NashvilleHousing] 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [SQL Learn].dbo.[NashvilleHousing] 
Add OwnerSplitCity NVARCHAR(255);

Update [SQL Learn].dbo.[NashvilleHousing] 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [SQL Learn].dbo.[NashvilleHousing] 
Add OwnerSplitState NVARCHAR(255);

Update [SQL Learn].dbo.[NashvilleHousing] 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM [SQL Learn].dbo.[NashvilleHousing] 


--Change 1 and 0 to Yes and No in "Sold as Vacant" field
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = '0' THEN 'No'
		WHEN SoldAsVacant = '1' THEN 'Yes'
		END
FROM [SQL Learn].dbo.[NashvilleHousing] 

Update [SQL Learn].dbo.[NashvilleHousing] 
SET SoldAsVacant = CASE WHEN SoldAsVacant = '0' THEN 'No'
		WHEN SoldAsVacant = '1' THEN 'Yes'
		END


-- Remove Duplicates (CTE), with rownumber

WITH RowNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM [SQL Learn].dbo.[NashvilleHousing] 
)

SELECT *
FROM RowNUMCTE
WHERE row_num >1

--Delete unused Columns
ALTER TABLE [SQL Learn].dbo.[NashvilleHousing] 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



