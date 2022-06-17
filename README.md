# Airport MM2 Simulation

Simulation of an airport with two lanes and different interarrival rate, assuming a system of M/M/2

# How to Run?

#### Using Docker

- Open `terminal` in current directory.
- Run the following command to build container
  `$ docker build -t airport-sim .`

#### Using R-base

- If you have Rlang installed simply run
  `$ Rscript main.R`

# Final Generated Results

### Reports

[Arrivals data](assets/arrivals.csv)  
[Airrivals step-by-step log](assets/steps.log)

### Charts for Multiple Runs

<p align="left">
  <h5>Activity Times</h5>
  <img src="assets/activity_time1.png" width="45%"/>
  <img src="assets/activity_time2.png" width="45%"/>
  <img src="assets/activity_time3.png" width="45%"/>
  <img src="assets/activity_time4.png" width="45%"/>

  <h5>Waiting Times</h5>
  <img src="assets/waiting_time1.png" width="45%"/>
  <img src="assets/waiting_time2.png" width="45%"/>
  <img src="assets/waiting_time3.png" width="45%"/>
  <img src="assets/waiting_time4.png" width="45%"/>
  
  <h5>Total Times</h5>
  <img src="assets/total_time1.png" width="45%"/>
  <img src="assets/total_time2.png" width="45%"/>
  <img src="assets/total_time3.png" width="45%"/>
  <img src="assets/total_time4.png" width="45%"/>

  <h5>Total Times - Boxplot</h5>
  <img src="assets/total_time_box1.png" width="45%"/>
  <img src="assets/total_time_box2.png" width="45%"/>
  <img src="assets/total_time_box3.png" width="45%"/>
  <img src="assets/total_time_box4.png" width="45%"/>
  
  <h5>Resource Usage</h5>
  <img src="assets/mon1.png" width="45%"/>
  <img src="assets/mon2.png" width="45%"/>
  <img src="assets/mon3.png" width="45%"/>
  <img src="assets/mon4.png" width="45%"/>
  
  <h5>Resource Usage</h5>
  <img src="assets/res_usage1.png" width="45%"/>
  <img src="assets/res_usage2.png" width="45%"/>
  <img src="assets/res_usage3.png" width="45%"/>
  <img src="assets/res_usage4.png" width="45%"/>
</p>
