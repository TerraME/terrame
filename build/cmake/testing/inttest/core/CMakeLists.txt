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
set(CMAKE_AUTOMOC ON)

if(MSVC)
	set(CMAKE_CXX_FLAGS_RELEASE "/MD")
endif(MSVC)

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER MATCHES ".*clang") OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
endif()

include_directories (${CMAKE_BINARY_DIR})
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src/core)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/chartPlot)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/udpsender)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/player)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/protocol/blackBoard)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/inttest/terrame)
include_directories(${GTEST_INCLUDE_DIRS} ${GMOCK_INCLUDE_DIRS})

file(GLOB TERRAME_OBSERVER_TYPES_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/*.cpp)
file(GLOB TERRAME_OBSERVER_TYPES_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/*.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/canvas.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/canvas.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/legend/legendWindow.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/legend/legendWindow.h)
list(APPEND TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/legend/legendColorBar.cpp)
list(APPEND TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/legend/legendColorBar.h)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PAINTER_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/painter/*.cpp)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PAINTER_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/painter/*.h)
file(GLOB TERRAME_OBSERVER_TYPES_CHART_PLOT_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/chartPlot/chartPlot.cpp)
file(GLOB TERRAME_OBSERVER_TYPES_CHART_PLOT_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/chartPlot/chartPlot.h)
file(GLOB TERRAME_OBSERVER_UDP_SENDER_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/udpSender/*.cpp)
file(GLOB TERRAME_OBSERVER_UDP_SENDER_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/udpSender/*.h)

find_package(Qt5 REQUIRED COMPONENTS Core Gui Widgets PrintSupport Network)
include_directories(${Qt5Network_INCLUDE_DIRS} ${Qt5Core_INCLUDE_DIRS} ${Qt5Gui_INCLUDE_DIRS} ${Qt5Widgets_INCLUDE_DIRS})

file(GLOB TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/console/*.ui)
file(GLOB TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/player/*.ui)
file(GLOB TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/components/receiver/*.ui)
file(GLOB TERRAME_OBSERVER_UDP_SENDER_UI_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/observer/types/udpSender/*.ui)

QT5_WRAP_UI(TERRAME_GEN_HDR_FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES}
                                  ${TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES}
                                  ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES}
                                  ${TERRAME_OBSERVER_UDP_SENDER_UI_FILES})

find_package(Qwt)
include_directories(${QWT_INCLUDE_DIR})

find_package(Lua REQUIRED)
include_directories(${LUA_INCLUDE_DIR})

file(GLOB TERRAME_INTTEST_CORE_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/inttest/core/*.cpp)
file(GLOB TERRAME_INTTEST_CORE_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/inttest/core/*.h)

source_group("Source Files\\core" FILES ${TERRAME_INTTEST_CORE_SRC_FILES})
source_group("Header Files\\core" FILES ${TERRAME_INTTEST_CORE_HDR_FILES})

source_group("Source Files\\observer" FILES ${TERRAME_OBSERVER_TYPES_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_SRC_FILES}
                                            ${TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_PAINTER_SRC_FILES}
                                            ${TERRAME_OBSERVER_TYPES_CHART_PLOT_SRC_FILES} ${TERRAME_OBSERVER_UDP_SENDER_SRC_FILES})

source_group("Header Files\\observer" FILES ${TERRAME_OBSERVER_TYPES_HDR_FILES} ${TERRAME_OBSERVER_COMPONENTS_HDR_FILES}
                                            ${TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES} ${TERRAME_OBSERVER_COMPONENTS_PAINTER_HDR_FILES}
                                            ${TERRAME_OBSERVER_TYPES_CHART_PLOT_HDR_FILES} ${TERRAME_OBSERVER_UDP_SENDER_HDR_FILES}
                                            ${TERRAME_GEN_HDR_FILES})

source_group("UI Files\\observer" FILES ${TERRAME_OBSERVER_COMPONENTS_CONSOLE_UI_FILES} ${TERRAME_OBSERVER_COMPONENTS_PLAYER_UI_FILES}
                                        ${TERRAME_OBSERVER_COMPONENTS_RECEIVER_UI_FILES} ${TERRAME_OBSERVER_UDP_SENDER_UI_FILES})

add_executable(core_itest ${TERRAME_INTTEST_SRC_FILES}
                       ${TERRAME_INTTEST_CORE_SRC_FILES} ${TERRAME_INTTEST_CORE_HDR_FILES}
                       ${TERRAME_OBSERVER_TYPES_SRC_FILES} ${TERRAME_OBSERVER_TYPES_HDR_FILES}
                       ${TERRAME_OBSERVER_COMPONENTS_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_HDR_FILES}
                       ${TERRAME_OBSERVER_COMPONENTS_LEGEND_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_LEGEND_HDR_FILES}
                       ${TERRAME_OBSERVER_COMPONENTS_PAINTER_SRC_FILES} ${TERRAME_OBSERVER_COMPONENTS_PAINTER_HDR_FILES}
                       ${TERRAME_OBSERVER_TYPES_CHART_PLOT_SRC_FILES} ${TERRAME_OBSERVER_TYPES_CHART_PLOT_HDR_FILES}
                       ${TERRAME_OBSERVER_UDP_SENDER_SRC_FILES} ${TERRAME_OBSERVER_UDP_SENDER_HDR_FILES}
                       ${TERRAME_GEN_HDR_FILES})

target_link_libraries(core_itest ${GTEST_BOTH_LIBRARIES} ${GMOCK_BOTH_LIBRARIES}
                              ${Qt5Network_LIBRARIES} ${Qt5Core_LIBRARIES} ${Qt5Gui_LIBRARIES} ${Qt5Widgets_LIBRARIES}
                              ${QWT_LIBRARY})

install(TARGETS core_itest
        RUNTIME DESTINATION ${TERRAME_DESTINATION_RUNTIME}
        COMPONENT runtime)

add_test(NAME core_itest COMMAND core_itest)