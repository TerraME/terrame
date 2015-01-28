# This script builds the TerraME
# (c) Gilberto Camara, Gilberto Ribeiro, Raian Maretto, Pedro R. Andrade june 2011
# (c) Rodrigo Reis january 2012, febuary 2013
# (c) Antonio Jose Rodrigues febuary 2013
# (c) Raian Vargas Maretto january 2014, september 2014, december 2014

cmake_minimum_required(VERSION 3.0)
project(TerraME)

set(ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../..)

set(DEPS ${ROOT}/dependencies)
set(SRCDIR ${ROOT}/src) # this is the directory where terralib sources will be located
set(SRCDIR_OBSERVER ${SRCDIR}/observer)

set(BLDIR  ${ROOT}/build/cmake) # this is the directory where cmake scripts are
set(CMAKE_MODULE_PATH ${BLDIR}/Find) # this is the directory where additional scritps are located

## Sets type of build: Release or Debug
set(CMAKE_BUILD_TYPE Release)

#-- TODO: Verify the effect these lines and make it works, if possible!!
if(CMAKE_COMPILER_IS_GNUCXX)
	message("  -- Otimization enabled!! ")
	set(CMAKE_CXX_FLAGS_RELEASE "-O3")        ## Optimize
	set(CMAKE_CXX_FLAGS_DEBUG  "-O0 -g")
	set(CMAKE_EXE_LINKER_FLAGS "-s")  ## Strip binary
endif(CMAKE_COMPILER_IS_GNUCXX)

#-- TODO: Veify all these flags. All of them are really necessary?
add_definitions(-w -DTME_LUA_5_2 -DTME_TERRALIB_RC3 -DQWT_DLL 
				-DTME_BLACK_BOARD -DTME_PROTOCOL_BUFFERS ) #Set -D define flags to the compilation of source files

set(BINARY_DIR ${ROOT}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR})
set(BASE_DIR ${ROOT}/base)

# file(MAKE_DIRECTORY ${BINARY_DIR}/packages)

# file(MAKE_DIRECTORY ${ROOT}/bin/lua)

file(COPY
	${BASE_DIR}/

	DESTINATION ${BINARY_DIR}/packages/base/
)

file(COPY
	${SRCDIR}/lua/

	DESTINATION ${BINARY_DIR}/lua/
)

message("Using additional find package files located in ${CMAKE_MODULE_PATH}")

file(GLOB_RECURSE INC_ALL *.h)

#Set include directories location
include_directories( ${SRCDIR}
	${SRCDIR}/core/
	${SRCDIR_OBSERVER}/components
	${SRCDIR_OBSERVER}/icons
	${SRCDIR_OBSERVER}/protocol
	${SRCDIR_OBSERVER}/statistic
	${SRCDIR_OBSERVER}/types
	${SRCDIR_OBSERVER}/components/console
	${SRCDIR_OBSERVER}/components/legend
	${SRCDIR_OBSERVER}/components/logFileTask
	${SRCDIR_OBSERVER}/components/painter
	${SRCDIR_OBSERVER}/components/player
	${SRCDIR_OBSERVER}/components/receiver
	${SRCDIR_OBSERVER}/components/senderGUI
	${SRCDIR_OBSERVER}/components/socketTask
	${SRCDIR_OBSERVER}/components/spatialObserver
	${SRCDIR_OBSERVER}/components/receiver/tcp
	${SRCDIR_OBSERVER}/components/receiver/udp
	${SRCDIR_OBSERVER}/protocol/blackBoard
	${SRCDIR_OBSERVER}/protocol/decoder
	${SRCDIR_OBSERVER}/types/chartPlot
	${SRCDIR_OBSERVER}/types/image
	${SRCDIR_OBSERVER}/types/stateMachine
	${SRCDIR_OBSERVER}/
	${SRCDIR_OBSERVER}/bagOfTasks
	${SRCDIR}/luaFileSystem

	/usr/local/include
)

