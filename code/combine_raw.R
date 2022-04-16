#!/usr/bin/env Rscript --vanilla

# name: combine_raw.R
# input: eight dataset by conditions from the two experiments
# output: one dataset with coded conditions and preprocessed outcomes
# notes: conditions were coded into variables diff_likelihood, diff_standard, and homosexual

library(tidyverse); library(magrittr)

input_file <- commandArgs(trailingOnly = TRUE)

output_file <- "data/processed/casual_sex_sim.csv"

# read file and combine
raw_tib <- map_dfr(.x = input_file, .f = read_csv, skip = 6)

# remove unnecessary columns and rename the variables
raw_tib <- 
  raw_tib %>% 
  select(-c("[run number]", "movement-range", "long-term-likelihood",
              "[step]"))

names(raw_tib) <- c("m_number", "m_likelihood", "f_likelihood",
                    "m_standard", "f_standard", "homosexual",
                    "seed", "m_inpool", "f_inpool",
                    "m_exp", "f_exp", "m_partner", "f_partner")

# preprocessing the data
raw_tib <- 
  raw_tib %>% 
    mutate(
      diff_likelihood = ifelse(m_likelihood == f_likelihood, 0, 1),
      diff_standard = ifelse(m_standard == f_standard, 0, 1),
      homosexual = ifelse(homosexual == FALSE, 0, 1),
      m_outpool = m_number - m_inpool,
      f_outpool = 300 - m_number - f_inpool,
      m_exp_all = m_exp / m_number,
      f_exp_all = f_exp / (300 - m_number),
      m_exp_ip = m_exp / m_inpool,
      f_exp_ip = f_exp / f_inpool,
      m_partner_all = m_partner / m_number,
      f_partner_all = f_partner / (300 - m_number),
      m_partner_ip = m_partner / m_inpool,
      f_partner_ip = f_partner / f_inpool
      )  %>% 
    select(-c(m_number, m_likelihood, f_likelihood, 
              m_standard, f_standard, m_exp:f_partner))

# reorder the columns
raw_tib <- 
  raw_tib %>% 
    relocate(seed, .before = everything()) %>% 
    relocate(homosexual, .after = diff_standard) %>% 
    relocate(m_inpool, .before = m_outpool) %>% 
    relocate(f_inpool, .after = m_inpool)

# output
write_csv(raw_tib, output_file)
