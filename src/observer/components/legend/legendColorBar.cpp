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

#include <QColor>
#include "legendColorUtils.h"
#include "legendColorBar.h"
#include <QCursor>
#include <QMenu>
#include <QPainter>
#include <QColorDialog>

#include <QMouseEvent>

//#include <help.h>
#include <algorithm>

using namespace TerraMEObserver;

TeQtColorBar::TeQtColorBar(QWidget* parent) : QFrame(parent)
{
    //help_ = 0;
    vertical_ = true;
    upDown_ = false;
    colorEdit_ = 0;

    ftam_ = frameRect().width();
    if (vertical_)
        ftam_ = frameRect().height();

    //popupMenu_.insertItem(tr("Add Color..."), this, SLOT(addColorSlot()));
    //popupMenu_.insertItem(tr("Change Color..."), this, SLOT(changeColorSlot()));
    //popupMenu_.insertItem(tr("Remove Color"), this, SLOT(removeColorSlot()));
    //popupMenu_.insertItem(tr("Help..."), this, SLOT(helpSlot()));

    addColor = popupMenu_.addAction(tr("Add Color..."), this, SLOT(addColorSlot()));
    removeColor = popupMenu_.addAction(tr("Change Color..."), this, SLOT(changeColorSlot()));
    changeColor = popupMenu_.addAction(tr("Remove Color"), this, SLOT(removeColorSlot()));
}


TeQtColorBar::~TeQtColorBar()
{
    //delete addColor;
    //delete removeColor;
    //delete changeColor;

    delete colorEdit_;
}

void TeQtColorBar::setVerticalBar(bool b)
{
    vertical_ = b;

    ftam_ = frameRect().width();
    if (vertical_)
        ftam_ = frameRect().height();
}

void TeQtColorBar::setColorBar(const vector<ColorBar>& colorBarVec)
{
    inputColorVec_.clear();
    inputColorVec_ = colorBarVec;

    sort(inputColorVec_.begin(), inputColorVec_.end());

    if ((int)inputColorVec_.empty() == false)
        inputColorVec_[0].distance_ = 0.;

    generateColorMap();
}

void TeQtColorBar::setColorBar(const vector<TeColor>& colorVec)
{
    int	i;

    inputColorVec_.clear();
    vector<ColorBar> cbVec;
    ColorBar cb;

    for (i = 0; i <(int)colorVec.size(); i++)
    {
        cb.color(colorVec[i]);
        cbVec.push_back(cb);
    }

    if (cbVec.size() == 1)
    {
        TeColor c = colorVec[0];
        c.red_ = c.red_ / 5;
        c.green_ = c.green_ / 5;
        c.blue_ = c.blue_ / 5;

        cb.color(c);
        cbVec.push_back(cb);
    }

    for (i = 0; i <(int)cbVec.size(); ++i)
    {
        cbVec[i].distance_ =(double)i;
        inputColorVec_.push_back(cbVec[i]);
    }

    generateColorMap();
}

