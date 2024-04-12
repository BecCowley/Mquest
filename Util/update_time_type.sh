#!/bin/bash
# script to change the datatype of the Mquest netcdf variable "time" from float to double
# Bec Cowley, 12 April, 2024

for f in $(find ./CSIROXBT2024ant -name '*.nc'); do ncap2 -O -s 'time=double(time)' $f $f; done
