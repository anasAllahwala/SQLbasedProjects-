/*
Cleaning data in SQL Queries
*/

----------------------------------------------------------------------------------------------------------
select * FROM [PortfolioProjects ].[dbo].[NashvilleHousing]

-- Standardise Date Format 

Select SaleDate from [PortfolioProjects ].[dbo].[NashvilleHousing]
-- The above statement simple gets us the column of sale Date which is in the format I would ever *ucking want, what the hell is with these zeros in the
--end im gonna rid of them right now!

select SaleDate, convert(Date,(SaleDate))
from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- so yeah the above statement query helps me get rid of those annoying time stamps so imma update that shizz

Update [PortfolioProjects ].[dbo].[NashvilleHousing]
set SaleDate = convert(Date,SaleDate)

--somehow the above query didnt bring any desired results like it didnt chnage the way date were being displayed when we run the date query again

-- so I will add a new column as SaleDate1 to have the date in my desired format 

alter table [PortfolioProjects ].[dbo].[NashvilleHousing]
Add SaleDate1 Date 

update [PortfolioProjects ].[dbo].[NashvilleHousing]
set SaleDate1=convert(Date,SaleDate)

select SaleDate1 from [PortfolioProjects ].[dbo].[NashvilleHousing]

--Bingo, we have the new date column that shows the date in desired format, now lets replace the original one with this one 

update [PortfolioProjects ].[dbo].[NashvilleHousing]
set SaleDate=SaleDate1, SaleDate1=SaleDate

-- this thing didnt swap the columns; I wanted SaleDate to go in the end and SaleDate1 to replace SaleDate with it at column no 5. Lets try something else

alter table [PortfolioProjects ].[dbo].[NashvilleHousing]
drop column SaleDate 

select * from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- hmmm so we have removed the original SaleDate column and now need to bring the SaleDate1 to its place and then rename it 
-- couldnt figure it out so I will do it manually; I will go to the designs and bring the SaleDate1 back in position

select * from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- Bingo! now we will change the name of the column from SaleDate1 to SaleDate
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--2)
--Populate property address
select PropertyAddress from [PortfolioProjects ].[dbo].[NashvilleHousing]

--lets see if there are null values 
select PropertyAddress from [PortfolioProjects ].[dbo].[NashvilleHousing]
where PropertyAddress is null

-- yes there are so lets see the other pieces of info where property address is null 

Select * from [PortfolioProjects ].[dbo].[NashvilleHousing]
where PropertyAddress is null 

--its kinda weird that Property Address is null in these few rows; owners address can hget changed but the address of property itself isnt going to be changed like 
-- its very rare so lets populate it and for that we need to d a little bit research:

select * from [PortfolioProjects ].[dbo].[NashvilleHousing]
order by ParcelID

-- results show that every unique address Property Address has a unique ParcelID and if the parcelIDs are repeated, then the same Property Address
-- will also be repeated. Look at row number 44 and 45, same ParcelID and same Property Address. and then look ath row 61 and row 62. So lets do a self join
-- to poluate the Property Address where its null. Basically what Im going to do is is to do a self join and we need to compare; if ParcelID 2 = XYZ Property Address
-- then this should be the case anywhere the ParcelID is 2 and Property Address is null. so without further ado, lets do it

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress, b.PropertyAddress) as Propee
from [PortfolioProjects ].[dbo].[NashvilleHousing] a
Join [PortfolioProjects ].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null 

-- so the above query has given us all the rows where Property Address is null against ParcelID and the "Isnull" function simply helped us to populate the rows 
--Propee when it was null so lets finalise it

Update a 
set PropertyAddress = Isnull(a.PropertyAddress,b.PropertyAddress)
From [PortfolioProjects ].[dbo].[NashvilleHousing] a
join [PortfolioProjects ].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null



--3) Breaking out Address into individual  columns(Address, City, State)

Select PropertyAddress from 
[PortfolioProjects ].[dbo].[NashvilleHousing]

-- okay so we dont have States, just the address and the city so lets do 2 columns so lets use the substring functionn 

select 
SUBSTRING(PropertyAddress, 1, 8) from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- so the problem with just using sub string is the addresses are of different lengths and we cant give one specific number/position as argument to the function
-- substring to tell it where to conclude the substring so we will use a function within a function i.e. charindex within substring