void TeQtColorBar::setColorBarFromNames(string colors)
{
    int	i;
    if (colors.empty())
        colors = "W";

    vector<string> colorNameVec;
    QString s(colors.c_str());
    QStringList ss = s.split("-");

    for (i = 0; i <(int)ss.size(); i++)
    {
        QString a = ss[i];
        if (tr("R") == a)
            colorNameVec.push_back("RED");
        else if (tr("G") == a)
            colorNameVec.push_back("GREEN");
        else if (tr("B") == a)
            colorNameVec.push_back("BLUE");
        else if (tr("Cy") == a)
            colorNameVec.push_back("CYAN");
        else if (tr("Or") == a)
            colorNameVec.push_back("ORANGE");
        else if (tr("Mg") == a)
            colorNameVec.push_back("MAGENTA");
        else if (tr("Y") == a)
            colorNameVec.push_back("YELLOW");
        else if ((tr("Bl") == a) ||(tr("BL") == a))
            colorNameVec.push_back("BLACK");
        else if (tr("W") == a)
            colorNameVec.push_back("WHITE");
        else
            colorNameVec.push_back("GRAY");
    }

	TeColor	RGB;
    map<string, TeColor> mapcor;

    RGB.name_ = "RED";
    RGB.red_ = 240;
    RGB.green_ = 0;
    RGB.blue_ = 0;
    mapcor["RED"] = RGB;

    RGB.name_ = "GREEN";
    RGB.red_ = 0;
    RGB.green_ = 240;
    RGB.blue_ = 0;
    mapcor["GREEN"] = RGB;

    RGB.name_ = "BLUE";
    RGB.red_ = 0;
    RGB.green_ = 0;
    RGB.blue_ = 240;
    mapcor["BLUE"] = RGB;

    RGB.name_ = "YELLOW";
    RGB.red_ = 255;
    RGB.green_ = 255;
    RGB.blue_ = 100;
    mapcor["YELLOW"] = RGB;

    RGB.name_ = "CYAN";
    RGB.red_ = 100;
    RGB.green_ = 255;
    RGB.blue_ = 255;
    mapcor["CYAN"] = RGB;

    RGB.name_ = "MAGENTA";
    RGB.red_ = 255;
    RGB.green_ = 100;
    RGB.blue_ = 255;
    mapcor["MAGENTA"] = RGB;

    RGB.name_ = "ORANGE";
    RGB.red_ = 255;
    RGB.green_ = 140;
    RGB.blue_ = 0;
    mapcor["ORANGE"] = RGB;

    RGB.name_ = "GRAY";
    RGB.red_ = 240;
    RGB.green_ = 240;
    RGB.blue_ = 240;
    mapcor["GRAY"] = RGB;

    RGB.name_ = "BLACK";
    RGB.red_ = 0;
    RGB.green_ = 0;
    RGB.blue_ = 0;
    mapcor["BLACK"] = RGB;

    RGB.name_ = "WHITE";
    RGB.red_ = 255;
    RGB.green_ = 255;
    RGB.blue_ = 255;
    mapcor["WHITE"] = RGB;

    vector<ColorBar> cbVec;
    for (i = 0; i <(int)colorNameVec.size(); ++i)  {
        ColorBar cb;
        cb.color(mapcor[colorNameVec[i]]);
        cbVec.push_back(cb);
    }

    if (inputColorVec_.size() == 1){
        ColorBar cb;
        TeColor c = inputColorVec_[0].cor_;

        c.red_ = c.red_ / 5;
        c.green_ = c.green_ / 5;
        c.blue_ = c.blue_ / 5;

        cb.color(c);
        cbVec.push_back(cb);
    }

    inputColorVec_.clear();
    for (i = 0; i <(int)cbVec.size(); ++i) {
        cbVec[i].distance_ =(double)i;
        inputColorVec_.push_back(cbVec[i]);
    }

    generateColorMap();
}

void TeQtColorBar::generateColorMap()
{
    sortByDistance();
    generateColorBarMap(inputColorVec_, ftam_, colorMap_);
    totalDistance_ = 1.;
    if (inputColorVec_.empty() == false)
        totalDistance_ = inputColorVec_[inputColorVec_.size()-1].distance_;
}

