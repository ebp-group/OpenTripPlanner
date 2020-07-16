############
# Primary Author: Jenna Goldberg
# Last Editor: 
# Creation date: 04/28/2020
# Last Modified: 05/14/2020

# Depends on:

# Change Log:
# 05/05 - JG : Used purr package to cut down script significantly 
# 05/14 - JG :  iterations on adding time periods to analysis 

#libraries
library(here)
library(opentripplanner) 
library(otpr)
library(tidyverse)

path_data <- getwd()

path_otp <- paste0(path_data, "/otp.jar")

#path_otp <- otp_dl_jar(path_data)

#log1 <- otp_build_graph(otp = path_otp, dir = paste0(path_data, "/OTP"), memory = 10240)

log2 <- otp_setup(otp = path_otp, dir = paste0(path_data, "/OTP"))

otpcon <- otp_connect()

ann_arbor_tracts <- 
c("403100", "403800", "403600",
  "402700", "402500", "402600",
  "402200", "402100", "403200", 
  "403400", "403500", "403300",
  "400700", "400800", "400100",
  "400200", "400600", "400500",
  "400400", "400300", "402300",
  "405400", "405300", "405200",
  "405100", "405500", "405600",
  "404600", "404500", "404400",
  "404300", "404200", "404100")

full_tract_ids <- 
  paste0("26161", ann_arbor_tracts)

city_tract_centroids <- 
  read.csv(here("Data", "Michigan_Tract_Centroids.txt")) %>% 
  filter(COUNTYFP == "161" & 
           TRACTCE %in% ann_arbor_tracts) %>% 
  mutate(id = as.character(seq(1:n())))

#from_place <- 
#  city_tract_centroids %>% 
#  select(LATITUDE, LONGITUDE)

#from_place <- data.matrix(from_place)

county_tract_centroids <- 
  read.csv(here("Data", "Michigan_Tract_Centroids.txt")) %>% 
  filter(COUNTYFP == "161") %>% 
  mutate(id = as.character(seq(1:n())))

#to_place <- 
#  county_tract_centroids %>% 
#  select(LATITUDE, LONGITUDE)

#to_place <- data.matrix(to_place)

#test <- 
#  otp_plan(otpcon, 
#           fromPlace = to_place,
#           toPlace = to_place,
#           fromID = county_tract_centroids$id,
#           toID = county_tract_centroids$id,
#           mode = "TRANSIT",
#           maxWalkDistance = 10000000000,
#           get_geometry = FALSE)

full_time1 <- 
  c("00:00:00",
    "00:45:00",
    "01:30:00",
    "02:15:00")

full_time2 <- 
  c("03:00:00",
    "03:45:00",
    "04:30:30",
    "05:15:00")

full_time3 <- 
  c("06:00:00",
    "06:45:00",
    "07:30:00",
    "08:15:00")

full_time4 <- 
  c("09:00:00",
    "09:45:00",
    "10:30:00",
    "11:15:00")

full_time5 <- 
  c("12:00:00",
    "12:45:00",
    "13:30:00",
    "14:15:00")

full_time6 <- 
  c("15:00:00",
    "15:45:00",
    "16:30:00",
    "17:15:00")

full_time7 <- 
  c("18:00:00",
    "18:45:00",
    "19:30:00",
    "20:15:00")
full_time8 <- 
  c("21:00:00",
    "21:45:00",
    "22:30:00",
    "23:15:00")

weekday <- "10-16-2019"
weekend <- "10-12-2019"
  
cross_vectors <- 
  list(id1 = 1:33,
       id2 = 1:100,
       time = full_time8
       ) %>% 
  cross_df() %>% 
  filter(id1 != id2) %>% 
  mutate(num = as.character(row_number()))

get_times <- function(id1, id2, time) {
  run <- otpr::otp_get_times(otpcon,
                      c(city_tract_centroids$LATITUDE[id1], city_tract_centroids$LONGITUDE[id1]),
                      c(county_tract_centroids$LATITUDE[id2], county_tract_centroids$LONGITUDE[id2]),
                      maxWalkDistance = 100000000, 
                      walkReluctance = 1,
                      date = weekday, 
                      time = time,
                      mode = "TRANSIT") %>% 
    append(c(id1 = id1, 
            id2 = id2,
            time = time))
  if(run[1] == "OK") {
    run
  }
}