select 
substring(PropertyAddress,1,charindex(',', PropertyAddress))
from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- so the above query has kinda worked but we dont want comma in the end so lets just subtract 1 from the position charindex would retunr. Please note that charindex 
-- returns a number, not a string 

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- so the comma is no more :( (xd)
-- so lets extract city as well and make it a seperate column along with the address column

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City 
from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- so we need to add these two new columns in the table and update them 

alter table [PortfolioProjects ].[dbo].[NashvilleHousing]
add PropertySplitAddress Nvarchar(255);

update [PortfolioProjects ].[dbo].[NashvilleHousing]
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table [PortfolioProjects ].[dbo].[NashvilleHousing]
add PropertySplitCity Nvarchar(255)

update [PortfolioProjects ].[dbo].[NashvilleHousing]
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))


select * from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- so we have added the two columns at the end of the table, lets bring them back right next to original PropertyAddress column. I will use designs for that, no
--query shizz

--4) lets do the same for owner's address too

select OwnerAddress
from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- so we see that although property address didnt have State(just city and addrss), Owner's address does have State too so we will split the address into
-- three different columns: Address, City, State and for this we will first use substring method and then I will do it with another method too

select substring(OwnerAddress, 1, charindex(',', OwnerAddress)-1), 
 substring(OwnerAddress, charindex(',', OwnerAddress)+1, (len(OwnerAddress)-2)), right(OwnerAddress,charindex(',',OwnerAddress)) as State
from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- I dont know im making some mistake ig I have not been able to achive the result I required so lets just move to the different method 


-- Second Method(failry easy as comapred to substring method, no?)
select 
parsename(Replace(OwnerAddress, ',', '.'),3) as OwnerSplitAddress,
parsename(Replace(OwnerAddress, ',', '.'),2) as OwnerSplitCity,
parsename(Replace(OwnerAddress, ',', '.'),1) as OwnerSplitState
from [PortfolioProjects ].[dbo].[NashvilleHousing]

alter table [PortfolioProjects ].[dbo].[NashvilleHousing]
add OwnerSplitAddress nvarchar(255)

update [PortfolioProjects ].[dbo].[NashvilleHousing]
set OwnerSplitAddress = parsename(Replace(OwnerAddress, ',', '.'),3) 

alter table [PortfolioProjects ].[dbo].[NashvilleHousing]
add OwnerSplitCity nvarchar(255)

update [PortfolioProjects ].[dbo].[NashvilleHousing]
set OwnerSplitCity = parsename(Replace(OwnerAddress, ',', '.'),2) 

alter table [PortfolioProjects ].[dbo].[NashvilleHousing]
add OwnerSplitState nvarchar(255)

update [PortfolioProjects ].[dbo].[NashvilleHousing]
set OwnerSplitState = parsename(Replace(OwnerAddress, ',','.'),1)


select * from [PortfolioProjects ].[dbo].[NashvilleHousing]

--we have got the three diffefent columns to have splitted Owner Address. I will bring them back few positions close to Owner Address using designs options



-- 5) Change Y and N to Yes and No in "Sold as Vacant field

select SoldAsVacant, count(SoldAsVacant)
from [PortfolioProjects ].[dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2

-- okay so we can see that SoldAsVacant column has largely two responses i.e. 'Yes' and 'No" but at some instances we do have 'Y' and 'N' so it doesnt 
--really make sense to me honeslty that its not aligned so lets populate the 'Y's and 'N's with Yes and No

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End 
from [PortfolioProjects ].[dbo].[NashvilleHousing]

update [PortfolioProjects ].[dbo].[NashvilleHousing]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End 
from [PortfolioProjects ].[dbo].[NashvilleHousing]

-- 6) remove duplicates 

With RowNumCTE AS (
Select *, Row_Number() OVER(
Partition by ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order By
					UniqueID
					) row_num

from 
[PortfolioProjects ].[dbo].[NashvilleHousing]

)

select * from 
RowNumCTE
where row_num>1
order by PropertyAddress

-- so kinda 104 rows are there that are duplicate let get rid of them


With RowNumCTE AS (
Select *, Row_Number() OVER(
Partition by ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order By
					UniqueID
					) row_num

from 
[PortfolioProjects ].[dbo].[NashvilleHousing]

)

Delete from 
RowNumCTE
where row_num>1

















