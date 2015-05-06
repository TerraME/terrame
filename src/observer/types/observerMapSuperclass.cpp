#include "observerMapSuperclass.h"

#include <QWheelEvent>
#include <QStringList>
#include <QApplication>
#include <QGraphicsView>
#include <QSplitter>
#include <QTreeWidgetItem>
#include <QTreeWidget>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QToolButton>
#include <QLabel>
#include <QFrame>
#include <QResizeEvent>
#include <QScrollBar>
#include <QLineEdit>
#include <QDebug>
#include <QMouseEvent>
#include <QMessageBox>

#include "canvas.h"
#include "decoder.h"
#include "observerMap.h"
#include "painterShapefile.h"

using namespace TerraMEObserver;

static const int DIMENSION = 77;

#include <QGraphicsRectItem>
#include <QGraphicsSceneDragDropEvent>

extern "C"
{
#include <lua.h>
}
#include "luna.h"

extern lua_State * L;

ObserverMapSuperclass::ObserverMapSuperclass(Subject *subj, const TypesOfObservers &obsType,
                                       const QString &windowTitle, QWidget *parent) : ObserverInterf(subj), QDialog(parent)
{
    observerType = obsType;
    subjectType = subj->getType(); // TO_DO: Changes it to Observer pattern

    setWindowTitle(windowTitle);
    setWindowFlags(Qt::Window);

    setupGUI();

    legendWindow = 0;
    buildLegend = 0;
    positionZoomVec = 0;
    offsetState = 0.0;

    mapAttributes = new QHash<QString, Attributes *>();

    protocolDecoder = new Decoder();// (mapAttributes);

    show();
}

ObserverMapSuperclass::~ObserverMapSuperclass()
{
    foreach(Attributes *attrib, mapAttributes->values())
        delete attrib;
    delete mapAttributes;

    delete protocolDecoder;
    delete legendWindow;

    delete zoomComboBox;
    delete butLegend;
    delete butZoomIn;
    delete butZoomOut;
    delete butZoomWindow;
    delete butHand;
    delete butZoomRestore;
    delete treeLayers;

    delete frameTools;
    delete view;
    delete scene;
}

