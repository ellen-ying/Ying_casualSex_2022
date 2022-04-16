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
