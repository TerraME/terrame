#include "calculateResult.h"
#include "legendAttributes.h"

#include <QImage>
#include <QDebug>

using namespace TerraMEObserver;
using namespace BagOfTasks;

#ifdef TME_STATISTIC
	// performance statistics
	#include "statistic.h"
#endif

CalculateResult::CalculateResult(const QSize &size,
		const QList<Attributes *> &attribList, QObject *parent)
    : imageSize(size), attribList(attribList),
	  QObject(parent), BagOfTasks::Task(Task::High)
{
    setType(Task::Arbitrary);
}

CalculateResult::~CalculateResult()
{
}

void CalculateResult::setAttributeList(const QList<Attributes *> &attribs)
{
    attribList = attribs;
}

void CalculateResult::setWidgetSize(const QSize &size)
{
    imageSize = size;
}

bool CalculateResult::execute()
{
#ifdef TME_STATISTIC
    // char block[30];
    double t = 0, renderCount = 0, renderSum;
    // sprintf(block, "%p", this);

    QString name = QString("zz__wait_task calculateResult %1").arg(getId());
    t = Statistic::getInstance().startMicroTime();
    waitTime = Statistic::getInstance().endMicroTime() - waitTime;
    Statistic::getInstance().addElapsedTime(name, waitTime);
#endif

    result = QImage(imageSize, QImage::Format_ARGB32_Premultiplied);
    /// result.fill(Qt::white);
	result.fill(0);
    // result.fill(Qt::darkBlue);

    QPainter painter(&result);
    //// painter.fillRect(result.rect(), Qt::transparent); // Qt::white);
    //// painter.fillRect(result.rect(), QColor(255, 255, 255, 127));  // Qt::white);
    //painter.setPen(Qt::black);
    //painter.drawRect(result.rect());


    Attributes * attrib = 0;
    for (int i = 0; i < attribList.size(); i++)
    {
        // Resets the composition mode of painter
        // painter.setCompositionMode(QPainter::CompositionMode_SourceOver);

        attrib = attribList.at(i);

#ifdef DEBUG_OBSERVER
        qDebug() << "CalculateResult::execute()" << attrib->getName();  std::cout.flush();
#endif

        if ((attrib && attrib->getVisible()) &&
            ((attrib->getType() != TObsAgent) || ((attrib->getType() != TObsSociety))))
        {
            switch(attrib->getType())
            {
            case TObsCell:
                painter.setCompositionMode(QPainter::CompositionMode_Multiply);
                break;

            case TObsTrajectory:

            case TObsNeighborhood:
                painter.setCompositionMode(QPainter::CompositionMode_SourceOver);
                break;

            //case TObsTrajectory:
            default:
                painter.setCompositionMode(QPainter::CompositionMode_HardLight);
                // // painter.setCompositionMode(QPainter::CompositionMode_Difference);
                break;
            }

#ifdef TME_STATISTIC
            tt = Statistic::getInstance().startMicroTime();

            painter.drawImage(POINT, *attrib->getImage());

            renderSum += Statistic::getInstance().endMicroTime() - tt;
            renderCount++;
#else

            if (attrib)
                painter.drawImage(ZERO_POINT, *attrib->getImage());

#ifdef DEBUG_OBSERVER
            static int o = 0;
            o++;
            if (attrib->getType() == TObsAutomaton) // TObsTrajectory)
                attrib->getImage()->save(QString("obj_%1.png").arg(o), "png");
            //else
            //    attrib->getImage()->save(QString("cs_%1.png").arg(o), "png");
#endif

#endif

        }
    }
    painter.end();

    emit displayImage(result);

#ifdef DEBUG_OBSERVER
    static int g = 0;
    g++;
    result.save(QString("result_%1.png").arg(g), "png");
#endif

#ifdef TME_STATISTIC
    Statistic::getInstance().addElapsedTime("rendering calculateResult",
        (renderCount > 0 ? renderSum / renderCount : -1));

    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime("zz_calculateResult::execute", t);
#endif

    return true;
}
