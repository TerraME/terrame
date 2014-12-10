-- -----------------------------------------------------------------------------
-- Generated from UI file `hello.ui'
-- 
-- Created by QtLua user interface compiler version 2.0 
-- 
-- WARNING! All changes made in this file will be lost when recompiling UI file!
-- -----------------------------------------------------------------------------

local Dialog = qt.new_qobject(qt.meta.QDialog);
Dialog.geometry = { 0, 0, 400, 79 };
Dialog.windowTitle = "Hello dialog";

local _layout_0 = qt.new_qobject(qt.meta.QVBoxLayout);
qt.ui.layout_add(Dialog, _layout_0);

local lineEdit = qt.new_qobject(qt.meta.QLineEdit);
Dialog.lineEdit = lineEdit;
qt.ui.layout_add(_layout_0, lineEdit);

local _layout_1 = qt.new_qobject(qt.meta.QHBoxLayout);
qt.ui.layout_spacer(_layout_1, 40, 20, qt.meta.QSizePolicy.Expanding, qt.meta.QSizePolicy.Minimum);

local pushButton = qt.new_qobject(qt.meta.QPushButton);
Dialog.pushButton = pushButton;
pushButton.text = "Hello !";
qt.ui.layout_add(_layout_1, pushButton);

local pushButton_2 = qt.new_qobject(qt.meta.QPushButton);
Dialog.pushButton_2 = pushButton_2;
pushButton_2.text = "Quit";
qt.ui.layout_add(_layout_1, pushButton_2);
qt.ui.layout_add(_layout_0, _layout_1);

return Dialog;
