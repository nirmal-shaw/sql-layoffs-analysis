-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2
;


-- Data range in terms of date is : 2020-03-11 to 2023-03-06

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Companies that went completely under (100% layoffs), sorted by how much funding they raised
-- Insight: Even well-funded companies like Britishvolt and Quibi shut down completely

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Which country had the largest layoffs altogether?
-- Insight: United states had the highest layoffs with 256559 people total laid off, followed by India with 35993 people total laid off

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Which company had the largest layoffs altogether?
-- Insight: Amazon had the highest layoffs with 18150 people laid off,  followed by Google with 12000 people laid off

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Year wise total layoffs

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


-- Month wise total laid off

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


-- Stage wise total layoffs

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Average percentage layoffs grouped by company

SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


-- Cumulative total of layoffs month wise

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`,total_off, SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;



-- Which companies were top 3 worst affected each year?
-- Insight: Uber, Booking.com & Groupon are the top 3 companies that were worstly affected

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC ) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;

-- Which industries were hit the hardest?
-- Insight: Consumer industry with 45182 layoffs is the highest one 

SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;

-- Which single dates had most layoffs?
-- Insight: Worst layoff date was 2023-01-04 with 16171 layoffs in that single day

SELECT `date`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `date`
ORDER BY 2 desc;

-- Which funding stage companies laid off the most?
-- Insight: 382 companies have laid off 204,132 people during the Post-IPO stage
-- Despite having lowest avg percentage (0.16), they have highest total
-- This means Post-IPO companies are large enough to survive even after laying off massively

SELECT stage,
	COUNT(company) AS num_of_companies,
	SUM(total_laid_off) AS total_laid_off,
    ROUND(AVG(percentage_laid_off), 2) avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY 3 DESC
;

-- Companies that laid off people more than once
-- Insight: Companies like Loft, Swiggy & Uber laid off more than 4 times

SELECT company,
	COUNT(total_laid_off) AS times_laid_off,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY 2 desc
;

-- Which comapnies were top 3 worst affected each year?
-- Insight: Transportation and Travel dominated 2020 layoffs due to COVID 19 Pandemic
-- Consumer industry appears consistently across all years showing prolonged struggle
-- 2023 saw the largest single industry layoffs with 28,512 in the Other category

WITH Industry_Year (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), Industry_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE ranking <= 3
;

-- How did layoffs change over the year?
-- Insight: In 2022 the layoffs were increased drastically
SELECT 
	YEAR(`date`) AS 'year',
	SUM(total_laid_off) AS total_laid_off,
	LAG(SUM(total_laid_off)) OVER (ORDER BY YEAR(`date`)) AS previous_year,
	SUM(total_laid_off) - LAG(SUM(total_laid_off)) OVER (ORDER BY YEAR(`date`)) AS year_over_year_change
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 1;


-- Companies that laid off most relative to their funding
-- Insight: High layoffs despite high funding indicated poor management
-- Amazon had raised 108 millions but still laid off above 15000 peoples indicating poor management
-- Better.com & Carvana had raised 905 millions  & 1600 millions respectively and laid off people close to 4000, indicating good management
-- Microsoft raised only 1 million and laid off 10000 people which is fair
-- Ericsson has raised 663 millions but still laid off 8500 peoples whic indicates poor management

SELECT company,
	funds_raised_millions,
    SUM(total_laid_off) AS total_laid_off,
    ROUND(SUM(total_laid_off)/funds_raised_millions,2) AS layoffs_per_million
FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL AND total_laid_off IS NOT NULL
GROUP BY company, funds_raised_millions
ORDER BY 4 desc
;

-- Number of companies that completely shut down vs companies still operating

SELECT 
	CASE 
	WHEN percentage_laid_off = 1 THEN 'Shut Down'
    ELSE 'Still Operating'
END AS company_status,
	COUNT(company) AS num_of_companies,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY company_status;


-- Companies that are still operating
-- Companies like Google, Meta, Microsoft & Amazon are still operating even with very high total laid off as thier perentage laid off in proportion to their total workforce is very low

WITH company_status1 (company, percentage_laid_off, company_num, total_laid_off, Company_Status) AS
(
SELECT company, percentage_laid_off,
	COUNT(company)  num_of_companies, 
	SUM(total_laid_off) total_laid_off ,
CASE
	WHEN percentage_laid_off = 1 THEN 'Shut down'
    ELSE 'Still operating'
    END AS 'Company_Status'
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY company, percentage_laid_off
)
SELECT *
FROM company_status1
WHERE percentage_laid_off <1 AND total_laid_off IS NOT NULL
ORDER BY 4 desc
;

-- Companines that were completely shut down
-- Companies like Katerra & Butler Hospitality have been shut down due to high layoffs

WITH company_status1 (company, percentage_laid_off, company_num, total_laid_off, Company_Status) AS
(
SELECT company, percentage_laid_off,
	COUNT(company)  num_of_companies, 
	SUM(total_laid_off) total_laid_off ,
CASE
	WHEN percentage_laid_off = 1 THEN 'Shut down'
    ELSE 'Still operating'
    END AS 'Company_Status'
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY company, percentage_laid_off
)
SELECT *
FROM company_status1
WHERE percentage_laid_off >=1 AND total_laid_off IS NOT NULL
ORDER BY 4 desc
;



































