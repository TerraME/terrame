#ifndef PAINTER_SHAPEFILE_H
#define PAINTER_SHAPEFILE_H

#include "../../observer.h"

#include "shapefil.h"

#include <QtGui/QGraphicsPathItem>

namespace TerraMEObserver {

class Attributes;
class PainterWidget;

class PainterShapefile{
public:
    PainterShapefile(QVector<QGraphicsPathItem*> *vshapes, const QVector<int> &idsShapes, int shapetype, QHash<QString, Attributes*> *attributes);
    void drawShapefile(Attributes *attrib);
    void drawAttrib(Attributes *attrib);
    void plotMap(Attributes *attrib);
    void replotMap();
    void setColor(QGraphicsPathItem *item, const QColor & color);
private:
    QVector<QGraphicsPathItem*> *shapes;
    QVector<int> ids;
    int shapeType;
    QHash<QString, Attributes*> *mapAttributes;
    bool reconfigMaxMin;
    int turn_allWhite;
};

}

#endif
