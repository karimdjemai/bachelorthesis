
#difference

all_df = read.csv("./data.csv", stringsAsFactors = TRUE)

df_ = data.frame(vp_id = factor(all_df$id), bedingung=factor(all_df$bedingung), laenge=factor(all_df$raumlaenge))
sch_num = as.numeric(sub(x=all_df$schaetzung, pattern = ",", replacement="."))
dis_num = as.numeric(sub(x=all_df$distance, pattern = ",", replacement="."))

df_$ratio = sch_num / dis_num
tibble(df_)

#dont include suject 5
df_ = subset(df_, vp_id!=10)

library(ez)
options(contrasts=c("contr.sum", "contr.poly"))
ezDesign(df_, x=vp_id, y=bedingung,laenge)
ezANOVA(data=df_, dv=.(ratio), wid=.(vp_id), within=.(bedingung, laenge), type=3)
