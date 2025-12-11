--DATA CLEANING

SELECT *
FROM World_layoffs.dbo.layoffs;

--Steps to be performed
--1.Remove Duplicates
--2.Standardize the Data
--3.Null Value or Blank Value
--4.Remove Any Columns


--Creating a copy
SELECT TOP 0 *
INTO World_layoffs.dbo.layoffstaging
FROM World_layoffs.dbo.layoffs;

SELECT *
FROM World_layoffs.dbo.layoffstaging;

INSERT World_layoffs.dbo.layoffstaging
SELECT *
FROM World_layoffs.dbo.layoffs 

--1.Removing Duplicates

--Finding dupliates
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, [date]
ORDER BY [date])
AS row_num
FROM World_layoffs.dbo.layoffstaging;

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, stage, country, percentage_laid_off, funds_raised_millions ,[date]
ORDER BY [date])
AS row_num
FROM World_layoffs.dbo.layoffstaging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

--Now checking whether it is correct
SELECT *
FROM World_layoffs.dbo.layoffstaging
WHERE company =  'Casper';


--Now deleting them
WITH duplicate_cte AS
(
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company, industry, total_laid_off, stage, country, percentage_laid_off, funds_raised_millions, [date]
               ORDER BY [date]
           ) AS row_num
    FROM World_layoffs.dbo.layoffstaging
)
DELETE FROM duplicate_cte
WHERE row_num > 1;

--2.Standardize the data
SELECT company, TRIM(company)
FROM World_layoffs.dbo.layoffstaging;

UPDATE World_layoffs.dbo.layoffstaging
SET company = TRIM(company);

SELECT DISTINCT industry
FROM World_layoffs.dbo.layoffstaging
ORDER by 1;

SELECT *
FROM World_layoffs.dbo.layoffstaging
WHERE industry LIKE 'Crypto%';

UPDATE World_layoffs.dbo.layoffstaging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM World_layoffs.dbo.layoffstaging
ORDER BY 1;

SELECT *
FROM World_layoffs.dbo.layoffstaging
WHERE country LIKE 'United States%'
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM World_layoffs.dbo.layoffstaging
ORDER BY 1;

UPDATE World_layoffs.dbo.layoffstaging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'; 

SELECT *
FROM World_layoffs.dbo.layoffstaging;

--3.NULL value or Blank Value

SELECT *
FROM World_layoffs.dbo.layoffstaging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE World_layoffs.dbo.layoffstaging
SET industry = NULL
WHERE industry = '';

Select *
FROM World_layoffs.dbo.layoffstaging
WHERE industry IS NULL
OR industry = '';

Select *
FROM World_layoffs.dbo.layoffstaging
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM World_layoffs.dbo.layoffstaging t1
JOIN World_layoffs.dbo.layoffstaging t2
  ON t1.company = t2.company
  AND t1.location = t2.location
  WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL


UPDATE  t1
SET t1.industry = t2.industry
FROM World_layoffs.dbo.layoffstaging t1
JOIN World_layoffs.dbo.layoffstaging t2
  ON t1.company = t2.company
 AND t1.location = t2.location
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

Select *
FROM World_layoffs.dbo.layoffstaging
WHERE company LIKE 'Bally%';


SELECT *
FROM World_layoffs.dbo.layoffstaging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE
FROM World_layoffs.dbo.layoffstaging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Step 1: Set invalid values to NULL
UPDATE World_layoffs.dbo.layoffstaging
SET percentage_laid_off = NULL
WHERE TRY_CAST(percentage_laid_off AS FLOAT) IS NULL;

-- Step 2: Convert the column to FLOAT
ALTER TABLE World_layoffs.dbo.layoffstaging
ALTER COLUMN percentage_laid_off FLOAT;


SELECT *
FROM World_layoffs.dbo.layoffstaging
WHERE percentage_laid_off IS NULL
   OR percentage_laid_off = 0
   OR percentage_laid_off < 0;


   SELECT *
FROM World_layoffs.dbo.layoffstaging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE
FROM World_layoffs.dbo.layoffstaging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM World_layoffs.dbo.layoffstaging


--Data is cleaned, there was no need to remove columns

--Now Exploratory Data Analysis

SELECT *
FROM World_layoffs.dbo.layoffstaging;

SELECT MAX(World_layoffs.dbo.layoffstaging.total_laid_off), MAX(World_layoffs.dbo.layoffstaging.percentage_laid_off)
FROM World_layoffs.dbo.layoffstaging;

SELECT *
FROM World_layoffs.dbo.layoffstaging
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY company
ORDER BY 2 DESC;

--Finding dates of when layoff started and ended
SELECT MIN(date), MAX(date)
FROM World_layoffs.dbo.layoffstaging;

SELECT industry, SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY industry
ORDER BY 2 DESC;

SELECT *
FROM World_layoffs.dbo.layoffstaging;

SELECT country, SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY YEAR(date)
ORDER BY 1 DESC;


SELECT stage, SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY stage
ORDER BY 2 DESC;


--Per Month how many people were laid off
SELECT FORMAT(date, 'yyyy-MM') AS MONTH, SUM(World_layoffs.dbo.layoffstaging.total_laid_off)
FROM World_layoffs.dbo.layoffstaging
WHERE FORMAT(date, 'yyyy-MM') IS NOT NULL
GROUP BY FORMAT(date, 'yyyy-MM')
ORDER BY 1 ASC;



--Creating a rolling total with respect to months
WITH Rolling_Total AS
(
SELECT FORMAT(date, 'yyyy-MM') AS MONTH, SUM(World_layoffs.dbo.layoffstaging.total_laid_off) AS total_off
FROM World_layoffs.dbo.layoffstaging
WHERE FORMAT(date, 'yyyy-MM') IS NOT NULL
GROUP BY FORMAT(date, 'yyyy-MM')

)
SELECT MONTH, total_off
,SUM(total_off) OVER(ORDER BY MONTH ASC ROWS UNBOUNDED PRECEDING) AS rolling_total
FROM Rolling_Total
ORDER BY MONTH ASC;

--Now looking at companies and how much were laying off per month

SELECT company, SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY company
ORDER BY 2 DESC;



--Looking at the total laid off by company and year
SELECT company, YEAR(date), SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY company, YEAR(date)
ORDER BY company ASC;

SELECT company, YEAR(date), SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY company, YEAR(date)
ORDER BY 3 DESC;



--Creating top 5 companies that laid off most people by year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(date), SUM(total_laid_off)
FROM World_layoffs.dbo.layoffstaging
GROUP BY company, YEAR(date)
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;




