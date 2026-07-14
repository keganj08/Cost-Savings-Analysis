/*****************************************************************************
* Program Name: cost_savings_analysis.sas  (Jenner compatibility bundle)
*
* Purpose:      Analyzes vendor purchase data to identify cost savings
*               opportunities by comparing current purchase prices against
*               internal (IBPI) pricing. Quantifies potential savings and
*               presents data visualizations.
*
* Author:       Kegan Johnson
*
* Note:         This is the repository's Cost Savings Analysis.sas, adapted
*               only so it is self-contained for a hosted run: the external
*               CSV read (filename/infile) is replaced by an inline DATALINES
*               block holding a sample of the repository's own purchase data.
*               All analysis logic is unchanged.
*****************************************************************************/

/* Import data from inline sample; Clean and format it */
data cost_savings_clean;
	infile datalines dsd truncover missover;

	* Input raw data;
	input
		date_char :$10.
		sku :$20.
		item_desc :$120.
		quantity
		ext_quantity
		unit_price_char :$12.
		order_price_char :$12.
		order_price_char_duplicate :$12.
		po_number_char :$10.
		entered_date_char :$10.
		item_inventory_code_char :$20.
		internal_sku :$10.
		internal_item_desc :$50.
		internal_price_char :$12.
		unit_price_difference_char :$20.
		ttl_price_difference_char :$20.
		ttl_order_savings_char :$20.
		ttl_item_savings_char :$20.
	;

	* Flag invalid or missing internal SKUs;
    valid_sku = 1;
    if missing(internal_sku) or upcase(strip(internal_sku)) in ("N/A","NA","NULL") then valid_sku = 0;

	* Convert character-based price fields into numeric values for calculations;
	unit_price_num = input(compress(unit_price_char, '$ ,'), dollar12.2);
	format unit_price_num dollar12.2;

	order_price_num = input(compress(order_price_char, '$ ,'), dollar12.2);
	format order_price_num dollar12.2;

	internal_price_num = input(compress(internal_price_char, '$ ,'), dollar12.2);
	format internal_price_num dollar12.2;

	* Convert date data into numeric values with date format;
	if not missing(date_char) then
		date = input(strip(date_char), MMDDYY10.);
	format date MMDDYY10.;

	unit_price_difference_num = unit_price_num - internal_price_num;
	format unit_price_difference_num dollar12.2;

	* Drop redundant and unnecessary variables;
	drop date_char ext_quantity po_number_char entered_date_char item_inventory_code_char
			order_price_char_duplicate unit_price_char order_price_char unit_price_difference_char
			ttl_price_difference_char ttl_order_savings_char ttl_item_savings_char internal_price_char;
	datalines;
