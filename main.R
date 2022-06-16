# Simulation of an airport with two lanes and different interarrival rate,
# assuming a system of M/M/2.

library(simmer)
library(simmer.plot)

set.seed(1269)

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
    paste("Waited: \t\t\t", get_attribute(airport, "waiting_time"))
  }) %>%
  set_attribute("activity_time", function() {
    rexp(1, 1 / 12)
  }) %>%
  timeout(function() {
    get_attribute(airport, "activity_time")
  }) %>%
  release("lane") %>%
  log_(function() {
    spent_time <-
      get_attribute(airport, "waiting_time") +
      get_attribute(airport, "activity_time")
    paste("Finished, Total spent: \t", spent_time)
  })

airport <-
  simmer("airport") %>%
  add_resource("lane", 2) %>%
  add_generator("Airplane", plane, function() {
    c(0, rexp(4, 1 / 10), -1)
  })



# Run
writeLines("\n\n>>>> Events\n")
run_value <- run(airport, until = 400)

# Values
airport_resources <- get_mon_resources(airport)
airport_attributes <- get_mon_attributes(airport)
airport_arrivals <- get_mon_arrivals(airport) %>%
  transform(
    name = name,
    start_time = start_time,
    end_time = end_time,
    activity_time = activity_time,
    waiting_time = (function() {
      x <- end_time - start_time - activity_time
      ifelse(x > 0, x, 0)
    })(),
    finished = NULL,
    replication = NULL
  )


# Log
writeLines("\n\n>>>> Minitoring\n")
print(airport_arrivals)

# Plot
plot(
  x = airport_arrivals,
  metric = c("activity_time", "waiting_time", "flow_time")
)

warnings()
