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

submission/figures/fig1_men_vs_women.pdf : code/plot_men_vs_women.R\
data/processed/casual_sex_sim.csv
	code/plot_men_vs_women.R

submission/figures/fig2_hetero_vs_gay_men.pdf : code/plot_hetero_vs_gay_men.R\
data/processed/casual_sex_sim.csv
	code/plot_hetero_vs_gay_men.R

submission/manuscript.pdf : submission/manuscript.Rmd\
data/processed/des_and_test_result.csv\
data/processed/compare_hetero_gay_men.csv\
submission/figures/fig1_men_vs_women.pdf\
submission/figures/fig2_hetero_vs_gay_men.pdf\
submission/reference.bib
	R -e "rmarkdown::render('submission/manuscript.Rmd')"
