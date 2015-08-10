#include "observerStateMachine.h"

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

#include <math.h>

#include "../components/canvas.h"
#include "../protocol/decoder/decoder.h"
#include "stateMachine/edge.h"
#include "stateMachine/node.h"
#include "observerMap.h"

using namespace TerraMEObserver;

static const int DIMENSION = 77;

#include <QGraphicsRectItem>
#include <QGraphicsSceneDragDropEvent>

//#include <QApplication>
//#include <time.h>
//
//void wait ( int seconds )
//{
//    clock_t endwait;
//    endwait = clock () + seconds * CLOCKS_PER_SEC ;
//    while (clock() < endwait)
//        qApp->processEvents();
//}

bool sortByXPosition(const QGraphicsItem *i1, const QGraphicsItem *i2)
{
    return (i1->pos().x() < i2->pos().x());
}

bool sortByYPosition(const QGraphicsItem *i1, const QGraphicsItem *i2)
{
    return (i1->pos().y() < i2->pos().y());
}

ObserverStateMachine::ObserverStateMachine(Subject *subj, QWidget *parent)
    : ObserverInterf(subj), QDialog(parent)
{
    observerType = TObsStateMachine;
    subjectType = TObsUnknown;

    setWindowTitle("TerraME Observer : StateMachine");
    setWindowFlags(Qt::Window);

    setupGUI();

    legendWindow = 0;
    buildLegend = 0;
    positionZoomVec = 0;
    offsetState = 0.0;

    states = new QHash<QString, Node *>;
    mapAttributes = new QHash<QString, Attributes *>();

    protocolDecoder = new Decoder(mapAttributes);

    show();
}

ObserverStateMachine::~ObserverStateMachine()
{
    foreach (Node *node, *states)
        delete node;
    delete states;

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
    // delete lblOperator;
    delete treeLayers;

    delete frameTools;
    delete view;
    delete scene;
}

bool ObserverStateMachine::draw(QDataStream &state)
{
    QString msg;
    state >> msg;

    QStringList tokens = msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);

    //QString subjectId = tokens.at(0);
    //int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    // int nroElems = tokens.at(3).toInt();

    QString key, textAux;
    // int typeOfData = 0;
    int j = 4;
    Attributes *attrib = 0;

    for (int i=0; i < qtdParametros; i++)
    {
        key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        bool contains = attribList.contains(key);

        switch (typeOfData)
        {
        case (TObsText):
            {
                textAux = tokens.at(j);

                if (contains)
                {
                    QStringList stateKeys = states->keys();
                    for (int i = 0; i < stateKeys.size(); i++)
                    {
                        Node *node = states->value(stateKeys.at(i));
                        if (textAux == stateKeys.at(i))
                            node->setActive(true);
                        else
                            node->setActive(false);
                    }
                    attrib = mapAttributes->value(key);

                    if (attrib->getDataType() == TObsUnknownData)
                        attrib->setDataType(TObsText);

                    attrib->addValue(textAux);
                }
                break;
            }

        default:
            break;
        }
    }

    // wait(2, qApp);

    if ((legendWindow) && (buildLegend <= 2 )) // (buildLegend <= states->size() )) //
    {
        legendWindow->makeLegend();
        showLayerLegend();

        zoomWindow();
        buildLegend++;
    }

    scene->update(scene->sceneRect());
    qApp->processEvents();

    return true;
}

