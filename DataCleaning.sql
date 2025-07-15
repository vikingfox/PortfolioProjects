/*

Cleaning data in SQL Queires

*/
SELECT *
FROM NashvilleHousing$

------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing$

UPDATE PortfolioProject..NashvilleHousing$
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing$
Add SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing$
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------

--Populate Property Address Data
SELECT *
From PortfolioProject..NashvilleHousing$
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

----------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing$

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing$
ORDER BY City

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing$






SELECT OwnerAddress
FROM NashvilleHousing$

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing$

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Change Y and N to Yes and No in "sold as vacant' field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing$
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y'
	THEN 'Yes'
 WHEN SoldAsVacant = 'N'
	THEN 'No'
 ELSE SoldAsVacant
 END
 From PortfolioProject..NashvilleHousing$

 UPDATE PortfolioProject..NashvilleHousing$
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y'
	THEN 'Yes'
 WHEN SoldAsVacant = 'N'
	THEN 'No'
 ELSE SoldAsVacant
 END


 --Remove Duplicates

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
			
 FROM PortfolioProject..NashvilleHousing$
 --ORDER BY ParcelID
 )
 SELECT *
 FROM RowNumCTE
 WHERE row_num >1
 --ORDER BY ParcelID
 

 SELECT * 
 FROM PortfolioProject..NashvilleHousing$

 --DELETE unused columns

 ALTER TABLE PortfolioProject..NashvilleHousing$
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

  ALTER TABLE PortfolioProject..NashvilleHousing$
 DROP COLUMN SaleDate