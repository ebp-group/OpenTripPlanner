rm(list = ls())

library(tidytransit)
library(gtfsr)

setwd("C:\\Users\\lmf\\Desktop\\Osmosis\\Inputs Switzerland")

gtfs <- tidytransit::read_gtfs("gtfsfp20202020-01-29.zip")

#________________________________________________________________________________________________________________________________________________________
#Make necesarry changes to GTFS data
gtfs_ch <- import_gtfs("gtfsfp20202020-01-29.zip", local=T)


routes <- setDT(gtfs_ch$routes_df, keep.rownames=FALSE) 
trips <- setDT(gtfs_ch$trips_df, keep.rownames=FALSE) 
agencies <- setDT(gtfs_ch$agency_df, keep.rownames=FALSE) 


#Replace Taxi-services by Local Bus-Services(not supported by OTP)
routes$route_type <- ifelse(routes$route_type>1450, "704", routes$route_type)
routes$route_desc <- ifelse(routes$route_desc=="Taxi", "Local Bus Service", routes$route_desc)

routes$agency_id <- ifelse(routes$agency_id=="", "06", routes$agency_id)

#Complete empty route name

routes$agency_id <- ifelse(routes$agency_id==6, "06", routes$agency_id)

test <- routes[3240,]

write.table(routes, "routes.txt", sep=",", quote=T,row.names = F)
#________________________________________________________________________________________________________________________________________________________

# 
# stops <- gtfs$stops
# stop_times <- gtfs$stop_times
# transfers <- gtfs$transfers
# agency <- gtfs$agency
# routes <- gtfs$routes
# trips <- gtfs$trips
# feed_info <- gtfs$feed_info
# calendar <- gtfs$calendar
# calendar_dates <- gtfs$calendar_dates
# 
# 
# routes$route_type <- ifelse(routes$route_type>1400 & routes$route_type<1700, 700, routes$route_type)
# 
# name <- "GTFS_Switzerland_OTP"
# dir.create(name)
# 
# setwd(paste("C:\\Users\\lmf\\Desktop\\Osmosis\\Inputs Switzerland", name, sep="\\"))
# 
# 
# calendar$start_date <- gsub("-","",calendar$start_date)
# calendar$end_date <- gsub("-","",calendar$end_date)
# 
# calendar_dates$date <- gsub("-","",calendar_dates$date)
# 
# 
# stops[is.na(stops)] <- ""
# stop_times[is.na(stop_times)] <- ""
# transfers[is.na(transfers)] <- ""
# agency[is.na(agency)] <- ""
# routes[is.na(routes)] <- ""
# trips[is.na(trips)] <- ""
# feed_info[is.na(feed_info)] <- ""
# calendar[is.na(calendar)] <- ""
# calendar_dates[is.na(calendar_dates)] <- ""
# 
# stops[] <- lapply(stops, as.character)
# stop_times[] <- lapply(stop_times, as.character)
# transfers[] <- lapply(transfers, as.character)
# trips[] <- lapply(trips, as.character)
# routes[] <- lapply(routes, as.character)
# feed_info[] <- lapply(feed_info, as.character)
# agency[] <- lapply(agency, as.character)
# calendar[] <- lapply(calendar, as.character)
# calendar_dates[] <- lapply(calendar_dates, as.character)
# 
# 
# write.table(stops, "stops.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# write.table(stop_times, "stop_times.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# write.table(transfers, "transfers.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# write.table(routes, "routes.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# write.table(trips, "trips.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# write.table(feed_info ,"feed_info.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# write.table(calendar, "calendar.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# write.table(calendar_dates,"calendar_dates.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# write.table(agency, "agency.txt", quote=T, sep=",", fileEncoding = "UTF-8", row.names = F)
# 
# 
# files2zip <- dir(getwd())
# 
# zip::zipr(zipfile=paste(name, "zip", sep="."), files=files2zip)
