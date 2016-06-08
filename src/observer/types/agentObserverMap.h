/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

#ifndef AGENT_OBSERVER_MAP
#define AGENT_OBSERVER_MAP

#include <QStringList>
#include <QPair>

#include "observerMap.h"

class SubjectInterf;

namespace TerraMEObserver {

/**
 * \brief Combined visualization for Agent, Automaton and
 * Trajectory in the user interface
 * \see ObserverMap
 * \author Antonio Jos? da Cunha Rodrigues
 * \file agentObserverMap.h
 */
class AgentObserverMap : public ObserverMap
{

public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget
     */
    AgentObserverMap(QWidget *parent = 0);


    /**
     * Constructor
     * \param subj a pointer to a Subject
     */
    AgentObserverMap(Subject *subj);

    /**
     * Destructor
     */
    virtual ~AgentObserverMap();

    /**
     * \copydoc Observer::draw
     */
    bool draw(QDataStream &);

    /**
     * Registers an other Subject to the observation
     * \param subj a pointer to a Subject: \a 'Agent', \a 'Automaton' or \a 'Trajectory'
     * \param className a reference to the class of the Subject.
     * \see Subject
     * \see QString
     */
    void registry(Subject *subj, const QString & className = "");

    /**
     * Unregisters a Subject under observation
     * \param subj a pointer to a Subject: \a 'Agent', \a 'Automaton' or \a 'Trajectory'
     * \param className a reference to the class of the Subject.
     * \return boolean, \a true if the Subject \a subj was unregistered.
     * Otherwise, returns \a false
     * \see Subject
     * \see QString
     */
    bool unregistry(Subject *subj, const QString & className = "");

    /**
     * Unregisters all subject under observation
     */
    void unregistryAll();

    /**
     * Sets the attribute list of a subject
     * \param attribs a reference to a list of attribute that will be observed
     * \param type the type of Subject
     * \param className  a reference to the class of the Subject.
     * \see TypesOfSubjects
     * \see QString, \see QStringList
     */
    void setSubjectAttributes(const QStringList & attribs, TypesOfSubjects type,
                            const QString & className = "");

    /**
     * Gets a reference to the list of subject attributes
     * \see QStringList
     */
    QStringList & getSubjectAttributes();


private:
    /**
     * Decodes a internal subject state
     * \param state a reference to a received state
     * \param subject the type of Subject
     * \return boolean, \a true if the \a state could be decoded
     * \see TypesOfSubjects
     * \see QDataStream
     */
    bool decode(QDataStream &state, TypesOfSubjects subject);

    /**
     * Draws an Agent, Automaton or a Trajectory
     * \return boolean, \a true if the Subject could be drawn
     */
    bool draw();

    QVector<QPair<Subject *, QString> > linkedSubjects;
    QStringList subjectAttributes;
    bool cleanImage;
    QString className;
};

} // namespace TerraMEObserver

#endif  //AGENT_OBSERVER_MAP
