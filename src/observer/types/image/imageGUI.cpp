#include "imageGUI.h"
#include "ui_imageGUI.h"

// using namespace TerraMEObserver;

ImageGUI::ImageGUI(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::ImageGUI)
{
    ui->setupUi(this);
}

ImageGUI::~ImageGUI()
{
    delete ui;
}

void ImageGUI::setPath(const QString &path, const QString &prefix)
{
    ui->editPrefix->setText( prefix );
    ui->editPath->setText( path );
}

void ImageGUI::setStatusMessage(const QString &msg)
{
    ui->lblStatus->setText(msg);
}
