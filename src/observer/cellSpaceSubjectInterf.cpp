#include "cellSpaceSubjectInterf.h"

#include "types/agentObserverMap.h"
#include "types/observerUDPSender.h"
#include "types/agentObserverImage.h"

#include "types/observerTextScreen.h"
#include "types/observerGraphic.h"
#include "types/observerLogFile.h"
#include "types/observerTable.h"
#include "types/observerUDPSender.h"
#include "types/observerShapefile.h"

using namespace TerraMEObserver;

Observer * CellSpaceSubjectInterf::createObserver(TypesOfObservers type)
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
            
        case TObsShapefile:
            obs = new ObserverShapefile(this);
            break;
    
        case TObsTextScreen:
        default:
            obs = new ObserverTextScreen(this);
            break;
    }
    return obs;
}

bool CellSpaceSubjectInterf::kill(int id)
{
    Observer * obs = getObserverById(id);
    detach(obs);

    if (! obs)
        return false;

    switch (obs->getType())
    {
        case TObsTextScreen:
            ((ObserverTextScreen *)obs)->close();
            delete (ObserverTextScreen *)obs;
            break;

        case TObsLogFile:
            ((ObserverLogFile *)obs)->close();
            delete (ObserverLogFile *)obs;
            break;

        case TObsTable:
            ((ObserverTable *)obs)->close();
            delete (ObserverTable *)obs;
            break;

        case TObsDynamicGraphic:
        case TObsGraphic:
            ((ObserverGraphic *)obs)->close();
            delete (ObserverGraphic *)obs;
            break;

        case TObsUDPSender:
            ((ObserverUDPSender *)obs)->close();
            delete (ObserverUDPSender *)obs;
            break;

        case TObsMap:
            ((AgentObserverMap *)obs)->close();
            delete (AgentObserverMap *)obs;
            break;

        case TObsImage:
            ((AgentObserverImage *)obs)->close();
            delete (AgentObserverImage *)obs;
            break;

        default:
            delete obs;
            break;
    }
    obs = 0;
    return true;
}
