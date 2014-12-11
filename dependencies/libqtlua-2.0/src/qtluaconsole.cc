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


#include <QKeyEvent>
#include <QTextCursor>
#include <QColor>
#include <QScrollBar>
#include <QAbstractSlider>
#include <QFontMetrics>

#ifdef QTLUA_DEBUG_KEYS
# include <QDebug>
#endif

#include <QtLua/Console>

namespace QtLua {

Console::Console(QWidget *parent, const QString &prompt, const QStringList &history)
  : QTextEdit(parent),
    _prompt(prompt),
    _history(history),
    _complete_re("[_.:a-zA-Z0-9]+$")
{
  _text_width = 80;
  _text_height = 25;
  _scroll_back = 1000;

  _fmt_normal.setFontFamily("monospace");
  _fmt_normal.setFontFixedPitch(true);
  _fmt_normal.setFontItalic(false);
  _fmt_normal.setFontPointSize(12);

  setCurrentCharFormat(_fmt_normal);
  setWordWrapMode(QTextOption::WrapAnywhere);
  setContextMenuPolicy(Qt::NoContextMenu);

  _history_ndx = _history.size();
  _history_size = 100;
  _history.append("");
  _print_timer = 0;

  display_prompt();
}

void Console::display_prompt()
{
  QTextCursor	tc;

  setUndoRedoEnabled(false);
  tc = textCursor();
  _complete_start = _prompt_start = tc.position();

  setTextColor(Qt::blue);
  insertPlainText(_prompt);

  setTextColor(palette().color(QPalette::Text));
  tc = textCursor();
  insertPlainText(" ");

  _mark = _line_start = tc.position();
  setUndoRedoEnabled(true);
}

void Console::set_history(const QStringList &h)
{
  _history = h;
  _history_ndx = _history.size();
  _history.append("");
}

void Console::load_history(QSettings &settings, const QString &key)
{
  int size = settings.beginReadArray(key);

  if (size > 0)
    {
      _history.clear();

      for (int i = 0; i < size; ++i)
	{
	  settings.setArrayIndex(i);
	  _history.append(settings.value("line").toString());
	}

      _history_ndx = _history.size();
      _history.append("");
    }

  settings.endArray();
}

void Console::save_history(QSettings &settings, const QString &key) const
{
  settings.beginWriteArray(key);

  int i, j;
  for (i = j = 0; i < _history.size(); i++)
    {
      const QString & line = _history.at(i);

      if (line.trimmed().isEmpty())
	continue;

      settings.setArrayIndex(j++);
      settings.setValue("line", _history.at(i));
    }

  settings.endArray();
}

void Console::action_history_up()
{
  if (_history_ndx == 0)
    return;

  setUndoRedoEnabled(false);
  QTextCursor	tc = textCursor();

  tc.setPosition(_line_start, QTextCursor::MoveAnchor);
  tc.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);

  _history.replace(_history_ndx, tc.selectedText());

  tc.insertText(_history[--_history_ndx]);
  setUndoRedoEnabled(true);
}

void Console::action_history_down()
{
  if (_history_ndx + 1 >= _history.size())
    return;

  setUndoRedoEnabled(false);
  QTextCursor	tc = textCursor();

  tc.setPosition(_line_start, QTextCursor::MoveAnchor);
  tc.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);

  _history.replace(_history_ndx, tc.selectedText());

  tc.insertText(_history[++_history_ndx]);
  setUndoRedoEnabled(true);
}

void Console::action_history_find(int direction)
{
  setUndoRedoEnabled(false);
  QTextCursor tc = textCursor();
  QString str;
  bool hs;

  if ((hs = tc.hasSelection()))
    str = tc.selectedText();

  tc.setPosition(_line_start, QTextCursor::MoveAnchor);
  tc.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);

  if (!hs)
    str = tc.selectedText().trimmed();

  if (str.size() > 0)
    {
      for (int i = _history_ndx + direction;
	   i >= 0 && i < _history.size(); i += direction)
	{
	  int ndx = _history[i].indexOf(str);

	  if (ndx >= 0)
	    {
	      _history_ndx = i;
	      tc.insertText(_history[i]);
	      tc.setPosition(_line_start + ndx, QTextCursor::MoveAnchor);
	      tc.setPosition(_line_start + ndx + str.size(), QTextCursor::KeepAnchor);
	      setTextCursor(tc);
	      break;
	    }
	}
    }

  setUndoRedoEnabled(true);
}

