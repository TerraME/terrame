# TerraME
## Overview
TerraME is a programming environment for spatial dynamical modelling. It supports cellular automata, agent-based models, and network models running in 2D cell spaces. TerraME provides an interface to TerraLib geographical database, allowing models direct access to geospatial data. Its modelling language has in-built functions that makes it easier to develop multi-scale and multi-paradigm models for environmental applications. For full documentation visit the [TerraME Home Page](http://terrame.org) and [TerraME Wiki Page](https://github.com/TerraME/terrame/wiki).

## License
TerraME is distributed under the GNU Lesser General Public License as published by the Free Software Foundation. See [terrame-license-lgpl-3.0.txt](https://github.com/TerraME/terrame/blob/master/licenses/terrame-license-lgpl-3.0.txt) for details. 

# Building TerraME

## Supported Platforms
MS Windows, Mac OS X and Linux.

## Building and Configuring
TerraME uses CMake for build its components and dependencies. See [How to build TerraME in Wiki Page](https://github.com/TerraME/terrame/wiki/Building-and-Configuring).

## Usage
The complete documentation for TerraME API is available via `-showdoc` command line:
```bash
$> terrame -showdoc
```

## Reporting Bugs
If you have found a bug, open an entry in the [TerraME Issue Tracker](https://github.com/TerraME/terrame/issues).
## Code Status

The output of the daily tests is available [here](http://www.dpi.inpe.br/jenkins/view/TerraME-Daily/).

| Task            | Windows | Linux | Mac |
|---|---|---|---|
| compile         | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-windows-10) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-linux-ubuntu-14.04) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-mac-el-captain)|
| base-test       | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-windows-10) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-linux-ubuntu-14.04) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-mac-el-captain) |
| base-doc        | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-windows-10) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-linux-ubuntu-14.04)| ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-mac-el-captain)|
| terralib-test   | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-terralib-windows-10) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-terralib-linux-ubuntu-14.04) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-terralib-mac-el-captain) |
| terralib-doc    |![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-terralib-windows-10) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-terralib-linux-ubuntu-14.04)| ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-terralib-mac-el-captain)|
| execution-test  | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-windows-10) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-linux-ubuntu-14.04)| ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-mac-el-captain) |
| repository-test | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-windows-10) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-linux-ubuntu-14.04) | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-mac-el-captain)|
|luacheck| | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-semantics-analyzer-lua-linux-ubuntu-14.04) ||
|cppcheck | | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-syntaxcheck-cpp-linux-ubuntu-14.04) | |

