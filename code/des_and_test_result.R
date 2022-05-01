#!/usr/bin/env Rscript --vanilla

# name: des_and_test_result.R
# input: data/processed/casual_sex_sim.csv
# output: data/processed/des_and_test_result.csv
# notes: take in the data file, do the statistical analyses 
#   and output into a table containing descriptive stats, t-test results, and effect size


library(tidyverse); library(magrittr); library(here); library(broom); library(effectsize)

input_file <- commandArgs(trailingOnly = TRUE)
output_file <- "data/processed/des_and_test_result.csv"

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
  unite(homosexual, diff_likelihood, diff_standard,
        col = "homosexual_dlikelihood_dstandard", sep = "_") %>% 
  pivot_longer(-c(seed, homosexual_dlikelihood_dstandard), 
               names_to = c("gender", ".value"), 
               names_pattern = "(.)_(.*)"
  )

# descriptives
casual_des <- 
  casual_long %>% 
  group_by(homosexual_dlikelihood_dstandard, gender) %>% 
  summarise(across(inpool:partner_ip, 
                   list(mean = mean, sd = sd),
                   .names = "{.col}.{.fn}")) %>% 
  pivot_wider(names_from = gender, 
              values_from = -c(homosexual_dlikelihood_dstandard, gender),
              names_glue = "{gender}_{.value}")

# t test by groups for exp_all variable
casual_t_test <- 
  casual_long %>% 
  nest_by(homosexual_dlikelihood_dstandard) %>% 
  mutate(
    inpool = t.test(inpool ~ gender, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter),
    outpool = t.test(outpool ~ gender, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter),
    exp_all = t.test(exp_all ~ gender, data = data) %>% tidy() %>% 
      # somehow the map function doesn't work here and I wonder why...
      select(statistic, p.value, parameter),
    exp_ip = t.test(exp_ip ~ gender, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter),
    partner_all = t.test(partner_all ~ gender, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter),
    partner_ip = t.test(partner_ip ~ gender, data = data) %>% tidy() %>% 
      select(statistic, p.value, parameter)
  ) %>% 
  select(-data) %>% 
  unnest(cols = -homosexual_dlikelihood_dstandard, names_sep = ".")

# effect size
casual_d <- 
  casual_long %>% 
  nest_by(homosexual_dlikelihood_dstandard) %>% 
  mutate(
    inpool.d = cohens_d(inpool ~ gender, data = data) %>% pull(Cohens_d),
    outpool.d = cohens_d(outpool ~ gender, data = data) %>% pull(Cohens_d),
    exp_all.d = cohens_d(exp_all ~ gender, data = data) %>% pull(Cohens_d),
    exp_ip.d = cohens_d(exp_ip ~ gender, data = data) %>% pull(Cohens_d),
    partner_all.d = cohens_d(partner_all ~ gender, data = data) %>% pull(Cohens_d),
    partner_ip.d = cohens_d(partner_ip ~ gender, data = data) %>% pull(Cohens_d)
  ) %>% 
  select(-data)

# combine the descriptives, test results, and effect size
full_join(casual_des, casual_t_test, by = "homosexual_dlikelihood_dstandard") %>% 
  full_join(., casual_d, by = "homosexual_dlikelihood_dstandard") %>% 
  write_csv(output_file)

