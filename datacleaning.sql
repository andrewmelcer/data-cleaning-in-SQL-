--CREATE Database and Table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Nashville Housing Data for Data Cleaning](
    [unique_id] [numeric](18, 0) NOT NULL,
    [parcel_id] [nvarchar](50) NOT NULL,
    [land_use] [text] NOT NULL,
    [property_address] [nvarchar](50) NULL,
    [sale_date] [date] NOT NULL,
    [sale_price] [int] NOT NULL,
    [legal_reference] [nvarchar](50) NOT NULL,
    [sold_as_vacant] [nvarchar](50) NOT NULL,
    [owner_name] [nvarchar](100) NULL,
    [owner_address] [nvarchar](50) NULL,
    [acreage] [float] NULL,
    [tax_district] [text] NULL,
    [land_value] [int] NULL,
    [building_value] [int] NULL,
    [total_value] [int] NULL,
    [year_built] [smallint] NULL,
    [bedrooms] [tinyint] NULL,
    [full_bath] [tinyint] NULL,
    [half_bath] [tinyint] NULL,
    [property_address_split] [nvarchar](255) NULL,
    [city] [nvarchar](255) NULL,
    [state] [nvarchar](255) NULL,
    [owner_address_split] [nvarchar](255) NULL,
    [owner_city] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--Check table functions

SELECT *
FROM dbo.[Nashville Housing Data for Data Cleaning]

--Populate property address

SELECT *
FROM dbo.[Nashville Housing Data for Data Cleaning]
WHERE property_address is NULL

SELECT *
FROM dbo.[Nashville Housing Data for Data Cleaning]
--WHERE property_address is NULL
ORDER BY parcel_id

--SELF Join the table
SELECT *
FROM dbo.[Nashville Housing Data for Data Cleaning] a
JOIN dbo.[Nashville Housing Data for Data Cleaning] b
    on a.parcel_id = b.parcel_id
    AND a.unique_id<>b.unique_id

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address
FROM dbo.[Nashville Housing Data for Data Cleaning] a
JOIN dbo.[Nashville Housing Data for Data Cleaning] b
    on a.parcel_id = b.parcel_id
    AND a.unique_id<>b.unique_id
WHERE a.property_address is NULL

--USE IS NULL function

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address, ISNULL(a.property_address,b.property_address)
FROM dbo.[Nashville Housing Data for Data Cleaning] a
JOIN dbo.[Nashville Housing Data for Data Cleaning] b
    on a.parcel_id = b.parcel_id
    AND a.unique_id<>b.unique_id
WHERE a.property_address is NULL

--UPDATE table to add proper address

UPDATE a    
SET property_address = ISNULL(a.property_address,b.property_address)
FROM dbo.[Nashville Housing Data for Data Cleaning] a
JOIN dbo.[Nashville Housing Data for Data Cleaning] b
    on a.parcel_id = b.parcel_id
    AND a.unique_id<>b.unique_id
WHERE a.property_address is NULL

--Breaking out Address into individual columns(Address, City, State)

SELECT property_address
FROM dbo.[Nashville Housing Data for Data Cleaning]

--USE substring function

SELECT 
SUBSTRING(property_address, 1, CHARINDEX(',', property_address)-1) as Address,
SUBSTRING(property_address, CHARINDEX(',', property_address)+1, LEN(property_address)) as City
FROM dbo.[Nashville Housing Data for Data Cleaning]

--ADD the new columns 
ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD property_address_split NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET property_address_split  = SUBSTRING(property_address, 1, CHARINDEX(',', property_address)-1)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD city NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET city = SUBSTRING(property_address, CHARINDEX(',', property_address)+1, LEN(property_address))

SELECT property_address_split, city 
FROM dbo.[Nashville Housing Data for Data Cleaning]

SELECT * 
FROM [Nashville Housing Data for Data Cleaning]

--SPLIT State from Owner address

SELECT owner_address
FROM [Nashville Housing Data for Data Cleaning]

--USE PARSENAME function

SELECT 
PARSENAME(REPLACE(owner_address, ',','.') ,3),
PARSENAME(REPLACE(owner_address, ',','.') ,2),
PARSENAME(REPLACE(owner_address, ',','.') ,1) as state
FROM dbo.[Nashville Housing Data for Data Cleaning]

--UPDATE table with new split information from above

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD state NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET state = PARSENAME(REPLACE(owner_address, ',','.') ,1)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD owner_address_split NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET owner_address_split = PARSENAME(REPLACE(owner_address, ',','.') ,3)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD owner_city NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET owner_city = PARSENAME(REPLACE(owner_address, ',','.') ,2)

SELECT *
FROM dbo.[Nashville Housing Data for Data Cleaning]

--CHANGE Y and N to Yes and No in sold_as_vacant field

SELECT DISTINCT(sold_as_vacant), COUNT(sold_as_vacant)
FROM dbo.[Nashville Housing Data for Data Cleaning]
GROUP BY sold_as_vacant
ORDER BY 2

SELECT (sold_as_vacant),
    CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
    WHEN sold_as_vacant = 'N' THEN 'No'
    ELSE sold_as_vacant
    END as sold_as_vacant_new
FROM dbo.[Nashville Housing Data for Data Cleaning]

UPDATE dbo.[Nashville Housing Data for Data Cleaning]
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
    WHEN sold_as_vacant = 'N' THEN 'No'
    ELSE sold_as_vacant
    END

SELECT * 
FROM dbo.[Nashville Housing Data for Data Cleaning]

--REMOVE Duplicates

WITH row_num_CTE as (
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY parcel_id,
        property_address,
        sale_price,
        sale_date,
        legal_reference
        ORDER BY
            unique_id
    ) row_num
FROM dbo.[Nashville Housing Data for Data Cleaning]
--ORDER BY parcel_id
)
DELETE
FROM row_num_CTE
WHERE row_num > 1

--DELETE Unused columns

SELECT *
FROM dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN owner_address, tax_district, property_address
