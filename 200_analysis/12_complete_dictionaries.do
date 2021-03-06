cd /home/co/git/RegulatoryComplexity_Public/200_analysis

//
// PREPARE COUNTS AND RESIDUALS (=UNMATCHED WORDS)
//
insheet using results/html/results_all_titles.csv, delimiter(";") clear
	rename v1 key
	rename v2 category
	rename v3 count

	sort key count

	egen id_key = group(key)
	egen id_category = group(category)

	bysort id_category: egen category_count = sum(count)
	bysort id_key: egen total_count = sum(count)
	drop count
duplicates drop key, force

	bysort id_key: gen _duplicate = _N
	gsort - _duplicate + id_key

outsheet using results/html/master_dict.csv, delimiter(";") replace

keep category category_count
duplicates drop

	gsort - category_count
outsheet using results/html/category_count.csv, delimiter(";") replace


//
// CREATE RESULTS FOR INDIVIDUAL TITLES
//
forval i=1/16 {
insheet using results/html/results_title_`i'.csv, delimiter(";") clear
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
outsheet using results/html/category_count_title_`i'.csv, delimiter(";") replace	
}

//
// PREPARE FOR DICTIONARY MERGE LATER
//
forval i=1/16 {
insheet using results/html/results_title_`i'.csv, delimiter(";") clear
	rename v1 key
	rename v2 category
	drop v3
save results/html/results_title_`i'.dta, replace
}

use results/html/results_title_1.dta, clear
forval i=2/16 {
	append using results/html/results_title_`i'.dta
}
duplicates drop key, force

//
// CHECK RESIDUALS
//

// prepare master dict
insheet using ./results/Master_clean.csv, clear
	rename v1 missing_key 
	rename v2 category
save ./results/Master_clean.dta, replace

// prepare residuals + merge
insheet using results/html/residual_all_titles.txt, delimiter(" ") clear
	rename v1 missing_key
	duplicates drop
	gsort - missing_key
save results/html/residual_all_titles.dta, replace

merge 1:1 missing_key using ./results/Master_clean.dta
	drop if _merge == 2
	drop _merge 
outsheet using ./results/html/residuals_matched.csv, replace

//
// RUN THIS AFTER MANUALLY COMPLETING THE ABOVE FILE
//
insheet using ./results/html/residuals_matched+manually_completed.csv, clear
	rename v1 missing_key
	rename v2 category
	
	// counting how many entries haven't been found
// 	gen foo = 1 if category == ""
// 	gen total = sum(foo)
	// result: 1749
// 	drop foo total
save ./results/html/residuals_matched+manually_completed.dta, replace


//
// COMPLETE NEW MASTER DICTIONARY
//
use ./results/Master_clean.dta, clear
	rename missing_key key
	
forval i=1/16 {
	append using results/html/results_title_`i'.dta
}

duplicates drop
duplicates drop key, force
	sort category key
save ./results/Master_extended.dta, replace
outsheet using ./results/Master_extended.csv, delimiter(";") replace
