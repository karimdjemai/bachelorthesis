library(tidyverse)
library(ggpubr)
library(rstatix)

d = read.csv("./data.csv", stringsAsFactors = FALSE)

sapply(d, mode)

#sub , with . to make it convertible
d = transform(d, schaetzung = sub(x=schaetzung, pattern = ",", replacement="."))
d = transform(d, distance = sub(x=distance, pattern = ",", replacement="."))
d = transform(d, difference = sub(x=difference, pattern = ",", replacement="."))
d$schaetzung

d = transform(d, schaetzung = as.numeric(schaetzung))
d = transform(d, distance = as.numeric(distance))
d = transform(d, difference = as.numeric(difference))

sapply(d, mode)

#tests the difference property
for(i in 1:nrow(d)) {
  row = d[i,]
  # do stuff with row
  print(abs(row[1,5] - row[1,6]))
  print("==?")
  print(row[1,7])
  print(all.equal(abs(row[1,5] - row[1,6]), row[1,7]))
  print("------------------")
}

#################################diff aov

#diff aov
aov_diff_df_ = data.frame(d$bedingung, d$difference, d$id)

#ohne id 10
aov_diff_df = subset(aov_diff_df_, d.id!=10)
aov_diff_df

#summary statistics 
aov_diff_df %>%
  group_by(d.bedingung) %>%
  get_summary_stats(d.difference, type = "mean_sd") #to Latex

#boxplot
bxp = ggboxplot(aov_diff_df, x = "d.bedingung", y = "d.difference", add = "point")
bxp #toLatex

#outliers
aov_diff_df %>%
    group_by("d.bedingung") %>%
    identify_outliers("d.difference") #no outliers

#normality test
aov_diff_df %>%
  group_by(d.bedingung) %>%
  shapiro_test(d.difference) #to latex, normality may be assumed

#normality plot
ggqqplot(aov_diff_df, "d.difference", facet.by = "d.bedingung") #tolatex

#anova 
diff_aov = anova_test(data = aov_diff_df, dv = d.difference, wid = d.id, within = d.bedingung) #with mauchly's test for spherecity
get_anova_table(diff_aov) # reenhouse-Geisser sphericity correction is automatically applied
#TOLATEX
#not significant :( this no posthoc test

#################################presence aov

#with 10 or not?
presence_df = data.frame(d$id, d$bedingung, d$A, d$B, d$C, d$D, d$E, d$F)
presence_df

#without 10?
presence_df = subset(presence_df, d.id!=5)

#calculate SUS-score
scores = c()
for(i in 1:nrow(presence_df)) {
  row = presence_df[i,]
  # do stuff with row
  count = 0
  #print(row$id)
  # print(i)
  # print(row$d.A)
  # print(row$d.A > 5)

  if (row$d.A > 5) {
    count = count + 1
  }

  if (row$d.B > 5) {
    count = count + 1
  }

  if (row$d.C > 5) {
    count = count + 1
  }

  if (row$d.D > 5) {
    count = count + 1
  }

  if (row$d.E > 5) {
    count = count + 1
  }

  if (row$d.F > 5) {
    count = count + 1
  }

  print(count)
  
  #presence_aov_df[i]$SUS = count
  scores = c(scores, count)
  print("------------------")
}
print(scores)

presence_df$SUS = scores
presence_df

#extract aov df
presence_aov_df = data.frame(presence_df$d.id, presence_df$d.bedingung, presence_df$SUS)
presence_aov_df

#summary statistics 
presence_aov_df %>%
  group_by(presence_df.d.bedingung) %>%
  get_summary_stats(presence_df.SUS, type = "mean_sd") #to Latex

#boxplot
presence_bxp = ggboxplot(presence_aov_df, x = "presence_df.d.bedingung", y = "presence_df.SUS", add = "point")
presence_bxp #toLatex

#outliers
presence_aov_df %>%
  group_by("presence_df.d.bedingung") %>%
  identify_outliers("presence_df.SUS") #no outliers

presence_aov_df %>%
  group_by(presence_df.d.bedingung) %>%
  shapiro_test(presence_df.SUS) #to latex, normality may not be assumed -> friedmann #tolatex

ggqqplot(presence_aov_df, "presence_df.SUS", facet.by = "presence_df.d.bedingung") #tolatex

presence_fried_res = presence_aov_df %>%
  friedman_test(presence_df.SUS ~ presence_df.d.bedingung|presence_df.d.id)
presence_fried_res #tolatex

# The Kendall’s W can be used as the measure of the Friedman test effect size. 
# It is calculated as follow : W = X2/N(K-1); where W is the Kendall’s W value; 
# X2 is the Friedman test statistic value; N is the sample size. 
# k is the number of measurements per subject (M. T. Tomczak and Tomczak 2014).
# 
# The Kendall’s W coefficient assumes the value from 0 (indicating no relationship) 
# to 1 (indicating a perfect relationship).
# 
# Kendall’s W uses the Cohen’s interpretation guidelines of 0.1 - < 0.3 (small effect), 
# 0.3 - < 0.5 (moderate effect) and >= 0.5 (large effect). 
# Confidence intervals are calculated by bootstap.

presence_aov_df %>%
  friedman_effsize(presence_df.SUS ~ presence_df.d.bedingung|presence_df.d.id) #tolatex

pairwise_presence = presence_aov_df %>%
 wilcox_test(presence_df.SUS ~ presence_df.d.bedingung, paired=TRUE, p.adjust.method = "bonferroni")
pairwise_presence#tolatex very confused, how can a and b be equal, b and c be equal but a and c not???

