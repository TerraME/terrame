# Find the QtLua installation.
# (c) Raian Vargas Maretto, Pedro Ribeiro de Andrade, December 2014
# ----------------------------------------------------------------------------
# Usage:
# In your CMakeLists.txt file do something like this:
# ...
# # QtLua-extras
# FIND_PACKAGE(QtLua-extras)
# ...
# if( QTLUAEXTRAS_FOUND )
#   link_directories(${QTLUAEXTRAS_LIBRARY})
# endif( QTLUAEXTRAS_FOUND )
# ...
# Remember to include ${QTLUAEXTRAS_LIBRARY} in the target_link_libraries() statement.
#
# ----------------------------------------------------------------------------
# IMPORTANT - You may need to manually set:
#  HINTS in lines 47 and 52  - path to where the QtLua include files are.
#  PATHS in line 35 and 40  - path to where the QtLua library files are.
#  in case FindGeoTIFF.cmake cannot find the include files or the library files.
#
# ----------------------------------------------------------------------------
# The following variables are set if QtLua is found:
#  QTLUAEXTRAS_FOUND         - Set to true when QtLua is found.
#  QTLUAEXTRAS_INCLUDE_DIR  - Include directories for QtLua
#  QTLUAEXTRAS_LIBRARY     - The QtLua libraries.
#	

cmake_minimum_required(VERSION 3.0)
# Find library - - tries to find *.a,*.so,*.dylib in paths hard-coded by the script

find_library(QTLUAEXTRAS_LIBRARY
   NAMES qtluae
   PATHS 	/usr/lib 
			/usr/local/lib 
			/opt/lib 
			/opt/local/lib 
			/usr/local/qtlua-extras/lib
			${TERRAME_DEPENDENCIES_DIR}/lib
)

# Export include and library path for linking with other libraries
# Find path - tries to find *.h in paths hard-coded by the script
find_path(QTLUAEXTRAS_INCLUDE_DIR qtluae_version.hpp
	HINTS  	/usr/include/QtLuaExtras 
			/usr/local/include/QtLuaExtras 
			/usr/local/qtlua-extras/include/QtLuaExtras
			${TERRAME_DEPENDENCIES_DIR}/include/QtLuaExtras
			${TERRALIB_3RDPARTY_DIR}/include/QtLuaExtras
)

if(QTLUAEXTRAS_INCLUDE_DIR AND QTLUAEXTRAS_LIBRARY)
	set(QTLUAEXTRAS_FOUND TRUE)
else(QTLUAEXTRAS_INCLUDE_DIR AND QTLUAEXTRAS_LIBRARY)
	set(QTLUAEXTRAS_FOUND FALSE)
	message("Looked for QtLua-extras library.")
	message("Could NOT find QtLua-extras:")
	if(QTLUAEXTRAS_LIBRARY)
		message("\tLibrary: ${QTLUAEXTRAS_LIBRARY}")
	else(QTLUAEXTRAS_LIBRARY)
		message("\tLibrary: -- NOT FOUND --")
	endif(QTLUAEXTRAS_LIBRARY)
	if(QTLUAEXTRAS_INCLUDE_DIR)
		message("\tInclude dir of qtluae_version.hpp: ${QTLUAEXTRAS_INCLUDE_DIR}")
	else(QTLUAEXTRAS_INCLUDE_DIR)
		message("\tInclude dir of qtluae_version.hpp: -- NOT FOUND --")
	endif(QTLUAEXTRAS_INCLUDE_DIR)
endif(QTLUAEXTRAS_INCLUDE_DIR AND QTLUAEXTRAS_LIBRARY)

mark_as_advanced(  QTLUAEXTRAS_LIBRARY QTLUAEXTRAS_INCLUDE_DIR )
 
