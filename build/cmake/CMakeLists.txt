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
set(DOC_DIR ${ROOT}/luadoc)

file(COPY
	${BASE_DIR}/
	DESTINATION ${BINARY_DIR}/packages/base/
)

file(COPY
	${DOC_DIR}/
	DESTINATION ${BINARY_DIR}/packages/luadoc/
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
          ${SRCDIR}/observer/components/
          ${SRCDIR}/observer/components/console/
          ${SRCDIR}/observer/types/chartPlot/
          ${SRCDIR}/observer/components/legend/
          ${SRCDIR}/observer/components/painter/
          ${SRCDIR}/observer/components/player/
          ${SRCDIR}/observer/protocol/blackBoard/
          ${SRCDIR}/observer/protocol/decoder/
          ${SRCDIR}/observer/statistic/
          ${SRCDIR}/observer/types/image/
          ${SRCDIR}/observer/types/stateMachine/
          ${SRCDIR}/observer/types/udpSender/
          ${SRCDIR}/observer/types/
          ${SRCDIR}/observer/
          ${SRCDIR}/luaFileSystem
          ${SRCDIR}/service/
          ${SRCDIR}/service/persistence
          ${SRCDIR}/service/persistence/terralib

          /usr/local/include
)

# Set source files location
file(GLOB SRCS  
	${SRCDIR}/core/*.cpp 
          ${SRCDIR}/observer/components/*.cpp
          ${SRCDIR}/observer/components/console/*.cpp
          ${SRCDIR}/observer/components/legend/*.cpp
          ${SRCDIR}/observer/components/painter/*.cpp
          ${SRCDIR}/observer/components/player/*.cpp 
          ${SRCDIR}/observer/components/receiver/*.cpp 
          ${SRCDIR}/observer/protocol/blackBoard/*.cpp    
          ${SRCDIR}/observer/protocol/decoder/*.cpp
          ${SRCDIR}/observer/statistic/*.cpp
          ${SRCDIR}/observer/types/image/*.cpp
          ${SRCDIR}/observer/types/udpSender/*.cpp
          ${SRCDIR}/observer/types/stateMachine/*.cpp
          ${SRCDIR}/observer/types/*.cpp
          ${SRCDIR}/observer/*.cpp
          ${SRCDIR}/observer/types/chartPlot/*.cpp
          ${SRCDIR}/luaFileSystem/*.c
          ${SRCDIR}/service/persistence/terralib/*.cpp
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
# if(MINGW)
	# set(TERRALIB_KERNEL_INCLUDE_DIR ${DEPS}/terralib/src/terralib/kernel )
	# set(TERRALIB_MYSQL_INCLUDE_DIR ${DEPS}/terralib/src/terralib/drivers/MySQL)
	# set(TERRALIB_JPEG_INCLUDE_DIR  ${DEPS}/terralib/src/terralib/drivers/libjpeg )
	# set(TERRALIB_LIBRARIES ${DEPS}/terralib/Release/win32-g++)
	# Set(TERRALIB_LIBRARY ${TERRALIB_LIBRARIES}/libterralib.a)
	# set(TERRALIB_FOUND TRUE)
# else(MINGW)
	find_package(TerraLib)
# endif(MINGW)
if( TERRALIB_FOUND )
	message("-- Found TerraLib library ${TERRALIB_LIBRARY} and include dir ${TERRLIB_INCLUDE_DIR}")
	include_directories(${TERRALIB_KERNEL_INCLUDE_DIR})
	include_directories(${TERRALIB_MYSQL_INCLUDE_DIR})
	include_directories(${TERRALIB_JPEG_INCLUDE_DIR})
	set(LIBS ${LIBS} ${TERRALIB_LIBRARY})
endif( TERRALIB_FOUND )

### --------------
#MySQL 
#-- TODO: Vefify if it is all correct and how we can use the CMAKE finder instead of this.
# if(MINGW) 
	# set(MYSQL_INCLUDE_DIR ${DEPS}/terralib/src/MySQL/)
	# set(MYSQL_LIBRARIES ${DEPS}/terralib/dependencies/win32/MySQL/lib/mingw)
	# set(MYSQL_LIBRARY ${MYSQL_LIBRARIES}/libmysql_mingw.a)
	# set(MYSQL_FOUND true)
# elseif(MINGW)
	find_package(MySQL)
# endif(MINGW) 

#-- TODO: Vefify if it is all correct and how we can use the CMAKE finder instead of this.
if( MYSQL_FOUND )
	message("-- Found MySQL library ${MYSQL_LIBRARY} and include dir ${MYSQL_INCLUDE_DIR}")
	include_directories(${SRCDIR} ${MYSQL_INCLUDE_DIR})
	set(LIBS ${LIBS} ${MYSQL_LIBRARY})
	#list(APPEND SRCS ${TERRALIB_MYSQL_INCLUDE_DIR}/TeMySQL.cpp)
endif( MYSQL_FOUND )

# if(MINGW) 
	##TE_MYSQL
	# set(TE_MYSQL_LIBRARY ${TERRALIB_LIBRARIES}/libte_mysql.a)
	# set(LIBS ${LIBS} ${TE_MYSQL_LIBRARY})
# endif(MINGW)

### --------------
#JPEG
#-- TODO: Vefify if it is all correct
# if(MINGW)
	# set(JPEG_INCLUDE_DIR ${DEPS}/terralib/src/libjpeg)
	# set(JPEG_LIBRARIES ${DEPS}/terralib/Release/win32-g++/)
	# set(JPEG_LIBRARY ${JPEG_LIBRARIES}/libjpeg.a)
	# set(LIBS ${LIBS} ${JPEG_LIBRARY})
# else(MINGW)
	find_package(JPEG REQUIRED)
	set(LIBS ${LIBS} ${JPEG_LIBRARIES})
# endif(MINGW)
include_directories(${JPEG_INCLUDE_DIR})

### --------------
#QWT
#-- TODO: Vefify if it is all correct and how we can use the CMAKE finder instead of this.
# if(MINGW)
	# set(QWT_INCLUDE_DIR ${DEPS}/qwt/src)
	# set(QWT_LIBRARIES ${DEPS}/qwt/lib)
	# set(QWT_LIBRARY ${QWT_LIBRARIES}/libqwt5.a)
	# set(QWT_FOUND true)
	# if(QWT_FOUND)
		# message("-- Found Qwt library ${QWT_LIBRARY} and include_dir ${QWT_INCLUDE_DIR}")
		# include_directories(${QWT_INCLUDE_DIR})
		# link_directories(${QWT_LIBRARIES})
		# set(LIBS ${LIBS} ${QWT_LIBRARY})
	# endif(QWT_FOUND)
# else(MINGW)
	find_package(qwt-qt5)
	if(QWT_FOUND)
		message("-- Found Qwt library ${QWT_LIBRARY} and include directories ${QWT_INCLUDE_DIR}")
		include_directories(${QWT_INCLUDE_DIR})
		if(QWTQT5_LIBRARY)
			set(LIBS ${LIBS} ${QWTQT5_LIBRARY})
		else(QWTQT5_LIBRARY)
			set(LIBS ${LIBS} ${QWT_LIBRARY})
		endif(QWTQT5_LIBRARY)
	endif( QWT_FOUND )
# endif(MINGW)

### --------------
#LUA52
#-- TODO: Vefify if it is all correct and how we can use the CMAKE finder instead of this.
# if(MINGW)
	# set(LUA_INCLUDE_DIR ${DEPS}/lua/include)
	# set(LUA_LIBRARIES ${DEPS}/lua/lib)
	# Set(LUA_LIBRARY ${LUA_LIBRARIES}/liblua5.2.a)
	# set(LIBS ${LIBS} ${LUA_LIBRARY})
# else(MINGW)
	find_package(Lua52 REQUIRED)
# endif(MINGW)

if(LUA_FOUND)
	message("-- Found Lua library ${LUA_LIBRARY} and include dir ${LUA_INCLUDE_DIR}") 
	include_directories(${LUA_INCLUDE_DIR})
	set(LIBS ${LIBS} ${LUA_LIBRARY})
endif(LUA_FOUND)

### --------------
#PROTOCOL BUFFERS
#-- TODO: Vefify if it is all correct
find_package(Protobuf REQUIRED)
if(PROTOBUF_FOUND)
	if(PROTOBUF_PROTOC_EXECUTABLE)
		message("-- Found Protocol Buffers library ${PROTOBUF_LIBRARY}, include dir ${PROTOBUF_INCLUDE_DIR} and compiler ${PROTOBUF_PROTOC_EXECUTABLE}")
	
		protobuf_generate_cpp(PROTO_SRC PROTO_HEADER ${SRCDIR_OBSERVER}/protocol/protocolBuffers/protocol.proto)

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
    ${SRCDIR}/observer/types/observerMap.h
    ${SRCDIR}/observer/types/observerGraphic.h
    ${SRCDIR}/observer/types/observerScheduler.h
    ${SRCDIR}/observer/types/observerStateMachine.h
    ${SRCDIR}/observer/types/observerMapSuperclass.h
    ${SRCDIR}/observer/types/observerShapefile.h
    ${SRCDIR}/observer/types/udpSender/udpSenderGUI.h
    ${SRCDIR}/observer/components/player/playerGUI.h
    ${SRCDIR}/observer/components/console/modelConsole.h
    ${SRCDIR}/observer/components/legend/legendWindow.h
    ${SRCDIR}/observer/components/legend/legendColorBar.h
    ${SRCDIR}/observer/components/painter/painterWidget.h
    ${SRCDIR}/observer/components/painter/painterThread.h
    ${SRCDIR}/observer/components/receiver/receiver.h
    ${SRCDIR}/observer/components/canvas.h
    ${SRCDIR}/observer/types/chartPlot/chartPlot.h
)

set(MOC_RSRCS 
	${SRCDIR}/observer/observerResource.qrc
)

set(UIS
    ${SRCDIR}/observer/components/console/modelConsoleGUI.ui
    ${SRCDIR}/observer/components/player/playerGUI.ui
    ${SRCDIR}/observer/components/receiver/receiverGUI.ui
    ${SRCDIR}/observer/types/udpSender/udpSenderGUI.ui
)

qt5_wrap_cpp(MOC_SRCS ${MOC_HDRS})
qt5_add_resources(MOC_SRCS ${MOC_RSRCS})
qt5_wrap_ui(UI_SRCS ${UIS})

include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(CMAKE_INSTALL_RPATH "@executable_path/../lib;/usr/local/terrame/lib")
set(CMAKE_INSTALL_NAME_DIR "@executable_path/../lib")
set(CMAKE_BUILD_WITH_INSTALL_RPATH true)
set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH true)

if(MINGW)
    set(APP_ICON ${ROOT}/res/resource.o)
else(MINGW)
    set(APP_ICON "")
endif(MINGW)

## ------------------------------------------------------------------------------------------------------------- ##
# Add Target and link directories, and link with libraries
add_executable( terrame
        ${SRCS}
        ${MOC_SRCS}
        ${UI_SRCS}
        ${INC_ALL}
        ${MOC_HDRS}
        ${PROTO_SRC}
        ${SHAPELIB_SRCS}
        ${SHAPELIB_HEADERS}
        ${PROTO_HEADER}
        ${APP_ICON}
)

link_directories(/usr/lib) # Set link directories
target_link_libraries(terrame ${LIBS}) # Link with libraries

set_target_properties( terrame PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ${BINARY_DIR}
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ${BINARY_DIR}
)


## ------------------------------------- Set Installation procedure -------------------------------------------- ##
set(CMAKE_INSTALL_PREFIX ${BLDIR}/tmp_install)
set(CPACK_PACKAGING_INSTALL_PREFIX /usr/local/terrame)
install(TARGETS terrame 
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		# COMPONENT Runtime
)

install(DIRECTORY ${SRCDIR}/lua/
	DESTINATION bin/lua/
)

install(DIRECTORY ${ROOT}/base/
		DESTINATION packages/base/
		# COMPONENT Base_Package
)

install(FILES ${QTLUA_LIBRARY}
			  ${QTLUAEXTRAS_INCLUDE_DIR}/../../lib/libqtluae.0.1.dylib
		DESTINATION lib)

set(CPACK_GENERATOR "PackageMaker")
set(CPACK_PACKAGEMAKER ON)
set(CPACK_OSX_PACKAGE_VERSION "10.9")
SET(CPACK_PACKAGE_VENDOR "TerraLAB")
SET(CPACK_PACKAGE_NAME "TerraME")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Description.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${ROOT}/licenses/terrame-license-lgpl-3.0.txt")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "TerraME is a programming environment for spatial dynamical modelling")
# set(CPACK_PACKAGE_ICON "/Users/raian/Documents/INPE/TerraME/source_code/PackageInstaller/Logomarca/logo_canto.png")
set(CPACK_DMG_BACKGROUND_IMAGE "/Users/raian/Documents/INPE/TerraME/source_code/PackageInstaller/Logomarca/logo_canto.png")
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
set(MY_BINARY_LOCATION ${BINARY_DIR}/terrame)

configure_file(
   "${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake.in"
   "${CMAKE_CURRENT_BINARY_DIR}/dependencies.cmake"
   @ONLY
 )
install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/dependencies.cmake")
######################################

include(DeployQt4)
resolve_qt4_paths(terrame "terrame" "@executable_path/../lib")
