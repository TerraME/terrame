#include "painterShapefile.h"
#include "legendAttributes.h"
#include "observerShapefile.h"
#include<QDebug>

extern "C"
{
#include <lua.h>
}
#include "luna.h"

extern lua_State * L;

using namespace TerraMEObserver;

PainterShapefile::PainterShapefile(QVector<QGraphicsPathItem*> *vshapes,
    const QVector<int> &idsShapes, int shapetype, QHash<QString, Attributes*> *attributes)
    : shapes(vshapes), ids(idsShapes), shapeType(shapetype), mapAttributes(attributes)
{
    reconfigMaxMin = false;
}

void PainterShapefile::drawShapefile(Attributes *attrib)
{
    if(attrib->getVisible()) {
        drawAttrib(attrib);
    }
    else turn_allWhite++;
}

void PainterShapefile::setColor(QGraphicsPathItem *item, const QColor &color) {
    if(shapeType == SHPT_ARC || shapeType == SHPT_ARCZ) {
        QPen pen;
        pen.setColor(color);
        item->setPen(pen);
    }
    else {
        item->setBrush(color);
    }
}

void PainterShapefile::drawAttrib(Attributes *attrib)
{
    if (attrib->getDataType() == TObsNumber)
    {
        QColor color(Qt::white);
        QVector<double> *values = attrib->getNumericValues();
        QVector<ObsLegend> *vecLegend = attrib->getLegend();

        double /*x = -1.0, y = -1.0, */ v = 0.0;

        int vSize = values->size();
        //int xSize = attrib->getXsValue()->size();
        //int ySize = attrib->getYsValue()->size();

        for(int pos = 0; pos < vSize; pos++)
        {
            QGraphicsPathItem *item = shapes->at(ids.at(pos));
            v = values->at(pos);

            //x = attrib->getXsValue()->at(pos);
            //y = attrib->getYsValue()->at(pos);

            if (vecLegend->isEmpty())
            {
                v = v - attrib->getMinValue();

                double c = v * attrib->getVal2Color();
                if ((c >= 0) && (c <= 255))
                {
                    color.setRgb(c, c, c);
                }
                else
                {
                    if (! reconfigMaxMin)
                    {
                        /*
                        if (! QUIET_MODE)
                            qWarning("Warning: Invalid color. You need to reconfigure the "
                                     "maximum and the minimum values of the attribute \"%s\".",
                                     qPrintable(attrib->getName()));
                        */

                        reconfigMaxMin = true;
                    }
                    color.setRgb(255, 255, 255);
                }
                setColor(item, color);
            }
            else
            {
                for(int j = 0; j < vecLegend->size(); j++)
                {
                    //setColor(item, Qt::white);

                    const ObsLegend &leg = vecLegend->at(j);
                    if (attrib->getGroupMode() == TObsUniqueValue) // single value 3
                    {
                        if (v == leg.getToNumber())
                        {
                            setColor(item, leg.getColor());
                            break;
                        }
                    }
                    else
                    {
                        if ((leg.getFromNumber() <= v) && (v < leg.getToNumber()))
                        {
                            setColor(item, leg.getColor());
                            break;
                        }
                    }
                }
            }
        }
    }
    else if (attrib->getDataType() == TObsText)
    {
        QVector<QString> *values = attrib->getTextValues();
        QVector<ObsLegend> *vecLegend = attrib->getLegend();

        int random = rand() % 256;
        double x = -1.0, y = -1.0;

        int vSize = values->size();
        int xSize = attrib->getXsValue()->size();
        int ySize = attrib->getYsValue()->size();

        for (int pos = 0; (pos < vSize && pos < xSize && pos < ySize); pos++)
        {
            QGraphicsPathItem *item = shapes->at(ids.at(pos));
            const QString & v = values->at(pos);

            // Fixes the bug when an agent dies
            if (attrib->getXsValue()->isEmpty() || attrib->getXsValue()->size() == pos)
                break;

            x = attrib->getXsValue()->at(pos);
            y = attrib->getYsValue()->at(pos);

            if (vecLegend->isEmpty())
            {
                setColor(item, QColor(random, random, random));
            }
            else
            {
                //setColor(item, Qt::white);
                for(int j = 0; j < vecLegend->size(); j++)
                {
                    const ObsLegend &leg = vecLegend->at(j);
                    if (v == leg.getFrom())
                    {
                        setColor(item, leg.getColor());
                        break;
                    }
                }
            }
        }
    }
}

void PainterShapefile::plotMap(Attributes *attrib)
{
    if (! attrib)
	{
		string err_out = string("Erro: PainterWidget::plotMap - Invalid attribute!!");
		lua_getglobal(L, "customErrorMsg");
		lua_pushstring(L, err_out.c_str());
		lua_pushnumber(L, 5);
		lua_call(L, 2, 0);
		//return 0;
	}

    drawShapefile(attrib);
}

void PainterShapefile::replotMap()
{
    turn_allWhite = 0;
    QList<Attributes *> listAttribs = mapAttributes->values();

    for (int i = 0; i < listAttribs.size(); i++)
        plotMap(listAttribs.at(i));
    if(turn_allWhite == listAttribs.size())
    	for(int i = 0; i < shapes->size(); i++)
    		setColor(shapes->at(i), Qt::white);
}
