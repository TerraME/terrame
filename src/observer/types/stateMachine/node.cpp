#include "node.h"

#include <QPainter>
#include <QStyleOptionGraphicsItem>
#include <QWidget>

#include "edge.h"

using namespace TerraMEObserver;

static const int DIMENSION = 70;
static const int ACTIVE_PEN_WIDTH = 3.0;
static const int INACTIVE_PEN_WIDTH = 0.0;

static const QColor INACTIVE_COLOR = Qt::gray;
static const QColor ACTIVE_COLOR = Qt::green;

Node::Node(QString n, QGraphicsItem *parent, QGraphicsScene *scene)
    : QGraphicsEllipseItem(parent/*, scene*/)
{
    // setZValue(-1);
    // setFlag(QGraphicsItem::ItemIsMovable);

    name = n;
    currentPenWidth = INACTIVE_PEN_WIDTH;
    currentColor = INACTIVE_COLOR;
    currentColorDefined = false;
}

Node::~Node()
{

}

QRectF Node::boundingRect() const
{
    qreal adjust = 2.0;
    return QRectF(- (DIMENSION * 0.5) - adjust, -(DIMENSION * 0.5) - adjust,
                  DIMENSION + adjust, DIMENSION + adjust);
}

QPainterPath Node::shape() const
{
    QPainterPath path;
    path.addEllipse(boundingRect());
    return path;
}

void Node::setActive(bool active)
{
    if (active)
    {
        if (! currentColorDefined)
            currentColor = ACTIVE_COLOR;
        currentPenWidth = ACTIVE_PEN_WIDTH;
    }
    else
    {
        if (! currentColorDefined)
            currentColor = INACTIVE_COLOR;
        currentPenWidth = INACTIVE_PEN_WIDTH;
    }
}

const QString & Node::getName()
{
    return name;
}

void Node::setColor(QColor c)
{
    currentColor = c;
    currentColorDefined = true;
}

const QColor & Node::getColor()
{
    return currentColor;
}

void Node::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    painter->setBrush(currentColor);
    painter->setPen(QPen(Qt::black, currentPenWidth));
    // painter->drawRect(boundingRect());
    painter->drawEllipse(boundingRect());

    QFont font = painter->font();
    font.setBold((currentPenWidth == ACTIVE_PEN_WIDTH));
    font.setPointSize(11);
    painter->setFont(font);

    painter->setBrush(Qt::black);
    painter->setPen(QPen(Qt::black, currentPenWidth));
    painter->drawText(boundingRect(), Qt::AlignCenter, name);
}

QVariant Node::itemChange(GraphicsItemChange change,
                          const QVariant &value)
{
    if (change == QGraphicsItem::ItemPositionChange)
    {
        foreach (Edge *i, edgeList)
            i->updatePosition();
    }
    return value;
}

void Node::addEdge(Edge *edge)
{
    edgeList.push_back(edge);
    edge->updatePosition();
}

QList<Edge *> Node::getEdges() const
{
    return edgeList;
}