get_times(1, 95, "00:00:00")

#speed test : 6.38 min to go 0.3 miles = ~ 3mph walking speed
# same trip by bike = 1.9min, ~ 11mph 
Sys.time()
all_times <- 
  pmap_dfr(list(cross_vectors$id1, cross_vectors$id2, cross_vectors$time), get_times,
           .id = NULL)
Sys.time()

test_all_times <- 
  all_times %>% 
  pull(id2) %>% 
  unique()

write.csv(all_times, here("Data", paste0("transit_travel_times_pt8_",
                                         Sys.Date(), ".csv")),
          row.names = F)
#no errors in 0:3
#no error in 4:7
# no error in 8:11
#ERROR 12:15 
#no error 16:19
#no error 20:23


#read in all the files generated above 
times_1 <- 
  read.csv(here("Data",
                "transit_travel_times_pt1_2020-06-23.csv"))
times_2 <- 
  read.csv(here("Data",
                "transit_travel_times_pt2_2020-06-24.csv"))
times_3 <- 
  read.csv(here("Data",
                "transit_travel_times_pt3_2020-06-24.csv"))
times_4 <- 
  read.csv(here("Data",
                "transit_travel_times_pt4_2020-06-25.csv"))
times_5 <- 
  read.csv(here("Data",
                "transit_travel_times_pt5_2020-06-26.csv"))
times_6 <- 
  read.csv(here("Data",
                "transit_travel_times_pt6_2020-06-26.csv"))
times_7 <- 
  read.csv(here("Data",
                "transit_travel_times_pt7_2020-06-29.csv"))
times_8 <- 
  read.csv(here("Data",
                "transit_travel_times_pt8_2020-06-29.csv"))

all_time_values <- 
  c(full_time1, full_time2,
    full_time3, full_time4,
    full_time5, full_time6,
    full_time7, full_time8)

all_possible_combos <- 
  list(id1 = 1:33,
       id2 = 1:100,
       time = all_time_values
  ) %>% 
  cross_df() %>% 
  filter(id1 != id2) 

all_times_full <- 
  bind_rows(times_1, times_2,
            times_3, times_4,
            times_5, times_6,
            times_7, times_8) %>% 
  full_join(all_possible_combos) %>% 
  mutate(hour = as.numeric(substr(time, 1, 2)), 
         time_period = case_when(
           hour >= 6 & hour < 9 ~ "6-9am",
           hour >= 9 & hour < 16 ~ "9am-4pm",
           hour >= 16 & hour < 19 ~ "4-7pm",
           hour >= 19 | hour == 0 ~ "7pm-1am",
           hour >= 1 & hour < 6 ~ "1-6am"
         ))

# Get walk times #####

cross_vectors <- 
  list(id1 = 1:33,
       id2 = 1:100
  ) %>% 
  cross_df() %>% 
  filter(id1 != id2) %>% 
  mutate(num = as.character(row_number()))

get_dist_walk <- function(id1, id2) {
  otpr::otp_get_distance(otpcon,
                      c(city_tract_centroids$LATITUDE[id1], city_tract_centroids$LONGITUDE[id1]),
                      c(county_tract_centroids$LATITUDE[id2], county_tract_centroids$LONGITUDE[id2]),
                      mode = "WALK") %>% 
    append(c(id1 = id1, 
             id2 = id2))
}

get_dist_walk(1, 33)

#speed test : 6.38 min to go 0.3 miles = ~ 3mph walking speed
# same trip by bike = 1.9min, ~ 11mph 

all_dist_walk <- 
  pmap_dfr(list(cross_vectors$id1, cross_vectors$id2), get_dist_walk,
           .id = NULL)


county_tract_ids <- 
  county_tract_centroids %>% 
  mutate(GEOID = paste0(STATEFP, COUNTYFP, TRACTCE)) %>% 
  select(id, GEOID)

