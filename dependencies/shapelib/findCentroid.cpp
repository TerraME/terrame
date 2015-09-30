#include "findCentroid.h"

#include <QDebug>

QPoint getCentroid(SHPObject *psCShape, double width, double height){
    PT	Centrd;

    for ( int ring = 0; ring < psCShape->nParts; ring ++ ) {
        SHPObject 	*psO;
        psO = SHPClone ( psCShape, ring,  ring + 1 );
        Centrd = SHPCentrd_2d ( psO );
        SHPDestroyObject ( psO );
    }
    QPoint cntrd((long)(Centrd.x+width), (long)(Centrd.y+height));
    return cntrd;
}

/* **************************************************************************
 * SHPDimension
 *
 * Return the Dimensionality of the SHPObject
 * a handy utility function
 *
 * **************************************************************************/
int SHPDimension ( int SHPType ) {
    int dimension;

    dimension = 0;

    switch ( SHPType ) {
        case  SHPT_POINT       :	dimension = SHPD_POINT ; break;
        case  SHPT_ARC         :	dimension = SHPD_LINE; break;
        case  SHPT_POLYGON     :	dimension = SHPD_AREA; break;
        case  SHPT_MULTIPOINT  :	dimension = SHPD_POINT; break;
        case  SHPT_POINTZ      :	dimension = SHPD_POINT | SHPD_Z; break;
        case  SHPT_ARCZ        :	dimension = SHPD_LINE | SHPD_Z; break;
        case  SHPT_POLYGONZ    :	dimension = SHPD_AREA | SHPD_Z; break;
        case  SHPT_MULTIPOINTZ :	dimension = SHPD_POINT | SHPD_Z; break;
        case  SHPT_POINTM      :	dimension = SHPD_POINT | SHPD_MEASURE; break;
        case  SHPT_ARCM        :	dimension = SHPD_LINE | SHPD_MEASURE; break;
        case  SHPT_POLYGONM    :	dimension = SHPD_AREA | SHPD_MEASURE; break;
        case  SHPT_MULTIPOINTM :	dimension = SHPD_POINT | SHPD_MEASURE; break;
        case  SHPT_MULTIPATCH  :	dimension = SHPD_AREA; break;
    }

   return ( dimension );
}

/* **************************************************************************
 * SHPClone
 *
 * Clone a SHPObject, replicating all data
 *
 * **************************************************************************/
SHPObject* SHPClone ( SHPObject *psCShape, int lowPart, int highPart ) {
    SHPObject	*psObject;
    int		newParts, newVertices;

    if ( highPart >= psCShape->nParts || highPart == -1 )
    highPart = psCShape->nParts ;

    newParts = highPart - lowPart;
    if ( newParts == 0 ) { return ( NULL ); }

    psObject = (SHPObject *) calloc(1,sizeof(SHPObject));
    psObject->nSHPType = psCShape->nSHPType;
    psObject->nShapeId = psCShape->nShapeId;

    psObject->nParts = newParts;
    if ( psCShape->padfX ) {
        psObject->panPartStart = (int*) calloc (newParts, sizeof (int));
        memcpy ( psObject->panPartStart, psCShape->panPartStart,
            newParts * sizeof (int) );
     }
    if ( psCShape->padfX ) {
      psObject->panPartType = (int*) calloc (newParts, sizeof (int));
      memcpy ( psObject->panPartType,
        (int *) &(psCShape->panPartType[lowPart]),
            newParts * sizeof (int) );
     }

    if ( highPart != psCShape->nParts ) {
      newVertices = psCShape->panPartStart[highPart] -
     psCShape->panPartStart[lowPart];
     }
    else
     { newVertices = psCShape->nVertices - psCShape->panPartStart[lowPart]; }

    psObject->nVertices = newVertices;
    if ( psCShape->padfX ) {
      psObject->padfX = (double*) calloc (newVertices, sizeof (double));
      memcpy ( psObject->padfX,
     (double *) &(psCShape->padfX[psCShape->panPartStart[lowPart]]),
            newVertices * sizeof (double) );
     }
    if ( psCShape->padfY ) {
      psObject->padfY = (double*) calloc (newVertices, sizeof (double));
      memcpy ( psObject->padfY,
     (double *) &(psCShape->padfY[psCShape->panPartStart[lowPart]]),
            newVertices * sizeof (double) );
     }
    if ( psCShape->padfZ ) {
      psObject->padfZ = (double*) calloc (newVertices, sizeof (double));
      memcpy ( psObject->padfZ,
     (double *) &(psCShape->padfZ[psCShape->panPartStart[lowPart]]),
            newVertices * sizeof (double) );
     }
    if ( psCShape->padfM ) {
      psObject->padfM = (double*) calloc (newVertices, sizeof (double));
      memcpy ( psObject->padfM,
    (double *) &(psCShape->padfM[psCShape->panPartStart[lowPart]]),
            newVertices * sizeof (double) );
     }

    psObject->dfXMin = psCShape->dfXMin;
    psObject->dfYMin = psCShape->dfYMin;
    psObject->dfZMin = psCShape->dfZMin;
    psObject->dfMMin = psCShape->dfMMin;

    psObject->dfXMax = psCShape->dfXMax;
    psObject->dfYMax = psCShape->dfYMax;
    psObject->dfZMax = psCShape->dfZMax;
    psObject->dfMMax = psCShape->dfMMax;

    SHPComputeExtents ( psObject );
    return ( psObject );
}

