/*

Cleaning Data in SQL querries

*/
select *
from [PortfolioProject].[dbo].[NashvilleHousing]

................................................................................................................

--standardize date format 

select SaleDateconverted, CONVERT(Date, SaleDate)
from [PortfolioProject].[dbo].[NashvilleHousing]

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET  SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD SaleDateconverted Date;

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET  SaleDateconverted = CONVERT(Date, SaleDate)


.......................................................................................

--populate Property address data

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress is null 

-----------------------------------------------------------------------------------
----Breaking out address into individual column (Address, City, State)
SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD PropertySplitAddress nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD PropertySplitCity nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select *
FROM [PortfolioProject].[dbo].[NashvilleHousing]

select OwnerAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing]

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD OwnerSplitAddress nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD OwnerSplitCity nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD OwnerSplitState nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select *
FROM [PortfolioProject].[dbo].[NashvilleHousing]

----------------------------------------------------------------------------------------------------------------
--change Y and N to Yes and No in the "sold as vacant" field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortfolioProject].[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2

select SoldAsVacant
,CASE When SoldAsVacant = 'Y' then 'Yes'
      When SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  END
FROM [PortfolioProject].[dbo].[NashvilleHousing]

update [PortfolioProject].[dbo].[NashvilleHousing]
set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
      When SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  END

-----------------------------------------------------------------------------------------------------------------
--Remove Duplicate
WITH RowNumCTE AS(
select *,
        ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		             PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
					 UniqueID
					 ) row_num

FROM [PortfolioProject].[dbo].[NashvilleHousing]
)
SELECT *
FROM RowNumCTE
where row_num>1
Order BY PropertyAddress

---------------------------------------------------------------------------------------------
--Delete unused columns 



select *
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
DROP COLUMN SaleDate