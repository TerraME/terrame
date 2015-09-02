#include "painterWidget.h"

#include <QPixmap>
#include <QPainter>
#include <QMetaType>
#include <QMessageBox>
#include <QScrollBar>
//#include <QRectF>
#include <QFile>
#include <QDebug>

#include "observerImpl.h"
#include "../legend/legendAttributes.h"

static const QString COMPLEMENT("000000");

using namespace TerraMEObserver;

PainterWidget::PainterWidget(QHash<QString, Attributes*> *mapAttrib, QWidget *parent)
    : mapAttributes(mapAttrib), QWidget(parent)
{
    // zoom
    handTool = false;
    zoomWindow = false;
    gridEnabled = false;

    heightProportion = 1.0;
    widthProportion = 1.0;

    countSave = 0;
    pixmapScale = 0.;
    curScale = 1.0;
    operatorMode = QPainter::CompositionMode_Multiply;

    zoomWindowCursor = QCursor(QPixmap(":icons/zoomWindow.png").scaled(ICON_SIZE));
    zoomInCursor = QCursor(QPixmap(":icons/zoomIn.png").scaled(ICON_SIZE));
    zoomOutCursor = QCursor(QPixmap(":icons/zoomOut.png").scaled(ICON_SIZE));

    resultImage = QImage(IMAGE_SIZE, QImage::Format_ARGB32_Premultiplied);

    setGeometry(0, 0, 1010, 1010);

    imageOffset = QPoint();
    showRectZoom = false;
    existAgent = false;

    // connect(this, SIGNAL(gridOn(bool)), &painterThread, SLOT(gridOn(bool)));
    painterThread.start();
}

PainterWidget::~PainterWidget()
{

}

void PainterWidget::calculateResult()
{
    resultImage.fill(0);
    QPainter painter(&resultImage);

    QPoint point(0, 0);

    // qDebug() << mapAttributes->keys();

    QList<Attributes *> attribs = mapAttributes->values();
    qStableSort(attribs.begin(), attribs.end(), sortAttribByType);

    foreach(Attributes * attrib, attribs)
    {
        if (attrib->getVisible() && (attrib->getType() != TObsAgent))
        {
            painter.fillRect(resultImage.rect(), Qt::white);

            if (attrib->getType() == TObsCell)
                painter.setCompositionMode(QPainter::CompositionMode_Multiply);
            else
			{
				//@RAIAN
				if(attrib->getType() == TObsNeighborhood)
					painter.setCompositionMode(QPainter::CompositionMode_SourceOver);
				else
				//@RAIAN: FIM
					painter.setCompositionMode(QPainter::CompositionMode_HardLight);
			}

            painter.drawImage(point, *attrib->getImage());
        }
    }

    painter.end();

    // resultImageBkp = QImage(resultImage.scaled(size(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation));
    resultImageBkp = QImage( resultImage.scaled(size()) );

    if (existAgent)
        drawAgent();
    
    if (gridEnabled)
        drawGrid();

    update();
}

void PainterWidget::setOperatorMode(QPainter::CompositionMode mode)
{
    operatorMode = mode;
}

void PainterWidget::plotMap(Attributes *attrib)
{
    if (! attrib)
        qFatal("\nErro: PainterWidget::plotMap - Invalid attribute!!\n");

    QPainter p;

    painterThread.drawAttrib(&p, attrib);
    calculateResult();
}

void PainterWidget::replotMap()
{
    QPainter p;

    QList<Attributes *> listAttribs = mapAttributes->values();

    for (int i = 0; i < listAttribs.size(); i++)
        painterThread.drawAttrib(&p, listAttribs.at(i));

    calculateResult();
}

//void PainterWidget::setVectorPos(QVector<double> *xs, QVector<double> *ys)
//{
//    // painterThread.setVectorPos(xs, ys);
//}

bool PainterWidget::rescale(QSize size)
{
    QImage img = QImage(resultImage.scaled(size/*, Qt::IgnoreAspectRatio, Qt::SmoothTransformation*/));

    if (img.isNull())
    {
        QMessageBox::information(this, "Map",
                                 tr("This zoom level generated a null image."));
        return false;
    }

    resultImageBkp = img;
    
    if (gridEnabled)
        drawGrid();

    update();
    return true;
}

