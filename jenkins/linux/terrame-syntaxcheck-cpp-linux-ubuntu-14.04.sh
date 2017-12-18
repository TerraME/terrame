#!/bin/bash

#
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

#
## It executes a static code inspection for TerraME C++ files
##
#
## VARIABLES:
## _TERRAME_GIT_DIR - Path to TerraME clone
#
## USAGE:
## ./terrame-syntaxcheck-cpp-linux-ubuntu-14.04.sh
##
#

python $HOME/Programs/cpplint/cpplint.py --filter=-whitespace/comments,-whitespace/tab,-whitespace/indent,-whitespace/braces,-build/namespaces,-build/header_guard,-whitespace/line_length,-readability/casting,-runtime/references,-build/include,-runtime/printf,-whitespace/newline,-runtime/explicit,-whitespace/parens,-runtime/int,-runtime/threadsafe,-runtime/indentation_namespace --extensions=c,h,cpp --recursive "$_TERRAME_GIT_DIR/src/"
RESULT1=$?
python $HOME/Programs/cpplint/cpplint.py --filter=-whitespace/tab,-whitespace/indent,-whitespace/braces,-build/header_guard,-whitespace/line_length,-build/include,-runtime/int --extensions=c,h,cpp --recursive "$_TERRAME_GIT_DIR/unittest/"
RESULT2=$?
python $HOME/Programs/cpplint/cpplint.py --filter=-whitespace/tab,-whitespace/indent,-whitespace/braces,-build/header_guard,-whitespace/line_length,-build/include,-runtime/int,-build/c++11 --extensions=c,h,cpp --recursive "$_TERRAME_GIT_DIR/inttest/"
RESULT3=$?

exit $(($RESULT1 + $RESULT2 + $RESULT3))