#include "trajectorySubjectInterf.h"

#include "types/observerTable.h"
#include "types/observerLogFile.h"
#include "types/observerTextScreen.h"
#include "types/observerGraphic.h"
#include "types/observerUDPSender.h"
#include "types/agentObserverMap.h"
#include "types/agentObserverImage.h"

using namespace TerraMEObserver;

Observer * TrajectorySubjectInterf::createObserver(TypesOfObservers typeObserver)
{
    Observer* obs = 0;

    switch (typeObserver)
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

bool TrajectorySubjectInterf::kill(int id)
{
    Observer * obs = getObserverById(id);
    detach(obs);

    if (! obs)
        return false;

    // if ((obs->getObserverType() != TObsMap) && (obs->getObserverType() != TObsImage)) 
    //     detachObserver(obs);

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

        case TObsTextScreen:
            ((ObserverTextScreen *)obs)->close();
            delete (ObserverTextScreen *)obs;
            break;
            
        case TObsUDPSender:
            ((ObserverUDPSender *)obs)->close();
            delete (ObserverUDPSender *)obs;
            break;

        //case TObsMap:
        //    ((AgentObserverMap *)obs)->unregistry(this);
        //    break;

        //case TObsImage:
        //    ((AgentObserverImage *)obs)->unregistry(this);
        //    break;

        default:
            delete obs;
            break;
    }
    obs = 0;
    return true;
}


