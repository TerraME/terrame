## What is TerraME?

TerraME is a programming environment for spatial dynamical modelling. It supports cellular automata, agent-based models, and network models running in 2D cellular spaces. TerraME provides an interface to TerraLib geographical database, allowing models to access geospatial data directly. Its modelling language has in built functions that makes it easier to develop multi-scale and multi-paradigm models. For full documentation please visit the [TerraME Home Page](http://terrame.org) and [TerraME Wiki Page](https://github.com/TerraME/terrame/wiki).

## How to use TerraME

### Supported Platforms
MS Windows, Mac OS X and Linux.

### Installing

Please visit the [download page](https://github.com/TerraME/terrame/releases). There you can find installers and instructions for different operational systems. It is also possible to compile TerraME from scratch. See [How to build TerraME in Wiki Page](https://github.com/TerraME/terrame/wiki/Building-and-Configuring).

### Getting started

In Windows, you can run TerraME by clicking in the icon on Desktop. In Mac and Linux, it is possible to run it by calling

```bash
$> terrame
```

using the command prompt. The graphical interface has options to run examples, configure and run models,
see documentation, as well as download and install additional packages. There are links to the source code
of the models as well as the examples in the documentation.

To develop your own models you will need a Lua editor. We currently recommend ZeroBraneStudio.
Please follow the instructions available [here](http://www.terrame.org/doku.php#editor) to install and configure it properly.

### Reporting Bugs
If you have found a bug, please report it at [TerraME Issue Tracker](https://github.com/TerraME/terrame/issues).
The list of known bugs is available [here](https://github.com/TerraME/terrame/issues?q=is%3Aopen+is%3Aissue+label%3Abug).


## License
TerraME is distributed under the GNU Lesser General Public License as published by the Free Software Foundation. See [terrame-license-lgpl-3.0.txt](https://github.com/TerraME/terrame/blob/master/licenses/terrame-license-lgpl-3.0.txt) for details.

## Code Status

The output of the daily tests is available [here](http://www.dpi.inpe.br/jenkins/view/TerraME-Daily/).

| Task            | Windows | Linux | Mac |
|---|---|---|---|
| dependencies   | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-terralib-build-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-terralib-build-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-terralib-build-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-terralib-build-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-terralib-build-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-terralib-build-mac-el-captain/lastBuild/consoleFull)|
| compile         | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-build-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-build-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-build-mac-el-captain/lastBuild/consoleFull)|
| base-test       | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-base-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-base-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-base-mac-el-captain/lastBuild/consoleFull) |
| base-doc        | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-base-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-base-linux-ubuntu-14.04/lastBuild/consoleFull)| [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-base-mac-el-captain/lastBuild/consoleFull)|
| terralib-test   | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-terralib-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-terralib-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-terralib-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-terralib-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-terralib-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-terralib-mac-el-captain/lastBuild/consoleFull) |
| terralib-doc    |[<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-terralib-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-terralib-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-terralib-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-terralib-linux-ubuntu-14.04/lastBuild/consoleFull)| [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-terralib-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-terralib-mac-el-captain/lastBuild/consoleFull)|
| execution-test  | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-test-execution-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-test-execution-linux-ubuntu-14.04/lastBuild/consoleFull)| [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-test-execution-mac-el-captain/lastBuild/consoleFull) |
| repository-test | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-repository-test-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-repository-test-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-repository-test-mac-el-captain/lastBuild/consoleFull)|
|luacheck| | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-semantics-analyzer-lua-linux-ubuntu-14.04) ||
|cppcheck | | ![](http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-syntaxcheck-cpp-linux-ubuntu-14.04) | |

