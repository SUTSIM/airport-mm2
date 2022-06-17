#!/usr/bin/env Rscript

# Simulation of an airport with two lanes and different interarrival rate,
# assuming a system of M/M/2.

library(simmer)
library(simmer.plot)

set.seed(1269)
airport <- simmer()

plane <-
  trajectory("Airplane's path") %>%
  log_("Arrive") %>%
  set_attribute("start_time", function() {
    now(airport)
  }) %>%
  seize("lane") %>%
  set_attribute("waiting_time", function() {
    now(airport) - get_attribute(airport, "start_time")
  }) %>%
  log_(function() {
    paste("Waited: \t", get_attribute(airport, "waiting_time"))
  }) %>%
  set_attribute("activity_time", function() {
    round(rexp(n = 1, rate = 1 / 25), digits = 2)
  }) %>%
  timeout(function() {
    get_attribute(airport, "activity_time")
  }) %>%
  release("lane") %>%
  log_("Finished") %>%
  log_(function() {
    total_time <-
      get_attribute(airport, "waiting_time") +
      get_attribute(airport, "activity_time")
    paste("Total: \t", total_time)
  })

airport <-
  simmer("airport") %>%
  add_resource("lane", 2) %>%
  add_generator("Airplane", plane, distribution = function() {
    c(0, rpois(n = 40, lambda = 21), -1)
  })



# Run
writeLines("\n>>>> Events\n")
run_value <- run(airport, until = 1000)

# Monitored values
resources <- get_mon_resources(airport)
attributes <- get_mon_attributes(airport)
arrivals <- get_mon_arrivals(airport) %>%
  transform(
    waiting_time = (function() {
      x <- round(end_time - start_time - activity_time, digits = 2)
      ifelse(x > 0, x, 0)
    })(),
    total_time = (function() {
      x <- round(end_time - start_time, digits = 2)
      ifelse(x > 0, x, 0)
    })()
  )

write.csv(arrivals, file = "assets/arrivals.csv")
writeLines("\n\n>>>> Minitoring\n")
df <- subset(arrivals, select = -c(replication, finished))
print(df)


# Plot
activity_time_path <- "assets/activity_time.png"
png(filename = activity_time_path)
hist(
  x = arrivals$activity_time,
  main = "Activity Times Frequency",
  xlab = "Activity Time",
  col = "#008900",
  border = "#004900",
  breaks = 10,
)
x <- dev.off()


waiting_time_path <- "assets/waiting_time.png"
png(filename = waiting_time_path)
hist(
  x = arrivals$waiting_time,
  main = "Waiting Times Frequency",
  xlab = "Waiting Time",
  col = "#9a0052",
  border = "#630035",
  breaks = 10,
)
x <- dev.off()


total_time_path <- "assets/total_time.png"
png(filename = total_time_path)
hist(
  x = arrivals$total_time,
  main = "Total Times Frequency",
  xlab = "Total Time",
  col = "#b36900",
  border = "#7d4900",
  breaks = 10,
)
x <- dev.off()
dataaa <- cbind(arrivals$total_time, arrivals$waiting_time)
ticks <- c("time", "wait")
total_time_box_path <- "assets/total_time_box.png"
png(filename = total_time_box_path)
boxplot(
  dataaa,
  # beside = T,
  # xaxp = c("time", "wait", "2"),
  main = "Boxplot Total Time",
  xlab = "Runs",
  xaxt = "n",
  ylab = "Total Time",
  col = "#00b3a1"
)
axis(1, at = 1:2, labels = c("total time", "waiting time"))
x <- dev.off()

options(warn = -1)
sys_mon_path <- "assets/sys_mon.png"
png(filename = sys_mon_path)
plot(
  airport,
  what = c("resources", "arrivals", "attributes"),
  metric = NULL,
  main = "Monitored",
)
x <- dev.off()

res_usage_path <- "assets/res_usage.png"
png(filename = res_usage_path)
plot(resources,
  what = "resources",
  metric = "usage",
  names = "lane",
  items = "system",
  steps = TRUE
)
x <- dev.off()
print(arrivals$waiting_time)
# if (.Platform$OS.type != "unix") {
#   shell.exec(file.path(getwd(), activity_time_path))
#   shell.exec(file.path(getwd(), waiting_time_path))
#   shell.exec(file.path(getwd(), total_time_path))
# }
