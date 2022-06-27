
-- Data Cleaning For NashvilleDC
SELECT*
FROM NashvilleDC


-- Standardize Date Format 

SELECT
	saledate,
	CONVERT ( saledate, date ) 
FROM
	NashvilleDC 

UPDATE NashvilleDC 
	SET saledate = CONVERT ( saledate, date ) 
	

	
-- Populate Null Proporty Address Data by Finding the Match Between ParcelID and PropertyAddress 
SELECT
	* 
FROM
	NashvilleDC 
WHERE
	PropertyAddress IS NULL

		-- See if ParcelID marches PropertyAddress
	
SELECT
	ParcelID 
FROM
	NashvilleDC 
GROUP BY
	ParcelID 
HAVING
	COUNT( ParcelID ) > 1 
ORDER BY
	ParcelID 
SELECT
	ParcelID,
	PropertyAddress 
FROM
	NashvilleDC 
WHERE
	ParcelID = "015 14 0 060.00"

	-- Use ParcelID to fill the Null PropertyAddress 
SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	IFNULL( a.PropertyAddress, b.PropertyAddress ) 
FROM
	NashvilleDC AS a
	JOIN NashvilleDC AS b ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID 
WHERE
	a.PropertyAddress IS NULL
	
UPDATE NashvilleDC AS a
JOIN NashvilleDC AS b 
ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID 
SET a.Propertyaddress = IFNULL( a.PropertyAddress, b.PropertyAddress ) 
WHERE
	a.PropertyAddress IS NULL


-- Breaking Full Address Into Columns (Address, City, State)

SELECT SUBSTRING_INDEX(owneraddress,',',1) as Address,
SUBSTRING_INDEX((SUBSTRING_INDEX(owneraddress,',',2)),',',-1) as City,
SUBSTRING_INDEX(owneraddress,',',-1) as State 
FROM NashvilleDC

ALTER TABLE NashvilleDC
ADD OwnerSplitAddress VARCHAR(255)

UPDATE NashvilleDC
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1)

ALTER TABLE NashvilleDC
ADD OwnerSplitCity VARCHAR(255)

UPDATE NashvilleDC
SET OwnerSplitCity = SUBSTRING_INDEX((SUBSTRING_INDEX(OwnerAddress,',',2)),',',-1)

ALTER TABLE NashvilleDC
ADD OwnerSplitState VARCHAR(255)

UPDATE NashvilleDC
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1)


SELECT * 
FROM NashvilleDC

-- Replace 'N' and 'Y' to 'Yes' and 'NO' in SoldAsVacant Field 
SELECT DISTINCT
	( SoldAsVacant ),
	COUNT( SoldAsVacant ) 
FROM
	NashvilleDC 
GROUP BY
	SoldAsVacant

	-- Replacement Logic 
SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE
		SoldAsVacant
END AS updatedSoldAsVacant
 FROM NashvilleDC
	-- Update the Table 
UPDATE NashvilleDC
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE
		SoldAsVacant
END

	-- Test the Replacement 
SELECT DISTINCT
	( SoldAsVacant ),
	COUNT( SoldAsVacant ) 
FROM
	NashvilleDC 
GROUP BY
	SoldAsVacant


-- Remove Duplicate ( Duplicates are defined by two or more rows have identical ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference.

	-- Check for Duplicates 
WITH Rownum_CTE AS (
SELECT
	*,
	ROW_NUMBER() OVER ( PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueid ) Row_numb
FROM
	NashvilleDC )

SELECT *
FROM Rownum_CTE 
WHERE Row_numb > 1

	-- Delete Duplicate 
WITH Rownum_CTE AS (
SELECT
	*,
	ROW_NUMBER() OVER ( PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueid ) Row_numb
FROM
	NashvilleDC )

DELETE ORG
FROM Rownum_CTE AS CTE 
INNER JOIN NashvilleDC AS Org
ON CTE.UniqueID = Org.UniqueID
WHERE Row_numb > 1


-- Delete Unused Columns, Drop full Address Columns

SELECT
	* 
FROM
	NashvilleDC 
ALTER TABLE NashvilleDC 
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress



-- Null Values needs to be Further Explored 

SELECT UniqueID
FROM NashvilleDC
WHERE OwnerName IS null AND OwnerSplitAddress IS NULL AND Acreage IS NULL AND TotalValue IS NULL





	
	
	
	
	
	
	

