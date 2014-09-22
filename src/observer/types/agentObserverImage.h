/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright © 2001-2012 INPE and TerraLAB/UFOP.
*  
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
* 
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

#ifndef AGENT_OBSERVER_IMAGE
#define AGENT_OBSERVER_IMAGE

#include <QStringList>

#include "observerImage.h"

namespace TerraMEObserver {

/**
 * \brief Combined visualization for Agent, Automaton and
 * Trajectory and saved in a png image file
 * \see ObserverImage
 * \author Antonio José da Cunha Rodrigues
 * \file agentObserverImage.h
 */
class AgentObserverImage : public ObserverImage
{

public:
    /** 
     * Constructor
     * \param parent a pointer to a QWidget
     */
    AgentObserverImage(QWidget *parent = 0);

    /**
     * Constructor
     * \param subj a pointer to a Subject
     */
    AgentObserverImage(Subject *subj);

    /**
     * Destructor
     */
    virtual ~AgentObserverImage();

    /**
     * \copydoc Observer::draw
     */
    bool draw(QDataStream &);

    /**
     * Registers an other Subject to the observation
     * \param subj a pointer to a Subject: \a 'Agent', \a 'Automaton' or \a 'Trajectory'
     * \param className a reference to the class of the Subject.
     */
    void registry(Subject * subj, const QString & className = "");

    /**
     * Unregisters a Subject under observation
     * \param subj a pointer to a Subject: \a 'Agent', \a 'Automaton' or \a 'Trajectory'
     * \param className a reference to the class of the Subject.
     * \return boolean, \a true if the Subject \a subj was unregistered.
     * Otherwise, returns \a false
     * \see Subject
     * \see QString
     */
    bool unregistry(Subject * subj, const QString & className = "");

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
    void setSubjectAttributes(const QStringList & attribs, 
        int nestedSubjID, const QString & className = "" );
    
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

    QVector<QPair<Subject *, QString> > nestedSubjects;
    QStringList subjectAttributes;

    bool cleanImage;
    QString className;

};

}

#endif  //AGENT_OBSERVER_IMAGE
