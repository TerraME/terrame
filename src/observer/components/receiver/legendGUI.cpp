#include "legendGUI.h"
#include "ui_legendGUI.h"

#include "observer.h"

#include <QDateTime>
#include <QDebug>

using namespace TerraMEObserver;

LegendGUI::LegendGUI(QWidget *parent)
    : QDialog(parent), ui(new Ui::legendGUI)
{
    ui->setupUi(this);

}

LegendGUI::~LegendGUI()
{
    delete ui;
}
