#include "coordinate.h"

using namespace TerraMEObserver;

Coordinate::Coordinate(double xv, double yv, double zv)
    : x(xv), y(yv), z(zv)
{

}

Coordinate::~Coordinate()
{

}

void Coordinate::setValue(double xv, double yv, double zv)
{
    x = xv;
    y = yv;
    z = zv;
}

void Coordinate::clear()
{
    x = 0.0;
    y = 0.0;
    z = 0.0;
}