void TeQtColorBar::drawColorBar()
{
    repaint();

    //	if (colorMap_.empty())
    //		return;
    //
    //	int	i, j = 0, size, tsize;
    //	QColor cor;
    //	map<int, vector<TeColor> > :: iterator it = colorMap_.begin();

    //	QRect rect = frameRect();
    //	int w = rect.width();
    //	int	h = rect.height();
    //	changeVec_.clear();
    //	changeVec_.push_back(0);
    //        //QPainter painter(this);
    //        QPainterPath painterPath;

    //painterPath = painter.clipPath();

    //	tsize = w;
    //	if (vertical_)
    //		tsize = h;
    //
    //	while (it != colorMap_.end())
    //	{
    //		vector<TeColor>& colorVec = it->second;
    //		size =(int)colorVec.size();
    //
    //		i = 0;
    //		while (i < size)
    //		{
    //			cor.setRgb(colorVec[i].red_, colorVec[i].green_, colorVec[i].blue_);
    //                        //painter.setPen(cor);
    //			if (vertical_)
    //			{
    //				if (upDown_)
    //				{
    //                                        painterPath.lineTo(0, j);
    //                                        painterPath.moveTo(w-7, j);
    //				}
    //				else
    //				{
    //                                        painterPath.lineTo(0, h-j);
    //                                        painterPath.moveTo(w-7, h-j);
    //				}
    //			}
    //			else
    //			{
    //                                painterPath.lineTo(j, 7);
    //                                painterPath.moveTo(j, h);
    //			}
    //			i++;
    //			j++;
    //		}
    //		it++;
    //		if (it == colorMap_.end())
    //		{
    //			while (j < tsize)
    //			{
    //				if (vertical_)
    //				{
    //					if (upDown_)
    //					{
    //                                                painterPath.lineTo(0, j);
    //                                                painterPath.moveTo(w-7, j);
    //					}
    //					else
    //					{
    //                                                painterPath.lineTo(0, h-j);
    //                                                painterPath.moveTo(w-7, h-j);
    //					}
    //				}
    //				else
    //				{
    //                                        painterPath.lineTo(j, 7);
    //                                        painterPath.moveTo(j, h);
    //				}
    //				j++;
    //			}
    //		}
    //		if (j-1 < 0)
    //			changeVec_.push_back(0);
    //		else if (j >= tsize)
    //			changeVec_.push_back(tsize-1);
    //		else
    //			changeVec_.push_back(j);
    //	}

    //       QPainter painter(this);
    //        painter.drawRect(rect);
    //painter.drawPath(painterPath);

    //        painter.setPen(Qt::black);
    //        painter.setBrush(Qt::white);

    //	QRect ru(0, 0, w, 7);
    //	if (vertical_)
    //		ru.setRect(w-7, 0, 7, h);
    //        painter.drawRect(ru);

    //        QPolygon pa(4);
    //	if (vertical_)
    //	{
    //		pa.setPoint(0, 0, 0);
    //		pa.setPoint(1, 6, -3);
    //		pa.setPoint(2, 6, 3);
    //		pa.setPoint(3, 0, 0);
    //                painter.drawPolygon(pa);
    //		pa.translate(0, h-1);
    //                painter.drawPolygon(pa);
    //		pa.translate(0, -(h-1));
    //		if (!upDown_)
    //			pa.translate(0, h);
    //
    //	}
    //	else
    //	{
    //		pa.setPoint(0, -3, 0);
    //		pa.setPoint(1, 3, 0);
    //		pa.setPoint(2, 0, 6);
    //		pa.setPoint(3, -3, 0);
    //                painter.drawPolygon(pa);
    //		pa.translate(w-1, 0);
    //                painter.drawPolygon(pa);
    //		pa.translate(-(w-1), 0);
    //	}
    //
    //	it = colorMap_.begin();
    //	while (it != colorMap_.end())
    //	{
    //		j = it->second.size();
    //		it++;
    //		if (it != colorMap_.end())
    //		{
    //			if (vertical_)
    //			{
    //				if (upDown_)
    //					pa.translate(0, j);
    //				else
    //					pa.translate(0, -j);
    //			}
    //			else
    //				pa.translate(j, 0);
    //                        painter.drawPolygon(pa);
    //		}
    //	}
    //
    //        painter.setBrush(Qt::NoBrush);
    //        painter.setPen(Qt::black);
    //
    //	double pd =(double)tsize / 10.;
    //	int	t;
    //	for (i=0; i<10; ++i)
    //	{
    //		t = 5;
    //		if (i%2)
    //			t = 3;
    //
    //		int a = TeRound((double)i * pd);
    //		if (vertical_)
    //		{
    //                        painterPath.moveTo(0, a);
    //                        painterPath.lineTo(t, a);
    //		}
    //		else
    //		{
    //                        painterPath.moveTo(a, h);
    //                        painterPath.lineTo(a, h-t);
    //		}
    //	}
    //        painter.drawPath(painterPath);
    //        painter.setPen(Qt::blue);
    //        painter.drawRect(rect);
}

