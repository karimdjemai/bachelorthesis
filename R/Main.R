

d = read.csv("./data.csv")
x = d[29,5]
n = as.numeric(sub(x=x, pattern=",", "replacement"="."))

n
class(n)


for (c in 1:3) {
  
  for (r in 1:nrow(d))
  {
    cx = c + 4
    
    d[r, cx] = as.numeric(sub(x=d[r,cx], pattern=",", "replacement"="."))
    
    print(class(d[r,cx]))
  }
}

d