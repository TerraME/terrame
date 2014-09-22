# Find the QWT installation.
# (c) Raian Vargas Maretto, February 2013
# ----------------------------------------------------------------------------
# Usage:
# In your CMakeLists.txt file do something like this:
# ...
# # Random
# FIND_PACKAGE(Random)
# ...
# if( RANDOM_FOUND )
#   include_directories(${RANDOM_INCLUDE_DIR})
#   link_directories(${RANDOM_LIBRARY})
# endif( RANDOM_FOUND )
# ...
# Remember to include ${RANDOM_LIBRARY} in the target_link_libraries() statement.
#
# ----------------------------------------------------------------------------
# IMPORTANT - You may need to manually set:
#  HINTS in lines 42 - path to where the qwt include files are.
#  PATHS in line 35 - path to where the qwt library files are.
#  in case FindGeoTIFF.cmake cannot find the include files or the library files.
#
# ----------------------------------------------------------------------------
# The following variables are set if qwt is found:
#  RANDOM_FOUND         - Set to true when qwt is found.
#  RANDOM_INCLUDE_DIR  - Include directories for qwt
#  RANDOM_LIBRARIES     - The qwt libraries.
#	

cmake_minimum_required(VERSION 2.8)
# Find library - - tries to find *.a,*.so,*.dylib in paths hard-coded by the script

find_library(RANDOM_LIBRARY
   NAMES Random
   PATHS /usr/lib /usr/local/lib /opt/lib /opt/local/lib ${DEPS}/random/src
)

# Export include and library path for linking with other libraries
if(RANDOM_LIBRARY)
	# Find path - tries to find *.hpp in paths hard-coded by the script
	find_path(RANDOM_INCLUDE_DIR Random.hpp
		HINTS   /usr/include
			/usr/include/RandomLib 
			/usr/local/include 
			/usr/local/include/RandomLib 
			/opt/include 
			/opr/include/RandomLib
			/opt/local/include 
			/opt/local/include/RandomLib
			${DEPS}/random/include
			${DEPS}/random/include/RandomLib
	)
endif(RANDOM_LIBRARY)

if(RANDOM_INCLUDE_DIR AND RANDOM_LIBRARY)
	set(RANDOM_FOUND TRUE)
else(RANDOM_INCLUDE_DIR AND RANDOM_LIBRARY)
	set(RANDOM_FOUND FALSE)
	message("Looked for RandomLib library named Random.")
	message("Could NOT find Random library")
endif(RANDOM_INCLUDE_DIR AND RANDOM_LIBRARY)

mark_as_advanced(  RANDOM_LIBRARY RANDOM_INCLUDE_DIR )
