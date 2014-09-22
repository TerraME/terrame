
#ifndef COORDINATE_H
#define COORDINATE_H

namespace TerraMEObserver {

class Coordinate
{
public:
	Coordinate(double x, double y, double z = 0.0);
	virtual ~Coordinate();

	void clear();
    
    void setValue(double x, double y, double z = 0.0);
    
    inline double getX() { return x; }
    inline double getY() { return y; }
    inline double getZ() { return z; }

private:
	double x;
	double y;
	double z;

};

}

#endif // ifndef COORDINATE_H
