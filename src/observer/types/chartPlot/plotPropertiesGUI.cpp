#include "plotPropertiesGUI.h"
#include "ui_plotPropertiesGUI.h"

#include <QMenu>
#include <QAction>
#include <QFontDialog>
#include <QColorDialog>
#include <QPalette>
#include <QTreeWidgetItem>
#include <QDebug>

#include <qwt_plot_canvas.h>
#include <qwt_scale_widget.h>
#include <qwt_scale_draw.h>
#include <qwt_legend.h>

#include "internalCurve.h"

using namespace TerraMEObserver;

PlotPropertiesGUI::PlotPropertiesGUI(ChartPlot *parent) : //, QWidget *parent) :
    plotter(parent),
    QDialog(parent),
    ui(new Ui::plotPropertiesGUI)
{
    ui->setupUi(this);
    setWindowTitle("TerraME Observer : Chart - Properties");
    // setStyleSheet("QTabWidget#tabWidget QPushButton[flat=true] {"
    //              "width: 35px; border-radius: 4px; "
    //              "border: 1px solid rgb(0, 0, 0); background-color: white; }");

    axesContextMenu = new QMenu(this);
    ui->treeCurve->header()->setVisible(false);
    ui->axesFontButton->setMenu(axesContextMenu);

    labelsFontAct = axesContextMenu->addAction("Labels...");
    scalesFontAct = axesContextMenu->addAction("Scales...");
    
    // Connecting slots 
    // general tab
    ui->borderColorButton->setEnabled(false);
    ui->borderColorButton->setFlat(false);
    connect(ui->borderColorButton, SIGNAL(clicked()), this, SLOT(borderColorClicked()));
    connect(ui->bckgrndColorButton, SIGNAL(clicked()), this, SLOT(bckgrndColorClicked()));
    connect(ui->canvasColorButton, SIGNAL(clicked()), this, SLOT(canvasColorClicked()));

    connect(ui->borderWidthSpinBox, SIGNAL(valueChanged(int)), this, SLOT(borderWidthValue(int)));
    connect(ui->marginSpinBox, SIGNAL(valueChanged(int)), this, SLOT(marginValue(int)));

    // fonts
    connect(labelsFontAct, SIGNAL(triggered()), this, SLOT(labelsFontClicked()));
    connect(scalesFontAct, SIGNAL(triggered()), this, SLOT(scalesFontClicked()));
    connect(ui->titlesFontButton, SIGNAL(clicked()), this, SLOT(titlesFontClicked()));
    connect(ui->legendsFontButton, SIGNAL(clicked()), this, SLOT(legendFontClicked()));

    // curve tab
    connect(ui->curveStyleCombo, SIGNAL(currentIndexChanged(int)), this, SLOT(selectedStyle(int)));
    connect(ui->curveSymbolCombo, SIGNAL(currentIndexChanged(int)), this, SLOT(selectedSymbol(int)));
    connect(ui->lineStylecombo, SIGNAL(currentIndexChanged(int)), this, SLOT(selectedLine(int)));

    connect(ui->curveWidthSpinBox, SIGNAL(valueChanged(int)), this, SLOT(curveWidthValue(int)));
    connect(ui->symbolSizeSpinBox, SIGNAL(valueChanged(int)), this, SLOT(symbolSizeValue(int)));

    connect(ui->curveColorButton, SIGNAL(clicked()), this, SLOT(curveColorClicked()));
    connect(ui->treeCurve, SIGNAL(currentItemChanged(QTreeWidgetItem *, QTreeWidgetItem *)), this,
        SLOT(currentItemChanged(QTreeWidgetItem *, QTreeWidgetItem *)));
}

PlotPropertiesGUI::~PlotPropertiesGUI()
{
    delete labelsFontAct;
    delete scalesFontAct;
    delete axesContextMenu;

    delete ui;
}

