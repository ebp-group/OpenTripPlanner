
# Introduction

This readme describes how to set up OpenTripPlanner (OTP) with R to perform routing requests and accessibility analysis. The package OpenTripPlanner for R is used here. The Package provides wrappers for making http POST requests to a local OTP server as well as functions used for building a graph and loading it. All is based on a runnable Java JAR file which was created by myself based on the current development Java OTP developer version (as of April 2020).

Functionalities directly available from the OpenTripPlanner R package:

-Routing for all modes as well as for combination of modes (intermodal trips) from point to point (in WGS84 coordinates).

-Option to customize routing based on several parameters.

-Construction of isochrones for transit, walk, bike (not car): see Example

-Saving shapes of routes and isochrones as sf spatial objects.

Functionalities which are extendable from the OpenTripPlanner R package:

-Virtually any type of accessibility analysis at any scale.

# Installation of resources

#### Java

First, Java 8 needs to be installed on the machine to run OTP (IMPORTANT: do not install a higher or lower version of Java). To check the installed java version, open the Command Prompt in Windows and type:

_java -version_

As a response, I get:

_java version &quot;1.8.0\_241&quot;_

_Java(TM) SE Runtime Environment (build 1.8.0\_241-b07)_

_Java HotSpot(TM) 64-Bit Server VM (build 25.241-b07, mixed mode)_

#### JAR File

A JAR File is a runnable Java program from outside a Java development environment. It is run from the Windows command prompt. When building a graph or starting it, the R functions from the opentripplanner package basically send commands through the Command prompt.

Pre-built JARs can directly be downloaded from MAVEN online:

[https://repo1.maven.org/maven2/org/opentripplanner/otp/](https://repo1.maven.org/maven2/org/opentripplanner/otp/)

As of today (June 2020) the most actual version there has a bug preventing to integrating elevation data for graph construction though. For this reason, I created an own .jar Snapshot from the most actual development version from IBI-Group were this bug was fixed:

[https://github.com/ibi-group/OpenTripPlanner](https://github.com/ibi-group/OpenTripPlanner)

The .jar file is available in this repository. 

As long as elevation data is unimportant for routing (eg. no hills in the study area possibly affecting routing for slow modes) the actual version from Maven can directly be downloaded.


#### OpenTripPlanner for R

Researchers at the University of Leeds created a great R package containing wrappers for building graphs, loading them, performing detailed routing requests and saving all results. It also contains the option to increase performance for batch requests, reducing computing time.

The actual version can be downloaded from:

[https://github.com/ropensci/opentripplanner](https://github.com/ropensci/opentripplanner)

For starting to understand the functioning of OTP, this tutorial is recommended:

[https://github.com/marcusyoung/otp-tutorial/blob/master/intro-otp.pdf](https://github.com/marcusyoung/otp-tutorial/blob/master/intro-otp.pdf)

IMPORTANT: The tutorial above is based on the otpr package which has different functions than the opentripplanner package. The opentripplanner package provides the same functions than the otpr package, only with different names and more functionalities. For route requests, both basically make a http GET request, which could as well be send directly using functions from the httr package


# Creating a graph

A graph can be created in R using the otp\_build\_graph() function. To create a graph, a main folder has to be created with a subfolder named &quot;graphs&quot; which contains folders with the names of each graph. In my case this looks something like:

OTP/graphs/CH2019Elev

In the CH2019Elev folder I placed three files:

- OpenStreetMap file in pbf format.
- Zipped GTFS dataset
- Elevation data in tif format.

Sources for the datasets are:

-OSM (Worldwide): [http://download.geofabrik.de/](http://download.geofabrik.de/)

-GTFS (Switzerland only): [https://opendata.swiss/de/](https://opendata.swiss/de/)

-Elevation (DACH countries): [http://data.opendataportal.at/dataset/a949dd6f-9f19-4727-872c-b70d35adb550](http://data.opendataportal.at/dataset/a949dd6f-9f19-4727-872c-b70d35adb550)

For Elevation, a 20m mesh is enough.

The graph creation process for Switzerland takes about 1h in my machine. Specs are:

Prozessor: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz, 2592 MHz, 6 Kern(e), 12 logische(r) Prozessor(en)

RAM: 40GB

System: 64bit

For creating a Swiss graph, it is recommended to allocate 30GB of RAM to the process. Definitely more than 20GB will be needed. For smaller areas, less should suffice as well. The most intensive data usage stems from the OpenStreetMap data which, at least for Switzerland, is extremely detailed. Making such a graph for larger areas than eg. Switzerland is not recommended.

#### Created Graph for Switzerland (Swiss EBP office only)
Ready to use graphs for Switzerland can be found under 

O:\OpenTripPlanner\Graphs


#### Issues with GTFS

Sometimes problems can occur with the graph construction due to GTFS data. As an example, a few lines in some Swiss GTFS functions had Route type ID&#39;s that were meant for Taxi. These need to be changed manually, eg. with an R script. The OTP graph constructor does not allow for such a mode, so the lines need to be either removed or the mode id changed to another one. Route types of GTFS data are available here:

[https://developers.google.com/transit/gtfs/reference/extended-route-types](https://developers.google.com/transit/gtfs/reference/extended-route-types)

An example script for correcting such errors is available here under AdaptGTFSforOTP.R


![](Images/1.JPG)

If included will not write Graph.obj file, but start server directly

Path to input files

JAR used

Memory allocation

If _-inMemory_ is used, the Grizzly server will start running on port 8080.


# Local server

The local server running locally has a GUI available at localhost:8080. It has several features, including personalized routing profiles as can be seen below for the example of bikes:

![](Images/2.jpg)

This feature is particularly important for validation of the results since it allows for a quick visualization of the routes.


# Validation of elevation data

Especially the routing for slow modes should be adapted in the Swiss case. This is exemplified below in the case of a bike route, which OTP standardly routes through hiking trails. As a comparison the OTP route is followed by Google Maps results for the same OD pair.

![](Images/3.jpg)

![](Images/4.jpg)

After increasing the weight of the &quot;bike friendly&quot; attribute, the following route is given by OTP, which is more realistic:

![](Images/5.jpg)

A quick comparison of travel times and values give the following results:

|   | km | Time (h) | climb | avg. km/h |
| --- | --- | --- | --- | --- |
| OTP (No elevation) | 7.79\* | 0.5 | 0m | 15.7 |
| OTP (Elevation) | 13.76 | 2.75 | 968m | 5.0 |
| GoogleMaps | 14.8 | 2.12 | 968m | 6.9 |

\*Direct route from first OTP route figure

OBSERVATION: The bike speed can be adjusted in an OTP routing profile. OpenTripPlanner for R provides a function for adjusting this manually. Therefore, the router profile can be adjusted to match GoogleMaps more closely, if it is decided that this should be a benchmark.


