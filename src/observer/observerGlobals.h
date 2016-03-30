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

/*!
 * \file observer.h
 * \brief Global items of observer layer
 * \author Antonio Jose da Cunha Rodrigues 
*/

#ifndef OBSERVER_GLOBAL_ITEMS
#define OBSERVER_GLOBAL_ITEMS

#include <QString>
#include <QSize>
#include <QStringList>

namespace TerraMEObserver{

//// Constants
static const int ZOOM_MAX = 11;
static const int ZOOM_MIN = -ZOOM_MAX;

static const int SIZE_CELL = 20;
static const int SIZE_AGENT = 10;
static const int SIZE_AUTOMATON = SIZE_CELL;

static const int DEFAULT_PORT = 456456;

static const int NUMBERIC_PRECISION = 6; // sets decimal places
static const qreal PI = 3.141592653589;

static const QSize ICON_SIZE(16, 16);
static const QSize IMAGE_SIZE(1000, 1000);

static const QString BROADCAST_HOST = "255.255.255.255";
static const QString TIMER_KEY = "@time";
static const QString EVENT_KEY = "@event";
static const QString DEFAULT_NAME = "result_";

static const QString PROTOCOL_SEPARATOR = "$";

static const QString COMP_COLOR_SEP = ",";
static const QString ITEM_SEP = ";";
static const QString ITEM_NULL = "?";
static const QString COLORS_SEP = "#";
static const QString COLOR_BAR_SEP= "|";

// Legend keys
static const QString TYPE = "type";
static const QString GROUP_MODE = "grouping";
static const QString SLICES = "slices";
static const QString PRECISION = "precision";
static const QString STD_DEV = "stdDeviation";
static const QString MAX = "maximum";
static const QString MIN = "minimum";
static const QString COLOR_BAR = "colorBar";
static const QString STD_COLOR_BAR = "stdColorBar";
static const QString FONT_FAMILY = "font";
static const QString FONT_SIZE = "fontSize";
static const QString SYMBOL = "symbol";
static const QString WIDTH = "width";
static const QString STYLE = "style";
static const QString SIZE_ = "size";
static const QString PENSTYLE = "pen";

static const QStringList LEGEND_KEYS = QStringList() << TYPE << GROUP_MODE << SLICES 
    << PRECISION << STD_DEV << MAX << MIN << COLOR_BAR << FONT_FAMILY << FONT_SIZE 
    << SYMBOL << WIDTH << STYLE << SIZE_ << PENSTYLE; // << STD_COLOR_BAR; // is not a legend key
static const int LEGEND_ITENS = LEGEND_KEYS.size(); /// Numero de itens que compoem a legenda de cada atributo

static const QString VALUE_NOT_INFORMED = "not informed"; 
static const QString WINDOW = "Window";
static const QString TRAJECTORY_LABEL = "does not belong";
static const QString TRAJECTORY_COUNT = "others";
static const QString COMPLETE_STATE = "COMPLETE_STATE";
static const QString COMPLETE_SIMULATION = "COMPLETE_SIMUL";
static const QString MEMORY_ALLOC_FAILED = "Failed: Not enough memory for execute "
         "this action.";

/**
* \enum TerraMEObserver::TypesOfSubjects
* \brief TerraME Subject Types.
* 
*/
enum TypesOfSubjects 
{
    TObsUnknown         = 0,   //!< Type unknown
    TObsCell,                  //!< Cell type
    TObsCellularSpace,         //!< CellularSpace type
    TObsNeighborhood,          //!< Neighborhood type
    TObsTimer,                 //!< Timer type
    TObsEvent,                 //!< Event type
    TObsTrajectory,            //!< Trajectory type
    TObsAutomaton,             //!< Automaton type
    TObsAgent,                 //!< Agent type
    TObsEnvironment,            //!< Environment type
    TObsSociety            //!< Environment type

    // TObsMessage,            // it isn't a Subject
    // TObsState,              // it isn't a Subject
    // TObsJumpCondition,      // it isn't a Subject
    // TObsFlowCondition,      // it isn't a Subject
};

/**
* \enum TerraMEObserver::TypesOfObservers
* \brief TerraME Observer Types.
*
*/
enum TypesOfObservers
{
    TObsUndefined       =  0,   //!< Undefined type
    TObsTextScreen      =  1,   //!< TextScreen type
    TObsLogFile         =  2,   //!< LogFile type
    TObsTable           =  3,   //!< Table type
    TObsGraphic         =  4,   //!< Graphic type
    TObsDynamicGraphic  =  5,   //!< Observes one attribute over the time
    TObsMap             =  6,   //!< Observes one or two attributes over the space
    TObsUDPSender       =  7,   //!< Sends the attributes via UDP protocol
    TObsScheduler       =  8,   //!< Observes the scheduler's event
    TObsImage           =  9,   //!< Saves in an image the attributes observed over the space
    TObsStateMachine    = 10,    //!< Observes the states and transitions of a State Machine type
    TObsNeigh           = 11,	//!< Observes the Neighborhood type
    TObsShapefile       = 12,    //!< Observes the Shapefile type
    TObsTCPSender       = 13    //!< Sends the attributes via TCP protocol
};

/**
* \enum TerraMEObserver::TypesOfData
* \brief TerraME Data Types.
*
*/
enum TypesOfData
{
    TObsBool,                   //!< Boolean type
    TObsNumber,                 //!< Numeric type 
    TObsDateTime,               //!< Time stamp type 
    TObsText,                   //!< Textual type
    TObsUnknownData     = 100   //!< Unknown type
};

/**
* \enum TerraMEObserver::GroupingMode
* \brief TerraME Grouping Mode.
*
*/
enum GroupingMode
{
    TObsEqualSteps      = 0,    //!< Equal steps type
    TObsQuantil         = 1,    //!< Quantil type
    TObsStdDeviation    = 2,    //!< Standard deviation type
    TObsUniqueValue     = 3     //!< Unique value type
};

/**
* \enum TerraMEObserver::StdDev
* \brief TerraME Standard Deviation Groupping Type.
*
*/
enum StdDev
{
    TObsNone    = -1,   //!< None deviation
    TObsFull    =  0,   //!< Full deviation
    TObsHalf    =  1,   //!< Half deviation
    TObsQuarter =  2    //!< Quarter deviation
};

}

#endif // OBSERVER_GLOBAL_ITEMS

