#ifndef LEGEND_GUI_H
#define LEGEND_GUI_H

#include <QDialog>
#include <QSignalMapper>

namespace Ui {
class legendGUI;
}

/**
 * \brief User interface for build legend
 * \see QDialog
 * \author Antonio Jose da Cunha Rodrigues
 * \file .h
 */
class LegendGUI : public QDialog
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget object
     * \see QWidget
     */
    LegendGUI(QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~LegendGUI();


signals:


private slots:

private:
    Ui::legendGUI *ui;

};

#endif // LEGEND_GUI_H
