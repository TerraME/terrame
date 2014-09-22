#!/bin/bash

# TerraME executable
install_name_tool -change /usr/local/lib/libterralib.dylib @executable_path/../lib/libterralib.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/bin/TerraME
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/bin/TerraME
install_name_tool -change /opt/local/lib/libqwt.5.2.3.dylib @executable_path/../lib/libqwt.5.2.3.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/bin/TerraME
install_name_tool -change /opt/local/lib/liblua.dylib @executable_path/../lib/liblua.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/bin/TerraME
install_name_tool -change /usr/local/lib/libRandom.1.0.6.dylib @executable_path/../lib/libRandom.1.0.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/bin/TerraME
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/4/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/bin/TerraME
install_name_tool -change /opt/local/Library/Frameworks/QtNetwork.framework/Versions/4/QtNetwork @executable_path/../lib/QtNetwork ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/bin/TerraME
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/4/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/bin/TerraME


#TerraLib
install_name_tool -id @executable_path/../lib/libterralib.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /usr/local/lib/libterralib_shp.dylib @executable_path/../lib/libterralib_shp.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/mysql55/mysql/libmysqlclient.18.dylib @executable_path/../lib/libmysqlclient.18.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/libgeotiff.2.dylib @executable_path/../lib/libgeotiff.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/libtiff.5.dylib @executable_path/../lib/libtiff.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /usr/lib/libz.1.dylib @executable_path/../lib/libz.1.2.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib.dylib
install_name_tool -change /opt/local/lib/libgdal.1.dylib @executable_path/../lib/libgdal.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib.dylib

#TerraLib_shp
install_name_tool -id @executable_path/../lib/libterralib_shp.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libterralib_shp.dylib

#libgeotiff
install_name_tool -id @executable_path/../lib/libgeotiff.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /opt/local/lib/libproj.0.dylib @executable_path/../lib/libproj.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib
install_name_tool -change /opt/local/lib/libtiff.5.dylib @executable_path/../lib/libtiff.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgeotiff.2.dylib

#libjpeg
install_name_tool -id @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libjpeg.9.dylib

#libzlib
install_name_tool -id @executable_path/../lib/libz.1.2.8.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libz.1.2.8.dylib

#libxml
install_name_tool -id @executable_path/../lib/libxml2.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib
install_name_tool -change /opt/local/lib/liblzma.5.dylib @executable_path/../lib/liblzma.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib
install_name_tool -change /opt/local/lib/libiconv.2.dylib @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libxml2.2.dylib

#libxcb
install_name_tool -id @executable_path/../lib/libxcb.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libxcb.1.dylib
install_name_tool -change /opt/local/lib/libXau.6.dylib @executable_path/../lib/libXau.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libxcb.1.dylib
install_name_tool -change /opt/local/lib/libXdmcp.6.dylib @executable_path/../lib/libXdmcp.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libxcb.1.dylib

#libTIFF
install_name_tool -id @executable_path/../lib/libtiff.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib
install_name_tool -change /opt/local/lib/liblzma.5.dylib @executable_path/../lib/liblzma.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libtiff.5.dylib

#libSSL
install_name_tool -id @executable_path/../lib/libssl.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libssl.1.0.0.dylib
install_name_tool -change /opt/local/lib/libcrypto.1.0.0.dylib @executable_path/../lib/libcrypto.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libssl.1.0.0.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libssl.1.0.0.dylib

#libQWT
install_name_tool -id @executable_path/../lib/libqwt.5.2.3.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libqwt.5.2.3.dylib
install_name_tool -change /opt/local/Library/Frameworks/QtGui.framework/Versions/4/QtGui @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libqwt.5.2.3.dylib
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/4/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libqwt.5.2.3.dylib

#libPROJ
install_name_tool -id @executable_path/../lib/libproj.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libproj.0.dylib

#libPNG
install_name_tool -id @executable_path/../lib/libpng16.16.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libpng16.16.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libpng16.16.dylib

