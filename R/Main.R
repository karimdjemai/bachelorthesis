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
aov_diff_df_ = data.frame(id = d$id, bedingung = d$bedingung, differenz = d$difference )

#ohne id 10
aov_diff_df = subset(aov_diff_df_, id!=10)
aov_diff_df

aov_diff_df = convert_as_factor(aov_diff_df, id, bedingung)
aov_diff_df = aov_diff_df %>%
  arrange(bedingung) 

tibble(aov_diff_df)

#summary statistics 
aov_diff_df %>%
  group_by(bedingung) %>%
  get_summary_stats(differenz, type = "mean_sd") #to Latex

#boxplot
bxp = ggboxplot(aov_diff_df, x = "bedingung", y = "differenz", add = "point", xlab="Fortbewegungsart", ylab="Differenz")
bxp #toLatex

#outliers
aov_diff_df %>%
    group_by("bedingung") %>%
    identify_outliers("differenz") #no extreme outliers

#normality test
aov_diff_df %>%
  group_by(bedingung) %>%
  shapiro_test(differenz) #to latex, normality may be assumed

#normality plot
ggqqplot(aov_diff_df, "differenz", facet.by = "bedingung") #tolatex

#anova 
diff_aov = anova_test(data = aov_diff_df, dv = differenz, wid = id, within = bedingung) #with mauchly's test for spherecity
get_anova_table(diff_aov) # reenhouse-Geisser sphericity correction is automatically applied
#TOLATEX
#not significant :( this no posthoc test
diff_aov

#################################presence aov

#with 10 or not?
presence_df = data.frame(d$id, d$bedingung, d$A, d$B, d$C, d$D, d$E, d$F)
presence_df

#without 5?
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
presence_aov_df = data.frame(id = presence_df$d.id, bedingung = presence_df$d.bedingung, sus_score = presence_df$SUS, stringsAsFactors = TRUE)
presence_aov_df = convert_as_factor(presence_aov_df, id)

#order by bedingung
presence_aov_df = presence_aov_df %>%
  arrange(bedingung) 
  
tibble(presence_aov_df)

#summary statistics 
presence_aov_df %>%
  group_by(bedingung) %>%
  get_summary_stats(sus_score, type = "mean_sd") #to Latex

#boxplot
presence_bxp = ggboxplot(presence_aov_df, x = "bedingung", y = "sus_score", add = "point", xlab="Fortbewegungsart", ylab="SUS Präsenz Score")
presence_bxp #toLatex

#outliers
presence_aov_df %>%
  group_by(bedingung) %>%
  identify_outliers(sus_score) #no extreme outliers

presence_aov_df %>%
  group_by(bedingung) %>%
  shapiro_test(sus_score) #to latex, normality may not be assumed -> friedmann #tolatex

ggqqplot(presence_aov_df, "sus_score", facet.by = "bedingung") #tolatex

presence_fried_res = presence_aov_df %>%
  friedman_test(sus_score ~ bedingung|id)
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
  friedman_effsize(sus_score ~ bedingung|id) #tolatex

pairwise_presence = presence_aov_df %>%
 wilcox_test(sus_score ~ bedingung, paired=TRUE, p.adjust.method = "bonferroni", exact=T)
pairwise_presence#tolatex very confused, how can a and b be equal, b and c be equal but a and c not???

#test it thouroghly
#GroupA = c(4,4,2,3,5,0,1,0,2)
#GroupB = c(0,1,2,0,4,0,1,0,0)
#GroupC = c(0,2,1,0,2,0,1,0,0)

#wilcox.test(GroupA, GroupC, paired=T)

#library(coin)
#wilcoxsign_test(GroupA ~ GroupC, distribution="exact")

#effektstärke von diff repeated measures anova

