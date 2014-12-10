#!/usr/bin/env qtlua

data = { "a", "b", "c", { "d", "e" } };

model = qt.mvc.new_table_tree_model(data, qt.meta.QtLua__TableTreeModel.Recursive +
				    qt.meta.QtLua__TableTreeModel.EditAll +
				    qt.meta.QtLua__TableTreeModel.EditLuaEval
				   );

view = qt.new_qobject(qt.meta.QTreeView);

dialog = qt.mvc.new_itemview_dialog(0, model, view);

dialog.edit_actions = 
	   qt.meta.QtLua__ItemViewDialog.EditData +
	   qt.meta.QtLua__ItemViewDialog.EditAddChild +
--	   qt.meta.QtLua__ItemViewDialog.EditDataOnNewRow +
	   qt.meta.QtLua__ItemViewDialog.EditInsertRow +
	   qt.meta.QtLua__ItemViewDialog.EditInsertRowAfter +
--	   qt.meta.QtLua__ItemViewDialog.EditAddRow +
	   qt.meta.QtLua__ItemViewDialog.EditRemoveRow
           ;

dialog:exec();

