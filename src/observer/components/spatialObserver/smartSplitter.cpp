#include "smartSplitter.h"

#include <QSplitterHandle>


using namespace TerraMEObserver;

SmartSplitterHandle::SmartSplitterHandle(Qt::Orientation orientation, QSplitter *parent)
    : QSplitterHandle(orientation, parent)
{
    lastUncollapsedSize = 0;
}

SmartSplitterHandle::~SmartSplitterHandle()
{
}

void SmartSplitterHandle::mouseDoubleClickEvent(QMouseEvent * /*e*/)
{
    QSplitter *splitter = QSplitterHandle::splitter();

    int pos = splitter->indexOf(this);

    if (lastUncollapsedSize == 0)
    {
        QWidget *w = splitter->widget(pos);

        if (splitter->orientation() == Qt::Horizontal)
            lastUncollapsedSize = w->sizeHint().width();
        else
            lastUncollapsedSize = w->sizeHint().height();
    }

    int currSize = splitter->sizes().value(pos-1);

    if (currSize == 0)
    {
        moveSplitter(lastUncollapsedSize);
    }
    else
    {
        lastUncollapsedSize = currSize;
        moveSplitter(0);
    }
}


SmartSplitter::SmartSplitter(QWidget *parent)
    : QSplitter(parent)
{
}

SmartSplitter::SmartSplitter(Qt::Orientation o, QWidget *parent)
    : QSplitter(o, parent)
{
}

SmartSplitter::~SmartSplitter()
{
}

QSplitterHandle * SmartSplitter::createHandle()
{
    return new SmartSplitterHandle(orientation(), this);
}
