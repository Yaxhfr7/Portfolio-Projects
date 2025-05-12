-- View the Entire Data
SELECT *
FROM layoffs_staging2;

-- Max Values of Total Laid Off and Percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Filter Rows Where 100% Laid Off and Order by Funds Raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Sum of Total Laid Off by Company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Min and Max Dates
SELECT MIN(date), MAX(date)
FROM layoffs_staging2;

-- Sum of Total Laid Off by Country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- All Data (Again)
SELECT *
FROM layoffs_staging2;

-- Sum of Total Laid Off by Year
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 DESC;

-- Sum of Total Laid Off by Stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Average Percentage of Laid Off by Company
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Sum of Total Laid Off by Month
SELECT SUBSTRING(date, 1, 7) AS months, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date, 1, 7) IS NOT NULL
GROUP BY months
ORDER BY 1;

-- Rolling Total of Laid Off by Month
WITH rolling_total AS (
    SELECT SUBSTRING(date, 1, 7) AS months, SUM(total_laid_off) AS layoff
    FROM layoffs_staging2
    WHERE SUBSTRING(date, 1, 7) IS NOT NULL
    GROUP BY months
    ORDER BY 1
)
SELECT months, layoff, SUM(layoff) OVER (ORDER BY months) AS rolling_total
FROM rolling_total;

-- Sum of Total Laid Off by Country (Repeated)
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Ranking Companies by Layoffs by Year
WITH company_year (company, years, total_laid_off) AS (
    SELECT 
        company, 
        YEAR(date), 
        SUM(total_laid_off)
    FROM 
        layoffs_staging2
    GROUP BY 
        company, 
        YEAR(date)
),
company_year_rank AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM 
        company_year
    WHERE 
        years IS NOT NULL
)
SELECT *
FROM company_year_rank;