void ObserverMapSuperclass::setupGUI(){
    resize(600, 400);

    scene = new QGraphicsScene(this);
    scene->setItemIndexMethod(QGraphicsScene::NoIndex);
    scene->setSceneRect(0, 0, 100, 200);

    view = new Canvas(scene, this);
    view->setCacheMode(QGraphicsView::CacheNone); // CacheBackground); //
    // view->setViewportUpdateMode(QGraphicsView::BoundingRectViewportUpdate); // SmartViewportUpdate) ; // FullViewportUpdate); does not exist in version 4.3.4
    // view->setRenderHints(QPainter::Antialiasing | QPainter::SmoothPixmapTransform);
    view->setRenderHint(QPainter::Antialiasing);
    // view->setTransformationAnchor(QGraphicsView::AnchorUnderMouse);
    // view->setFrameShape(QFrame::WinPanel);
    connect(view, SIGNAL(zoomOut()), this, SLOT(zoomOut()));

    // Frame Tools
    frameTools = new QFrame(this);
    frameTools->setGeometry(0, 0, 200, 500);

    butLegend = new QToolButton(frameTools);
    butLegend->setText(tr("legend"));
    butLegend->setIcon(QIcon(QPixmap(":/icons/legend.png")));
    butLegend->setGeometry(5, 5, 50, 20);
    butLegend->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    connect(butLegend, SIGNAL(clicked()), this, SLOT(butLegend_Clicked()));


    butZoomIn = new QToolButton(frameTools);
    butZoomIn->setText("In");
    butZoomIn->setIcon(QIcon(QPixmap(":/icons/zoomIn.png")));
    butZoomIn->setGeometry(5, 35, 20, 20);
    butZoomIn->setToolTip("Zoom in");
    butZoomIn->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    connect(butZoomIn, SIGNAL(clicked()), this, SLOT(butZoomIn_Clicked()));

    butZoomOut = new QToolButton(frameTools);
    butZoomOut->setText("Out");
    butZoomOut->setIcon(QIcon(QPixmap(":/icons/zoomOut.png")));
    butZoomOut->setGeometry(5, 65, 20, 20);
    butZoomOut->setToolTip("Zoom out");
    butZoomOut->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    connect(butZoomOut, SIGNAL(clicked()), this, SLOT(butZoomOut_Clicked()));

    butHand = new QToolButton(frameTools);
    butHand->setText("Pan");
    butHand->setIcon(QIcon(QPixmap(":/icons/hand.png")));
    butHand->setGeometry(5, 95, 20, 20);
    butHand->setToolTip("Pan");
    butHand->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    butHand->setCheckable(true);
    connect(butHand, SIGNAL(clicked()), this, SLOT(butHand_Clicked()));

    butZoomWindow = new QToolButton(frameTools);
    butZoomWindow->setText("Window");
    butZoomWindow->setIcon(QIcon(QPixmap(":/icons/zoomWindow.png")));
    butZoomWindow->setGeometry(5, 125, 20, 20);
    butZoomWindow->setToolTip("Zoom window");
    butZoomWindow->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    butZoomWindow->setCheckable(true);
    connect(butZoomWindow, SIGNAL(clicked()), this, SLOT(butZoomWindow_Clicked()));

    butZoomRestore = new QToolButton(frameTools);
    butZoomRestore->setText("Restore");
    butZoomRestore->setIcon(QIcon(QPixmap(":/icons/zoomRestore.png")));
    butZoomRestore->setGeometry(5, 155, 20, 20);
    butZoomRestore->setToolTip("Restore Zoom");
    butZoomRestore->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    //butZoomRestore->setCheckable(true);
    connect(butZoomRestore, SIGNAL(clicked()), this, SLOT(butZoomRestore_Clicked()));

    zoomVec << 3200 << 2400 << 1600 << 1200 << 800 << 700 << 600 << 500 << 400 << 300
        << 200 << 100 << 66 << 50 << 33 << 25 << 16  << 12 << 8 << 5 << 3 << 2 << 1;

    QStringList zoomList;

    for (int i = 0; i < zoomVec.size(); i++)
        zoomList.append(QString::number(zoomVec.at(i)) + "%");

    zoomList.append(WINDOW);

    zoomComboBox = new QComboBox(frameTools);
    zoomComboBox->addItems(zoomList);
    zoomComboBox->setGeometry(10, 95, 30, 20);
    zoomComboBox->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    zoomComboBox->setCurrentIndex(23); // window  //zoomIdx); //11);
    //zoomComboBox->setCurrentIndex(zoomIdx); //11);
    zoomComboBox->setEditable(true);
    connect(zoomComboBox, SIGNAL(activated(const QString &)), this, SLOT(zoomActivated(const QString &)));

    QHBoxLayout *hLayoutZoom1 = new QHBoxLayout();
    hLayoutZoom1->setMargin(5);

    QHBoxLayout *hLayoutZoom2 = new QHBoxLayout();
    hLayoutZoom2->setMargin(5);

    hLayoutZoom1->addWidget(butZoomIn);
    hLayoutZoom1->addWidget(butZoomOut);
    hLayoutZoom1->addWidget(butHand);
    hLayoutZoom2->addWidget(butZoomWindow);
    hLayoutZoom2->addWidget(butZoomRestore);    // Displays information layers
    treeLayers = new QTreeWidget(frameTools);
    treeLayers->setGeometry(5, 150, 190, 310);
    treeLayers->setHeaderLabel(tr("Layers"));

    connect(treeLayers, SIGNAL(itemClicked(QTreeWidgetItem *, int)),
        this, SLOT(treeLayers_itemChanged(QTreeWidgetItem *, int)));
    connect(treeLayers, SIGNAL(itemActivated(QTreeWidgetItem *, int)),
        this, SLOT(treeLayers_itemChanged(QTreeWidgetItem *, int)));

    //lblOperator = new QLabel(tr("Operations: "), frameTools);
    //lblOperator->setGeometry(10, 95, 150, 20);

    QVBoxLayout *layoutTools = new QVBoxLayout(frameTools);
    layoutTools->setMargin(5);

    QSpacerItem *verticalSpacer = new QSpacerItem(20, 50,  QSizePolicy::Minimum, QSizePolicy::Fixed);

    layoutTools->addWidget(butLegend);
    layoutTools->addItem(verticalSpacer);
    layoutTools->addWidget(zoomComboBox);
    layoutTools->addItem(hLayoutZoom1);
    layoutTools->addItem(hLayoutZoom2);
    // layoutTools->addWidget(lblOperator);
    // layoutTools->addWidget(operatorComboBox);
    layoutTools->addWidget(treeLayers);

    QSplitter *splitter = new QSplitter(this);
    splitter->setStyleSheet("QSplitter::handle{image: url(:/icons/splitter.png); QSplitter { width: 3px; }}");
    splitter->addWidget(frameTools);
    splitter->addWidget(view);
    splitter->setStretchFactor(0, 0);
    splitter->setStretchFactor(1, 1);

    QHBoxLayout *layoutDefault = new QHBoxLayout(this);
    layoutDefault->setMargin(5);

    layoutDefault->addWidget(splitter);
    setLayout(layoutDefault);
}

