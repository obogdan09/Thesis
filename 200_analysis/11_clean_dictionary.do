cd /home/co/git/RegulatoryComplexity_Public/200_analysis


// the extended version includes the items from Words_2.xlsx sent by Jean-Edouard in mid 2017.
insheet using results/all_words_dictionary_extended.csv, clear

duplicates drop
duplicates drop v1, force

outsheet using results/all_words_dictionary_clean.csv, replace
