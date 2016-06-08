/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

#include "painterThread.h"

#include <QtGui/QPainter>
#include <QDebug>
#include <time.h>
#include "terrameGlobals.h"

#include "../legend/legendAttributes.h"

///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L;
extern ExecutionModes execModes;

using namespace TerraMEObserver;

PainterThread::PainterThread(QObject *parent)
    : QThread(parent)
{
    restart = false;
    abort = false;
    // defaultPen = QPen(Qt::NoPen);		// n?o desenha a grade

    //posicionar randomicamente os agentes na c?lula
    // para que seja poss?vel visualizar mais agentes
    // dentro da mesma c?lular
    //qsrand(time(NULL));
    qsrand(1);
}

PainterThread::~PainterThread()
{
    mutex.lock();
    abort = true;
    condition.wakeOne();
    mutex.unlock();

    wait();
}

//void PainterThread::render(double scaleFactor, QSize resultSize)
//{
//	QMutexLocker locker(&mutex);
//
//	this->resultSize = resultSize;
//
//	if (!isRunning()) {
//		start(LowPriority);
//	} else {
//		restart = true;
//		condition.wakeOne();
//	}
//}

void PainterThread::run()
{
    // qDebug() << "PainterThread::run()";

    //forever {

    //    //locker.unlock();

    //    // mutex.lock();
    //    //---- Atribui??es locais
    //    //QPainter *p = this->p;
    //    //Attributes *attrib = this->attrib;
    //    //QImage *img = this->img;
    //    //----
    //    // mutex.unlock();


    //    mutex.lock();
    //    if (! restart)
    //        condition.wait(&mutex);
    //    restart = false;
    //    //printf("===>> dormiu\n");
    //    mutex.unlock();

    //}
    exec();
}

void PainterThread::drawAttrib(QPainter *p, Attributes *attrib)
{
    if (attrib->getType() == TObsAgent)
        return;

    //---- Desenha o atributo
    p->begin(attrib->getImage());

    p->setPen(Qt::NoPen); //defaultPen);

	//@RAIAN: Desenhando a vizinhanca
	if (attrib->getType() == TObsNeighborhood)
	{
		QColor color(Qt::white);
                QVector<QMap<QString, QList<double> > > *neighborhoods = attrib->getNeighValues();
		QVector<ObsLegend> *vecLegend = attrib->getLegend();

		QPen pen = p->pen();
		pen.setStyle(Qt::SolidLine);
		pen.setWidth(attrib->getWidth());

        // int random = qrand() % 256;
		double xCell = -1.0, yCell = -1.0;

		for (int pos = 0; pos < neighborhoods->size(); pos++)
		{
            QMap<QString, QList<double> > neigh = neighborhoods->at(pos);

			xCell = attrib->getXsValue()->at(pos);
			yCell = attrib->getYsValue()->at(pos);

			if ((xCell >= 0) && (yCell >=0))
			{
                QMap<QString, QList<double> >::Iterator itNeigh = neigh.begin();

				while (itNeigh != neigh.end())
				{
					QString neighID = itNeigh.key();
					QList<double> neighbor = itNeigh.value();

					double xNeigh = neighbor.at(0);
					double yNeigh = neighbor.at(1);
					double weight = neighbor.at(2);

					if (vecLegend->isEmpty())
					{
						weight = weight - attrib->getMinValue();
						double c = weight * attrib->getVal2Color();
						if (c >= 0 && c <= 255)
						{
							color.setRgb(c, c, c);
						}
						else
						{
							color.setRgb(255, 255, 255);
						}

						pen.setColor(color);
					}
					else
					{
						for (int j = 0; j < vecLegend->size(); j++)
						{
							ObsLegend leg = vecLegend->at(j);
							if (attrib->getGroupMode() == 3)
							{
								if (weight == leg.getTo().toDouble())
								{
									pen.setColor(leg.getColor());
									break;
								}
							}
							else
							{
								if ((leg.getFrom().toDouble() <= weight) && (weight < leg.getTo().toDouble()))
								{
									pen.setColor(leg.getColor());
									break;
								}
							}
						}
					}
					p->setPen(pen);

					if ((xNeigh >= 0) && (yNeigh >= 0))
					{
						drawNeighborhood(p, xCell, yCell, xNeigh, yNeigh);
					}

					itNeigh++;
				}
			}
		}
	}
	//@RAIAN: FIM
	else
	{
		if (attrib->getDataType() == TObsNumber)
		{
			QColor color(Qt::white);
			QVector<double> *values = attrib->getNumericValues();
			QVector<ObsLegend> *vecLegend = attrib->getLegend();

			double x = -1.0, y = -1.0, v = 0.0;

			int vSize = values->size();
			int xSize = attrib->getXsValue()->size();
			int ySize = attrib->getYsValue()->size();

			for (int pos = 0; (pos < vSize && pos < xSize && pos < ySize); pos++)
			{
				v = values->at(pos);

				// Corrige o bug gerando quando um agente morre
				if (attrib->getXsValue()->isEmpty() || attrib->getXsValue()->size() == pos)
					break;

				x = attrib->getXsValue()->at(pos);
				y = attrib->getYsValue()->at(pos);

				if (vecLegend->isEmpty())
				{
					v = v - attrib->getMinValue();

					double c = v * attrib->getVal2Color();
					if ((c >= 0) && (c <= 255))
					{
						color.setRgb(c, c, c);
					}
					else
					{
						color.setRgb(255, 255, 255);
					}
					p->setBrush(color);
				}
				else
				{
					for (int j = 0; j < vecLegend->size(); j++)
					{
						p->setBrush(Qt::white);

						const ObsLegend &leg = vecLegend->at(j);
						if (attrib->getGroupMode() == TObsUniqueValue) // valor ?nico 3
						{
							if (v == leg.getToNumber())
							{
								p->setBrush(leg.getColor());
								break;
							}
						}
						else
						{
							if ((leg.getFromNumber() <= v) && (v < leg.getToNumber()))
							{
								p->setBrush(leg.getColor());
								break;
							}
						}
					}
				}
				if ((x >= 0) && (y >= 0))
					draw(p, attrib->getType(), x, y);
			}
		}
		else if (attrib->getDataType() == TObsText)
		{
			QVector<QString> *values = attrib->getTextValues();
			QVector<ObsLegend> *vecLegend = attrib->getLegend();

            int random = qrand() % 256;
			double x = -1.0, y = -1.0;

			int vSize = values->size();
			int xSize = attrib->getXsValue()->size();
			int ySize = attrib->getYsValue()->size();

			for (int pos = 0; (pos < vSize && pos < xSize && pos < ySize); pos++)
			{
				const QString & v = values->at(pos);

				// Corrige o bug gerando quando um agente morre
				if (attrib->getXsValue()->isEmpty() || attrib->getXsValue()->size() == pos)
					break;

				x = attrib->getXsValue()->at(pos);
				y = attrib->getYsValue()->at(pos);

				if (vecLegend->isEmpty())
				{
					p->setBrush(QColor(random, random, random));
				}
				else
				{
					p->setBrush(Qt::white);
					for (int j = 0; j < vecLegend->size(); j++)
					{
						const ObsLegend &leg = vecLegend->at(j);
						if (v == leg.getFrom())
						{
							p->setBrush(leg.getColor());
							break;
						}
					}
				}

				if ((x >= 0) && (y >= 0))
					draw(p, attrib->getType(), x, y);
			}
		}
	}
    p->end();
}


