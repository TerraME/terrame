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

// __moc_flags__ -fQtLua/Console

#ifndef QTLUACONSOLE_HH_
#define QTLUACONSOLE_HH_

#include <QTextEdit>
#include <QTextCursor>
#include <QMouseEvent>
#include <QPointer>
#include <QSettings>

#define QTLUA_MAX_COMPLETION 200

namespace QtLua {

  /**
   * @short Qt console widget
   * @header QtLua/Console
   * @module {Base}
   *
   * This class provides an easy to use console widget for use in QtLua
   * based applications.
   *
   * This widget is a general purpose console widget with history and
   * completion capabilities.
   *
   * @xref{The qtlua interpreter} uses this widget.
   *
   * When used with a @ref QtLua::State lua interpreter object, it
   * only needs a few signals connections to get a working lua based
   * shell:
   * @example examples/cpp/console/console.cc:1
   */

class Console : public QTextEdit
{
  Q_OBJECT;
  Q_PROPERTY(int history_size READ get_history_size WRITE set_history_size);
  Q_PROPERTY(int text_width READ get_text_width WRITE set_text_width);
  Q_PROPERTY(int text_height READ get_text_height WRITE set_text_height);
  Q_PROPERTY(int scroll_back READ get_scroll_back WRITE set_scroll_back);
  Q_PROPERTY(QString prompt READ get_prompt WRITE set_prompt);

public:

  /** Create a console widget and restore history */
  Console(QWidget *parent = 0, const QString &prompt = QString("$"),
	  const QStringList &history = QStringList());

  /** Set console prompt. */
  void set_prompt(const QString &p);
  /** Get console prompt. */
  const QString & get_prompt() const;

  /** Set console width in character count */
  void set_text_width(int width);
  /** Get console width in character count */
  int get_text_width() const;

  /** Set console height in character count */
  void set_text_height(int height);
  /** Get console height in character count */
  int get_text_height() const;

  /** Set console max history entries count */
  void set_history_size(int history_size);
  /** Get console max history entries count */
  int get_history_size() const;

  /** Set number of lines in the scrollback buffer. Changes will
      take effect next time a line is entered or a @ref print is
      performed. Default value is 1000. */
  void set_scroll_back(int scroll_back);
  /** Get number of lines in the scrollback buffer. */
  int get_scroll_back() const;

  /** Get current history. */
  inline const QStringList & get_history() const;

  /** Set current history. */
  void set_history(const QStringList &h);

  /** Load history from @ref QSettings object and keep a @ref QPointer
      to QSettings for subsequent call to the @ref save_history function. */
  void load_history(QSettings &s, const QString &key = "qtlua_console_history");

  /** Save history using @ref QSettings object previously passed to
      @ref load_history function. */
  void save_history(QSettings &s, const QString &key = "qtlua_console_history") const;

  /** Set Qt regular expression used to extract text before cursor to
    * pass to completion signal.
    *
    * The default regexp @tt{[_.:a-zA-Z0-9]+$} is suited to extract
    * lua identifiers and table member access statements.
    */
  inline void set_completion_regexp(const QRegExp &regexp);

signals:

  /** Signal emited when text line is validated with enter key */
  void line_validate(const QString &str);

  /** Signal emited to query completion list.
   *
   * @param prefix text extracted before cursor.
   * @param list must be filled with completion matches by completion slot function.
   * @param cursor_offset may be decreased by completion slot function to move cursor backward on completed text. (only used on single match)
   */
  void get_completion_list(const QString &prefix, QStringList &list, int &cursor_offset);

public slots:

  /** Display text on the console */
  void print(const QString &str);

private:

  QTextCharFormat	_fmt_normal;
  int			_complete_start;
  int			_prompt_start;
  int			_line_start;
  int			_mark;
  QString		_prompt;
  QStringList		_history;
  int			_history_ndx;
  int			_history_size;
  int			_cursor_pos;
  QRegExp		_complete_re;
  int			_text_width;
  int			_text_height;
  QString               _print_buffer;
  int                   _print_timer;
  int                   _scroll_back;

  QSize sizeHint() const;

  void init();
  // Internal actions
  void action_key_complete();
  void action_key_enter();
  void action_history_up();
  void action_history_down();
  void action_history_find(int direction);
  void display_prompt();
  void delete_completion_list();
  void action_home();
  void action_end();
  void print_flush();

  // Handle mouse events on console
  void mousePressEvent(QMouseEvent *e);
  void mouseReleaseEvent(QMouseEvent *e);
  void mouseDoubleClickEvent(QMouseEvent *e);
  void timerEvent(QTimerEvent *event);

  // Handle keypress
  void keyPressEvent(QKeyEvent * e);
};

/*
  Text color can be changed by writing #x where 'x' is a lower case
  letter code:

  c Qt::black  2   Black (#000000) 
  d Qt::white  3   White (#ffffff) 
  e Qt::darkGray  4   Dark gray (#808080) 
  f Qt::gray  5   Gray (#a0a0a4) 
  g Qt::lightGray  6   Light gray (#c0c0c0) 
  h Qt::red  7   Red (#ff0000) 
  i Qt::green  8   Green (#00ff00) 
  j Qt::blue  9   Blue (#0000ff) 
  k Qt::cyan  10   Cyan (#00ffff) 
  l Qt::magenta  11   Magenta (#ff00ff) 
  m Qt::yellow  12   Yellow (#ffff00) 
  n Qt::darkRed  13   Dark red (#800000) 
  o Qt::darkGreen  14   Dark green (#008000) 
  p Qt::darkBlue  15   Dark blue (#000080) 
  q Qt::darkCyan  16   Dark cyan (#008080) 
  r Qt::darkMagenta  17   Dark magenta (#800080) 
  s Qt::darkYellow  18   Dark yellow (#808000) 
  
*/

}

#endif


