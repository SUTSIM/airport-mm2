# Simulation of an airport with two lanes and different interarrival rate,
# assuming a system of M/M/2.
# The system is modeled as a queue with a single server.
# The queue is modeled as a FIFO queue.

library(simmer)

customer <-
  trajectory("Customer's path") %>%
  log_("Here I am") %>%
  timeout(10) %>%
  log_("I must leave")

bank <-
  simmer("bank") %>%
  add_generator("Customer", customer, at(5))

bank %>% run(until = 100)
bank %>% get_mon_arrivals()
