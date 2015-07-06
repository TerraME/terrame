#include "cellSubjectInterf.h"

#include "types/observerTable.h"
#include "types/observerLogFile.h"
#include "types/observerTextScreen.h"
#include "types/observerGraphic.h"
#include "types/observerUDPSender.h"
#include "types/agentObserverMap.h"

Observer * CellSubjectInterf::createObserver(TypesOfObservers type)
{
    Observer* obs = 0;

#ifdef DEBUG_OBSERVER
    printf("create in CellSubjectInterf\n");
#endif

    switch (type)
    {
        case TObsLogFile:
            obs = new ObserverLogFile(this);
            break;

        case TObsTable:
            obs = new ObserverTable(this);
            break;

        case TObsDynamicGraphic:
        case TObsGraphic:
            obs = new ObserverGraphic(this);
            break;

        case TObsUDPSender:
            obs = new ObserverUDPSender(this);
            break;
			
		case TObsNeigh:
			obs = new AgentObserverMap(this);
			break;
		
        default:
            obs = new ObserverTextScreen(this);
            break;
    }
    return obs;
}

bool CellSubjectInterf::kill(int id)
{
    Observer * obs = getObserverById(id);
    detach(obs);

    if (! obs)
        return false;

    switch (obs->getType())
    {
        case TObsLogFile:
            ((ObserverLogFile *)obs)->close();
            delete (ObserverLogFile *)obs;
            break;

        case TObsTable:
            ((ObserverTable *)obs)->close();
            delete (ObserverTable *)obs;
            break;

        case TObsGraphic:
        case TObsDynamicGraphic:
            ((ObserverGraphic *)obs)->close();
            delete (ObserverGraphic *)obs;
            break;

        case TObsUDPSender:
            ((ObserverUDPSender *)obs)->close();
            delete (ObserverUDPSender *)obs;
            break;

        case TObsTextScreen:
            ((ObserverTextScreen *)obs)->close();
            delete (ObserverTextScreen *)obs;
            break;
            
        default:
            delete obs;
            break;
    }
    obs = 0;
    return true;
}

