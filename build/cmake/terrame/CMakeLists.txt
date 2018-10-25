############################################################################################
# TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
# Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org
#
# This code is part of the TerraME framework.
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
# indirect, special, incidental, or consequential damages arising out of the use
# of this software and its documentation.
############################################################################################

#terrame/src/core
file(GLOB TERRAME_CORE_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/core/*.cpp)
file(GLOB TERRAME_CORE_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/core/*.h)
source_group("Source Files\\core" FILES ${TERRAME_CORE_SRC_FILES})
source_group("Header Files\\core" FILES ${TERRAME_CORE_HDR_FILES})

#terrame/src/lua
file(GLOB TERRAME_LUA_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/lua/*.lua)
source_group("Source Files\\lua" FILES ${TERRAME_LUA_FILES})

#terrame/src/luaFileSystem
file(GLOB TERRAME_LUA_FILE_SYSTEM_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/luaFileSystem/*.c)
file(GLOB TERRAME_LUA_FILE_SYSTEM_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/luaFileSystem/*.h)
source_group("Source Files\\luaFileSystem" FILES ${TERRAME_LUA_FILE_SYSTEM_SRC_FILES})
source_group("Header Files\\luaFileSystem" FILES ${TERRAME_LUA_FILE_SYSTEM_HDR_FILES})

#terrame/src/observer
file(GLOB TERRAME_OBSERVER_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/*.cpp)
file(GLOB TERRAME_OBSERVER_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/*.h)
source_group("Source Files\\observer" FILES ${TERRAME_OBSERVER_SRC_FILES})
source_group("Header Files\\observer" FILES ${TERRAME_OBSERVER_HDR_FILES})

#terrame/src/observer/components
file(GLOB TERRAME_OBSERVER_COMPONENTS_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/*.h)
source_group("Source Files\\observer\\components" FILES ${TERRAME_OBSERVER_COMPONENTS_SRC_FILES})
source_group("Header Files\\observer\\components" FILES ${TERRAME_OBSERVER_COMPONENTS_HDR_FILES})

#terrame/src/observer/components/console
file(GLOB TERRAME_OBSERVER_COMPONENTS_CONSOLE_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/console/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_CONSOLE_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/console/*.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/console/*.ui)
source_group("Source Files\\observer\\components\\console" FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_SRC_FILES})
source_group("Header Files\\observer\\components\\console" FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_HDR_FILES})
source_group("UI Files\\observer\\components\\console" FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES})

#terrame/src/observer/components/legend
file(GLOB TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/legend/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/legend/*.h)
source_group("Source Files\\observer\\components\\legend" FILES ${TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES})
source_group("Header Files\\observer\\components\\legend" FILES ${TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES})

#terrame/src/observer/components/painter
file(GLOB TERRAME_OBSERVER_COMPONENTS_PAINTER_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/painter/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PAINTER_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/painter/*.h)
source_group("Source Files\\observer\\components\\painter" FILES ${TERRAME_OBSERVER_COMPONENTS_PAINTER_SRC_FILES})
source_group("Header Files\\observer\\components\\painter" FILES ${TERRAME_OBSERVER_COMPONENTS_PAINTER_HDR_FILES})

#terrame/src/observer/components/player
file(GLOB TERRAME_OBSERVER_COMPONENTS_PLAYER_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/player/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PLAYER_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/player/*.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/player/*.ui)
source_group("Source Files\\observer\\components\\player" FILES ${TERRAME_OBSERVER_COMPONENTS_PLAYER_SRC_FILES})
source_group("Header Files\\observer\\components\\player" FILES ${TERRAME_OBSERVER_COMPONENTS_PLAYER_HDR_FILES})
source_group("UI Files\\observer\\components\\player" FILES ${TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES})

#terrame/src/observer/components/receiver
file(GLOB TERRAME_OBSERVER_COMPONENTS_RECEIVER_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/receiver/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_RECEIVER_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/receiver/*.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/receiver/*.ui)
source_group("Source Files\\observer\\components\\receiver" FILES ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_SRC_FILES})
source_group("Header Files\\observer\\components\\receiver" FILES ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_HDR_FILES})
source_group("UI Files\\observer\\components\\receiver" FILES ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES})

#terrame/src/observer/protocol/blackBoard
file(GLOB TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/protocol/blackBoard/*.cpp)
file(GLOB TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/protocol/blackBoard/*.h)
source_group("Source Files\\observer\\protocol\\blackboard" FILES ${TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_SRC_FILES})
source_group("Header Files\\observer\\protocol\\blackboard" FILES ${TERRAME_OBSERVER_PROTOCOL_BLACKBOARD_HDR_FILES})

#terrame/src/observer/protocol/decoder
file(GLOB TERRAME_OBSERVER_PROTOCOL_DECODER_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/protocol/decoder/*.cpp)
file(GLOB TERRAME_OBSERVER_PROTOCOL_DECODER_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/protocol/decoder/*.h)
source_group("Source Files\\observer\\protocol\\decoder" FILES ${TERRAME_OBSERVER_PROTOCOL_DECODER_SRC_FILES})
source_group("Header Files\\observer\\protocol\\decoder" FILES ${TERRAME_OBSERVER_PROTOCOL_DECODER_HDR_FILES})

#TODO: REVIEW
file(GLOB TERRAME_OBSERVER_PROTOCOL_BUFFERS_PROTO_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/protocol/protocolBuffers/*.proto)
source_group("Source Files\\observer\\protocol\\protocolbuffers" FILES ${TERRAME_OBSERVER_PROTOCOL_BUFFERS_PROTO_FILES})

#terrame/src/observer/types
file(GLOB TERRAME_OBSERVER_TYPES_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/*.cpp)
file(GLOB TERRAME_OBSERVER_TYPES_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/*.h)
source_group("Source Files\\observer\\types" FILES ${TERRAME_OBSERVER_TYPES_SRC_FILES})
source_group("Header Files\\observer\\types" FILES ${TERRAME_OBSERVER_TYPES_HDR_FILES})

#terrame/src/observer/types/chartPlot
file(GLOB TERRAME_OBSERVER_TYPES_CHART_PLOT_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/chartPlot/*.cpp)
file(GLOB TERRAME_OBSERVER_TYPES_CHART_PLOT_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/chartPlot/*.h)
source_group("Source Files\\observer\\types\\chartplot" FILES ${TERRAME_OBSERVER_TYPES_CHART_PLOT_SRC_FILES})
source_group("Header Files\\observer\\types\\chartplot" FILES ${TERRAME_OBSERVER_TYPES_CHART_PLOT_HDR_FILES})

#terrame/src/observer/types/stateMachine
file(GLOB TERRAME_OBSERVER_TYPES_STATE_MACHINE_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/stateMachine/*.cpp)
file(GLOB TERRAME_OBSERVER_TYPES_STATE_MACHINE_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/stateMachine/*.h)
source_group("Source Files\\observer\\types\\statemachine" FILES ${TERRAME_OBSERVER_TYPES_STATE_MACHINE_SRC_FILES})
source_group("Header Files\\observer\\types\\statemachine" FILES ${TERRAME_OBSERVER_TYPES_STATE_MACHINE_HDR_FILES})

#terrame/src/observer/types/udpSender
file(GLOB TERRAME_OBSERVER_UDP_SENDER_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/udpSender/*.cpp)
file(GLOB TERRAME_OBSERVER_UDP_SENDER_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/udpSender/*.h)
file(GLOB TERRAME_OBSERVER_UDP_SENDER_UI_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/udpSender/*.ui)
source_group("Source Files\\observer\\types\\udpsender" FILES ${TERRAME_OBSERVER_UDP_SENDER_SRC_FILES})
source_group("Header Files\\observer\\types\\udpsender" FILES ${TERRAME_OBSERVER_UDP_SENDER_HDR_FILES})
source_group("UI Files\\observer\\types\\udpsender" FILES ${TERRAME_OBSERVER_UDP_SENDER_UI_FILES})

if(APPLE)
	find_library(_COREFOUNDATION_LIBRARY NAMES CoreFoundation PATHS "/")

	if(TERRAME_BUILD_AS_BUNDLE)
		set(MACOSX_BUNDLE_BUNDLE_NAME "TerraME")
		set(MACOSX_BUNDLE_COPYRIGHT "Copyright 2001-2017")
		set(MACOSX_BUNDLE_SIGNATURE "TerraME")
		set(MACOSX_BUNDLE_GUI_IDENTIFIER "http://www.terrame.org")
		set(MACOSX_BUNDLE_EXECUTABLE_NAME "terrame")
		set(MACOSX_BUNDLE_INFO_STRING "System for spatial dynamical modelling.")
		set(MACOSX_BUNDLE_ICON_FILE "../Resources/icon/app.icns")
		set(MACOSX_BUNDLE_LONG_VERSION_STRING ${TERRAME_STRING_VERSION})
		set(MACOSX_BUNDLE_SHORT_VERSION_STRING ${TERRAME_PKG_VERSION})
		set(MACOSX_BUNDLE_BUNDLE_VERSION ${TERRAME_STRING_VERSION})

		install(PROGRAMS ${TERRAME_ABSOLUTE_ROOT_DIR}/res/terrame
		        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
		        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
		        COMPONENT runtime)

		configure_file(${CMAKE_ROOT}/Modules/MacOSXBundleInfo.plist.in ${CMAKE_BINARY_DIR}/Info.plist)

		set(CPACK_PACKAGE_ICON "${TERRAME_ABSOLUTE_ROOT_DIR}/res/app.icns")
		set(CPACK_BUNDLE_NAME "TerraME")
		set(CPACK_BUNDLE_ICON ${CPACK_PACKAGE_ICON})
		set(CPACK_BUNDLE_STARTUP_COMMAND ${TERRAME_INSTALL_PREFIX}/bin/terrame) # TODO: REVIEW #1046
		set(CPACK_BUNDLE_PLIST ${CMAKE_BINARY_DIR}/Info.plist)

		set(TERRAME_APP_TYPE MACOSX_BUNDLE)
	endif()
endif()

if(MINGW)
	file(GLOB TERRAME_APP_ICON ${TERRAME_ABSOLUTE_ROOT_DIR}/res/resource.o)
elseif(MSVC)
	file(GLOB TERRAME_APP_ICON ${TERRAME_ABSOLUTE_ROOT_DIR}/res/resource.rc)
endif()

# TODO: REVIEW
 #configure_file(${TERRAME_ABSOLUTE_ROOT_DIR}/src/Config.h.in
			   # ${CMAKE_BINARY_DIR}/terrame_config.h @ONLY)

#
# first check of libraries
#
find_package(Qt5 REQUIRED COMPONENTS Core Gui Widgets PrintSupport Network)
if(Qt5_FOUND)
	message("Qt5 found!")
	set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${Qt5Network_LIBRARIES} ${Qt5Core_LIBRARIES} ${Qt5Gui_LIBRARIES} ${Qt5Widgets_LIBRARIES})
endif()

find_package(Qwt)
if(QWT_FOUND)
	message("Qwt found!")
	message("library: ${QWT_LIBRARY}")
	message("include: ${QWT_INCLUDE_DIR}")
	set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${QWT_LIBRARY})
endif()

find_package(Lua REQUIRED)
if(LUA_FOUND)
	message("Lua found!")
	message("library: ${LUA_LIBRARY}")
	message("include: ${LUA_INCLUDE_DIR}")
	set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${LUA_LIBRARY})
endif()

find_package(Protobuf REQUIRED)
if(PROTOBUF_FOUND)
	add_definitions(-DPROTOBUF_USE_DLLS)
	message("Protobuf found!")
	message("library: ${PROTOBUF_LIBRARY}")
	message("include: ${PROTOBUF_INCLUDE_DIR}")
	message("compiler: ${PROTOBUF_PROTOC_EXECUTABLE}")
	set(TERRAME_OBSERVER_ROOT_DIR ${TERRAME_SRC_DIR}/observer)
	PROTOBUF_GENERATE_CPP(PROTO_SRCS PROTO_HDRS ${TERRAME_OBSERVER_ROOT_DIR}/protocol/protocolBuffers/protocol.proto)
	set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${PROTOBUF_LIBRARY})
endif()

find_package(QtLua REQUIRED)
if(QTLUA_FOUND)
	message("QtLua found!")
	message("library: ${QTLUA_LIBRARY}")
	message("include: ${QTLUA_INCLUDE_DIR}")
	if(WIN32)
		set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${QTLUA_LIBRARY})
	endif()
endif()

find_package(QtLua-extras REQUIRED)
if(QTLUAEXTRAS_FOUND)
	message("QtLua-extras found!")
	message("library: ${QTLUAEXTRAS_LIBRARY}")
	message("include: ${QTLUAEXTRAS_INCLUDE_DIR}")
	if(WIN32)
		set(TERRAME_LIBRARIES ${TERRAME_LIBRARIES} ${QTLUAEXTRAS_LIBRARY})
	endif()
endif()

#
# process TerraME configuration files
#
configure_file(${CMAKE_SOURCE_DIR}/terrameVersion.h.in
               ${TERRAME_ABSOLUTE_ROOT_DIR}/src/core/terrameVersion.h @ONLY)

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
                    ${TERRAME_SRC_DIR}/luaFileSystem
                    ${QWT_INCLUDE_DIR}
                    ${LUA_INCLUDE_DIR}
                    ${PROTOBUF_INCLUDE_DIR}
                    ${Qt5Network_INCLUDE_DIRS} ${Qt5Core_INCLUDE_DIRS} ${Qt5Gui_INCLUDE_DIRS} ${Qt5Widgets_INCLUDE_DIRS})

set(TERRAME_OBSERVER_QRC_FILES ${TERRAME_SRC_DIR}/observer/observerResource.qrc)
QT5_ADD_RESOURCES(TERRAME_OBSERVER_QRC_FILES_ADD ${TERRAME_OBSERVER_QRC_FILES})
source_group("Resource Files\\observer"	FILES ${TERRAME_OBSERVER_QRC_FILES})

include_directories(${CMAKE_CURRENT_BINARY_DIR})

#uic wrap
QT5_WRAP_UI(TERRAME_GEN_HDR_FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES}
                                  ${TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES}
                                  ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES}
                                  ${TERRAME_OBSERVER_UDP_SENDER_UI_FILES})

set(TERRAME_FILES ${TERRAME_CORE_SRC_FILES} ${TERRAME_CORE_HDR_FILES}
                  ${TERRAME_LUA_FILES}
                  ${TERRAME_LUA_FILE_SYSTEM_SRC_FILES} ${TERRAME_LUA_FILE_SYSTEM_HDR_FILES}
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
                  ${TERRAME_OBSERVER_UDP_SENDER_SRC_FILES} ${TERRAME_OBSERVER_UDP_SENDER_HDR_FILES} ${TERRAME_OBSERVER_UDP_SENDER_UI_FILES}
                  ${TERRAME_GEN_HDR_FILES}
                  ${TERRAME_OBSERVER_QRC_FILES} ${TERRAME_OBSERVER_QRC_FILES_ADD}
                  ${TERRAME_APP_ICON})

add_executable(terrame ${TERRAME_APP_TYPE} ${TERRAME_FILES} ${PROTO_SRCS} ${PROTO_HDRS})

#qt5_use_modules(terrame Core Gui Widgets PrintSupport) #TODO: REVIEW

target_link_libraries(terrame ${TERRAME_LIBRARIES})

if(APPLE)
	target_link_libraries(terrame ${_COREFOUNDATION_LIBRARY})
	set_target_properties(terrame PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${CMAKE_BINARY_DIR}/Info.plist)
endif()

if(WIN32 AND MSVC)
	set_target_properties(terrame PROPERTIES
	                      RUNTIME_OUTPUT_DIRECTORY_DEBUG ${TERRAME_BIN_DIR}
	                      RUNTIME_OUTPUT_DIRECTORY_RELEASE ${TERRAME_BIN_DIR})

	set_target_properties(terrame PROPERTIES LINK_FLAGS_DEBUG "/SUBSYSTEM:CONSOLE")
	set_target_properties(terrame PROPERTIES RELWITHDEBINFO "/SUBSYSTEM:CONSOLE")
	set_target_properties(terrame PROPERTIES LINK_FLAGS_RELEASE "/SUBSYSTEM:CONSOLE")
	set_target_properties(terrame PROPERTIES MINSIZEREL "/SUBSYSTEM:CONSOLE")

	string(REGEX REPLACE "/W[0-4]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}") #TODO: REVIEW
endif()

## ------------------------------------- Set Installation procedure -------------------------------------------- ##
install(TARGETS terrame
        RUNTIME DESTINATION bin COMPONENT runtime
        LIBRARY DESTINATION lib COMPONENT runtime
        ARCHIVE DESTINATION lib COMPONENT runtime
        BUNDLE DESTINATION . COMPONENT runtime)

if(NOT DEFINED CMAKE_INSTALL_PREFIX)
	set(CMAKE_INSTALL_PREFIX ${TERRAME_ABSOLUTE_ROOT_DIR}/install)
endif()

set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "runtime")

# install(FILES ${PROTOBUF_INCLUDE_DIR}/../bin/*.dll
		# DESTINATION bin/
		# COMPONENT runtime
		#)

if(APPLE)
	if(TERRAME_BUILD_AS_BUNDLE)
		TmeInstallQtPlugins("qgif;qico;qjpeg;qmng;qtiff;qsvg;qsvgicon;qsqlite;qwindows;qcocoa")

		file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/qt.conf
		     "[Paths]\nBinaries = MacOS\nPlugins = qtplugins")

		install(FILES ${CMAKE_CURRENT_BINARY_DIR}/qt.conf
		        DESTINATION ${TERRAME_INSTALL_PREFIX}/Resources
		        COMPONENT runtime)

		install(FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/res/app.icns
		        DESTINATION ${TERRAME_INSTALL_PREFIX}/Resources/icon
		        COMPONENT runtime)

		set(TERRAME_CURRENT_BINARY_DIR ${TERRAME_INSTALL_PREFIX}/MacOS)

	else()
		set(TERRAME_CURRENT_BINARY_DIR bin)

		install(FILES ${TERRALIB_3RDPARTY_DIR}/lib/liblua.dylib
		        DESTINATION ${TERRAME_INSTALL_PREFIX}/lib
		        COMPONENT runtime)
	endif()

	install(DIRECTORY ${TERRALIB_DIR}/lib
	        DESTINATION ${TERRAME_INSTALL_PREFIX}
	        COMPONENT runtime
	        PATTERN "cmake" EXCLUDE)

	list(APPEND QTLUA_LIBS ${TERRALIB_3RDPARTY_DIR}/lib/libqtluae.0.1.dylib
	                       ${TERRALIB_3RDPARTY_DIR}/lib/qtluae.dylib
	                       ${TERRALIB_3RDPARTY_DIR}/lib/libqtlua.dylib)

	install(FILES ${QTLUA_LIBS}
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/lib
	        COMPONENT runtime)

	set(TERRAME_LUA_SRC_DIR ${TERRAME_SRC_DIR}/lua)

	install(DIRECTORY ${TERRAME_LUA_SRC_DIR}
	        DESTINATION ${TERRAME_CURRENT_BINARY_DIR}
	        COMPONENT runtime)

	set(TERRAME_PACKAGES_DIR ${TERRAME_ABSOLUTE_ROOT_DIR}/packages)

	if(NOT TERRAME_CREATE_INSTALLER)
		install(DIRECTORY ${TERRAME_PACKAGES_DIR}
		        DESTINATION ${TERRAME_CURRENT_BINARY_DIR}
		        COMPONENT runtime
		        PATTERN "windows" EXCLUDE
		        PATTERN "linux" EXCLUDE)
	else()
		install(DIRECTORY ${TERRAME_PACKAGES_DIR}
		        DESTINATION ${TERRAME_CURRENT_BINARY_DIR}
		        COMPONENT runtime
		        PATTERN "log" EXCLUDE
		        PATTERN "test" EXCLUDE
		        PATTERN "tests" EXCLUDE
		        PATTERN "*.tview" EXCLUDE)

		install(DIRECTORY ${TERRAME_ABSOLUTE_ROOT_DIR}/ide/zerobrane
		        DESTINATION ${TERRAME_INSTALL_PREFIX}/ide
		        COMPONENT runtime)
	endif()

#	install(DIRECTORY ${TERRALIB_DIR}/share/data
#			DESTINATION ${TERRAME_INSTALL_PREFIX}/share/data/
#			COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/json
	        DESTINATION ${TERRAME_CURRENT_BINARY_DIR}/share/terralib
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/plugins
	        DESTINATION ${TERRAME_CURRENT_BINARY_DIR}/share/terralib
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/schemas
	        DESTINATION ${TERRAME_CURRENT_BINARY_DIR}/share/terralib
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_3RDPARTY_DIR}/share/gdal
	        DESTINATION ${TERRAME_CURRENT_BINARY_DIR}/share
	        COMPONENT runtime)

	install(DIRECTORY ${TERRAME_DEPENDENCIES_DIR}/luacheck/src/luacheck
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/lib
	        COMPONENT runtime)
elseif(WIN32)
	set(TERRAME_LUA_SRC_DIR ${TERRAME_SRC_DIR}/lua)

	install(DIRECTORY ${TERRAME_LUA_SRC_DIR}/
	        DESTINATION bin/lua
	        COMPONENT runtime)

	set(TERRAME_PACKAGES_DIR ${TERRAME_ABSOLUTE_ROOT_DIR}/packages)

	if(TERRAME_CREATE_INSTALLER)
		install(DIRECTORY ${TERRAME_PACKAGES_DIR}/
		        DESTINATION bin/packages
		        COMPONENT runtime
		        PATTERN "log" EXCLUDE
		        PATTERN "test" EXCLUDE
		        PATTERN "tests" EXCLUDE
		        PATTERN "*.tview" EXCLUDE)

		install(DIRECTORY ${TERRAME_ABSOLUTE_ROOT_DIR}/ide/zerobrane/
		        DESTINATION bin/ide/zerobrane
		        COMPONENT runtime)

		install(PROGRAMS ${TERRAME_ABSOLUTE_ROOT_DIR}/res/configure-zerobrane.bat
		        DESTINATION .
		        COMPONENT runtime)
	else()
		install(DIRECTORY ${TERRAME_PACKAGES_DIR}/
		        DESTINATION bin/packages
		        COMPONENT runtime
		        PATTERN "linux" EXCLUDE
		        PATTERN "mac" EXCLUDE)
	endif()

	set(QTLUA_LIBRARY_DLL ${QTLUA_INCLUDE_DIR}/../../lib/qtlua.dll)
	install(FILES ${QTLUA_LIBRARY_DLL}
	        DESTINATION bin
	        COMPONENT runtime)

	set(QTLUAEXTRAS_LIBRARY_DLL ${QTLUAEXTRAS_INCLUDE_DIR}/../../lib/qtluae.dll)
	install(FILES ${QTLUAEXTRAS_LIBRARY_DLL}
	        DESTINATION bin
	        COMPONENT runtime)

	list(APPEND MSYS_DEPENDENCIES ${MSYS_DIR}/cp.exe
	                              ${MSYS_DIR}/ls.exe
	                              ${MSYS_DIR}/md5sum.exe
	                              ${MSYS_DIR}/mktemp.exe
	                              ${MSYS_DIR}/msys-1.0.dll
	                              ${MSYS_DIR}/msys-iconv-2.dll
	                              ${MSYS_DIR}/msys-intl-8.dll
	                              ${MSYS_DIR}/rm.exe
	                              ${MSYS_DIR}/touch.exe
	                              ${MSYS_DIR}/unzip.exe
	                              ${MSYS_DIR}/zip.exe
	                              ${MSYS_DIR}/mv.exe)

	add_custom_command(TARGET terrame
	                   POST_BUILD
	                   COMMAND ${CMAKE_COMMAND} -E copy "${MSYS_DIR}/find.exe" "${CMAKE_INSTALL_PREFIX}/bin/find.exe"
	                   COMMAND ${CMAKE_COMMAND} -E rename "${CMAKE_INSTALL_PREFIX}/bin/find.exe" "${CMAKE_INSTALL_PREFIX}/bin/find-msys.exe"
	                   COMMENT "Renamed bin/find.exe to bin/find-msys.exe..."
	                   VERBATIM)

	list(APPEND MSYS_DEPENDENCIES ${CMAKE_INSTALL_PREFIX}/bin/find-msys.exe)

	install(FILES ${MSYS_DEPENDENCIES}
	        DESTINATION bin
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/bin/
	        DESTINATION bin
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_3RDPARTY_DIR}/data/
	        DESTINATION bin/share/data
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/json/
	        DESTINATION bin/share/terralib/json
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/plugins/
	        DESTINATION bin/share/terralib/plugins
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/schemas/
	        DESTINATION bin/share/terralib/schemas
	        COMPONENT runtime)

	install(FILES ${Qt5_DIR}/../../../plugins/platforms/qwindowsd.dll
	        DESTINATION bin/platforms
	        COMPONENT runtime
	        CONFIGURATIONS Debug)

	install(FILES ${Qt5_DIR}/../../../plugins/platforms/qwindows.dll
	        DESTINATION bin/platforms
	        COMPONENT runtime
	        CONFIGURATIONS Release)

	list(APPEND TERRALIB_DEPENDENCIES ${TERRALIB_3RDPARTY_DIR}/lib/boost_chrono-mt.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/boost_date_time-mt.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/boost_filesystem-mt.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/boost_system-mt.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/boost_thread-mt.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/expat.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/freexl.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/gdal213.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/geos.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/geos_c.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/hdfdll.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/iconv.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/libcurl.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/libeay32.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/libgeotiff.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/libpng15.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/libpq.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/libtiff.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/libxml2.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/mfhdfdll.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/netcdf.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/pcre.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/proj.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/spatialite.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/sqlite3.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/ssleay32.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/xdrdll.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/xerces-c_3_1.dll
	                                  ${TERRALIB_3RDPARTY_DIR}/lib/xercesc_messages_3_1_1.dll)

	install(FILES ${TERRALIB_DEPENDENCIES}
	        DESTINATION bin
	        COMPONENT runtime
	        CONFIGURATIONS Release)

	install(DIRECTORY ${TERRAME_DEPENDENCIES_DIR}/luacheck/src/luacheck/
	        DESTINATION bin/luacheck
	        COMPONENT runtime)
else(UNIX)
	set(TERRAME_LUA_SRC_DIR ${TERRAME_SRC_DIR}/lua)

	install(DIRECTORY ${TERRAME_LUA_SRC_DIR}
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
	        COMPONENT runtime)

	set(TERRAME_PACKAGES_DIR ${TERRAME_ABSOLUTE_ROOT_DIR}/packages)

	if(NOT TERRAME_CREATE_INSTALLER)
		install(DIRECTORY ${TERRAME_PACKAGES_DIR}/
		        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin/packages
		        COMPONENT runtime
		        PATTERN "windows" EXCLUDE
		        PATTERN "mac" EXCLUDE)

	else()
		install(DIRECTORY ${TERRAME_PACKAGES_DIR}/
		        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin/packages
		        COMPONENT runtime
		        PATTERN "log" EXCLUDE
		        PATTERN "test" EXCLUDE
		        PATTERN "tests" EXCLUDE
		        PATTERN "*.tview" EXCLUDE)

		install(DIRECTORY ${TERRAME_ABSOLUTE_ROOT_DIR}/ide/zerobrane/
		        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin/ide/zerobrane
		        COMPONENT runtime)
	endif()

	install(DIRECTORY ${TERRALIB_DIR}/lib/
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
	        COMPONENT runtime
	        PATTERN "cmake" EXCLUDE)

	list(APPEND QTLUAE_LIBS ${TERRALIB_3RDPARTY_DIR}/lib/libqtluae.so.0.1
	                        ${TERRALIB_3RDPARTY_DIR}/lib/qtluae.so)

	install(FILES ${QTLUAE_LIBS}
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
	        COMPONENT runtime)

	file(GLOB TERRAME_CORE_DEPENDENCIES ${TERRALIB_3RDPARTY_DIR}/lib/libqwt.so*
	                                    ${TERRALIB_3RDPARTY_DIR}/lib/liblua.so*
	                                    ${TERRALIB_3RDPARTY_DIR}/lib/libqtlua.so*)

	install(FILES ${TERRAME_CORE_DEPENDENCIES}
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
	        COMPONENT runtime)

	file(GLOB Qt5_LIBS ${Qt5_DIR}/../../libQt5Network.so*
	                   ${Qt5_DIR}/../../libQt5Gui.so*
	                   ${Qt5_DIR}/../../libQt5Core.so*
	                   ${Qt5_DIR}/../../libQt5Widgets.so*
	                   ${Qt5_DIR}/../../libQt5PrintSupport.so*
	                   ${Qt5_DIR}/../../libQt5Svg.so*
	                   ${Qt5_DIR}/../../libQt5OpenGL.so*
	                   ${Qt5_DIR}/../../libQt5DBus.so*
	                   ${Qt5_DIR}/../../libicui18n.so*
	                   ${Qt5_DIR}/../../libicuuc.so*
	                   ${Qt5_DIR}/../../libicudata.so*
	                   ${Qt5_DIR}/../../libkmldom*so*
	                   ${Qt5_DIR}/../../libkmlengine*so*
	                   ${Qt5_DIR}/../../libkmlbase*so*
	                   ${Qt5_DIR}/../../libminizip*so*
	                   ${Qt5_DIR}/../../../liburiparser*so*)

	install(FILES ${Qt5_LIBS}
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
	        COMPONENT runtime)

	install(FILES ${Qt5_DIR}/../../qt5/plugins/platforms/libqxcb.so
	        DESTINATION bin/platforms
	        COMPONENT runtime)

	file(GLOB TERRALIB_DEPENDENCIES ${TERRALIB_3RDPARTY_DIR}/lib/libboost_system.so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libboost_date_time.so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libboost_filesystem.so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libboost_thread.so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libboost_locale.so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libboost_regex.so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libboost_log.so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libboost_log_setup.so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libgeos*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libproj*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libxerces*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libsz*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libgeotiff*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libjpeg*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libpng*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libspatialite*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libfreexl*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libpcre*so*
	                                ${TERRALIB_3RDPARTY_DIR}/pgsql/lib/libpq*so*
	                                ${TERRALIB_3RDPARTY_DIR}/lib/libgdal.so*)

	install(FILES ${TERRALIB_DEPENDENCIES}
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/json
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin/share/terralib
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/plugins
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin/share/terralib
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_DIR}/share/terralib/schemas
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin/share/terralib
	        COMPONENT runtime)

	install(DIRECTORY ${TERRALIB_3RDPARTY_DIR}/share/gdal
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin/share
	        COMPONENT runtime)

	install(DIRECTORY ${TERRAME_DEPENDENCIES_DIR}/luacheck/src/luacheck/
	        DESTINATION ${TERRAME_INSTALL_PREFIX}/bin/luacheck
	        COMPONENT runtime)
endif()

if(TERRAME_BUILD_AS_BUNDLE)
	include(InstallRequiredSystemLibraries)

	if(WIN32)
		install(FILES ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
		DESTINATION bin
		COMPONENT runtime)
	endif()

	configure_file(${terrame_SOURCE_DIR}/fixBundle.cmake.in ${terrame_BINARY_DIR}/fixBundle.cmake @ONLY)
	install(SCRIPT ${CMAKE_BINARY_DIR}/fixBundle.cmake COMPONENT runtime)
endif()