void Console::action_key_complete()
{
  QStringList list;

  // get text chunk to complete
  QTextCursor	tc = textCursor();
  tc.setPosition(_line_start, QTextCursor::KeepAnchor);
  QString prefix = tc.selectedText();
  int idx = prefix.indexOf(_complete_re);

  if (idx < 0)
    {
      delete_completion_list();
      return;
    }

  int offset = 0;
  // get completion candidates list
  emit get_completion_list(prefix.mid(idx), list, offset);

  switch (list.count())
    {
      //////////// no candidate
    case 0:
      delete_completion_list();
      return;

      //////////// single candidate
    case 1: {
      QTextCursor	tc = textCursor();

      // insert
      tc.setPosition(_line_start + idx, QTextCursor::KeepAnchor);
      tc.insertText(list[0]);

      // move cursor if needed
      if (offset)
	{
	  tc.setPosition(tc.position() + offset, QTextCursor::MoveAnchor);
	  setTextCursor(tc);
	}
      delete_completion_list();
      break;
    }

      //////////// multiple candidates
    default: {
      int i;

      // find common prefix
      for (i = 0; ; i++)
	{
	  QChar c;

	  foreach(QString str, list)
	    {
	      if (i == str.size())
		goto break2;
	      if (c.isNull())
		c = str[i];
	      else if (str[i] != c)
		goto break2;
	    }
	}

    break2:

      // insert common prefix
      if (i)
	{
	  QTextCursor	tc = textCursor();

	  tc.setPosition(_line_start + idx, QTextCursor::KeepAnchor);
	  tc.insertText(list[0].left(i));
	}

      // print list

      setUndoRedoEnabled(false);
      // clear previous completion list text
      QTextCursor tc = textCursor();
      int offset = tc.position() - _line_start;
      tc.setPosition(_complete_start, QTextCursor::MoveAnchor);
      tc.setPosition(_prompt_start, QTextCursor::KeepAnchor);
      tc.removeSelectedText();
      setTextCursor(tc);

      // insert new completion list text
      foreach(const QString &str, list)
	{
	  setTextColor(Qt::darkRed);
	  insertPlainText(str + "\n");
	}
      if (list.size() >= QTLUA_MAX_COMPLETION)
	{
	  setTextColor(Qt::darkBlue);
	  insertPlainText("...too many entries...\n");
	}
      setTextColor(palette().color(QPalette::Text));

      // adjust cursor position variables
      tc = textCursor();
      _line_start += tc.position() - _prompt_start;
      _mark += tc.position() - _prompt_start;
      _prompt_start = tc.position();
      tc.setPosition(_line_start + offset, QTextCursor::MoveAnchor);
      setTextCursor(tc);
      setUndoRedoEnabled(true);
    }
    }
}

void Console::set_prompt(const QString &p)
{
#if 0
  int diff = p.size() - _prompt.size();
#endif
  _prompt = p;

#if 0
  // replace current prompt
  // FIXME missing color
  QTextCursor	tc = textCursor();
  tc.setPosition(_prompt_start, QTextCursor::MoveAnchor);
  tc.setPosition(_line_start, QTextCursor::KeepAnchor);
  tc.insertText(p + " ");

  _line_start += diff;
  _mark += diff;
#endif
}

const QString & Console::get_prompt() const
{
  return _prompt;
}

void Console::set_text_width(int width)
{
  _text_width = width;
}

int Console::get_text_width() const
{
  return _text_width;
}

void Console::set_text_height(int height)
{
  _text_height = height;
}

int Console::get_text_height() const
{
  return _text_height;
}

void Console::set_history_size(int history_size)
{
  _history_size = history_size;

  // strip _history if too long
  while (_history.size() > _history_size)
    _history.removeFirst();
}

int Console::get_history_size() const
{
  return _history_size;
}

void Console::set_scroll_back(int scroll_back)
{
  _scroll_back = scroll_back;
}

int Console::get_scroll_back() const
{
  return _scroll_back;
}

void Console::action_key_enter()
{
  QTextCursor	tc = textCursor();

  // select function line
  tc.setPosition(_line_start, QTextCursor::MoveAnchor);
  tc.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);

  QString	line = tc.selectedText().trimmed();

  // strip _history if too long
  while (_history.size() > _history_size)
    _history.removeFirst();

  // skip empty strings
  if (!line.trimmed().isEmpty())
    {
      // detect duplicate in _history
      if (_history.size() > 1)
	{
	  int	prev = _history.lastIndexOf(line, _history.size() - 2);

	  if (prev >= 0)
	    _history.removeAt(prev);
	}

      // set _history entry
      _history.replace(_history.size() - 1, line);

      _history.append("");
    }

  _history_ndx = _history.size() - 1;

  // move visible cursor to end
  tc.clearSelection();
  setTextCursor(tc);
  // new line
  append("");

  // print() text goes at end
  _complete_start = textCursor().position();

  if (!line.trimmed().isEmpty())
    emit line_validate(line);

  document()->setMaximumBlockCount(_scroll_back);
  document()->setMaximumBlockCount(0);
  setUndoRedoEnabled(true);
}

