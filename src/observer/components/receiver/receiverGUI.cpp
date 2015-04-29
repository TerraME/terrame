#include "receiverGUI.h"
#include "ui_receiverGUI.h"

#include <QDateTime>
#include <QDebug>
#include <QSettings>
#include <QCloseEvent>

using namespace TerraMEObserver;


class LuaLegend 
{
public:
    LuaLegend() {}
    virtual ~LuaLegend() {}

    QString name;
    TypesOfData type;
    GroupingMode grouping;
    int slices;
    int precision;
    StdDev stdDev;
    double maximum;
    double mininum;
    QString fontFamily;
    int fontSize;
    QString symbol;  // may contain a character or an enumerator QwtSymbol::Style
    int width;
    int curveStyle; // refers to the 'style' of the legend (QwtPlotCurve::CurveStyle)
    int lineStyle;  // not yet used in the legend and ObsChart
    QString colorBar;
    QString stdColorBar;

    const QStringList & keysToString() const 
    {
        return LEGEND_KEYS;
    }

    QStringList valuesToString() const 
    {
#ifndef DEBUG_OBSERVER
        return QString("%1$ %2$ %3$ %4$ %5$ %6$ %7$ %8$ %9$ %10$ %11$ %12$ %13$") // %14")
#else
        return QString("type:%1$ group:%2$ slice:%3$ precis:%4$ stdD:%5$ max:%6$ "
            "min:%7$ colorB:%8$ fontF:%9$ fontS:%10$ sym:%11$ wid:%12$ sty:%13$") // %14")
#endif
            .arg(type)
            .arg(grouping)
            .arg(slices)
            .arg(precision)
            .arg(stdDev)
            .arg(maximum)
            .arg(mininum)
            .arg( (stdColorBar.isEmpty() ? colorBar : colorBar + COLOR_BAR_SEP + stdColorBar) )
            .arg(fontFamily)
            .arg(fontSize)
            .arg(symbol)
            .arg(width)
            .arg(curveStyle)
            // .arg(lineStyle) // not yet used in the legend and ObsChart
            .remove(QChar(' '), Qt::CaseInsensitive)
            // .split("$");
            .split("$", QString::SkipEmptyParts);
    }
};


ReceiverGUI::ReceiverGUI(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::receiverGUI)
{
    ui->setupUi(this);
    obsType = TObsMap;

    activeItem = -1;
    activeItemName = "";
    setupGUI();

    readSettings();
}

ReceiverGUI::~ReceiverGUI()
{
    delete ui;
    delete signalMapper;

    foreach(LuaLegend *leg, luaLegendHash.values())
        delete leg;
}

void ReceiverGUI::setStatusAndPort(const QString &state, int port)
{
    ui->lblReceiverStatus->setText(QString("State: '%1' @ Port: %2").arg(state).arg(port));
}

void ReceiverGUI::setMessagesStatus(int msg)
{
    ui->lblMessageStatus->setText("Messages sent: " + QString::number(msg));
}

void ReceiverGUI::setStatesStatus(int state)
{
    ui->lblStatesStatus->setText("States sent: " + QString::number(state));
}

void ReceiverGUI::setSpeed(const QString &speed)
{
    ui->lblSpeedStatus->setText(speed);

//    double secs = stopWatch.elapsed() / 1000.0;
//    qDebug("\t%.2fMB/%.2fs: %.2fMB/s", double(nbytes / (1024.0*1024.0)),
//    secs, double(nbytes / (1024.0*1024.0)) / secs);
}

void ReceiverGUI::appendMessage(const QString &message)
{
    // ui->logEdit->appendPlainText(tr("%1 %2")
    ui->logEdit->appendHtml(tr("<p>%1 %2</p>")
        .arg( QDateTime::currentDateTime().toString("MM/dd/yyyy, hh:mm:ss:") )
        .arg(message) );
}

void ReceiverGUI::setCompression(bool compress)
{
    if (compress)
    {
        ui->lblCompress->setText("Compress: On");
        ui->lblCompress->setToolTip("The send compressed is enabled.");
    }
    else
    {
        ui->lblCompress->setText("Compress: Off");
        ui->lblCompress->setToolTip("The send compressed is disabled.");
    }
}

void ReceiverGUI::closeButtonClicked()
{
    close();
}