void PainterWidget::paintEvent(QPaintEvent * /* event */)
{	
    QPainter painter(this);
    painter.drawPixmap(QPoint(0, 0), QPixmap::fromImage(resultImageBkp));
    
    // drawAgent();

    if (! showRectZoom)
        return;

    //---- Desenha o retangulo de zoom
    QPen pen(Qt::DashDotLine);
    QBrush brush(Qt::Dense5Pattern);
    brush.setColor(Qt::white);

    painter.setPen(Qt::black);
    painter.setBrush(brush);
    painter.drawRect(QRect(imageOffset, lastDragPos));
}

void PainterWidget::resizeEvent(QResizeEvent * /*event*/)
{
    // drawAgent();
}

void PainterWidget::resizeImage(const QSize &newSize)
{
    resultImage = QImage(newSize, QImage::Format_ARGB32_Premultiplied);
    resize(newSize);

    widthProportion = newSize.width() / SIZE_CELL;
    heightProportion = newSize.height() / SIZE_CELL;
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
            if (! rect().contains( QRect(imageOffset, event->pos()) ))
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

bool PainterWidget::save(const QString & path)
{
    countSave++;

    QString countString, aux;
    aux = COMPLEMENT;
    countString = QString::number(countSave);
    aux = aux.left(COMPLEMENT.size() - countString.size());
    aux.append(countString);

    QString name =  path + aux + ".png";
    return resultImageBkp.save(name);

    //// bool ret = resultImage.save(name);

    //// if (countSave == 1)
    //{
    //    // Salva o resultado em um PNG de 8 bits e em escala cinza.
    //    QImage imgTeste = resultImage.scaled(8193, 8193);
    //    // imgTeste.save(path + "teste.png");

    //    QImage retImg(imgTeste.width(), imgTeste.height(), QImage::Format_Indexed8);
    //    QVector<QRgb> table( 256 );
    //    for( int i = 0; i < 256; ++i )
    //        table[i] = qRgb(i, i, i);

    //    retImg.setColorTable(table);

    //    for(int i = 0; i < imgTeste.width(); i++)
    //    {
    //        for(int j = 0; j < imgTeste.height(); j++)
    //        {
    //            QRgb value = imgTeste.pixel(i, j);
    //            retImg.setPixel(i, j, qGray(value));
    //        }
    //    }
    //    return retImg.save(name); // path+ + "grayScale.png");
    //}
    ////return ret;
}

void PainterWidget::gridOn(bool on)
{
    gridEnabled = on;

    if (gridEnabled)
    {
        drawGrid();
        update();
    }
    else
    {
        calculateResult();
    }
}

void PainterWidget::drawGrid()
{
    double w = resultImageBkp.width() / widthProportion;
    double h = resultImageBkp.height() / heightProportion;

    painterThread.drawGrid(resultImageBkp, w, h);
}

void PainterWidget::drawAgent()
{
    QPainter painter(&resultImageBkp);

    double orig2destW = (double) resultImageBkp.width() / resultImage.width();
    double orig2destH = (double) resultImageBkp.height() / resultImage.height();
    
    double sizeCellPropW = orig2destW * SIZE_CELL;
    double sizeCellPropH = orig2destH * SIZE_CELL;

    QRectF rec, recCell;
    double x, y;

    recCell = QRectF(0 - sizeCellPropW * 0.5, 0 - sizeCellPropH * 0.5,
                     sizeCellPropW, sizeCellPropH);
    
    //recCell = QRectF(0 - SIZE_CELL * 0.5, 0 - SIZE_CELL * 0.5,
    //                 SIZE_CELL, SIZE_CELL);

    foreach(Attributes * attrib, mapAttributes->values())
    {
        if ((attrib->getType() == TObsAgent) && (attrib->getVisible()) )
        {
            QVector<ObsLegend> *vecLegend = attrib->getLegend();

            // TO-DO: Necessita otimiza??o
            if (attrib->getDataType() == TObsText)
            {
                QVector<QString> *values = attrib->getTextValues();

                for (int pos = 0; pos < values->size(); pos++)
                {
                    const QString & v = values->at(pos);

                    // Corrige o bug gerando quando um agente morre
                    if (attrib->getXsValue()->isEmpty() || attrib->getXsValue()->size() == pos)
                        break;

                    x = attrib->getXsValue()->at(pos) * SIZE_CELL;
                    y = attrib->getYsValue()->at(pos) * SIZE_CELL;

                    rec = QRectF( x * orig2destW , y * orig2destH, sizeCellPropW, sizeCellPropH);

                    painter.save();

                    for(int j = 0; j < vecLegend->size(); j++)
                    {
                        const ObsLegend &leg = vecLegend->at(j);
                        if (v == leg.getFrom())
                        {
                            painter.setPen(leg.getColor());
                            break;
                        }
                    }
                    painter.setFont(attrib->getFont());
                    painter.translate(rec.center());

                    // painter.rotate(attrib->getDirection(pos, x, y)); // future use issue #411

                    double xPos = recCell.x();
                    double yPos = -recCell.y();

                    int fontSize = attrib->getFont().pointSize();

                    if (fontSize == 1)
                    {
                        QFont font = attrib->getFont();
#ifdef Q_OS_MAC
                        font.setPixelSize((int)floor(recCell.width())*1.3334); // 1.333 == 96/72
#else
                        font.setPixelSize((int)floor(recCell.width()));
#endif
                        painter.setFont(font);
                    }
                    else if (fontSize <= recCell.height())
                    {
                        double range = floor(recCell.height() - fontSize);
                        double randx = ((double)qrand() / RAND_MAX) * range;
                        double randy = ((double)qrand() / RAND_MAX) * range;
                        xPos += randx;
                        yPos -= randy;
                    }
                    else
                    {
                        xPos = -fontSize * 0.5;
                        yPos = fontSize * 0.5;
                    }

                    QPointF position = QPointF(xPos, yPos);
                    painter.drawText(position, attrib->getSymbol());
                    painter.restore();
                }
            }
            else
            {
                QVector<double> *values = attrib->getNumericValues();

                for (int pos = 0; pos < values->size(); pos++)
                {
                    const double & v = values->at(pos);

                    // Corrige o bug gerando quando um agente morre
                    if (attrib->getXsValue()->isEmpty() || attrib->getXsValue()->size() == pos)
                        break;

                    x = attrib->getXsValue()->at(pos) * SIZE_CELL;
                    y = attrib->getYsValue()->at(pos) * SIZE_CELL;

                    rec = QRectF( x * orig2destW , y * orig2destH, sizeCellPropW, sizeCellPropH);

                    painter.save();

                    for(int j = 0; j < vecLegend->size(); j++)
                    {
                        const ObsLegend &leg = vecLegend->at(j);
                        if (v == leg.getFromNumber())
                        {
                            painter.setPen(leg.getColor());
                            break;
                        }
                    }
                    painter.setFont(attrib->getFont());
                    painter.translate(rec.center());

                    // painter.rotate(attrib->getDirection(pos, x, y)); // future use issue #411

                    double xPos = recCell.x();
                    double yPos = -recCell.y();

                    int fontSize = attrib->getFont().pointSize();

                    if (fontSize == 1)
                    {
                        QFont font = attrib->getFont();
                        font.setPointSize((int)floor(recCell.width()));
                        painter.setFont(font);
                    }
                    else if (fontSize < recCell.height())
                    {
                        double range = floor(recCell.height() - fontSize);
                        double rand = ((double)qrand() / RAND_MAX) * range;
                        xPos += rand;
                        yPos -= rand;
                    }
                    else
                    {
                        xPos = -fontSize * 0.5;
                        yPos = fontSize * 0.5;
                    }

                    QPointF position = QPointF(xPos, yPos);
                    painter.drawText(position, attrib->getSymbol());
                    painter.restore();
                }
            }
        }
    }
    painter.end();
}

int PainterWidget::close()
{
    // QWidget::close();
    painterThread.exit(0);
    return 0;
}

void PainterWidget::setExistAgent(bool exist)
{
    existAgent = exist;
}
