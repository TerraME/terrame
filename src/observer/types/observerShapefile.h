#ifndef OBSERVER_SHAPEFILE_H
#define OBSERVER_SHAPEFILE_H

#include "observerMapSuperclass.h"
#include <QtGui>
#include "../../dependencies/shapelib/shapefil.h"
#include <QVector>
#include<string>
#include<QHash>
#include "../components/painter/painterShapefile.h"

namespace TerraMEObserver{

class ObserverShapefile : public ObserverMapSuperclass{
    Q_OBJECT

public:
    ObserverShapefile(Subject *subj, QWidget *parent = 0);

    virtual ~ObserverShapefile();

    bool draw(QDataStream &state);
    
    QGraphicsPathItem* createItem(SHPObject *obj, int x, int y,double dx, double dy, double sx, double sy);
    void loadShape(const string &filename);
    void scaleView(qreal newScale);

public slots:
    void treeLayers_itemChanged(QTreeWidgetItem * item, int column);

private:
    QGraphicsPathItem* createItemPolygon(SHPObject *obj, int x, int y,double dx, double dy, double sx, double sy);
    QGraphicsPathItem* createItemPolyline(SHPObject *obj, int x, int y,double dx, double dy, double sx, double sy);
    QGraphicsPathItem* createItemPoint(SHPObject *obj, int x, int y,double dx, double dy, double sx, double sy);
    void showLayerLegend();

    QVector<QGraphicsPathItem*> shapes;
    int nshapes;
    int shapeType;
    QPointF *pf;
    QVector<int> *ids;
    PainterShapefile *painter;
};
}

#endif