void PlotPropertiesGUI::consistGUI(QList<InternalCurve *> *interCurves)
{
    QTreeWidgetItem *item = 0;
    InternalCurve *curve = 0;

    for (int i = 0; i < interCurves->size(); i++)
    {
        curve = interCurves->at(i);
        item = new QTreeWidgetItem(ui->treeCurve);
        item->setText(0, curve->plotCurve->title().text());

        internalCurves.insert(curve->plotCurve->title().text(), curve);
    }

    ui->treeCurve->sortItems(0, Qt::AscendingOrder);
    ui->treeCurve->setSortingEnabled(true);

    // General tab
	// TODO: Verify if it is necessary and put it back if yes
//    ui->marginSpinBox->setValue(plotter->margin());
    ui->borderWidthSpinBox->setValue(plotter->lineWidth());

    if(ui->borderColorButton->isEnabled())
    {
        ui->borderColorButton->setStyleSheet(QString("border-radius: 4px; "
            "border: 1px solid rgb(0, 0, 0); background-color: %1")
            .arg(plotter->palette().color(QPalette::Foreground).name()));
    }
    ui->bckgrndColorButton->setStyleSheet(QString("  border-radius: 4px; "
            "border: 1px solid rgb(0, 0, 0); background-color: %1")
            .arg(plotter->palette().color(QPalette::Background).name()));

    ui->canvasColorButton->setStyleSheet(QString("  border-radius: 4px; "
            "border: 1px solid rgb(0, 0, 0); background-color: %1")
            .arg(plotter->canvas()->palette().color(QPalette::Background).name()));

    // Curves tab
    //ui->treeCurve->setCurrentItem(ui->treeCurve->topLevelItem(0));
    //consistCurveTab(ui->treeCurve->currentItem()->text(0));
}

void PlotPropertiesGUI::borderColorClicked()
{
    // borderColorButton is disabled
    
    QColor color;
    color = QColorDialog::getColor(color, this, "TerraME Observer : Chart - Select color");

    if (color.isValid())
    {
        ui->borderColorButton->setStyleSheet(QString("border-radius: 4px; "
            "border: 1px solid rgb(0, 0, 0); background-color: %1").arg(color.name()));

     //   QPalette plotterPalette = plotter->palette(); //, palette = plotter->axisWidget(QwtPlot::xBottom)->palette();
        //plotterPalette.setColor(QPalette::Foreground, color);
        //plotter->setPalette(plotterPalette);
     //   // plotter->axisWidget(QwtPlot::xBottom)->setPalette(palette);
    }
}

void PlotPropertiesGUI::bckgrndColorClicked()
{
    QColor color;
    color = QColorDialog::getColor(plotter->palette().color(QPalette::Background), 
        this, "Chart Properties - Select color");

    if(color.isValid())
    {
        ui->bckgrndColorButton->setStyleSheet(QString("  border-radius: 4px; "
            "border: 1px solid rgb(0, 0, 0);background-color: %1").arg(color.name()));

        QPalette palette = plotter->palette();
        palette.setColor(QPalette::Background, color);
        plotter->setPalette(palette);
    }
}

void PlotPropertiesGUI::canvasColorClicked()
{
    QColor color;
    color = QColorDialog::getColor(plotter->canvas()->palette().color(QPalette::Background), 
        this, "Chart Properties - Select color");

    if(color.isValid())
    {
        ui->canvasColorButton->setStyleSheet(QString("  border-radius: 4px; "
            "border: 1px solid rgb(0, 0, 0);background-color: %1").arg(color.name()));

        QPalette palette = plotter->canvas()->palette();
        palette.setColor(QPalette::Background, color);
        plotter->canvas()->setPalette(palette);
        plotter->canvas()->update();
    	plotter->replot();
    }
}

void PlotPropertiesGUI::curveColorClicked()
{
    QColor color;
    color = QColorDialog::getColor(color, this, "TerraME Observer : Chart - Select color");

    if(color.isValid())
    {
        ui->curveColorButton->setStyleSheet(QString("  border-radius: 4px; "
            "border: 1px solid rgb(0, 0, 0);background-color: %1").arg(color.name()));

        internalCurves.value(currentCurve)->plotCurve->setPen(QPen(color));
        plotter->replot();
    }
}

void PlotPropertiesGUI::borderWidthValue(int value)
{
    plotter->setLineWidth(value);
}

void PlotPropertiesGUI::marginValue(int value)
{
//    plotter->setMargin(value);
}

void PlotPropertiesGUI::selectedStyle(int value)
{
    internalCurves.value(currentCurve)->plotCurve
        ->setStyle((QwtPlotCurve::CurveStyle) (value - 1));
    plotter->replot();
}

void PlotPropertiesGUI::selectedSymbol(int value)
{
    QwtPlotCurve* plotCurve = internalCurves.value(currentCurve)->plotCurve;

	//QwtSymbol* const oldSym = plotCurve->symbol();
	QwtSymbol* symbol = new QwtSymbol;
	symbol->setStyle((QwtSymbol::Style) (value - 1)); // starts in -1);
    symbol->setSize(ui->symbolSizeSpinBox->value());
    //symbol->setPen(oldSym->pen());

    if(symbol->brush().style() != Qt::NoBrush)
    	// symbol.setBrush(QBrush(oldSym.pen().color()));
        symbol->setBrush(QBrush(plotCurve->pen().color()));

    plotCurve->setSymbol(symbol);
    plotter->replot();
}

