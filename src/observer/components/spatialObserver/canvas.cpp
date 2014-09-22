#include "canvas.h"
#include <QMenu>
#include <QRubberBand>
#include <QDebug>
#include "observer.h"
// static const QSize ICON_SIZE(20, 20);

using namespace TerraMEObserver;


Canvas::Canvas(QWidget *parent)
    : QGraphicsView(parent)
{
    init();
}

Canvas::Canvas(QGraphicsScene * scene, QWidget *parent)
    : QGraphicsView(scene, parent)
{
    init();
}

Canvas::~Canvas()
{
    if (selectionrBand)
        delete selectionrBand;
    selectionrBand = 0;

//    if (contextMenu)
//        delete contextMenu;
//    contextMenu = 0;
}

void Canvas::setupContextMenu(QList<QAction *> *actions)
{
    contextMenuActions = actions;
}

void Canvas::setWindowCursor()
{
    zoomWindow = true;
    handTool = false;
    setCursor(zoomWindowCursor);
}

void Canvas::setPanCursor()
{
    handTool = true;
    zoomWindow = false;
    setCursor(Qt::OpenHandCursor);
}

void Canvas::paintEvent(QPaintEvent * ev)
{	
    if (showRectZoom)
    {
        //---- Desenha o retangulo de zoom
        QPen pen(Qt::DashDotLine);
        QBrush brush(Qt::Dense5Pattern);
        brush.setColor(Qt::white);

        //QPainter painter;
        //painter.setPen(Qt::black);
        //painter.setBrush(brush);
        // painter.drawRect(QRect(imageOffset, lastDragPos));

        zoomRectItem = scene()->addRect(QRectF(mapToScene(imageOffset.x(), imageOffset.y()), 
            mapToScene(lastDragPos.x(), lastDragPos.y()) ), pen, brush);
    }
    QGraphicsView::paintEvent(ev);
}


void Canvas::mousePressEvent(QMouseEvent *ev)
{
    if (ev->button() == Qt::LeftButton)
    {
        imageOffset = mapToScene( ev->pos() );

        if (zoomWindow)
        {
            showRectZoom = true;
            setCursor(zoomInCursor);
        }
        else if (handTool)
        {
            lastDragPos = ev->pos();
            setCursor(Qt::ClosedHandCursor);
        }
    }
    else if (ev->button() == Qt::RightButton)
    {
        if (zoomWindow)
            setCursor(zoomOutCursor);
    }
    // QGraphicsView::mousePressEvent(ev);
}

void Canvas::mouseMoveEvent(QMouseEvent *ev)
{
    if (ev->buttons() & Qt::LeftButton)
    {
        if (zoomWindow)
        {
            // Define as coordenadas do retangulo de zoom
            if (! sceneRect().contains( QRectF(imageOffset, ev->pos()) ))
            {

                bool right = ev->pos().x() > rect().right();
                bool left = ev->pos().x() < rect().left();

                bool top = ev->pos().y() < rect().top();
                bool bottom = ev->pos().y() > rect().bottom();

                // x
                if (right)
                {
                    lastDragPos.setX(rect().right() - 1);
                    lastDragPos.setY(ev->pos().y());
                }
                else if (left)
                {
                    lastDragPos.setX(rect().left());
                    lastDragPos.setY(ev->pos().y());
                }

                // y
                if (top)
                {
                    lastDragPos.setY(0);
                    lastDragPos.setX(ev->pos().x());
                }
                else if (bottom)
                {
                    lastDragPos.setY(rect().height() - 2);
                    lastDragPos.setX(ev->pos().x());
                }
            }
            else
            {
                lastDragPos = ev->pos();
            }
            update();
        }
        else if(handTool)
        {
            setCursor(Qt::ClosedHandCursor);
            QPointF delta = mapToScene(lastDragPos.toPoint()) - mapToScene(ev->pos());
            centerOn( mapToScene(viewport()->rect().center()) + delta);

            // Causa bug ao arrastar
            // lastDragPos = ev->pos();
        }
    }
    // QGraphicsView::mousePressEvent(ev);
}

void Canvas::mouseReleaseEvent(QMouseEvent *ev)
{
    if (ev->button() == Qt::LeftButton)
    {
        if (zoomWindow)
        {
            showRectZoom = false;

            setCursor(zoomWindowCursor);
            update();

            QRectF zoomRect(imageOffset, lastDragPos);
            zoomRect = zoomRect.normalized();

            double factWidth = viewport()->width(); // resultImage.size().width();
            double factHeight = viewport()->height(); // resultImage.size().height();

            factWidth /= zoomRect.width();
            factHeight /= zoomRect.height();

            // Define o maior zoom como sendo 3200%
            factWidth = factWidth > 32.0 ? 32.0 : factWidth;
            factHeight = factHeight > 32.0 ? 32.0 : factHeight;

            // emite o sinal informando o tamanho do retangulo de zoom e
            // os fatores width e height
            emit zoomChanged(zoomRect, factWidth, factHeight);

            // scene()->removeItem(zoomRectItem);
            // delete zoomRectItem;
        }
        else
        {
            if (handTool)
            {
                setCursor(Qt::OpenHandCursor);
                lastDragPos = QPointF();
            }
        }
    }
    else
    {
        if (ev->button() == Qt::RightButton)
        {
            if (zoomWindow)
            {
                emit zoomOut();
                setCursor(zoomWindowCursor);
            }
        }
    }
    // QGraphicsView::mouseReleaseEvent(ev);
}

void Canvas::init()
{
    // zoom
    handTool = false;
    zoomWindow = false;
    gridEnabled = false;

    zoomWindowCursor = QCursor(QPixmap(":icons/zoomWindow.png").scaled(ICON_SIZE));
    zoomInCursor = QCursor(QPixmap(":icons/zoomIn.png").scaled(ICON_SIZE));
    zoomOutCursor = QCursor(QPixmap(":icons/zoomOut.png").scaled(ICON_SIZE));

    imageOffset = QPointF();
    showRectZoom = false;
    selectionrBand = 0; // new QRubberBand(QRubberBand::Rectangle, this);

    // contexMenu = 0;

    // setContextMenuPolicy(Qt::DefaultContextMenu);
}

void Canvas::contextMenuEvent(QContextMenuEvent *event)
{
    if (contextMenuActions)
    {
        QMenu contextMenu(this);
        contextMenu.addActions(*contextMenuActions);
        contextMenu.exec(event->globalPos());
    }
}


