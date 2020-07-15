# assign a value as a variable and operations (+ - / * %% etc.) - google 'R operators' to see what other operations are available 

a <- 3

b <- a/2

c <- a + b

# boolean operations

d <- 3

a == d

a == b

a != b


# save and load data - can help save a lot of processing time when you have large data-structures as is common in circadian experiments

save(a, file = "./data/a.Rda")

load("./data/a.Rda")

# data can also be saved in structures rather than as individual values, these are commonly referred to as data.frames but we will use
# more developed structure called a data.table - library(data.table) - help(data.table)

# load data.table package
library(data.table)

# create data.table and assign it to variable dt
dt <- data.table(t = seq(0,10,0.01), x = runif(1001), y = rnorm(1001))

## select column of dt

# by name (returns vector)
dt_col1 <- dt[, t]

# by index (returns data table)
dt_col2 <- dt[, 1:2]

## select rows

# by index
dt_row1 <- dt[1:100]

# by head()/tail() function
dt_row2 <- dt[, head(.SD, 100)]

# by condition
dt_row3 <- dt[t %between% c(3, 5)]

## add column
dt[, z := sin(t)]

# plot data with ggplot2

library(ggplot2)

ggplot(data = dt, mapping = aes(x = t, y = x)) +
  geom_point()

# melt data

dt_molten <- melt(dt, measure.vars = c("x", "y", "z"))

ggplot(data = dt_molten, mapping = aes(x = t, y = value, group = variable, colour = variable)) +
  geom_point()

