--[[ [previous](07-visualize.lua) | [contents](00-contents.lua) | [next](itaituba/data.lua)

TerraME can use fill scripts to automatically document cellular layers.
Additionally, it can help you to document your data. To accomplish that, it is
necessary to create a TerraME package to store data as well as scripts to create
projects and cellular spaces. A package encapsulates all the data in a single
directory and allows documentation of data and their attributes. It also
simplifies scripts to create cellular spaces as it is possible to use filePath()
instead of describing where the files are stored in the computer manually.
To create a data package it is necessary to execute the following steps:

1. Create a directory with the package's name.
2. Create description.lua and fill it with the description of the package.
3. Create data directory and put data as well as fill scripts.
4. Create data.lua with the description of the package's data. Projects as well
   as cellular spaces created from scripts do not need to be manually documented.
   They will automatically be documented by TerraME.

For example, there is a directory named itaituba, in same directory of this file
(08-document.lua). See the location of this directory from the path shown in the
top of ZeroBrane Studio, with the currently opened file (this one). Directory
itaituba contains the data used along this tutorial and a complete script that
creates and fills a cellular space. The files are stored in data directory,
together with itaituba.lua script. By clickin in next above, you will go through
such files.

]]
