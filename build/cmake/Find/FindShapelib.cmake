# Find Lua Shapelib includes.
# (c) Raian Vargas Maretto, August 2014
# ----------------------------------------------------------------------------
# Usage:
# In your CMakeLists.txt file do something like this:
#
# ...
# # Shapelib Includes
# find_package(ShapelibInc
# ...
# if( SHAPELIB_FOUND )
#   include_directories(${SHAPELIB_INCLUDE_DIR})
# endif( SHAPELIB_FOUND )
# ...
#
# ----------------------------------------------------------------------------
# IMPORTANT - You may need to manually set:
#  PATH_SUFFIXES in lines 36 and 53 - path suffixes to where the Shapelib include files are.
#  PATHS in lines 37 and 54  - path to where the Shapelib include files are.
#  in case FindShapelib.cmake cannot find the include files or the library files.
#
# ----------------------------------------------------------------------------
# The following variables are set if Lua is found:
#  SHAPELIB_FOUND         - Set to true when Lua is found.
#  SHAPELIB_INCLUDE_DIR  - include directory for Lua
#i

# Find path - tries to find *.h in paths hard-coded by the script
find_path(SHAPELIB_SRC_DIR findCentroid.h
   HINTS 
   #PATH_SUFFIXES include/lua52 include/lua5.2 include/lua include lua52/include lua5.2/include lua/include 
   PATHS
   ${TERRAME_DEPENDENCIES_DIR}/shapelib
)

if(SHAPELIB_SRC_DIR)
   set(SHAPELIB_FOUND true)
else(SHAPELIB_SRC_DIR)
   set(SHAPELIB_FOUND false)
endif(SHAPELIB_SRC_DIR)

mark_as_advanced(SHAPELIB_SRC_DIR)
