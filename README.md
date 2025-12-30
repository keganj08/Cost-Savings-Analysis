# Cost-Savings-Analysis
A SAS cost savings analysis from raw purchase data in CSV form.

This project analyzes purchasing data to identify potential cost savings by comparing previous purchase prices with offered pricing. The SAS program imports raw data, cleans and formats fields, removes invalid records, calculates savings by SKU, and produces summary tables and visualizations.

##Contents
- cost_savings.sas — Main SAS script
- data/ — Folder containing the raw CSV input file
- Raw Purchase Data.csv — Subset of source dataset used in the analysis

##How to Run
- Clone or download this repository
- Open cost_savings.sas in SAS or SAS Studio
- Ensure the filename path points to the data folder
- Run the script to generate cleaned data, summary tables, and plots

##Output
- Cleaned dataset of purchased items with corresponding internal offerings
- Total savings calculated per SKU
- Bar chart of savings by SKU
- Bubble plot showing savings impact of price difference vs. quantity
