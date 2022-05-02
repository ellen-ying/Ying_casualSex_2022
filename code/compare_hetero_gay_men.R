#!/usr/bin/env Rscript --vanilla

# name: compare_hetero_gay_men.R
# input: data/processed/casual_sex_sim.csv
# output: data/processed/compare_hetero_gay_men.csv
# notes: take in the data file, do the statistical analyses 
#   and output into a table containing descriptive stats, t-test results, and effect size


library(tidyverse); library(magrittr); library(here); library(broom); library(effectsize)

input_file <- commandArgs(trailingOnly = TRUE)
output_file <- "data/processed/compare_hetero_gay_men.csv"

casual_tib <- here(input_file) %>% 
  read_csv() %>% 
  mutate(
    diff_likelihood = as_factor(diff_likelihood),
    diff_standard = as_factor(diff_standard),
    homosexual = as_factor(homosexual)
  )

# create a long tibble
casual_long <- 
  casual_tib %>%
  unite(diff_likelihood, diff_standard,
        col = "dlikelihood_dstandard", sep = "_") %>% 
  select(-c(seed, starts_with("f_")))

# descriptives
casual_des <- 
  casual_long %>% 
  group_by(dlikelihood_dstandard, homosexual) %>% 
  summarise(across(m_inpool:m_partner_ip, 
                   list(mean = mean, sd = sd),
                   .names = "{.col}.{.fn}"),
            .groups = "keep") %>% 
  pivot_wider(names_from = homosexual, 
              values_from = -c(dlikelihood_dstandard, homosexual),
              names_glue = "{.value}_{homosexual}")

# t test by groups for exp_all variable
casual_t_test <- 
  casual_long %>% 
  nest_by(dlikelihood_dstandard) %>% 
  mutate(
    m_inpool = t.test(m_inpool ~ homosexual, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter),
    m_outpool = t.test(m_outpool ~ homosexual, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter),
    m_exp_all = t.test(m_exp_all ~ homosexual, data = data) %>% tidy() %>% 
      # somehow the map function doesn't work here and I wonder why...
      select(statistic, p.value, parameter),
    m_exp_ip = t.test(m_exp_ip ~ homosexual, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter),
    m_partner_all = t.test(m_partner_all ~ homosexual, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter),
    m_partner_ip = t.test(m_partner_ip ~ homosexual, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter)
  ) %>% 
  select(-data) %>% 
  unnest(cols = -dlikelihood_dstandard, names_sep = ".")

# effect size
casual_d <- 
  casual_long %>% 
  nest_by(dlikelihood_dstandard) %>% 
  mutate(
    m_inpool.d = cohens_d(m_inpool ~ homosexual, data = data) %>% pull(Cohens_d),
    m_outpool.d = cohens_d(m_outpool ~ homosexual, data = data) %>% pull(Cohens_d),
    m_exp_all.d = cohens_d(m_exp_all ~ homosexual, data = data) %>% pull(Cohens_d),
    m_exp_ip.d = cohens_d(m_exp_ip ~ homosexual, data = data) %>% pull(Cohens_d),
    m_partner_all.d = cohens_d(m_partner_all ~ homosexual, data = data) %>% pull(Cohens_d),
    m_partner_ip.d = cohens_d(m_partner_ip ~ homosexual, data = data) %>% pull(Cohens_d)
  ) %>% 
  select(-data)

# combine the descriptives, test results, and effect size
full_join(casual_des, casual_t_test, by = "dlikelihood_dstandard") %>% 
full_join(., casual_d, by = "dlikelihood_dstandard") %>% 
write_csv(output_file)