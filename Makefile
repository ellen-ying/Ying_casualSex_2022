# rule:
# output : dependencies
# (tab) rule

data/processed/casual_sex_sim.csv : code/combine_raw.R\
data/raw/likelihoodD_standardD_He-table.csv\
data/raw/likelihoodD_standardS_He-table.csv\
data/raw/likelihoodS_standardD_He-table.csv\
data/raw/likelihoodS_standardS_He-table.csv\
data/raw/likelihoodD_standardD_Ho-table.csv\
data/raw/likelihoodD_standardS_Ho-table.csv\
data/raw/likelihoodS_standardD_Ho-table.csv\
data/raw/likelihoodS_standardS_Ho-table.csv
	$^

data/processed/des_and_test_result.csv : code/des_and_test_result.R\
data/processed/casual_sex_sim.csv
	$^

data/processed/compare_hetero_gay_men.csv : code/compare_hetero_gay_men.R\
data/processed/casual_sex_sim.csv
	$^

submission/manuscript.pdf : data/processed/des_and_test_result.csv
	R -e "rmarkdown::render('submission/manuscript.Rmd')"