void PlotPropertiesGUI::selectedLine(int value)
{
    QwtPlotCurve *plotCurve = internalCurves.value(currentCurve)->plotCurve;

    // Changes only the curve style
    QPen pen = plotCurve->pen();
    pen.setStyle((Qt::PenStyle) value);
    plotCurve->setPen(pen);
    plotter->replot();
}

void PlotPropertiesGUI::curveWidthValue(int value)
{
    QwtPlotCurve *plotCurve = internalCurves.value(currentCurve)->plotCurve;

    // Changes only the curve width
    QPen pen = plotCurve->pen();
    pen.setWidth(value);
    plotCurve->setPen(pen);
    plotter->replot();
}

void PlotPropertiesGUI::symbolSizeValue(int value)
{
    QwtPlotCurve *plotCurve = internalCurves.value(currentCurve)->plotCurve;

    // Changes only the symbol width
    const QwtSymbol * const oldSymbol = plotCurve->symbol();
	QwtSymbol* symbol = new QwtSymbol;
    symbol->setStyle((QwtSymbol::Style) (ui->curveSymbolCombo->currentIndex() - 1)); // starts in -1

    if (symbol->brush().style() != Qt::NoBrush)
        symbol->setBrush(QBrush(plotCurve->pen().color()));

    symbol->setSize(value);
    plotCurve->setSymbol(symbol);
    plotter->replot();
}

void PlotPropertiesGUI::titlesFontClicked()
{
    bool ok;
    QFont newFont = QFontDialog::getFont(&ok, plotter->title().font(),
                                         this, "TerraME Observer : Chart - Select Font");
    if ((ok) && (newFont != plotter->title().font()))
    {
        QwtText text = plotter->title();
        text.setFont(newFont);
        plotter->setTitle(text);
    }
}

void PlotPropertiesGUI::labelsFontClicked()
{
    bool ok;
    QFont newFont = QFontDialog::getFont(&ok, plotter->axisTitle(QwtPlot::xBottom).font(),
                                         this, "TerraME Observer : Chart - Select Font");
    if ((ok) && (newFont != plotter->axisTitle(QwtPlot::xBottom).font()))
    {
        QwtText text = plotter->axisTitle(QwtPlot::xBottom);
        text.setFont(newFont);
        plotter->setAxisTitle(QwtPlot::xBottom, text);

        text = plotter->axisTitle(QwtPlot::yLeft);
        text.setFont(newFont);
        plotter->setAxisTitle(QwtPlot::yLeft, text);
    }
}

void PlotPropertiesGUI::scalesFontClicked()
{
    bool ok;
    QFont newFont = QFontDialog::getFont(&ok, plotter->axisFont(QwtPlot::xBottom),
                                         this, "TerraME Observer : Chart - Select Font");
    if ((ok) && (newFont != plotter->axisFont(QwtPlot::xBottom)))
    {
        plotter->setAxisFont(QwtPlot::xBottom, newFont);
        plotter->setAxisFont(QwtPlot::yLeft, newFont);
    }
}

void PlotPropertiesGUI::legendFontClicked()
{
    bool ok;

    QFont newFont = QFontDialog::getFont(&ok, plotter->legend()->font(),
                                         this, "TerraME Observer : Chart - Select Font");
    if ((ok) && (newFont != plotter->legend()->font()))
    {
        plotter->legend()->setFont(newFont);
    }
}

void PlotPropertiesGUI::currentItemChanged(QTreeWidgetItem * current, QTreeWidgetItem * /* previous */)
{
    currentCurve = current->text(0);
    consistCurveTab(currentCurve);
    plotter->replot();
}

void PlotPropertiesGUI::consistCurveTab(const QString &name)
{
    QwtPlotCurve *plotCurve = internalCurves.value(name)->plotCurve;

    const QwtSymbol* const oldSymbol = plotCurve->symbol();
	QwtSymbol *symbol = new QwtSymbol(oldSymbol->style(), oldSymbol->brush(), oldSymbol->pen(), oldSymbol->size());
    ui->symbolSizeSpinBox->setValue(symbol->size().width());
    ui->curveSymbolCombo->setCurrentIndex((int)symbol->style() + 1); // Starts in -1
    // Fixes bug built when used 'plotCurve->symbol()'
    plotCurve->setSymbol(symbol);

    ui->curveWidthSpinBox->setValue(plotCurve->pen().width());
    ui->curveStyleCombo->setCurrentIndex((int)plotCurve->style());
    ui->lineStylecombo->setCurrentIndex((int)plotCurve->pen().style());

    ui->curveColorButton->setStyleSheet(QString("  border-radius: 4px; "
            "border: 1px solid rgb(0, 0, 0); background-color: %1")
            .arg(plotCurve->pen().color().name()));
}

