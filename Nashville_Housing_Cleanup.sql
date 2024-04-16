-- Select Data

SELECT TOP 1000 * FROM Portfolio_Project..NashvilleHousing
-------------------------------------------------------------------------
-- Removing time from SaleDate column by converting it to Date type.

ALTER TABLE Portfolio_Project..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Portfolio_Project..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 
-------------------------------------------------------------------------------
--Filling in NULL property addresses by matching rows with the same ParcelID


-- Populated Property Address Data (By coping the address from rows with same ParcelID)

-- Using Join, we match each NULL property address with the row that does have the property address. 
-- Checking to see if ISNULL will return the correct value that will be updated
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..NashvilleHousing a 
JOIN Portfolio_Project..NashvilleHousing b
-- If ParcelID is the same (same property) but UniqueID is different (different sale row) populate address. 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Updating all NULL values with the not-null property address
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..NashvilleHousing a 
JOIN Portfolio_Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

----------------------------------------------------------------------------------------

--Splitting Property Address into separate Address and City Columns

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing

-- PropertyAddress is separated by commas 
--Using charcter index to search for specific value
-- Fetches everything before Comma. (Starts at 1st value (1).
-- CharIndex is a number (how many charcters until we reach comma, so minus 1 removes comma). 

-- The comma acts as a bookmark in the string, which allows us to navigate to the left and right of it.
SELECT 
-- Select BEFORE Comma 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) - 1) as Address,
-- Select AFTER Comma
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM Portfolio_Project..NashvilleHousing

-- Creating 2 new columns to hold the Address and City Values.

--Adding Column and Updating Values for PropertyAddress Address
ALTER TABLE Portfolio_Project..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Portfolio_Project..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) - 1) 

--Adding Column and Updating Values for PropertyAddress City
ALTER TABLE Portfolio_Project..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE Portfolio_Project..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

-- Verifying that values have been split correctly
SELECT PropertyAddress,PropertySplitAddress, PropertySplitCity FROM Portfolio_Project..NashvilleHousing

-------------------------------------------------------------------------------------
-- Splitting OwnerAddress into separate Address, City and State columns

SELECT OwnerAddress
FROM Portfolio_Project..NashvilleHousing

-- Using ParseName for delimited values. (need to convert ',' separator to '.' for ParseName to work.

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio_Project..NashvilleHousing

-- Creating and updating values for split OwnerAddress Address column
ALTER TABLE Portfolio_Project..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio_Project..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

-- Creating and updating values for split OwnerAddress City column
ALTER TABLE Portfolio_Project..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Portfolio_Project..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

-- Creating and updating values for split OwnerAddress State column
ALTER TABLE Portfolio_Project..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE Portfolio_Project..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Portfolio_Project..NashvilleHousing

------------------------------------------------------------
--Update Y and N to Yes and No in "SoldAsVacant" field

--Checking for ibpout variations in 'Sold as Vacant' column, which will be used to verify changes.
SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant) 
FROM Portfolio_Project..NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2


-- Updating 'Y' to 'Yes'
UPDATE Portfolio_Project..NashvilleHousing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y'

-- Updating 'N' to 'No'
UPDATE Portfolio_Project..NashvilleHousing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N'


-- Using Case to check which values need to be updated

SELECT SoldAsVacant
	, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		   WHEN SoldAsVacant = 'N' THEN 'No'
		   ELSE SoldAsVacant
		   END
FROM Portfolio_Project..NashvilleHousing

-- Using Case to Update

UPDATE Portfolio_Project..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		   WHEN SoldAsVacant = 'N' THEN 'No'
		   ELSE SoldAsVacant
		   END
---------------------------------------------------------
--Remove Duplicates

-- CTE using windows functions to find duplicates
--Using Row Number (Instead of Rank) to identify duplicate rowx
--Partion by will take all the values

-- When row num is greater than 1, indicates a duplicate has occured.
-- The duplicate row will get deleted.

-- Assigning CTE as a temp table.
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num

FROM Portfolio_Project..NashvilleHousing
--ORDER BY ParcelID
)

--Checking if any duplicates exist
SELECT *
FROM RowNumCTE
WHERE row_num > 1



-- Deleting duplicate from table
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

-------------------------------------------------------------------
-- Deleting Unused Columns

--Remove old SalesDate,PropertyAddress and OwnerAddress columns after transformations.

SELECT * 
FROM Portfolio_Project..NashvilleHousing

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
