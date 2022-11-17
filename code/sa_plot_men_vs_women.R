#!/usr/bin/env Rscript --vanilla

# name: sa_plot_men_vs_women.R
# input: data/processed/sa_casual_sex_sim.csv
# output: submission/figures/sa_fig1_men_vs_women.pdf submission/figures/sa_fig1_men_vs_women.jpeg
# notes: none

# load libraries
library(tidyverse); library(wesanderson); library(here)

args <- commandArgs(trailingOnly = TRUE)
#args <- c("data/processed/sa_casual_sex_sim.csv", "submission/figures/sa_fig1_men_vs_women.pdf")

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
    homosexual = rep(c(0, 1), each = 2),
    label = c("(A)", "(B)", " ", " "),
    variable = rep(c("exp_all", "partner_all"), 2),
    x = -0.5
  ) %>% 
  mutate(y = ifelse(variable == "exp_all", 9, 5.5))

# construct y-axis label
y_lab <- labeller(
  homosexual = c(
    `0` = "Experiment 1\nHeterosexual individuals",
    `1` = "Experiment 2\nGay men and lesbian women"),
  variable = c(
    `exp_all` = "Average number of\nshort-term mating experiences",
    `partner_all` = "Average number of\nshort-term mates")
)

casual_tib %>% 
  filter(diff_likelihood == 1, diff_standard == 1) %>% 
  select(lt_likelihood, homosexual, 
         m_exp_all, f_exp_all, m_partner_all, f_partner_all) %>% 
  pivot_longer(c(m_exp_all, f_exp_all, m_partner_all, f_partner_all), 
               values_to = "value", names_to = c("gender", "variable"),
               names_pattern = "(.)_(.*)") %>% 
  ggplot(aes(x = lt_likelihood, y = value, color = gender)) +
  stat_summary(fun = "mean", geom = "point", size = 2.5,
               position = position_dodge(width = 0.9)) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", 
               width = 1, size = 0.7, 
               position = position_dodge(width = 0.9)) +
  stat_summary(fun = "mean", geom = "line", size = 0.1,
               position = position_dodge(width = 0.9)) +
  geom_text(data = facet_label, aes(label = label, x = x, y = y), 
            hjust = 0, fontface = 2, inherit.aes = FALSE) +
  scale_color_discrete(
    type = wes_palette("Royal1", 2, type = "discrete"),
    name = "", labels = c("Women", "Men")
  ) +
  scale_y_continuous(limits = c(0, NA), breaks = seq(0, 8, by = 1)) +
  labs(x = "Long-term Likelihood (%)", y = NULL) +
  facet_grid(
    variable ~ homosexual, scales = "free_y", 
    switch = "y", labeller = y_lab) +
  theme_minimal() +
  theme(
    axis.line = element_line(size = 0.3),
    axis.ticks.x = element_line(size = 0.3),
    axis.ticks.y = element_line(size = 0.3),
    axis.title.x  = element_text(margin = margin(t = 7)),
    panel.grid = element_blank(),
    panel.spacing.x = unit(1, "line"),
    panel.spacing.y = unit(1, "line"),
    strip.text = element_text(size = 11),
    strip.placement = "outside",
    legend.position = "bottom",
    legend.box.spacing = unit(0, "npc")
  )

ggsave(output_file[1], width = 7, height = 7)

ggsave(output_file[2], width = 7, height = 7)
