#
# IODA-converters
# Copyright and License: see LICENSE

cmake_minimum_required( VERSION 3.12 )
project( iodaconv LANGUAGES CXX Fortran )

## Ecbuild integration
include( ecbuild_system NO_POLICY_SCOPE )
ecbuild_declare_project()
list( APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake )
set( CMAKE_DIRECTORY_LABELS ${PROJECT_NAME} )

## Configuration options
include( ${PROJECT_NAME}_compiler_flags )
include( ${PROJECT_NAME}_extra_macros )
include( GNUInstallDirs )
set( PYIODACONV_BUILD_LIBDIR   ${CMAKE_BINARY_DIR}/lib/pyiodaconv )
set( PYIODACONV_INSTALL_LIBDIR ${CMAKE_INSTALL_PREFIX}/lib/pyiodaconv )
set( IODACONV_PYLINT_CFG_DIR ${CMAKE_CURRENT_SOURCE_DIR} )
## Dependencies
ecbuild_find_python( REQUIRED )
find_package(NetCDF REQUIRED COMPONENTS Fortran)

#Optional dependencies
find_package(odb_api QUIET)
find_package(bufrlib QUIET)
find_package(odc QUIET)
find_package(odyssey QUIET)

if (HAVE_ODB_API)
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -DHAVE_ODB_API")
endif (HAVE_ODB_API)

## Sources
add_subdirectory( src )
add_subdirectory( tools )
add_subdirectory( test )

## Package Config
ecbuild_install_project( NAME ${PROJECT_NAME} )

ecbuild_print_summary()
