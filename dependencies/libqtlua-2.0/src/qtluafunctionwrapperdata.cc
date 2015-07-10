/*
    This file is part of LibQtLua.

    LibQtLua is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    LibQtLua is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with LibQtLua.  If not, see <http://www.gnu.org/licenses/>.

    Copyright (C) 2008, Alexandre Becoulet <alexandre.becoulet@free.fr>

    Fork
    Copyright (C) 2015 (Li, Kwue-Ron) <likwueron@gmail.com>
*/

#include <internal/FunctionWrapperData>

namespace QtLua {

  FunctionWrapperData::FunctionWrapperData(FunctionSignature func, 
                                           const QMetaType::Type argt_array[], 
                                           int count)
      : _func(func)
  {
    //convert Type to bytearray
    _argc = (count < defaultMaxCount) ? count : defaultMaxCount;
    if(0 < _argc) {
        //generate return type
        _return_type_name = QMetaType::typeName(argt_array[0]);
        //generate argv
        for(int i = 1; i < _argc; i++) {
            QByteArray name = QMetaType::typeName(argt_array[i]);
            if(!name.isEmpty()) _argvs_type_name += name + ",";
        }
        _argvs_type_name.chop(1);
        
        _argc -= 1;
    }
    else {
        _return_type_name = "unknown";
        _argvs_type_name = "unknown";
    }
  }
  FunctionWrapperData::FunctionWrapperData(FunctionSignature func, 
                                           const QList<String> argv)
    : _func(func)
  {
    int count = argv.count();
    _argc = (count < defaultMaxCount) ? count : defaultMaxCount;
    if(0 < _argc) {
        //generate return type
        _return_type_name = argv.at(0);
        //generate argv
        for(int i = 1; i < _argc; i++) {
            String name = argv.at(i);
            if(!name.isEmpty()) _argvs_type_name += name + ",";
        }
        _argvs_type_name.chop(1);
        
        _argc -= 1;
    }
    else {
        _return_type_name = "unknown";
        _argvs_type_name = "unknown";
    }
  }
}