void ReceiverGUI::blindListenButtonClicked()
{
    quint16 port = (quint16)ui->portComboBox->currentText().toUInt();
    emit blindListenPort(port);
}

    
int ReceiverGUI::getDimX() const 
{ 
    return ui->xDimSpin->value(); 
}
    
int ReceiverGUI::getDimY() const 
{ 
    return ui->yDimSpin->value(); 
}

void ReceiverGUI::okButtonClicked()
{
    // remove white space
    QString part = ui->attribsPlainEdit->toPlainText().remove(QChar(' '), Qt::CaseInsensitive);
    QStringList attrsList = part.split(";", QString::SkipEmptyParts);
    
    if (attrsList.isEmpty())
    {
        clearAll();
        return;
    }

    //if (! attrs.contains("x"))
    //    attributes.append("x");

    //if (! attrs.contains("y"))
    //    attributes.append("y");

  //  for (int i = 0; i < attrs.size(); i++)
  //       attributes.append(attrs.at(i));

    for (int i = 0; i < attrsList.size(); i++)
    {
        QStringList keys, attrs = attrsList.at(i).split(",", QString::SkipEmptyParts);
        attributesList.append(attrs);

        LuaLegend *leg = 0;

        for (int i = 0; i < attrs.size(); i++)
        {
            leg = new LuaLegend();

            leg->name = attrs.at(i);
            leg->type = TObsNumber;
            leg->grouping = TObsEqualSteps;
            leg->slices = 50;
            leg->precision = 6;
            leg->stdDev = TObsNone;
            leg->maximum = 100.0;
            leg->mininum = 0.0;
            leg->fontFamily = "Symbol";
            leg->fontSize = 12;
            leg->symbol = "�";
            leg->width = 12;
            leg->curveStyle = 1; // see QwtPlotCurve::CurveStyle
            leg->lineStyle = 0;  // ainda n�o utilizado no ObsChart e na legenda
            leg->colorBar = "0,0,0;0;0;?;#255,255,255;100;100;?;#";
            leg->stdColorBar = "";

            QListWidgetItem *item = new QListWidgetItem(ui->listWidget);
            item->setText(leg->name);
            
            keys.append(leg->keysToString());

            luaLegendHash.insert(leg->name, leg);
        }
        // ui->listWidget->addItems(attrs);
        keysList.append(keys);
    }

    // qDebug() << attributesList; //keysList;

    ui->listWidget->setCurrentItem( ui->listWidget->item(0) );
    consistGUI(0);
    // ui->okButton->setEnabled(false);
    // ui->clearButton->setEnabled(true);
    ui->legendGroupBox->setEnabled(true);

    if (ui->autoCreateCheck->isChecked())
        emit createObserver();
}

int ReceiverGUI::getNumberOfObservers() const
{
    return attributesList.size();
}

void ReceiverGUI::consistGUI(int listRow)
{
    if (activeItem == listRow)
        return;

    activeItem = listRow;
    activeItemName = ui->listWidget->currentItem()->text();

    LuaLegend *leg = luaLegendHash.value(activeItemName); // (luaLegends.size() > listRow) ? luaLegends.at(listRow) : 0;
    if (leg)
    {
        switch (leg->type)
        {
            case TObsBool: ui->boolRadio->setChecked(true); break;
            case TObsDateTime: ui->dateTimeRadio->setChecked(true); break;
            case TObsNumber: ui->numberRadio->setChecked(true); break;
            case TObsText: 
            default: ui->stringRadio->setChecked(true); break;
        }

        switch (leg->grouping)
        {
            case TObsEqualSteps: ui->equalRadio->setChecked(true); break;
            case TObsQuantil: ui->quantilRadio->setChecked(true); break;
            case TObsStdDeviation: ui->stdDevRadio->setChecked(true); break;
            case TObsUniqueValue: 
            default: ui->uniqueRadio->setChecked(true); break;
        }

        switch (leg->stdDev)
        {
            case TObsNone: ui->noneRadio->setChecked(true); break;
            case TObsQuarter: ui->quarterRadio->setChecked(true); break;
            case TObsHalf: ui->halfRadio->setChecked(true); break;
            case TObsFull: 
            default: ui->fullRadio->setChecked(true); break;
        }

        ui->maxDoubleSpin->setValue(leg->maximum);
        ui->minDoubleSpin->setValue(leg->mininum);
        ui->slicesSpin->setValue(leg->slices);
        ui->widthSpin->setValue(leg->width);

        int symbolPos = ui->curveSymbolCombo->findText(leg->symbol);
        
        ui->lineStylecombo->setCurrentIndex(leg->lineStyle); // ui->lineStylecombo->findText(leg->lineStyle));
        ui->curveStyleCombo->setCurrentIndex(leg->curveStyle); // ui->curveStyleCombo->findText(leg->curveStyle));
        ui->curveSymbolCombo->setCurrentIndex( (symbolPos < 0 ? 0 : symbolPos ) );
        ui->fontComboBox->setCurrentIndex(ui->fontComboBox->findText(leg->fontFamily));
        
        // ui->lineStylecombo->setCurrentIndex(ui->lineStylecombo->findText(leg->style));
        
        ui->colorBarLine->setText(leg->colorBar);
        ui->stdColorBarLine->setText(leg->stdColorBar);
    }
}