//void PainterThread::setVectorPos(QVector<double> *xs, QVector<double> *ys)
//{
//QMutexLocker locker(&mutex);

//this->xs = xs;
//this->ys = ys;

// a thread pode n?o ter os dados dos atributos
//if (!isRunning() && (this->p)) {
//	start(LowPriority);
//}// else {
//	restart = true;
//	condition.wakeOne();
//	//printf("--->>  acordou\n");
//}
//}

void PainterThread::draw(QPainter *p, TypesOfSubjects type, double &x, double &y)
{
    switch (type)
    {
        case TObsAutomaton:
            p->drawRect(SIZE_CELL * x, SIZE_CELL * y, SIZE_AUTOMATON, SIZE_AUTOMATON);
            break;

        case TObsAgent:
        {
            //double rx = qrand() %(SIZE_CELL - SIZE_AGENT);
            //double ry = qrand() %(SIZE_CELL - SIZE_AGENT);
            //p->setPen(Qt::SolidLine);
            //p->drawEllipse(SIZE_CELL * x + rx, SIZE_CELL * y + ry, SIZE_AGENT, SIZE_AGENT);
            break;
        }
        default:
            p->drawRect(SIZE_CELL * x, SIZE_CELL * y, SIZE_CELL, SIZE_CELL);
    }
}

//@RAIAN: Metodo que desenha a vizinhanca
void PainterThread::drawNeighborhood(QPainter *p, double &xCell, double &yCell, double &xNeighbor, double &yNeighbor)
{
	double coordXCell =(SIZE_CELL * xCell) +(SIZE_CELL/2);
	double coordYCell =(SIZE_CELL * yCell) +(SIZE_CELL/2);
	double coordXNeighbor =(SIZE_CELL * xNeighbor) +(SIZE_CELL/2);
	double coordYNeighbor =(SIZE_CELL * yNeighbor) +(SIZE_CELL/2);
	p->drawLine(coordXCell, coordYCell, coordXNeighbor, coordYNeighbor);

	// Desenha a cabeca da seta
	// TO DO
}
//@RAIAN: FIM


//void PainterThread::gridOn(bool on)
//{
//    if (on)
//        defaultPen = QPen(Qt::darkGray);// habilita desenhar a grade
//    else
//        defaultPen = QPen(Qt::NoPen);		// n?o desenha a grade
//
//}

void PainterThread::drawGrid(QImage &imgResult, double &width, double &height)
{
    mutex.lock();

    QPainter p(&imgResult);
    p.setPen(QPen(Qt::black));

    for (int j = 0; j < imgResult.height(); j++)
    {
        for (int i = 0; i < imgResult.width(); i++)
        {
            p.drawRect(QRectF(i * width, j * height, width, height));
        }
    }

    mutex.unlock();
}
