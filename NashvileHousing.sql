------------------------------------------------
-- Cleaning Data in SQL Queries 

select * from NashvilleHousing;

-- standardize Date Formate
select saledate,
       convert(Date, saleDate) 
from NashvilleHousing;

update NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate);

-----------------------------------------------------------------------
-- convertig column SalePrice Data type from varchar(50) to INT

alter table NashvilleHousing
add SalePriceConverted int;

update NashvilleHousing
set SalePriceConverted = try_cast(SalePrice as int);

alter table NashvilleHousing
drop column SalePrice; -- data type is varchar

alter table NashvilleHousing
add SalePrice int;  -- recreating column with data type int

update NashvilleHousing
set SalePrice = SalePriceConverted;

select SalePrice from NashvilleHousing;

alter table NashvilleHousing
drop column SalePriceConverted;

------------------------------------------------------------------
-- populate Property Address data that is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
on a.ParcelID = a.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
on a.ParcelID = a.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

--------------------------------------------------------------------------
-- Breaking out the Address into individual Columns (Address, City, State)

select 
   substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
   substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from NashvilleHousing ;

alter table NashvilleHousing
add PropertySplitAddress varchar(255);

alter table NashvilleHousing
add PropertySplitCity varchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

select * from NashvilleHousing

-- working on spliting the owner addres

select 
ownerAddress, PropertyAddress
from NashvilleHousing

select 
PARSENAME(replace(ownerAddress, ',', '.'), 3),
PARSENAME(replace(ownerAddress, ',', '.'), 2),
PARSENAME(replace(ownerAddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress varchar(255);

alter table NashvilleHousing
add OwnerSplitCity varchar(255);

alter table NashvilleHousing
add OwnerSplitState varchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(ownerAddress, ',', '.'), 3);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(ownerAddress, ',', '.'), 2);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(ownerAddress, ',', '.'), 1);

select * from NashvilleHousing ;

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
     case 
         when SoldAsVacant = 'Y' then 'Yes'
         when SoldAsVacant = 'N' then 'No'
         else SoldAsVacant
     end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
         when SoldAsVacant = 'Y' then 'Yes'
         when SoldAsVacant = 'N' then 'No'
         else SoldAsVacant
     end


-- Remove Duplicates
select * 
from (select *,
        ROW_NUMBER() over (
            partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
            order by UniqueID
            ) as row_numb
        from NashvilleHousing
        -- order by ParcelID
) as subqueryAlias
where row_numb > 1

-- using CTE
with duplicatesRows as (
select *,
        ROW_NUMBER() over (
            partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
            order by UniqueID
            ) as row_numb
        from NashvilleHousing
        -- order by ParcelID
)
delete from duplicatesRows  --delete instead of select to remove the dupplicates
where row_numb > 1


-- delete unused columns 

select * from NashvilleHousing;

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

alter table NashvilleHousing
drop column SaleDate
