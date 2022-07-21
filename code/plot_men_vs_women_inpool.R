#!/usr/bin/env Rscript --vanilla

# name: plot_men_vs_women_inpool.R
# input: data/processed/casual_sex_sim.csv
# output: submission/figures/fig2_men_vs_women_inpool.pdf submission/figures/fig2_men_vs_women_inpool.jpeg
# notes: none

# load libraries
library(tidyverse); library(wesanderson); library(here)

args <- commandArgs(trailingOnly = TRUE)
#args <- c("data/processed/casual_sex_sim.csv", "submission/figures/fig2_men_vs_women_inpool.pdf")

input_file <- args[1]
output_file <- args[-1]

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
    variable = c("exp_ip", "partner_ip"),
    x = 0.5
  ) %>% 
  mutate(y = ifelse(variable == "exp_ip", 5.9, 2.8))

# construct y-axis label
y_lab <- labeller(
  variable = c(
    `exp_ip` = "Average number of short-term\nmating experiences in the mating pool",
    `partner_ip` = "Average number of short-term\nmates in the mating pool")
)

casual_tib %>% 
  filter(homosexual == 0, diff_likelihood == 1, diff_standard == 1) %>% 
  select(m_exp_ip, f_exp_ip, m_partner_ip, f_partner_ip) %>% 
  pivot_longer(c(m_exp_ip, f_exp_ip, m_partner_ip, f_partner_ip), 
               values_to = "value", names_to = c("gender", "variable"),
               names_pattern = "(.)_(.*)") %>% 
  ggplot(aes(x = gender, y = value)) +
  geom_violin(aes(fill = gender)) +
  stat_summary(fun = "mean", geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  geom_text(
    data = facet_label, aes(label = label, x = x, y = y), hjust = 0, fontface = 2
  ) +
  scale_fill_discrete(
    type = wes_palette("Darjeeling2", 2, type = "discrete"),
    name = "", labels = c("Women", "Men")
  ) +
  scale_y_continuous(limits = c(0, NA), breaks = seq(0, 6, by = 1)) +
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
    strip.text = element_text(size = 12),
    strip.placement = "outside",
    legend.position = "bottom",
    legend.box.spacing = unit(0.1, "line"),
    legend.text = element_text(size = 12)
  )

ggsave(output_file[1], width = 9, height = 5)

ggsave(output_file[2], width = 9, height = 5)
