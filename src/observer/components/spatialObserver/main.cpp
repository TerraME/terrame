#ifdef OBSERVER_REFACTORING

#include "spatialObserverGUI.h"
#include <QApplication>

int main(int argc, char *argv[])
{

    QApplication a(argc, argv);
    SpatialObserverGUI w;
    w.show();

    return a.exec();
}

#endif
