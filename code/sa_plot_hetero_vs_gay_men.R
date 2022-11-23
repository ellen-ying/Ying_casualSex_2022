#!/usr/bin/env Rscript --vanilla

# name: sa_plot_hetero_vs_gay_men.R
# input: data/processed/sa_casual_sex_sim.csv
# output: submission/figures/sa_fig3_hetero_vs_gay_men.pdf submission/figures/sa_fig3_hetero_vs_gay_men.jpeg
# notes: none

# load libraries
library(tidyverse); library(wesanderson); library(here)

args <- commandArgs(trailingOnly = TRUE)
#args <- c("data/processed/sa_casual_sex_sim.csv", "submission/figures/sa_fig3_hetero_vs_gay_men.pdf")

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
    variable = c("exp_all", "partner_all"),
    x = 8
  ) %>% 
  mutate(y = ifelse(variable == "exp_all", 8.8, 5.5))

# construct y-axis label
y_lab <- labeller(
  variable = c(
    `exp_all` = "Average number of\nshort-term mating experiences",
    `partner_all` = "Average number of short-term mates"))

casual_tib %>% 
  filter(diff_likelihood == 1, diff_standard == 1) %>% 
  select(lt_likelihood, homosexual, m_exp_all, m_partner_all) %>% 
  pivot_longer(c(m_exp_all, m_partner_all), values_to = "value",
               names_to = "variable", names_pattern = "m_(.*)") %>% 
  ggplot(aes(x = lt_likelihood, y = value, color = homosexual)) +
  stat_summary(fun = "mean", geom = "point", size = 2.5,
               position = position_dodge(width = 0.9)) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", 
               width = 0.8, size = 0.7, 
               position = position_dodge(width = 0.9)) +
  stat_summary(fun = "mean", geom = "line", size = 0.1,
               position = position_dodge(width = 0.9)) +
  geom_text(
    data = facet_label, aes(label = label, x = x, y = y), 
    hjust = 1, fontface = 2, inherit.aes = FALSE
  ) +
  scale_color_discrete(
    type = wes_palette("Royal1", 2, type = "discrete"),
    name = "", labels = c("Heterosexual male", "Gay male")
  ) +
  scale_y_continuous(limits = c(0, NA), breaks = seq(0, 8, by = 1)) +
  labs(x = "Long-term Likelihood (%)", y = NULL) +
  facet_wrap(
    ~ variable, nrow = 1, scales = "free",
    strip.position = "left",
    labeller = y_lab
  ) +
  theme_minimal() +
  theme(
    axis.line = element_line(size = 0.3),
    axis.ticks.y = element_line(size = 0.3),
    axis.ticks.x = element_line(size = 0.3),
    axis.title.x  = element_text(margin = margin(t = 7)),
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
