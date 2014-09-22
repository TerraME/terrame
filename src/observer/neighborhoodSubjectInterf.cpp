#include "neighborhoodSubjectInterf.h"

#include "observerTable.h"
#include "observerLogFile.h"
#include "observerTextScreen.h"
// #include "observerGraphic.h"
#include "observerUDPSender.h"
#include "observerTCPSender.h"
#include "agentObserverMap.h"
#include "agentObserverImage.h"


Observer * NeighborhoodSubjectInterf::createObserver(TypesOfObservers type)
{
    Observer* obs = 0;

    switch (type)
    {
        case TObsLogFile:
            obs = new ObserverLogFile(this);
            break;

        case TObsTable:
            obs = new ObserverTable(this);
            break;

        // case TObsDynamicGraphic:
        // case TObsGraphic:
            // obs = new ObserverGraphic(this);
            // break;

        case TObsUDPSender:
            obs = new ObserverUDPSender(this);
            break;

        case TObsTCPSender:
            obs = new ObserverTCPSender(this);
            break;
			
        case TObsMap:
            obs = new AgentObserverMap(this);
            break;

        case TObsImage:
            obs = new AgentObserverImage(this);
            break;
		
        default:
            obs = new ObserverTextScreen(this);
            break;
    }
    return obs;
}

bool NeighborhoodSubjectInterf::kill(int id)
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

        // case TObsGraphic:
        // case TObsDynamicGraphic:
            // ((ObserverGraphic *)obs)->close();
            // delete (ObserverGraphic *)obs;
            // break;

        case TObsUDPSender:
            ((ObserverUDPSender *)obs)->close();
            delete (ObserverUDPSender *)obs;
            break;

        case TObsTCPSender:
            ((ObserverTCPSender *)obs)->close();
            delete (ObserverTCPSender *)obs;
            break;           
            
        case TObsTextScreen:
            ((ObserverTextScreen *)obs)->close();
            delete (ObserverTextScreen *)obs;
            break;
       
        //case TObsMap:
        //    ((AgentObserverMap *)obs)->close();
        //    delete (AgentObserverMap *)obs;
        //    break;

        //case TObsImage:
        //    ((AgentObserverImage *)obs)->close();
        //    delete (AgentObserverImage *)obs;
        //    break;
            
        default:
            delete obs;
            break;
    }
    obs = 0;
    return true;
}

