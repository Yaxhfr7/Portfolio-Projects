-- Data cleaning

	-- Remove Duplicates
	-- Standardize the Data
	-- Null Values or Blank Values
	-- Remove Any Unnecessary Columns OR ROWS

-- Step 1: View the original layoffs data
SELECT * FROM layoffs;

-- Step 2: Create a staging table with the same structure as 'layoffs'
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Step 3: Copy all data from 'layoffs' into 'layoffs_staging'
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Step 4: Add row numbers to identify duplicate rows based on all main columns
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Step 5: Use CTE to isolate duplicates (row_num > 1 means duplicate rows)
WITH duplicate_cte AS (
  SELECT *,
  ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
  FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

-- Step 6: Create a new cleaned table with an extra column to store row numbers
CREATE TABLE `layoffs_staging2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 7: Insert data into 'layoffs_staging2' with row numbers for duplicate handling
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Step 8: Delete all duplicate rows from 'layoffs_staging2' (keeping only row_num = 1)
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Step 9: View the final cleaned data
SELECT * FROM layoffs_staging2;



-- Standardizing data:

-- 1. Remove extra spaces from company names
SELECT TRIM(company), COMPANY
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- 2. Standardize industry name (e.g., CRYPTO, Crypto Trading) to just 'CRYPTO'
SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET INDUSTRY = 'CRYPTO'
WHERE INDUSTRY LIKE 'CRYPTO%';

-- 3. Clean country name 'United States.' to 'United States' by removing the dot
SELECT DISTINCT(COUNTRY), TRIM(TRAILING '.' FROM COUNTRY)
FROM layoffs_staging2
WHERE COUNTRY LIKE 'UNITED STATES.%';

UPDATE layoffs_staging2
SET COUNTRY = TRIM(TRAILING '.' FROM COUNTRY)
WHERE COUNTRY LIKE 'UNITED STATES%';

-- 4. Convert 'date' column from text to proper date format and change its datatype to DATE
SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- Working with NULL values:

-- 1. Check rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND
PERCENTAGE_LAID_OFF IS NULL;

-- 2. Check where industry is missing (NULL or empty string)
SELECT *
FROM layoffs_staging2
WHERE INDUSTRY IS NULL
OR INDUSTRY = '';

-- 3. Look at a specific company (example: Airbnb)
SELECT *
FROM layoffs_staging2
WHERE COMPANY = 'AIRBNB';

-- 4. Replace empty strings in industry column with NULL
UPDATE layoffs_staging2
SET INDUSTRY = NULL
WHERE INDUSTRY = '';

-- 5. Fill missing industry using values from other rows with the same company name
SELECT *
FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
  ON T1.COMPANY = T2.COMPANY
WHERE T1.INDUSTRY IS NULL AND T2.INDUSTRY IS NOT NULL;

UPDATE layoffs_staging2 T1
JOIN layoffs_staging2 T2
  ON T1.COMPANY = T2.COMPANY
SET T1.INDUSTRY = T2.INDUSTRY
WHERE T1.INDUSTRY IS NULL AND T2.INDUSTRY IS NOT NULL;

-- 6. Delete rows where both layoff values are still NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND
PERCENTAGE_LAID_OFF IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND
PERCENTAGE_LAID_OFF IS NULL;

-- 7. Drop the helper column ROW_NUM (if it exists)
ALTER TABLE layoffs_staging2
DROP COLUMN ROW_NUM;