void ReceiverGUI::consistButtons(const QString & /*value*/)
{
    // ui->okButton->setEnabled( ! value.isEmpty() );
    // ui->clearButton->setEnabled( ! value.isEmpty() );
}

void ReceiverGUI::clearAll()
{
    attributesList.clear();
    ui->legendGroupBox->setEnabled(false);
    ui->listWidget->clear();
    activeItem = -1;
    activeItemName = "";
    foreach(LuaLegend *leg, luaLegendHash.values())
        delete leg;

    luaLegendHash.clear();
    keysList.clear();
    ui->logEdit->clear();
}

QStringList * ReceiverGUI::getAttributes(int pos) const
{
    if ( (! attributesList.isEmpty()) && (pos < attributesList.size()) )
        return (QStringList *) &attributesList[pos];
    return 0;
}

QStringList * ReceiverGUI::getLegendKeys(int pos) const
{
    // qDebug() << "fix for more than one observer ---------------\n" << keysList[pos];

    if ( (! keysList.isEmpty()) && (pos < keysList.size()) )
        return (QStringList *) &keysList[pos];
    return 0;
}

const QStringList ReceiverGUI::getLegendValue(int obsPos) const
{
    // obsPos: observer's position in the list
    const QStringList &attrList = attributesList[obsPos];
    QStringList ret;
    for(int i = 0; i < attrList.size(); i++)
    {
        LuaLegend *leg = luaLegendHash.value( attrList.at(i) );
        ret.append( leg->valuesToString() );
    }
    return ret;

    //if ( (! attributesList.isEmpty()) && (pos < attributesList.at(pos).size()) )
    //{
    //    QStringList ret;
    //    LuaLegend *leg = 0;
    //    // for (int j = 0; j < luaLegends.size(); j++)
    //    {
    //        for(int i = 0; i < attributesList.at(pos).size(); i++)
    //        {
    //            leg = luaLegends.at(i); //at(j);
    //            if (leg && leg->name == attributesList.at(pos).at(i))
    //                ret.append(leg->valuesToString());
    //        }
    //    }
    //    return ret;
    //}
    return QStringList();
}

void ReceiverGUI::obsTypeSelected(int type)
{
    obsType = (TypesOfObservers) type;
}

void ReceiverGUI::dataTypeSelected(int type)
{
    // dataType = (TypesOfData) type;

    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->type = (TypesOfData) type; // dataType;
}

void ReceiverGUI::grpTypeSelected(int type)
{
    // grpType = (GroupingMode) type;

    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->grouping = (GroupingMode) type; // grpType;
}

void ReceiverGUI::stdTypeSelected(int type)
{
    // stdType = (StdDev) type;

    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->stdDev = (StdDev) type; // stdType;
}

void ReceiverGUI::on_maxDoubleSpin_valueChanged(double value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->maximum = value;
}

void ReceiverGUI::on_minDoubleSpin_valueChanged(double value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->mininum = value;
}

void ReceiverGUI::on_slicesSpin_valueChanged(int value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->slices = value;
}

void ReceiverGUI::on_widthSpin_valueChanged(int value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->width = value;
}

