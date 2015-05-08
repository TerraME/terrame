#include "painterWidget.h"

#include <QApplication>
#include <QPixmap>
#include <QPainter>
#include <QMetaType>
#include <QMessageBox>
#include <QScrollBar>
#include <QFile>
#include <QDebug>

#include "observerImpl.h"
#include "legendAttributes.h"

#include "taskManager.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Performance Statistics
    #include "statistic.h"
#endif

using namespace TerraMEObserver;

PainterWidget::PainterWidget(QHash<QString, Attributes*> *mapAttrib,
    TypesOfObservers observerType, QWidget *parent)
    : mapAttributes(mapAttrib), QWidget(parent)
{
    // Optimization for Paint Event
    // setAttribute(Qt::WA_OpaquePaintEvent);

    // zoom
    handTool = false;
    zoomWindow = false;
    gridEnabled = false;

    heightProportion = 1.0;
    widthProportion = 1.0;

    pixmapScale = 0.;
    curScale = 1.0;
    operatorMode = QPainter::CompositionMode_Multiply;

    zoomWindowCursor = QCursor(QPixmap(":icons/zoomWindow.png").scaled(ICON_SIZE));
    zoomInCursor = QCursor(QPixmap(":icons/zoomIn.png").scaled(ICON_SIZE));
    zoomOutCursor = QCursor(QPixmap(":icons/zoomOut.png").scaled(ICON_SIZE));

    // resultImage = QImage(IMAGE_SIZE, QImage::Format_ARGB32_Premultiplied);
    resultImage = QImage(QSize(10, 10), QImage::Format_ARGB32_Premultiplied);
    resultImage.fill(0);
    // resultImageBkp = resultImage;

    setGeometry(0, 0, 1010, 1010);

    cellSize = QSize(-1, -1);
    imageOffset = QPoint();
    showRectZoom = false;
    existAgent = false;
    mapValuesPassed = false;

    qRegisterMetaType<QImage>("QImage");
    //connect(&visualMapping, SIGNAL(displayImage(QImage)), this, SLOT(displayImage(QImage)), Qt::DirectConnection);
    //connect(&visualMapping, SIGNAL(update()), this, SLOT(update()), Qt::QueuedConnection);

    visualMapping = new VisualMapping(observerType);
    connect(visualMapping, SIGNAL(displayImage(QImage)),
        this, SLOT(displayImage(QImage)) , Qt::QueuedConnection); // DirectConnection); //
    connect(this, SIGNAL(enableGrid(bool)),
        visualMapping, SLOT(enableGrid(bool)));
}

PainterWidget::~PainterWidget()
{
    if (visualMapping)
        delete visualMapping; visualMapping = 0;
}

void PainterWidget::setOperatorMode(QPainter::CompositionMode mode)
{
    operatorMode = mode;
}

void PainterWidget::plotMap(Attributes * /*attrib*/)
{
    qWarning("\nPainterWidget::plotMap() deprecated!!\n");

    // TO-DO: Verif., does not work with BlackBoard

    //if (!attrib)
    //    qFatal("\nErro: PainterWidget::plotMap - Invalid attribute!!\n");

    //if (attrib->getType() != TObsAgent)
    //{
    //    QPainter p;
    //    visualMapping.drawAttrib(&p, attrib);

    //    //static int aa = 1;
    //    //attrib->getImage()->save(QString("%1_%2.png").arg(attrib->getName()).arg(aa));
    //    //aa++;

    //    // movido para o 'draw()'
    //    // calculateResult();
    //}
    //
}

void PainterWidget::replotMap()
{
    // qDebug() << "PainterWidget::replotMap() not implemented";

    draw();

    /*
    QPainter p;

    foreach (Attributes *attrib, mapAttributes->values())
    {
        if (attrib->getType() != TObsAgent)
            visualMapping.drawAttrib(&p, attrib);
    }

    // movido para o 'draw()'
    // calculateResult();

    */
}

//void PainterWidget::setVectorPos(QVector<double> *xs, QVector<double> *ys)
//{
//    // visualMapping.setVectorPos(xs, ys);
//}

