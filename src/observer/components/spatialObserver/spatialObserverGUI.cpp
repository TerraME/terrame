#include "spatialObserverGUI.h"
#include "ui_spatialObserverGUI.h"

#include <QToolBar>
#include <QAction>
#include <QToolButton>
#include <QComboBox>
#include <QActionGroup>
#include <QGraphicsScene>

static const QString WINDOW = "Window";

SpatialObserverGUI::SpatialObserverGUI(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::spatialObserverGUI)
{
    setWindowFlags(Qt::Window);
    ui->setupUi(this);

    scene = new QGraphicsScene();
    scene->setSceneRect(-100, -100, 200, 200);

    ui->canvas->setRenderHint(QPainter::Antialiasing);
    ui->canvas->setScene(scene);
    ui->canvas->setPanCursor();// Changes the canvas cursor

    setupToolBars();
}

SpatialObserverGUI::~SpatialObserverGUI()
{
    delete ui;
    delete scene;
}

void SpatialObserverGUI::legendClicked()
{
}

void SpatialObserverGUI::gridClicked()
{
}

void SpatialObserverGUI::zoomInClicked()
{
}

void SpatialObserverGUI::zoomOutClicked()
{
}

void SpatialObserverGUI::setupToolBars()
{
    toolBar = new QToolBar(this);
    toolBar->setIconSize(QSize(20, 20));

    actLegend = toolBar->addAction("Legend");
    actLegend->setToolTip("Shows the legend dialog");
    actLegend->setIcon(QIcon(":/icons/legend.png"));

    actGrid = toolBar->addAction("Grid");
    actGrid->setToolTip("Shows a grid over the map");
    actGrid->setIcon(QIcon(":/icons/grid.png"));

    toolBar->addSeparator();

    actHand = toolBar->addAction("Pan");
    actHand->setToolTip("Actives the panoramio tool");
    actHand->setIcon(QIcon(":/icons/hand.png"));
    actHand->setCheckable(true);

    actZoomWindow = toolBar->addAction("Zoom window");
    actZoomWindow->setToolTip("Allows to make a zoom into an interesting area");
    actZoomWindow->setIcon(QIcon(":/icons/zoomWindow.png"));
    actZoomWindow->setCheckable(true);

    actZoomRestore = toolBar->addAction("Zoom restore");
    actZoomRestore->setIcon(QIcon(":/icons/zoomRestore.png"));

    QAction *actSep2 = toolBar->addSeparator();

    actZoomIn = toolBar->addAction("Zoom in");
    actZoomIn->setIcon(QIcon(":/icons/zoomIn.png"));
    actZoomIn->setCheckable(true);

    QList<int> zoomVec;
    zoomVec << 3200 << 2400 << 1600 << 1200 << 800 << 700 << 600 << 500 << 400 << 300
        << 200 << 100 << 66 << 50 << 33 << 25 << 16  << 12 << 8 << 5 << 3 << 2 << 1;

    QStringList zoomList;
    for (int i = 0; i < zoomVec.size(); i++)
        zoomList.append( QString::number(zoomVec.at(i)) + "%");
    zoomList.append(WINDOW);

    zoomComboBox = new QComboBox(this);
    zoomComboBox->setMinimumWidth(70);
            //setGeometry(0, 0, 90, 20);
    zoomComboBox->addItems(zoomList);
    zoomComboBox->setMaxVisibleItems(zoomList.size());
    zoomComboBox->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    // zoomComboBox->setCurrentIndex(23); // window  //zoomIdx); //11);
    //zoomComboBox->setCurrentIndex(zoomIdx); //11);
    zoomComboBox->setEditable(true);

    toolBar->addWidget(zoomComboBox);

    actZoomOut = toolBar->addAction("Zoom out");
    actZoomOut->setIcon(QIcon(":/icons/zoomOut.png"));
    actZoomOut->setCheckable(true);

    ui->toolVerticalLayout->insertWidget(0, toolBar);

    actionGroup = new QActionGroup(this);
    actionGroup->setExclusive(true);
    actionGroup->addAction(actHand);
    actionGroup->addAction(actZoomWindow);
    actionGroup->addAction(actZoomIn);
    actionGroup->addAction(actZoomOut);
    actHand->setChecked(true);

    connect(actLegend, SIGNAL(triggered()), this, SLOT(legendClicked()) );
    connect(actGrid, SIGNAL(triggered()), this, SLOT(gridClicked()) );

    connect(actHand, SIGNAL(triggered()), ui->canvas, SLOT(setPanCursor()) );
    connect(actZoomWindow, SIGNAL(triggered()), ui->canvas, SLOT(setWindowCursor()) );

    connect(actZoomIn, SIGNAL(triggered()), this, SLOT(zoomInClicked()));
    connect(actZoomOut, SIGNAL(triggered()), this, SLOT(zoomOutClicked()));

    // It will be deleted into ui->canvas object
    QList<QAction *> *actions = new QList<QAction *>();
    (*actions) << actHand << actSep2 << actZoomWindow << actZoomRestore
                        << actZoomIn << actZoomOut;
    ui->canvas->setupContextMenu(actions);
}
