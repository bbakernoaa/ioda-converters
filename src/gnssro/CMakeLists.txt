# ioda-converters/src/gnssro

if( bufrlib_FOUND and NetCDF_FOUND )
    add_executable(gnssro_bufr2ioda gnssro_bufr2ioda.f90)
    target_link_libraries(gnssro_bufr2ioda PUBLIC ${bufrlib_LIBRARIES})
    target_link_libraries(gnssro_bufr2ioda PUBLIC NetCDF::NetCDF_Fortran)
    install(TARGETS gnssro_bufr2ioda
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
    set_target_properties(gnssro_bufr2ioda PROPERTIES
                        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
endif()