# Set source files location
file(GLOB SRCS  
	${SRCDIR}/core/*.cpp 
	${SRCDIR_OBSERVER}/components/*.cpp 
	${SRCDIR_OBSERVER}/icons/*.cpp 
	${SRCDIR_OBSERVER}/protocol/*.cpp 
	${SRCDIR_OBSERVER}/statistic/*.cpp 
	${SRCDIR_OBSERVER}/types/*.cpp 
	${SRCDIR_OBSERVER}/components/console/*.cpp 
	${SRCDIR_OBSERVER}/components/legend/*.cpp 
	${SRCDIR_OBSERVER}/components/logFileTask/*.cpp 
	${SRCDIR_OBSERVER}/components/painter/*.cpp 
	${SRCDIR_OBSERVER}/components/player/*.cpp 
	${SRCDIR_OBSERVER}/components/receiver/*.cpp 
	${SRCDIR_OBSERVER}/components/senderGUI/*.cpp 
	${SRCDIR_OBSERVER}/components/socketTask/*.cpp 
	${SRCDIR_OBSERVER}/components/spatialObserver/*.cpp 
	${SRCDIR_OBSERVER}/components/receiver/tcp/*.cpp 
	${SRCDIR_OBSERVER}/components/receiver/udp/*.cpp 
	${SRCDIR_OBSERVER}/protocol/blackBoard/*.cpp 
	${SRCDIR_OBSERVER}/protocol/decoder/*.cpp
	${SRCDIR_OBSERVER}/types/chartPlot/*.cpp 
	${SRCDIR_OBSERVER}/types/image/*.cpp 
	${SRCDIR_OBSERVER}/types/stateMachine/*.cpp 
	${SRCDIR_OBSERVER}/*.cpp
	${SRCDIR_OBSERVER}/bagOfTasks/*.cpp
	${SRCDIR}/luaFileSystem/*.c
)

# Set header files location
file(GLOB HEADERS 
	${SRCDIR}/core/*.h 
	${SRCDIR_OBSERVER}/components/*.h 
	${SRCDIR_OBSERVER}/icons/*.h 
	${SRCDIR_OBSERVER}/protocol/*.h 
	${SRCDIR_OBSERVER}/statistic/*.h 
	${SRCDIR_OBSERVER}/types/*.h 
	${SRCDIR_OBSERVER}/components/console/*.h 
	${SRCDIR_OBSERVER}/components/legend/*.h 
	${SRCDIR_OBSERVER}/components/logFileTask/*.h 
	${SRCDIR_OBSERVER}/components/painter/*.h 
	${SRCDIR_OBSERVER}/components/player/*.h 
	${SRCDIR_OBSERVER}/components/receiver/*.h 
	${SRCDIR_OBSERVER}/components/senderGUI/*.h 
	${SRCDIR_OBSERVER}/components/socketTask/*.h 
	${SRCDIR_OBSERVER}/components/spatialObserver/*.h 
	${SRCDIR_OBSERVER}/components/receiver/tcp/*.h 
	${SRCDIR_OBSERVER}/components/receiver/udp/*.h 
	${SRCDIR_OBSERVER}/protocol/blackBoard/*.h 
	${SRCDIR_OBSERVER}/protocol/decoder/*.h
	${SRCDIR_OBSERVER}/types/chartPlot/*.h 
	${SRCDIR_OBSERVER}/types/image/*.h 
	${SRCDIR_OBSERVER}/types/stateMachine/*.h 
	${SRCDIR_OBSERVER}/*.h 
	${SRCDIR_OBSERVER}/bagOfTasks/*.h
	${SRCDIR}/luaFileSystem/*.h
)

set(LIBS)

### --------------
# Shapelib sources
##-- TODO: Verify if it is all correct and review the file FindShapelibSrcs.cmake
find_package(ShapelibSrcs REQUIRED)
if(SHAPELIB_FOUND)
	message("-- Found Shapelib sources in ${SHAPELIB_SRC_DIR}")
	file(GLOB SHAPELIB_HEADERS ${SHAPELIB_SRC_DIR}/*.h)
	file(GLOB SHAPELIB_SRCS 
		${SHAPELIB_SRC_DIR}/*.cpp
		${SHAPELIB_SRC_DIR}/*.c
	)
	include_directories(${SHAPELIB_SRC_DIR})
else(SHAPELIB_FOUND)
	message(FATAL_ERROR "-- Shapelib source code was not found in the dependencies folder")
endif(SHAPELIB_FOUND)

## ---------------------------------------- Find dependencies -------------------------------------------------- ##
#TerraLib
#-- TODO: Vefify if it is all correct
if(MINGW)
	set(TERRALIB_KERNEL_INCLUDE_DIR ${DEPS}/terralib/src/terralib/kernel )
	set(TERRALIB_MYSQL_INCLUDE_DIR ${DEPS}/terralib/src/terralib/drivers/MySQL)
	set(TERRALIB_JPEG_INCLUDE_DIR  ${DEPS}/terralib/src/terralib/drivers/libjpeg )
	set(TERRALIB_LIBRARIES ${DEPS}/terralib/Release/win32-g++)
	Set(TERRALIB_LIBRARY ${TERRALIB_LIBRARIES}/libterralib.a)
	set(TERRALIB_FOUND TRUE)
else(MINGW)
	find_package(TerraLib)
endif(MINGW)
if( TERRALIB_FOUND )
	message("-- Found TerraLib library ${TERRALIB_LIBRARY} and include dir ${TERRLIB_INCLUDE_DIR}")
	include_directories(${TERRALIB_KERNEL_INCLUDE_DIR})
	include_directories(${TERRALIB_MYSQL_INCLUDE_DIR})
	include_directories(${TERRALIB_JPEG_INCLUDE_DIR})
	link_directories(${TERRALIB_LIBRARY})
	set(LIBS ${LIBS} ${TERRALIB_LIBRARY})
endif( TERRALIB_FOUND )

### --------------
#MySQL 
#-- TODO: Vefify if it is all correct and how we can use the CMAKE finder instead of this.
if(MINGW) 
	set(MYSQL_INCLUDE_DIR ${DEPS}/terralib/src/MySQL/)
	set(MYSQL_LIBRARIES ${DEPS}/terralib/dependencies/win32/MySQL/lib/mingw)
	set(MYSQL_LIBRARY ${MYSQL_LIBRARIES}/libmysql_mingw.a)
	set(MYSQL_FOUND true)
elseif(MINGW)
	find_package(MySQL)
endif(MINGW) 

#-- TODO: Vefify if it is all correct and how we can use the CMAKE finder instead of this.
if( MYSQL_FOUND )
	message("-- Found MySQL library ${MYSQL_LIBRARY} and include dir ${MYSQL_INCLUDE_DIR}")
	include_directories(${SRCDIR} ${MYSQL_INCLUDE_DIR})
	set(LIBS ${LIBS} ${MYSQL_LIBRARY})
	#list(APPEND SRCS ${TERRALIB_MYSQL_INCLUDE_DIR}/TeMySQL.cpp)
endif( MYSQL_FOUND )

if(MINGW) 
	#TE_MYSQL
	set(TE_MYSQL_LIBRARY ${TERRALIB_LIBRARIES}/libte_mysql.a)
	set(LIBS ${LIBS} ${TE_MYSQL_LIBRARY})
endif(MINGW)

### --------------
#JPEG
#-- TODO: Vefify if it is all correct
if(MINGW)
	set(JPEG_INCLUDE_DIR ${DEPS}/terralib/src/libjpeg)
	set(JPEG_LIBRARIES ${DEPS}/terralib/Release/win32-g++/)
	set(JPEG_LIBRARY ${JPEG_LIBRARIES}/libjpeg.a)
	set(LIBS ${LIBS} ${JPEG_LIBRARY})
else(MINGW)
	find_package(JPEG REQUIRED)
	set(LIBS ${LIBS} ${JPEG_LIBRARIES})
endif(MINGW)
link_directories(${JPEG_LIBRARIES})
include_directories(${JPEG_INCLUDE_DIR})

### --------------
#QWT
#-- TODO: Vefify if it is all correct and how we can use the CMAKE finder instead of this.
if(MINGW)
	set(QWT_INCLUDE_DIR ${DEPS}/qwt/src)
	set(QWT_LIBRARIES ${DEPS}/qwt/lib)
	set(QWT_LIBRARY ${QWT_LIBRARIES}/libqwt5.a)
	set(QWT_FOUND true)
	if(QWT_FOUND)
		message("-- Found Qwt library ${QWT_LIBRARY} and include_dir ${QWT_INCLUDE_DIR}")
		include_directories(${QWT_INCLUDE_DIR})
		link_directories(${QWT_LIBRARIES})
		set(LIBS ${LIBS} ${QWT_LIBRARY})
	endif(QWT_FOUND)
else(MINGW)
	find_package(qwt-qt5)
	if(QWT_FOUND)
		message("-- Found Qwt library ${QWT_LIBRARY} and include directories ${QWT_INCLUDE_DIR}")
		include_directories(${QWT_INCLUDE_DIR})
		link_directories(${QWT_LIBRARY_DIR})
		if(QWTQT5_LIBRARY)
			set(LIBS ${LIBS} ${QWTQT5_LIBRARY})
		else(QWTQT5_LIBRARY)
			set(LIBS ${LIBS} ${QWT_LIBRARY})
		endif(QWTQT5_LIBRARY)
	endif( QWT_FOUND )
endif(MINGW)

### --------------
#LUA52
#-- TODO: Vefify if it is all correct and how we can use the CMAKE finder instead of this.
if(MINGW)
	set(LUA_INCLUDE_DIR ${DEPS}/lua/include)
	set(LUA_LIBRARIES ${DEPS}/lua/lib)
	Set(LUA_LIBRARY ${LUA_LIBRARIES}/liblua5.2.a)
	set(LIBS ${LIBS} ${LUA_LIBRARY})
else(MINGW)
	find_package(Lua52 REQUIRED)
endif(MINGW)

if(LUA_FOUND)
	message("-- Found Lua library ${LUA_LIBRARY} and include dir ${LUA_INCLUDE_DIR}") 
	link_directories(${LUA_LIBRARY})
	include_directories(${LUA_INCLUDE_DIR})
	set(LIBS ${LIBS} ${LUA_LIBRARY})
endif(LUA_FOUND)

### --------------
#RANDOM
if(MINGW)
	set(RANDOM_INCLUDE_DIR ${DEPS}/random/include)
	set(RANDOM_LIBRARY ${DEPS}/random/src/libRandom.a)
	link_directories(${RANDOM_LIBRARY})
	include_directories(${RANDOM_INCLUDE_DIR})
	set(LIBS ${LIBS} ${RANDOM_LIBRARY})
else(MINGW)
	find_package(Random REQUIRED)
	if(RANDOM_FOUND)
		message("-- Found RandomLib library ${RANDOM_LIBRARY} and include dir ${RANDOM_INCLUDE_DIR}")
		link_directories(${RANDOM_LIBRARY})
		include_directories(${RANDOM_INCLUDE_DIR})
		set(LIBS ${LIBS} ${RANDOM_LIBRARY})
	endif(RANDOM_FOUND)
endif(MINGW)

### --------------
#PROTOCOL BUFFERS
#-- TODO: Vefify if it is all correct
find_package(Protobuf REQUIRED)
if(PROTOBUF_FOUND)
	if(PROTOBUF_PROTOC_EXECUTABLE)
		message("-- Found Protocol Buffers library ${PROTOBUF_LIBRARY}, include dir ${PROTOBUF_INCLUDE_DIR} and compiler ${PROTOBUF_PROTOC_EXECUTABLE}")
	
		protobuf_generate_cpp(PROTO_SRC PROTO_HEADER ${SRCDIR_OBSERVER}/protocol/protocolBuffers/protocol.proto)

		link_directories(${PROTOBUF_LIBRARY})
		include_directories(${PROTOBUF_INCLUDE_DIR})
		set(LIBS ${LIBS} ${PROTOBUF_LIBRARY})
	else(PROTOBUF_PROTOC_EXECUTABLE)
		message( FATAL_ERROR "-- Protocol Buffers compiler was not found" )
	endif(PROTOBUF_PROTOC_EXECUTABLE)
else(PROTOBUF_FOUND)
	message( FATAL_ERROR "-- Protocol Buffers package was not found.")
endif(PROTOBUF_FOUND)

### --------------
#QT5
#-- TODO: Vefify if it is all correct and how to check the version
find_package(Qt5Widgets REQUIRED)
find_package(Qt5Network REQUIRED)
find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
# set(QT_USE_QTNETWORK TRUE)
# include(${QT_USE_FILE})
set(LIBS ${LIBS} ${Qt5Network_LIBRARIES} ${Qt5Core_LIBRARIES} ${Qt5Gui_LIBRARIES} ${Qt5Widgets_LIBRARIES})
link_directories(${Qt5Network_LIBRARIES} ${Qt5Core_LIBRARIES} ${Qt5Gui_LIBRARIES} ${Qt5Widgets_LIBRARIES})
include_directories(${Qt5Network_INCLUDE_DIRS} ${Qt5Core_INCLUDE_DIRS} ${Qt5Gui_INCLUDE_DIRS} ${Qt5Widgets_INCLUDE_DIRS})

### --------------
#QtLua
find_package(QtLua REQUIRED)
if(QTLUA_FOUND)
	message("-- Found QtLua library ${QTLUA_LIBRARY} and include directories ${QTLUA_INCLUDE_DIR}")
	# TODO: Vefify if it is realy necessary (TerraME needs to link to QtLua?)
	# include_directories(${QTLUA_INCLUDE_DIR})
	# link_directories(${QTLUA_LIBRARY})
	# if(QTLUA_LIBRARY)
	# 	set(LIBS ${LIBS} ${QTLUA_LIBRARY})
	# else(QTLUA_LIBRARY)
	# 	set(LIBS ${LIBS} ${QTLUA_LIBRARY})
	# endif(QTLUA_LIBRARY)
else(QTLUA_FOUND)
	message( FATAL_ERROR "-- QtLua library was not found.")
endif(QTLUA_FOUND)

### --------------
#QtLua-extras
find_package(QtLua-extras REQUIRED)
if(QTLUAEXTRAS_FOUND)
	message("-- Found QtLua-extras library ${QTLUAEXTRAS_LIBRARY} and include directories ${QTLUAEXTRAS_INCLUDE_DIR}")
	# TODO: Vefify if it is realy necessary (TerraME needs to link to QtLua-extras?)
	# include_directories(${QTLUA_INCLUDE_DIR})
	# link_directories(${QTLUAEXTRAS_LIBRARY})
	# if(QTLUAEXTRAS_LIBRARY)
	# 	set(LIBS ${LIBS} ${QTLUAEXTRAS_LIBRARY})
	# else(QTLUAEXTRAS_LIBRARY)
	# 	set(LIBS ${LIBS} ${QTLUAEXTRAS_LIBRARY})
	# endif(QTLUAEXTRAS_LIBRARY)
else(QTLUAEXTRAS_FOUND)
	message( FATAL_ERROR "-- QtLua-extras library was not found.")
endif(QTLUAEXTRAS_FOUND)

## ------------------------------------------------------------------------------------------------------------- ##
# Set Qt moc parameters

set(MOC_SRCS)

set(MOC_HDRS
	${SRCDIR_OBSERVER}/types/observerScheduler.h
	${SRCDIR_OBSERVER}/types/observerStateMachine.h
	${SRCDIR_OBSERVER}/types/observerMapSuperclass.h
	${SRCDIR_OBSERVER}/types/image/imageGUI.h
	${SRCDIR_OBSERVER}/types/observerShapefile.h
	${SRCDIR_OBSERVER}/types/observerTCPSender.h
	${SRCDIR_OBSERVER}/types/observerGraphic.h
	${SRCDIR_OBSERVER}/types/observerUDPSender.h
	${SRCDIR_OBSERVER}/types/chartPlot/plotPropertiesGUI.h
	${SRCDIR_OBSERVER}/types/chartPlot/chartPlot.h
	${SRCDIR_OBSERVER}/types/observerMap.h
	${SRCDIR_OBSERVER}/statistic/statistic.h
	${SRCDIR_OBSERVER}/components/receiver/receiverGUI.h
	${SRCDIR_OBSERVER}/components/receiver/legendGUI.h
	${SRCDIR_OBSERVER}/components/receiver/udp/receiverUDP.h
	${SRCDIR_OBSERVER}/components/receiver/udp/datagramReceiverTask.h
	${SRCDIR_OBSERVER}/components/receiver/tcp/clientTcpConnection.h
	${SRCDIR_OBSERVER}/components/receiver/tcp/receiverTcpServer.h
	${SRCDIR_OBSERVER}/components/painter/visualMapping.h
	${SRCDIR_OBSERVER}/components/painter/calculateResult.h
	${SRCDIR_OBSERVER}/components/painter/painterWidget.h
	${SRCDIR_OBSERVER}/components/player/playerGUI.h
	${SRCDIR_OBSERVER}/components/legend/legendWindow.h
	${SRCDIR_OBSERVER}/components/legend/legendColorBar.h
	${SRCDIR_OBSERVER}/components/spatialObserver/spatialObserverGUI.h
	${SRCDIR_OBSERVER}/components/spatialObserver/smartSplitter.h
	${SRCDIR_OBSERVER}/components/spatialObserver/canvas.h
	${SRCDIR_OBSERVER}/components/socketTask/udpSocketTask.h
	${SRCDIR_OBSERVER}/components/socketTask/tcpSocketTask.h
	${SRCDIR_OBSERVER}/components/senderGUI/senderGUI.h
	${SRCDIR_OBSERVER}/components/console/modelConsole.h
)

set(MOC_RSRCS 
	${SRCDIR_OBSERVER}/observerResource.qrc
)

set(UIS
	${SRCDIR_OBSERVER}/types/image/imageGUI.ui
	${SRCDIR_OBSERVER}/types/chartPlot/plotPropertiesGUI.ui
	${SRCDIR_OBSERVER}/components/receiver/legendGUI.ui
	${SRCDIR_OBSERVER}/components/receiver/receiverGUI.ui
	${SRCDIR_OBSERVER}/components/player/playerGUI.ui
	${SRCDIR_OBSERVER}/components/spatialObserver/spatialObserverGUI.ui
	${SRCDIR_OBSERVER}/components/senderGUI/senderGUI.ui
	${SRCDIR_OBSERVER}/components/console/modelConsoleGUI.ui
)

qt5_wrap_cpp(MOC_SRCS ${MOC_HDRS})
qt5_add_resources(MOC_SRCS ${MOC_RSRCS})
qt5_wrap_ui(UI_SRCS ${UIS})

include_directories(${CMAKE_CURRENT_BINARY_DIR})

#RAIAN: 
set(CMAKE_INSTALL_RPATH "@executable_path/../lib;/usr/local/terrame/lib")
#Ver o que acontece caso esta linha seja comentada.
set(CMAKE_INSTALL_NAME_DIR "@executable_path/../lib")
set(CMAKE_BUILD_WITH_INSTALL_RPATH true)
set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH true)

## ------------------------------------------------------------------------------------------------------------- ##
# Add Target and link directories, and link with libraries
add_executable( terrame 
	${SRCS} 
	${MOC_SRCS} 
	${UI_SRCS} 
	${HEADERS} 
	${INC_ALL} 
	${MOC_HDRS} 
	${PROTO_SRC} 
	${SHAPELIB_SRCS}
	${SHAPELIB_HEADERS}
	${PROTO_HEADER})

link_directories(/usr/lib) # Set link directories
target_link_libraries(terrame ${LIBS}) # Link with libraries

set_target_properties( terrame PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ${BINARY_DIR}
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ${BINARY_DIR}
)

## --------------------------------------- Defining source groups ---------------------------------------------- ##

#-- TODO: Change it to another file if possible.
source_group("core" FILES 
	${SRCDIR}/core/*
	${SRCDIR}/core/agent.h
	${SRCDIR}/core/bridge.h
	${SRCDIR}/core/cell.h
	${SRCDIR}/core/cellularSpace.h
	${SRCDIR}/core/composite.h
	${SRCDIR}/core/controlMode.h
	${SRCDIR}/core/environment.h
	${SRCDIR}/core/environment.cpp
	${SRCDIR}/core/event.h
	${SRCDIR}/core/event.cpp
	${SRCDIR}/core/loadNeighborhood.h
	${SRCDIR}/core/luaAgent.h
	${SRCDIR}/core/luaCell.h
	${SRCDIR}/core/luaCell.cpp
	${SRCDIR}/core/luaCellIndex.h
	${SRCDIR}/core/luaCellularSpace.h
	${SRCDIR}/core/luaCellularSpace.cpp
	${SRCDIR}/core/luaControlMode.h
	${SRCDIR}/core/luaEnvironment.h
	${SRCDIR}/core/luaEnvironment.cpp
	${SRCDIR}/core/luaEvent.h
	${SRCDIR}/core/luaEvent.cpp
	${SRCDIR}/core/luaFlowCondition.h
	${SRCDIR}/core/luaGlobalAgent.h
	${SRCDIR}/core/luaGlobalAgent.cpp
	${SRCDIR}/core/luaJumpCondition.h
	${SRCDIR}/core/luaLocalAgent.h
	${SRCDIR}/core/luaLocalAgent.cpp
	${SRCDIR}/core/luaMessage.h
	${SRCDIR}/core/luaNeighborhood.cpp
	${SRCDIR}/core/luaNeighborhood.h
	${SRCDIR}/core/imageCompare.h
	${SRCDIR}/core/imageCompare.cpp
	${SRCDIR}/core/luaRandomUtils.h
	${SRCDIR}/core/luaRegion.h
	${SRCDIR}/core/luaRule.h
	${SRCDIR}/core/luaSociety.cpp
	${SRCDIR}/core/luaSociety.h
	${SRCDIR}/core/luaTimer.cpp
	${SRCDIR}/core/luaTimer.h
	${SRCDIR}/core/luaTrajectory.cpp
	${SRCDIR}/core/luaTrajectory.h
	${SRCDIR}/core/luaVisualArrangement.cpp
	${SRCDIR}/core/luaVisualArrangement.h
	${SRCDIR}/core/luaMap.cpp
	${SRCDIR}/core/luaMap.h
	${SRCDIR}/core/luaChart.cpp
	${SRCDIR}/core/luaChart.h
	${SRCDIR}/core/luaUtils.cpp
	${SRCDIR}/core/luaUtils.h
	${SRCDIR}/core/luna.h
	${SRCDIR}/core/message.h
	${SRCDIR}/core/model.cpp
	${SRCDIR}/core/model.h
	${SRCDIR}/core/neighborhood.h
	${SRCDIR}/core/process.h
	${SRCDIR}/core/reference.h
	${SRCDIR}/core/region.h
	${SRCDIR}/core/registryObjects.h
	${SRCDIR}/core/rule.h
	${SRCDIR}/core/scheduler.h
	${SRCDIR}/core/society.h
	${SRCDIR}/core/strategy.h
	${SRCDIR}/core/terrameGlobals.h
	${SRCDIR}/core/terrameLua.cpp
	${SRCDIR}/core/terrameLua.h
	${SRCDIR}/core/terrameLua5_0.h
	${SRCDIR}/core/terrameLua5_1.h
)

source_group("observer" FILES
	${SRCDIR_OBSERVER}/cellSpaceSubjectInterf.cpp
	${SRCDIR_OBSERVER}/cellSpaceSubjectInterf.h
	${SRCDIR_OBSERVER}/cellSubjectInterf.cpp
	${SRCDIR_OBSERVER}/cellSubjectInterf.h
	${SRCDIR_OBSERVER}/environmentSubjectInterf.cpp
	${SRCDIR_OBSERVER}/environmentSubjectInterf.h
	${SRCDIR_OBSERVER}/eventSubjectInterf.cpp
	${SRCDIR_OBSERVER}/eventSubjectInterf.h
	${SRCDIR_OBSERVER}/globalAgentSubjectInterf.cpp
	${SRCDIR_OBSERVER}/globalAgentSubjectInterf.h
	${SRCDIR_OBSERVER}/localAgentSubjectInterf.cpp
	${SRCDIR_OBSERVER}/localAgentSubjectInterf.h
	${SRCDIR_OBSERVER}/neighborhoodSubjectInterf.cpp
	${SRCDIR_OBSERVER}/neighborhoodSubjectInterf.h
	${SRCDIR_OBSERVER}/observer.h
	${SRCDIR_OBSERVER}/observerGlobals.h
	${SRCDIR_OBSERVER}/observerImpl.cpp
	${SRCDIR_OBSERVER}/observerImpl.h
	${SRCDIR_OBSERVER}/observerInterf.cpp
	${SRCDIR_OBSERVER}/observerInterf.h
	${SRCDIR_OBSERVER}/observerLua.h
	${SRCDIR_OBSERVER}/schedulerSubjectInterf.cpp
	${SRCDIR_OBSERVER}/schedulerSubjectInterf.h
	${SRCDIR_OBSERVER}/societySubjectInterf.cpp
	${SRCDIR_OBSERVER}/societySubjectInterf.h
	${SRCDIR_OBSERVER}/terrameIncludes.h
	${SRCDIR_OBSERVER}/trajectorySubjectInterf.cpp
	${SRCDIR_OBSERVER}/trajectorySubjectInterf.h
	${SRCDIR_OBSERVER}/visualArrangement.h
	${SRCDIR_OBSERVER}/visualArrangement.cpp
)

source_group("observer\\components\\console" FILES
	${SRCDIR_OBSERVER}/components/console/modelConsole.cpp
	${SRCDIR_OBSERVER}/components/console/modelConsole.h
)

source_group("observer\\components\\legend" FILES
	${SRCDIR_OBSERVER}/components/legend/legendAttributes.cpp
	${SRCDIR_OBSERVER}/components/legend/legendAttributes.h
	${SRCDIR_OBSERVER}/components/legend/legendColorBar.cpp
	${SRCDIR_OBSERVER}/components/legend/legendColorBar.h
	${SRCDIR_OBSERVER}/components/legend/legendColorUtils.cpp
	${SRCDIR_OBSERVER}/components/legend/legendColorUtils.h
	${SRCDIR_OBSERVER}/components/legend/legendWindow.cpp
	${SRCDIR_OBSERVER}/components/legend/legendWindow.h
)

source_group("observer\\components\\painter" FILES
	${SRCDIR_OBSERVER}/components/painter/calculateResult.cpp
	${SRCDIR_OBSERVER}/components/painter/calculateResult.h
	${SRCDIR_OBSERVER}/components/painter/painterShapefile.cpp
	${SRCDIR_OBSERVER}/components/painter/painterShapefile.h
	${SRCDIR_OBSERVER}/components/painter/painterWidget.cpp
	${SRCDIR_OBSERVER}/components/painter/painterWidget.h
	${SRCDIR_OBSERVER}/components/painter/visualMapping.cpp
	${SRCDIR_OBSERVER}/components/painter/visualMapping.h
)

source_group("observer\\components\\player" FILES
	${SRCDIR_OBSERVER}/components/player/player.cpp
	${SRCDIR_OBSERVER}/components/player/player.h
	${SRCDIR_OBSERVER}/components/player/playerGUI.cpp
	${SRCDIR_OBSERVER}/components/player/playerGUI.h
)

source_group("observer\\components\\receiver" FILES
	${SRCDIR_OBSERVER}/components/receiver/concretSubject.h
	${SRCDIR_OBSERVER}/components/receiver/legendGUI.cpp
	${SRCDIR_OBSERVER}/components/receiver/legendGUI.h
	${SRCDIR_OBSERVER}/components/receiver/receiverGUI.cpp
	${SRCDIR_OBSERVER}/components/receiver/receiverGUI.h
)

source_group("observer\\components\\receiver\\tcp" FILES
	${SRCDIR_OBSERVER}/components/receiver/tcp/clientTcpConnection.cpp
	${SRCDIR_OBSERVER}/components/receiver/tcp/clientTcpConnection.h
	${SRCDIR_OBSERVER}/components/receiver/tcp/receiverTcpServer.cpp
	${SRCDIR_OBSERVER}/components/receiver/tcp/receiverTcpServer.h
)

source_group("observer\\components\\receiver\\udp" FILES
	${SRCDIR_OBSERVER}/components/receiver/udp/datagramReceiverTask.cpp
	${SRCDIR_OBSERVER}/components/receiver/udp/datagramReceiverTask.h
	${SRCDIR_OBSERVER}/components/receiver/udp/receiverUDP.cpp
	${SRCDIR_OBSERVER}/components/receiver/udp/receiverUDP.h
)

source_group("observer\\components\\spatialObserver" FILES
	${SRCDIR_OBSERVER}/components/spatialObserver/canvas.cpp
	${SRCDIR_OBSERVER}/components/spatialObserver/canvas.h
	${SRCDIR_OBSERVER}/components/spatialObserver/main.cpp
	${SRCDIR_OBSERVER}/components/spatialObserver/smartSplitter.cpp
	${SRCDIR_OBSERVER}/components/spatialObserver/smartSplitter.h
	${SRCDIR_OBSERVER}/components/spatialObserver/spatialObserverGUI.cpp
	${SRCDIR_OBSERVER}/components/spatialObserver/spatialObserverGUI.h
)

source_group("observer\\components\\logFileTask" FILES
	${SRCDIR_OBSERVER}/components/logFileTask/logFileTask.cpp
	${SRCDIR_OBSERVER}/components/logFileTask/logFileTask.h
)

source_group("observer\\components\\senderGUI" FILES
	${SRCDIR_OBSERVER}/components/senderGUI/senderGUI.cpp
	${SRCDIR_OBSERVER}/components/senderGUI/senderGUI.h
)

source_group("observer\\components\\socketTask" FILES
	${SRCDIR_OBSERVER}/components/socketTask/socketTask.cpp
	${SRCDIR_OBSERVER}/components/socketTask/socketTask.h
	${SRCDIR_OBSERVER}/components/socketTask/tcpSocketTask.cpp
	${SRCDIR_OBSERVER}/components/socketTask/tcpSocketTask.h
	${SRCDIR_OBSERVER}/components/socketTask/udpSocketTask.cpp
	${SRCDIR_OBSERVER}/components/socketTask/udpSocketTask.h
)

source_group("observer\\protocol\\blackBoard" FILES
	${SRCDIR_OBSERVER}/protocol/blackBoard/blackBoard.cpp
	${SRCDIR_OBSERVER}/protocol/blackBoard/blackBoard.h
	${SRCDIR_OBSERVER}/protocol/blackBoard/coordinate.cpp
	${SRCDIR_OBSERVER}/protocol/blackBoard/coordinate.h
	${SRCDIR_OBSERVER}/protocol/blackBoard/subjectAttributes.cpp
	${SRCDIR_OBSERVER}/protocol/blackBoard/subjectAttributes.h
)

source_group("observer\\protocol\\decoder" FILES
	${SRCDIR_OBSERVER}/protocol/decoder/decoder.cpp
	${SRCDIR_OBSERVER}/protocol/decoder/decoder.h
)

source_group("observer\\statistic" FILES
	${SRCDIR_OBSERVER}/statistic/statistic.cpp
	${SRCDIR_OBSERVER}/statistic/statistic.h
)

source_group("observer\\types" FILES
	${SRCDIR_OBSERVER}/types/agentObserverImage.cpp
	${SRCDIR_OBSERVER}/types/agentObserverImage.h
	${SRCDIR_OBSERVER}/types/agentObserverMap.cpp
	${SRCDIR_OBSERVER}/types/agentObserverMap.h
	${SRCDIR_OBSERVER}/types/observerGraphic.cpp
	${SRCDIR_OBSERVER}/types/observerGraphic.h
	${SRCDIR_OBSERVER}/types/observerImage.cpp
	${SRCDIR_OBSERVER}/types/observerImage.h
	${SRCDIR_OBSERVER}/types/observerLogFile.cpp
	${SRCDIR_OBSERVER}/types/observerLogFile.h
	${SRCDIR_OBSERVER}/types/observerMap.cpp
	${SRCDIR_OBSERVER}/types/observerMap.h
	${SRCDIR_OBSERVER}/types/observerMapSuperclass.cpp
	${SRCDIR_OBSERVER}/types/observerMapSuperclass.h
	${SRCDIR_OBSERVER}/types/observerScheduler.cpp
	${SRCDIR_OBSERVER}/types/observerScheduler.h
	${SRCDIR_OBSERVER}/types/observerShapefile.cpp
	${SRCDIR_OBSERVER}/types/observerShapefile.h
	${SRCDIR_OBSERVER}/types/observerStateMachine.cpp
	${SRCDIR_OBSERVER}/types/observerStateMachine.h
	${SRCDIR_OBSERVER}/types/observerTCPSender.cpp
	${SRCDIR_OBSERVER}/types/observerTCPSender.h
	${SRCDIR_OBSERVER}/types/observerTable.cpp
	${SRCDIR_OBSERVER}/types/observerTable.h
	${SRCDIR_OBSERVER}/types/observerTextScreen.cpp
	${SRCDIR_OBSERVER}/types/observerTextScreen.h
	${SRCDIR_OBSERVER}/types/observerUDPSender.cpp
	${SRCDIR_OBSERVER}/types/observerUDPSender.h
)

source_group("observer\\types\\chartPlot" FILES
	${SRCDIR_OBSERVER}/types/chartPlot/chartPlot.cpp
	${SRCDIR_OBSERVER}/types/chartPlot/chartPlot.h
	${SRCDIR_OBSERVER}/types/chartPlot/internalCurve.h
	${SRCDIR_OBSERVER}/types/chartPlot/plotPropertiesGUI.cpp
	${SRCDIR_OBSERVER}/types/chartPlot/plotPropertiesGUI.h
	#${SRCDIR_OBSERVER}/types/chartPlot/plotPropertiesGUI.ui
)

source_group("observer\\types\\image" FILES
	${SRCDIR_OBSERVER}/types/image/imageGUI.cpp
	${SRCDIR_OBSERVER}/types/image/imageGUI.h
	#${SRCDIR_OBSERVER}/types/image/imageGUI.ui
)

source_group("observer\\types\\stateMachine" FILES
	${SRCDIR_OBSERVER}/types/stateMachine/edge.cpp
	${SRCDIR_OBSERVER}/types/stateMachine/edge.h
	${SRCDIR_OBSERVER}/types/stateMachine/node.cpp
	${SRCDIR_OBSERVER}/types/stateMachine/node.h
)

source_group("observer\\bagOfTasks" FILES
	${SRCDIR_OBSERVER}/bagOfTasks/task.cpp
	${SRCDIR_OBSERVER}/bagOfTasks/task.h
	${SRCDIR_OBSERVER}/bagOfTasks/taskManager.cpp
	${SRCDIR_OBSERVER}/bagOfTasks/taskManager.h
	${SRCDIR_OBSERVER}/bagOfTasks/worker.cpp
	${SRCDIR_OBSERVER}/bagOfTasks/worker.h
)

source_group("luaFileSystem" FILES
	${SRCDIR}/luaFileSystem/lfs.c
	${SRCDIR}/luaFileSystem/lfs.h
)

## ------------------------------------- Set Installation procedure -------------------------------------------- ##
set(CMAKE_INSTALL_PREFIX ${BLDIR}/tmp_install)
set(CPACK_PACKAGING_INSTALL_PREFIX /usr/local/terrame)
install(TARGETS terrame 
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		#PERMITIONS GROUP_READ GROUP_EXECUTE
		#COMPONENT Runtime
)

install(DIRECTORY ${SRCDIR}/lua/
	DESTINATION bin/Lua/
	PATTERN ".svn" EXCLUDE
)

install(DIRECTORY ${ROOT}/demos
		DESTINATION .
		PATTERN ".svn" EXCLUDE
		#COMPONENT Demos
)

install(DIRECTORY ${ROOT}/docs/docs_lua/
		DESTINATION ./docs/
		# RENAME docs
		PATTERN ".svn" EXCLUDE
		# PATTERN "doxygen" EXCLUDE
		#COMPONENT Documentation
)

install(DIRECTORY ${ROOT}/database
		DESTINATION .
		# PATTERN ".svn" EXCLUDE
		PATTERN "*.gpm" EXCLUDE
		PATTERN "*.GAL" EXCLUDE
		PATTERN "*.GWT" EXCLUDE
		PATTERN "*.teste" EXCLUDE
		PATTERN "*.csv" EXCLUDE
)

set(CPACK_GENERATOR "PackageMaker")
set(CPACK_PACKAGEMAKER ON)
set(CPACK_OSX_PACKAGE_VERSION "10.9")
SET(CPACK_PACKAGE_VENDOR "TerraLAB")
SET(CPACK_PACKAGE_NAME "TerraME")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Description.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${ROOT}/licenses/terrame-license-lgpl-3.0.txt")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "TerraME is a programming environment for spatial dynamical modelling")
set(CPACK_PACKAGE_ICON "/Users/raian/Documents/INPE/TerraME/source_code/PackageInstaller/Logomarca/logo_canto.png")
set(CPACK_DMG_BACKGROUND_IMAGE "/Users/raian/Documents/INPE/TerraME/source_code/PackageInstaller/Logomarca/logo_canto.png")
#VERSION
set(CPACK_PACKAGE_VERSION "2.0")
set(CPACK_PACKAGE_VERSION_MAJOR "2")
set(CPACK_PACKAGE_VERSION_MINOR "0")
set(CPACK_PACKAGE_VERSION_PATCH "0")
set(CPACK_PACKAGE_EXECUTABLES "TerraME;TerraME")
set(CPACK_SYSTEM_NAME "Mac-OSX")

# Environment Variables???? 
set(CPACK_POSTFLIGHT_SCRIPT "${CMAKE_CUURENT_SOURCE_DIR}/setenv_install_MAC.sh" ) 

include(CPack)

########### Get dependencies ################
# RAIAN: COMENTEI AQUI, pois e necessario resolver o problema do LOCATION. Ao resolver, remover comentarios
# get_target_property(MY_BINARY_LOCATION terrame LOCATION)
# configure_file(
#    "${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake.in"
#    "${CMAKE_CURRENT_BINARY_DIR}/dependencies.cmake"
#    @ONLY
#  )
# install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/dependencies.cmake")
#RAIAN: Retirar comentarios ate aqui.
######################################


include(DeployQt4)
resolve_qt4_paths(terrame "terrame" "@executable_path/../lib")