void TeQtColorBar::paintEvent(QPaintEvent *)
{
    if (colorMap_.empty())
        return;

    int	i = 0, j = 0, size = 0, tsize = 0;
    QColor cor;
    map<int, vector<TeColor> > :: iterator it = colorMap_.begin();

    QRect rect = this->rect(); //frameRect();
    int w = rect.width(); //  - 1;
    int h = rect.height(); // - 1;
    changeVec_.clear();
    changeVec_.push_back(0);
    //QPainterPath painterPath;
    QPainter painter(this);

    tsize = w;
    if (vertical_)
        tsize = h;

    painter.setPen(Qt::NoPen);

    while (it != colorMap_.end())
    {
        vector<TeColor>& colorVec = it->second;
        size =(int)colorVec.size();

        i = 0;
        while (i < size)
        {
            //            int r = colorVec[i].red_;
            //            int g = colorVec[i].green_;
            //            int b = colorVec[i].blue_;
            //
            //            cor.setRgb(r, g, b);

            cor.setRgb(colorVec[i].red_, colorVec[i].green_, colorVec[i].blue_);
            painter.setPen(cor);

            //qvecColor.append(cor);

            if (vertical_)
            {
                if (upDown_)
                {
                    //painter.lineTo(0, j);
                    //painter.moveTo(w-7, j);
                    painter.drawLine(0, j, w-7, j);
                }
                else
                {
                    //painter.lineTo(0, h-j);
                    //painter.moveTo(w-7, h-j);
                    painter.drawLine(0, h-j, w-7, h-j);
                }
            }
            else
            {
                //painter.lineTo(j, 7);
                //painter.moveTo(j, h);
                painter.drawLine(j, 7, j, h);
            }
            i++;
            j++;
        }
        //painter.drawPath(painterPath);

        it++;
        if (it == colorMap_.end())
        {
            while (j < tsize)
            {
                if (vertical_)
                {
                    if (upDown_)
                    {
                        //painter.lineTo(0, j);
                        //painter.moveTo(w-7, j);
                        painter.drawLine(0, j, w-7, j);
                    }
                    else
                    {
                        //painter.lineTo(0, h-j);
                        //painter.moveTo(w-7, h-j);
                        painter.drawLine(0, h - j, w - 7, h - j);
                    }
                }
                else
                {
                    //painter.lineTo(j, 7);
                    //painter.moveTo(j, h);
                    painter.drawLine(j, 7, j, h);
                }
                j++;
            }
        }
        if (j-1 < 0)
            changeVec_.push_back(0);
        else if (j >= tsize)
            changeVec_.push_back(tsize-1);
        else
            changeVec_.push_back(j);
    }

    //painter.drawPath(painterPath);

    painter.setPen(Qt::black);
    painter.setBrush(Qt::white);

    QRect ru(0, 0, w, 7);
    if (vertical_)
        ru.setRect(w-7, 0, 7, h);
    painter.drawRect(ru);

    QPolygon pa(4);
    if (vertical_)
    {
        pa.setPoint(0, 0, 0);
        pa.setPoint(1, 6, -3);
        pa.setPoint(2, 6, 3);
        pa.setPoint(3, 0, 0);
        painter.drawPolygon(pa);
        pa.translate(0, h-1);
        painter.drawPolygon(pa);
        pa.translate(0, -(h-1));

        if (!upDown_)
            pa.translate(0, h);
    }
    else
    {
        pa.setPoint(0, -3, 0);
        pa.setPoint(1, 3, 0);
        pa.setPoint(2, 0, 6);
        pa.setPoint(3, -3, 0);
        painter.drawPolygon(pa);
        pa.translate(w-1, 0);
        painter.drawPolygon(pa);
        pa.translate(-(w-1), 0);
    }

    it = colorMap_.begin();
    while (it != colorMap_.end())
    {
        j = it->second.size();
        it++;
        if (it != colorMap_.end())
        {
            if (vertical_)
            {
                if (upDown_)
                    pa.translate(0, j);
                else
                    pa.translate(0, -j);
            }
            else
                pa.translate(j, 0);
            painter.drawPolygon(pa);
        }
    }

    painter.setBrush(Qt::NoBrush);
    painter.setPen(Qt::black);

    double pd =(double)tsize / 10.;
    int	t;
    for (i = 0; i < 10; ++i){
        t = 5;
        if (i % 2)
            t = 3;

        int a = TeRound((double)i * pd);
        if (vertical_){
            //painterPath.moveTo(0, a);
            //painterPath.lineTo(t, a);
            painter.drawLine(0, a, t, a);
        }
        else{
            //painterPath.moveTo(a, h);
            //painterPath.lineTo(a, h-t);
            painter.drawLine(a, h, a, h-t);
        }
        //painter.drawPath(painterPath);
    }
    painter.drawRect(rect);
}