/* **************************************************************************
 * SHPCentrd_2d
 *
 * Return the single mathematical / geometric centroid of a potentially
 * complex/compound SHPObject
 *
 * reject non area SHP Types
 *
 * **************************************************************************/
PT SHPCentrd_2d ( SHPObject *psCShape ) {
    int	ring, ringPrev, ring_nVertices, rStart;
    double Area, ringArea;
    PT ringCentrd, C;


   //if ( !(SHPDimension (psCShape->nSHPType) & SHPD_AREA) )
     //  return ( (PT){0,0.0} );

   Area = 0;
   C.x = 0.0;
   C.y = 0.0;

   /* for each ring in compound / complex object calc the ring cntrd		*/

   ringPrev = psCShape->nVertices;
   for ( ring = (psCShape->nParts - 1); ring >= 0; ring-- ) {
     rStart = psCShape->panPartStart[ring];
     ring_nVertices = ringPrev - rStart;

     RingCentroid_2d ( ring_nVertices, (double*) &(psCShape->padfX [rStart]),
        (double*) &(psCShape->padfY [rStart]), &ringCentrd, &ringArea);

     /* use Superposition of these rings to build a composite Centroid		*/
     /* sum the ring centrds * ringAreas,  at the end divide by total area	*/
     C.x +=  ringCentrd.x * ringArea;
     C.y +=  ringCentrd.y * ringArea;
     Area += ringArea;
     ringPrev = rStart;
    }

     /* hold on the division by AREA until were at the end					*/
     C.x = C.x / Area;
     C.y = C.y / Area;

   return ( C );
}

 /* **************************************************************************
  * RingCentroid_2d
  *
  * Return the mathematical / geometric centroid of a single closed ring
  *
  * **************************************************************************/
 int RingCentroid_2d ( int nVertices, double *a, double *b, PT *C, double *Area ) {
   int		iv,jv;
   int		sign_x, sign_y;
   double	dy_Area, dx_Area, Cx_accum, Cy_accum, ppx, ppy;
   double 	x_base, y_base, x, y;

 /* the centroid of a closed Ring is defined as
  *
  *      Cx = sum (cx * dArea ) / Total Area
  *  and
  *      Cy = sum (cy * dArea ) / Total Area
  */

   x_base = a[0];
   y_base = b[0];

   Cy_accum = 0.0;
   Cx_accum = 0.0;

   ppx = a[1] - x_base;
   ppy = b[1] - y_base;
   *Area = 0;

 /* Skip the closing vector */
   for ( iv = 2; iv <= nVertices - 2; iv++ ) {
     x = a[iv] - x_base;
     y = b[iv] - y_base;

     /* calc the area and centroid of triangle built out of an arbitrary 	*/
     /* base_point on the ring and each successive pair on the ring			*/

     /* Area of a triangle is the cross product of its defining vectors		*/
     /* Centroid of a triangle is the average of its vertices				*/

     dx_Area =  ((x * ppy) - (y * ppx)) * 0.5;
     *Area += dx_Area;

     Cx_accum += ( ppx + x ) * dx_Area;
     Cy_accum += ( ppy + y ) * dx_Area;

     ppx = x;
     ppy = y;
   }

   /* adjust back to world coords 											*/
   C->x = round(( Cx_accum / ( *Area * 3)) + x_base);
   C->y = round(( Cy_accum / ( *Area * 3)) + y_base);

   return ( 1 );
 }
