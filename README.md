# Cost-Savings-Analysis
A SAS cost savings analysis from raw purchase data in CSV form.

This SAS program analyzes a CSV of product purchase records and alternative equivalent product offerings, comparing pricing to identify potential cost savings. The program imports raw data, cleans, validates, and formats it, calculates savings by SKU, and produces summary tables and visualizations.

## Contents
- cost_savings.sas — Main SAS script
- data/ — Folder containing the raw CSV input file
- Raw Purchase Data.csv — Subset of source dataset used in the analysis

## How to Run
- Clone or download this repository
- Open cost_savings.sas in SAS or SAS Studio
- Ensure the filename path points to the data folder
- Run the script to generate cleaned data, summary tables, and plots

## Output
- Cleaned dataset of purchased items with corresponding internal offerings
- Total savings calculated per SKU
- Bar chart of savings by SKU
- Bubble plot showing savings impact of price difference vs. quantity