city_tract_ids <- 
  city_tract_centroids %>% 
  mutate(GEOID = paste0(STATEFP, COUNTYFP, TRACTCE)) %>% 
  select(id, GEOID)


all_dist_walk_clean <- 
  all_dist_walk %>% 
  left_join(city_tract_ids, by = c("id1" = "id")) %>% 
  select(
         start_geoid = GEOID, 
         id2, 
         distance_meters = distance) %>% 
  left_join(county_tract_ids, by = c("id2" = "id")) %>% 
  select(
         start_geoid, 
         end_geoid = GEOID,
         distance_meters) 

write.csv(
  all_dist_walk_clean,
  here("Data", paste0("walk_travel_distances_", Sys.Date(), ".csv")))
# get bike times #####
cross_vectors <- 
  list(id1 = 1:33,
       id2 = 1:100,
  ) %>% 
  cross_df() %>% 
  filter(id1 != id2) %>% 
  mutate(num = as.character(row_number()))

get_dist_bike <- function(id1, id2) {
  otpr::otp_get_distance(otpcon,
                      c(city_tract_centroids$LATITUDE[id1], city_tract_centroids$LONGITUDE[id1]),
                      c(county_tract_centroids$LATITUDE[id2], county_tract_centroids$LONGITUDE[id2]),
                      mode = "BICYCLE") %>% 
    append(c(id1 = id1, 
             id2 = id2))
}

get_dist_bike(1, 33)

#speed test : 6.38 min to go 0.3 miles = ~ 3mph walking speed
# same trip by bike = 1.9min, ~ 11mph 

all_dist_bike <- 
  pmap_dfr(list(cross_vectors$id1, cross_vectors$id2), get_dist_bike,
           .id = NULL)


all_dist_bike_clean <- 
  all_dist_bike %>% 
  left_join(city_tract_ids, by = c("id1" = "id")) %>% 
  select(
         start_geoid = GEOID, 
         id2, 
         distance_meters = distance) %>% 
  left_join(county_tract_ids, by = c("id2" = "id")) %>% 
  select(
         start_geoid, 
         end_geoid = GEOID,
         distance_meters) 

write.csv(
  all_dist_bike_clean,
  here("Data", paste0("bike_travel_distances_", Sys.Date(), ".csv")))

test_bike_walk_equal <- 
  inner_join(all_dist_bike_clean, all_dist_walk_clean,
             by = c("start_geoid", "end_geoid")) %>% 
  filter(distance_meters.x != distance_meters.y)
####

otp_stop()


tract_ids <- 
  tract_centroids %>% 
  mutate(GEOID = paste0(STATEFP, COUNTYFP, TRACTCE)) %>% 
  select(id, GEOID)

all_times_clean <- 
  all_times_full %>% 
  mutate(id1 = as.character(id1),
         id2 = as.character(id2)) %>% 
  left_join(city_tract_ids, by = c("id1" = "id")) %>% 
  select(time_period,
         time,
         start_geoid = GEOID, 
         id2, 
         duration) %>% 
  left_join(county_tract_ids, by = c("id2" = "id")) %>% 
  select(time_period,
         time,
         start_geoid, 
         end_geoid = GEOID,
         duration) 

all_times_collapsed <- 
  all_times_clean %>% 
  group_by(time_period, start_geoid, end_geoid) %>% 
  summarise(avg_duration = mean(duration, na.rm = T),
            median = median(duration, na.rm = T),
            min = min(duration, na.rm = T),
            q1 = quantile(duration, 0.25, na.rm = T),
            q3 = quantile(duration, 0.75, na.rm = T),
            max = max(duration, na.rm = T)
            ) %>% 
  mutate(min = ifelse(is.infinite(min), NA, min),
         max = ifelse(is.infinite(max), NA, max))

write.csv(all_times_clean,
          here("Data", paste0("transit_travel_times_long_", Sys.Date(), ".csv")),
          row.names = FALSE)

write.csv(all_times_collapsed,
          here("Data", paste0("transit_travel_times_collapsed_", Sys.Date(), ".csv")),
          row.names = FALSE)


test_always_same <- 
  all_times_clean %>% 
  filter(min == max)
