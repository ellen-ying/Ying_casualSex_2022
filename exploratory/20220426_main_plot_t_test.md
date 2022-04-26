20220426_main_plot_t\_test
================
Yurun (Ellen) Ying
4/26/2022

## Main plots

-   Violin plots of the diff x diff condition
    -   grouped by gender
    -   paneled by experiments
    -   separate for two dependent variables: avg num of experiences
        (all), avg num of partners (all)

``` r
casual_tib %>% 
  filter(diff_likelihood == 1, diff_standard == 1) %>% 
  select(homosexual, m_exp_all, f_exp_all) %>% 
  pivot_longer(c(m_exp_all, f_exp_all), values_to = "exp_all",
               names_to = "gender", names_pattern = "(.)_exp_all") %>% 
  ggplot(aes(x = gender, y = exp_all)) +
  geom_violin(aes(fill = gender)) +
  stat_summary(fun = "mean", geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  scale_fill_discrete(
    type = wes_palette("Darjeeling2", 2, type = "discrete"),
    name = "", labels = c("Women", "Men")
  ) +
  labs(x = "", y = "Average number of\nshort-term mating experiences",
       title = " Main plot 1: violin plot of average number of\nshort-term mating experiences") +
  facet_wrap(
    ~ homosexual,
    labeller = labeller(
      homosexual = c(
        `0` = "Experiment 1\nHeterosexual individuals",
        `1` = "Experiment 2\nGay men and lesbian women")
      )) +
  theme_minimal() +
  theme(
    axis.line = element_line(size = 0.3),
    axis.ticks.y = element_line(size = 0.3),
    axis.text.x = element_blank(),
    panel.grid = element_blank(),
    panel.spacing = unit(0, "npc"),
    strip.text = element_text(size = 10)
    )
```

![](20220426_main_plot_t_test_files/figure-gfm/violin_exp-1.png)<!-- -->

``` r
casual_tib %>% 
  filter(diff_likelihood == 1, diff_standard == 1) %>% 
  select(homosexual, m_partner_all, f_partner_all) %>% 
  pivot_longer(c(m_partner_all, f_partner_all), values_to = "partner_all",
               names_to = "gender", names_pattern = "(.)_partner_all") %>% 
  ggplot(aes(x = gender, y = partner_all)) +
  geom_violin(aes(fill = gender)) +
  stat_summary(fun = "mean", geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.2) +
  coord_cartesian(ylim = c(0, 3)) +
  scale_fill_discrete(
    type = wes_palette("Darjeeling2", 2, type = "discrete"),
    name = "", labels = c("Women", "Men")
  ) +
  labs(x = "", y = "Average number of\nshort-term patners",
       title = " Main plot 2: violin plot of average\nnumber of short-term partners") +
  facet_wrap(
    ~ homosexual,
    labeller = labeller(
      homosexual = c(
        `0` = "Experiment 1\nHeterosexual individuals",
        `1` = "Experiment 2\nGay men and lesbian women")
      )) +
  theme_minimal() +
  theme(
    axis.line = element_line(size = 0.3),
    axis.ticks.y = element_line(size = 0.3),
    axis.text.x = element_blank(),
    panel.grid = element_blank(),
    panel.spacing = unit(0, "npc"),
    strip.text = element_text(size = 10)
    )
```

![](20220426_main_plot_t_test_files/figure-gfm/violin_partner-1.png)<!-- -->

## T-tests

-   Independent samples *t*-test between men and women, separate for
    conditions and experiments
-   Output into a large table

``` r
# t test by groups for exp_all variable
casual_tib %>% 
  unite(homosexual, diff_likelihood, diff_standard,
              col = "condition_hs_lh_sd", sep = "_") %>% 
  pivot_longer(c(m_exp_all, f_exp_all), values_to = "exp_all",
               names_to = "gender", names_pattern = "(.)_exp_all") %>% 
  select(condition_hs_lh_sd, gender, exp_all) %>% 
  nest_by(condition_hs_lh_sd) %>% 
  mutate(t.test(exp_all ~ gender, data = data) %>% tidy()) %>% 
  select(condition_hs_lh_sd, statistic, p.value, parameter) %>% 
  kable()
```

| condition_hs_lh_sd |   statistic |   p.value | parameter |
|:-------------------|------------:|----------:|----------:|
| 0_0\_0             |    0.000000 | 1.0000000 |  4998.000 |
| 0_0\_1             |    0.000000 | 1.0000000 |  4998.000 |
| 0_1\_0             |    0.000000 | 1.0000000 |  4998.000 |
| 0_1\_1             |    0.000000 | 1.0000000 |  4998.000 |
| 1_0\_0             |    1.260672 | 0.2074859 |  4997.831 |
| 1_0\_1             | -180.274948 | 0.0000000 |  4017.526 |
| 1_1\_0             |  -94.395098 | 0.0000000 |  3466.441 |
| 1_1\_1             | -301.783672 | 0.0000000 |  2867.562 |