void ObserverMapSuperclass::zoomChanged(const QRectF &zoomRect, double width,
                                       double height)
{
    double ratio = scene->sceneRect().width() / scene->sceneRect().height();
    ratio *= scene->sceneRect().width();
    double percent = 0.0;

    if (width < height)
        percent = zoomRect.width() / ratio;
    else
        percent = zoomRect.height() / ratio;

    QString newZoom(QString::number(ceil(percent * 100)));
    int curr = zoomComboBox->findText(newZoom + "%");

#ifdef OBSERVER_DEBUG
    qDebug() << "zoomRect: " << zoomRect << " width: "  << width
       << " height: " << height;
    qDebug() << "curr: " << curr << " newZoom: " << newZoom
        << " percent: " << percent;
#endif

    if (curr >= 0)
    {
        zoomComboBox->setCurrentIndex(curr);
    }
    else
    {
        // FIX: the zoom scale is always the same, because the view is not rescaled

        zoomComboBox->setCurrentIndex(-1);
        //if (zoomComboBox->isEditable())
        zoomComboBox->lineEdit()->setText(newZoom + "%");

        QVector<int> zoomVecAux(zoomVec);
        zoomVecAux.push_back(newZoom.toInt());
        qStableSort(zoomVecAux.begin(), zoomVecAux.end(), qGreater<int>());
        positionZoomVec = zoomVecAux.indexOf(newZoom.toInt());
    }

    // Rescaling the view according to the rectangle zoomRect
    view->fitInView(zoomRect, Qt::KeepAspectRatio);
}


int ObserverMapSuperclass::convertZoomIndex(bool in)
{
    int idx = zoomComboBox->currentIndex();

    if (in)
    {
        if (idx >= 1)
        {
            idx = zoomComboBox->currentIndex() - 1;
            return idx;
        }
    }
    else
    {
        if (idx <= 22)
        {
            idx = zoomComboBox->currentIndex() + 1;
            return idx;
        }
    }
    return -1;
}

