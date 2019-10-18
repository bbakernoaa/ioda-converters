#!/usr/bin/env python

from __future__ import print_function
import sys
import os
import re
import argparse
import numpy as np
import netCDF4
from netCDF4 import Dataset
import matplotlib.pyplot as plt

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
ap.add_argument("x_variable", help="coordinates for x-axis")
ap.add_argument("y_variable", help="coordinates for y-axis")
ap.add_argument("z_variable", help="data for contour plot")
ap.add_argument("output_image_file", help="path to output image file")
ap.add_argument("-c", "--clobber", action="store_true",
                help="allow overwrite of output file")


MyArgs = ap.parse_args()

InFname = MyArgs.input_ioda_file
OutFname = MyArgs.output_image_file
XvarName = MyArgs.x_variable
YvarName = MyArgs.y_variable
ZvarName = MyArgs.z_variable
ClobberOfile = MyArgs.clobber

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
print("     X: {0:s}".format(XvarName))
print("     Y: {0:s}".format(YvarName))
print("     Z: {0:s}".format(ZvarName))
print("  Output image file: {0:s}".format(OutFname))
print("")

# Get the data from the input file. The data is in an unstructured grid format
# meaning that there are vectors for x, y and z tuples.
Fid = netCDF4.Dataset(InFname, 'r')

X = Fid.variables[XvarName][:]
Y = Fid.variables[YvarName][:]
Z = Fid.variables[ZvarName][:]

Fid.close()

# Plot using the triangulated contour routine (for unstructured grids)

Fig, Ax = plt.subplots()
Ax.tricontourf(X, Y, Z, 20)
Fig.savefig(OutFname)
