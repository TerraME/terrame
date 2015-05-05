#ifndef PLOTPROPERTIES_H
#define PLOTPROPERTIES_H

#include <QDialog>
#include <QList>
#include <QHash>

#include "chartPlot.h"

class QMenu;
class QAction;
class QTreeWidgetItem;

namespace Ui {
class plotPropertiesGUI;
}

namespace TerraMEObserver {
	class InternalCurve;
}

// #include "internalCurve.h"


class PlotPropertiesGUI : public QDialog
{
    Q_OBJECT
    
public:
    PlotPropertiesGUI(TerraMEObserver::ChartPlot *plot); //, QWidget *parent = 0);
    virtual ~PlotPropertiesGUI();

    void consistGUI(QList<TerraMEObserver::InternalCurve *> *interCurves);
private slots:
    // general tab
    void borderColorClicked();
    void bckgrndColorClicked();
    void canvasColorClicked();

    void borderWidthValue(int);
    void marginValue(int);

    // fonts
    void titlesFontClicked();
    void labelsFontClicked();
    void scalesFontClicked();
    void legendFontClicked();

    // curve tab
    void selectedStyle(int);
    void selectedSymbol(int);
    void selectedLine(int);
    void curveWidthValue(int);
    void symbolSizeValue(int);
    void curveColorClicked();

    void currentItemChanged (QTreeWidgetItem * current, QTreeWidgetItem * previous);
private:
    void consistCurveTab(const QString &name);

    Ui::plotPropertiesGUI *ui;

    TerraMEObserver::ChartPlot *plotter;
    QHash<QString, TerraMEObserver::InternalCurve *> internalCurves;

    QMenu *axesContextMenu;
    QAction *labelsFontAct, *scalesFontAct;
    QString currentCurve;
};

#endif // PLOTPROPERTIES_H

