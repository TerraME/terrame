#ifndef SPATIALOBSERVERSUI_H
#define SPATIALOBSERVERSUI_H

#include <QDialog>

class QToolButton;
class QToolBar;
class QComboBox;
class QActionGroup;
class QGraphicsScene;

namespace Ui {
class spatialObserverGUI;
}

class SpatialObserverGUI : public QDialog
{
    Q_OBJECT
    
public:
    explicit SpatialObserverGUI(QWidget *parent = 0);
    ~SpatialObserverGUI();
    
signals:

public slots:

private slots:
    void legendClicked();
    void gridClicked();
    void zoomInClicked();
    void zoomOutClicked();

private:
    void setupToolBars();

    Ui::spatialObserverGUI *ui;

    QToolBar *toolBar;
    QAction *actLegend, *actGrid;
    QAction *actHand, *actZoomWindow;
    QAction *actZoomRestore, *actZoomIn;
    QAction *actZoomOut;

//    QToolButton *butLegend, *butGrid;
//    QToolButton *butHand, *butZoomWindow;
//    QToolButton *butZoomRestore, *butZoomIn;
//    QToolButton *butZoomOut;
    QComboBox *zoomComboBox;
    QActionGroup *actionGroup;

    QGraphicsScene *scene;

};

#endif // SPATIALOBSERVERSUI_H
