

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
  print(class(abs(row[1,5] - row[1,6])) == class(row[1,7]))
  print(abs(row[1,5] - row[1,6]) == row[1,7])
  print("------------------")
}
