#ifndef RECEIVER_GUI_H
#define RECEIVER_GUI_H

#include <QDialog>
#include <QSignalMapper>
#include <QHash>

#include "observer.h"

class QCloseEvent;
class LuaLegend;

namespace Ui {
class receiverGUI;
}

using namespace TerraMEObserver;

/**
 * \brief User interface for Udp Receiver
 * \see QDialog
 * \author Antonio Jose da Cunha Rodrigues
 * \file observerUDPSenderGUI.h
 */
class ReceiverGUI : public QDialog
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget object
     * \see QWidget
     */
    ReceiverGUI(QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~ReceiverGUI();

    /**
     * Sets the receiver state and the port number
     * \param state the receiver state
     * \param port the communication port
     */
    void setStatusAndPort(const QString &state, int port);

    /**
     * Sets the number of states received
     * \param stateNum number of state received
     */
    void setStatesStatus(int stateNum);

    /**
     * Sets the number of messages received
     * \param msgNum number of messages received
     */
    void setMessagesStatus(int msgNum);

    /**
     * Sets the speed sent
     * \param speed a reference for a QString speed
     * \see QString
     */
    void setSpeed(const QString &speed);

    /**
     * Appends a message into the user interface
     * \param msg a reference to the message
     */
    void appendMessage(const QString &msg);

    /**
     * Sets the condition of the send message. Default is uncompress.
     * \param compress boolean, if \a true message sent is compress.
     * Otherwise, message is not compressed.
     */
    void setCompression(bool compress);

    // const QString * getAttributes(int pos) const;
    // inline int getAttributesSize() { return attributes.size(); }
    QStringList * getAttributes(int pos) const;

    int getTypeSelected() const;

    int getDimX() const;
    int getDimY() const;

    QStringList * getLegendKeys(int) const;
    const QStringList getLegendValue(int) const;
    int getNumberOfObservers() const;

    void clearLog();

signals:
    void blindListenPort(quint16);
    void createObserver();

private slots:
    /**
     * Treats the click in the blindListen button
     */
    void blindListenButtonClicked();
    /**
     * Treats the click in the close button
     */
    void closeButtonClicked();
    void okButtonClicked();
    void obsTypeSelected(int);
    void dataTypeSelected(int);
    void grpTypeSelected(int);
    void stdTypeSelected(int);
    void consistGUI(int listRow);
    void consistButtons(const QString &);
    void clearAll();

    // Autoconnected slots
    void on_maxDoubleSpin_valueChanged(double);
    void on_minDoubleSpin_valueChanged(double);
    void on_slicesSpin_valueChanged(int);
    void on_widthSpin_valueChanged(int);
    void on_precisionSpin_valueChanged(int);
    void on_fontComboBox_currentFontChanged(const QFont &);
    void on_lineStylecombo_currentIndexChanged(int);
    void on_curveSymbolCombo_currentIndexChanged(const QString &);
    void on_curveStyleCombo_currentIndexChanged(int);
    void on_colorBarLine_textChanged(const QString&);
    void on_stdColorBarLine_textChanged(const QString&);

protected:
    void closeEvent(QCloseEvent *event);

private:
    void setupGUI();
    void writeSettings();
    void readSettings();

    Ui::receiverGUI *ui;

    QList<QStringList> attributesList;
    QList<QStringList> keysList;
    QSignalMapper *signalMapper, *signalMapperAttrType;
    QSignalMapper *signalMapperGrpType, *signalMapperStdType;

    TypesOfObservers obsType;
    //TypesOfData dataType;
    //GroupingMode grpType;
    //StdDev stdType;

    int activeItem;
    QString activeItemName;
    QHash<QString, LuaLegend *> luaLegendHash;

};

#endif // RECEIVER_GUI_H

