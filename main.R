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
    round(rexp(n = 1, rate = 1 / 20), digits = 2)
  }) %>%
  timeout(function() {
    get_attribute(airport, "activity_time")
  }) %>%
  release("lane") %>%
  log_("Finished") %>%
  log_(function() {
    spent_time <-
      get_attribute(airport, "waiting_time") +
      get_attribute(airport, "activity_time")
    paste("Total: \t", spent_time)
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
airport_resources <- get_mon_resources(airport)
airport_attributes <- get_mon_attributes(airport)
airport_arrivals <- get_mon_arrivals(airport) %>%
  transform(
    name = name,
    start_time = start_time,
    end_time = end_time,
    service_time = activity_time,
    waiting_time = (function() {
      x <- round(end_time - start_time - activity_time, digits = 2)
      ifelse(x > 0, x, 0)
    })(),
    activity_time = NULL,
    finished = NULL,
    replication = NULL
  )

writeLines("\n\n>>>> Minitoring\n")
print(airport_arrivals)
write.csv(airport_arrivals, file = "assets/arrivals.csv")


# Plot
result <- tryCatch(
  expr <- function() {
    activity_time_path <- "assets/activity_time.png"
    png(filename = activity_time_path)
    activity_time_hist <- hist(
      x = airport_arrivals$activity_time,
      main = "Activity Times Frequency",
      xlab = "Activity Time",
      col = "#008900",
      border = "#004900",
      breaks = 10,
    )
    dev.off()

    waiting_time_path <- "assets/waiting_time.png"
    png(filename = waiting_time_path)
    waiting_time_hist <- hist(
      x = airport_arrivals$waiting_time,
      main = "Waiting Times Frequency",
      xlab = "Waiting Time",
      col = "#9a0052",
      border = "#630035",
      breaks = 10,
    )
    dev.off()

    total_time_path <- "assets/total_time.png"
    png(filename = total_time_path)
    total_time_hist <- hist(
      x = airport_arrivals$activity_time + airport_arrivals$waiting_time,
      main = "Total Times Frequency",
      xlab = "Total Time",
      col = "#b36900",
      border = "#7d4900",
      breaks = 10,
    )
    dev.off()

    if (.Platform$OS.type != "unix") {
      shell.exec(file.path(getwd(), activity_time_path))
      shell.exec(file.path(getwd(), waiting_time_path))
      shell.exec(file.path(getwd(), total_time_path))
    }
  },
  warning = function(cond) {
    message(cond)
  },
  error = function(cond) {
    message(cond)
  }
)

plot(bank,
  what = "resources",
  metric = "usage",
  names = "counter",
  items = "system",
  steps = TRUE
)
