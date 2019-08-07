FC = ifort
NETCDF_LIB = -L$(NETCDF)/lib -lnetcdff -L$(NETCDF)/lib -Wl,-rpath -Wl,$(NETCDF)/lib -lnetcdf -lnetcdf
NETCDF_INC = -I/$(NETCDF)/include
FCFLAGS = -convert big_endian
FCFLAGS = -qopenmp -traceback
LDFLAGS = $(NETCDF_LIB) $(BUFR_LIBd) # $(NEMSIO_LIB) $(BACIO_LIB4) $(W3NCO_LIB4) $(CRTM_LIB) 
INCFLAGS = $(NETCDF_INC)# -I$(NEMSIO_INC) -I$(CRTM_INC) 
EXECUTABLE = bufr2ioda 

objects = \
	bufr2ioda.o\
        bufrio_bufr2ioda.o\
	init_bufr2ioda.o

bufr2ioda: $(objects)
	$(FC) -o $(EXECUTABLE) $(objects) $(FCFLAGS) $(LDFLAGS) $(INCFLAGS)

bufr2ioda.o: init_bufr2ioda.o\
		bufrio_bufr2ioda.o
bufrio_bufr2ioda.o: init_bufr2ioda.o

%.o: %.f90
	$(FC) $(FCFLAGS) -c $< $(INCFLAGS) $(LDFLAGS) -o $@ -module $(BUILDDIR)
%: %.o
	$(FC) $(FCFLAGS) -o $@ $^ $(LDFLAGS) $(INCFLAGS)

clean:
	rm $(EXECUTABLE) *.mod *.o 
