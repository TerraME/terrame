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

#include "imageCompare.h"

#include <iostream>

using namespace std;

double comparePerPixel(const QString &img1, const QString &img2)
{
	QImage image1(img1);
	QImage image2(img2);

	if (image1.width() == 0 || image1.height() == 0)
		return 1;

	if (image2.width() == 0 || image2.height() == 0)
		return 1;

	if (image1.width() != image2.width() || image1.height() != image2.height())
		return 1;

    double count = 0;
    for (int i = 0; i < image1.height(); i++)
        for (int j = 0; j < image1.width(); j++)
			if (image1.pixel(j, i) != image2.pixel(j, i))
			{
                count = count + 1;
            }

	return count /(image1.width() * image1.height());
}

