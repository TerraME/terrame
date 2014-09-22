/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright � 2001-2012 INPE and TerraLAB/UFOP.
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

#ifndef LOG_FILE_TASK_H
#define LOG_FILE_TASK_H

#include <QByteArray>
#include <QString>
#include <QStringList>

#include "observer.h"
#include "task.h"

namespace TerraMEObserver {

// class Attributes;
class SubjectAttributes;

class LogFileTask : public BagOfTasks::Task
{
public:
    /** 
     * Constructor
     */
    LogFileTask(int subjID, TypesOfSubjects subjType);
    
    /**
     * Destructor
     */
    virtual ~LogFileTask();

    /**
     * Overload of task method.
     * \copydoc BagOfTasks::Task::execute
     */
    virtual bool execute();

    void setProperties(const QString &filename = DEFAULT_NAME + ".csv", 
        const QString &separator = ";", const QString &mode = "w");

    void setFilename(const QString &filename = DEFAULT_NAME + ".csv");
    void setSeparator(const QString &separator = ";");
    void setWriteMode(const QString &mode = "w");
    const QString & getWriteMode() const;

    void createHeader(const QStringList &attribs);
    inline const QStringList & getAttributes() const
    {
        return attribList;
    }

protected:
    bool executing;

private:

    /**
     * Saves the data in hard disk
     * \return true if could save the data
     */
    bool rendering();

    /**
     * Draws/Prepares the data in a writeble format
     * \return true if could draw the data
     */
    bool draw();

    const int subjectId;
    TypesOfSubjects subjectType;

    bool header;
    QString filename, separator, mode;
    QStringList attribList, valuesList;
};

}

#endif // LOG_FILE_TASK_H
