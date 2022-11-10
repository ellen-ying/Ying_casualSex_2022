#!/usr/bin/env Rscript --vanilla

# name: des_and_test_result.R
# input: data/processed/casual_sex_sim.csv or data/processed/sa_casual_sex_sim.csv
# output: data/processed/des_and_test_result.csv or data/processed/sa_des_and_test_result.csv
# notes: take in the data file, do the statistical analyses 
#   and output into a table containing descriptive stats, t-test results, and effect size


library(tidyverse); library(here); library(broom); library(effectsize)

args <- commandArgs(trailingOnly = TRUE)
# main test
#args <- c("data/processed/casual_sex_sim.csv", "data/processed/des_and_test_result.csv")
# sensitivity test
#args <- c("data/processed/sa_casual_sex_sim.csv", "data/processed/sa_des_and_test_result.csv")

input_file <- args[1]
output_file <- args[2]

casual_tib <- here(input_file) %>% 
  read_csv() %>% 
  mutate(
    diff_likelihood = as_factor(diff_likelihood),
    diff_standard = as_factor(diff_standard),
    homosexual = as_factor(homosexual),
    lt_likelihood = as_factor(lt_likelihood)
  )

# create a long tibble
casual_long <- 
  casual_tib %>%
  unite(homosexual, diff_likelihood, diff_standard, lt_likelihood,
        col = "homosexual_dlikelihood_dstandard_lt", sep = "_") %>% 
  pivot_longer(-c(seed, homosexual_dlikelihood_dstandard_lt), 
               names_to = c("gender", ".value"), 
               names_pattern = "(.)_(.*)"
  )

# descriptives
casual_des <- 
  casual_long %>% 
  group_by(homosexual_dlikelihood_dstandard_lt, gender) %>% 
  summarise(across(inpool:partner_ip, 
                   list(mean = mean, sd = sd),
            .names = "{.col}.{.fn}"),
            .groups = "drop") %>% 
  pivot_wider(names_from = gender, 
              values_from = -c(homosexual_dlikelihood_dstandard_lt, gender),
              names_glue = "{gender}_{.value}")

# t test by groups for exp_all variable
casual_t_test <- 
  casual_long %>% 
  nest_by(homosexual_dlikelihood_dstandard_lt) %>% 
  mutate(
    inpool = t.test(inpool ~ gender, data = data, var.equal = TRUE) %>% tidy() %>% 
      select(statistic, p.value, parameter, conf.low, conf.high),
    outpool = t.test(outpool ~ gender, data = data, var.equal = TRUE) %>% tidy() %>% 
      select(statistic, p.value, parameter, conf.low, conf.high),
    exp_all = t.test(exp_all ~ gender, data = data, var.equal = TRUE) %>% tidy() %>% 
      # somehow the map function doesn't work here and I wonder why...
      select(statistic, p.value, parameter, conf.low, conf.high),
    exp_ip = t.test(exp_ip ~ gender, data = data, var.equal = TRUE) %>% tidy() %>% 
      select(statistic, p.value, parameter, conf.low, conf.high),
    partner_all = t.test(partner_all ~ gender, data = data , var.equal = TRUE) %>% tidy() %>% 
      select(statistic, p.value, parameter, conf.low, conf.high),
    partner_ip = t.test(partner_ip ~ gender, data = data, var.equal = TRUE) %>% tidy() %>% 
      select(statistic, p.value, parameter, conf.low, conf.high)
  ) %>% 
  select(-data) %>% 
  unnest(cols = -homosexual_dlikelihood_dstandard_lt, names_sep = ".")

# effect size
casual_d <- 
  casual_long %>% 
  nest_by(homosexual_dlikelihood_dstandard_lt) %>% 
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
full_join(casual_des, casual_t_test, by = "homosexual_dlikelihood_dstandard_lt") %>% 
  full_join(., casual_d, by = "homosexual_dlikelihood_dstandard_lt") %>% 
  write_csv(output_file)