void ObserverMapSuperclass::zoomWindow()
{

    //// Sets the rectangle that surrounds all objects in the scene
    //double x = fstNode->pos().x() + fstNode->boundingRect().width() + 4;
    //double y = fstNode->pos().y() - offsetState * 0.25;
    //QSizeF size(lstNode->pos().x() + lstNode->boundingRect().right() - offsetState * 0.66, offsetState);

    // QRectF zoomRect(view->mapFromScene(x, y), size);
    QRectF zoomRect(scene->sceneRect());

    double factWidth = view->viewport()->rect().width() - 1;
    double factHeight = view->viewport()->rect().height() - 1;

    factWidth /= zoomRect.width() - 1;
    factHeight /= zoomRect.height() - 1;

    // Sets the most zoom as 3200%
    factWidth = factWidth > 32.0 ? 32.0 : factWidth;
    factHeight = factHeight > 32.0 ? 32.0 : factHeight;

    zoomChanged(zoomRect, factWidth, factHeight);
    //// view->centerOn(zoomRect.center());  // is not centered
    //// view->centerOn(scene->itemsBoundingRect().center());  // is not centered
    // view->centerOn(scene->sceneRect().center()); // is almost centralized
    view->centerOn(center);
    zoomComboBox->setCurrentIndex(zoomComboBox->findText(WINDOW));


#ifdef OBSEVER_DEBUG
    //qDebug() << "\nx: " << x << " y: " << y << " size: " << size;
    qDebug() << "\nscene->sceneRect(): " << scene->sceneRect()
        << " == view->sceneRect(): " << view->sceneRect();

    qDebug() << "view->viewport(): " << view->viewport()->rect();
    qDebug() << "view->rect(): " << view->rect();
    qDebug() << "zoomRect: " << zoomRect;
    // qDebug() << "size: " << size;
    qDebug() << "offsetState: " << offsetState;
    qDebug() << "lstNode->boundingRect().height(): " << lstNode->boundingRect().height();
    qDebug() << "center: " << center;
    qDebug() << "node: " << lstNode->pos().x() + lstNode->boundingRect().width()
        << "; " << fstNode->pos().x() + fstNode->boundingRect().width();
    qDebug() << "center 2: " << lstNode->pos().x() << " + " <<  lstNode->boundingRect().width()
         << " - " <<  fstNode->pos().x() << " + " <<  fstNode->boundingRect().height()
         << " = " << (lstNode->pos().x() + lstNode->boundingRect().width())
         - (fstNode->pos().x() + fstNode->boundingRect().height());
    qDebug() << "center 3: " << scene->itemsBoundingRect().center();

    //qDebug() << factWidth << "; " << factHeight;
    //qDebug() << "scrollH: " << view->horizontalScrollBar()->value();

    static bool criado = false;
    if (!criado){
        criado = true;
        RectItemDebug *rectItem = 0;

        // scene->setSceneRect(QRectF(zoomRect.topLeft() + QPoint(-1, -1), zoomRect.bottomRight() + QPoint(2, 1)));
        // scene->setSceneRect(scene->sceneRect());

        rectItem = new RectItemDebug(zoomRect);
        scene->addItem(rectItem);

        //rectItem = new RectItemDebug(QRectF(center + QPointF(-1, -1),
        //    center + QPointF(1, 1)), Qt::darkCyan);
        //scene->addItem(rectItem);

        //rectItem = new RectItemDebug(QRectF(scene->itemsBoundingRect().center() + QPointF(-1, -1),
        //    scene->itemsBoundingRect().center() + QPointF(1, 1)), Qt::red);
        //scene->addItem(rectItem);

        //rectItem = new RectItemDebug(scene->itemsBoundingRect(), Qt::blue);
        //scene->addItem(rectItem);

        rectItem = new RectItemDebug(scene->sceneRect(), Qt::darkGray);
        scene->addItem(rectItem);
    }
#endif
}

void ObserverMapSuperclass::butLegend_Clicked()
{
    if (legendWindow->exec())
        showLayerLegend();
    repaint();
}

void ObserverMapSuperclass::butZoomIn_Clicked()
{
    positionZoomVec = max(positionZoomVec - 1, 0);
    zoomComboBox->setCurrentIndex(positionZoomVec);
    zoomActivated(zoomComboBox->currentText());
}

void ObserverMapSuperclass::butZoomOut_Clicked()
{
    positionZoomVec = min(positionZoomVec + 1, 22);
    zoomComboBox->setCurrentIndex(positionZoomVec);
    zoomActivated(zoomComboBox->currentText());
}

void ObserverMapSuperclass::butZoomWindow_Clicked()
{
    QMessageBox::information(this, windowTitle(), "Do not implemented!");
    //view->setDragMode(QGraphicsView::NoDrag);

    //view->setWindowCursor();
    //butZoomWindow->setChecked(true);
    //butHand->setChecked(false);
}

void ObserverMapSuperclass::butZoomRestore_Clicked()
{
    if (zoomComboBox->currentText() == WINDOW)		// zoom in Window
       return;

     zoomComboBox->setCurrentIndex(zoomComboBox->findText(WINDOW));
     zoomActivated(WINDOW);

    // zoomWindow();
}

