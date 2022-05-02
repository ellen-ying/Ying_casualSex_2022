#!/usr/bin/env Rscript --vanilla

# name: plot_hetero_vs_gay_men.R
# input: data/processed/casual_sex_sim.csv
# output: submission/figures/fig2_hetero_vs_gay_men.pdf
# notes: none

# load libraries
library(tidyverse); library(ggplot2); library(wesanderson); library(magrittr); library(here); library(knitr); library(broom); library(effectsize)

# read file
casual_tib <- here("data/processed/casual_sex_sim.csv") %>% 
  read_csv() %>% 
  mutate(
    diff_likelihood = as_factor(diff_likelihood),
    diff_standard = as_factor(diff_standard),
    homosexual = as_factor(homosexual)
  )

y_lab <- labeller(
  variable = c(
    `exp_all` = "Average number of\nshort-term mating experiences",
    `partner_all` = "Average number of\nshort-term mates"))

casual_tib %>% 
  filter(diff_likelihood == 1, diff_standard == 1) %>% 
  select(homosexual, m_exp_all, m_partner_all) %>% 
  pivot_longer(c(m_exp_all, m_partner_all), values_to = "value",
               names_to = "variable", names_pattern = "m_(.*)") %>% 
  ggplot(aes(x = homosexual, y = value)) +
  geom_violin(aes(fill = homosexual)) +
  stat_summary(fun = "mean", geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  scale_fill_discrete(
    type = wes_palette("Darjeeling2", 2, type = "discrete"),
    name = "", labels = c("Heterosexual men", "Gay men")
  ) +
  scale_y_continuous(limits = c(0, NA), breaks = seq(0, 4, by = 1)) +
  labs(x = "", y = NULL) +
  facet_wrap(
    ~ variable, ncol = 1, scales = "free",
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

ggsave("submission/figures/fig2_hetero_vs_gay_men.pdf", width = 5, height = 9)
