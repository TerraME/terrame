/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

/*!
  \file rule.h
  \brief This file contains definitions about the JumpCondition and FlowCondition classes.
                 Interfaces: RuleStrategy, Rule
                 Implementations: FlowCondition, JumpCondition
  \author Tiago Garcia de Senna Carneiro
*/
#ifndef RULE_H
#define RULE_H

#include "bridge.h"
#include "composite.h"
#include "cell.h"
#include "event.h"
#include "neighborhood.h"

//////////////////////////////////// RULES ///////////////////////////////////////////////////
class Agent;
class LocalAgent;
class GlobalAgent;

/**
 * \brief
 *  Implementation for a RuleStrategy object.
 *
 */
class RuleStrategy {
public:
    RuleStrategy(void) {}
    virtual bool execute(Event & /*event*/, Agent * /*agent*/,
    		pair<CellIndex, Cell*> & /*cellIndexPair*/)
    {
    	return true;
    }
};

/**
 * \brief
 *  Implementation of a Rule object.
 *
 */
class Rule
{
public:
    /// Copy constructor
    Rule(RuleStrategy *strategy):theStrategy_(strategy) {
    }

    /// Configures the strategy to be used.
    /// \param strategy is a pointer to the choseen RuleStrategy object
    void config(RuleStrategy *strategy) { theStrategy_ = strategy; }

    /// Executes a RuleStrategy object
    /// \param event is a reference to the Event which linked message has triggered the agent Rule execution.
    /// \param agent is a pointer to the Agent being executed
    /// \param cellIndexPair is a pair of CellIndex objects and Cell pointers. The formers are user defined
    ///  n-dimensional coordinates for the latter.
    int execute(Event &event, class Agent *agent, pair<CellIndex, Cell*> &cellIndexPair) {
        return theStrategy_->execute(event, agent, cellIndexPair);
    }

private:
    RuleStrategy *theStrategy_; ///< Each aRule is executed as the Strategy software design pattern
};

/**
 * \brief
 *  Implementation of a FlowCondition object.
 *  It is a empty object!
 *
 */
class FlowCondition : public RuleStrategy
{
};

/**
 * \brief
 *  Implementation of a JumpCondition object.
 *
 */
class JumpCondition : public RuleStrategy
{
public:
    /// Default constructor
    JumpCondition(void):targetControlMode_(NULL), targetControlModeName_("") { }

    /// Constructor
    /// \param target is a pointer to a the JumpCondtion target ControleMode
    /// \param targetName is the name of the target ControlMode
    JumpCondition(ControlMode *target, string &targetName)
        :targetControlMode_(target),
          targetControlModeName_(targetName) { }

    /// Transits the JumpCondition object to the target ControlMode
    /// \param agent is a pointer to the LocalAgent object being executed
    /// \param cell is a pointer to the Cell object where the Rule objects are being executed
    void jump(LocalAgent* const agent, Cell *cell) {
        cell->attachControlMode((Agent*)agent, targetControlMode_);
    }

    /// Gets the JumpConfidtion target ControlMode
    /// \return A pointer to the JumpCondition target ControlMode object.
    ControlMode* getTarget(void) { return targetControlMode_;  }

    /// Configures the JumpCondition
    /// \param target is the JumpCondition target ControlMode reference
    /// \param targetName is the target ControlMode name (identifier)
    void config(ControlMode& target, string& targetName) {
        targetControlMode_ = &target;
        targetControlModeName_ =  targetName;
    }

    /// Sets the JumpCondition target ControlMode name.
    /// \param ctrlModeName is the target ControlMode name (identifier)
    void setTargetControlModeName(string ctrlModeName)
    {
    	targetControlModeName_ = ctrlModeName;
    }

    /// Gets the JumpCondition target ControlMode name.
    /// \returns A string with the JumpCondition targe ControlMode name (identifier)
    string getTargetControlModeName(void) { return targetControlModeName_; }
private:
    ControlMode* targetControlMode_; ///< The JumpCondition target ControlModel object

    string targetControlModeName_;  ///< The target ControlMode name (identifier)
};

#endif
