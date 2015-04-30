#include "environmentSubjectInterf.h"

#include "observerTable.h"
#include "observerGraphic.h"
#include "observerTextScreen.h"
#include "observerLogFile.h"
#include "observerUDPSender.h"
// #include "types/observerPlayer.h"

Observer * EnvironmentSubjectInterf::createObserver(TypesOfObservers typeObserver)
{
    Observer* obs = 0;

    switch (typeObserver)
    {
        case TObsTable:
            obs = new ObserverTable(this);
            break;

        case TObsLogFile:
            obs = new ObserverLogFile(this);
            break;

        case TObsDynamicGraphic:
        case TObsGraphic:
            obs = new ObserverGraphic(this);
            break;

        case TObsUDPSender:
            obs = new ObserverUDPSender(this);
            break;

        case TObsTextScreen:
        default:
            obs = new ObserverTextScreen(this);
            break;
    }
    return obs;
}

bool EnvironmentSubjectInterf::kill(int id)
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

            //case TObsPlayer:
            //    ((ObserverPlayer *)obs)->close();
            //    delete (ObserverPlayer *)obs;
            //    break;

            // case TObsMap:
            //     ((AgentObserverMap *)obs)->close();
            //     delete (AgentObserverMap *)obs;
            //     break;

            //case TObsImage:
            //     ((AgentObserverImage *)obs)->close();
            //     delete (AgentObserverImage *)obs;
            //     break;

        default:
            delete obs;
            break;
    }
    obs = 0;
    return true;
}
