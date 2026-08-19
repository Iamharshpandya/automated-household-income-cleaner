# Automated-household-income-cleaner
  Automated data cleaning of the US Household Income dataset using SQL

## Overview
This project cleans the raw `ushouseholdincome` dataset (US Census-style household income data by state, county, and city) using MySQL. It identifies duplicate records, fixes typos, and standardizes text formatting, then copies the cleaned data into a new table. The process is automated to re-run whenever new data is inserted or on a yearly schedule, so the cleaned table stays up to date without manual intervention.

## Tools Used
- SQL (MySQL) 🐬

## What the cleaning does
- **Identifies duplicates** — uses `ROW_NUMBER()` partitioned by `id` to flag rows with duplicate `id` values for review
- **Fixes typos** — corrects known data entry errors (e.g. `georia` → `Georgia`, `CPD` → `CDP`, `Boroughs` → `Borough`)
- **Standardizes text formatting** — converts `County`, `City`, `Place`, and `State_Name` to uppercase for consistency
- **Copies cleaned data** — a stored procedure (`Copy_and_clean_Data`) creates a new `ushouseholdincome_cleaned` table (if it doesn't already exist) and copies the cleaned records into it, adding a `TimeStamp` column to track when each copy ran

## Automation
- **Event**: `run_data_cleaning` runs the cleaning procedure automatically once a year
- **Trigger**: `Transfer_clean_data` runs the cleaning procedure automatically after any new row is inserted into `ushouseholdincome`

## How to Run
1. Import `ushouseholdincome.csv` into a MySQL database
2. Run the SQL script (`data_cleaning.sql`) — this will identify duplicates, fix typos, standardize formatting, and create the `ushouseholdincome_cleaned` table
3. The event and trigger keep the cleaned table updated automatically going forward
