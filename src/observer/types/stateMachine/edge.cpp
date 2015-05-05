/****************************************************
* Based on the Arrow object example DiagramScene
* the framework Qt 4.7.1
****************************************************/

#include "edge.h"

#include <QGraphicsItem>
#include <QtGui>
#include <QPointF>
#include <math.h>

#include "node.h"
#include "observer.h"

using namespace TerraMEObserver;

static const int ARROW_SIZE = 16;

Edge::Edge(Node *orig, Node *dest, QGraphicsItem *parent, QGraphicsScene *scene)
    : QGraphicsLineItem(parent/*, scene*/)
{
    origin = orig;
    destiny = dest;
    updatePosition();

    origin->addEdge(this);
    destiny->addEdge(this);
}

Edge::~Edge()
{

}

QRectF Edge::boundingRect() const
{
    qreal extra = (pen().width() + ARROW_SIZE) / 2.0;

    return QRectF(line().p1(), QSizeF(line().p2().x() - line().p1().x(),
                                      line().p2().y() - line().p1().y()))
            .normalized()
            .adjusted(-extra, -extra, extra, extra);
}

QPainterPath Edge::shape() const
{
    QPainterPath path = QGraphicsLineItem::shape();
    path.addPolygon(arrowHead);
    return path;
}

void Edge::updatePosition()
{
    //    QLineF line(mapFromItem((QGraphicsItem *) destiny, QPointF(0, 0)),
    //                mapFromItem((QGraphicsItem *) origin, QPointF(0, 0)));
    //    setLine(line);
    // update();
    // update(boundingRect());
}

void Edge::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    painter->setPen(QPen(Qt::black, 1, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter->setBrush(Qt::NoBrush);

    // Edge correction
    QPointF mediumPointDest = destiny->pos() + destiny->boundingRect().center();
    QPointF mediumPointOrig = origin->pos() + origin->boundingRect().center();
    qreal hip = destiny->boundingRect().width() * 0.5;
    QLineF base(mediumPointDest, mediumPointOrig);

    double angle = 0;
    if (base.length() != 0)
        angle = ::acos(base.dx() / base.length());

    QPointF intersectPointDest, intersectPointOrig;

    intersectPointDest = QPointF(destiny->pos());
    intersectPointOrig = QPointF(origin->pos());

    if (base.dy() <= 0)
    {
        intersectPointDest += QPointF(cos(angle) * hip, sin(-angle) * hip);
        intersectPointOrig -= QPointF(cos(-angle) * hip, sin(-angle) * hip);
    }
    else
    {
        intersectPointDest += QPointF(cos(angle) * hip, sin(angle) * hip);
        intersectPointOrig -= QPointF(cos(-angle) * hip, sin(angle) * hip);
    }

    // Draws the intersection points in the origin and destination
    //    painter->setPen(QPen(Qt::red, 4));
    //    painter->drawPoint(intersectPointOrig);
    //    painter->drawPoint(intersectPointDest);
    //    painter->setPen(pen);

    base = QLineF(intersectPointDest, intersectPointOrig);
    // setLine(QLineF(intersectPointDest, origin->pos()));
    // setLine(base);

    QPen pen = painter->pen();

    //    // Draws the area between source and destination
    //    painter->setBrush(Qt::NoBrush);
    //    QRectF rec(intersectPointDest, QSizeF(base.dx(), base.dy()));
    //    painter->drawRect(rec);
    //    painter->setPen(QPen(Qt::blue, 4));
    //    painter->drawPoint(intersectPointDest);

    QPointF m = (base.p1() + base.p2()) * 0.5 ;
    QLineF normal = QLineF(m, base.p2()).normalVector();


    QPainterPath path;
    path.moveTo(intersectPointDest);
    path.cubicTo(base.p1(), normal.p2(), base.p2());
    painter->drawPath(path);

    //    painter->setPen(QPen(Qt::blue, 4));
    //    painter->drawPoint(base.p1());
    //    painter->setPen(QPen(Qt::cyan, 4));
    //    painter->drawPoint(normal.p2());
    //    painter->setPen(QPen(Qt::darkBlue, 4));
    //    painter->drawPoint(base.p2());

    angle = 0;
    base.setP2(normal.p2());
    // painter->drawLine(base);

    if (base.length() != 0)
        angle = ::acos(base.dx() / base.length());

    if (base.dy() >= 0)
        angle = (PI * 2) - angle;

    QPointF arrowP1 = intersectPointDest + QPointF(sin(angle + PI / 3) * ARROW_SIZE,
                                                   cos(angle + PI / 3) * ARROW_SIZE);
    QPointF arrowP2 = intersectPointDest + QPointF(sin(angle + PI - PI / 3) * ARROW_SIZE,
                                                   cos(angle + PI - PI / 3) * ARROW_SIZE);

    arrowHead.clear();
    arrowHead << intersectPointDest << arrowP1 << arrowP2;

    painter->setBrush(origin->getColor());
    painter->setPen(pen);
    painter->drawPolygon(arrowHead);

    //    painter->setPen(QPen(Qt::gray, 1));
    //    painter->drawLine(-20, 0, 20, 0);
    //    painter->drawLine(0, -20, 0, 20);

    //    painter->setPen(QPen(Qt::blue, 4));
    //    painter->drawPoint(intersectPointDest - intersectPointDest);
    //    painter->setPen(QPen(Qt::cyan, 4));
    //    painter->drawPoint(arrowP1 - intersectPointDest);
    //    painter->setPen(QPen(Qt::darkBlue, 4));
    //    painter->drawPoint(arrowP2 - intersectPointDest);

    //    qDebug() << "arrowP1: " << arrowP1 << " arrowP2: " << arrowP2;
    //    qDebug() << "dif: " << arrowP1 - arrowP2;
}