#MySQL
install_name_tool -id @executable_path/../lib/libmysqlclient.18.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libmysqlclient.18.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libmysqlclient.18.dylib

#libZMA
install_name_tool -id @executable_path/../lib/liblzma.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/liblzma.5.dylib

#LUA
install_name_tool -id @executable_path/../lib/liblua.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/liblua.dylib

#libCONV
install_name_tool -id @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libiconv.2.dylib

#libGIF
install_name_tool -id @executable_path/../lib/libgif.4.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib
install_name_tool -change /opt/local/lib/libSM.6.dylib @executable_path/../lib/libSM.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib
install_name_tool -change /opt/local/lib/libICE.6.dylib @executable_path/../lib/libICE.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib
install_name_tool -change /opt/local/lib/libX11.6.dylib @executable_path/../lib/libX11.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgif.4.dylib

#libGDAL
install_name_tool -id @executable_path/../lib/libgdal.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libproj.0.dylib @executable_path/../lib/libproj.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libexpat.1.dylib @executable_path/../lib/libexpat.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libgif.4.dylib @executable_path/../lib/libgif.4.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libjpeg.9.dylib @executable_path/../lib/libjpeg.9.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libgeotiff.2.dylib @executable_path/../lib/libgeotiff.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libtiff.5.dylib @executable_path/../lib/libtiff.5.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libpng16.16.dylib @executable_path/../lib/libpng16.16.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libxml2.2.dylib @executable_path/../lib/libxml2.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib
install_name_tool -change /opt/local/lib/libiconv.2.dylib @executable_path/../lib/libiconv.2.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libgdal.1.dylib

#libXEPAT
install_name_tool -id @executable_path/../lib/libexpat.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libexpat.1.dylib

#libCRYPTO
install_name_tool -id @executable_path/../lib/libcrypto.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libcrypto.1.0.0.dylib
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libcrypto.1.0.0.dylib

#libXDMCP
install_name_tool -id @executable_path/../lib/libXdmcp.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libXdmcp.6.dylib

#libXAU
install_name_tool -id @executable_path/../lib/libXau.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libXau.6.dylib

#libX11
install_name_tool -id @executable_path/../lib/libX11.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libX11.6.dylib
install_name_tool -change /opt/local/lib/libxcb.1.dylib @executable_path/../lib/libxcb.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libX11.6.dylib

#libSM
install_name_tool -id @executable_path/../lib/libSM.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libSM.6.dylib
install_name_tool -change /opt/local/lib/libICE.6.dylib @executable_path/../lib/libICE.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libSM.6.dylib

#libRANDOM
install_name_tool -id @executable_path/../lib/libRandom.1.0.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libRandom.1.0.6.dylib

#libRANDOM
install_name_tool -id @executable_path/../lib/libRandom.1.0.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libRandom.1.0.6.dylib

#libICE
install_name_tool -id @executable_path/../lib/libICE.6.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/libICE.6.dylib

#QtNetwork
install_name_tool -id @executable_path/../lib/QtNetwork ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/4/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /opt/local/lib/libssl.1.0.0.dylib @executable_path/../lib/libssl.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtNetwork
install_name_tool -change /opt/local/lib/libcrypto.1.0.0.dylib @executable_path/../lib/libcrypto.1.0.0.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtNetwork

#QtGui
install_name_tool -id @executable_path/../lib/QtGui ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtGui
install_name_tool -change /opt/local/Library/Frameworks/QtCore.framework/Versions/4/QtCore @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtGui
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtGui
install_name_tool -change /opt/local/lib/libpng16.16.dylib @executable_path/../lib/libpng16.16.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtGui

#QtCore
install_name_tool -id @executable_path/../lib/QtCore ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtCore
install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/../lib/libz.1.dylib ./_CPack_Packages/Mac-OSX/PackageMaker/TerraME-1.3.1-Mac-OSX/usr/local/terrame/lib/QtCore







