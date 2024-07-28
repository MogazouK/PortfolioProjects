
select * from [dbo].[NashVilleHousingProject]


                                               /* cleaning Data in SQL Queries

                                               */


select * from [dbo].[NashVilleHousingProject]


-------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format


select saledate, convert(date, saledate)
from [dbo].[NashVilleHousingProject]

/*update [dbo].[NashVilleHousingProject]
set saledate= convert(date, saledate)      Did not work. adding a column SaledateConverted to alter table*/



alter table [dbo].[NashVilleHousingProject]   --1 Adding a column named SaleDateConverted
add SaleDateConverted date; 

update [dbo].[NashVilleHousingProject]
set SaleDateConverted = convert(date, saledate)  --- 2 Updating and setting SaledateConverted to original column and converting the original column

select SaleDateConverted
from [dbo].[NashVilleHousingProject]    ------ 3 Column updated and added with the date standardized to the desired format YYYY-MM-DD

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----Populate Property Address data

select *
from [dbo].[NashVilleHousingProject] 
where propertyAddress is   null           /* need a reference point to populate propertyaddress since the column cannot have null values.owner address might 
                                        but we can be certain that propertyAddress will be the same*/

 select * from 
 [dbo].[NashVilleHousingProject]   
 order by ParcelID                     /* --- Reference point is the ParceID since on order where the parcelID is the same, 100% PropertyAddress is also the same.
                                        so we populate the address where there's null values in the from the parcelID and vice versa */



 select A.ParcelID, A.propertyAddress, b.parcelId, b.PropertyAddress, ISNULL(a.propertyAddress, b.propertyAddress)
 from [dbo].[NashVilleHousingProject] a                                  ----- Need a self join 
 join   [dbo].[NashVilleHousingProject] b 
 on a.parcelID = b.parcelID
 and a.uniqueID <> b.uniqueID
where a.propertyAddress is NULL


update a 
set propertyAddress = ISNULL(a.propertyAddress, b.propertyAddress)
from [dbo].[NashVilleHousingProject] a                                 
 join   [dbo].[NashVilleHousingProject] b 
 on a.parcelID = b.parcelID
 and a.uniqueID <> b.uniqueID
 where  a.propertyAddress is NULL


 select *
from [dbo].[NashVilleHousingProject] 
where propertyAddress is not  null     ----Query comes back empty. removed null columns and populated them with matching addresses from ParcelID 
 
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-----Breaking out Address into Individual Columns (Address, City, State) (PropertyAddress) using a Substring 

select PropertyAddress
 from [dbo].[NashVilleHousingProject]


SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS ADDRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyAddress)) AS CityAddress
from [dbo].[NashVilleHousingProject]


ALTER TABLE [dbo].[NashVilleHousingProject]
ADD ADDRESS NVARCHAR(255);

UPDATE [dbo].[NashVilleHousingProject]
SET ADDRESS = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [dbo].[NashVilleHousingProject]
ADD CityAddress NVARCHAR(255);

UPDATE [dbo].[NashVilleHousingProject]
SET CityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyAddress))  

SELECT * FROM [dbo].[NashVilleHousingProject]     -----Worked. Address separated from city in separate columns 


---------------------------------------------------------------------------------------------------------------------------------------------------------------
-----Breaking out Address into Individual Columns (Address, City, State) (OwnerAddress)  using PARSENAME  (only works with period (.) delimiter)


SELECT OWNERADDRESS, 
Parsename ( replace (owneraddress, ',', '.'), 3) as OwnerSplitAddress,
Parsename ( replace (owneraddress, ',', '.'), 2) as OwnerSplitCity,
Parsename ( replace (owneraddress, ',', '.'), 1) as OwnerSplitState
 FROM [dbo].[NashVilleHousingProject]

 alter table  [dbo].[NashVilleHousingProject]
 add OwnerSplitAddress NVARCHAR(255);

update [dbo].[NashVilleHousingProject]
set OwnerSplitAddress = Parsename ( replace (owneraddress, ',', '.'), 3)

alter table [dbo].[NashVilleHousingProject]
add OwnerSplitCity NVARCHAR(255);

update [dbo].[NashVilleHousingProject]
set OwnerSplitCity = Parsename ( replace (owneraddress, ',', '.'), 2)

alter table [dbo].[NashVilleHousingProject]
add OwnerSplitState NVARCHAR(255);

update [dbo].[NashVilleHousingProject]
set OwnerSplitState = Parsename ( replace (owneraddress, ',', '.'), 1)

select * from [dbo].[NashVilleHousingProject]
--where OwnerSplitCity is not null 


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
----- Using case statement to Change Y and N to Yes and No in "Sold as Vacant" Field.

select DISTINCT soldasvacant 
from [dbo].[NashVilleHousingProject]    --- Table column  had 4 distinct responses with Y and N also included 


select soldasvacant, 
case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant ='N' then 'No'
     else soldasvacant
     end as soldasvacant
FROM [dbo].[NashVilleHousingProject]

update  [dbo].[NashVilleHousingProject]
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant ='N' then 'No'
     else soldasvacant
     end  
FROM [dbo].[NashVilleHousingProject]


select DISTINCT soldasvacant 
from [dbo].[NashVilleHousingProject]    ---- Table column now has only 2 distinct returns of NO and YES



-------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Removing duplicates 


with RowNumbCTE AS(
select*,
Row_number ()over(
    PARTITION by parcelID,
                 PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                order by 
                         uniqueID 
) Row_Num

from [dbo].[NashVilleHousingProject] 
--order by ParcelID 
)
select * 
 FROM RowNumbCTE 
 where Row_num =2
 --order by PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------------------------
---- Deleting unused columns 

Select * from [dbo].[NashVilleHousingProject] 


alter table [dbo].[NashVilleHousingProject] 
drop 
      column Owneraddress,
      propertyaddress,
     taxdistrict,
    saledate


    