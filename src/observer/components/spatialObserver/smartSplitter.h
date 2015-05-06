#ifndef SMARTSPLITTER_H
#define SMARTSPLITTER_H

#include <QSplitter>

class QSplitterHandle;

namespace TerraMEObserver
{

class SmartSplitterHandle : public QSplitterHandle
{
    // Q_OBJECT

public:
    SmartSplitterHandle(Qt::Orientation orientation, QSplitter *parent);
    virtual ~SmartSplitterHandle();
    void mouseDoubleClickEvent(QMouseEvent *e);

private:
    int lastUncollapsedSize;

};

class SmartSplitter : public QSplitter
{
    // Q_OBJECT
    friend class SmartSplitterHandle;

public:
    SmartSplitter(QWidget *parent = 0);
    SmartSplitter(Qt::Orientation o, QWidget *parent = 0);
    virtual ~SmartSplitter();

protected:
    QSplitterHandle * createHandle();
    
};

} // namespace TerraMEObserver

#endif // SMARTSPLITTER_H
