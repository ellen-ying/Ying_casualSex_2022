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
	$^

data/processed/des_and_test_result.csv : code/des_and_test_result.R\
data/processed/casual_sex_sim.csv
	$^ $@

data/processed/compare_hetero_gay_men.csv : code/compare_hetero_gay_men.R\
data/processed/casual_sex_sim.csv
	$^ $@

submission/figures/fig1_men_vs_women.pdf : code/plot_men_vs_women.R\
data/processed/casual_sex_sim.csv
	$^ $@

submission/figures/fig2_men_vs_women_inpool.pdf : code/plot_men_vs_women_inpool.R\
data/processed/casual_sex_sim.csv
	$^ $@

submission/figures/fig3_hetero_vs_gay_men.pdf : code/plot_hetero_vs_gay_men.R\
data/processed/casual_sex_sim.csv
	$^ $@

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
