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

    Copyright (C) 2008-2012, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#include <QSize>
#include <QSizeF>
#include <QRect>
#include <QRectF>
#include <QPoint>
#include <QPointF>
#include <QMetaObject>
#include <QMetaType>
#include <QWidget>
#include <QIcon>
#include <QColor>

#include <QtLua/String>
#include <QtLua/MetaType>
#include <internal/QObjectWrapper>

#include <internal/QMetaValue>

namespace QtLua {

  metatype_map_t types_map;

  static int ud_ref_type = qRegisterMetaType<Ref<UserData> >("QtLua::UserData::ptr");

  Value QMetaValue::raw_get_object(State *ls, int type, const void *data)
  {
    switch (type)
      {
      case QMetaType::Void:
	return Value(ls);
      case QMetaType::Bool:
	return Value(ls, (Value::Bool)*(bool*)data);
      case QMetaType::Int:
	return Value(ls, (double)*(int*)data);
      case QMetaType::UInt:
	return Value(ls, (double)*(unsigned int*)data);
      case QMetaType::Long:
	return Value(ls, (double)*(long*)data);
      case QMetaType::LongLong:
	return Value(ls, (double)*(long long*)data);
      case QMetaType::Short:
	return Value(ls, (double)*(short*)data);
      case QMetaType::Char:
	return Value(ls, (double)*(char*)data);
      case QMetaType::ULong:
	return Value(ls, (double)*(unsigned long*)data);
      case QMetaType::ULongLong:
	return Value(ls, (double)*(unsigned long long*)data);
      case QMetaType::UShort:
	return Value(ls, (double)*(unsigned short*)data);
      case QMetaType::UChar:
	return Value(ls, (double)*(unsigned char*)data);
      case QMetaType::Double:
	return Value(ls, *(double*)data);
      case QMetaType::Float:
	return Value(ls, *(float*)data);
      case QMetaType::QChar:
	return Value(ls, (double)reinterpret_cast<const QChar*>(data)->unicode());
      case QMetaType::QString:
	return Value(ls, String(*reinterpret_cast<const QString*>(data)));
      case QMetaType::QStringList: {
	Value value(Value::new_table(ls));
	const QStringList *qsl = reinterpret_cast<const QStringList*>(data);
	for (int i = 0; i < qsl->size(); i++)
	  value[i+1] = String(qsl->at(i));
	return value;
      }
      case QMetaType::QByteArray:
	return Value(ls, String(*reinterpret_cast<const QByteArray*>(data)));
      case QMetaType::QObjectStar:
	return Value(ls, QObjectWrapper::get_wrapper(ls, *(QObject**)data));
#if QT_VERSION < 0x050000
      case QMetaType::QWidgetStar:
	return Value(ls, QObjectWrapper::get_wrapper(ls, *(QWidget**)data));
#endif
      case QMetaType::QSize: {
	Value value(Value::new_table(ls));
	const QSize *size = reinterpret_cast<const QSize*>(data);
	value[1] = size->width();
	value[2] = size->height();
	return value;
      }
      case QMetaType::QSizeF: {
	Value value(Value::new_table(ls));
	const QSizeF *size = reinterpret_cast<const QSizeF*>(data);
	value[1] = size->width();
	value[2] = size->height();
	return value;
      }
      case QMetaType::QRect: {
	Value value(Value::new_table(ls));
	const QRect *rect = reinterpret_cast<const QRect*>(data);
	value[1] = rect->x();
	value[2] = rect->y();
	value[3] = rect->width();
	value[4] = rect->height();
	return value;
      }
      case QMetaType::QRectF: {
	Value value(Value::new_table(ls));
	const QRectF *rect = reinterpret_cast<const QRectF*>(data);
	value[1] = rect->x();
	value[2] = rect->y();
	value[3] = rect->width();
	value[4] = rect->height();
	return value;
      }
      case QMetaType::QPoint: {
	Value value(Value::new_table(ls));
	const QPoint *point = reinterpret_cast<const QPoint*>(data);
	value[1] = point->x();
	value[2] = point->y();
	return value;
      }
      case QMetaType::QPointF: {
	Value value(Value::new_table(ls));
	const QPointF *point = reinterpret_cast<const QPointF*>(data);
	value[1] = point->x();
	value[2] = point->y();
	return value;
      }
      case QMetaType::QColor: {
	Value value(Value::new_table(ls));
	const QColor *color = reinterpret_cast<const QColor*>(data);
	value[1] = color->red();
	value[2] = color->green();
	value[3] = color->blue();
	return value;
      }
      default:
	if (type == ud_ref_type)
	  {
	    const Ref<UserData> &ud = *(Ref<UserData>*)data;
	    if (ud.valid())
	      return Value(ls, ud);
	    else
	      return Value(ls);
	  }

	metatype_map_t::const_iterator i = types_map.find(type);

	if (i != types_map.end())
	  return i.value()->qt2lua(ls, data);

	return Value(ls);
      }
  }

