# Find the QtLua installation.
# (c) Raian Vargas Maretto, Pedro Ribeiro de Andrade, December 2014
# ----------------------------------------------------------------------------
# Usage:
# In your CMakeLists.txt file do something like this:
# ...
# # QtLua
# FIND_PACKAGE(QtLua)
# ...
# if( QTLUA_FOUND )
#   link_directories(${QTLUA_LIBRARY_DIR})
# endif( QTLUA_FOUND )
# ...
# Remember to include ${QTLUA_LIBRARIES} in the target_link_libraries() statement.
#
# ----------------------------------------------------------------------------
# IMPORTANT - You may need to manually set:
#  HINTS in lines 47 and 52  - path to where the QtLua include files are.
#  PATHS in line 35 and 40  - path to where the QtLua library files are.
#  in case FindGeoTIFF.cmake cannot find the include files or the library files.
#
# ----------------------------------------------------------------------------
# The following variables are set if QtLua is found:
#  QTLUA_FOUND         - Set to true when QtLua is found.
#  QTLUA_INCLUDE_DIR  - Include directories for QtLua
#  QTLUA_LIBRARIES     - The QtLua libraries.
#	

cmake_minimum_required(VERSION 3.0)
# Find library - - tries to find *.a,*.so,*.dylib in paths hard-coded by the script

find_library(QTLUA_LIBRARY NAMES qtlua
	PATHS /usr/lib /usr/local/lib /opt/lib /opt/local/lib /usr/local/qtlua/lib)

# Export include and library path for linking with other libraries
# Find path - tries to find *.h in paths hard-coded by the script
find_path(QTLUA_INCLUDE_DIR qtluafunction.hh
	HINTS /usr/include/QtLua 
	      /usr/local/include/QtLua 
	      /usr/local/qtlua/include/QtLua
	      ${TERRAME_DEPENDENCIES_DIR}/include/QtLua
	      ${TERRALIB_3RDPARTY_DIR}/include/QtLua)

if(QTLUA_INCLUDE_DIR AND QTLUA_LIBRARY)
	set(QTLUA_FOUND TRUE)
else(QTLUA_INCLUDE_DIR AND QTLUA_LIBRARY)
	set(QTLUA_FOUND FALSE)
	message("Looked for QtLua library.")
	message("Could NOT find QtLua:")
	if(QTLUA_LIBRARY)
		message("\tLibrary: ${QTLUA_LIBRARY}")
	else(QTLUA_LIBRARY)
		message("\tLibrary: -- NOT FOUND --")
	endif(QTLUA_LIBRARY)
	if(QTLUA_INCLUDE_DIR)
		message("\tInclude dir of qtluafunction.hh: ${QTLUA_INCLUDE_DIR}")
	else(QTLUA_INCLUDE_DIR)
		message("\tInclude dir of qtluafunction.hh: -- NOT FOUND --")
	endif(QTLUA_INCLUDE_DIR)
endif(QTLUA_INCLUDE_DIR AND QTLUA_LIBRARY)

mark_as_advanced(  QTLUA_LIBRARY QTLUA_INCLUDE_DIR )
