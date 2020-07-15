library(data.table)

## create metadata

metadt <- data.table(file = rep(c("20190612_rawact/Monitor84.txt"), each = 32),
                     exp_ID = rep("Rtute", times = 32),
                     env_monitor = rep(c("20190612_rawenv/Monitor82.txt"), each = 32),
                     incubator = rep(c("Morty"), each = 32),
                     entrainment = rep(c("LDVS"), each = 32),
                     start_datetime = rep("2019-05-25 09:00:00", times = 32),
                     stop_datetime = rep("2019-06-06 23:59:00", times = 32),
                     region_id = rep(1:32, 1),
                     genotype = rep(c("iso31", "iso31+pym", "CS", "CS+pym"), times = 8),
                     sex = rep("M", times = 32),
                     temp = rep(c("21"), each = 32))

metadt[, treatment := paste(genotype, entrainment, sep='_')]

