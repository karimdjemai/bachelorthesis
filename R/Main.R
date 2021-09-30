

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

#aov for residual testing 
aov_df = data.frame(d$bedingung, d$difference, d$id)

aov_df %>%
  group_by(d.bedingung) %>%
  shapiro_test(d.difference)

ggqqplot(aov_df, "d.difference", facet.by = "d.bedingung")

aov = anova_test(data = aov_df, dv = d.difference, wid = d.id, within = d.bedingung)
get_anova_table(aov)


#ohne id 10

aov_df_without_ten = subset(aov_df, d.id!=10)
aov_df_without_ten

a  k




