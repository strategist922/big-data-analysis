# This script is to be used for testing sparkr and sparklyr connection on standalone pc.
# script created on: 27/5/2017

# Load the libraries
library(sparklyr)
library(nycflights13)

#details of my session
sessionInfo()

# install spark on local machine
sparklyr::spark_install()

# Start spark cluster on local machine
sc<- spark_connect(master = "local")
