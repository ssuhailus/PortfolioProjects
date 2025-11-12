--Cleaning Data in SQL queries


Select *
From PortfolioProject.dbo.NashvilleHousing

--Standardize SaleDate

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SaleDate= CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted= CONVERT(Date, SaleDate)


--Populate Property Address data

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

Select *
From PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID= b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Now making a new column of address for the null values
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID= b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Now making the null values fill
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID= b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out address into indiviual column (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--Now that we have separate the address, we can add column

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Now Lets see

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--There is another way to do the same things, Separating OwnerAddress now

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress  = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,3) 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.') ,1)


--Change Y and N to Yes and No in 'Sold as Vacnt' field

Select DISTINCT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing


Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldasVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END

--Remove Duplicates

WITH RowNumCTE AS(
Select * ,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                  UniqueID
                  ) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select *
FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Now to delete

WITH RowNumCTE AS(
Select * ,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                  UniqueID
                  ) row_num

From PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
Where row_num > 1


--Delete Unused Column

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate












