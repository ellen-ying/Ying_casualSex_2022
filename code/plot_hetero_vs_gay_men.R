#!/usr/bin/env Rscript --vanilla

# name: plot_hetero_vs_gay_men.R
# input: data/processed/casual_sex_sim.csv
# output: submission/figures/fig2_hetero_vs_gay_men.pdf
# notes: none

# load libraries
library(tidyverse); library(ggplot2); library(wesanderson); library(here)

args <- commandArgs(trailingOnly = TRUE)
#args <- c("data/processed/casual_sex_sim.csv", "submission/figures/fig2_hetero_vs_gay_men.pdf")

input_file <- args[1]
output_file <- args[2]

# read file
casual_tib <- here(input_file) %>% 
  read_csv() %>% 
  mutate(
    diff_likelihood = as_factor(diff_likelihood),
    diff_standard = as_factor(diff_standard),
    homosexual = as_factor(homosexual)
  )

# construct facet label
facet_label <- 
  tibble(
    label = c("(A)", "(B)"),
    variable = c("exp_all", "partner_all"),
    x = 0.5
  ) %>% 
  mutate(y = ifelse(variable == "exp_all", 4, 2.3))

# construct y-axis label
y_lab <- labeller(
  variable = c(
    `exp_all` = "Average number of\nshort-term mating experiences",
    `partner_all` = "Average number of short-term mates"))

casual_tib %>% 
  filter(diff_likelihood == 1, diff_standard == 1) %>% 
  select(homosexual, m_exp_all, m_partner_all) %>% 
  pivot_longer(c(m_exp_all, m_partner_all), values_to = "value",
               names_to = "variable", names_pattern = "m_(.*)") %>% 
  ggplot(aes(x = homosexual, y = value)) +
  geom_violin(aes(fill = homosexual)) +
  stat_summary(fun = "mean", geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  geom_text(
    data = facet_label, aes(label = label, x = x, y = y), hjust = 0, fontface = 2
    ) +
  scale_fill_discrete(
    type = wes_palette("Darjeeling2", 2, type = "discrete"),
    name = "", labels = c("Heterosexual men", "Gay men")
  ) +
  scale_y_continuous(limits = c(0, NA), breaks = seq(0, 4, by = 1)) +
  labs(x = "", y = NULL) +
  facet_wrap(
    ~ variable, nrow = 1, scales = "free",
    strip.position = "left",
    labeller = y_lab
  ) +
  theme_minimal() +
  theme(
    axis.line = element_line(size = 0.3),
    axis.ticks.y = element_line(size = 0.3),
    axis.text.x = element_blank(),
    panel.grid = element_blank(),
    panel.spacing = unit(0.5, "line"),
    strip.text = element_text(size = 11),
    strip.placement = "outside",
    legend.position = "bottom",
    legend.box.spacing = unit(0.1, "line")
  )

ggsave(output_file, width = 9, height = 5)