void TeQtColorBar::mousePressEvent(QMouseEvent* e)
{
    if (colorMap_.empty())
        return;

    p_ = e->pos();
    ind_ = getColorIndiceToChange();

    if (e->button() == Qt::RightButton)
    {
        if (change_)
        {
            //popupMenu_.setItemEnabled(popupMenu_.idAt(0), false); // add color
            addColor->setEnabled(false);
            //popupMenu_.setItemEnabled(popupMenu_.idAt(1), true); // change color
            changeColor->setEnabled(true);

            if (colorMap_.size() <= 1)
                //popupMenu_.setItemEnabled(popupMenu_.idAt(2), false); // remove color
                removeColor->setEnabled(false);
            else
                //popupMenu_.setItemEnabled(popupMenu_.idAt(2), true); // remove color
                removeColor->setEnabled(true);
        }
        else
        {
            //popupMenu_.setItemEnabled(popupMenu_.idAt(0), true); // add color
            //popupMenu_.setItemEnabled(popupMenu_.idAt(1), false); // change color
            //popupMenu_.setItemEnabled(popupMenu_.idAt(2), false); // remove color
            addColor->setEnabled(true);
            changeColor->setEnabled(false);
            removeColor->setEnabled(false);
        }

        setCursor(QCursor(Qt::ArrowCursor));
        QPoint	mp(e->globalPos().x(), e->globalPos().y());
        popupMenu_.exec(mp);
    }
}

void TeQtColorBar::mouseDoubleClickEvent(QMouseEvent* e)
{
    ind_ = getColorIndiceToChange();

    if (change_)
    {
        if (vertical_)
        {
            if (e->pos().x() >= frameRect().width()-7)
                changeColorSlot();
            else
                removeColorSlot();
        }
        else
        {
            if (e->pos().y() <= 7)
                changeColorSlot();
            else
                removeColorSlot();
        }
    }
    else
        addColorSlot();
}

void TeQtColorBar::mouseMoveEvent(QMouseEvent* e)
{
    if (colorMap_.empty())
        return;

    pa_ = e->pos();
    if (e->button() == Qt::NoButton) // set cursor
    {
        ind_ = getColorIndiceToChange();
        QCursor cursor;
        if (distance_)
        {
            if (vertical_)
                cursor.setShape(Qt::SplitVCursor);
            else
                cursor.setShape(Qt::SplitHCursor);
        }
        else if (change_ && brightness_)
        {
            if (vertical_)
                cursor.setShape(Qt::SplitHCursor);
            else
                cursor.setShape(Qt::SplitVCursor);
        }

        setCursor(cursor);
    }
    else
    {
        if (((cursor().shape() == Qt::SplitVCursor) && vertical_)
                ||((cursor().shape() == Qt::SplitHCursor) && !vertical_))
            changeDistance();
        else if (((cursor().shape() == Qt::SplitVCursor) && !vertical_)
                ||((cursor().shape() == Qt::SplitHCursor) && vertical_))
        {
            if (e->button() & Qt::LeftButton)
            {
                if (e->button() == Qt::LeftButton)
                    changeBrightness();
                else
                    changeHue();
            }
            else if (e->button() == Qt::MidButton)
                changeSaturation();
        }
        else
        {
            QCursor cursor(Qt::SizeVerCursor);
            setCursor(cursor);

            if (e->button() == Qt::LeftButton)
                changeAllBrightness();
            else if (e->button() == Qt::MidButton)
                changeAllSaturation();
        }
    }
    p_ = e->pos();
}

void TeQtColorBar::mouseReleaseEvent(QMouseEvent*)
{
    QCursor cursor;
    setCursor(cursor);
}

void TeQtColorBar::leaveEvent(QEvent*)
{
}

void TeQtColorBar::addColorSlot()
{
    int ind = ind_;
    TeColor cor;

    bool isOK = false;
    QColor inputColor(255, 255, 255);
    QColor outputColor = QColorDialog::getRgba(inputColor.rgb(), &isOK, this);
    if (isOK)
    {
        cor.init(outputColor.red(), outputColor.green(), outputColor.blue());
        ColorBar cb;
        double dist =(double)a_ * totalDistance_ /(double)(ftam_-1);
        cb.color(cor);
        cb.distance_ = dist;

        vector<ColorBar> bcor = inputColorVec_;
        inputColorVec_.clear();
        int i;
        for (i = 0; i <(int)bcor.size(); ++i)
        {
            if (i == ind+1)
                inputColorVec_.push_back(cb);
            inputColorVec_.push_back(bcor[i]);
        }
        generateColorMap();
        drawColorBar();

        emit colorChangedSignal();
    }
}

