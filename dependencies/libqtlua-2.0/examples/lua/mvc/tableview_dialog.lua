#!/usr/bin/env qtlua

qt.dialog.table_view(_G,
		     qt.meta.QtLua__TableTreeModel.Editable +
			qt.meta.QtLua__TableGridModel.EditLuaEval +
			qt.meta.QtLua__TableTreeModel.EditInsert +
			qt.meta.QtLua__TableTreeModel.EditRemove +
			qt.meta.QtLua__TableTreeModel.EditKey);



