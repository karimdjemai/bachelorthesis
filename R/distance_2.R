library(tidyverse)
library(ggpubr)
library(rstatix)

table = read.csv("./data.csv", stringsAsFactors = TRUE)
table

dd = data.frame(vp_id=table$id, bedingung=table$bedingung,schaetzung=table$schaetzung, laenge=table$raumlaenge, distance=table$distance)
dd$schaetzung = as.numeric(sub(pattern=",",replacement=".", x=dd$schaetzung))
dd$distance = as.numeric(sub(pattern=",",replacement=".", x=dd$distance))
tibble(dd)
dd

#without 10?
dd = subset(dd, vp_id!=10)

dd$nadiff = dd$schaetzung/dd$distance
dd

#overall mean and sd
get_summary_stats(dd, nadiff, type = "mean_sd")
#A tibble: 1 × 4
#variable     n  mean    sd
#<chr>    <dbl> <dbl> <dbl>
#  1 nadiff      27 0.649 0.352



get_summary_stats(group_by(dd,bedingung,laenge), nadiff, type = "mean_sd")
# A tibble: 9 × 6
# bedingung laenge variable     n  mean    sd
# <fct>      <int> <chr>    <dbl> <dbl> <dbl>
# 1 A              1 nadiff       3 0.813 0.298
# 2 A              2 nadiff       3 0.415 0.356
# 3 A              3 nadiff       3 0.546 0.183
# 4 B              1 nadiff       3 0.775 0.319
# 5 B              2 nadiff       3 1.16  0.422
# 6 B              3 nadiff       3 0.37  0.298
# 7 C              1 nadiff       3 0.458 0.343
# 8 C              2 nadiff       3 0.464 0.199
# 9 C              3 nadiff       3 0.836 0.051
dd = convert_as_factor(dd, laenge)

bxp = ggboxplot(
  dd, x = "bedingung", y = "nadiff",
  color = "laenge", palette = "jco", xlab="Fortbewegungsart", ylab="Verhältnis Schätzung / Distanz", panel.labs=c("Raumzahl des Levels"))
bxp

ggqqplot(dd, "nadiff", ggtheme = theme_bw()) +
  facet_grid(bedingung ~ laenge, labeller = "label_both")

shapiro_test(group_by(dd,bedingung,laenge), nadiff)#normality not violated
# A tibble: 9 × 5
# bedingung laenge variable statistic      p
# <fct>     <fct>  <chr>        <dbl>  <dbl>
# 1 A         1      nadiff       0.917 0.442 
# 2 A         2      nadiff       0.918 0.445 
# 3 A         3      nadiff       0.823 0.172 
# 4 B         1      nadiff       0.934 0.504 
# 5 B         2      nadiff       0.922 0.459 
# 6 B         3      nadiff       0.842 0.219 
# 7 C         1      nadiff       0.920 0.451 
# 8 C         2      nadiff       0.792 0.0959
# 9 C         3      nadiff       0.981 0.738 

dd %>%
  group_by(laenge, bedingung) %>%
  identify_outliers(nadiff) #no outliers

ff = data.frame(vp_id=dd$vp_id, bedingung=dd$bedingung, laenge=dd$laenge, nadiff= dd$nadiff)
tibble(ff)

anova_test(nadiff ~ bedingung*laenge, data=ff, wid=vp_id)

# Coefficient covariances computed by hccm()
# ANOVA Table (type II tests)
# 
#             Effect DFn DFd     F     p p<.05   ges
# 1        bedingung   2  18 1.144 0.341       0.113
# 2           laenge   2  18 0.332 0.722       0.036
# 3 bedingung:laenge   4  18 4.106 0.015     * 0.477

#effect of bedingung on the different laenge values

# anova_test(data=ff, wid=vp_id, within=laenge, dv=nadiff )
# anova_test(data=ff, wid=vp_id, within=bedingung, dv=nadiff )

ff %>%
  group_by(laenge) %>%
  anova_test(nadiff ~ bedingung, wid = vp_id) %>%
  get_anova_table() %>%
  adjust_pvalue(method = "bonferroni")

# # A tibble: 3 × 9
# laenge Effect      DFn   DFd     F     p `p<.05`   ges p.adj
# * <fct>  <chr>     <dbl> <dbl> <dbl> <dbl> <chr>   <dbl> <dbl>
# 1 1      bedingung     2     6  1.11 0.389 ""      0.27  1    
# 2 2      bedingung     2     6  4.60 0.061 ""      0.605 0.183
# 3 3      bedingung     2     6  3.99 0.079 ""      0.571 0.237

#effect of laenge on the different bedingungen
ff %>%
  group_by(bedingung) %>%
  anova_test(nadiff ~ laenge, wid = vp_id) %>%
  get_anova_table() %>%
  adjust_pvalue(method = "bonferroni")

# # A tibble: 3 × 9
# bedingung Effect   DFn   DFd     F     p `p<.05`   ges p.adj
# * <fct>     <chr>  <dbl> <dbl> <dbl> <dbl> <chr>   <dbl> <dbl>
# 1 A         laenge     2     6  1.49 0.299 ""      0.332 0.897
# 2 B         laenge     2     6  3.86 0.084 ""      0.563 0.252
# 3 C         laenge     2     6  2.63 0.151 ""      0.467 0.453
