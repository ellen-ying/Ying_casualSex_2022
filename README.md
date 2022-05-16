ABM simulating short-term mating behaviors
================
Yurun (Ellen) Ying
5/6/2022

## Description

By using a spatial agent-based model, the present study investigated we
investigated whether men and women’s different mating preferences
resulted in any gender differences in short-term mating behaviors, and
if they did, under what circumstances.

### Dependencies:

-   Netlogo version 6.2.1
-   R version 4.1.3 (2022-03-10)
    -   `tidyverse` (v. 1.3.1)
    -   `here` (v. 1.0.1)
    -   `broom` (v. 0.8.0)
    -   `effectsize` (v. 0.6.0.1)
    -   `rmarkdown` (v. 2.14)
    -   `knitr` (v. 1.39)
    -   `kableExtra` (v. 1.3.4)

### My computer

    ## R version 4.1.3 (2022-03-10)
    ## Platform: x86_64-apple-darwin17.0 (64-bit)
    ## Running under: macOS Catalina 10.15.7
    ## 
    ## Matrix products: default
    ## BLAS:   /Library/Frameworks/R.framework/Versions/4.1/Resources/lib/libRblas.0.dylib
    ## LAPACK: /Library/Frameworks/R.framework/Versions/4.1/Resources/lib/libRlapack.dylib
    ## 
    ## locale:
    ## [1] C/UTF-8/C/C/C/C
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] kableExtra_1.3.4   knitr_1.39         rmarkdown_2.14     effectsize_0.6.0.1
    ##  [5] broom_0.8.0        here_1.0.1         forcats_0.5.1      stringr_1.4.0     
    ##  [9] dplyr_1.0.9        purrr_0.3.4        readr_2.1.2        tidyr_1.2.0       
    ## [13] tibble_3.1.7       ggplot2_3.3.6      tidyverse_1.3.1   
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] httr_1.4.2        viridisLite_0.4.0 jsonlite_1.8.0    splines_4.1.3    
    ##  [5] modelr_0.1.8      datawizard_0.4.0  assertthat_0.2.1  cellranger_1.1.0 
    ##  [9] yaml_2.3.5        bayestestR_0.11.5 pillar_1.7.0      backports_1.4.1  
    ## [13] lattice_0.20-45   glue_1.6.2        digest_0.6.29     rvest_1.0.2      
    ## [17] colorspace_2.0-3  sandwich_3.0-1    htmltools_0.5.2   Matrix_1.4-1     
    ## [21] pkgconfig_2.0.3   haven_2.5.0       xtable_1.8-4      mvtnorm_1.1-3    
    ## [25] webshot_0.5.3     scales_1.2.0      svglite_2.1.0     tzdb_0.3.0       
    ## [29] emmeans_1.7.3     generics_0.1.2    ellipsis_0.3.2    TH.data_1.1-1    
    ## [33] withr_2.5.0       cli_3.3.0         survival_3.3-1    magrittr_2.0.3   
    ## [37] crayon_1.5.1      readxl_1.4.0      estimability_1.3  evaluate_0.15    
    ## [41] fs_1.5.2          fansi_1.0.3       MASS_7.3-57       xml2_1.3.3       
    ## [45] tools_4.1.3       hms_1.1.1         lifecycle_1.0.1   multcomp_1.4-19  
    ## [49] munsell_0.5.0     reprex_2.0.1      compiler_4.1.3    systemfonts_1.0.4
    ## [53] rlang_1.0.2       grid_4.1.3        parameters_0.17.0 rstudioapi_0.13  
    ## [57] gtable_0.3.0      codetools_0.2-18  DBI_1.1.2         R6_2.5.1         
    ## [61] zoo_1.8-10        lubridate_1.8.0   performance_0.9.0 fastmap_1.1.0    
    ## [65] utf8_1.2.2        rprojroot_2.0.3   insight_0.17.0    stringi_1.7.6    
    ## [69] vctrs_0.4.1       dbplyr_2.1.1      tidyselect_1.1.2  xfun_0.30        
    ## [73] coda_0.19-4
