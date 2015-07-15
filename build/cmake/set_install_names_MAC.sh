#!/bin/bash

cp /opt/local/lib/libiconv.2.dylib ~/github/terrame/build/cmake/_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/
cp /opt/local/lib/libxml2.2.dylib ~/github/terrame/build/cmake/_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/

# TerraME executable
install_name_tool -change /usr/local/lib/libterralib.dylib @executable_path/../lib/libterralib.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /usr/local/qwt-6.1.2/lib/qwt.framework/Versions/6/qwt @executable_path/../lib/qwt ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /opt/local/lib/liblua.dylib @executable_path/../lib/liblua.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /opt/local/lib/libprotobuf.8.dylib @executable_path/../lib/libprotobuf.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /opt/local/Library/Frameworks/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../lib/QtWidgets ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /opt/local/Library/Frameworks/QtNetwork.framework/Versions/5/QtNetwork @executable_path/../lib/QtNetwork ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/5/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /usr/lib/libc++.1.dylib @executable_path/../lib/libc++.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame
install_name_tool -change qwt.framework/Versions/6/qwt @executable_path/../lib/qwt ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/bin/terrame

#TerraLib
install_name_tool -id @executable_path/../lib/libterralib.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /usr/local/lib/libterralib_shp.dylib @executable_path/../lib/libterralib_shp.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/mysql55/mysql/libmysqlclient.18.dylib @executable_path/../lib/libmysqlclient.18.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/libgeotiff.2.dylib @executable_path/../lib/libgeotiff.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/libtiff.5.dylib @executable_path/../lib/libtiff.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /usr/lib/libz.1.dylib @executable_path/../lib/libz.1.2.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/libgdal.1.dylib @executable_path/../lib/libgdal.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /usr/lib/libc++.1.dylib @executable_path/../lib/libc++.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib.dylib

#TerraLib_shp
install_name_tool -id @executable_path/../lib/libterralib_shp.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib_shp.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libterralib_shp.dylib

#libgeotiff
install_name_tool -id @executable_path/../lib/libgeotiff.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /opt/local/lib/libproj.0.dylib @executable_path/../lib/libproj.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /opt/local/lib/libtiff.5.dylib @executable_path/../lib/libtiff.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib

#libjpeg
install_name_tool -id @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libjpeg.9.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libjpeg.9.dylib

#libzlib
install_name_tool -id @executable_path/../lib/libz.1.2.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libz.1.2.8.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libz.1.2.8.dylib

#libxml
install_name_tool -id @executable_path/../lib/libxml2.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib
install_name_tool -change /opt/local/lib/liblzma.5.dylib @executable_path/../lib/liblzma.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib
install_name_tool -change /opt/local/lib/libiconv.2.dylib @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib

#libxcb
install_name_tool -id @executable_path/../lib/libxcb.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxcb.1.dylib
install_name_tool -change /opt/local/lib/libXau.6.dylib @executable_path/../lib/libXau.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxcb.1.dylib
install_name_tool -change /opt/local/lib/libXdmcp.6.dylib @executable_path/../lib/libXdmcp.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxcb.1.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libxcb.1.dylib

#libTIFF
install_name_tool -id @executable_path/../lib/libtiff.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib
install_name_tool -change /opt/local/lib/liblzma.5.dylib @executable_path/../lib/liblzma.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib

#libSSL
install_name_tool -id @executable_path/../lib/libssl.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libssl.1.0.0.dylib
install_name_tool -change /opt/local/lib/libcrypto.1.0.0.dylib @executable_path/../lib/libcrypto.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libssl.1.0.0.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libssl.1.0.0.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libssl.1.0.0.dylib

#libQWT
install_name_tool -id @executable_path/../lib/qwt ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /opt/local/Library/Frameworks/QtOpenGL.framework/Versions/5/QtOpenGL @executable_path/../lib/QtOpenGL ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /opt/local/Library/Frameworks/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../lib/QtWidgets ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/5/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /opt/local/Library/Frameworks/QtSvg.framework/Versions/5/QtSvg @executable_path/../lib/QtSvg ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /opt/local/Library/Frameworks/QtPrintSupport.framework/Versions/5/QtPrintSupport @executable_path/../lib/QtPrintSupport ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /opt/local/Library/Frameworks/QtConcurrent.framework/Versions/5/QtConcurrent @executable_path/../lib/QtConcurrent ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /System/Library/Frameworks/OpenGL.framework/Versions/A/OpenGL @executable_path/../lib/OpenGL ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /System/Library/Frameworks/AGL.framework/Versions/A/AGL @executable_path/../lib/AGL ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /usr/lib/libstdc++.6.dylib @executable_path/../lib/libstdc++.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/qwt

