#include "event.h"

/// Compares Event objects.
/// \param e1 is a Event object
/// \param e2 is a Event object
/// \return A boolean value:  true if e1 must occur earlier than e2, false otherwise.
bool operator<(Event e1, Event e2)
	{
    if(e1.getTime() > e2.getTime())
		return false;
    else if(e1.getTime() < e2.getTime())
		return true;
    return e1.getPriority() < e2.getPriority();
}