void Console::action_home()
{
  QTextCursor	tc = textCursor();

  tc.setPosition(_line_start, QTextCursor::MoveAnchor);
  setTextCursor(tc);
}

void Console::action_end()
{
  QTextCursor	tc = textCursor();

  tc.movePosition(QTextCursor::End, QTextCursor::MoveAnchor, 1);
  setTextCursor(tc);
}

void Console::delete_completion_list()
{
  if (_complete_start != _prompt_start)
    {
      QTextCursor	tc = textCursor();

      setUndoRedoEnabled(false);
      tc.setPosition(_complete_start, QTextCursor::MoveAnchor);
      tc.setPosition(_prompt_start, QTextCursor::KeepAnchor);
      tc.removeSelectedText();

      _line_start += tc.position() - _prompt_start;
      _mark += tc.position() - _prompt_start;
      _prompt_start = tc.position();
      setUndoRedoEnabled(true);
    }
}

void Console::keyPressEvent(QKeyEvent * e)
{
#ifdef QTLUA_DEBUG_KEYS
  qDebug() << e->key() << e->modifiers();
#endif

  switch (e->modifiers())
    {
    case Qt::ControlModifier:
      switch (e->key())
	{
	case Qt::Key_C: {
	  QTextCursor	tc = textCursor();

	  tc.movePosition(QTextCursor::End, QTextCursor::MoveAnchor, 1);
	  tc.insertText("\n");
	  setTextCursor(tc);
	  delete_completion_list();
	  display_prompt();
	} break;

	case Qt::Key_R:
	  action_history_find(-1);
	  break;
	case Qt::Key_F:
	  action_history_find(1);
	  break;

	case Qt::Key_Y:
	case Qt::Key_V:
	  paste();
	  break;

	case Qt::Key_Underscore:
	case Qt::Key_Z:
	  undo();
	  break;

	case Qt::Key_A:
	  action_home();
	  break;

	case Qt::Key_E:
	  action_end();
	  break;

	case Qt::Key_U: {
	  QTextCursor	tc = textCursor();
	  tc.setPosition(_line_start, QTextCursor::KeepAnchor);
	  setTextCursor(tc);
	  cut();
	  break;
	}

	case Qt::Key_K: {
	  QTextCursor	tc = textCursor();
	  tc.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);
	  setTextCursor(tc);
	  cut();
	  break;
	}

	case Qt::Key_W: {
	  QTextCursor	tc = textCursor();
	  tc.setPosition(_mark, QTextCursor::KeepAnchor);
	  setTextCursor(tc);
	  cut();
	  break;
	}

	case Qt::Key_Space: {
	  QTextCursor	tc = textCursor();
	  _mark = textCursor().position();
	  break;
	}
	}

      ensureCursorVisible();
      break;

    case Qt::AltModifier:

      switch (e->key())
	{
	case Qt::Key_W: {
	  QTextCursor	tc = textCursor();
	  int cur = tc.position();
	  tc.setPosition(_mark, QTextCursor::KeepAnchor);
	  setTextCursor(tc);
	  copy();
	  tc.setPosition(cur, QTextCursor::MoveAnchor);
	  setTextCursor(tc);
	  break;
	}

	case Qt::Key_D: {
	  QTextCursor	tc = textCursor();
	  tc.movePosition(QTextCursor::NextWord, QTextCursor::KeepAnchor, 1);
	  tc.removeSelectedText();
	  break;
	}

	case Qt::Key_Backspace: {
	  QTextCursor	tc = textCursor();
	  tc.movePosition(QTextCursor::PreviousWord, QTextCursor::KeepAnchor, 1);
	  if (tc.position() < _line_start)
	    tc.setPosition(_line_start, QTextCursor::KeepAnchor);
	  tc.removeSelectedText();
	  break;
	}

	case Qt::Key_F: {
	  QTextCursor	tc = textCursor();
	  tc.movePosition(QTextCursor::NextWord, QTextCursor::MoveAnchor, 1);
	  setTextCursor(tc);
	  break;
	}

	case Qt::Key_B: {
	  QTextCursor	tc = textCursor();
	  tc.movePosition(QTextCursor::PreviousWord, QTextCursor::MoveAnchor, 1);
	  if (tc.position() < _line_start)
	    tc.setPosition(_line_start, QTextCursor::MoveAnchor);
	  setTextCursor(tc);
	  break;
	}

	}
      break;

    case Qt::NoModifier:
    case Qt::KeypadModifier:

      switch (e->key())
	{
	case Qt::Key_End:
	  action_end();
	  break;

	case Qt::Key_Delete:
	case Qt::Key_Right:
	  QTextEdit::keyPressEvent(e);
	  break;

	case Qt::Key_Return:
	case Qt::Key_Enter:
	  delete_completion_list();
	  action_key_enter();
	  display_prompt();
	  break;

	case Qt::Key_Tab:
	  action_key_complete();
	  break;

	case Qt::Key_Left:
	case Qt::Key_Backspace:
	  if (textCursor().position() > _line_start)
	    QTextEdit::keyPressEvent(e);
	  break;

	case Qt::Key_Home:
	  action_home();
	  break;

	case Qt::Key_Up:
	  action_history_up();
	  break;

	case Qt::Key_Down:
	  action_history_down();
	  break;

	case Qt::Key_PageUp:
	  verticalScrollBar()->triggerAction(QAbstractSlider::SliderPageStepSub);
	  return;

	case Qt::Key_PageDown:
	  verticalScrollBar()->triggerAction(QAbstractSlider::SliderPageStepAdd);
	  return;
	}

    case Qt::GroupSwitchModifier:
    case Qt::ShiftModifier:

      if (e->key() >= Qt::Key_Space && e->key() <= Qt::Key_AsciiTilde)
	{
	  // Let normal ascii keys through
	  QTextEdit::keyPressEvent(e);
	  ensureCursorVisible();
	  break;
	}

      ensureCursorVisible();
      break;
    }
}

