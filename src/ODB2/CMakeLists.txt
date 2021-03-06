list( APPEND libs
  var_convert.py)

list( APPEND programs
  odbapi2nc.py
  odbapi2json.py)

list( APPEND configs
  MO_aircraft_16026_Definition.yaml
  MO_aircraft_16029_Definition.yaml
  MO_amsua_Definition.yaml
  MO_radiosonde_Definition.yaml
  era5_16013_16015_Definition.yaml
  era5_16022_16045_Definition.yaml
  era5_aircraft_Definition.yaml )

set ( ODB2_PYCODESTYLE_CONFIG ${CMAKE_CURRENT_SOURCE_DIR} )

SET_TARGETS_DEPS( "${libs}"
                   ${CMAKE_CURRENT_SOURCE_DIR}
                   ${PYIODACONV_BUILD_LIBDIR}
                   odb2_scripts_deps)
add_custom_target( odb2_scripts ALL DEPENDS ${odb2_scripts_deps} )

set( SCRIPT_LIB_PATH ${PYIODACONV_BUILD_LIBDIR} )
CONF_TARGETS_DEPS( "${programs}"
                   ${CMAKE_CURRENT_SOURCE_DIR}
                   ${CMAKE_BINARY_DIR}/bin
                   bin_odb2_scripts_deps)
add_custom_target( bin_odb2_scripts ALL
    COMMAND chmod +x ${bin_odb2_scripts_deps}
    DEPENDS ${bin_odb2_scripts_deps} )

# Configure files for install prefix bin
set( SCRIPT_LIB_PATH ${PYIODACONV_INSTALL_LIBDIR} )
CONF_TARGETS_DEPS( "${programs}"
                   ${CMAKE_CURRENT_SOURCE_DIR}
                   ${CMAKE_BINARY_DIR}/install-bin
                   install_bin_odb2_scripts_deps)
add_custom_target( install_bin_odb2_scripts ALL
    COMMAND chmod +x ${install_bin_odb2_scripts_deps}
    DEPENDS ${install_bin_odb2_scripts_deps} )

# ODB "definition" files which are configurations for the odbapi2nc.py script.
COPY_FILES( "${configs}"
            ${CMAKE_CURRENT_SOURCE_DIR}/Definitions
            ${CMAKE_BINARY_DIR}/etc/pyiodaconv )

install( PROGRAMS
  ${install_bin_odb2_scripts_deps}
  DESTINATION bin
)

install( FILES
  ${odb2_scripts_deps}
  DESTINATION lib/pyiodaconv
)

# ODB "definition" files which are configurations for the odbapi2nc.py script.
foreach (FILENAME ${configs})
  list( APPEND build_area_configs ${CMAKE_BINARY_DIR}/etc/pyiodaconv/${FILENAME} )
endforeach(FILENAME)

install( FILES
   ${build_area_configs}
   DESTINATION etc/pyiodaconv
)

ecbuild_add_test( TARGET iodaconv_odb2_coding_norms
                  TYPE SCRIPT
                  COMMAND ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}_lint.sh
                  ARGS ${CMAKE_CURRENT_SOURCE_DIR} ${ODB2_PYCODESTYLE_CONFIG} )
