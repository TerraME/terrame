# Find the TerraLib installation.
# (c) Raian Vargas Maretto, Pedro Ribeiro de Andrade 2011
# ----------------------------------------------------------------------------
# Usage:
# In your CMakeLists.txt file do something like this:
# ...
# # TerraLib
# find_package(TerraLib)
# ...
# if( TERRALIB_FOUND )
#   include_directories(${TERRALIB_KERNEL_INCLUDE_DIR})
#   include_directories(${TERRALIB_MYSQL_INCLUDE_DIR})
#   include_directories(${TERRALIB_JPEG_INCLUDE_DIR})
#   link_directories(${TERRALIB_LIBRARY_DIRS})
# endif( TERRALIB_FOUND )
# ...
# Remember to include ${TERRALIB_LIBRARY} in the target_link_libraries() statement.
#
# ----------------------------------------------------------------------------
# IMPORTANT - You may need to manually set:
#  HINTS in lines 38, 42 and 46 - path to where the TerraLib include files are.
#  PATHS in line 52  - path to where the TerraLib library file are.
#  in case FindTerraLib.cmake cannot find the include files or the library files.
#
# ----------------------------------------------------------------------------
# The following variables are set if TerraLib is found:
#  TERRALIB_FOUND         - Set to true when TerraLib is found.
#  TERRALIB_KERNEL_INCLUDE_DIR  - Kernel include directory for TerraLib
#  TERRALIB_MYSQL_INCLUDE_DIR  - MySQL drivers include directory for TerraLib
#  TERRALIB_JPEG_INCLUDE_DIR  - LibJPEG drivers include directory for TerraLib
#  TERRALIB_LIBRARY     - The TerraLib library.
#

cmake_minimum_required(VERSION 2.8)

# Find path - tries to find *.h in paths hard-coded by the script
find_path(TERRALIB_KERNEL_INCLUDE_DIR TeDatabase.h
   HINTS  /opt/local/include /opt/local/terralib/kernel /usr/local/include /usr/local/terralib/src/kernel ${DEPS}/terralib/src/terralib/kernel /usr/local/include/terralib/kernel
)

find_path(TERRALIB_MYSQL_INCLUDE_DIR TeMySQL.h
   HINTS  /opt/local/include /opt/local/terralib/drivers/MySQL /usr/local/include /usr/local/terralib/src/drivers/MySQL /usr/lib ${DEPS}/terralib/src/terralib/drivers/MySQL /usr/local/include/terralib/drivers/MySQL
)

find_path(TERRALIB_JPEG_INCLUDE_DIR TeLibJpegWrapper.h
   HINTS  /opt/local/include /opt/local/terralib/drivers/libjpeg /usr/local/include /usr/local/terralib/src/drivers/libjpeg ${DEPS}/terralib/src/terralib/drivers/libjpeg /usr/local/include/terralib/drivers/libjpeg
)

# Find library - - tries to find *.a,*.so,*.dylib in paths hard-coded by the script
find_library(TERRALIB_LIBRARY
   NAMES terralib
   PATHS /usr/lib /usr/local/lib /opt/lib /opt/local/lib /usr/local/terralib/build/cmake/terralib
)

# Export include and library path for linking with other libraries

if(TERRALIB_KERNEL_INCLUDE_DIR AND TERRALIB_MYSQL_INCLUDE_DIR AND TERRALIB_JPEG_INCLUDE_DIR AND TERRALIB_LIBRARY)
	set(TERRALIB_FOUND TRUE)
else(TERRALIB_KERNEL_INCLUDE_DIR AND TERRALIB_MYSQL_INCLUDE_DIR AND TERRALIB_JPEG_INCLUDE_DIR AND TERRALIB_LIBRARY)
	set(TERRALIB_FOUND FALSE)
	message("Looked for TerraLib library named terralib.")
	message("Could NOT find TerraLib library")
endif(TERRALIB_KERNEL_INCLUDE_DIR AND TERRALIB_MYSQL_INCLUDE_DIR AND TERRALIB_JPEG_INCLUDE_DIR AND TERRALIB_LIBRARY)

mark_as_advanced(  TERRALIB_KERNEL_INCLUDE_DIR  TERRALIB_MYSQL_INCLUDE_DIR  TERRALIB_JPEG_INCLUDE_DIR  TERRALIB_LIBRARY )
 