void Console::mouseDoubleClickEvent(QMouseEvent *e)
{
  Q_UNUSED(e);
}

void Console::mousePressEvent(QMouseEvent *e)
{
  QTextCursor		tc = textCursor();

  if (e->button() & Qt::LeftButton)
    {
      // make readonly while using mouse
      _cursor_pos = tc.position();
      setReadOnly(true);
      QTextEdit::mousePressEvent(e);
    }

  if (e->button() & Qt::MidButton)
    {
      paste();
    }
}

void Console::mouseReleaseEvent(QMouseEvent *e)
{
  if ((e->button() & Qt::LeftButton))
    {
      QTextCursor	tc = textCursor();

      QTextEdit::mouseReleaseEvent(e);

      // copy selection to clipboard
      copy();

      // restore cursor position and remove readonly
      tc.setPosition(_cursor_pos, QTextCursor::MoveAnchor);
      setReadOnly(false);
      setTextCursor(tc);
    }
}

void Console::print(const QString &str)
{
  _print_buffer.append(str);
  if (!_print_timer)
    _print_timer = startTimer(0);
}

void Console::timerEvent(QTimerEvent *event)
{
  if (event->timerId() == _print_timer)
    print_flush();
}

void Console::print_flush()
{
  if (_print_buffer.isEmpty())
    return;

  int first = 0;
  int last;
  static QRegExp rx("\\0033\\[(\\d*)m");

  document()->setMaximumBlockCount(_scroll_back);

  // go before prompt and completion list
  QTextCursor tc = textCursor();
  int cur = tc.position();
  tc.setPosition(_complete_start, QTextCursor::MoveAnchor);
  setTextCursor(tc);

  // insert text
  setTextColor(palette().color(QPalette::Text));

  while ((last = _print_buffer.indexOf(rx, first)) >= 0)
    {
      if (last > first)
	insertPlainText(_print_buffer.mid(first, last - first));
      first = last + rx.matchedLength();

      unsigned int c = rx.cap(1).toUInt();
      if (!c)
	setTextColor(palette().color(QPalette::Text));
      else
	setTextColor((Qt::GlobalColor)c);
    }

  insertPlainText(_print_buffer.mid(first, _print_buffer.size() - first));
  _print_buffer.clear();

  killTimer(_print_timer);
  _print_timer = 0;

  // adjust cursor position variables
  tc = textCursor();
  int len = tc.position() - _complete_start;
  _complete_start += len;
  _line_start += len;
  _mark += len;
  _prompt_start += len;
  tc.setPosition(cur + len, QTextCursor::MoveAnchor);
  setTextCursor(tc);

  document()->setMaximumBlockCount(0);
  setUndoRedoEnabled(true);
}

QSize Console::sizeHint() const
{
  QFontMetrics fm(_fmt_normal.font());
  int left, top, right, bottom;
  getContentsMargins(&left, &top, &right, &bottom);
  QSize hint(left + right + fm.width('x') * _text_width,
	     top + bottom + fm.height() * _text_height);

  return hint;
}

}