void TeQtColorBar::changeColorSlot()
{
    int ind = ind_;

    if ((int)inputColorVec_.size() <= ind)
        return;
    ColorBar& cb = inputColorVec_[ind];
    TeColor cor = cb.cor_;

    bool isOK = false;
    QColor inputColor(cor.red_, cor.green_, cor.blue_);
    QColor outputColor = QColorDialog::getRgba(inputColor.rgb(), &isOK, this);

    if (isOK)
    {
        cor.init(outputColor.red(), outputColor.green(), outputColor.blue());
        cb.color(cor);
        generateColorMap();
        drawColorBar();

        emit colorChangedSignal();
    }
}

void TeQtColorBar::removeColorSlot()
{
    int i;

    if (ind_ == 0 || ind_ ==(int)inputColorVec_.size()-1)
        return;

    vector<ColorBar> bcor = inputColorVec_;
    inputColorVec_.clear();

    for (i = 0; i <(int)bcor.size(); ++i)
    {
        if (i == ind_)
            continue;
        inputColorVec_.push_back(bcor[i]);
    }
    //	if (inputColorVec_.size() == 1)
    //		inputColorVec_.push_back(inputColorVec_[0]);

    QCursor cursor;
    setCursor(cursor);
    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

int TeQtColorBar::getColorIndiceToChange()
{
    int	i, j, ind;
    distance_ = false;
    change_ = false;

    fitMousePosition(p_);

    limit_ = inf_ = sup_ = ind = -1;
    for (i = 0; i <(int)changeVec_.size(); ++i)
    {
        j = changeVec_[i];
        if ((a_ >= j-2) && (a_ <= j+2))
        {
            ind = i;
            change_ = true;
            distance_ = true;
            break;
        }
    }

    if (ind == 0)
    {
        for (i = 1; i <(int)changeVec_.size() - 1; ++i)
        {
            j = changeVec_[i];
            if ((a_ >= j-2) && (a_ <= j+2))
            {
                ind = i;
                break;
            }
        }
    }

    if (ind == -1)
    {
        int jj;
        for (i = 0; i <(int)changeVec_.size()-1; ++i)
        {
            j = changeVec_[i];
            jj = changeVec_[i+1];
            if ((a_ > j+2) && (a_ < jj-2))
            {
                ind = i;
                break;
            }
        }
    }

    if (brightness_ || ind == 0 || ind ==(int)changeVec_.size() - 2)
        distance_ = false;

    if (distance_)
    {
        limit_ = ind - 1;
        if ((int)changeVec_.size() > limit_+2)
        {
            inf_ = changeVec_[limit_];
            sup_ = changeVec_[limit_+2];
            colorEdit_ = &(inputColorVec_[limit_+1]);
        }
    }

    if (ind < 0)
        ind = 0;
    else if (ind >(int)inputColorVec_.size()-1)
        ind =(int)inputColorVec_.size()-1;

    return ind;
}

void TeQtColorBar::fitMousePosition(QPoint point)
{
    brightness_ = false;
    QRect rect = frameRect();

    if (vertical_)
    {
        ftam_ = rect.height();
        if (upDown_)
            a_ = point.y();
        else
            a_ = ftam_ - point.y();
        b_ = point.x();

        if (point.x() >= rect.width() - 7 && point.x() <= rect.width())
            brightness_ = true;
    }
    else
    {
        ftam_ = rect.width();
        a_ = point.x();
        b_ = point.y();
        if (point.y() <= 7)
            brightness_ = true;
    }

    if (a_ < 0)
        a_ = 0;
    else if (a_ > ftam_)
        a_ = ftam_;
}

void TeQtColorBar::changeDistance()
{
    fitMousePosition(pa_);
    int nc = changeVec_[changeVec_.size()-1];

    if (colorEdit_ && a_ >= nc) // end of bar
    {
        a_ = nc;
        int t =(int)inputColorVec_.size();

        colorEdit_->distance_ = totalDistance_;
        double d = inputColorVec_[t-3].distance_;
        d = d +(totalDistance_ - d) * .8;
        inputColorVec_[t-1].distance_ = d;
        QCursor cursor;
        setCursor(cursor);
        colorEdit_ = 0;
    }
    else if (a_ <= 0)
    {
        a_ = 0;

        colorEdit_->distance_ = 0.;
        int t = changeVec_[2];
        double dist = .2 *(double)t * totalDistance_ /(double)(ftam_-1);
        inputColorVec_[0].distance_ = dist;
        QCursor cursor;
        setCursor(cursor);
        colorEdit_ = 0;

    }
    else
    {
        colorEdit_->distance_ =(double)a_ * totalDistance_ /(double)(ftam_-1);
    }
    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::sortByDistance()
{
    multimap<double, ColorBar> mMap;
    typedef pair <double, ColorBar> myPair;
    int i;
    double dist;

    for (i = 0; i <(int)inputColorVec_.size(); ++i)
    {
        double d = inputColorVec_[i].distance_;
        if (&(inputColorVec_[i]) == colorEdit_)
        {
            dist = inputColorVec_[i].distance_;
            inputColorVec_[i].distance_ = -1.;
        }
        mMap.insert(myPair(d, inputColorVec_[i]));
    }

    inputColorVec_.clear();
    multimap<double, ColorBar>::iterator it;

    for (it = mMap.begin(); it!= mMap.end(); it++)
        inputColorVec_.push_back(it->second);

    for (i = 0; i <(int)inputColorVec_.size(); ++i)
    {
        ColorBar cb = inputColorVec_[i];
        if (cb.distance_ == -1)
        {
            inputColorVec_[i].distance_ = dist;
            colorEdit_ = &(inputColorVec_[i]);
            break;
        }
    }
}

void TeQtColorBar::changeAllBrightness()
{
    double	dif;
    int ind;

    fitMousePosition(pa_);

    if (vertical_)
        dif = 6.*(double)(p_.x() - b_);
    else
        dif = 6.*(double)(p_.y() - b_);


    for (ind = 0; ind <(int)inputColorVec_.size(); ++ind)
    {
        ColorBar cb = inputColorVec_[ind];
        cb.v_ +=(int)dif;

        int v = 1;
        if (cb.s_ == 0 || cb.h_ == -1) // achromatic(grey)
            v = 0;

        if (cb.v_ > 255)
            return;
        if (cb.v_ < v)
            return;
    }

    for (ind = 0; ind <(int)inputColorVec_.size(); ++ind)
    {
        ColorBar& cb = inputColorVec_[ind];
        cb.v_ +=(int)dif;

        int v = 1;
        if (cb.s_ == 0 || cb.h_ == -1) // achromatic(grey)
            v = 0;

        if (cb.v_ > 255)
            cb.v_ = 255;
        if (cb.v_ < v)
            cb.v_ = v;

        QColor cor;
        cor.setHsv(cb.h_, cb.s_, cb.v_);

        TeColor tc(cor.red(), cor.green(), cor.blue());
        cb.color(tc);
    }
    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::changeBrightness()
{
    double	dif;
    int ind = ind_;

    if ((int)inputColorVec_.size() <= ind)
        return;

    ColorBar& cb = inputColorVec_[ind];

    fitMousePosition(pa_);

    if (vertical_)
        dif = 6.*(double)(p_.x() - b_);
    else
        dif = 6.*(double)(p_.y() - b_);

    cb.v_ +=(int)dif;

    int v = 1;
    if (cb.s_ == 0 || cb.h_ == -1) // achromatic(grey)
        v = 0;

    if (cb.v_ > 255)
        cb.v_ = 255;
    if (cb.v_ < v)
        cb.v_ = v;

    QColor cor;
    cor.setHsv(cb.h_, cb.s_, cb.v_);

    TeColor tc(cor.red(), cor.green(), cor.blue());
    cb.color(tc);

    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::changeAllSaturation()
{
    double	dif;
    int ind;

    fitMousePosition(pa_);

    if (vertical_)
        dif = 6.*(double)(p_.x() - b_);
    else
        dif = 6.*(double)(p_.y() - b_);

    for (ind = 0; ind <(int)inputColorVec_.size(); ++ind)
    {
        ColorBar cb = inputColorVec_[ind];

        if (cb.s_ == 0 || cb.h_ == -1) // achromatic(grey)
        {
            cb.v_ +=(int)dif;
            if (cb.v_ > 255)
                return;
            if (cb.v_ < 0)
                return;
        }
        else
        {
            cb.s_ -=(int)dif;
            if (cb.s_ > 255)
                return;
            if (cb.s_ < 1)
                return;
        }
    }

    for (ind = 0; ind <(int)inputColorVec_.size(); ++ind)
    {
        ColorBar& cb = inputColorVec_[ind];

        if (cb.s_ == 0 || cb.h_ == -1) // achromatic(grey)
        {
            cb.v_ +=(int)dif;
            if (cb.v_ > 255)
                cb.v_ = 255;
            if (cb.v_ < 0)
                cb.v_ = 0;
        }
        else
        {
            cb.s_ -=(int)dif;
            if (cb.s_ > 255)
                cb.s_ = 255;
            if (cb.s_ < 1)
                cb.s_ = 1;
        }

        QColor cor;
        cor.setHsv(cb.h_, cb.s_, cb.v_);

        TeColor tc(cor.red(), cor.green(), cor.blue());
        cb.color(tc);
    }
    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::changeSaturation()
{
    double	dif;
    int ind = ind_;

    if ((int)inputColorVec_.size() <= ind)
        return;

    ColorBar& cb = inputColorVec_[ind];

    fitMousePosition(pa_);

    if (vertical_)
        dif = 6.*(double)(p_.x() - b_);
    else
        dif = 6.*(double)(p_.y() - b_);

    if (cb.s_ == 0 || cb.h_ == -1) // achromatic(grey)
    {
        cb.v_ +=(int)dif;
        if (cb.v_ > 255)
            cb.v_ = 255;
        if (cb.v_ < 0)
            cb.v_ = 0;
    }
    else
    {
        cb.s_ -=(int)dif;
        if (cb.s_ > 255)
            cb.s_ = 255;
        if (cb.s_ < 1)
            cb.s_ = 1;
    }

    QColor cor;
    cor.setHsv(cb.h_, cb.s_, cb.v_);

    TeColor tc(cor.red(), cor.green(), cor.blue());
    cb.color(tc);

    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::changeHue()
{
    double	dif;
    int ind = ind_;

    if ((int)inputColorVec_.size() <= ind)
        return;

    ColorBar& cb = inputColorVec_[ind];

    fitMousePosition(pa_);

    if (vertical_)
        dif =(double)(p_.x() - b_);
    else
        dif =(double)(p_.y() - b_);

    if (cb.h_ == -1)
        cb.s_ = cb.v_;

    cb.h_ +=(int)dif;
    if (cb.h_ == -1)
    {
        cb.s_ = 0;
        cb.v_ = cb.cor_.red_;
    }
    else if (cb.h_ >= 360)
        cb.h_ -= 360;
    else if (cb.h_ < 0)
        cb.h_ += 360;

    QColor cor;
    cor.setHsv(cb.h_, cb.s_, cb.v_);

    TeColor tc(cor.red(), cor.green(), cor.blue());
    cb.color(tc);

    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::invertColorBar()
{
    int	i;
    vector<ColorBar> cbVec = inputColorVec_;
    inputColorVec_.clear();

    for (i =(int)cbVec.size() - 1; i >= 0; --i)
    {
        cbVec[i].distance_ = totalDistance_ - cbVec[i].distance_;
        inputColorVec_.push_back(cbVec[i]);
    }
    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::clearColorBar()
{
    inputColorVec_.clear();
    ColorBar cb;

    QColor cor(Qt::white); // = paletteBackgroundColor();
    TeColor c(cor.red(), cor.green(), cor.blue());
    cb.color(c);
    cb.distance_ = 0.;
    inputColorVec_.push_back(cb);
    cb.distance_ = 10.;
    inputColorVec_.push_back(cb);

    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::setEqualSpace()
{
    int i;

    for (i = 0; i <(int)inputColorVec_.size(); ++i)
        inputColorVec_[i].distance_ =(double)i;

    if ((int)inputColorVec_.size()-1 >= 0)
        totalDistance_ = inputColorVec_[inputColorVec_.size()-1].distance_;
    generateColorMap();
    drawColorBar();

    emit colorChangedSignal();
}

void TeQtColorBar::resizeEvent(QResizeEvent*)
{
    ftam_ = frameRect().width();
    if (vertical_)
        ftam_ = frameRect().height();

    generateColorMap();
    drawColorBar();
}

void TeQtColorBar::helpSlot()
{
    //	if (help_)
    //		delete help_;
    //
    //	help_ = new Help(this, "help", false);
    //	help_->init("colorBar.htm");
    //	if (help_->erro_ == false)
    //	{
    //		help_->show();
    //		help_->raise();
    //	}
    //	else
    //	{
    //		delete help_;
    //		help_ = 0;
    //	}
}