void ReceiverGUI::on_precisionSpin_valueChanged(int value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->precision = value;
}

void ReceiverGUI::on_fontComboBox_currentFontChanged(const QFont & font )
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
    {
        leg->fontFamily = font.family();
        leg->fontSize = font.pointSize();
    }
}

void ReceiverGUI::on_lineStylecombo_currentIndexChanged(int value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->lineStyle = value;
}

void ReceiverGUI::on_curveSymbolCombo_currentIndexChanged(const QString &value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
    {
        if (ui->chartRadio->isChecked() || ui->dynChartRadio->isChecked())
            leg->symbol = QString("%1").arg(ui->curveSymbolCombo->currentIndex());
        else
            leg->symbol = (value.isEmpty() ? SYMBOL_CHAR : value);
    }
}

void ReceiverGUI::on_curveStyleCombo_currentIndexChanged(int value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->curveStyle = value;
}

void ReceiverGUI::on_colorBarLine_textChanged(const QString &value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    // LuaLegend *leg = (luaLegends.size() > activeItem) ? luaLegends.at(activeItem) : 0;
    if (leg)
        leg->colorBar = value;
}


void ReceiverGUI::on_stdColorBarLine_textChanged(const QString &value)
{
    LuaLegend *leg = luaLegendHash.value(activeItemName);
    if (leg)
        leg->stdColorBar = value;
}

