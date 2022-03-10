
/*
Cleaning Data in SQL Queries

Cleaning techniques displayed: 
	Convert Data
    Alter Table -- add & drop columns
    Update Table
    Populate NULLS with known missing information
    Break up full address column into multiple columns
    Change data based on CASE function to match
    Remove duplicate data entries
*/

SELECT * 
FROM nashville_housing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(SaleDate, date)
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD SaleDateConverted date;

UPDATE nashville_housing
SET SaleDateConverted = CONVERT(SaleDate, date);

SELECT SaleDateConverted, CONVERT(SaleDate, date)
FROM nashville_housing;

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

UPDATE nashville_housing SET PropertyAddress = NULL WHERE PropertyAddress = '';
SELECT * FROM nashville_housing WHERE PropertyAddress IS NULL;

SELECT *
FROM nashville_housing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b 
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE nashville_housing a
JOIN nashville_housing b 
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

	-- Property Address Formatting

SELECT PropertyAddress
FROM nashville_housing;

SELECT 
	SUBSTRING_INDEX(PropertyAddress, ",", 1) AS Address,
	SUBSTRING_INDEX(PropertyAddress, ",", - 1) AS City
FROM nashville_housing;



-- alternate solution with same results but more customizable if needed

SELECT 
	SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1, LENGTH(PropertyAddress))  AS City
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress CHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress) - 1);

ALTER TABLE nashville_housing
ADD PropertySplitCity CHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1, LENGTH(PropertyAddress));



	-- Owner Address Formatting

SELECT OwnerAddress
FROM nashville_housing;

SELECT 
	OwnerAddress,
    SUBSTRING_INDEX(OwnerAddress,',', 1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2),',', - 1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 3),',', - 1)
FROM nashville_housing;



ALTER TABLE nashville_housing
ADD OwnerSplitAddress CHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',', 1);


ALTER TABLE nashville_housing
ADD OwnerSplitCity CHAR(255);

UPDATE nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2),',', - 1);

ALTER TABLE nashville_housing
ADD OwnerSplitState CHAR(255);

UPDATE nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 3),',', - 1);



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM nashville_housing;

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY 
		ParcelID) row_num
FROM nashville_housing
)


DELETE FROM nashville_housing 
USING nashville_housing 
JOIN RowNumCTE 
ON nashville_housing.UniqueID = RowNumCTE.UniqueID
WHERE RowNumCTE.row_num > 1; 


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate