#include "legendWindow.h"

class ObsLegend;

#include <QMessageBox>
#include <QFile>
#include <QTextStream>
#include <QPainter>
#include <QDebug>

#include <cmath>
#include "terrameGlobals.h"

#define MAXSLICES 255

extern "C"
{
#include <lua.h>
}
#include "luna.h"

///< Global variable: Lua stack used for communication with C++ modules.
extern lua_State * L;
extern ExecutionModes execModes;

static const QString MEAN = "mean";

using namespace TerraMEObserver;

LegendWindow::LegendWindow(QWidget *parent)
    : QDialog(parent)
{
    invertColor = false;
    attrValuesChanged = false;
    rows = 5;
    teColorVec = 0;

    setupUi();

    //createView();

    std::string color = "W-Bl";
    frameTeQtStdColorBar->setColorBarFromNames(color);
    frameTeQtStdColorBar->setVerticalBar(false);
    frameTeQtStdColorBar->hide();

    frameTeQtColorBar->setColorBarFromNames(color);
    frameTeQtColorBar->setVerticalBar(false);
    //********//

    setupComboBoxes();

    functionComboBox->setEnabled(false);
    chrononComboBox->setEnabled(false);
    saveColorPushButton->setEnabled(false);
    loadGroupBox->setEnabled(false);

    applyPushButton->setEnabled(false);

    // connectSlots();
    createColorVector();
    //applyPushButton_clicked();
}

LegendWindow::~LegendWindow()
{
    delete attributeTextLabel;
    delete groupingModeTextLabel;
    delete precisionTextLabel;
    delete slicesTextLabel;
    delete stdDevTextLabel;
    delete functionTextLabel;
    delete chrononTextLabel;

    delete groupingModeComboBox;
    delete slicesComboBox;
    delete precisionComboBox;
    delete chrononComboBox;
    delete functionComboBox;
    delete stdDevComboBox;
    delete attributesComboBox;
    delete loadNamesComboBox;

    delete clearColorsPushButton;
    delete invertColorsPushButton;
    delete equalSpacePushButton;
    delete saveColorPushButton;
    delete helpPushButton;
    delete cancelPushButton;
    delete okPushButton;
    delete applyPushButton;

    delete loadGroupBox;
    delete colorGroupBox;
    delete groupingParamsGroupBox;

    //if (frameBTeQtColorBar)
    //    delete frameBTeQtColorBar;

    //if (frameTeQtColorBar)
    //    delete frameTeQtColorBar;

    delete legendTable;
    delete teColorVec;
}

void LegendWindow::createView(int rowsNum)
{
    QStringList colTitle;

    if (groupingModeComboBox->currentIndex() == TObsUniqueValue)
        colTitle << tr("Color") << tr("Value") << tr("Label"); // << tr("Count");
    else
        colTitle << tr("Color") << tr("From") << tr("To") << tr("Label"); //  << tr("Count");

    legendTable->clear();
    //legendTable->setAlternatingRowColors(true);
    legendTable->setRowCount(rowsNum);
    legendTable->setColumnCount(colTitle.size());

    QTableWidgetItem *item;
    for (int i = 0; i < colTitle.size(); i++){
        item = new QTableWidgetItem();
        item->setText(colTitle.at(i));
        legendTable->setHorizontalHeaderItem(i, item);
    }

    legendTable->resizeColumnToContents(0);

    //legendTable->setColumnReadOnly (1, false);		// From
    //legendTable->setColumnReadOnly (2, false);		// To
    //legendTable->setColumnReadOnly (3, false);		// Label
    //legendTable->setColumnReadOnly (4, true);		// Count
}

void LegendWindow::insertAttributesCombo(const QStringList &attribs)
{
    attributesComboBox->clear();
    // attributesComboBox->insertItems(0, mapAttributes->keys());
    attributesComboBox->insertItems(0, attribs);
    attributesComboBox->setCurrentIndex(0);

    attribList = attribs;
}

void LegendWindow::setupComboBoxes()
{
    //*********** Grouping Modes ******************************
    // Set the grouping modes
    groupingModeComboBox->clear();

    QStringList groups;
    groups << tr("Equal Steps")
           << tr("Quantil")
           << tr("Standard Deviation")
           << tr("Unique Value");
    groupingModeComboBox->insertItems(0, groups);
    groupingModeComboBox->setEditable(false);


    //***********
    attributesComboBox->clear();
    attributesComboBox->insertItem(0, "-"); // attributes that are being observed


    //*********** Slices *******************************************
    // Fill the slices combobox according to the grouping mode
    slicesComboBox->clear();
    for(int i = 1; i <= MAXSLICES; i++)
        slicesComboBox->insertItem(i, QString::number(i));
    slicesComboBox->setCurrentIndex(4); // sets the index - remembering that starts with 0

    //************************** Standard Deviation ********************
    // Fill the standard deviation combobox
    stdDevComboBox->clear();
    stdDevComboBox->insertItem(0, "1");
    stdDevComboBox->insertItem(1, "0.5");
    stdDevComboBox->insertItem(2, "0.25");
    stdDevComboBox->setCurrentIndex(-1);
    stdDevComboBox->setEnabled(false);

    //******************************* Precision *********************************
    // Fill the precision combobox
    precisionComboBox->clear();
    for(int i = 1; i <= 15; ++i)
        precisionComboBox->insertItem(i, QString::number(i));
    precisionComboBox->setEditable(false);
    precisionComboBox->setCurrentIndex(5); // precision 6
}

void LegendWindow::legendTable_doubleClicked(int /*row*/, int col)
{
    if (col == 0){
        QMessageBox::information(this, "LegendWindow", "Do not implemented!");
        return;
    }
}

void LegendWindow::slicesComboBox_activated(const QString &)
{
    applyPushButton->setEnabled(true);
    okPushButton->setEnabled(false);
}

void LegendWindow::stdDevComboBox_activated(const QString &)
{
    applyPushButton->setEnabled(true);
    okPushButton->setEnabled(false);
}

void LegendWindow::precisionComboBox_activated(const QString &)
{
    applyPushButton->setEnabled(true);
    okPushButton->setEnabled(false);
}

void LegendWindow::functionComboBox_activated(int)
{
    applyPushButton->setEnabled(true);
    okPushButton->setEnabled(false);
}

void LegendWindow::clearColorsPushButton_clicked()
{
    frameTeQtColorBar->clearColorBar();
    if(frameTeQtStdColorBar->isVisible())
        frameTeQtStdColorBar->clearColorBar();
}

void LegendWindow::invertColorsPushButton_clicked()
{
    frameTeQtColorBar->invertColorBar();
    if(frameTeQtStdColorBar->isVisible())
        frameTeQtStdColorBar->invertColorBar();

    invertColor = !invertColor;
}

void LegendWindow::equalSpacePushButton_clicked()
{
    frameTeQtColorBar->setEqualSpace();
    if(frameTeQtStdColorBar->isVisible())
        frameTeQtStdColorBar->setEqualSpace();

    colorChangedSlot();
}

void LegendWindow::attributesComboBox_activated(const QString &selected)
{
    Attributes *attrib = mapAttributes->value(selected);

    if (! attrib)
        return;
#ifdef DEBUG_OBSERVER
    printf("attributesComboBox_activated:\n %s\n", attrib->toQString().toLatin1().constData());
#endif

    if (attributesActive != selected)
    {
        if (isVisible() && attrValuesChanged)
        {
            attrValuesChanged = false;
            
             QMessageBox msgBox(this);
             msgBox.setWindowTitle("TerraME Observer : Map");
             msgBox.setText(tr("The attribute value has been modified.\n"
                 "Do you want save your changes?"));

            /*QPushButton *saveBut = */ msgBox.addButton(tr("Yes"), QMessageBox::YesRole);
            QPushButton *cancelBut = msgBox.addButton(tr("No"), QMessageBox::NoRole);
            msgBox.setDefaultButton(cancelBut);
            // msgBox.setEscapeButton(cancelBut);

            msgBox.exec();

            // Rollback the changes
            if (msgBox.clickedButton() == cancelBut)
                rollbackChanges(attributesActive);
        }

        attributesActive = selected;
        precisionComboBox->setCurrentIndex(attrib->getPrecisionNumber());
        groupingModeComboBox->setCurrentIndex(attrib->getGroupMode());

        frameTeQtColorBar->setColorBar(attrib->getColorBar());
        frameTeQtColorBar->repaint();

        applyPushButton->setEnabled(true);
    }

    if (attrib->getGroupMode() != TObsUniqueValue)
    {
        if (frameTeQtStdColorBar->isVisible())
            frameTeQtStdColorBar->hide();

        int s = attrib->getSlices();
        if (s == 0)
            s = 4;

        slicesComboBox->setCurrentIndex(s);
        slicesComboBox->setEnabled(true);

        stdDevComboBox->setCurrentIndex(-1);
        stdDevComboBox->setEnabled(false);

        if (attrib->getGroupMode() == TObsStdDeviation)
        {
            frameTeQtStdColorBar->setVisible(true);
            //frameBTeQtColorBar->setColorBar(frameBTeQtColorBar->getInputColorVec());
            frameTeQtStdColorBar->setColorBar(attrib->getStdColorBar());
            frameTeQtStdColorBar->drawColorBar();

            stdDevComboBox->setCurrentIndex(attrib->getStdDeviation());
            stdDevComboBox->setEnabled(true);
        }
    }
    else
    {
        slicesComboBox->setEnabled(false);
        slicesComboBox->setCurrentIndex(-1);
    }
    // applyPushButton_clicked();
}

void LegendWindow::groupingModeComboBox_activated(int idx)
{
    Attributes *attrib = mapAttributes->value(attributesComboBox->currentText());

    if (idx == TObsStdDeviation)	 // standard deviation
    {
        frameTeQtStdColorBar->setVisible(true);
        //frameBTeQtColorBar->setColorBar(frameBTeQtColorBar->getInputColorVec());
        frameTeQtStdColorBar->setColorBar(attrib->getStdColorBar());
        frameTeQtStdColorBar->drawColorBar();

        slicesComboBox->setCurrentIndex(-1);
        slicesComboBox->setEnabled(false);

        stdDevComboBox->setCurrentIndex(0);
        stdDevComboBox->setEnabled(true);
    }
    else
    {
        if (frameTeQtStdColorBar->isVisible())
            frameTeQtStdColorBar->hide();

        if (idx == TObsUniqueValue)  // valor unico
        {
            slicesComboBox->setCurrentIndex(-1);
            slicesComboBox->setEnabled(false);
        }
        else
        {
            int s = attrib->getSlices();
            if (s == 0)
                s = 4;
            slicesComboBox->setCurrentIndex(s);
            slicesComboBox->setEnabled(true);
        }

        stdDevComboBox->setCurrentIndex(-1);
        stdDevComboBox->setEnabled(false);
    }

    //attrib->setGroupNumber(idx);

    applyPushButton->setEnabled(true);
    okPushButton->setEnabled(false);
}

void LegendWindow::applyPushButton_clicked()
{
    if (! mapAttributes->contains(attributesComboBox->currentText()))
        return;
        
    Attributes *attrib = mapAttributes->value(attributesComboBox->currentText());

    if ((attrib->getDataType() == TObsText)
            && (groupingModeComboBox->currentIndex() != TObsUniqueValue))
    {
        QString msg;
        msg = tr("The attribute \"%1\" is not a numerical value.").arg(attrib->getName());

        if (isVisible())
        {
            QMessageBox::information(this, windowTitle(), msg);
        }
        else
        {
            if (execModes != Quiet){
                string err_out = msg.toLatin1().constData();
                lua_getglobal(L, "customWarning");
                lua_pushstring(L, err_out.c_str());
                lua_call(L, 1, 0);
            }
        }
        groupingModeComboBox->setCurrentIndex(attrib->getGroupMode());
        slicesComboBox->setEnabled(false);
        return;
    }

    if ((groupingModeComboBox->currentIndex() != TObsUniqueValue)
            && (groupingModeComboBox->currentIndex() != TObsStdDeviation))
    {
        rows = slicesComboBox->currentText().toInt();
        if (rows == 0)
        {
            rows = 5;
            slicesComboBox->setCurrentIndex(4);
        }
        createView(rows);
        createColorVector();

        int idx = slicesComboBox->currentIndex();
        attrib->setSlices(idx);
        //legendTable->resizeColumnsToContents();
    }

    groupingAttribute(attrib);
    legendTable->resizeColumnsToContents();

    attrib->setPrecisionNumber(precisionComboBox->currentIndex());
    attrib->setGroupMode((GroupingMode) groupingModeComboBox->currentIndex());
    attrib->setStdDeviation((StdDev) stdDevComboBox->currentIndex());

    okPushButton->setEnabled(true);
    applyPushButton->setEnabled(false);
    attrValuesChanged = false;
}

void LegendWindow::okPushButton_clicked()
{
    commitFile();
    applyPushButton->setEnabled(false);

    makeAttribsBkp();

    connectSlots(false);
    attrValuesChanged = false;
    accept(); // close the window
}

void LegendWindow::makeAttribsBkp()
{
    QList<Attributes *> attribs = mapAttributes->values();

    for (int i = 0; i < attribs.size(); i++)
        attribs.at(i)->makeBkp();
}

//void LegendWindow::restoreAttribs()
//{
//    QList<Attributes *> attribs = mapAttributes->values();
//
//    for (int i = 0; i < attribs.size(); i++)
//        attribs.at(i)->restore();
//}

int LegendWindow::exec()
{
    connectSlots(true);
    attributesComboBox_activated(attributesComboBox->currentText());
    return QDialog::exec();
}

void LegendWindow::rejectWindow()
{
    hide();

    if (attrValuesChanged)
    {
        rollbackChanges(attributesComboBox->currentText());
        applyPushButton_clicked();
    }
    connectSlots(false);
    attrValuesChanged = false;
    QDialog::reject();
}

void LegendWindow::setValues(QHash<QString, Attributes*> *mapAttribs, const QStringList &attribs)
{
    mapAttributes = mapAttribs;
    makeAttribsBkp();
    createView(rows);
    insertAttributesCombo(attribs);
}

void LegendWindow::setAndAdjustTableColumns()
{
    //    legendTable->horizontalHeader()->setLabel(0, tr("Color"));
    //    if (groupingMode_ == TeUniqueValue){
    //        legendTable->horizontalHeader()->setLabel(1, tr("Value"));
    //        legendTable->horizontalHeader()->setLabel(2, tr("Label"));
    //        legendTable->horizontalHeader()->setLabel(3, tr("Count"));
    //        legendTable->setColumnReadOnly (1, true);		// Value
    //        legendTable->setColumnReadOnly (2, false);		// Label
    //        legendTable->setColumnReadOnly (3, true);		// Count
    //    }
    //    else {
    //        legendTable->horizontalHeader()->setLabel(1, tr("From"));
    //        legendTable->horizontalHeader()->setLabel(2, tr("To"));
    //        legendTable->horizontalHeader()->setLabel(3, tr("Label"));
    //        legendTable->horizontalHeader()->setLabel(4, tr("Count"));
    //        legendTable->setColumnReadOnly (1, false);		// From
    //        legendTable->setColumnReadOnly (2, false);		// To
    //        legendTable->setColumnReadOnly (3, false);		// Label
    //        legendTable->setColumnReadOnly (4, true);		// Count
    //}

    // Adjust the columns of the table
    //    legendTable->adjustColumn(0);
    //    legendTable->adjustColumn(1);
    //    legendTable->adjustColumn(2);
    //    legendTable->adjustColumn(3);
    //    if (groupingMode_ != TeUniqueValue)
    //        legendTable->adjustColumn(4);
}

void LegendWindow::colorChangedSlot()
{
    if (rows > 0)
    {
        createColorVector();
        applyPushButton_clicked();
    }
}

// in case of doubt see code in the file
// TeQtLegendSource.cpp, linha 526, method putColorOnLegend
void LegendWindow::createColorVector()
{
    std::vector<ColorBar> stdColorVec = frameTeQtStdColorBar->getInputColorVec();
    std::vector<ColorBar> colorVec = frameTeQtColorBar->getInputColorVec();

    // vector TeColor having the colors
    if (teColorVec)
        delete teColorVec;
    teColorVec = new std::vector<TeColor>();
    std::vector<TeColor> leftColorVec;

    if (rows == 1)
        rows++;

    if (groupingModeComboBox->currentIndex() != TObsStdDeviation) 
    {
        leftColorVec = getColors(colorVec, rows);

        for (unsigned i = 0; i < leftColorVec.size(); ++i)
            teColorVec->push_back(leftColorVec.at(i));
    }
    else	// standard deviation
    {
        Attributes *attrib = mapAttributes->value(attributesComboBox->currentText());
        QVector<ObsLegend> *vecLegend = attrib->getLegend();

        int leftColors = 0, rightColors = 0;
        int ii;
        for(ii = 0; ii < vecLegend->size(); ii++)
        {
            if (vecLegend->at(ii).getLabel().contains(MEAN))
                break;
        }
        leftColors = ii;
        rightColors = vecLegend->size() - ii - 1;

        // Bug fix: division by zero in  getColors method of TeColorUtils.cpp
        if (leftColors == 1)
            leftColors++;

        // Bug fix: division by zero in  getColors method of TeColorUtils.cpp
        if (rightColors == 1)
            rightColors++;

        leftColorVec = getColors(colorVec, leftColors);
        std::vector<TeColor> rightColorVec = getColors(stdColorVec, rightColors);

        unsigned ui;
        for (ui = 0; ui < leftColorVec.size(); ++ui)
            teColorVec->push_back(leftColorVec.at(ui));

        // if (ui > 0)
            teColorVec->push_back(leftColorVec.at(ui-1));

        for (ui = 0; ui < rightColorVec.size(); ++ui)
            teColorVec->push_back(rightColorVec.at(ui));

#ifdef OBSERVER_DEBUG
        for (int p = 0; p < leftColorVec.size(); p++)
            qDebug() << "(" << leftColorVec.at(p).red_ << ", "
                << leftColorVec.at(p).green_ << ", "
                << leftColorVec.at(p).blue_ << ")";

        qDebug() << "++++++++++++++++";

        for (int p = 0; p < rightColorVec.size(); p++)
            qDebug() << "(" << rightColorVec.at(p).red_ << ", "
                << rightColorVec.at(p).green_ << ", "
                << rightColorVec.at(p).blue_ << ")";

        qDebug() << "================";

        for (int p = 0; p < teColorVec->size(); p++)
            qDebug() << "(" << teColorVec->at(p).red_ << ", "
                << teColorVec->at(p).green_ << ", "
                << teColorVec->at(p).blue_ << ")";
#endif
    }
}

void LegendWindow::countElementsBySlices()
{
    QVector<double>::iterator it;
    double from, to;
    int occurrence;

    QAbstractItemModel *model = legendTable->model();

    Attributes *attrib = mapAttributes->value(attributesComboBox->currentText());
    QVector<double> *values = attrib->getNumericValues();
    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    legendTable->setRowCount(vecLegend->size());

    if (groupingModeComboBox->currentIndex() == TObsStdDeviation)  // standard deviation
    {
        for (int i = 0; i < vecLegend->size(); ++i)
        {
            ObsLegend leg = vecLegend->at(i);
            occurrence = 0;
            from = leg.getFromNumber();
            to = leg.getToNumber();

            if (! leg.getLabel().contains(MEAN))
            {
                // counting the occurrence of repeated values
                for (it = values->begin(); it != values->end(); ++it)
                {
                    if (*it >= from && *it < to)
                    {
                        occurrence++;
                        leg.setOccurrence(occurrence);
                        leg.setColor(teColorVec->at(leg.getIdxColor()).red_, 
                                teColorVec->at(leg.getIdxColor()).green_,
                                teColorVec->at(leg.getIdxColor()).blue_);
                        vecLegend->replace(i, leg);
                    }
                }

                switch (attrib->getType())
                {
                    case TObsAgent:
                    case TObsSociety:
                        model->setData(model->index(i, 0, QModelIndex()), 
                            symbol2Pixmap(leg.getColor(), attrib->getFont(), attrib->getSymbol()),
                            Qt::DecorationRole);
                        break;

                    case TObsNeighborhood:
                            model->setData(model->index(i, 0, QModelIndex()), 
                                color2PixmapLine(leg.getColor(), attrib->getWidth()), 
                                Qt::DecorationRole);
                        break;

                    default:
                            model->setData(model->index(i, 0, QModelIndex()), 
                                color2Pixmap(leg.getColor()), 
                                Qt::DecorationRole);
                        break;

            	}
                // // Hide the count display
                // model->setData(model->index(i, 4, QModelIndex()), leg.getOccurrence(),
                //            Qt::DisplayRole);
            }
            else
            {
                model->setData(model->index(i, 0, QModelIndex()), QString(""),
                            Qt::DecorationRole); // does not display color
                model->setData(model->index(i, 4, QModelIndex()), QString(""),
                            Qt::DisplayRole);
            }
            // displays in the table
            model->setData(model->index(i, 1, QModelIndex()), leg.getFrom(),
                        Qt::DisplayRole);
            model->setData(model->index(i, 2, QModelIndex()), leg.getTo(),
                        Qt::DisplayRole);
            model->setData(model->index(i, 3, QModelIndex()), leg.getLabel(),
                           Qt::DisplayRole);
        }
    }
    else
    {
        for (int i = 0; i < vecLegend->size(); ++i)
        {
            ObsLegend leg = vecLegend->at(i);
            occurrence = 0;
            from = leg.getFromNumber();
            to = leg.getToNumber();

            // counting the occurrence of repeated values
            for (it = values->begin(); it != values->end(); ++it)
			{
                if (*it >= from && *it < to)
				{
					occurrence++;
					leg.setOccurrence(occurrence);
					vecLegend->replace(i, leg);
				}
			}
				// displays in the table

            switch (attrib->getType())
            {
                case TObsAgent:
                case TObsSociety:
                    model->setData(model->index(i, 0, QModelIndex()), 
                        symbol2Pixmap(leg.getColor(), attrib->getFont(), attrib->getSymbol()),
					Qt::DecorationRole);
                    break;

                case TObsNeighborhood:
                        model->setData(model->index(i, 0, QModelIndex()), 
                            color2PixmapLine(leg.getColor(), attrib->getWidth()), 
                            Qt::DecorationRole);
                    break;

                default:
                        model->setData(model->index(i, 0, QModelIndex()), 
                            color2Pixmap(leg.getColor()), 
                            Qt::DecorationRole);
                    break;

			}

			for (it = values->begin(); it != values->end(); ++it)
			{
				if (*it >= from && *it < to)
				{
					occurrence++;
					leg.setOccurrence(occurrence);
					vecLegend->replace(i, leg);
				}
			}

			// displays in the table

            switch (attrib->getType())
            {
                case TObsAgent:
                case TObsSociety:
                    model->setData(model->index(i, 0, QModelIndex()), 
                        symbol2Pixmap(leg.getColor(), attrib->getFont(), attrib->getSymbol()),
							   Qt::DecorationRole);
                    break;

                case TObsNeighborhood:
                        model->setData(model->index(i, 0, QModelIndex()), 
                            color2PixmapLine(leg.getColor(), attrib->getWidth()), 
                            Qt::DecorationRole);
                    break;

                default:
                        model->setData(model->index(i, 0, QModelIndex()), 
                            color2Pixmap(leg.getColor()), 
                            Qt::DecorationRole);
                    break;

            }

			model->setData(model->index(i, 1, QModelIndex()), leg.getFrom(),
						   Qt::DisplayRole);
			model->setData(model->index(i, 2, QModelIndex()), leg.getTo(),
						   Qt::DisplayRole);
			model->setData(model->index(i, 3, QModelIndex()), leg.getLabel(),
						   Qt::DisplayRole);

            // // Hide the count display
            // model->setData(model->index(i, 4, QModelIndex()), leg.getOccurrence(),
            //               Qt::DisplayRole);
		}

        // show info "does not belong"
        //if (attrib->getType() == TObsTrajectory)
        //{
        //    int row = legendTable->rowCount() + 1;
        //    legendTable->setRowCount(row);

        //    model->setData(model->index(row - 1, 0, QModelIndex()), color2Pixmap(Qt::white),
        //                   Qt::DecorationRole);	// color
        //    model->setData(model->index(row - 1, 1, QModelIndex()), "-",
        //                   Qt::DisplayRole);		// from
        //    model->setData(model->index(row - 1, 2, QModelIndex()), "-",
        //                   Qt::DisplayRole);		// to
        //    model->setData(model->index(row - 1, 3, QModelIndex()), TRAJECTORY_LABEL,
        //                   Qt::DisplayRole);		// label
        //    model->setData(model->index(row - 1, 4, QModelIndex()), TRAJECTORY_COUNT,
        //                   Qt::DisplayRole);	// count
        //}
    }
}

void LegendWindow::groupingAttribute(Attributes *attrib)
{
    attrib->setColorBar(frameTeQtColorBar->getInputColorVec());
    attrib->setStdColorBar(frameTeQtStdColorBar->getInputColorVec());

    // fix for more and for less...
    double fix = pow(10, precisionComboBox->currentText().toDouble());
    fix = 1 / fix;

    // methods based on terraView
    switch (groupingModeComboBox->currentIndex())
    {

        case 0: // TObsEqualSteps
            // see method TeGroupByEqualStep in TeGroupingAlgorithms.(h, cpp)
            groupByEqualStep(fix, attrib);
            countElementsBySlices();
            break;

        case 1: // TObsQuantil
            // see method TeGroupByQuantil in TeGroupingAlgorithms.(h, cpp)
            groupByQuantil(fix, attrib);
            countElementsBySlices();
            break;

        case 2: // TObsStdDeviation
            // see method TeGroupByStdDev in TeGroupingAlgorithms.(h, cpp)
            groupByStdDeviation(fix, attrib);
            createColorVector();
            countElementsBySlices();
            break;

            // if this set "unique value" -- TObsUniqueValue
        case 3:
        default:
            // see method TeGroupByUniqueValue in TeGroupingAlgorithms.(h, cpp)
            groupByUniqueValue(fix, attrib);
    }
}

void LegendWindow::groupByEqualStep(double fix, Attributes *attrib)
{
    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    vecLegend->clear();

    int precision = precisionComboBox->currentText().toInt();

    double maxValue = attrib->getMaxValue();
    double minValue = attrib->getMinValue();
    double slice = (maxValue - minValue) / (rows * 1.0);

    for (int row = 0; row < rows; ++row)
    {
        QString from, to;

        if ((row != 0) && (row != rows - 1))
        {
            from = QString("%1").arg(minValue + double(row) * slice,
                                     0, 'f', precision);
            to = QString("%1").arg(minValue + double(row + 1) * slice,
                                   0, 'f', precision);
        }
        else // Corrects the legend for the first and last value
        {
            if (row == 0)
            {
                from = QString("%1").arg(minValue + double(row) * slice - fix,
                                         0, 'f', precision);
                to = QString("%1").arg(minValue + double(row + 1) * slice,
                                       0, 'f', precision);
            }
            else
            {
                from = QString("%1").arg(minValue + double(row) * slice,
                                         0, 'f', precision);
                to = QString("%1").arg(minValue + double(row + 1) * slice  + fix,
                                       0, 'f', precision);
            }
        }

        QString label = QString("%1 ~ %2").arg(from).arg(to);

        ObsLegend leg;
        leg.setFrom(from);
        leg.setTo(to);
        leg.setLabel(label);
        leg.setOccurrence(0);

        // retrieves the color already divided into slices
        leg.setColor(teColorVec->at(row).red_,
                teColorVec->at(row).green_,
                teColorVec->at(row).blue_);

        vecLegend->append(leg);
    }
}

void LegendWindow::groupByQuantil(double fix, Attributes *attrib)
{
    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    vecLegend->clear();

    // Caused permanent changes in the structure, fact that
    // generated disagreement in the data after changes in the legend
    // when made after the model end
    //QVector<double> *values = attrib->getNumericValues();
    std::vector<double> values = attrib->getNumericValues()->toStdVector();
    qStableSort(values.begin(), values.end());

    int precision = precisionComboBox->currentText().toInt();

    double step = values.size() / (rows * 1.0);

    int	n = 0;
    std::vector<double>::iterator it = values.begin();

#ifdef DEBUB_OBSERVER
    qDebug() << "values.end(): " << values.size();
    qDebug() << "teColorVec->size(): " << teColorVec->size();
    qDebug() << "step: " << step;
#endif

    while (it < values.end())
    {
        QString from;

        if (it == values.begin())
            from = QString("%1").arg(*it - fix , 0, 'f', precision);
        else
            from = QString("%1").arg(*it, 0, 'f', precision);

        int p = (int)(step * (double)++n + 0.5);
        it = values.begin() + p;

        QString to;
        if(it < values.end())
        {
            to = QString("%1").arg(*it, 0, 'f', precision);
        }
        else
        {
            if (it != values.end())
                to = QString("%1").arg(*(it-1), 0, 'f', precision);
            else
                to = QString("%1").arg(*(it-1) + fix , 0, 'f', precision);
        }

        QString label = QString("%1 ~ %2").arg(from).arg(to);
        
        ObsLegend leg;
        leg.setFrom(from);
        leg.setTo(to);
        leg.setLabel(label);
        leg.setOccurrence(0);

        // retrieves the color already divided into slices
        // n - 1 because the "n" is pre incremented (++n)
        leg.setColor(teColorVec->at(n - 1).red_, 
                teColorVec->at(n - 1).green_,
                teColorVec->at(n - 1).blue_);

        vecLegend->append(leg);
    }
}

void LegendWindow::groupByStdDeviation(double fix, Attributes *attrib)
{
    // Compute min, max and mean
    double	min = MAX_FLOAT;
    double	max = MIN_FLOAT;
    double	sum = 0.0, sm2 = 0.0;

    QVector<double>* values = attrib->getNumericValues();
    QVector<double>::iterator it = values->begin();

    while(it < values->end())
    {
        min = std::min(min, *it);
        max = std::max(max, *it);
        sum += (*it);
        sm2 += ((*it) * (*it));
        it++;
    }

    double cont = (double) values->size();
    double mean = sum / cont;
    long double var = (sm2 / cont) - (mean * mean);
    double sdev = sqrt(var);

    double ndev = stdDevComboBox->currentText().toDouble();
    int precision = precisionComboBox->currentText().toInt();

    double slice = sdev * ndev;
    double val = mean;
    int idxColor = 0;

    QString strMean = QString("%1").arg(mean , 0, 'f', precision);

    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    QVector<ObsLegend> *auxVecLegend = new QVector<ObsLegend>();
    vecLegend->clear();
    auxVecLegend->clear();

    while (val - slice > min - slice)
    {
        double v = val - slice;

        ObsLegend leg;
        leg.setFrom(QString("%1").arg(v, 0, 'f', precision));
        leg.setTo(QString("%1").arg(val, 0, 'f', precision));
        leg.setLabel(QString("%1 ~ %2").arg(leg.getFrom()).arg(leg.getTo()));

        auxVecLegend->append(leg);
        val = v;
    }

    if (auxVecLegend->size())
    {
        for (int i = auxVecLegend->size() - 1; i >= 0; i--)
        {
            ObsLegend leg = auxVecLegend->at(i);

            leg.setIdxColor(idxColor);
            idxColor++;
            vecLegend->append(leg);
        }
    }

    QString media = QString("%1 = %2").arg(MEAN).arg(strMean);

    ObsLegend leg;
    leg.setFrom(media);
    leg.setTo("");
    leg.setLabel(media);

    leg.setIdxColor(idxColor);
    idxColor++;

    vecLegend->append(leg);

    val = mean;
    while (val + slice < max + slice)
    {
        double v = val + slice;

        ObsLegend leg;
        leg.setFrom(QString("%1").arg(val, 0, 'f', precision));
        leg.setTo(QString("%1").arg(v, 0, 'f', precision));
        leg.setLabel(QString("%1 ~ %2")
                      .arg(leg.getFrom()).arg(leg.getTo()));

        leg.setIdxColor(idxColor);
        idxColor++;

        vecLegend->append(leg);
        val = v;
    }

    if(vecLegend->size() > 2)
    {
        // Corrige o valor minimo
        ObsLegend leg = vecLegend->at(0);
        leg.setFrom(QString("%1").arg(min - fix, 0, 'f', precision));

        if (! leg.getFrom().contains(MEAN))
        {
            leg.setLabel(QString("%1 ~ %2")
                          .arg(leg.getFrom()).arg(leg.getTo()));
        }
        vecLegend->replace(0, leg);

        // Corrige o valor maximo
        leg = vecLegend->at(vecLegend->size() - 1);
        leg.setTo(QString("%1").arg(max + fix, 0, 'f', precision));

        if (! leg.getFrom().contains(MEAN))
        {
            leg.setLabel(QString("%1 ~ %2")
                          .arg(leg.getFrom()).arg(leg.getTo()));
        }
        vecLegend->replace(vecLegend->size() - 1, leg);
    }
}

void LegendWindow::groupByUniqueValue(double /*fix*/, Attributes *attrib)
{
    if (attrib->getDataType() == TObsNumber)
        attrib->getValueList()->clear();

    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    vecLegend->clear();

    std::vector<double> numValues;
    std::vector<QString> txtValues;

    switch (attrib->getDataType())
    {
        case TObsNumber:
            numValues = attrib->getNumericValues()->toStdVector();
            qStableSort(numValues.begin(), numValues.end());

            for (unsigned int i = 0; i < numValues.size(); i++)
                txtValues.push_back(QString::number(numValues.at(i)));

            break;

        case TObsText:
            txtValues = attrib->getTextValues()->toStdVector();
            qStableSort(txtValues.begin(), txtValues.end());
            break;

        default:
            break;
    }

#ifdef DEBUG_OBSERVER
    qDebug() << "\n\nLegendWindow::groupByUniqueValue()\n"
        << "attrib->getType()" << getSubjectName((int) attrib->getType()) 
        << "  txtValues.size()" << txtValues.size() << "\n";
#endif


    if ((txtValues.empty()) 
            && (attrib->getType() != TObsAgent)
            && (attrib->getType() != TObsSociety)
            && (attrib->getType() != TObsAutomaton) 
            && (attrib->getType() != TObsTrajectory) 
      )
    {
        QString msg;
        msg = tr("The \"%1\" attribute has been configured incorrectly. An error might "
                    "have occurred when this attribute was defined in the legend.") 
                    .arg(attrib->getName());

        if (isVisible())
        {
            QMessageBox::information(this, windowTitle(), msg);
        }
        else
        {
            if (execModes != Quiet)
            {
				string str = msg.toLatin1().data();
				lua_getglobal(L, "customWarning");
				lua_pushstring(L, str.c_str());
				lua_call(L, 1, 0);
            }
        }
        // return;
    }

    unsigned int max = attrib->getMaxValue();
    int min = attrib->getMinValue();
    unsigned int i = 0;
    QString from;

    // Creates all possible inputs
    // considering the maximum and minimum values
    for (i = min; i <= max; i++)
    {
        ObsLegend leg;
        from = QString::number(i);

        leg.setIdxColor(i);
        leg.setFrom(from);
        leg.setLabel(from);
        leg.setTo(from);
        leg.setOccurrence(0);
        vecLegend->append(leg);

        if (attrib->getDataType() == TObsNumber)
            attrib->addValueListItem(from);
    }

    rows = max - min + 1;

    // Adds a row for the item "does not belong" in legend
    //if (attrib->getType() == TObsTrajectory)
    //{
    //    rows += 1;
    //    attrib->setLabelList(QStringList());
    //}

    createView(rows);
    createColorVector();

    int count = 1, vecLegendPos = 0;

    // counting the occurrence of values
    for (i = 1; i < txtValues.size(); i++)
    {
        if (txtValues.at(i - 1) == txtValues.at(i))
        {
            count++;
        }
        else
        {
            from = txtValues.at(i - 1);

            // adds the item and returns the index
            // case already contains the item returns the index
            vecLegendPos = attrib->addValueListItem(from);

            if (vecLegendPos >= vecLegend->size())
            {
                QString msg;
                msg = tr("Was found more values in the model than those reported in the legend for the "
                    "attribute \"%1\". Please, check the maximum and mininum value for this attribute.")
                    .arg(attrib->getName());
                
                if (isVisible())
                {
                    QMessageBox::information(this, windowTitle(), msg);
                }
                else
                {
                    if (execModes != Quiet)
                    {
						string str = msg.toLatin1().data();
						lua_getglobal(L, "customWarning");
						lua_pushstring(L, str.c_str());
						lua_call(L, 1, 0);
                    }
                }

                break;
            }
            
            ObsLegend leg;
            leg.setIdxColor(vecLegendPos);
            leg.setFrom(from);
            leg.setLabel(from);
            leg.setTo(from);
            leg.setOccurrence(count);

            vecLegend->replace(vecLegendPos, leg);
            count = 1;
        }
    }

    if (! txtValues.empty())
    {
        if ((i > 1) && (txtValues.at(i - 2) == txtValues.at(i - 1)))
        {
            from = txtValues.at(i - 1);
            vecLegendPos = attrib->addValueListItem(from);

            ObsLegend leg;
            leg.setIdxColor(vecLegendPos);
            leg.setFrom(from);
            leg.setLabel(from);
            leg.setTo(from);
            leg.setOccurrence(count);
            
            if (vecLegendPos < vecLegend->size())
                vecLegend->replace(vecLegendPos, leg);
        }
        else
        {
            from = txtValues.at(i - 1);
            vecLegendPos = attrib->addValueListItem(from);

            ObsLegend leg;
            leg.setIdxColor(vecLegendPos);
            leg.setFrom(from);

            leg.setTo(from);
            leg.setOccurrence(1);
            
            if (vecLegendPos < vecLegend->size())
            {
                vecLegend->replace(vecLegendPos, leg);
            }
            //else
            //{
            //    // qWarning() << "out of range -- " << from; 
            //    leg.setLabel("out of range");

            //    vecLegend->push_back(leg);
            //    rows++;
            //    createView(rows);
            //}
        }
    }
    
    QAbstractItemModel *model = legendTable->model();

#ifdef DEBUG_OBSERVER
    printf("\n\n rows: %i, vecLegend->size(): %i\n", rows, vecLegend->size());
#endif

    QStringList *values = attrib->getValueList();
    QStringList *labels = attrib->getLabelList();
    ObsLegend leg;

    for (i = 0; i < (unsigned int) vecLegend->size(); i++)
    {
        leg = vecLegend->at(i);
        QColor color;

        // Retrieves the label on the labels list
        if ((labels->size() == vecLegend->size()) && (values->size() == vecLegend->size()))
        {            
            leg.setLabel(labels->at(i));
            leg.setFrom(values->at(i));
            leg.setIdxColor(i);
        }

        if (leg.getIdxColor() < teColorVec->size())
        {
            leg.setColor(teColorVec->at(leg.getIdxColor()).red_,
                    teColorVec->at(leg.getIdxColor()).green_,
                    teColorVec->at(leg.getIdxColor()).blue_);

        }

        switch (attrib->getType())
        {
	        case TObsAgent:
	        case TObsSociety:
		        model->setData(model->index(i, 0, QModelIndex()), 
			        symbol2Pixmap(leg.getColor(), attrib->getFont(), attrib->getSymbol()),
				        Qt::DecorationRole);
		        break;

	        case TObsNeighborhood:
			        model->setData(model->index(i, 0, QModelIndex()), 
				        color2PixmapLine(leg.getColor(), attrib->getWidth()), 
				        Qt::DecorationRole);
		        break;

	        default:
			        model->setData(model->index(i, 0, QModelIndex()), 
				        color2Pixmap(leg.getColor()), 
				        Qt::DecorationRole);
		        break;

        }

        model->setData(model->index(i, 1, QModelIndex()), leg.getFrom(),
                       Qt::DisplayRole);		// value
        model->setData(model->index(i, 2, QModelIndex()), leg.getLabel(),
                       Qt::DisplayRole);		// label

        // // Hides the count display
        // model->setData(model->index(i, 3, QModelIndex()), leg.getOccurrence(),
        //               Qt::DisplayRole);	// count

        vecLegend->replace(i, leg);
    }

    // Displays the item "does not belong" in legend
    //if (attrib->getType() == TObsTrajectory)
    //{
    //    model->setData(model->index(rows - 1, 0, QModelIndex()), color2Pixmap(Qt::white),
    //                   Qt::DecorationRole);	// color
    //    model->setData(model->index(rows - 1, 1, QModelIndex()), "-",
    //                   Qt::DisplayRole);		// value
    //    model->setData(model->index(rows - 1, 2, QModelIndex()), TRAJECTORY_LABEL,
    //                   Qt::DisplayRole);		// label
    //    model->setData(model->index(rows - 1, 3, QModelIndex()), TRAJECTORY_COUNT,
    //                   Qt::DisplayRole);	// count
    //}
}

void LegendWindow::rollbackChanges(const QString & name)
{
    Attributes *attrib = mapAttributes->value(name);
    attrib->restore();
    frameTeQtColorBar->setColorBar(attrib->getColorBar());
    frameTeQtStdColorBar->setColorBar(attrib->getStdColorBar());

    frameTeQtColorBar->repaint();
    frameTeQtStdColorBar->repaint();
    // applyPushButton_clicked();
}

void LegendWindow::makeLegend()
{
#ifdef DEBUG_OBSERVER
    qDebug() << "LegendWindow::makeLegend() - keys.size(): " << mapAttributes->keys().size();
    qDebug() << "LegendWindow::makeLegend() - attribList: " << attribList;
#endif

    for (int i = 0; i < attribList.size(); i++)
    {
        attributesComboBox->setCurrentIndex(i);
        attributesComboBox_activated(attribList.at(i));
        applyPushButton_clicked();
    }
}

QPixmap LegendWindow::color2Pixmap(const QColor &color, const QSize size)
{
    QSize itemSize = size - QSize(1, 1);
    QImage img(size, QImage::Format_RGB32);

    //itemSize -= QSize(1, 1);
    QPainter p(&img);
    p.fillRect(img.rect(), Qt::white);

    // QPen pen(Qt::darkGray, 0.1);
    
    // Draws the border
    // p.setPen(Qt::black);
    p.setPen(Qt::NoPen);
    
    p.setBrush(color);
    p.drawRect(QRect(QPoint(0, 0), itemSize));
    p.end();

    return QPixmap::fromImage(img);
}

QPixmap LegendWindow::color2PixmapLine(const QColor &color, double width, const QSize size)
{
	QImage img(size, QImage::Format_RGB32);
    QPainter p(&img);
	p.fillRect(img.rect(), Qt::white);
    
    //// Draws the border
    //p.setPen(Qt::black);
    //p.setBrush(Qt::white);
    //p.drawRect(QRect(QPoint(0, 0), size - QSize(1, 1)));

	QPen pen(color);
	pen.setStyle(Qt::SolidLine);
	pen.setWidth(width);

	p.setPen(pen);
	p.drawLine(QLine(QPoint(0, (size.height() * 0.5)), 
        QPoint(size.width(), (size.height() * 0.5))));
	p.end();

    return QPixmap::fromImage(img);
}

QPixmap LegendWindow::symbol2Pixmap(const QColor& color, const QFont &font, const QString symbol,
    const QSize size)
{
    QSize itemSize = size - QSize(1, 1);
    QImage img(size, QImage::Format_RGB32);
    QPainter p(&img);
    p.fillRect(img.rect(), Qt::white);

    //// Draws the border
    //p.setPen(Qt::black);
    //p.setBrush(Qt::white);
    //p.drawRect(QRect(QPoint(0, 0), itemSize));

    QFont f = font;
    f.setBold(true);
    f.setPointSize(14);

    itemSize = size - QSize(2, 2);
	p.setPen(color);
    p.setBrush(Qt::white);
    p.setFont(f);
    p.drawText(QRect(QPoint(0, 0), itemSize), Qt::AlignCenter, symbol);
    p.end();

    return QPixmap::fromImage(img);
}

void LegendWindow::valueChanged()
{
    attrValuesChanged = true;
    // QMessageBox::information(this, "LegendWindow", "attributo modificado");
}

void LegendWindow::connectSlots(bool con)
{
    if (con)
    {
        connect(cancelPushButton, SIGNAL(clicked()), this,
                SLOT(rejectWindow())); //SLOT(reject()));
        connect(attributesComboBox, SIGNAL(activated(QString)), this,
                SLOT(attributesComboBox_activated(QString)));
        connect(attributesComboBox, SIGNAL(activated(QString)), this,
                SLOT(applyPushButton_clicked())); // Performs related slot to click the Ok button
        connect(functionComboBox, SIGNAL(activated(int)), this,
                SLOT(functionComboBox_activated(int)));

        connect(slicesComboBox, SIGNAL(activated(QString)), this,
                SLOT(slicesComboBox_activated(QString)));
        connect(slicesComboBox, SIGNAL(currentIndexChanged(QString)), this,
                SLOT(slicesComboBox_activated(QString)));

        connect(stdDevComboBox, SIGNAL(activated(QString)), this,
                SLOT(stdDevComboBox_activated(QString)));
        connect(precisionComboBox, SIGNAL(activated(QString)), this,
                SLOT(precisionComboBox_activated(QString)));
        connect(groupingModeComboBox, SIGNAL(activated(int)), this,
                SLOT(groupingModeComboBox_activated(int)));

        connect(okPushButton, SIGNAL(clicked()), this,
                SLOT(okPushButton_clicked()));
        // connect(helpPushButton, SIGNAL(clicked()), this,
        // SLOT(helpPushButton_clicked()));
        connect(invertColorsPushButton, SIGNAL(clicked()), this,
                SLOT(invertColorsPushButton_clicked()));
        connect(clearColorsPushButton, SIGNAL(clicked()), this,
                SLOT(clearColorsPushButton_clicked()));
        connect(equalSpacePushButton, SIGNAL(clicked()), this,
                SLOT(equalSpacePushButton_clicked()));

        connect(applyPushButton, SIGNAL(clicked()), this,
                SLOT(applyPushButton_clicked()));
        connect(legendTable, SIGNAL(cellDoubleClicked(int, int)), this,
                SLOT(legendTable_doubleClicked(int, int)));

        connect(frameTeQtColorBar, SIGNAL(colorChangedSignal()), this,
                SLOT(colorChangedSlot()));
        connect(frameTeQtStdColorBar, SIGNAL(colorChangedSignal()), this,
                SLOT(colorChangedSlot()));

        // Change checks the values of GUI objects
        //connect(attributesComboBox, SIGNAL(currentIndexChanged(int)), this,
        //        SLOT(valueChanged()));
        connect(functionComboBox, SIGNAL(currentIndexChanged(int)), this,
                SLOT(valueChanged()));
        connect(slicesComboBox, SIGNAL(currentIndexChanged(int)), this,
                SLOT(valueChanged()));
        connect(stdDevComboBox, SIGNAL(currentIndexChanged(int)), this,
                SLOT(valueChanged()));
        connect(precisionComboBox, SIGNAL(currentIndexChanged(int)), this,
                SLOT(valueChanged()));

        connect(frameTeQtColorBar, SIGNAL(colorChangedSignal()), this,
                SLOT(valueChanged()));
            connect(frameTeQtStdColorBar, SIGNAL(colorChangedSignal()), this,
                SLOT(valueChanged()));
    }
    else
    {
        disconnect(cancelPushButton, SIGNAL(clicked()), this,
                SLOT(rejectWindow())); //SLOT(reject()));
        disconnect(attributesComboBox, SIGNAL(activated(QString)), this,
                SLOT(attributesComboBox_activated(QString)));
        disconnect(attributesComboBox, SIGNAL(activated(QString)), this,
                SLOT(applyPushButton_clicked())); // Performs related slot to click the Ok button
        connect(functionComboBox, SIGNAL(activated(int)), this,
                SLOT(functionComboBox_activated(int)));

        disconnect(slicesComboBox, SIGNAL(activated(QString)), this,
                SLOT(slicesComboBox_activated(QString)));
        disconnect(slicesComboBox, SIGNAL(currentIndexChanged(QString)), this,
                SLOT(slicesComboBox_activated(QString)));

        disconnect(stdDevComboBox, SIGNAL(activated(QString)), this,
                SLOT(stdDevComboBox_activated(QString)));
        disconnect(precisionComboBox, SIGNAL(activated(QString)), this,
                SLOT(precisionComboBox_activated(QString)));
        disconnect(groupingModeComboBox, SIGNAL(activated(int)), this,
                SLOT(groupingModeComboBox_activated(int)));

        disconnect(okPushButton, SIGNAL(clicked()), this,
                SLOT(okPushButton_clicked()));
        // connect(helpPushButton, SIGNAL(clicked()), this,
        // SLOT(helpPushButton_clicked()));
        disconnect(invertColorsPushButton, SIGNAL(clicked()), this,
                SLOT(invertColorsPushButton_clicked()));
        disconnect(clearColorsPushButton, SIGNAL(clicked()), this,
                SLOT(clearColorsPushButton_clicked()));
        disconnect(equalSpacePushButton, SIGNAL(clicked()), this,
                SLOT(equalSpacePushButton_clicked()));

        disconnect(applyPushButton, SIGNAL(clicked()), this,
                SLOT(applyPushButton_clicked()));
        disconnect(legendTable, SIGNAL(cellDoubleClicked(int, int)), this,
                SLOT(legendTable_doubleClicked(int, int)));

        disconnect(frameTeQtColorBar, SIGNAL(colorChangedSignal()), this,
                SLOT(colorChangedSlot()));
        connect(frameTeQtStdColorBar, SIGNAL(colorChangedSignal()), this,
                SLOT(colorChangedSlot()));

        // Change checks the values of GUI objects
        //disconnect(attributesComboBox, SIGNAL(currentIndexChanged(int)), this,
        //        SLOT(valueChanged()));
        disconnect(functionComboBox, SIGNAL(currentIndexChanged(int)), this,
                SLOT(valueChanged()));
        disconnect(slicesComboBox, SIGNAL(currentIndexChanged(int)), this,
                SLOT(valueChanged()));
        disconnect(stdDevComboBox, SIGNAL(currentIndexChanged(int)), this,
                SLOT(valueChanged()));
        disconnect(precisionComboBox, SIGNAL(currentIndexChanged(int)), this,
                SLOT(valueChanged()));

        disconnect(frameTeQtColorBar, SIGNAL(colorChangedSignal()), this,
                SLOT(valueChanged()));
        disconnect(frameTeQtStdColorBar, SIGNAL(colorChangedSignal()), this,
                SLOT(valueChanged()));
    }
}

QString LegendWindow::enumToString(QString type, int e)
{
    if (type == "TypesOfData")
        return typesOfDataToString(e);
    else if (type == "GroupingMode")
        return groupingToString(e);
    else if (type == "StdDev")
        return stdDevToString(e);
    return QString("");
}

QString LegendWindow::typesOfDataToString(int e)
{
    QString str("\"");
    switch (e)
    {
        case (TObsBool):
            str += "bool";
            break;

        case (TObsNumber):
            str += "number";
            break;

        case (TObsDateTime):
            str += "datetime";
            break;

        case (TObsText):
            str += "text";
            break;

        default:
            str += "undefined";
    }
    str.append("\"");
    return str;
}

QString LegendWindow::groupingToString(int e)
{
    QString str("\"");
    switch (e)
    {
        case (TObsQuantil):
            str += "quantil";
            break;

        case (TObsStdDeviation):
            str += "stddeviation";
            break;

        case (TObsUniqueValue):
            str += "uniquevalue";
            break;

        default:
            str += "equalsteps";
    }
    str.append("\"");
    return str;
}

QString LegendWindow::stdDevToString(int e)
{
    QString str("\"");
    switch (e)
    {
        case (TObsFull):
            str += "full";
            break;

        case (TObsHalf):
            str += "half";
            break;

        case (TObsQuarter):
            str += "quarter";
            break;

        default:
            str += "none";
    }
    str.append("\"");
    return str;
}

void LegendWindow::commitFile()
{
    QFile file("legend.tol"); // tol -> TerraObserver Legend

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return;

    QTextStream out(&file);
    QStringList keys, legendKeys, legAttribs;
    const QString tabulation("    ");

    // insert the first line
    out << "Legend{\n";

    keys = mapAttributes->keys();

    legendKeys << TYPE << GROUP_MODE << SLICES << PRECISION 
            << STD_DEV << MAX << MIN 
            << SYMBOL << FONT_FAMILY << FONT_SIZE     // special attributes for agents
            << WIDTH /*<< STYLE*/                         // special attributes to the neighborhood and graphic
            << COLOR_BAR << STD_COLOR_BAR;          // color tables

    for (int i = 0; i < keys.size(); i++)
    {
        legAttribs.clear();   // clear the attributes vector
        Attributes *attrib = mapAttributes->value(keys.at(i));

        //legAttribs.push_back(attrib->getName());		// attribute name

        out << tabulation << "-- Attribute: " << attrib->getName() << "\n";

        legAttribs.push_back(enumToString("TypesOfData", attrib->getDataType()) + ", ");     // type

        legAttribs.push_back(enumToString("GroupingMode", attrib->getGroupMode()) + ", ");   // grouping
        legAttribs.push_back(QString::number(attrib->getSlices() + 1) + ", ");		// slices
        legAttribs.push_back(QString::number(attrib->getPrecisionNumber() + 1) + ", ");	// precision
        legAttribs.push_back(enumToString("StdDev", attrib->getStdDeviation()) + ", ");      // standard deviation %
        legAttribs.push_back(QString::number(attrib->getMaxValue()) + ", ");	// max value
        legAttribs.push_back(QString::number(attrib->getMinValue()) + ", ");		// min value

        legAttribs.push_back(QString("\"%1\"").arg(attrib->getSymbol()) + ", ");             // symbol
        legAttribs.push_back(QString("\"%1\"").arg(attrib->getFont().family()) + ", ");      // font
        legAttribs.push_back(QString::number(attrib->getFont().pointSize()) + ", ");		// font size

        legAttribs.push_back(QString::number(attrib->getWidth()) + ", ");                    // width

        // stdDevComboBox	// not used
        // functionComboBox	// not used
        // chrononComboBox	// not used

        std::vector<ColorBar> colorBarVec = attrib->getColorBar();
        QString colors; //("{\n" + tabulation + tabulation + tabulation);

        if ((int)colorBarVec.size() > 0)
        {
            colors = "{\n" + tabulation + tabulation;
            
            for (int j = 0; j < (int)colorBarVec.size(); j++)
            {
                QString color = QString("{color = {%1, %2, %3}, distance = %4}")    // formatting: "r g b dist; "
                        .arg(QString::number(colorBarVec.at(j).cor_.red_))
                        .arg(QString::number(colorBarVec.at(j).cor_.green_))
                        .arg(QString::number(colorBarVec.at(j).cor_.blue_))
                        .arg(QString::number(colorBarVec.at(j).distance_));

                if (j < (int)colorBarVec.size() - 1)
                    color.append(", \n" + tabulation + tabulation);
                else
                    color.append("\n");
                
                colors.append(color);
            }
            colors.append(tabulation + "}, ");
        }
        else{
            colors = "{}, ";
        }

        legAttribs.push_back(colors);

        colors.clear();
        colors.append("{\n" + tabulation + tabulation);

        if(attrib->getGroupMode() == TObsStdDeviation) // standard deviation
        {
            std::vector<ColorBar> colorBarVec = attrib->getStdColorBar();

            if ((int)colorBarVec.size() > 0){
                for (int j = 0; j < (int)colorBarVec.size(); j++)
                {
                    // formatting: "r g b dist; "
                    QString color = QString("{color = {%1, %2, %3}, distance = %4}")
                            .arg(QString::number(colorBarVec.at(j).cor_.red_))
                            .arg(QString::number(colorBarVec.at(j).cor_.green_))
                            .arg(QString::number(colorBarVec.at(j).cor_.blue_))
                            .arg(QString::number(colorBarVec.at(j).distance_));

                    if (j < (int)colorBarVec.size() - 1)
                        color.append(", \n" + tabulation + tabulation);
                    else
                        color.append("\n");
                    colors.append(color);
                }
            }
            colors.append(tabulation + "}");
        }
        else
        {
            colors = "{}";
        }

        // Adds the agent class
        if ((attrib->getType() == TObsAgent) || (attrib->getType() == TObsSociety))
        {
            legendKeys.push_back("class");
            legAttribs.push_back(attrib->getClassName());
        }

        legAttribs.push_back(colors);
    
        // dump in the file
        for (int k = 0; k < legendKeys.size(); k++)
        {
            out << tabulation << legendKeys.at(k) << " = " << legAttribs.at(k) << "\n";

#ifdef DEBUG_OBSERVER	
            printf("k: %i\t %s = %s\n", k, qPrintable(legendKeys.at(k)),
            qPrintable(legAttribs.at(k));
#endif
        }

        int idx = legendKeys.indexOf("class");
        if (idx > 0)
            legendKeys.removeAt(idx);

        // get another legend
        if (i < keys.size() - 1)
            out << "};\n\nLegend{\n";
        else
            out << "};\n";

#ifdef DEBUG_OBSERVER	
        printf("\n\n");
#endif
    }
    file.close();
}

void LegendWindow::setupUi()
{
    if (this->objectName().isEmpty())
        this->setObjectName(QString::fromUtf8("LegendWindow"));
    this->resize(582, 522);
    this->setMinimumSize(QSize(0, 0));
    this->setSizeGripEnabled(true);

    gridLayout = new QGridLayout(this);
    gridLayout->setSpacing(6);
    gridLayout->setContentsMargins(11, 11, 11, 11);
    gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
    vboxlayout_1 = new QVBoxLayout();
    vboxlayout_1->setSpacing(6);
    vboxlayout_1->setObjectName(QString::fromUtf8("vboxlayout_1"));
    groupingParamsGroupBox = new QGroupBox(this);
    groupingParamsGroupBox->setObjectName(QString::fromUtf8("groupingParamsGroupBox"));
    QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Fixed);
    sizePolicy.setHorizontalStretch(0);
    sizePolicy.setVerticalStretch(0);
    sizePolicy.setHeightForWidth(groupingParamsGroupBox->sizePolicy().hasHeightForWidth());
    groupingParamsGroupBox->setSizePolicy(sizePolicy);
    gridLayout1 = new QGridLayout(groupingParamsGroupBox);
    gridLayout1->setSpacing(6);
    gridLayout1->setContentsMargins(11, 11, 11, 11);
    gridLayout1->setObjectName(QString::fromUtf8("gridLayout1"));
    attributeTextLabel = new QLabel(groupingParamsGroupBox);
    attributeTextLabel->setObjectName(QString::fromUtf8("attributeTextLabel"));
    QSizePolicy sizePolicy1(QSizePolicy::Minimum, QSizePolicy::Minimum);
    sizePolicy1.setHorizontalStretch(0);
    sizePolicy1.setVerticalStretch(0);
    sizePolicy1.setHeightForWidth(attributeTextLabel->sizePolicy().hasHeightForWidth());
    attributeTextLabel->setSizePolicy(sizePolicy1);
    attributeTextLabel->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
    attributeTextLabel->setWordWrap(false);

    gridLayout1->addWidget(attributeTextLabel, 1, 0, 1, 1);

    groupingModeTextLabel = new QLabel(groupingParamsGroupBox);
    groupingModeTextLabel->setObjectName(QString::fromUtf8("groupingModeTextLabel"));
    groupingModeTextLabel->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
    groupingModeTextLabel->setWordWrap(false);

    gridLayout1->addWidget(groupingModeTextLabel, 0, 0, 1, 1);

    precisionTextLabel = new QLabel(groupingParamsGroupBox);
    precisionTextLabel->setObjectName(QString::fromUtf8("precisionTextLabel"));
    sizePolicy1.setHeightForWidth(precisionTextLabel->sizePolicy().hasHeightForWidth());
    precisionTextLabel->setSizePolicy(sizePolicy1);
    precisionTextLabel->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
    precisionTextLabel->setWordWrap(false);

    gridLayout1->addWidget(precisionTextLabel, 2, 2, 1, 1);

    slicesTextLabel = new QLabel(groupingParamsGroupBox);
    slicesTextLabel->setObjectName(QString::fromUtf8("slicesTextLabel"));
    sizePolicy1.setHeightForWidth(slicesTextLabel->sizePolicy().hasHeightForWidth());
    slicesTextLabel->setSizePolicy(sizePolicy1);
    slicesTextLabel->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
    slicesTextLabel->setWordWrap(false);

    gridLayout1->addWidget(slicesTextLabel, 2, 0, 1, 1);

    stdDevTextLabel = new QLabel(groupingParamsGroupBox);
    stdDevTextLabel->setObjectName(QString::fromUtf8("stdDevTextLabel"));
    stdDevTextLabel->setEnabled(false);
    QSizePolicy sizePolicy2(QSizePolicy::Minimum, QSizePolicy::Fixed);
    sizePolicy2.setHorizontalStretch(0);
    sizePolicy2.setVerticalStretch(0);
    sizePolicy2.setHeightForWidth(stdDevTextLabel->sizePolicy().hasHeightForWidth());
    stdDevTextLabel->setSizePolicy(sizePolicy2);
    stdDevTextLabel->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
    stdDevTextLabel->setWordWrap(false);

    gridLayout1->addWidget(stdDevTextLabel, 0, 4, 1, 3);

    functionTextLabel = new QLabel(groupingParamsGroupBox);
    functionTextLabel->setObjectName(QString::fromUtf8("functionTextLabel"));
    functionTextLabel->setEnabled(false);
    functionTextLabel->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
    functionTextLabel->setWordWrap(false);

    gridLayout1->addWidget(functionTextLabel, 1, 4, 1, 2);

    chrononTextLabel = new QLabel(groupingParamsGroupBox);
    chrononTextLabel->setObjectName(QString::fromUtf8("chrononTextLabel"));
    chrononTextLabel->setEnabled(false);
    sizePolicy1.setHeightForWidth(chrononTextLabel->sizePolicy().hasHeightForWidth());
    chrononTextLabel->setSizePolicy(sizePolicy1);
    chrononTextLabel->setAlignment(Qt::AlignRight|Qt::AlignTrailing|Qt::AlignVCenter);
    chrononTextLabel->setWordWrap(false);

    gridLayout1->addWidget(chrononTextLabel, 2, 4, 1, 1);

    hboxlayout_3 = new QHBoxLayout();
    hboxlayout_3->setSpacing(6);
    hboxlayout_3->setObjectName(QString::fromUtf8("hboxlayout_3"));
    spacer13 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    hboxlayout_3->addItem(spacer13);

    applyPushButton = new QPushButton(groupingParamsGroupBox);
    applyPushButton->setObjectName(QString::fromUtf8("applyPushButton"));

    hboxlayout_3->addWidget(applyPushButton);

    spacer14_2 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    hboxlayout_3->addItem(spacer14_2);


    gridLayout1->addLayout(hboxlayout_3, 3, 0, 1, 8);

    groupingModeComboBox = new QComboBox(groupingParamsGroupBox);
    groupingModeComboBox->setObjectName(QString::fromUtf8("groupingModeComboBox"));
    QSizePolicy sizePolicy3(QSizePolicy::Expanding, QSizePolicy::Fixed);
    sizePolicy3.setHorizontalStretch(0);
    sizePolicy3.setVerticalStretch(0);
    sizePolicy3.setHeightForWidth(groupingModeComboBox->sizePolicy().hasHeightForWidth());
    groupingModeComboBox->setSizePolicy(sizePolicy3);
    groupingModeComboBox->setMinimumSize(QSize(160, 0));

    gridLayout1->addWidget(groupingModeComboBox, 0, 1, 1, 3);

    slicesComboBox = new QComboBox(groupingParamsGroupBox);
    slicesComboBox->setObjectName(QString::fromUtf8("slicesComboBox"));
    sizePolicy2.setHeightForWidth(slicesComboBox->sizePolicy().hasHeightForWidth());
    slicesComboBox->setSizePolicy(sizePolicy2);
    slicesComboBox->setMinimumSize(QSize(50, 0));
    slicesComboBox->setEditable(true);

    gridLayout1->addWidget(slicesComboBox, 2, 1, 1, 1);

    precisionComboBox = new QComboBox(groupingParamsGroupBox);
    precisionComboBox->setObjectName(QString::fromUtf8("precisionComboBox"));
    sizePolicy2.setHeightForWidth(precisionComboBox->sizePolicy().hasHeightForWidth());
    precisionComboBox->setSizePolicy(sizePolicy2);
    precisionComboBox->setMinimumSize(QSize(50, 0));

    gridLayout1->addWidget(precisionComboBox, 2, 3, 1, 1);

    chrononComboBox = new QComboBox(groupingParamsGroupBox);
    chrononComboBox->setObjectName(QString::fromUtf8("chrononComboBox"));
    chrononComboBox->setEnabled(false);
    sizePolicy3.setHeightForWidth(chrononComboBox->sizePolicy().hasHeightForWidth());
    chrononComboBox->setSizePolicy(sizePolicy3);
    chrononComboBox->setMinimumSize(QSize(120, 0));

    gridLayout1->addWidget(chrononComboBox, 2, 5, 1, 3);

    functionComboBox = new QComboBox(groupingParamsGroupBox);
    functionComboBox->setObjectName(QString::fromUtf8("functionComboBox"));
    functionComboBox->setEnabled(false);
    functionComboBox->setMinimumSize(QSize(60, 0));

    gridLayout1->addWidget(functionComboBox, 1, 6, 1, 2);

    stdDevComboBox = new QComboBox(groupingParamsGroupBox);
    stdDevComboBox->setObjectName(QString::fromUtf8("stdDevComboBox"));
    stdDevComboBox->setEnabled(false);
    sizePolicy2.setHeightForWidth(stdDevComboBox->sizePolicy().hasHeightForWidth());
    stdDevComboBox->setSizePolicy(sizePolicy2);
    stdDevComboBox->setMinimumSize(QSize(60, 0));

    gridLayout1->addWidget(stdDevComboBox, 0, 7, 1, 1);

    attributesComboBox = new QComboBox(groupingParamsGroupBox);
    attributesComboBox->setObjectName(QString::fromUtf8("attributesComboBox"));
    sizePolicy3.setHeightForWidth(attributesComboBox->sizePolicy().hasHeightForWidth());
    attributesComboBox->setSizePolicy(sizePolicy3);
    attributesComboBox->setMinimumSize(QSize(160, 0));

    gridLayout1->addWidget(attributesComboBox, 1, 1, 1, 3);


    vboxlayout_1->addWidget(groupingParamsGroupBox);

    colorGroupBox = new QGroupBox(this);
    colorGroupBox->setObjectName(QString::fromUtf8("colorGroupBox"));
    sizePolicy.setHeightForWidth(colorGroupBox->sizePolicy().hasHeightForWidth());
    colorGroupBox->setSizePolicy(sizePolicy);
    gridLayout2 = new QGridLayout(colorGroupBox);
    gridLayout2->setSpacing(6);
    gridLayout2->setContentsMargins(11, 11, 11, 11);
    gridLayout2->setObjectName(QString::fromUtf8("gridLayout2"));
    frameTeQtStdColorBar = new TeQtColorBar(colorGroupBox);
    frameTeQtStdColorBar->setObjectName(QString::fromUtf8("frameBTeQtColorBar"));
    frameTeQtStdColorBar->setMinimumSize(QSize(384, 25));
    frameTeQtStdColorBar->setMouseTracking(true);

    gridLayout2->addWidget(frameTeQtStdColorBar, 1, 0, 1, 1);

    frameTeQtColorBar = new TeQtColorBar(colorGroupBox);
    frameTeQtColorBar->setObjectName(QString::fromUtf8("frameTeQtColorBar"));
    sizePolicy3.setHeightForWidth(frameTeQtColorBar->sizePolicy().hasHeightForWidth());
    frameTeQtColorBar->setSizePolicy(sizePolicy3);
    frameTeQtColorBar->setMinimumSize(QSize(384, 25));
    frameTeQtColorBar->setMouseTracking(true);

    gridLayout2->addWidget(frameTeQtColorBar, 0, 0, 1, 1);

    hboxlayout_2 = new QHBoxLayout();
    hboxlayout_2->setSpacing(6);
    hboxlayout_2->setObjectName(QString::fromUtf8("hboxlayout_2"));
    clearColorsPushButton = new QPushButton(colorGroupBox);
    clearColorsPushButton->setObjectName(QString::fromUtf8("clearColorsPushButton"));

    hboxlayout_2->addWidget(clearColorsPushButton);

    invertColorsPushButton = new QPushButton(colorGroupBox);
    invertColorsPushButton->setObjectName(QString::fromUtf8("invertColorsPushButton"));

    hboxlayout_2->addWidget(invertColorsPushButton);

    equalSpacePushButton = new QPushButton(colorGroupBox);
    equalSpacePushButton->setObjectName(QString::fromUtf8("equalSpacePushButton"));

    hboxlayout_2->addWidget(equalSpacePushButton);

    loadGroupBox = new QGroupBox(colorGroupBox);
    loadGroupBox->setObjectName(QString::fromUtf8("loadGroupBox"));
    loadGroupBox->setEnabled(false);
    gridLayout3 = new QGridLayout(loadGroupBox);
    gridLayout3->setSpacing(6);
    gridLayout3->setContentsMargins(11, 11, 11, 11);
    gridLayout3->setObjectName(QString::fromUtf8("gridLayout3"));
    loadNamesComboBox = new QComboBox(loadGroupBox);
    loadNamesComboBox->setObjectName(QString::fromUtf8("loadNamesComboBox"));
    loadNamesComboBox->setMinimumSize(QSize(160, 0));

    gridLayout3->addWidget(loadNamesComboBox, 0, 0, 1, 1);


    hboxlayout_2->addWidget(loadGroupBox);

    saveColorPushButton = new QPushButton(colorGroupBox);
    saveColorPushButton->setObjectName(QString::fromUtf8("saveColorPushButton"));
    saveColorPushButton->setEnabled(false);

    hboxlayout_2->addWidget(saveColorPushButton);


    gridLayout2->addLayout(hboxlayout_2, 2, 0, 1, 1);


    vboxlayout_1->addWidget(colorGroupBox);

    legendTable = new QTableWidget(this);
    legendTable->setObjectName(QString::fromUtf8("legendTable"));
    legendTable->setMinimumSize(QSize(0, 150));

    vboxlayout_1->addWidget(legendTable);

    hboxlayout_1 = new QHBoxLayout();
    hboxlayout_1->setSpacing(6);
    hboxlayout_1->setObjectName(QString::fromUtf8("hboxlayout_1"));
    spacer22 = new QSpacerItem(20, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    hboxlayout_1->addItem(spacer22);

    okPushButton = new QPushButton(this);
    okPushButton->setObjectName(QString::fromUtf8("okPushButton"));
    okPushButton->setDefault(true);

    hboxlayout_1->addWidget(okPushButton);

    spacer16 = new QSpacerItem(30, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    hboxlayout_1->addItem(spacer16);

    cancelPushButton = new QPushButton(this);
    cancelPushButton->setObjectName(QString::fromUtf8("cancelPushButton"));

    hboxlayout_1->addWidget(cancelPushButton);

    spacer14 = new QSpacerItem(16, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    hboxlayout_1->addItem(spacer14);

    helpPushButton = new QPushButton(this);
    helpPushButton->setObjectName(QString::fromUtf8("helpPushButton"));

    hboxlayout_1->addWidget(helpPushButton);

    spacer23 = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    hboxlayout_1->addItem(spacer23);


    vboxlayout_1->addLayout(hboxlayout_1);


    gridLayout->addLayout(vboxlayout_1, 0, 0, 1, 1);

    QWidget::setTabOrder(groupingModeComboBox, attributesComboBox);
    QWidget::setTabOrder(attributesComboBox, slicesComboBox);
    QWidget::setTabOrder(slicesComboBox, precisionComboBox);
    QWidget::setTabOrder(precisionComboBox, stdDevComboBox);
    QWidget::setTabOrder(stdDevComboBox, functionComboBox);
    QWidget::setTabOrder(functionComboBox, chrononComboBox);
    QWidget::setTabOrder(chrononComboBox, clearColorsPushButton);
    QWidget::setTabOrder(clearColorsPushButton, invertColorsPushButton);
    QWidget::setTabOrder(invertColorsPushButton, applyPushButton);
    QWidget::setTabOrder(applyPushButton, okPushButton);
    QWidget::setTabOrder(okPushButton, cancelPushButton);
    QWidget::setTabOrder(cancelPushButton, helpPushButton);

    retranslateUi();

} // setupUi

void LegendWindow::retranslateUi()
{
    this->setWindowTitle(QApplication::translate("LegendWindow", "Legend Editor", 0));
    groupingParamsGroupBox->setTitle(QApplication::translate("LegendWindow", "Grouping Parameters", 0));
    attributeTextLabel->setText(QApplication::translate("LegendWindow", "Attribute:", 0));
    groupingModeTextLabel->setText(QApplication::translate("LegendWindow", "Mode:", 0));
    precisionTextLabel->setText(QApplication::translate("LegendWindow", "Precision:", 0));
    slicesTextLabel->setText(QApplication::translate("LegendWindow", "Slices:", 0));
    stdDevTextLabel->setText(QApplication::translate("LegendWindow", "Standard Deviation:", 0));
    functionTextLabel->setText(QApplication::translate("LegendWindow", "Function:", 0));
    chrononTextLabel->setText(QApplication::translate("LegendWindow", "Chronon:", 0));
    applyPushButton->setText(QApplication::translate("LegendWindow", "&Apply", 0));
    applyPushButton->setShortcut(QApplication::translate("LegendWindow", "Alt+A", 0));
    colorGroupBox->setTitle(QApplication::translate("LegendWindow", "Colors", 0));
    clearColorsPushButton->setText(QApplication::translate("LegendWindow", "Clear", 0));
    invertColorsPushButton->setText(QApplication::translate("LegendWindow", "Invert", 0));
    equalSpacePushButton->setText(QApplication::translate("LegendWindow", "Equal Space", 0));
    loadGroupBox->setTitle(QApplication::translate("LegendWindow", "Load Color Bar", 0));
    loadNamesComboBox->clear();
    loadNamesComboBox->insertItems(0, QStringList()
                                   << QApplication::translate("LegendWindow", "      -------------------------------------", 0)
                                 );
    saveColorPushButton->setText(QApplication::translate("LegendWindow", "Save...", 0));
    okPushButton->setText(QApplication::translate("LegendWindow", "&OK", 0));
    okPushButton->setShortcut(QApplication::translate("LegendWindow", "Alt+O", 0));
    cancelPushButton->setText(QApplication::translate("LegendWindow", "&Cancel", 0));
    cancelPushButton->setShortcut(QApplication::translate("LegendWindow", "Alt+C", 0));
    helpPushButton->setText(QApplication::translate("LegendWindow", "&Help", 0));
    helpPushButton->setShortcut(QApplication::translate("LegendWindow", "Alt+H", 0));

} // retranslateUi