void ReceiverGUI::setupGUI()
{
    ui->legendGroupBox->setVisible(false);

    // ui->lblCompressIcon->setScaledContents(true);
    // ui->lblCompressIcon->setPixmap(QPixmap(":/icons/compress.png"));
    ui->lblCompress->setText("Compress: Off");
    ui->lblCompress->setToolTip("The send compressed is disabled.");
    
    connect(ui->closeButton, SIGNAL(clicked()), this, SLOT(closeButtonClicked()));
    connect(ui->blindListenButton, SIGNAL(clicked()), this, SLOT(blindListenButtonClicked()));
    connect(ui->okButton, SIGNAL(clicked()), this, SLOT(okButtonClicked()));
    connect(ui->listWidget, SIGNAL(currentRowChanged(int)), this, SLOT(consistGUI(int)));
    // connect(ui->attribsPlainEdit, SIGNAL(textChanged(const QString &)), this, SLOT(consistButtons(const QString &)));
    connect(ui->clearButton, SIGNAL(clicked()), this, SLOT(clearAll()));

    // Maps radioBUttons in slot obsTypeSelected
    signalMapper = new QSignalMapper(this);
    signalMapper->setMapping(ui->logFileRadio, TObsLogFile);
    signalMapper->setMapping(ui->tableRadio, TObsTable);
    signalMapper->setMapping(ui->textScreenRadio, TObsTextScreen);
    signalMapper->setMapping(ui->chartRadio, TObsGraphic);
    signalMapper->setMapping(ui->dynChartRadio, TObsDynamicGraphic);
    signalMapper->setMapping(ui->mapRadio, TObsMap);
    signalMapper->setMapping(ui->schedulerRadio, TObsScheduler);
    signalMapper->setMapping(ui->imageRadio, TObsImage);
    signalMapper->setMapping(ui->stateMachineRadio, TObsStateMachine);
    signalMapper->setMapping(ui->neighborRadio, TObsNeigh);
    signalMapper->setMapping(ui->udpSenderRadio, TObsUDPSender);
    signalMapper->setMapping(ui->tcpSenderRadio, TObsTCPSender);
    
    connect(ui->logFileRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->tableRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->textScreenRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->chartRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->dynChartRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->mapRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->schedulerRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->imageRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->stateMachineRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->neighborRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->udpSenderRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));
    connect(ui->tcpSenderRadio, SIGNAL(clicked()), signalMapper, SLOT(map()));

    connect(signalMapper, SIGNAL(mapped(int)), this, SLOT(obsTypeSelected(int)));


    // Maps radioBUttons in slot dataTypeSelected
    signalMapperAttrType = new QSignalMapper(this);
    signalMapperAttrType->setMapping(ui->boolRadio, TObsBool);
    signalMapperAttrType->setMapping(ui->dateTimeRadio, TObsDateTime);
    signalMapperAttrType->setMapping(ui->numberRadio, TObsNumber);
    signalMapperAttrType->setMapping(ui->stringRadio, TObsText);

    connect(ui->boolRadio, SIGNAL(clicked()), signalMapperAttrType, SLOT(map()));
    connect(ui->dateTimeRadio, SIGNAL(clicked()), signalMapperAttrType, SLOT(map()));
    connect(ui->numberRadio, SIGNAL(clicked()), signalMapperAttrType, SLOT(map()));
    connect(ui->stringRadio, SIGNAL(clicked()), signalMapperAttrType, SLOT(map()));

    connect(signalMapperAttrType, SIGNAL(mapped(int)), this, SLOT(dataTypeSelected(int)));


    // Maps radioBUttons in slot grpTypeSelected
    signalMapperGrpType = new QSignalMapper(this);
    signalMapperGrpType->setMapping(ui->equalRadio, TObsEqualSteps);
    signalMapperGrpType->setMapping(ui->quantilRadio, TObsQuantil);
    signalMapperGrpType->setMapping(ui->stdDevRadio, TObsStdDeviation);
    signalMapperGrpType->setMapping(ui->uniqueRadio, TObsUniqueValue);

    connect(ui->equalRadio, SIGNAL(clicked()), signalMapperGrpType, SLOT(map()));
    connect(ui->quantilRadio, SIGNAL(clicked()), signalMapperGrpType, SLOT(map()));
    connect(ui->stdDevRadio, SIGNAL(clicked()), signalMapperGrpType, SLOT(map()));
    connect(ui->uniqueRadio, SIGNAL(clicked()), signalMapperGrpType, SLOT(map()));

    connect(signalMapperGrpType, SIGNAL(mapped(int)), this, SLOT(grpTypeSelected(int)));


    // Maps radioBUttons in slot stdTypeSelected
    signalMapperStdType = new QSignalMapper(this);
    signalMapperStdType->setMapping(ui->noneRadio, TObsNone);
    signalMapperStdType->setMapping(ui->quarterRadio, TObsQuarter);
    signalMapperStdType->setMapping(ui->halfRadio, TObsHalf);
    signalMapperStdType->setMapping(ui->fullRadio, TObsFull);

    connect(ui->noneRadio, SIGNAL(clicked()), signalMapperStdType, SLOT(map()));
    connect(ui->quarterRadio, SIGNAL(clicked()), signalMapperStdType, SLOT(map()));
    connect(ui->halfRadio, SIGNAL(clicked()), signalMapperStdType, SLOT(map()));
    connect(ui->fullRadio, SIGNAL(clicked()), signalMapperStdType, SLOT(map()));

    connect(signalMapperStdType, SIGNAL(mapped(int)), this, SLOT(stdTypeSelected(int)));
}

 void ReceiverGUI::writeSettings()
 {
     QSettings settings(QSettings::IniFormat, QSettings::UserScope, "TerraME", "ObserverClient");

     settings.beginGroup("RemoteVisualizations");

     settings.beginGroup("Attributes");
     settings.setValue("attributes", ui->attribsPlainEdit->toPlainText());
     settings.setValue("stdColorBar", ui->stdColorBarLine->text());
     settings.setValue("colorBar", ui->colorBarLine->text());
     settings.setValue("autoCreate", ui->autoCreateCheck->isChecked());
     settings.endGroup();

     settings.endGroup();
 }

 void ReceiverGUI::readSettings()
 {
     ui->frame->blockSignals(true);

     QSettings settings(QSettings::IniFormat, QSettings::UserScope, "TerraME", "ObserverClient");

     settings.beginGroup("RemoteVisualizations");
     
     settings.beginGroup("Attributes");
     ui->attribsPlainEdit->setPlainText( settings.value("attributes").toString() );
     ui->colorBarLine->setText( settings.value("colorBar").toString() );
     ui->stdColorBarLine->setText( settings.value("stdColorBar").toString() );
     ui->autoCreateCheck->setChecked( settings.value("autoCreate").toBool() );
     settings.endGroup();

     settings.endGroup();


     ui->frame->blockSignals(false);
 }

 void ReceiverGUI::closeEvent(QCloseEvent *event)
 {
    writeSettings();
    event->accept();
 }

 void ReceiverGUI::clearLog()
{
    ui->logEdit->clear();
}