bool PainterWidget::rescale(const QSize &newSize)
{
    QImage img = QImage(resultImage.scaled(newSize/*,
    	Qt::IgnoreAspectRatio, Qt::SmoothTransformation*/));

    if (img.isNull())
    {
        QMessageBox::information(this, "TerraME :: Map",
                                 tr("This zoom level generated a null image."));
        return false;
    }

    resultImageBkp = img;

    update();
    return true;
}

void PainterWidget::paintEvent(QPaintEvent * /* event */)
{
    // if (resultImageBkp.isNull())
    //    return;

    QPainter painter(this);
    // painter.drawPixmap(QPoint(0, 0), QPixmap::fromImage(resultImageBkp));
    painter.drawImage(ZERO_POINT, resultImageBkp);

    if (!showRectZoom)
        return;

    //---- Desenha o retangulo de zoom
    QPen pen(Qt::DashDotLine);
    QBrush brush(Qt::Dense5Pattern);
    brush.setColor(Qt::white);

    painter.setPen(Qt::black);
    painter.setBrush(brush);
    painter.drawRect(QRect(imageOffset, lastDragPos));
}

void PainterWidget::resizeEvent(QResizeEvent *event)
{
    update();
    QWidget::resizeEvent(event);
}

void PainterWidget::resize(const QSize &newSize, const QSize &cellSize)
{
    if (size() == newSize)
        return;

    this->cellSize = cellSize;

    resultImage = QImage(newSize, QImage::Format_ARGB32_Premultiplied);
    resultImage.fill(0);
    resultImageBkp = resultImage;

    visualMapping->setSize(newSize, cellSize);
    QWidget::resize(newSize);
}

void PainterWidget::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
    {
        imageOffset = event->pos();

        if (zoomWindow)
        {
            showRectZoom = true;
            setCursor(zoomInCursor);
        }
        else if (handTool)
        {
            setCursor(Qt::ClosedHandCursor);
        }
    }
    else if (event->button() == Qt::RightButton)
    {
        if (zoomWindow)
            setCursor(zoomOutCursor);
    }
}

void PainterWidget::mouseMoveEvent(QMouseEvent *event)
{
    if (event->buttons() & Qt::LeftButton)
    {
        if (zoomWindow)
        {
            // Define as coordenadas do retangulo de zoom
            if (!rect().contains(QRect(imageOffset, event->pos())))
            {
                bool right = event->pos().x() > rect().right();
                bool left = event->pos().x() < rect().left();

                bool top = event->pos().y() < rect().top();
                bool bottom = event->pos().y() > rect().bottom();

                // x
                if (right)
                {
                    lastDragPos.setX(rect().right() - 1);
                    lastDragPos.setY(event->pos().y());
                }
                else if (left)
                {
                    lastDragPos.setX(rect().left());
                    lastDragPos.setY(event->pos().y());
                }

                // y
                if (top)
                {
                    lastDragPos.setY(0);
                    lastDragPos.setX(event->pos().x());
                }
                else if (bottom)
                {
                    lastDragPos.setY(rect().height() - 2);
                    lastDragPos.setX(event->pos().x());
                }
            }
            else
            {
                lastDragPos = event->pos();
            }
            update();
        }
        else if(handTool)
        {
            setCursor(Qt::ClosedHandCursor);
            lastDragPos = event->pos();

            int x = mParentScroll->horizontalScrollBar()->value()
                    - (lastDragPos.x() - imageOffset.x());
            int y = mParentScroll->verticalScrollBar()->value()
                    - (lastDragPos.y() - imageOffset.y());

            mParentScroll->horizontalScrollBar()->setValue(x);
            mParentScroll->verticalScrollBar()->setValue(y);
        }
    }
}

void PainterWidget::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
    {
        if (zoomWindow)
        {
            showRectZoom = false;

            setCursor(zoomWindowCursor);
            update();

            QRect zoomRect(imageOffset, lastDragPos);
            zoomRect = zoomRect.normalized();

            double factWidth = mParentScroll->size().width(); // resultImage.size().width();
            double factHeight = mParentScroll->size().height(); // resultImage.size().height();

            factWidth /= zoomRect.width();
            factHeight /= zoomRect.height();

            // Define o maior zoom como sendo 3200%
            factWidth = factWidth > 32.0 ? 32.0 : factWidth;
            factHeight = factHeight > 32.0 ? 32.0 : factHeight;

            // emite o sinal informando o tamanho do retangulo de zoom e
            // os fatores width e height
            emit zoomChanged(zoomRect, factWidth, factHeight);
        }
        else
        {
            if (handTool)
                setCursor(Qt::OpenHandCursor);
        }
    }
    else
    {
        if (event->button() == Qt::RightButton)
        {
            if (zoomWindow)
            {
                emit zoomOut();
                setCursor(zoomWindowCursor);
            }
        }
    }
}

void PainterWidget::setParentScroll(QScrollArea *scroll)
{
    mParentScroll = scroll;
}

void PainterWidget::setZoomWindow()
{
    zoomWindow = true;
    handTool = false;
    setCursor(zoomWindowCursor);
}

void PainterWidget::setHandTool()
{
    handTool = true;
    zoomWindow = false;
    setCursor(Qt::OpenHandCursor);
}

void PainterWidget::defineCursor(QCursor &cursor)
{
    zoomWindowCursor = cursor;
}

void PainterWidget::setPath(const QString & path)
{
    visualMapping->setPath(path);
}

int PainterWidget::close()
{
    // QWidget::close();
    // visualMapping.exit(0);
    return 0;
}

void PainterWidget::setExistAgent(bool exist)
{
    existAgent = exist;
}

bool PainterWidget::draw()
{
    BagOfTasks::TaskManager::getInstance().add(visualMapping);
    return true;
}

void PainterWidget::updateAttributeList()
{
    visualMapping->setAttributeList(mapAttributes->values());
}

void PainterWidget::displayImage(const QImage &result)
{
#ifdef TME_STATISTIC
    double t = 0;
    QString name;
    char block[30];
    sprintf(block, "%p", this);

    t = Statistic::getInstance().startMicroTime();

    resultImage = result; //.copy();
    resultImageBkp = resultImage.scaled(size(),
    		Qt::IgnoreAspectRatio, Qt::FastTransformation);

// see more information about this flag in VisualMapping.h
#ifdef TME_DRAW_VECTORIAL_AGENTS
    if (existAgent && visualMapping)
    {
        // qDebug() << "resultImageBkp.size() " << resultImageBkp.size()
        //      << "resultImage.size()" << resultImage.size();
        const QSize origSize = resultImage.size();
        visualMapping->drawAgent(resultImageBkp, origSize);

        foreach (Attributes *attrib, mapAttributes->values())
        {
        switch (attrib->getType())
        {
            default:
                break;

            case TObsSociety:
                if (attrib->getVisible())
                {
                    QPainter p;
                    visualMapping->mappingSociety(attrib, &p, resultImageBkp, origSize);
                }
        }
        }

        visualMapping->save(resultImageBkp);
    }
#endif // TME_DRAW_VECTORIAL_AGENTS

    update();

    // It processes the update event
    qApp->processEvents();

#ifdef DEBUG_OBSERVER
    static int g = 0;
    g++;
    resultImage.save(QString("result_%1.png").arg(g), "png");
#endif

    name = QString("display %1").arg(block);
    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime(name, t);

#else

    resultImage = result;
    resultImageBkp = resultImage.scaled(size(),
    		Qt::IgnoreAspectRatio, Qt::FastTransformation);

// see more information about this flag in VisualMapping.h
#ifdef TME_DRAW_VECTORIAL_AGENTS
    if (existAgent && visualMapping)
    {
        const QSize origSize = resultImage.size();
        visualMapping->drawAgent(resultImageBkp, origSize);

        foreach (Attributes *attrib, mapAttributes->values())
        {
        switch (attrib->getType())
        {
            default:
                break;

            case TObsSociety:
                if (attrib->getVisible())
                {
                    QPainter p;
                    visualMapping->mappingSociety(attrib, &p, resultImageBkp, origSize);
                }
            }
        }
        visualMapping->save(resultImageBkp);
    }
#endif // TME_DRAW_VECTORIAL_AGENTS

    update();

    // It processes the update event
    qApp->processEvents();

#endif

#ifdef DEBUG_OBSERVER
    if (result.isNull())
        qDebug() << ("result is NULL!!!");

    if (resultImage.isNull())
        qDebug() << ("resultImage is NULL!!!");

    if (resultImageBkp.isNull())
        qDebug() << ("resultImageBkp is NULL!!!");
#endif
}

