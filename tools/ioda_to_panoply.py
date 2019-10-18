#!/usr/bin/env python

from __future__ import print_function
import sys
import os
import re
import argparse
import numpy as np
import netCDF4
from netCDF4 import Dataset

LAT_NAME = 'latitude'
LON_NAME = 'longitude'
LOCS_NAME = 'nlocs'

###########################################################################
# SUBROUTINES
###########################################################################

###########################################################################
# MAIN
###########################################################################
ScriptName = os.path.basename(sys.argv[0])

# Parse command line
ap = argparse.ArgumentParser()

# Main arguments
ap.add_argument("input_ioda_file", help="path to input ioda file")
ap.add_argument("lon_variable", help="longitude vector")
ap.add_argument("lat_variable", help="latitude vector")
ap.add_argument("variable", help="data vector")
ap.add_argument("output_panoply_file", help="path to output panoply file")
ap.add_argument("-c", "--clobber", action="store_true",
                help="allow overwrite of output file")
ap.add_argument("-s", "--sample", type=int, default=0, help="sample every nth point")


MyArgs = ap.parse_args()

InFname = MyArgs.input_ioda_file
OutFname = MyArgs.output_panoply_file
LonVname = MyArgs.lon_variable
LatVname = MyArgs.lat_variable
Vname = MyArgs.variable
ClobberOfile = MyArgs.clobber
Sample = MyArgs.sample

# Check files
BadArgs = False

# Verify that the input files exist
if (not os.path.isfile(InFname)):
    print("ERROR: {0:s}: Input file does not exist: {1:s}".format(ScriptName, InFname))
    BadArgs = True

# Verify if okay to write to the output files
if (os.path.isfile(OutFname)):
    if (ClobberOfile):
        print("WARNING: {0:s}: Overwriting ioda file: {1:s}".format(ScriptName, OutFname))
        print("")
    else:
        print("ERROR: {0:s}: Specified ioda file already exists: {1:s}".format(ScriptName, OutFname))
        print("ERROR: {0:s}:   Use -c option to overwrite.".format(ScriptName))
        print("")
        BadArgs = True

if (BadArgs):
    sys.exit(2)

# Everything looks okay, forge on and plot the image.
print("Plotting netcdf image:")
print("  Input ioda file: {0:s}".format(InFname))
print("     Longitude: {0:s}".format(LonVname))
print("     Latitude: {0:s}".format(LatVname))
print("     Data: {0:s}".format(Vname))
print("     Sample: {0:d}".format(Sample))
print("  Output image file: {0:s}".format(OutFname))
print("")

# Get the data from the input file. The data is in an unstructured grid format
# meaning that there are vectors for x, y and z tuples. Panoply will handle
# an unstructured grid, so all we need to do is attach the COARDS style
# attributes onto the variables.
Fid = netCDF4.Dataset(InFname, 'r')

UgLon = Fid.variables[LonVname][:].astype('f4')
UgLat = Fid.variables[LatVname][:].astype('f4')
UgVar = Fid.variables[Vname][:].astype('f4')

Fid.close()

# Down sample the input data if the sample argument is more than 1 (every point)
if (Sample > 1):
    UgLon = UgLon[::Sample]
    UgLat = UgLat[::Sample]
    UgVar = UgVar[::Sample]

# Dump into the output file, and set the appropiate
# attributes for Panoply.
Nlocs = UgVar.size

Fid = netCDF4.Dataset(OutFname, 'w', format='NETCDF4')

Fid.createDimension(LOCS_NAME, Nlocs)

NcLats = Fid.createVariable(LAT_NAME, np.float, (LOCS_NAME,))
NcLats.long_name = LAT_NAME
NcLats.units = 'degrees_north'
NcLats[:] = UgLat

NcLons = Fid.createVariable(LON_NAME, np.float, (LOCS_NAME,))
NcLons.long_name = LON_NAME
NcLons.units = 'degrees_east'
NcLons[:] = UgLon

NcVar = Fid.createVariable('radiance', np.float, (LOCS_NAME))
NcVar.long_name = 'ABI L1b Radiances'
NcVar.units = 'W m-2 sr-1 um-1'
NcVar.coordinates = "{0:s} {1:s}".format(LON_NAME, LAT_NAME)
NcVar[:] = UgVar

Fid.close()

print("")
