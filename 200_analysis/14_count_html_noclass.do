cd /home/co/git/RegulatoryComplexity_Public/200_analysis

forval i=1/16 {
insheet using results/html_noclass/cons-count_title_`i'.csv, delimiter(";") clear
	rename v1 key
	rename v2 category
	rename v3 count

	sort key count

	egen id_key = group(key)
	egen id_category = group(category)

	gen _one = 1

	bysort id_category: egen category_count = sum(count)
	bysort id_category: egen category_unique_count = sum(_one)

	bysort id_key: egen total_count = sum(count)
drop count _one

	bysort id_key: gen _duplicate = _N
	gsort - _duplicate + id_key

	keep category category_count category_unique_count
duplicates drop

	gsort category
	gen title = `i'
outsheet using results/html_noclass/category_cons_count_title_`i'.csv, delimiter(";") replace	
save results/html_noclass/category_cons_count_title_`i'.dta, replace
}

// join them together
use results/html_noclass/category_cons_count_title_1.dta, clear
forval i=2/16 {
	append using results/html_noclass/category_cons_count_title_`i'.dta
}
outsheet using results/html_noclass/category_cons_count_all_titles.csv, replace
	bysort category: egen tot_cat_count = total(category_count)
	bysort category: egen tot_cat_unique_count = total(category_unique_count)
keep category tot_*
duplicates drop
drop if category == "subprime crisis"  // weird bug
outsheet using results/html_noclass/category_cons_count_all_titles-total.csv, replace


//
// COMPUTE MOST OCCURRING WORDS
//
forval i=1/16 {
insheet using results/html_noclass/cons-count_title_`i'.csv, delimiter(";") clear
	rename v1 key
	rename v2 category
	rename v3 count

	save ./results/html_noclass/cons-count_title_`i'.dta, replace
}

use ./results/html_noclass/cons-count_title_1.dta, clear
forval i=2/16 {
append using ./results/html_noclass/cons-count_title_`i'.dta
}

	bysort key: egen total_count = sum(count)
	keep key category total_count

duplicates drop
	gsort + category - total_count
outsheet using ./results/html_noclass/category_cons_all_titles_most_frequent_keys.csv, replace