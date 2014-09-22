# Find Lua 5.2 installation folders.
# (c) Raian Vargas Maretto, December 2012
# ----------------------------------------------------------------------------
# Usage:
# In your CMakeLists.txt file do something like this:
# ...
# # Lua 5.2
# find_package(Lua52)
# ...
# if( LUA_FOUND )
#   include_directories(${LUA_INCLUDE_DIR})
#   link_directories(${LUA_LIBRARY_DIRS})
# endif( LUA_FOUND )
# ...
# Remember to include ${LUA_LIBRARY} in the target_link_libraries() statement.
#
# ----------------------------------------------------------------------------
# IMPORTANT - You may need to manually set:
#  PATH_SUFFIXES in lines 36 and 53 - path suffixes to where the Lua include 
#  and library files are.
#  PATHS in lines 37 and 54  - path to where the Lua include and library files are.
#  in case FindLua52.cmake cannot find the include files or the library files.
#
# ----------------------------------------------------------------------------
# The following variables are set if Lua is found:
#  LUA_FOUND         - Set to true when Lua is found.
#  LUA_INCLUDE_DIR  - include directory for Lua
#  LUA_LIBRARY     - The Lua library.
#

cmake_minimum_required(VERSION 2.8)

# Find path - tries to find *.h in paths hard-coded by the script
find_path(LUA_INCLUDE_DIR lua.h
   HINTS 
   $ENV{LUA_DIR} 
   PATH_SUFFIXES include/lua52 include/lua5.2 include/lua include lua52/include lua5.2/include lua/include 
   PATHS
   ~/Library/Frameworks
   /Library/Frameworks
   /usr/local
   /usr
   /opt/local
   /opt
)

set(LUA_LIB_NAMES lua52 lua5.2 lua-5.2 lua-52 lua)

# Find library - - tries to find *.a,*.so,*.dylib in paths hard-coded by the script
find_library(LUA_LIBRARY
   NAMES ${LUA_LIB_NAMES}
   HINTS
   $ENV{LUA_DIR}
   PATH_SUFFIXES lib64 lib lib/lua52 lib64/lua52 lib/lua5.2 lib64/lua5.2 lib/lua lib64/lua lua52/lib lua5.2/lib lua/lib
   PATHS
   ~/Library/Frameworks
   /Library/Frameworks
   /usr/local
   /usr
   /opt/local
   /opt 
)

# Export include and library path for linking with other libraries

if(LUA_INCLUDE_DIR AND LUA_LIBRARY)
	set(LUA_FOUND TRUE)
else(LUA_INCLUDE_DIR AND LUA_LIBRARY)
	set(LUA_FOUND FALSE)
	message("Looked for Lua library named ${LUA_LIB_NAMES}.")
	message("Could NOT find Lua library")
endif(LUA_INCLUDE_DIR AND LUA_LIBRARY)

mark_as_advanced(  LUA_INCLUDE_DIR LUA_LIBRARY )
 
