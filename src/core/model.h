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

/**
 * \file model.h
 * \author Tiago Garcia de Senna Carneiro
 */

#ifndef MODEL
#define MODEL

#include "bridge.h"
#include <string>

#include <sstream>
#include <stdio.h>

#if defined(TME_WIN32)
#include <iostream>
#else
//#include <iostream.h>
#endif

using namespace std;

typedef string ModelID;

/**
 * \brief Defines the interface for a general purpose model.
 *
 * Model Class: defines the interface for a general purpose model. Its derivatives interfaces
 * could model regions, watches, the laws that govern the behavior of some phenomenon
 * or interference resulting from the co-operation of autonomous individuals communities
 * over a given environment.
 * To implement these subclasses the programmer could make use of mathematical models,
 * for example, cells that model regions generally rectangular or hexagonal of space.
 * Simulation algorithms such as Monte Carlo simulation or simulation ran for events
 * could be used to implement the clocks. State machines like finite state automata or
 * stack of automaton could be utilized to model the behavior of phenomena. Artificial
 * intelligence techniques as agents could be utilized to simulate autonomous individuals.
 */

/**
 * \brief
 *  Implementation for a Model object.
 *
 */
class ModelImpl : public Implementation
{
public:
    /// Constructor
    ModelImpl(void)
	{
        char strNum[255];

        sprintf(strNum, "%ld", modelCounter);

        setID(string("model") + strNum); modelCounter++;
    }
    void setID(ModelID id) { modelID = id; }
    ModelID getID(void) { return modelID; }
    ModelID setId(ModelID id) { modelID = modelID + ":" + id; return modelID; }
private:
    ModelID modelID;
    static long int modelCounter;
};

/**
 * \brief
 *  Handle for a Model object.
 *
 */
class Model: public Interface<ModelImpl>
{
public:
    ModelID getID(void) { return pImpl_->getID(); }
    virtual void update(void) { }

    ModelID setId(ModelID id) { return pImpl_->setId(id); }
};

#endif

