use PortFolioProject

SELECT * FROM dbo.NashvilleHousing$

--Standardizing Date format

--SELECT CONVERT(Date,'2013-04-09 00:00:00.000') FROM dbo.NashvilleHousing$

ALTER TABLE NashvilleHousing$
ALTER COLUMN SaleDate Date;

--Populating data
SELECT  a.ParcelID,b.ParcelID,isnull(a.PropertyAddress,b.PropertyAddress)
 FROM dbo.NashvilleHousing$ a
 JOIN dbo.NashvilleHousing$  b on
a.ParcelID = b.ParcelID 
AND
a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing$ a
 JOIN dbo.NashvilleHousing$  b on
a.ParcelID = b.ParcelID 
AND
a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing$

--Splitting Columns
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address FROM
NashvilleHousing$

ALTER TABLE NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing$
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing$

ALTER TABLE NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Setting Y as Yes and N as No
SELECT SoldAsVacant,COUNT(SoldAsVacant) FROM NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing$

UPDATE NashvilleHousing$
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
		

--Removing Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing$
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Deleting Unused Columns
