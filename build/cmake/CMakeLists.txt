# TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
# Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
#
# This file is part of the TerraME framework.
# This framework is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.
#
# The authors reassure the license terms regarding the warranties.
# They specifically disclaim any warranties, including, but not limited to,
# the implied warranties of merchantability and fitness for a particular purpose.
# The framework provided hereunder is on an "as is" basis, and the authors have no
# obligation to provide maintenance, support, updates, enhancements, or modifications.
# In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
# indirect, special, incidental, or caonsequential damages arising out of the use
# of this library and its documentation.
#
# Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
#          Rodrigo Avancini

cmake_minimum_required(VERSION 3.0)

project(TerraME)

#
# main variables for the build script
#

# variables that control the system versioning
set(TERRAME_VERSION_MAJOR 2)
set(TERRAME_VERSION_MINOR 0)
set(TERRAME_VERSION_PATCH 0)
set(TERRAME_VERSION_STRING "${TERRAME_VERSION_MAJOR}.${TERRAME_VERSION_MINOR}.${TERRAME_VERSION_PATCH}")
set(TERRAME_VERSION "0x020000")
set(TERRAME_PKG_VERSION ${TERRAME_VERSION_MAJOR}.${TERRAME_VERSION_MINOR}.${TERRAME_VERSION_PATCH})

set(TERRAME_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../..)

set(TERRAME_SRC_DIR ${TERRAME_ROOT_DIR}/src) # this is the directory where terralib sources will be located
set(TERRAME_OBSERVER_ROOT_DIR ${TERRAME_SRC_DIR}/observer)

set(CMAKE_MODULE_PATH ${TERRAME_ROOT_DIR}/build/cmake/Find) # this is the directory where additional scritps are located

