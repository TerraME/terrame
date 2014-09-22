# Find the mysqlclient installation.
# Find the native MySQL includes and library
# (c) Raian Vargas Maretto, Pedro Ribeiro de Andrade 2011
# ----------------------------------------------------------------------------
# Usage:
# In your CMakeLists.txt file do something like this:
# ...
# # Mysql
# find_package(MySQL)
# ...
# if( MYSQL_FOUND )
#   include_directories(${MYSQL_INCLUDE_DIR})
#   link_directories(${MYSQL_LIBRARY})
# endif( MYSQL_FOUND )
# ...
# Remember to include ${MYSQL_LIBRARY} in the target_link_libraries() statement.
#
# ----------------------------------------------------------------------------
# IMPORTANT - You may need to manually set:
#  HINTS in line 36  - path to where the qwt include files are.
#  PATHS in line 44  - path to where the qwt library files are.
#  in case FindGeoTIFF.cmake cannot find the include files or the library files.
#
# ----------------------------------------------------------------------------
# The following variables are set if MySQL is found:
#
#  MYSQL_INCLUDE_DIR - where to find mysql.h, etc.
#  MYSQL_LIBRARY   - List of libraries when using MySQL.
#  MYSQL_FOUND       - True if MySQL found.
#

cmake_minimum_required(VERSION 2.8)

find_path(MYSQL_INCLUDE_DIR 
   NAMES mysql.h
   HINTS /usr/local/include /opt/local/include /usr/include/mysql
   PATH_SUFFIXES mysql5 mysql5/mysql
)

set(MYSQL_LIBRARY_NAMES mysqlclient mysqlclient_r)

find_library(MYSQL_LIBRARY
   NAMES ${MYSQL_LIBRARY_NAMES}
   PATHS /usr/lib /usr/local/lib /opt/local/lib
   PATH_SUFFIXES mysql5 mysql5/mysql
)

if(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARY)
	set(MYSQL_FOUND TRUE)
	
else(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARY)
	set(MYSQL_FOUND FALSE)
	message("Looked for MySQL libraries named ${MYSQL_LIBRARY_NAMES}.")
	message("Could NOT find MySQL library")
endif(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARY)