  void QMetaValue::raw_set_object(int type, void *data, const Value &v)
  {
    switch (type)
      {
      case QMetaType::Bool:
	*(bool*)data = v.to_boolean();
	break;
      case QMetaType::Int:
	*(int*)data = v.to_number();
	break;
      case QMetaType::UInt:
	*(unsigned int*)data = v.to_number();
	break;
      case QMetaType::Long:
	*(long*)data = v.to_number();
	break;
      case QMetaType::LongLong:
	*(long long*)data = v.to_number();
	break;
      case QMetaType::Short:
	*(short*)data = v.to_number();
	break;
      case QMetaType::Char:
	*(char*)data = v.to_number();
	break;
      case QMetaType::ULong:
	*(unsigned long*)data = v.to_number();
	break;
      case QMetaType::ULongLong:
	*(unsigned long long*)data = v.to_number();
	break;
      case QMetaType::UShort:
	*(unsigned short*)data = v.to_number();
	break;
      case QMetaType::UChar:
	*(unsigned char*)data = v.to_number();
	break;
      case QMetaType::Double:
	*(double*)data = v.to_number();
	break;
      case QMetaType::Float:
	*(double*)data = v.to_number();
	break;
      case QMetaType::QChar:
	*reinterpret_cast<QChar*>(data) = QChar((unsigned short)v.to_number());
	break;
      case QMetaType::QString:
	*reinterpret_cast<QString*>(data) = v.to_qstring();
	break;
      case QMetaType::QStringList: {
	QStringList *qsl = reinterpret_cast<QStringList*>(data);
	try {
	  for (int i = 1; ; i++)
	    qsl->push_back(v.at(i).to_qstring());
	} catch (String &e) {
	}
	break;
      }
      case QMetaType::QByteArray:
	*reinterpret_cast<QByteArray*>(data) = v.to_string();
	break;
      case QMetaType::QObjectStar:
	if (v.is_nil())
	  *reinterpret_cast<QObject**>(data) = 0;
	else
	  *reinterpret_cast<QObject**>(data) = &v.to_userdata_cast<QObjectWrapper>()->get_object();
	break;
#if QT_VERSION < 0x050000
      case QMetaType::QWidgetStar: {
	if (v.is_nil())
	  {
	    *reinterpret_cast<QWidget**>(data) = 0;
	    break;
	  }
	QObject *obj = &v.to_userdata_cast<QObjectWrapper>()->get_object();
	QWidget *w = dynamic_cast<QWidget*>(obj);
	if (obj && !w)
	  QTLUA_THROW(QtLua::MetaType, "Can not convert a non-QObject lua value to a QWidget.");
	else
	  *reinterpret_cast<QWidget**>(data) = w;
	break;
      }
#endif
      case QMetaType::QSize: {
	QSize *size = reinterpret_cast<QSize*>(data);
	size->setWidth(v.at(1).to_number());
	size->setHeight(v.at(2).to_number());
	break;
      }
      case QMetaType::QSizeF: {
	QSizeF *size = reinterpret_cast<QSizeF*>(data);
	size->setWidth(v.at(1).to_number());
	size->setHeight(v.at(2).to_number());
	break;
      }
      case QMetaType::QSizePolicy: {
	QSizePolicy *sp = reinterpret_cast<QSizePolicy*>(data);
	sp->setHorizontalStretch(v.at(1).to_number());
	sp->setVerticalStretch(v.at(2).to_number());
	sp->setHorizontalPolicy((QSizePolicy::Policy)v.at(3).to_integer());
	sp->setVerticalPolicy((QSizePolicy::Policy)v.at(4).to_integer());
	break;
      }
      case QMetaType::QRect: {
	QRect *rect = reinterpret_cast<QRect*>(data);
	rect->setX(v.at(1).to_number());
	rect->setY(v.at(2).to_number());
	rect->setWidth(v.at(3).to_number());
	rect->setHeight(v.at(4).to_number());
	break;
      }
      case QMetaType::QRectF: {
	QRectF *rect = reinterpret_cast<QRectF*>(data);
	rect->setX(v.at(1).to_number());
	rect->setY(v.at(2).to_number());
	rect->setWidth(v.at(3).to_number());
	rect->setHeight(v.at(4).to_number());
	break;
      }
      case QMetaType::QPoint: {
	QPoint *point = reinterpret_cast<QPoint*>(data);
	point->setX(v.at(1).to_number());
	point->setY(v.at(2).to_number());
	break;
      }
      case QMetaType::QPointF: {
	QPointF *point = reinterpret_cast<QPointF*>(data);
	point->setX(v.at(1).to_number());
	point->setY(v.at(2).to_number());
	break;
      }
      case QMetaType::QIcon: {
	QIcon *icon = reinterpret_cast<QIcon*>(data);
	*icon = QIcon(v.to_string());
	break;
      }
      case QMetaType::QColor: {
	QColor *color = reinterpret_cast<QColor*>(data);
	*color = QColor(v.at(1).to_integer(), v.at(2).to_integer(), v.at(3).to_integer());
	break;
      }
      default: {

	if (!QMetaType::isRegistered(type))
	  QTLUA_THROW(QtLua::MetaType, "Unable to convert from lua type `%' to the non-registered Qt type handle `%'.",
		      .arg(v.type_name_u()).arg(type));

	if (type == ud_ref_type)
	  {
	    *reinterpret_cast<Ref<UserData>*>(data) = v.to_userdata();
	    break;
	  }

	metatype_map_t::const_iterator i = types_map.find(type);

	if (i != types_map.end() && i.value()->lua2qt(data, v))
	  break;
      }

      case 0:
	QTLUA_THROW(QtLua::MetaType, "Unsupported conversion from lua type `%' to Qt type `%'.",
		    .arg(v.type_name_u()).arg(QMetaType::typeName(type)));
      }

  }

}

