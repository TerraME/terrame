/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright (C) 2001-2012 INPE and TerraLAB/UFOP.
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

/*!
 * \file observer.h
 * \brief Global items of observer layer
 * \author Antonio Jose da Cunha Rodrigues
*/

#ifndef OBSERVER_GLOBAL_ITEMS
#define OBSERVER_GLOBAL_ITEMS

#include <QString>
#include <QSize>
#include <QPoint>
#include <QStringList>

namespace TerraMEObserver {

//////////////////// CONSTANTS
//// QStrings
static const QString BROADCAST_HOST = "255.255.255.255";
static const QString LOCAL_HOST = "127.0.0.1";
static const QString DEFAULT_NAME = "result_";

static const QString PROTOCOL_SEPARATOR = ":";
static const QString COMP_COLOR_SEP = ",";
static const QString ITEM_SEP = ";";
static const QString ITEM_NULL = "?";
static const QString COLORS_SEP = "#";
static const QString COLOR_BAR_SEP = "|";
static const QString SYMBOL_CHAR = "-";

static const QString WINDOW = "Window";
static const QString TRAJECTORY_LABEL = "does not belong";
static const QString TRAJECTORY_COUNT = "others";
static const QString MEMORY_ALLOC_FAILED = "Failed: Not enough memory for execute "
         "this action.";

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
static const QString SIZE = "size";
static const QString PENSTYLE = "pen";

//// QByteArrays
static const QByteArray COMPLETE_STATE = "COMPLETE_STATE";
static const QByteArray COMPLETE_SIMULATION = "COMPLETE_SIMUL";
static const QByteArray DISCONNECT_FROM_CLIENT = "DISCONNECT";
static const QByteArray VALUE_NOT_INFORMED = "not informed";
static const QByteArray TIMER_KEY = "@time";
static const QByteArray EVENT_KEY = "@event";
static const QByteArray LUA_ADDRESS = "Lua-Address";
static const QByteArray LUA_ADDRESS_TABLE = LUA_ADDRESS + "(TB): ";
static const QByteArray LUA_ADDRESS_USER_DATA = LUA_ADDRESS + "(UD): ";
static const QByteArray LUA_ADDRESS_FUNCTION = LUA_ADDRESS + "(FT): ";
static const QByteArray LUA_ADDRESS_OTHER = LUA_ADDRESS + "(O): ";

//// Lists
static const QStringList LEGEND_KEYS = QStringList() << TYPE << GROUP_MODE << SLICES
    << PRECISION << STD_DEV << MAX << MIN << COLOR_BAR << FONT_FAMILY << FONT_SIZE
    << SYMBOL << WIDTH << STYLE << SIZE << PENSTYLE; // << STD_COLOR_BAR; // is not a legend key

//// Integers
static const int LEGEND_ITENS = LEGEND_KEYS.size(); /// Number of items composing the legend of each attribute
static const int ZOOM_MAX = 11;
static const int ZOOM_MIN = -ZOOM_MAX;
static const int DEFAULT_PORT = 456456;
static const int NUMBERIC_PRECISION = 6; // sets decimal places

//// Doubles
const double MAX_FLOAT = 3.4E37;                  //!< Maximum float value
const double MIN_FLOAT = 3.4E-37;				//!< Minimum float value
const double PI = 3.14159265358979323846;		//!< The ratio of the circumference to the diameter of a circle
const double PI_DIV = 1 / PI;

//static const double INV_SIZE_CELL = 1 / SIZE_CELL;
//static const double INV_SIZE_AGENT = 1 / SIZE_AGENT;
//static const double INV_SIZE_AUTOMATON = 1 / SIZE_AUTOMATON;
static const double KILOBYTE_VALUE = 1024;
static const double KILOBYTE_DIV = 1 / KILOBYTE_VALUE;
static const double MEGABYTE_VALUE = 1024 * 1024;
static const double MEGABYTE_DIV = 1 / MEGABYTE_VALUE;

//// QSize
static const QSize ICON_SIZE(16, 16);

//// QPoint
static const QPoint ZERO_POINT(0, 0);

//////////////////// ENUMERATORS

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
    TObsSociety                //!< Society type

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
    TObsNeigh			= 11,	//!< Observes the Neighborhood type
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
* \brief TerraME Standard Deviation Grouping Type.
*
*/
enum StdDev
{
    TObsNone    = -1,   //!< None deviation
    TObsFull    =  0,   //!< Full deviation
    TObsHalf    =  1,   //!< Half deviation
    TObsQuarter =  2    //!< Quarter deviation
};

} // TerraMEObserver

#endif // OBSERVER_GLOBAL_ITEMS

