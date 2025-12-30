/* COST SAVINGS ANALYSIS PROJECT */

* Assign file reference to CSV;
filename rawdata "data/Raw Purchase Data.csv";

/* Import data from CSV; Clean and format it */
data cost_savings_clean;
	infile rawdata dsd firstobs=2 truncover missover;
	
	* Input raw data from CSV;
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