void ObserverStateMachine::setAttributes(QStringList &attribs, QStringList legKeys,
                                         QStringList legAttribs)
{
    attribList = attribs;

    for (int j = 0; (legKeys.size() > 0 && j < LEGEND_KEYS.size()); j++)
    {
        if (legKeys.indexOf(LEGEND_KEYS.at(j)) < 0)
        {
            qFatal("Error: Parameter legend \"%s\" not found. "
                "Please check it in the model.", qPrintable( LEGEND_KEYS.at(j) ) );
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
    for( int i = 0; i < attribs.size(); i++)
    {
        if ((! mapAttributes->contains(attribs.at(i)))
            && (attribs.at(i) != QString("x")) && (attribs.at(i) != QString("y")) )
        {
            obsAttrib.append(attribs.at(i));
            attrib = new Attributes(attribs.at(i), 2, 0, 0); // states->size(), 0, 0);

            //------- Recupera a legenda do arquivo e cria o objeto attrib
            if (legKeys.size() > 0)
            {
                attrib->setDataType( (TypesOfData) legAttribs.at(type).toInt());
                attrib->setGroupMode( (GroupingMode) legAttribs.at(mode ).toInt());
                attrib->setSlices(legAttribs.at(slices).toInt() - 1);				// conta com o zero
                attrib->setPrecisionNumber(legAttribs.at(precision).toInt() - 1);	// conta com o zero
                attrib->setStdDeviation( (StdDev) legAttribs.at(stdDeviation ).toInt());
                attrib->setMaxValue(legAttribs.at(max).toDouble());
                attrib->setMinValue(legAttribs.at(min).toDouble());

                //Fonte
                attrib->setFontFamily(legAttribs.at(font));
                attrib->setFontSize(legAttribs.at(fontSize).toInt());

                //Converte o c?digo ASCII do s?mbolo em caracter
                bool ok = false;
                int asciiCode = legAttribs.at(symbol).toInt(&ok, 10);
                if (ok)
                    attrib->setSymbol( QString( QChar(asciiCode) ));
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
            }

            mapAttributes->insert(attribs.at(i), attrib);

            item = new QTreeWidgetItem(treeLayers);
            item->setText(0, attribs.at(i));
            // item->setCheckState(0, Qt::Checked);
        }
    }

    if (! legendWindow)
        legendWindow = new LegendWindow(this);
    legendWindow->setValues(mapAttributes);
}

QStringList ObserverStateMachine::getAttributes()
{
    return attribList;
}

const TypesOfObservers ObserverStateMachine::getType()
{
    return observerType;
}

void ObserverStateMachine::addState(QList<QPair<QString, QString> > &allStates)
{
    Node *nodeSource = 0, *nodeDest = 0;
    offsetState = DIMENSION * 2;

    // Valores para o posicionamento do estados
    // no centro do objeto view
    int resizeHeight = allStates.size();
    if (allStates.size() % 2 == 0)
        resizeHeight = allStates.size() - 1;

    scene->setSceneRect(0, 0, offsetState * allStates.size() - DIMENSION,
        DIMENSION * resizeHeight);
    center = scene->sceneRect().center();

    float yPos = scene->sceneRect().center().y();

    for (int i = 0; i < allStates.size(); i++)
    {
        QString stateName = allStates.at(i).first;
        nodeSource = new Node(stateName);
        nodeSource->setPos(40 + offsetState * i, yPos);

        // Adiciona  o nodo na cena
        scene->addItem(nodeSource);

        // Armazena no hash
        states->insert(stateName, nodeSource);
    }

    nodeSource = 0;
    nodeDest = 0;

    for(int i = 0; i < allStates.size(); i++)
    {
        // recupero novamente os estados j? criados
        if (states->contains(allStates.at(i).first))
            nodeSource = states->value(allStates.at(i).first);

        if (states->contains(allStates.at(i).second))
            nodeDest = states->value(allStates.at(i).second);

        if ((nodeSource) && (nodeDest))
            scene->addItem(new Edge(nodeSource, nodeDest));
    }
}

void ObserverStateMachine::butLegend_Clicked()
{
    if (legendWindow->exec())
        showLayerLegend();
}

void ObserverStateMachine::showLayerLegend()
{
    int layer = treeLayers->topLevelItemCount();

    QTreeWidgetItem *parent = 0, *child = 0;
    Attributes *attrib = 0;
    QVector<ObsLegend> *leg = 0;
    for(int i = 0; i < layer; i++)
    {
        parent = treeLayers->topLevelItem(i);
        treeLayers->setItemExpanded(parent, true);
        attrib = mapAttributes->value(parent->text(0));

        leg = attrib->getLegend();

        if (parent->childCount() > 0)
            parent->takeChildren();

        for(int j = 0; j < leg->size(); j++)
        {
            if (states->contains(leg->at(j).getLabel()) )
            {
                child = new QTreeWidgetItem( parent);
                child->setSizeHint(0, ICON_SIZE);
                child->setText(0, leg->at(j).getLabel());
                QColor color = leg->at(j).getColor();

                if (! leg->at(j).getLabel().contains("mean"))
                    child->setData(0, Qt::DecorationRole,
                    legendWindow->color2Pixmap(color, ICON_SIZE));
                else
                    child->setData(0, Qt::DecorationRole, QString(""));

                // Define as cores dos estados
                Node *node = states->value(leg->at(j).getLabel());
                node->setColor(color);
                node->update(node->boundingRect());
            }
        }

    }
    treeLayers->resizeColumnToContents(0);
}

void ObserverStateMachine::wheelEvent(QWheelEvent * /*event*/)
{
    //scaleView(pow(2.0, -event->delta() / 240.0));

    // qDebug() << "scaleFactor: " << event->delta();
}

void ObserverStateMachine::scaleView(qreal newScale)
{
    QMatrix oldMatrix = view->matrix();
    view->resetMatrix();
    view->translate(oldMatrix.dx(), oldMatrix.dy());
    view->scale(newScale, newScale);

    //view->horizontalScrollBar()->setValue(0);
    //view->verticalScrollBar()->setValue(0);
}

void ObserverStateMachine::butZoomIn_Clicked()
{
    // currentIndex() < 0 : o indice n?o existe no comboBox
    // currentIndex() > 22 : o indice ? o zoom de janela
    // if ((zoomComboBox->currentIndex() < 0) || (zoomComboBox->currentIndex() > 22))
    if ((zoomComboBox->currentIndex() > 0)) // || (zoomComboBox->currentIndex() < 22))
    {
        positionZoomVec--;
        zoomComboBox->setCurrentIndex(positionZoomVec);
        zoomActivated(zoomComboBox->currentText());
    }

    //if ((zoomComboBox->currentIndex() < 0) || (zoomComboBox->currentIndex() > 22))
    ////         zoomComboBox->setCurrentIndex(positionZoomVec);
    //    zoomComboBox->setCurrentIndex(calculeZoom(true));
}

void ObserverStateMachine::butZoomOut_Clicked()
{
    // qDebug() << "zoomComboBox->currentIndex(): " << zoomComboBox->currentIndex();

    if ((zoomComboBox->currentIndex() <= 23)) // || (zoomComboBox->currentIndex() > 0))
    //if ((zoomComboBox->currentIndex() < 0) || (zoomComboBox->currentIndex() > 22))
    {
        positionZoomVec++;
        zoomComboBox->setCurrentIndex(positionZoomVec);
        zoomActivated(zoomComboBox->currentText());
    }

    //if ((zoomComboBox->currentIndex() < 0) || (zoomComboBox->currentIndex() > 22))
    //{
    //    // positionZoomVec--;
    //    // zoomComboBox->setCurrentIndex(positionZoomVec);
    //    zoomComboBox->setCurrentIndex(calculeZoom(false));
    //}
}

void ObserverStateMachine::butZoomWindow_Clicked()
{
    QMessageBox::information(this, windowTitle(), "Do not implemented!");
    //view->setDragMode(QGraphicsView::NoDrag);

    //view->setWindowCursor();
    //butZoomWindow->setChecked(true);
    //butHand->setChecked(false);
}

void ObserverStateMachine::butZoomRestore_Clicked()
{
    if (zoomComboBox->currentText() == WINDOW)		// zoom em Window
       return;

     zoomComboBox->setCurrentIndex(zoomComboBox->findText(WINDOW));
     zoomActivated(WINDOW);

    // zoomWindow();
}

void ObserverStateMachine::butHand_Clicked()
{
    view->setPanCursor();

    butHand->setChecked(true);
    butZoomWindow->setChecked(false);
}

void ObserverStateMachine::zoomActivated(const QString & scale)
{
    if (scale == WINDOW)
    {
        zoomWindow();
        return;
    }
    qreal newScale = scale.left(scale.indexOf(tr("%"))).toDouble() * 0.01;
    scaleView(newScale);
}

void ObserverStateMachine::resizeEvent(QResizeEvent * /*ev*/)
{
    if (zoomComboBox->currentText() == WINDOW)
        zoomWindow();

    //QWidget::resizeEvent(ev);
}

void ObserverStateMachine::zoomWindow()
{

    //// Define o retangulo que envolve todos os objetos da cena
    //float x = fstNode->pos().x() + fstNode->boundingRect().width() + 4;
    //float y = fstNode->pos().y() - offsetState * 0.25;
    //QSizeF size(lstNode->pos().x() + lstNode->boundingRect().right() - offsetState * 0.66, offsetState);

    // QRectF zoomRect(view->mapFromScene(x, y), size);
    QRectF zoomRect(scene->sceneRect());

    double factWidth = view->viewport()->rect().width() - 1;
    double factHeight = view->viewport()->rect().height() - 1;

    factWidth /= zoomRect.width() - 1;
    factHeight /= zoomRect.height() - 1;

    // Define o maior zoom como sendo 3200%
    factWidth = factWidth > 32.0 ? 32.0 : factWidth;
    factHeight = factHeight > 32.0 ? 32.0 : factHeight;

    zoomChanged(zoomRect, factWidth, factHeight);
    //// view->centerOn(zoomRect.center());  // n?o fica centralizado
    //// view->centerOn( scene->itemsBoundingRect().center() );  // n?o fica centralizado
    // view->centerOn(scene->sceneRect().center()); // fica quase centralizado
    view->centerOn(center);
    zoomComboBox->setCurrentIndex(zoomComboBox->findText(WINDOW));
}

void ObserverStateMachine::zoomChanged(const QRectF &zoomRect, float width,
                                       float height)
{
    float ratio = scene->sceneRect().width() / scene->sceneRect().height();
    ratio *= scene->sceneRect().width();
    float percent = 0.0;
    
    if (width < height)
        percent = zoomRect.width() / ratio;
    else
        percent = zoomRect.height() / ratio;

    QString newZoom(QString::number(ceil(percent * 100)));
    int curr = zoomComboBox->findText(newZoom + "%");

    if (curr >= 0)
    {
        zoomComboBox->setCurrentIndex(curr);
    }
    else
    {
        // FIX: a escala de zoom ? sempre a mesma, pq o view n?o ? rescalado

        zoomComboBox->setCurrentIndex(-1);
        //if (zoomComboBox->isEditable())
        zoomComboBox->lineEdit()->setText(newZoom + "%");

        QVector<int> zoomVecAux(zoomVec);
        zoomVecAux.push_back(newZoom.toInt());
        qStableSort(zoomVecAux.begin(), zoomVecAux.end(), qGreater<int>());
        positionZoomVec = zoomVecAux.indexOf(newZoom.toInt());
    }

    // Rescala o view de acordo como o retangulo zoomRect
    view->fitInView(zoomRect, Qt::KeepAspectRatio);
}

int ObserverStateMachine::convertZoomIndex(bool in)
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

void ObserverStateMachine::zoomOut()
{
    zoomComboBox->setCurrentIndex(zoomComboBox->currentIndex() + 1);
    QString scale(zoomComboBox->currentText());
    zoomActivated(scale);
}

//void ObserverStateMachine::connectTreeLayer(bool connect)
//{
//    // conecta/disconecta o sinal do treeWidget com o slot
//    if (! connect)
//    {
//        disconnect(treeLayers, SIGNAL(itemChanged( QTreeWidgetItem *, int )), 
//            this, SLOT(treeLayers_itemChanged( QTreeWidgetItem *, int ) ));
//    }
//    else
//    {
//        QWidget::connect(treeLayers, SIGNAL(itemChanged( QTreeWidgetItem *, int )), 
//            this, SLOT(treeLayers_itemChanged( QTreeWidgetItem *, int ) ));
//    }
//}

void ObserverStateMachine::setupGUI()
{
    resize(600, 400);

    scene = new QGraphicsScene(this);
    scene->setItemIndexMethod(QGraphicsScene::NoIndex);
    scene->setSceneRect(0, 0, 100, 200);

    view = new Canvas(scene, this);
    view->setCacheMode(QGraphicsView::CacheNone); // CacheBackground); // 
    // view->setViewportUpdateMode(QGraphicsView::BoundingRectViewportUpdate); // SmartViewportUpdate) ; // FullViewportUpdate); n?o existe na vers?o 4.3.4
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
        zoomList.append( QString::number(zoomVec.at(i)) + "%");

    zoomList.append(WINDOW);

    zoomComboBox = new QComboBox(frameTools);
    zoomComboBox->addItems(zoomList);
    zoomComboBox->setGeometry(10, 95, 30, 20);
    zoomComboBox->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    zoomComboBox->setCurrentIndex(23); // window  //zoomIdx); //11);
    //zoomComboBox->setCurrentIndex(zoomIdx); //11);
    zoomComboBox->setEditable(true);
    connect(zoomComboBox, SIGNAL(activated(const QString & )), this, SLOT(zoomActivated(const QString &)));

    QHBoxLayout *hLayoutZoom1 = new QHBoxLayout();
    hLayoutZoom1->setMargin(5);

    QHBoxLayout *hLayoutZoom2 = new QHBoxLayout();
    hLayoutZoom2->setMargin(5);

    hLayoutZoom1->addWidget(butZoomIn);
    hLayoutZoom1->addWidget(butZoomOut);
    hLayoutZoom1->addWidget(butHand);
    hLayoutZoom2->addWidget(butZoomWindow);
    hLayoutZoom2->addWidget(butZoomRestore);    // Exibe os layers de informa??o
    treeLayers = new QTreeWidget(frameTools);
    treeLayers->setGeometry(5, 150, 190, 310);
    treeLayers->setHeaderLabel(tr("Layers"));

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

