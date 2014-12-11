#!/usr/bin/env qtlua

qt.dialog.tree_view(_G, 
--		    qt.meta.QtLua__TableTreeModel.HideKey +
--		    qt.meta.QtLua__TableTreeModel.HideValue +
		    qt.meta.QtLua__TableTreeModel.HideType +

		    qt.meta.QtLua__TableTreeModel.Recursive +
		    qt.meta.QtLua__TableTreeModel.UserDataIter +
		    qt.meta.QtLua__TableTreeModel.Editable +
		    qt.meta.QtLua__TableTreeModel.EditInsert +
		    qt.meta.QtLua__TableTreeModel.EditRemove +
		    qt.meta.QtLua__TableTreeModel.EditKey);

