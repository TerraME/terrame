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

*/

#include <QMetaObject>
#include <internal/QMetaObjectWrapper>

#include <QtLua/Console>
#include <QtLua/UserItemSelectionModel>
#include <QtLua/UserItemModel>
#include <QtLua/ItemViewDialog>
#include <QtLua/TableTreeModel>
#include <QtLua/TableGridModel>
#include <QtLua/LuaModel>
#include <QtLua/State>

#include <QAbstractItemDelegate>
#include <QAbstractItemModel>
#include <QAbstractItemView>
#include <QAction>
#include <QApplication>
#include <QButtonGroup>
#include <QCalendarWidget>
#include <QCheckBox>
#include <QClipboard>
#include <QColorDialog>
#include <QColumnView>
#include <QComboBox>
#include <QCoreApplication>
#include <QDateEdit>
#include <QDateTimeEdit>
#include <QDesktopWidget>
#include <QDial>
#include <QDialog>
#include <QDialogButtonBox>
#include <QDockWidget>
#include <QDoubleSpinBox>
#include <QErrorMessage>
#include <QFile>
#include <QFileDialog>
#include <QFocusFrame>
#include <QFont>
#include <QFontDialog>
#include <QFrame>
#include <QGraphicsScene>
#include <QGraphicsView>
#include <QGridLayout>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QInputDialog>
#include <QItemDelegate>
#include <QLCDNumber>
#include <QLabel>
#include <QLibrary>
#include <QLineEdit>
#include <QListView>
#include <QListWidget>
#include <QLocale>
#include <QMainWindow>
#include <QMdiArea>
#include <QMdiSubWindow>
#include <QMenu>
#include <QMenuBar>
#include <QMessageBox>
#include <QObject>
#include <QPainter>
#include <QPalette>
#include <QPluginLoader>
#include <QProcess>
#include <QProgressBar>
#include <QProgressDialog>
#include <QPushButton>
#include <QRadioButton>
#include <QRubberBand>
#include <QScrollArea>
#include <QSettings>
#include <QShortcut>
#include <QSignalMapper>
#include <QSlider>
#include <QSpinBox>
#include <QSplashScreen>
#include <QSplitter>
#include <QStackedLayout>
#include <QStackedWidget>
#include <QStatusBar>
#include <QStringListModel>
#include <QTabBar>
#include <QTabWidget>
#include <QTableView>
#include <QTableWidget>
#include <QTemporaryFile>
#include <QTextDocument>
#include <QTextEdit>
#include <QThread>
#include <QTimeEdit>
#include <QTimer>
#include <QToolBar>
#include <QToolBox>
#include <QToolButton>
#include <QTranslator>
#include <QTreeView>
#include <QTreeWidget>
#include <QVBoxLayout>
#include <QValidator>
#include <QWidget>
#include <QWidgetAction>

#if QT_VERSION >= 0x040400
#include <QFormLayout>
#include <QCommandLinkButton>
#include <QPlainTextEdit>
#include <QStyledItemDelegate>
#endif

