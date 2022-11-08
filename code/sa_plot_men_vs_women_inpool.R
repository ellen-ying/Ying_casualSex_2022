#!/usr/bin/env Rscript --vanilla

# name: sa_plot_men_vs_women_inpool.R
# input: data/processed/sa_casual_sex_sim.csv
# output: submission/figures/sa_fig2_men_vs_women_inpool.pdf submission/figures/sa_fig2_men_vs_women_inpool.jpeg
# notes: none

# load libraries
library(tidyverse); library(wesanderson); library(here)

args <- commandArgs(trailingOnly = TRUE)
#args <- c("data/processed/sa_casual_sex_sim.csv", "submission/figures/sa_fig2_men_vs_women_inpool.pdf")

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
    x = 8
  ) %>% 
  mutate(y = ifelse(variable == "exp_ip", 11.8, 6.8))

# construct y-axis label
y_lab <- labeller(
  variable = c(
    `exp_ip` = "Average number of short-term\nmating experiences in the mating pool",
    `partner_ip` = "Average number of short-term\nmates in the mating pool")
)

casual_tib %>% 
  filter(homosexual == 0, diff_likelihood == 1, diff_standard == 1) %>% 
  select(lt_likelihood, m_exp_ip, f_exp_ip, m_partner_ip, f_partner_ip) %>% 
  pivot_longer(c(m_exp_ip, f_exp_ip, m_partner_ip, f_partner_ip), 
               values_to = "value", names_to = c("gender", "variable"),
               names_pattern = "(.)_(.*)") %>% 
  ggplot(aes(x = lt_likelihood, y = value, color = gender)) +
  stat_summary(fun = "mean", geom = "point",
               position = position_dodge(width = 0.7)) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", 
               width = 0.4, size = 0.5, 
               position = position_dodge(width = 0.7)) +
  stat_summary(fun = "mean", geom = "line", 
               position = position_dodge(width = 0.7)) +
  geom_text(
    data = facet_label, aes(label = label, x = x, y = y), 
    hjust = 1, fontface = 2, inherit.aes = FALSE
  ) +
  scale_color_discrete(
    type = wes_palette("Darjeeling2", 2, type = "discrete"),
    name = "", labels = c("Women", "Men")
  ) +
  scale_y_continuous(limits = c(0, NA), breaks = seq(0, 12, by = 2)) +
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
