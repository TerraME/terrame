#!/usr/bin/env qtlua

t = {
   { 1, 2, 3, 4 },
   { 5, 6, 7, 8 },
   { 9, 10,11,12 }
};

qt.dialog.grid_view(t,
--		    qt.meta.QtLua__TableGridModel.RowColSwap +

		    qt.meta.QtLua__TableGridModel.NumKeysCols +
		    qt.meta.QtLua__TableGridModel.NumKeysRows +

		    qt.meta.QtLua__TableGridModel.Editable +
--		    qt.meta.QtLua__TableGridModel.EditLuaEval +
--		    qt.meta.QtLua__TableGridModel.EditFixedType +
		    qt.meta.QtLua__TableGridModel.EditInsertRow +
		    qt.meta.QtLua__TableGridModel.EditInsertCol +
		    qt.meta.QtLua__TableGridModel.EditRemoveRow +
		    qt.meta.QtLua__TableGridModel.EditRemoveCol);

