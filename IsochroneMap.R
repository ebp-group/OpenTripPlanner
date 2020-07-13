rm(list = ls())
library(tmap)
library(tmaptools)

# If you do not already have the remotes package
# install.packages("remotes")
# Install the package from GitHub
install.packages("Rtools")
install.packages("devtools")
# Load the package
library(opentripplanner)
library(devtools)
library(progress)
library(otpr)
library(opentripplanner)
library(gtfsr)
library(httr)
library(gtfsr)
library(data.table)
library(leaflet)
library(rgdal)
library(geojson)
library(htmlwidgets)
getwd()

setwd("C:\\Users\\lmf\\Desktop\\OTPGraphEclipse")

getwd()

tpcon <- otp_connect(
  hostname = "localhost",
  router = "CH2019Elev",
  port = 8801)

otp_setup(otp = "C:\\Users\\lmf\\Desktop\\Osmosis\\bin\\otp-1.4.1-SNAPSHOT-shaded.jar", dir = getwd(), 
                  router="CH2019Elev", memory=30000, wait=T)


routingOptions <- otp_routing_options()
routingOptions$
  otp_stop(kill_all=T)

otp_plan()

otp_check_java()

otp_build_graph("C:\\Users\\lmf\\Desktop\\Osmosis\\bin\\otp-1.4.1-SNAPSHOT-shaded.jar", 
                dir=getwd(), router="CH2019",memory=29000)

otp_setup(otp = "C:\\Users\\lmf\\Desktop\\Osmosis\\bin\\otp-1.4.1-SNAPSHOT-shaded.jar", dir = getwd(), 
                  router="CH2019", memory=30000, wait=T)


view(otp_setup)
#________________________________________________________________________________________________________________________________________________________
#Make necesarry changes to GTFS data
gtfs_ch <- import_gtfs("gtfsfp20192019-09-11.zip", local=T)


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
#2. Generate the OTP Graph with Osmosis
#________________________________________________________________________________________________________________________________________________________
#
#3. Do analysis with requests to local API
otpcon <- otp_connect(hostname ="localhost",router ="default",
                      port =8080,ssl =FALSE)


# 1 Perform a routing request
zh_be <- otp_get_times(otpcon,fromPlace = c(47.36493, 8.55031),toPlace = c(46.95682, 7.45560),mode ="TRANSIT",detail =TRUE,date ="10-25-2019",
              time ="08:00:00",maxWalkDistance =1600,walkReluctance =5,
              minTransferTime =600)



#2 Get isochrones for Mühlebachstrasse 11
test <- otp_get_isochrone(otpcon, location= c(47.36493, 8.55031), cutoffs = c(1800, 2700, 3600, 5400), mode = "TRANSIT", date ="10-24-2019",
                          time ="09:59:00",maxWalkDistance =1800,walkReluctance =2,
                          minTransferTime =200, format="JSON")


write(test$response, file = "my_isochrone.geojson")


#Plot to a cool map: 
iso <- geojsonio::geojson_read("my_isochrone.geojson",
                               what = "sp")


pal=c('cyan','gold','tomato','red')

m<-leaflet(iso) %>%
  setView(lng = 8.55031, lat = 47.36493, zoom = 9) %>%
  addProviderTiles(providers$CartoDB.DarkMatter,
                   options = providerTileOptions(opacity = 0.8))%>%  
  addPolygons(stroke = TRUE, weight=0.5,
              smoothFactor = 0.5, color="black",
              fillOpacity = 0.23,fillColor =pal ) %>%
  addLegend(position="bottomleft",colors=rev(c("lightskyblue","greenyellow","gold","red")),
            labels=rev(c("90 min", "60 min","45 min",
                         "30 min")),
            opacity = 0.4,
            title="ÖV-Reisezeit ab Mühlebachstrasse 11
                    (Reisestart um 9:59)")


m

saveWidget(m, file="ÖV-Reisezeit ab Mühlebachstrasse 11.html")


devtools::install_github("ebp-group/OpenTripPlannerApplications")