#libPROJ
install_name_tool -id @executable_path/../lib/libproj.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libproj.0.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libproj.0.dylib

#libPNG
install_name_tool -id @executable_path/../lib/libpng16.16.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libpng16.16.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libpng16.16.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libpng16.16.dylib

#MySQL
install_name_tool -id @executable_path/../lib/libmysqlclient.18.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libmysqlclient.18.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libmysqlclient.18.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libmysqlclient.18.dylib

#libZMA
install_name_tool -id @executable_path/../lib/liblzma.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/liblzma.5.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/liblzma.5.dylib

#LUA
install_name_tool -id @executable_path/../lib/liblua.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/liblua.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/liblua.dylib

#libCONV
install_name_tool -id @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libiconv.2.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libiconv.2.dylib

#libGIF
install_name_tool -id @executable_path/../lib/libgif.4.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib
install_name_tool -change /opt/local/lib/libSM.6.dylib @executable_path/../lib/libSM.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib
install_name_tool -change /opt/local/lib/libICE.6.dylib @executable_path/../lib/libICE.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib
install_name_tool -change /opt/local/lib/libX11.6.dylib @executable_path/../lib/libX11.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib

#libGDAL
install_name_tool -id @executable_path/../lib/libgdal.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libproj.0.dylib @executable_path/../lib/libproj.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libexpat.1.dylib @executable_path/../lib/libexpat.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libgif.4.dylib @executable_path/../lib/libgif.4.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libgeotiff.2.dylib @executable_path/../lib/libgeotiff.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libtiff.5.dylib @executable_path/../lib/libtiff.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libpng16.16.dylib @executable_path/../lib/libpng16.16.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libxml2.2.dylib @executable_path/../lib/libxml2.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libiconv.2.dylib @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib

#libXEPAT
install_name_tool -id @executable_path/../lib/libexpat.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libexpat.1.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libexpat.1.dylib

#libCRYPTO
install_name_tool -id @executable_path/../lib/libcrypto.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libcrypto.1.0.0.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libcrypto.1.0.0.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libcrypto.1.0.0.dylib

#libXDMCP
install_name_tool -id @executable_path/../lib/libXdmcp.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libXdmcp.6.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libXdmcp.6.dylib

#libXAU
install_name_tool -id @executable_path/../lib/libXau.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libXau.6.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libXau.6.dylib

#libX11
install_name_tool -id @executable_path/../lib/libX11.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libX11.6.dylib
install_name_tool -change /opt/local/lib/libxcb.1.dylib @executable_path/../lib/libxcb.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libX11.6.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libX11.6.dylib

#libSM
install_name_tool -id @executable_path/../lib/libSM.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libSM.6.dylib
install_name_tool -change /opt/local/lib/libICE.6.dylib @executable_path/../lib/libICE.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libSM.6.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libSM.6.dylib

#libICE
install_name_tool -id @executable_path/../lib/libICE.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libICE.6.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libICE.6.dylib

#QtNetwork
install_name_tool -id @executable_path/../lib/QtNetwork ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /System/Library/Frameworks/Security.framework/Versions/A/Security @executable_path/../lib/Security ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /opt/local/lib/libssl.1.0.0.dylib @executable_path/../lib/libssl.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /opt/local/lib/libcrypto.1.0.0.dylib @executable_path/../lib/libcrypto.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtNetwork

#QtGui
install_name_tool -id @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtGui
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtGui
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtGui
install_name_tool -change /opt/local/lib/libpng16.16.dylib @executable_path/../lib/libpng16.16.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtGui
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtGui

#QtCore
install_name_tool -id @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libicui18n.54.dylib @executable_path/../lib/libicui18n.54.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libicuuc.54.dylib @executable_path/../lib/libicuuc.54.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libicudata.54.dylib @executable_path/../lib/libicudata.54.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libgthread-2.0.0.dylib @executable_path/../lib/libgthread-2.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libglib-2.0.0.dylib @executable_path/../lib/libglib-2.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libintl.8.dylib @executable_path/../lib/libintl.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libpcre16.0.dylib @executable_path/../lib/libpcre16.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtCore

