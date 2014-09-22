# Find the QWT installation.
# (c) Raian Vargas Maretto, Pedro Ribeiro de Andrade 2011
# ----------------------------------------------------------------------------
# Usage:
# In your CMakeLists.txt file do something like this:
# ...
# # QWT
# FIND_PACKAGE(qwt)
# ...
# if( QWT_FOUND )
#   include_directories(${QWT_INCLUDE_DIR})
#   link_directories(${QWT_LIBRARY_DIR})
# endif( QWT_FOUND )
# ...
# Remember to include ${QWT_LIBRARIES} in the target_link_libraries() statement.
#
# ----------------------------------------------------------------------------
# IMPORTANT - You may need to manually set:
#  HINTS in lines 47 and 52  - path to where the qwt include files are.
#  PATHS in line 35 and 40  - path to where the qwt library files are.
#  in case FindGeoTIFF.cmake cannot find the include files or the library files.
#
# ----------------------------------------------------------------------------
# The following variables are set if qwt is found:
#  QWT_FOUND         - Set to true when qwt is found.
#  QWT_INCLUDE_DIR  - Include directories for qwt
#  QWT_LIBRARIES     - The qwt libraries.
#	

cmake_minimum_required(VERSION 2.8)
# Find library - - tries to find *.a,*.so,*.dylib in paths hard-coded by the script

find_library(QWT_LIBRARY
   NAMES qwt qwt-qt4
   PATHS /usr/lib /usr/local/lib /opt/lib /opt/local/lib ${DEPS}/qwt/lib
)

# Export include and library path for linking with other libraries
if(QWTQT4_LIBRARY)
	# Find path - tries to find *.h in paths hard-coded by the script
	find_path(QWT_INCLUDE_DIR qwt.h
		HINTS  /usr/include/qwt-qt4 ${DEPS}/qwt/src
	)
else(QWTQT4_LIBRARY)
	# Find path - tries to find *.h in paths hard-coded by the script
	find_path(QWT_INCLUDE_DIR qwt.h
	HINTS  /usr/include/qwt-qt4 /opt/include /opt/include/qwt /opt/local/include /opt/local/include/qwt /usr/include /usr/include/qwt /usr/local/include /usr/local/include/qwt ${DEPS}/qwt/src
	)
endif(QWTQT4_LIBRARY)

if(QWT_INCLUDE_DIR AND (QWTQT4_LIBRARY OR QWT_LIBRARY))
	set(QWT_FOUND TRUE)
else(QWT_INCLUDE_DIR AND (QWTQT4_LIBRARY OR QWT_LIBRARY))
	set(QWT_FOUND FALSE)
	message("Looked for qwt library named qwt.")
	message("Could NOT find qwt library")
endif(QWT_INCLUDE_DIR AND (QWTQT4_LIBRARY OR QWT_LIBRARY))

mark_as_advanced(  QWT_LIBRARY QWTQT4_LIBRARY QWT_LIBRARY )
 
