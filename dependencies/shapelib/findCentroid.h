#ifndef FIND_CENTROID_H
#define FIND_CENTROID_H

#include "shapefil.h"
#include <cstring>
#include <QPoint>
#include <cmath>

#define		SHPD_POINT	 		1
#define		SHPD_LINE	 		2
#define		SHPD_AREA			4
#define 	SHPD_Z		 		8
#define		SHPD_MEASURE		16



typedef struct { double x; double y; } PT;

QPoint getCentroid(SHPObject *psCShape, double width, double height);
int SHPDimension (int SHPType);
SHPObject* SHPClone ( SHPObject *psCShape, int lowPart, int highPart );
int RingCentroid_2d ( int nVertices, double *a, double *b, PT *C, double *Area );
PT SHPCentrd_2d ( SHPObject *psCShape );

#endif
