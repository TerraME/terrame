#ifndef CONCRET_SUBJECT
#define CONCRET_SUBJECT

#include "observerInterf.h"

namespace TerraMEObserver{

class ConcretSubject : public SubjectInterf
{
public:
    ConcretSubject(int id, TypesOfSubjects type) 
    {
        setId(id);
        this->type = type;
    }

    virtual ~ConcretSubject() {}

    virtual QDataStream& getState(QDataStream &state, Subject * /* subj */,
        int /*observerId*/, const QStringList &/*attribs */)
    { 
        return state; 
    }

    const TypesOfSubjects getType() const
    { 
        return type;
    }

private:
    TypesOfSubjects type;

private:
#ifdef TME_PROTOCOL_BUFFERS
    QByteArray pop(lua_State *, const QStringList& , ObserverDatagramPkg::SubjectAttribute *,
        ObserverDatagramPkg::SubjectAttribute *) { return ""; }
    QByteArray getAll(QDataStream& , const QStringList& ) { return ""; }
    QByteArray getChanges(QDataStream& , const QStringList& ) { return ""; };
#else
    QByteArray pop(lua_State *, const QStringList& ) { return ""; }
    QByteArray getAll(QDataStream& , int , const QStringList& ) { return ""; }
    QByteArray getChanges(QDataStream& , int , const QStringList& ) { return ""; }
#endif
};

}

#endif
