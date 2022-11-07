# rule:
# output : dependencies
# (tab) rule

README.md : README.Rmd
	R -e "rmarkdown::render('README.Rmd')"

data/processed/casual_sex_sim.csv : code/combine_raw.R\
data/raw/likelihoodD_standardD_He-table.csv\
data/raw/likelihoodD_standardS_He-table.csv\
data/raw/likelihoodS_standardD_He-table.csv\
data/raw/likelihoodS_standardS_He-table.csv\
data/raw/likelihoodD_standardD_Ho-table.csv\
data/raw/likelihoodD_standardS_Ho-table.csv\
data/raw/likelihoodS_standardD_Ho-table.csv\
data/raw/likelihoodS_standardS_Ho-table.csv
	$^ $@
	
data/processed/sa_casual_sex_sim.csv : code/combine_raw.R\
data/raw/sa_likelihoodD_standardD_He-table.csv\
data/raw/sa_likelihoodD_standardS_He-table.csv\
data/raw/sa_likelihoodS_standardD_He-table.csv\
data/raw/sa_likelihoodS_standardS_He-table.csv\
data/raw/sa_likelihoodD_standardD_Ho-table.csv\
data/raw/sa_likelihoodD_standardS_Ho-table.csv\
data/raw/sa_likelihoodS_standardD_Ho-table.csv\
data/raw/sa_likelihoodS_standardS_Ho-table.csv
	$^ $@

data/processed/des_and_test_result.csv : code/des_and_test_result.R\
data/processed/casual_sex_sim.csv
	$^ $@

data/processed/compare_hetero_gay_men.csv : code/compare_hetero_gay_men.R\
data/processed/casual_sex_sim.csv
	$^ $@

submission/figures/fig1_men_vs_women.* : code/plot_men_vs_women.R\
data/processed/casual_sex_sim.csv
	$^ submission/figures/fig1_men_vs_women.pdf submission/figures/fig1_men_vs_women.jpeg

submission/figures/fig2_men_vs_women_inpool.* : code/plot_men_vs_women_inpool.R\
data/processed/casual_sex_sim.csv
	$^ submission/figures/fig2_men_vs_women_inpool.pdf submission/figures/fig2_men_vs_women_inpool.jpeg

submission/figures/fig3_hetero_vs_gay_men.* : code/plot_hetero_vs_gay_men.R\
data/processed/casual_sex_sim.csv
	$^ submission/figures/fig3_hetero_vs_gay_men.pdf submission/figures/fig3_hetero_vs_gay_men.jpeg

submission/manuscript.pdf : submission/manuscript.Rmd\
data/processed/des_and_test_result.csv\
data/processed/compare_hetero_gay_men.csv\
submission/figures/fig1_men_vs_women.pdf\
submission/figures/fig2_men_vs_women_inpool.pdf\
submission/figures/fig3_hetero_vs_gay_men.pdf\
submission/reference.bib
	R -e "rmarkdown::render('submission/manuscript.Rmd', output_format = 'all', output_options = list())"

submission/supplemental_materials.pdf : submission/supplemental_materials.Rmd\
data/processed/des_and_test_result.csv\
submission/reference.bib
	R -e "rmarkdown::render('submission/supplemental_materials.Rmd')"
	
submission/title_page.pdf : submission/title_page.Rmd
	R -e "rmarkdown::render('submission/title_page.Rmd')"
