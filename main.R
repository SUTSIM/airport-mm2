#!/usr/bin/env Rscript

# Simulation of an airport with two lanes and different interarrival rate,
# assuming a system of M/M/2.

library(simmer)
library(simmer.plot)
library(parallel)


seeds <- c(393943, 100005, 777999555, 1269)
mclapply(seeds, function(s) {
  set.seed(s)

  i <- which(seeds == s, arr.ind = TRUE)
  gen_path <- function(path) {
    gsub("0", i, path)
  }

  airport <- simmer()

  plane <-
    trajectory("Airplane's path") %>%
    set_attribute("start_time", function() {
      now(airport)
    }) %>%
    seize("lane") %>%
    set_attribute("waiting_time", function() {
      now(airport) - get_attribute(airport, "start_time")
    }) %>%
    set_attribute("activity_time", function() {
      round(rexp(n = 1, rate = 1 / 20), digits = 2)
    }) %>%
    timeout(function() {
      get_attribute(airport, "activity_time")
    }) %>%
    release("lane")

  airport <-
    simmer("airport") %>%
    add_resource("lane", 2) %>%
    add_generator("Airplane", plane, distribution = function() {
      c(0, rpois(n = 40, lambda = 21), -1)
    })

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

  write.csv(arrivals, file = gen_path("assets/arrivals0.csv"))


  # Plot
  activity_time_path <- gen_path("assets/activity_time0.png")
  png(filename = activity_time_path)
  hist(
    x = arrivals$activity_time,
    main = "Activity Times Frequency",
    xlab = "Activity Time",
    col = "#008900",
    border = "#004900",
    breaks = 10,
  )
  dev.off()

  waiting_time_path <- gen_path("assets/waiting_time0.png")
  png(filename = waiting_time_path)
  hist(
    x = arrivals$waiting_time,
    main = "Waiting Times Frequency",
    xlab = "Waiting Time",
    col = "#9a0052",
    border = "#630035",
    breaks = 10,
  )
  dev.off()

  total_time_path <- gen_path("assets/total_time0.png")
  png(filename = total_time_path)
  hist(
    x = arrivals$total_time,
    main = "Total Times Frequency",
    xlab = "Total Time",
    col = "#b36900",
    border = "#7d4900",
    breaks = 10,
  )
  dev.off()

  total_time_box_path <- gen_path("assets/total_time_box0.png")
  png(filename = total_time_box_path)
  boxplot(
    arrivals$total_time,
    main = "Boxplot Total Time",
    xlab = "Runs",
    ylab = "Total Time",
    col = "#00b3a1"
  )
  dev.off()

  sys_mon_path <- gen_path("assets/sys_mon0.png")
  png(filename = sys_mon_path)
  plot(
    airport,
    what = c("resources", "arrivals", "attributes"),
    metric = NULL,
    main = "Monitored",
  )
  dev.off()

  paint <- function() {
    res_usage_path <- gen_path("assets/res_usage0.png")
    png(filename = res_usage_path)
    x <- plot(resources,
      what = "resources",
      metric = "usage",
      names = "lane",
      items = "system",
      steps = TRUE
    )
    dev.off()
  }
  paint()


  paste(
    "Average wait for ", sum(arrivals$finished), " completions was ",
    mean(arrivals$waiting_time), "minutes."
  )
}) %>% unlist() # nolint