4/4/2024,B5L2967903,HP B5L29-67903 500GB Secure Hard Disk Drive (HDD) LaserJet Enterprise (LJ Ent) M506,1,1, $ 125.00 , $ 125.00 , $ 125.00 ,8660-0,4/4/2024,Parts,00037004,512GB SSD,$89.00,,,
9/13/2023,B5L2967903,HP B5L29-67903 500GB Secure Hard Disk Drive (HDD) LaserJet Enterprise (LJ Ent) M506,1,1, $ 125.00 , $ 125.00 , $ 125.00 ,5307-0,9/13/2023,Parts,00037004,512GB SSD,$89.00,,,
11/22/2023,B5L29A,HP 500GB Internal Hard Disk Drive,1,1, $ 417.64 , $ 417.64 , $ 417.64 ,6399-0,11/22/2023,Parts,00037004,512GB SSD,$89.00,,,
4/8/2024,NROLR2120FCZZ,ROLLER,2,2, $ 8.51 , $ 17.02 , $ 17.02 ,8695-0,4/8/2024,Parts,04012020,Separation Roller,$4.75,$3.76 ,$7.52 ,
3/27/2024,AR620RT,Paper Feed Roller Kit,2,2, $ 35.25 , $ 70.50 , $ 70.50 ,8532-0,3/27/2024,Parts,04036046,Tire Kit,$15.15,,,
4/17/2023,AR620RT,Paper Feed Roller Kit,2,2, $ 35.25 , $ 70.50 , $ 70.50 ,3176-0,4/17/2023,Parts,04036046,Tire Kit,$15.15,,,
5/15/2023,AR620RT,Paper Feed Roller Kit,2,2, $ 35.25 , $ 70.50 , $ 70.50 ,3472-0,5/15/2023,Parts,04036046,Tire Kit,$15.15,,,
1/29/2024,AR620RT,Paper Feed Roller Kit,2,2, $ 35.25 , $ 70.50 , $ 70.50 ,7371-0,1/29/2024,Parts,04036046,Tire Kit,$15.15,,,
1/29/2024,AR620RT,Paper Feed Roller Kit,1,1, $ 35.25 , $ 35.25 , $ 35.25 ,7392-0,1/29/2024,Parts,04036046,Tire Kit,$15.15,,,
6/16/2023,6LJ70598000,ODFC50,5,5, $ 34.29 , $ 171.45 , $ 171.45 ,3925-0,6/16/2023,Parts,05010031,Organic Drum,$18.95,$15.34 ,$76.70 ,
2/21/2024,CP0386B003AA,"Canon imageRUNNER 1025iF Compatible Black Toner Cartridge GPR-22 8,400 yield",1,1, $ 15.40 , $ 15.40 , $ 15.40 ,7887-0,2/21/2024,Supplies,01071038,GPR-22 Toner,$17.53,,,
6/23/2023,NBRGY0957FCZZ,BEARING MX5111N,2,2, $ 16.97 , $ 33.94 , $ 33.94 ,4016-0,6/23/2023,Parts,04001011,Lower Fuser Bearing,$12.68,$4.29 ,$8.58 ,
7/24/2023,NBRGY0957FCZZ,BEARING MX5111N,2,2, $ 16.97 , $ 33.94 , $ 33.94 ,4374-0,7/24/2023,Parts,04001011,Lower Fuser Bearing,$12.68,$4.29 ,$8.58 ,$17.16 
4/11/2024,NROLR1466FCZ1,PF separate roller and feed,12,12, $ 9.76 , $ 117.12 , $ 117.12 ,8792-0,4/11/2024,Parts,04012014,Separation Roller,$4.70,$5.06 ,$60.72 ,
6/6/2023,NROLR1466FCZ1,PF separate roller and feed,8,8, $ 9.76 , $ 78.08 , $ 78.08 ,3688-0,6/6/2023,Parts,04012014,Separation Roller,$4.70,$5.06 ,$40.48 ,
8/25/2023,NROLR1466FCZ1,PF separate roller and feed,7,7, $ 9.76 , $ 68.32 , $ 68.32 ,4949-0,8/25/2023,Parts,04012014,Separation Roller,$4.70,$5.06 ,$35.42 ,
11/16/2023,NROLR1466FCZ1,PF separate roller and feed,7,7, $ 9.76 , $ 68.32 , $ 68.32 ,6193-0,11/16/2023,Parts,04012014,Separation Roller,$4.70,$5.06 ,$35.42 ,
12/26/2023,NROLR1466FCZ1,PF separate roller and feed,8,8, $ 9.76 , $ 78.08 , $ 78.08 ,6762-0,12/26/2023,Parts,04012014,Separation Roller,$4.70,$5.06 ,$40.48 ,$212.52 
4/17/2023,NROLR1682FCZZ,Paper Feed Sep Roller,8,8, $ 35.50 , $ 284.00 , $ 284.00 ,3154-0,4/17/2023,Parts,04012016,Feed/Separation Roller,$6.60,$28.90 ,$231.12 ,
4/21/2023,NROLR1682FCZZ,Paper Feed Sep Roller,2,2, $ 35.50 , $ 71.00 , $ 71.00 ,3176-0,4/21/2023,Parts,04012016,Feed/Separation Roller,$6.60,$28.90 ,$57.80 ,
6/30/2023,NROLR1682FCZZ,Paper Feed Sep Roller,5,5, $ 35.50 , $ 177.50 , $ 177.50 ,4093-0,6/30/2023,Parts,04012016,Feed/Separation Roller,$6.60,$28.90 ,$144.50 ,
7/5/2023,NROLR1682FCZZ,Paper Feed Sep Roller,3,3, $ 35.50 , $ 106.50 , $ 106.50 ,4145-0,7/5/2023,Parts,04012016,Feed/Separation Roller,$6.60,$28.90 ,$86.70 ,
10/30/2023,NROLR1682FCZZ,Paper Feed Sep Roller,5,5, $ 35.50 , $ 177.50 , $ 177.50 ,5967-0,10/30/2023,Parts,04012016,Feed/Separation Roller,$6.60,$28.90 ,$144.50 ,$664.62 
6/6/2023,NROLR1467FCZ2,Pickup Roller,5,5, $ 9.76 , $ 48.80 , $ 48.80 ,3688-0,6/6/2023,Parts,04012017,Urethane Pick-up Roller,$6.60,$3.16 ,$15.80 ,
7/5/2023,NROLR1467FCZ2,Pickup Roller,6,6, $ 9.76 , $ 58.56 , $ 58.56 ,4145-0,7/5/2023,Parts,04012017,Urethane Pick-up Roller,$6.60,$3.16 ,$18.96 ,
9/29/2023,NROLR1467FCZ2,Pickup Roller,5,5, $ 9.76 , $ 48.80 , $ 48.80 ,5540-0,9/29/2023,Parts,04012017,Urethane Pick-up Roller,$6.60,$3.16 ,$15.80 ,
12/18/2023,NROLR1467FCZ2,Pickup Roller,5,5, $ 9.76 , $ 48.80 , $ 48.80 ,6723-0,12/18/2023,Parts,04012017,Urethane Pick-up Roller,$6.60,$3.16 ,$15.80 ,
12/26/2023,NROLR1467FCZ2,Pickup Roller,1,1, $ 9.76 , $ 9.76 , $ 9.76 ,6762-0,12/26/2023,Parts,04012017,Urethane Pick-up Roller,$6.60,$3.16 ,$3.16 ,
2/5/2024,NROLR1467FCZ2,Pickup Roller,5,5, $ 9.76 , $ 48.80 , $ 48.80 ,7463-0,2/5/2024,Parts,04012017,Urethane Pick-up Roller,$6.60,$3.16 ,$15.80 ,$85.32 
3/15/2024,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,8291-0,3/15/2024,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,
3/26/2024,NROLR2120FCZZ,ROLLER,5,5, $ 8.51 , $ 42.55 , $ 42.55 ,8461-0,3/26/2024,Parts,04012020,Separation Roller,$4.75,$3.76 ,$18.80 ,
4/4/2024,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,8637-0,4/4/2024,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,
5/1/2023,NROLR2120FCZZ,ROLLER,5,5, $ 8.51 , $ 42.55 , $ 42.55 ,3311-0,5/1/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$18.80 ,
6/23/2023,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,3995-0,6/23/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,
7/25/2023,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,4437-0,7/25/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,
8/24/2023,NROLR2120FCZZ,ROLLER,6,6, $ 8.51 , $ 51.06 , $ 51.06 ,4901-0,8/24/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$22.56 ,
10/12/2023,NROLR2120FCZZ,ROLLER,7,7, $ 8.51 , $ 59.57 , $ 59.57 ,5738-0,10/12/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$26.32 ,
11/14/2023,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,6224-0,11/14/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,
11/15/2023,NROLR2120FCZZ,ROLLER,1,1, $ 8.51 , $ 8.51 , $ 8.51 ,6258-0,11/15/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$3.76 ,
11/27/2023,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,6443-0,11/27/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,
12/15/2023,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,6676-0,12/15/2023,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,
2/8/2024,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,7545-0,2/8/2024,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,
2/20/2024,NROLR2120FCZZ,ROLLER,4,4, $ 8.51 , $ 34.04 , $ 34.04 ,7809-0,2/20/2024,Parts,04012020,Separation Roller,$4.75,$3.76 ,$15.04 ,$233.12 
3/12/2024,NROLR2125FCZZ,ROLLER,4,4, $ 9.76 , $ 39.04 , $ 39.04 ,8201-0,3/12/2024,Parts,04012021,Pickup Roller,$5.13,$4.63 ,$18.52 ,
3/15/2024,NROLR2125FCZZ,ROLLER,1,1, $ 9.76 , $ 9.76 , $ 9.76 ,8291-0,3/15/2024,Parts,04012021,Pickup Roller,$5.13,$4.63 ,$4.63 ,
;
run;

