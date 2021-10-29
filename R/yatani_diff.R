
#difference

all_df = read.csv("./data.csv", stringsAsFactors = TRUE)

df = data.frame(vp_id = factor(all_df$id), bedingung=factor(all_df$bedingung), diff=as.numeric(sub(x=all_df$difference, pattern = ",", replacement=".")))
tibble(df)

#dont include suject 10
df = subset(df, vp_id!=10)

library(ez)
options(contrasts=c("contr.sum", "contr.poly"))
ezANOVA(data=df, dv=.(diff), wid=.(vp_id), within=.(bedingung), type=3)
# $ANOVA
#      Effect DFn DFd         F         p p<.05        ges
# 2 bedingung   2  16 0.2074697 0.8147898       0.01036784
# 
# $`Mauchly's Test for Sphericity`
#      Effect         W          p p<.05
# 2 bedingung 0.4568389 0.06444228      
# 
# $`Sphericity Corrections`
#      Effect       GGe     p[GG] p[GG]<.05       HFe     p[HF] p[HF]<.05
# 2 bedingung 0.6480205 0.7204338           0.7207956 0.7444184       


