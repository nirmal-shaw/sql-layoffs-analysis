![SQL Analysis Preview](Sql_Project_Preview.png)

# World Layoffs — SQL Analysis Project

## The Story Behind This Project

Between 2020 and 2023, the tech world went through one of its 
most turbulent periods. Companies that once seemed untouchable 
started laying off thousands of employees. I wanted to understand 
the story behind the numbers — who got hit hardest, when, and why.

This project uses MySQL to clean a messy real-world dataset and 
then dig into the patterns hidden inside it.

---

## What I Did

### Part 1 — Data Cleaning
Raw data is never clean. Before any analysis could happen, I had to:

- Remove duplicate records using ROW_NUMBER() and CTEs
- Fix inconsistent values — "Crypto%" becoming "Crypto", 
  "United States." becoming "United States"
- Convert dates from plain text into proper DATE format
- Fill missing industry values using a self JOIN
- Remove rows where both key columns were completely empty

### Part 2 — Exploratory Data Analysis
Once the data was clean, I started asking real business questions:

- Which companies and industries suffered the most?
- When did layoffs peak — and by how much?
- Which funding stage had th most layoffs?
- Which companies laid off people multiple times?
- Did having more funding protect companies from layoffs?
- Which companies completely shut down vs survived?

---

## Key Insights I Found

- **United States** had by far the highest layoffs globally.
- **Consumer and Retail** industries were consistently 
  the worst affected industries across all years.
- **2022 saw a dramatic spike** in layoffs compared to 2021 .
- **High funding didn't guarantee survival** — companies like 
  Ericsson raised $663M but still laid off 8,500 people.
- **Companies like Uber, Swiggy and Loft** went through 
  more than 4 rounds of layoffs showing continuos financial distress.
- **Post-IPO companies** laid off the most people in absolute 
  numbers — 204,132 across 382 companies.
- Even well-funded startups completely shut down — 
  Katerra and Butler Hospitality are among them.

---

## SQL Concepts Used

- **CTEs** in Duplicate records removal & ranking queries.
- **Window Functions** in ROW_NUMBER, DENSE_RANK, LAG, SUM OVER.
- **CASE WHEN** in Company status classification.
- **Self JOIN** in Filling NULL industry values.
- **STR_TO_DATE** in Date's data type conversion.
- **SUBSTRING** in Monthly trend extraction.
- **Aggregate Functions** in SUM, COUNT, AVG, MAX, MIN.

---

## Files in This Repository

`layoffs.csv` - Raw dataset — original messy data 
`Data_Cleaning.sql`  - Full cleaning process with comments 
`Exploratory_Data_Analysis.sql` - All analysis queries with insights 

---

## Tools Used
- MySQL
- MySQL Workbench

---

## Dataset Source
Alex the Analyst — World Layoffs Dataset (Kaggle)

---

## Author
**Nirmal Shaw**
Aspiring Data Analyst · BBA Honours · West Bengal

- 🌐 Portfolio: [nirmal-shaw.github.io](https://nirmal-shaw.github.io)
- 💼 LinkedIn: [linkedin.com/in/nirmal-shaw](https://linkedin.com/in/nirmal-shaw)