proc univariate data=cost_savings_clean noprint;
	var unit_price_num;
	output out=stats pctlpts=99 pctlpre=P;
run;

data cost_savings_no_outliers;
    if _n_=1 then set stats;
    set cost_savings_clean;
    if unit_price_num > P99 then delete; *Remove outlier prices in the top 1% of data;
run;


* Sort data by SKU;
proc sort data=cost_savings_no_outliers;
	by sku;
run;

* Calculate total quantites and total savings;
data cost_savings_totaled_collapsed;
	set cost_savings_no_outliers;
	if valid_sku = 1; * Remove data with no corresponding internal SKU;
	by sku;
	retain total_quantity total_order_price total_savings;
	if first.sku then do;
		total_quantity = 0;
		total_order_price = 0;
		total_savings = 0;
	end;

	total_quantity + quantity; * Track total quantity of all purchases for a given SKU;

	total_order_price + order_price_num; * Track total price of all purchases for a given SKU;
	format total_order_price dollar12.2;

	total_savings + unit_price_difference_num * quantity; * Track total savings for all purchases of a given SKU;
	format total_savings dollar12.2;

	if last.sku then do;
		if total_savings <= 0 then delete; * If an item would become more expensive, then drop it;
		output;
	end;

	keep sku internal_item_desc total_quantity unit_price_num internal_price_num unit_price_difference_num total_savings;
