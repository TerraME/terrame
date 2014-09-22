#include "modelConsole.h"
#include "ui_modelConsoleGUI.h"

#include <QDebug>

ModelConsole::ModelConsole(QWidget *parent) 
    : QWidget(parent), ui(new Ui::ModelConsoleGUI)
{
    ui->setupUi(this);
}

ModelConsole::~ModelConsole()
{
    delete ui;
}

//ModelConsole& ModelConsole::getInstance()
//{
//    static ModelConsole modelConsole;
//    return modelConsole;
//}

void ModelConsole::appendMessage(const QString &s)
{
    ui->tfMessages->append(s);
}