namespace QtLua {

const meta_object_table_s meta_object_table[] = {
  { &QtLua::Console::staticMetaObject,               &create_qobject<QtLua::Console> },
  { &QtLua::UserItemSelectionModel::staticMetaObject,    0 },
  { &QtLua::UserItemModel::staticMetaObject,	     0 },
  { &QtLua::ItemViewDialog::staticMetaObject,	     0 },
  { &QtLua::TableTreeModel::staticMetaObject,	     0 },
  { &QtLua::TableGridModel::staticMetaObject,	     0 },
  { &QtLua::LuaModel::staticMetaObject,	     0 },

  { &QAbstractItemDelegate::staticMetaObject,	     0 },
  { &QAbstractItemModel::staticMetaObject,	     0 },
  { &QAbstractItemView::staticMetaObject,	     0 },
  { &QAction::staticMetaObject,			     0 },
  { &QApplication::staticMetaObject,		     0 },
  { &QButtonGroup::staticMetaObject,		     &create_qobject<QButtonGroup> },
  { &QCalendarWidget::staticMetaObject,		     &create_qobject<QCalendarWidget> },
  { &QCheckBox::staticMetaObject,		     &create_qobject<QCheckBox> },
  { &QClipboard::staticMetaObject,		     0 },
  { &QColorDialog::staticMetaObject,		     &create_qobject<QColorDialog> },
  { &QColumnView::staticMetaObject,		     &create_qobject<QColumnView> },
  { &QComboBox::staticMetaObject,		     &create_qobject<QComboBox> },
  { &QCoreApplication::staticMetaObject,	     0 },
  { &QDateEdit::staticMetaObject,		     &create_qobject<QDateEdit> },
  { &QDateTimeEdit::staticMetaObject,		     &create_qobject<QDateTimeEdit> },
  { &QDesktopWidget::staticMetaObject,		     &create_qobject<QDesktopWidget> },
  { &QDial::staticMetaObject,			     &create_qobject<QDial> },
  { &QDialog::staticMetaObject,			     &create_qobject<QDialog> },
  { &QDialogButtonBox::staticMetaObject,	     &create_qobject<QDialogButtonBox> },
  { &QDockWidget::staticMetaObject,		     &create_qobject<QDockWidget> },
  { &QDoubleSpinBox::staticMetaObject,		     &create_qobject<QDoubleSpinBox> },
  { &QErrorMessage::staticMetaObject,		     &create_qobject<QErrorMessage> },
  { &QFile::staticMetaObject,			     &create_qobject<QFile> },
  // { &QFileDialog::staticMetaObject,		     &create_qobject<QFileDialog> },
  { &QFocusFrame::staticMetaObject,		     &create_qobject<QFocusFrame> },
  { &QFont::staticMetaObject,			     0 },
  { &QFontDialog::staticMetaObject,		     &create_qobject<QFontDialog> },
  { &QFrame::staticMetaObject,			     &create_qobject<QFrame> },
  { &QGraphicsScene::staticMetaObject,		     &create_qobject<QGraphicsScene> },
  { &QGraphicsView::staticMetaObject,		     &create_qobject<QGraphicsView> },
  { &QGridLayout::staticMetaObject,		     &create_qobject<QGridLayout> },
  { &QGroupBox::staticMetaObject,		     &create_qobject<QGroupBox> },
  { &QHBoxLayout::staticMetaObject,		     &create_qobject<QHBoxLayout> },
  { &QHeaderView::staticMetaObject,		     0 },
  { &QInputDialog::staticMetaObject,		     &create_qobject<QInputDialog> },
  { &QItemDelegate::staticMetaObject,		     &create_qobject<QItemDelegate> },
  { &QLCDNumber::staticMetaObject,		     &create_qobject<QLCDNumber> },
  { &QLabel::staticMetaObject,			     &create_qobject<QLabel> },
  { &QLayout::staticMetaObject,			     0 },
  { &QLibrary::staticMetaObject,		     &create_qobject<QLibrary> },
  { &QLineEdit::staticMetaObject,		     &create_qobject<QLineEdit> },
  { &QListView::staticMetaObject,		     &create_qobject<QListView> },
  { &QListWidget::staticMetaObject,		     &create_qobject<QListWidget> },
  { &QLocale::staticMetaObject,			     0 },
  { &QMainWindow::staticMetaObject,		     &create_qobject<QMainWindow> },
  { &QMdiArea::staticMetaObject,		     &create_qobject<QMdiArea> },
  { &QMdiSubWindow::staticMetaObject,		     &create_qobject<QMdiSubWindow> },
  { &QMenu::staticMetaObject,			     &create_qobject<QMenu> },
  { &QMenuBar::staticMetaObject,		     &create_qobject<QMenuBar> },
  { &QMessageBox::staticMetaObject,		     &create_qobject<QMessageBox> },
  { &QObject::staticMetaObject,			     &create_qobject<QObject> },
  { &QPainter::staticMetaObject,		     0 },
  { &QPalette::staticMetaObject,		     0 },
  { &QPluginLoader::staticMetaObject,		     &create_qobject<QPluginLoader> },
  { &QProcess::staticMetaObject,		     &create_qobject<QProcess> },
  { &QProgressBar::staticMetaObject,		     &create_qobject<QProgressBar> },
  { &QProgressDialog::staticMetaObject,		     &create_qobject<QProgressDialog> },
  { &QPushButton::staticMetaObject,		     &create_qobject<QPushButton> },
  { &QRadioButton::staticMetaObject,		     &create_qobject<QRadioButton> },
  { &QRubberBand::staticMetaObject,		     0 },
  { &QScrollArea::staticMetaObject,		     &create_qobject<QScrollArea> },
  { &QSettings::staticMetaObject,		     &create_qobject<QSettings> },
  { &QShortcut::staticMetaObject,		     0 },
  { &QSignalMapper::staticMetaObject,		     &create_qobject<QSignalMapper> },
  { &QSlider::staticMetaObject,			     &create_qobject<QSlider> },
  { &QSpinBox::staticMetaObject,		     &create_qobject<QSpinBox> },
  { &QSplashScreen::staticMetaObject,		     &create_qobject<QSplashScreen> },
  { &QSplitter::staticMetaObject,		     &create_qobject<QSplitter> },
  { &QStackedLayout::staticMetaObject,		     &create_qobject<QStackedLayout> },
  { &QStackedWidget::staticMetaObject,		     &create_qobject<QStackedWidget> },
  { &QStatusBar::staticMetaObject,		     &create_qobject<QStatusBar> },
  { &QStringListModel::staticMetaObject,	     &create_qobject<QStringListModel> },
  { &QTabBar::staticMetaObject,			     &create_qobject<QTabBar> },
  { &QTabWidget::staticMetaObject,		     &create_qobject<QTabWidget> },
  { &QTableView::staticMetaObject,		     &create_qobject<QTableView> },
  { &QTableWidget::staticMetaObject,		     &create_qobject<QTableWidget> },
  { &QTemporaryFile::staticMetaObject,		     &create_qobject<QTemporaryFile> },
  { &QTextDocument::staticMetaObject,		     &create_qobject<QTextDocument> },
  { &QTextEdit::staticMetaObject,		     &create_qobject<QTextEdit> },
  { &QThread::staticMetaObject,			     &create_qobject<QThread> },
  { &QTimeEdit::staticMetaObject,		     &create_qobject<QTimeEdit> },
  { &QTimer::staticMetaObject,			     &create_qobject<QTimer> },
  { &QToolBar::staticMetaObject,		     &create_qobject<QToolBar> },
  { &QToolBox::staticMetaObject,		     &create_qobject<QToolBox> },
  { &QToolButton::staticMetaObject,		     &create_qobject<QToolButton> },
  { &QTranslator::staticMetaObject,		     &create_qobject<QTranslator> },
  { &QTreeView::staticMetaObject,		     &create_qobject<QTreeView> },
  { &QTreeWidget::staticMetaObject,		     &create_qobject<QTreeWidget> },
  { &QVBoxLayout::staticMetaObject,		     &create_qobject<QVBoxLayout> },
  { &QValidator::staticMetaObject,		     0 },
  { &QWidget::staticMetaObject,			     &create_qobject<QWidget> },
  { &QWidgetAction::staticMetaObject,                0 },

#if QT_VERSION >= 0x040400
  { &QCommandLinkButton::staticMetaObject,           &create_qobject<QCommandLinkButton> },
  { &QFormLayout::staticMetaObject,		     &create_qobject<QFormLayout> },
  { &QPlainTextEdit::staticMetaObject,		     &create_qobject<QPlainTextEdit> },
  { &QStyledItemDelegate::staticMetaObject,          &create_qobject<QStyledItemDelegate> },
#endif

  { 0, 0 },
};

}