run;

proc sort data=cost_savings_totaled_collapsed
          out=cost_savings_sorted;
    by descending total_savings;
run;


data cost_savings_labeled; * Apply labels to variables;
	set cost_savings_sorted;
	label
		sku = 'Item SKU'
		internal_item_desc = 'Item'
		total_quantity = 'Quantity Purchased'
		unit_price_num = 'Current Purchase Price'
		internal_price_num = 'IBPI Price'
		unit_price_difference_num = 'Price Difference'
		total_savings = 'Savings'
	;
run;

* Print total cost savings by SKU in descending order;
proc print data=cost_savings_labeled label;
	var sku internal_item_desc total_quantity unit_price_num internal_price_num unit_price_difference_num total_savings;
	sum total_savings;
run;

* Display bar chart of total cost savings grouped by SKU;
proc sgplot data=cost_savings_sorted;
    hbar sku / response=total_savings datalabel;
    xaxis label="Total Savings" valuesformat=dollar12.;
    title "Savings by SKU";
run;

* Display bubble plot of savings from price difference vs. volume;
proc sgplot data=cost_savings_labeled;
    bubble x=total_quantity
           y=unit_price_difference_num
           size=total_savings;
    xaxis label="Total Quantity Purchased";
    yaxis label="Unit Price Difference (Current - Internal)"
          grid valuesformat=dollar12.;
    title "Drivers of Cost Savings: Price Difference vs Volume";
run;
