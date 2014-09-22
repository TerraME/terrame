#include "environment.h"
/// Transits the Agent JumpCondition object to the tagert ControlMode
/// \param event is the reference to the Event which has triggered this auxiliary function
/// \param agent is a pointer to the LocalAgent object being executed
/// \param targetControlMode is a pointer to the jump condition target ControlMode
void jump(Event& event, GlobalAgent* const agent, ControlMode* targetControlMode )
{
    if( targetControlMode == agent->getControlMode() ) return;
    agent->jump( targetControlMode );
    agent->setLastChangeTime( event.getTime() );

}