## Sets type of build: Release or Debug
if(NOT DEFINED CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif()

#-- TODO: Verify the effect these lines and make it works, if possible!!
if(CMAKE_COMPILER_IS_GNUCXX)
	message("  -- Otimization enabled!! ")
	set(CMAKE_CXX_FLAGS_RELEASE "-O3")        ## Optimize
	set(CMAKE_CXX_FLAGS_DEBUG  "-O0 -g")
	set(CMAKE_EXE_LINKER_FLAGS "-s")  ## Strip binary
endif(CMAKE_COMPILER_IS_GNUCXX)

#-- TODO: Veify all these flags. All of them are really necessary?
add_definitions(-w -DTME_LUA_5_2 -DQWT_DLL -DTME_BLACK_BOARD -DTME_PROTOCOL_BUFFERS ) #Set -D define flags to the compilation of source files

set(TERRAME_BIN_DIR ${TERRAME_ROOT_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${TERRAME_BIN_DIR})
set(TERRAME_PACKAGE_DIR ${TERRAME_ROOT_DIR}/packages)
set(TERRAME_LUA_SRC_DIR ${TERRAME_SRC_DIR}/lua)

file(COPY
	${TERRAME_PACKAGE_DIR}/
	DESTINATION ${TERRAME_BIN_DIR}/packages/
)

file(COPY
	${TERRAME_LUA_SRC_DIR}/
	DESTINATION ${TERRAME_BIN_DIR}/lua/
)

message("Using additional find package files located in ${CMAKE_MODULE_PATH}")

file(GLOB TERRAME_CORE_SRC_FILES ${TERRAME_ROOT_DIR}/src/core/*.cpp)
file(GLOB TERRAME_CORE_HDR_FILES ${TERRAME_ROOT_DIR}/src/core/*.h)

file(GLOB TERRAME_LUA_FILES ${TERRAME_ROOT_DIR}/src/lua/*.lua)

file(GLOB TERRAME_LUA_FILE_SYSTEM_FILES ${TERRAME_ROOT_DIR}/src/luaFileSystem/*.c)

file(GLOB TERRAME_OBSERVER_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/*.cpp)
file(GLOB TERRAME_OBSERVER_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/*.h)

file(GLOB TERRAME_OBSERVER_COMPONENTS_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/components/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/components/*.h)

file(GLOB TERRAME_OBSERVER_COMPONENTS_CONSOLE_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/legend/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_CONSOLE_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/legend/*.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES ${TERRAME_ROOT_DIR}/src/observer/components/console/*.ui)

file(GLOB TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/components/legend/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/components/legend/*.h)

file(GLOB TERRAME_OBSERVER_COMPONENTS_PAINTER_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/components/painter/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PAINTER_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/components/painter/*.h)

file(GLOB TERRAME_OBSERVER_COMPONENTS_PLAYER_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/components/player/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PLAYER_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/components/player/*.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES ${TERRAME_ROOT_DIR}/src/observer/components/player/*.ui)

file(GLOB TERRAME_OBSERVER_COMPONENTS_RECEIVER_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/components/receiver/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_RECEIVER_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/components/receiver/*.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES ${TERRAME_ROOT_DIR}/src/observer/components/receiver/*.ui)

file(GLOB TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/protocol/blackBoard/*.cpp)
file(GLOB TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/protocol/blackBoard/*.h)

file(GLOB TERRAME_OBSERVER_PROTOCOL_DECODER_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/protocol/decoder/*.cpp)
file(GLOB TERRAME_OBSERVER_PROTOCOL_DECODER_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/protocol/decoder/*.h)

file(GLOB TERRAME_OBSERVER_PROTOCOL_BUFFERS_PROTO_FILES ${TERRAME_ROOT_DIR}/src/observer/protocol/decoder/*.proto)

file(GLOB TERRAME_OBSERVER_TYPES_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/types/*.cpp)
file(GLOB TERRAME_OBSERVER_TYPES_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/types/*.h)

file(GLOB TERRAME_OBSERVER_TYPES_CHART_PLOT_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/types/chartPlot/*.cpp)
file(GLOB TERRAME_OBSERVER_TYPES_CHART_PLOT_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/types/chartPlot/*.h)

file(GLOB TERRAME_OBSERVER_TYPES_STATE_MACHINE_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/types/stateMachine/*.cpp)
file(GLOB TERRAME_OBSERVER_TYPES_STATE_MACHINE_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/types/stateMachine/*.h)

file(GLOB TERRAME_OBSERVER_UDP_SENDER_SRC_FILES ${TERRAME_ROOT_DIR}/src/observer/types/udpSender/*.cpp)
file(GLOB TERRAME_OBSERVER_UDP_SENDER_HDR_FILES ${TERRAME_ROOT_DIR}/src/observer/types/udpSender/*.h)
file(GLOB TERRAME_OBSERVER_UDP_SENDER_UI_FILES ${TERRAME_ROOT_DIR}/src/observer/types/udpSender/*.ui)

source_group("Source Files\\core"              						FILES ${TERRAME_CORE_SRC_FILES})
source_group("Header Files\\core"              						FILES ${TERRAME_CORE_HDR_FILES})

source_group("Source Files\\lua"              						FILES ${TERRAME_LUA_FILES})

source_group("Source Files\\luaFileSystem"              			FILES ${TERRAME_LUA_FILE_SYSTEM_FILES})

source_group("Source Files\\observer"              					FILES ${TERRAME_OBSERVER_SRC_FILES})
source_group("Header Files\\observer"              					FILES ${TERRAME_OBSERVER_HDR_FILES})

source_group("Source Files\\observer\\components"					FILES ${TERRAME_OBSERVER_COMPONENTS_SRC_FILES})
source_group("Header Files\\observer\\components"   				FILES ${TERRAME_OBSERVER_COMPONENTS_HDR_FILES})

source_group("Source Files\\observer\\components\\console"			FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_SRC_FILES})
source_group("Header Files\\observer\\components\\console"   		FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_HDR_FILES})
source_group("UI Files\\observer\\components\\console"   			FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES})

source_group("Source Files\\observer\\components\\legend"			FILES ${TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES})
source_group("Header Files\\observer\\components\\legend"   		FILES ${TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES})

source_group("Source Files\\observer\\components\\painter"			FILES ${TERRAME_OBSERVER_COMPONENTS_PAINTER_SRC_FILES})
source_group("Header Files\\observer\\components\\painter"   		FILES ${TERRAME_OBSERVER_COMPONENTS_PAINTER_HDR_FILES})

source_group("Source Files\\observer\\components\\player"			FILES ${TERRAME_OBSERVER_COMPONENTS_PLAYER_SRC_FILES})
source_group("Header Files\\observer\\components\\player"   		FILES ${TERRAME_OBSERVER_COMPONENTS_PLAYER_HDR_FILES})
source_group("UI Files\\observer\\components\\player"   			FILES ${TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES})

source_group("Source Files\\observer\\components\\receiver"			FILES ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_SRC_FILES})
source_group("Header Files\\observer\\components\\receiver"   		FILES ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_HDR_FILES})
source_group("UI Files\\observer\\components\\receiver"   			FILES ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES})

source_group("Source Files\\observer\\protocol\\blackBoard"			FILES ${TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_SRC_FILES})
source_group("Header Files\\observer\\protocol\\blackBoard"   		FILES ${TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_HDR_FILES})

source_group("Source Files\\observer\\protocol\\decoder"			FILES ${TERRAME_OBSERVER_PROTOCOL_DECODER_SRC_FILES})
source_group("Header Files\\observer\\protocol\\decoder"   			FILES ${TERRAME_OBSERVER_PROTOCOL_DECODER_HDR_FILES})

source_group("Source Files\\observer\\protocol\\protocolBuffers"   	FILES ${TERRAME_OBSERVER_PROTOCOL_BUFFERS_PROTO_FILES})

source_group("Source Files\\observer\\types"						FILES ${TERRAME_OBSERVER_TYPES_SRC_FILES})
source_group("Header Files\\observer\\types"   						FILES ${TERRAME_OBSERVER_TYPES_HDR_FILES})

source_group("Source Files\\observer\\types\\chartPlot"				FILES ${TERRAME_OBSERVER_TYPES_CHART_PLOT_SRC_FILES})
source_group("Header Files\\observer\\types\\chartPlot"   			FILES ${TERRAME_OBSERVER_TYPES_CHART_PLOT_HDR_FILES})

source_group("Source Files\\observer\\types\\stateMachine"			FILES ${TERRAME_OBSERVER_TYPES_STATE_MACHINE_SRC_FILES})
source_group("Header Files\\observer\\types\\stateMachine"   		FILES ${TERRAME_OBSERVER_TYPES_STATE_MACHINE_HDR_FILES})

source_group("Source Files\\observer\\types\\udpSender"				FILES ${TERRAME_OBSERVER_UDP_SENDER_SRC_FILES})
source_group("Header Files\\observer\\types\\udpSender"   			FILES ${TERRAME_OBSERVER_UDP_SENDER_HDR_FILES})
source_group("UI Files\\observer\\types\\udpSender"   				FILES ${TERRAME_OBSERVER_UDP_SENDER_UI_FILES})

set(TERRAME_FILES 	${TERRAME_CORE_SRC_FILES} ${TERRAME_CORE_HDR_FILES}
					${TERRAME_LUA_FILES} 
					${TERRAME_LUA_FILE_SYSTEM_FILES} 
					${TERRAME_OBSERVER_SRC_FILES} ${TERRAME_OBSERVER_HDR_FILES}
					${TERRAME_OBSERVER_COMPONENTS_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_HDR_FILES}
					${TERRAME_OBSERVER_COMPONENTS_CONSOLE_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_HDR_FILES} ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES}
					${TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES} 
					${TERRAME_OBSERVER_COMPONENTS_PAINTER_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_PAINTER_HDR_FILES} 
					${TERRAME_OBSERVER_COMPONENTS_PLAYER_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_PLAYER_HDR_FILES} ${TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES}
					${TERRAME_OBSERVER_COMPONENTS_RECEIVER_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_HDR_FILES} ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES}
					${TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_SRC_FILES} ${TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_HDR_FILES}
					${TERRAME_OBSERVER_PROTOCOL_DECODER_SRC_FILES} ${TERRAME_OBSERVER_PROTOCOL_DECODER_HDR_FILES}
					${TERRAME_OBSERVER_PROTOCOL_BUFFERS_PROTO_FILES}
					${TERRAME_OBSERVER_TYPES_SRC_FILES} ${TERRAME_OBSERVER_TYPES_HDR_FILES}
					${TERRAME_OBSERVER_TYPES_CHART_PLOT_SRC_FILES} ${TERRAME_OBSERVER_TYPES_CHART_PLOT_HDR_FILES}
					${TERRAME_OBSERVER_TYPES_STATE_MACHINE_SRC_FILES} ${TERRAME_OBSERVER_TYPES_STATE_MACHINE_HDR_FILES}
					${TERRAME_OBSERVER_UDP_SENDER_SRC_FILES} ${TERRAME_OBSERVER_UDP_SENDER_HDR_FILES} ${TERRAME_OBSERVER_UDP_SENDER_UI_FILES})

#Set include directories location
include_directories(${TERRAME_SRC_DIR}
					${TERRAME_SRC_DIR}/core/
					${TERRAME_SRC_DIR}/observer/components/
					${TERRAME_SRC_DIR}/observer/components/console/
					${TERRAME_SRC_DIR}/observer/types/chartPlot/
					${TERRAME_SRC_DIR}/observer/components/legend/
					${TERRAME_SRC_DIR}/observer/components/painter/
					${TERRAME_SRC_DIR}/observer/components/player/
					${TERRAME_SRC_DIR}/observer/protocol/blackBoard/
					${TERRAME_SRC_DIR}/observer/protocol/decoder/
					${TERRAME_SRC_DIR}/observer/types/image/
					${TERRAME_SRC_DIR}/observer/types/stateMachine/
					${TERRAME_SRC_DIR}/observer/types/udpSender/
					${TERRAME_SRC_DIR}/observer/types/
					${TERRAME_SRC_DIR}/observer/
					${TERRAME_SRC_DIR}/luaFileSystem)

set(TERRAME_LIBRARIES)

set(TERRAME_DEPENDENCIES_DIR ${TERRAME_ROOT_DIR}/dependencies)
### --------------
# Shapelib
find_package(Shapelib REQUIRED)
if(SHAPELIB_FOUND)
	message("-- Found Shapelib sources in ${SHAPELIB_SRC_DIR}")

	file(GLOB TERRAME_DEPENDENCIES_SHAPELIB_SRC_FILES 		${TERRAME_ROOT_DIR}/dependencies/shapelib/*.cpp 
															${TERRAME_ROOT_DIR}/dependencies/shapelib/*.c)
	file(GLOB TERRAME_DEPENDENCIES_SHAPELIB_HDR_FILES 		${TERRAME_ROOT_DIR}/dependencies/shapelib/*.h)

	source_group("Source Files\\shapelib"	FILES ${TERRAME_DEPENDENCIES_SHAPELIB_SRC_FILES})
	source_group("Header Files\\shapelib"	FILES ${TERRAME_DEPENDENCIES_SHAPELIB_HDR_FILES})
					
	set(TERRAME_FILES 	${TERRAME_FILES} 
						${TERRAME_DEPENDENCIES_SHAPELIB_SRC_FILES} ${TERRAME_DEPENDENCIES_SHAPELIB_HDR_FILES})	
						
	include_directories(${SHAPELIB_SRC_DIR})	
else(SHAPELIB_FOUND)
	message(FATAL_ERROR "-- Shapelib source code was not found in the dependencies folder")
endif(SHAPELIB_FOUND)

## ---------------------------------------- Find dependencies -------------------------------------------------- ##
find_package(qwt-qt5)
if(QWT_FOUND)
	message("-- Found Qwt library ${QWT_LIBRARY} and include directories ${QWT_INCLUDE_DIR}")
	include_directories(${QWT_INCLUDE_DIR})
	if(QWTQT5_LIBRARY)
		set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${QWTQT5_LIBRARY})
	else(QWTQT5_LIBRARY)
		set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${QWT_LIBRARY})
	endif(QWTQT5_LIBRARY)
endif( QWT_FOUND )

### --------------
#LUA
find_package(Lua52 REQUIRED)
if(LUA_FOUND)
	message("-- Found Lua library ${LUA_LIBRARY} and include dir ${LUA_INCLUDE_DIR}") 
	include_directories(${LUA_INCLUDE_DIR})
	set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${LUA_LIBRARY})
endif(LUA_FOUND)

### --------------
#PROTOCOL BUFFERS
find_package(Protobuf REQUIRED)
if(PROTOBUF_FOUND)
	if(PROTOBUF_PROTOC_EXECUTABLE)
		message("-- Found Protocol Buffers library ${PROTOBUF_LIBRARY}, include dir ${PROTOBUF_INCLUDE_DIR} and compiler ${PROTOBUF_PROTOC_EXECUTABLE}")
	
		protobuf_generate_cpp(PROTO_SRC PROTO_HEADER ${TERRAME_OBSERVER_ROOT_DIR}/protocol/protocolBuffers/protocol.proto)
		
		include_directories(${PROTOBUF_INCLUDE_DIR})
		
		set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${PROTOBUF_LIBRARY})
		
		set(TERRAME_FILES ${TERRAME_FILES} ${PROTO_SRC} ${PROTO_HEADER})
	else(PROTOBUF_PROTOC_EXECUTABLE)
		message( FATAL_ERROR "-- Protocol Buffers compiler was not found" )
	endif(PROTOBUF_PROTOC_EXECUTABLE)
else(PROTOBUF_FOUND)
	message( FATAL_ERROR "-- Protocol Buffers package was not found.")
endif(PROTOBUF_FOUND)

### --------------
#QT5
find_package(Qt5Widgets REQUIRED)
find_package(Qt5Network REQUIRED)
find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${Qt5Network_LIBRARIES} ${Qt5Core_LIBRARIES} ${Qt5Gui_LIBRARIES} ${Qt5Widgets_LIBRARIES})
include_directories(${Qt5Network_INCLUDE_DIRS} ${Qt5Core_INCLUDE_DIRS} ${Qt5Gui_INCLUDE_DIRS} ${Qt5Widgets_INCLUDE_DIRS})

### --------------
#QtLua
find_package(QtLua REQUIRED)
if(QTLUA_FOUND)
	message("-- Found QtLua library ${QTLUA_LIBRARY} and include directories ${QTLUA_INCLUDE_DIR}")
else(QTLUA_FOUND)
	message( FATAL_ERROR "-- QtLua library was not found.")
endif(QTLUA_FOUND)

### --------------
#QtLua-extras
find_package(QtLua-extras REQUIRED)
if(QTLUAEXTRAS_FOUND)
	message("-- Found QtLua-extras library ${QTLUAEXTRAS_LIBRARY} and include directories ${QTLUAEXTRAS_INCLUDE_DIR}")
else(QTLUAEXTRAS_FOUND)
	message( FATAL_ERROR "-- QtLua-extras library was not found.")
endif(QTLUAEXTRAS_FOUND)

## ------------------------------------------------------------------------------------------------------------- ##
# Set Qt moc parameters
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(TERRAME_OBSERVER_QRC_FILES ${TERRAME_SRC_DIR}/observer/observerResource.qrc)
QT5_ADD_RESOURCES(TERRAME_OBSERVER_QRC_FILES_ADD ${TERRAME_OBSERVER_QRC_FILES})

source_group("Resource Files\\observer"	FILES ${TERRAME_OBSERVER_QRC_FILES})

QT5_WRAP_UI(TERRAME_GEN_HDR_FILES 	${TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES} 
									${TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES} 
									${TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES} 
									${TERRAME_OBSERVER_UDP_SENDER_UI_FILES})
									
set(TERRAME_FILES ${TERRAME_FILES} ${TERRAME_OBSERVER_QRC_FILES} ${TERRAME_OBSERVER_QRC_FILES_ADD})

include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(CMAKE_INSTALL_RPATH "@executable_path/../lib;/usr/local/terrame/lib")
set(CMAKE_INSTALL_NAME_DIR "@executable_path/../lib")
set(CMAKE_BUILD_WITH_INSTALL_RPATH true)
set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH true)

if(MINGW)
    file(TERRAME_APP_ICON ${TERRAME_ROOT_DIR}/res/resource.o)
elseif(MSVC)
	file(GLOB TERRAME_APP_ICON ${TERRAME_ROOT_DIR}/res/resource.rc)
else()
    file(TERRAME_APP_ICON "")
endif()

set(TERRAME_FILES ${TERRAME_FILES} ${TERRAME_APP_ICON})

## ------------------------------------------------------------------------------------------------------------- ##
# Add Target and link directories, and link with libraries
add_executable(terrame ${TERRAME_FILES})

link_directories(/usr/lib) # Set link directories
target_link_libraries(terrame ${TERRAME_LIBRARIES}) # Link with libraries

set_target_properties( terrame PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ${TERRAME_BIN_DIR}
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ${TERRAME_BIN_DIR}
)

## ------------------------------------- Set Installation procedure -------------------------------------------- ##
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
	set(CMAKE_INSTALL_PREFIX ${TERRAME_ROOT_DIR}/install)
endif()

set(CPACK_PACKAGING_INSTALL_PREFIX /usr/local/terrame)
install(TARGETS terrame 
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		# COMPONENT Runtime
)

install(DIRECTORY ${TERRAME_LUA_SRC_DIR}/
		DESTINATION bin/lua/
)

install(DIRECTORY ${TERRAME_PACKAGE_DIR}/
		DESTINATION bin/packages/
		# COMPONENT Base_Package
)

if(APPLE)
install(FILES ${QTLUA_LIBRARY}
			  ${QTLUAEXTRAS_INCLUDE_DIR}/../../lib/libqtluae.0.1.dylib
		DESTINATION lib)
endif()

set(CPACK_GENERATOR "PackageMaker")
set(CPACK_PACKAGEMAKER ON)
set(CPACK_OSX_PACKAGE_VERSION "10.9")
SET(CPACK_PACKAGE_VENDOR "TerraLAB")
SET(CPACK_PACKAGE_NAME "TerraME")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Description.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${TERRAME_ROOT_DIR}/licenses/terrame-license-lgpl-3.0.txt")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "TerraME is a programming environment for spatial dynamical modelling")

#VERSION
set(CPACK_PACKAGE_VERSION "1.4")
set(CPACK_PACKAGE_VERSION_MAJOR "1")
set(CPACK_PACKAGE_VERSION_MINOR "4")
set(CPACK_PACKAGE_VERSION_PATCH "0")
set(CPACK_PACKAGE_EXECUTABLES "TerraME;TerraME")
set(CPACK_SYSTEM_NAME "Mac-OSX")

# Environment Variables
set(CPACK_POSTFLIGHT_SCRIPT "${CMAKE_CUURENT_SOURCE_DIR}/setenv_install_MAC.sh" ) 

include(CPack)

########### Get dependencies ################
set(MY_BINARY_LOCATION ${TERRAME_BIN_DIR}/terrame)

configure_file(
   "${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake.in"
   "${CMAKE_CURRENT_BINARY_DIR}/dependencies.cmake"
   @ONLY
 )
install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/dependencies.cmake")
######################################

include(DeployQt4)
resolve_qt4_paths(terrame "terrame" "@executable_path/../lib")
