#!/bin/sh

module purge
module load intel/18.1.163
module load netcdf/4.6.1

ifort -c  read_nc_combine_sst_IODA.f  -I/scratch3/NCEPDEV/nwprod/lib `nc-config --fflags --flibs --libs`
ifort -o read_nc_sst_IODA read_nc_combine_sst_IODA.o -L/scratch3/NCEPDEV/nwprod/lib -lw3nco_4 -lw3emc_4  `nc-config --fflags --flibs --libs`