#QtConcurrent
install_name_tool -id @executable_path/../lib/QtConcurrent ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtConcurrent
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtConcurrent
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtConcurrent
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtConcurrent

#QtOpenGL
install_name_tool -id @executable_path/../lib/QtOpenGL ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtOpenGL
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtOpenGL
install_name_tool -change /opt/local/Library/Frameworks/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../lib/QtWidgets ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtOpenGL
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/5/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtOpenGL
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtOpenGL
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtOpenGL

#QtPrintSupport
install_name_tool -id @executable_path/../lib/QtPrintSupport ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtPrintSupport
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtPrintSupport
install_name_tool -change /opt/local/Library/Frameworks/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../lib/QtWidgets ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtPrintSupport
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/5/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtPrintSupport
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtPrintSupport
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtPrintSupport

#QtSvg
install_name_tool -id @executable_path/../lib/QtSvg ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtSvg
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtSvg
install_name_tool -change /opt/local/Library/Frameworks/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../lib/QtWidgets ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtSvg
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/5/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtSvg
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtSvg
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtSvg

#QtWidgets
install_name_tool -id @executable_path/../lib/QtWidgets ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtWidgets
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtWidgets
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/5/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtWidgets
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtWidgets
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/QtWidgets

#QtLua
install_name_tool -id @executable_path/../lib/libqtlua.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtlua.dylib
install_name_tool -change /opt/local/Library/Frameworks/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../lib/QtWidgets ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtlua.dylib
install_name_tool -change /opt/local/lib/liblua.dylib @executable_path/../lib/liblua.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtlua.dylib
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/5/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtlua.dylib
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtlua.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtlua.dylib

#QtLua-extras
install_name_tool -id @executable_path/../lib/libqtluae.0.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtluae.0.1.dylib
install_name_tool -change /opt/local/Library/Frameworks/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../lib/QtWidgets ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtluae.0.1.dylib
install_name_tool -change libqtlua.dylib @executable_path/../lib/libqtlua.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtluae.0.1.dylib
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/5/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtluae.0.1.dylib
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/5/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtluae.0.1.dylib
install_name_tool -change /usr/lib/libSystem.B.dylib @executable_path/../lib/libSystem.B.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libqtluae.0.1.dylib

#libglib-2.0.0.dylib
install_name_tool -id @executable_path/../lib/libglib-2.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libglib-2.0.0.dylib
install_name_tool -change /opt/local/lib/libiconv.2.dylib @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libglib-2.0.0.dylib
install_name_tool -change /opt/local/lib/libintl.8.dylib @executable_path/../lib/libintl.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libglib-2.0.0.dylib

#libgthread-2.0.0.dylib
install_name_tool -id @executable_path/../lib/libgthread-2.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgthread-2.0.0.dylib
install_name_tool -change /opt/local/lib/libglib-2.0.0.dylib @executable_path/../lib/libglib-2.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgthread-2.0.0.dylib
install_name_tool -change /opt/local/lib/libiconv.2.dylib @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgthread-2.0.0.dylib
install_name_tool -change /opt/local/lib/libintl.8.dylib @executable_path/../lib/libintl.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libgthread-2.0.0.dylib

#libicuuc.54.1.dylib
install_name_tool -id @executable_path/../lib/libicuuc.54.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libicuuc.54.1.dylib
install_name_tool -change /opt/local/lib/libicudata.54.dylib @executable_path/../lib/libicudata.54.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libicuuc.54.1.dylib

#libicui18n.54.1.dylib
install_name_tool -id @executable_path/../lib/libicui18n.54.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libicui18n.54.1.dylib
install_name_tool -change /opt/local/lib/libicuuc.54.dylib @executable_path/../lib/libicuuc.54.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libicui18n.54.1.dylib
install_name_tool -change /opt/local/lib/libicudata.54.dylib @executable_path/../lib/libicudata.54.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libicui18n.54.1.dylib

#libintl.8.dylib
install_name_tool -id @executable_path/../lib/libintl.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libintl.8.dylib
install_name_tool -change /opt/local/lib/libiconv.2.dylib @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libintl.8.dylib

#libpcre16.0.dylib
install_name_tool -id @executable_path/../lib/libpcre16.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libpcre16.0.dylib

#libprotobuf.8.dylib
install_name_tool -id @executable_path/../lib/libprotobuf.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libprotobuf.8.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.4-Mac-OSX/usr/local/terrame/lib/libprotobuf.8.dylib

