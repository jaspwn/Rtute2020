library(behavr)
library(damr)
library(sleepr)
library(ggetho)
library(zeitgebr)
library(circatools)

##set directory of DAM monitor files

data_dir <- "./data"

##link meta and raw monitor files

metadata <- link_dam_metadata(metadt, result_dir = data_dir)

##load raw monitor files

dt <- load_dam(metadata, FUN = sleepr::sleep_dam_annotation)

##add simple unique id (uid) and map back to id
dt[, uid := 1 : .N, meta = TRUE]
dt[, .(id, uid) , meta = TRUE]

## bring treatment to data.table rather than meta
#treatment <- data.table(id = attributes(dt)$metadata$id, treatment = attributes(dt)$metadata$treatment)
#dt <- merge(dt, treatment, by = "id")
#rejoin(dt)


#automatically detect dead animals
dt_curated <- curate_dead_animals(dt)
#rejoin(dt_curated)

## see which flies were removed
setdiff(dt[, id, meta=T],
        dt_curated[, id, meta=T])

## circatool curation functions

pop_exp_graph(dt_curated[xmv(entrainment) == "LDVS"], daysLD = 6, smooth_window = 15)

## add experiment phase information to each segment of experiment
dt_curated[, phase := ifelse(t %between% c(days(0), days(2.5)), "LD",
                             ifelse(t %between% c(days(3), days(5)), "VS",
                                    ifelse(t %between% c(days(7), days(11)), "FR",
                                           "Not-used")))]

## circatools phase graphs - generates graphs per phase of experiment

pop_phase_graph(dt_curated, exp_phase = "LD", param = "activity", bin_width = 1)
pop_phase_graph(dt_curated, exp_phase = "VS", param = "activity", bin_width = 1)
pop_phase_graph(dt_curated, exp_phase = "FR", param = "activity", bin_width = 1)

## ggetho plotting

ggetho(data = dt_curated[phase == "LD"], aes(x = t, y = activity, colour = genotype),
       summary_FUN = mean,
       summary_time_window = mins(15)) +
  stat_ld_annotations(phase = hours(0),
                      ld_colours = c("light yellow", "dark grey"),
                      alpha = 0.2, height = 1, outline = NA, ypos = "top") +
  stat_pop_etho() +
  scale_colour_brewer(type = "qual", palette = "Dark2") +
  scale_fill_brewer(type = "qual", palette = "Dark2") +
  facet_wrap(. ~ genotype, scales = "free_y", ncol = 1) +
  theme(text = element_text(size = 20),
        axis.text = element_text(size = 14),
        legend.position = "none",
        strip.background = element_blank(),
        strip.text = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  ylab("")


## calculate mean activity per experimental phase
sum_dt <- dt_curated[, .(sum_act_LD = sum(activity, na.rm = TRUE),
                         sum_act_LDVS = sum(activity, na.rm = TRUE),
                         sum_act_FR = sum(activity, na.rm = TRUE)),
                     by = c("id", "phase")]



sum_dt <- rejoin(dt_curated[, .(sum_act_LD = sum(activity[phase == "LD"], na.rm = TRUE),
                                sum_act_LDVS = sum(activity[phase == "VS"], na.rm = TRUE),
                                sum_act_FR = sum(activity[phase == "FR"], na.rm = TRUE)),
                            by = c("id")])


molten_dt <- melt(sum_dt, measure.vars = patterns("sum_act_"),
                  variable.name = "phase", value.name = "sum_activity")


phase_labels <- c(sum_act_LD = "LD",
                  sum_act_LDVS = "VS",
                  sum_act_FR = "Free-run")


ggplot(molten_dt, aes(x = entrainment, y = sum_activity, fill = genotype)) + 
  geom_boxplot(outlier.colour = "black", outlier.alpha = 0.5) +
  scale_fill_brewer(type = "qual", palette = "Dark2") +
  facet_grid(. ~ phase, labeller = labeller(phase = phase_labels), scales = "free_y") +
  xlab("Experiment section") +
  ylab("Average fly activity") +
  ggtitle("Mean activity by phase") +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        text = element_text(size = 20),
        axis.text.y = element_text(size = 14))