void ObserverMapSuperclass::butHand_Clicked()
{
    view->setPanCursor();
    butHand->setChecked(true);
    butZoomWindow->setChecked(false);
}


void ObserverMapSuperclass::zoomOut()
{
    zoomComboBox->setCurrentIndex(zoomComboBox->currentIndex() + 1);
    QString scale(zoomComboBox->currentText());
    zoomActivated(scale);
}

void ObserverMapSuperclass::zoomActivated(const QString & scale)
{
    if (scale == WINDOW)
    {
        zoomWindow();
        return;
    }
    qreal newScale = scale.left(scale.indexOf(tr("%"))).toDouble() * 0.01;
    scaleView(newScale);
}

void ObserverMapSuperclass::wheelEvent(QWheelEvent * /*event*/)
{
    //scaleView(pow(2.0, -event->delta() / 240.0));

    // qDebug() << "scaleFactor: " << event->delta();
}

void ObserverMapSuperclass::scaleView(qreal newScale)
{
    QMatrix oldMatrix = view->matrix();
    view->resetMatrix();
    view->translate(oldMatrix.dx(), oldMatrix.dy());
    view->scale(newScale, newScale);

    //view->horizontalScrollBar()->setValue(0);
    //view->verticalScrollBar()->setValue(0);
}

void ObserverMapSuperclass::resizeEvent(QResizeEvent * /*ev*/)
{
    if (zoomComboBox->currentText() == WINDOW)
        zoomWindow();

    //QWidget::resizeEvent(ev);
}

