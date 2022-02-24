SELECT *
FROM housing..NashvilleHousing

-- Standardize Date Format

Select SaleDate,CONVERT(Date,SaleDate)
FROM housing..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 


-- Populate Property Address data
Select *
FROM housing..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


Select *
FROM housing..NashvilleHousing a
JOIN housing..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID   -- <>  means NOT EQUAL

-- Show where address is null
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
FROM housing..NashvilleHousing a
JOIN housing..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID   -- <>  means NOT EQUAL
WHERE a.PropertyAddress is null

-- Fill values where address is null
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing..NashvilleHousing a
JOIN housing..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID   -- <>  means NOT EQUAL
WHERE a.PropertyAddress is null


-- to get char index of comma

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address,
CHARINDEX(',',PropertyAddress)
FROM housing..NashvilleHousing

-- Break Address to Individual Columns(Adress,City,State)
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM housing..NashvilleHousing

--Add new column
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))



-- Check 
SELECT *
FROM housing..NashvilleHousing


--DROP COLUMN
ALTER TABLE NashvilleHousing
DROP COLUMN Property;


-- Break OwnerAddress to Individual Columns(Adress,City,State)
SELECT OwnerAddress
FROM housing..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM housing..NashvilleHousing


--Add new column
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



-- Change Y and N To Yes and No in "Sold as Vacant" field
--Unique Values 
SELECT DISTINCT(SoldAsVacant)
FROM housing..NashvilleHousing

-- Get count of Y and N
SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM housing..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 ASC


-- Get count of Y and N
SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM housing..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--CHECK Unique Values 
SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM housing..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 ASC



-- Remove Duplicates

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM housing..NashvilleHousing



-- Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM housing..NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- DELETE Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM housing..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

SELECT *
FROM housing..NashvilleHousing

ALTER TABLE housing..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE housing..NashvilleHousing
DROP COLUMN SaleDate