void ObserverMapSuperclass::setAttributes(QStringList &attribs, QStringList legKeys,
                                         QStringList legAttribs)
{
    connectTreeLayerSlot(false);

    bool complexMap = false;

    // list of attributes that will be observed
    //itemList = headers;
    if (attribList.isEmpty())
    {
        attribList << attribs;
    }
    else
    {
        complexMap = true;

        foreach(const QString & str, attribs)
        {
            if (! attribList.contains(str))
                attribList.append(str);
        }
    }
    attribList = attribs;

    for (int j = 0; (legKeys.size() > 0 && j < LEGEND_KEYS.size()); j++)
    {
        if (legKeys.indexOf(LEGEND_KEYS.at(j)) < 0)
        {
			string err_out = string("Error: Parameter legend") + LEGEND_KEYS.at(j).toLatin1().data() + string(" not found. ") +
					string("Please check it in the model.");
			lua_getglobal(L, "customErrorMsg");
			lua_pushstring(L, err_out.c_str());
			lua_pushnumber(L, 5);
			lua_call(L, 2, 0);
			//return 0;
			break;
        }
    }

    int type = legKeys.indexOf(TYPE);
    int mode = legKeys.indexOf(GROUP_MODE);
    int slices = legKeys.indexOf(SLICES);
    int precision = legKeys.indexOf(PRECISION);
    int stdDeviation = legKeys.indexOf(STD_DEV);
    int max = legKeys.indexOf(MAX);
    int min = legKeys.indexOf(MIN);
    int colorBar = legKeys.indexOf(COLOR_BAR);
    int font = legKeys.indexOf(FONT_FAMILY);
    int fontSize = legKeys.indexOf(FONT_SIZE);
    int symbol = legKeys.indexOf(SYMBOL);

    QTreeWidgetItem *item = 0;
    Attributes *attrib = 0;
    int hasObjectId = 0;
    for(int i = 0; i < attribList.size(); i++)
    {
        if(attribList.at(i) == QString("objectId_")) hasObjectId++;
        //qDebug() << "------------------" << attribList.at(i) << " " << hasObjectId;
        if (((! mapAttributes->contains(attribs.at(i)))
                && (attribList.at(i) != QString("x"))
                && (attribList.at(i) != QString("y"))
                && (attribList.at(i) != QString("objectId_")))
            || (!mapAttributes->contains(attribList.at(i))
                && (hasObjectId > 1)
                && (attribList.at(i) == QString("objectId_"))))
        {
            obsAttrib.append(attribList.at(i));
            attrib = new Attributes(attribList.at(i), 2, 2, TObsCell); // TO-DO: Should be the dimension of space
            attrib->setVisible(true);

            //------- Retrieves the legend from the file and creates the object attrib
            if (legKeys.size() > 0)
            {
                attrib->setDataType((TypesOfData) legAttribs.at(type).toInt());
                attrib->setGroupMode((GroupingMode) legAttribs.at(mode).toInt());
                attrib->setSlices(legAttribs.at(slices).toInt() - 1);				// conta com o zero
                attrib->setPrecisionNumber(legAttribs.at(precision).toInt() - 1);	// conta com o zero
                attrib->setStdDeviation((StdDev) legAttribs.at(stdDeviation).toInt());
                attrib->setMaxValue(legAttribs.at(max).toDouble());
                attrib->setMinValue(legAttribs.at(min).toDouble());

                //Font
                attrib->setFontFamily(legAttribs.at(font));
                attrib->setFontSize(legAttribs.at(fontSize).toInt());

                // Converts the ASCII code of the symbol to character
                bool ok = false;
                int asciiCode = legAttribs.at(symbol).toInt(&ok, 10);
                if (ok)
                    attrib->setSymbol(QString(QChar(asciiCode)));
                else
                    attrib->setSymbol(legAttribs.at(symbol));

                std::vector<ColorBar> colorBarVec;
                std::vector<ColorBar> stdColorBarVec;
                QStringList labelList, valueList;

                ObserverMap::createColorsBar(legAttribs.at(colorBar),
                    colorBarVec, stdColorBarVec, valueList, labelList);

                attrib->setColorBar(colorBarVec);
                attrib->setStdColorBar(stdColorBarVec);
                attrib->setValueList(valueList);
                attrib->setLabelList(labelList);

                // Removes the legend items retrieved
                for(int j = 0; j < LEGEND_ITENS; j++)
                {
                    legKeys.removeFirst();
                    legAttribs.removeFirst();
                }
            }

            mapAttributes->insert(attribList.at(i), attrib);
            attrib->makeBkp();

            item = new QTreeWidgetItem(treeLayers);
            item->setText(0, attribs.at(i));
            item->setCheckState(0, Qt::Checked);

            if ((complexMap) && (treeLayers->topLevelItemCount() > 1))
            {
                item = treeLayers->takeTopLevelItem(treeLayers->topLevelItemCount() - 1);
                treeLayers->insertTopLevelItem(0, item);
                item->setExpanded(true);
            }
        }
    }

    //if(!hasObsId) obsAttrib.append("objectId_");

    if (! legendWindow)
        legendWindow = new LegendWindow(this);
    legendWindow->setValues(mapAttributes, obsAttrib);

    zoomWindow();

    connectTreeLayerSlot(true);
}

QStringList ObserverMapSuperclass::getAttributes()
{
    return attribList;
}

const TypesOfObservers ObserverMapSuperclass::getType() const
{
    return observerType;
}

void ObserverMapSuperclass::connectTreeLayerSlot(bool on)
{
    // connects/disconnects the treeWidget signal with the slot
    if (! on)
    {
        QWidget::disconnect(treeLayers, SIGNAL(itemChanged(QTreeWidgetItem *, int)),
            this, SLOT(treeLayers_itemChanged(QTreeWidgetItem *, int)));
    }
    else
    {
        QWidget::connect(treeLayers, SIGNAL(itemChanged(QTreeWidgetItem *, int)),
            this, SLOT(treeLayers_itemChanged(QTreeWidgetItem *, int)));
    }
}

void ObserverMapSuperclass::treeLayers_itemChanged(QTreeWidgetItem * item, int /*column*/)
{
    if (obsAttrib.size() == 0)
        return;

    Attributes * attrib = mapAttributes->value(item->text(0));
    if (attrib)
    {
        attrib->setVisible((item->checkState(0) == Qt::Checked) ? true : false);
        //painterWidget->calculateResult();
        //update();
        //QWidget::update();
        //scene->update();
    }
}

int ObserverMapSuperclass::close()
{
    QDialog::close();
    return 0;
}
