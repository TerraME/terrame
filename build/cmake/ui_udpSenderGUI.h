/********************************************************************************
** Form generated from reading UI file 'udpSenderGUI.ui'
**
** Created by: Qt User Interface Compiler version 5.3.2
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_UDPSENDERGUI_H
#define UI_UDPSENDERGUI_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QDialog>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>
#include <QtWidgets/QPlainTextEdit>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QVBoxLayout>

QT_BEGIN_NAMESPACE

class Ui_UdpSenderGUI
{
public:
    QVBoxLayout *verticalLayout;
    QHBoxLayout *horizontalLayout_2;
    QLabel *label;
    QSpacerItem *horizontalSpacer;
    QPushButton *pushButton;
    QPlainTextEdit *logEdit;
    QHBoxLayout *horizontalLayout;
    QLabel *lblPortStatus;
    QLabel *lblCompress;
    QLabel *lblStatesSent;
    QLabel *lblMessagesSent;
    QLabel *lblSpeedStatus;

    void setupUi(QDialog *UdpSenderGUI)
    {
        if (UdpSenderGUI->objectName().isEmpty())
            UdpSenderGUI->setObjectName(QStringLiteral("UdpSenderGUI"));
        UdpSenderGUI->resize(516, 200);
        verticalLayout = new QVBoxLayout(UdpSenderGUI);
        verticalLayout->setSpacing(4);
        verticalLayout->setContentsMargins(4, 4, 4, 4);
        verticalLayout->setObjectName(QStringLiteral("verticalLayout"));
        horizontalLayout_2 = new QHBoxLayout();
        horizontalLayout_2->setSpacing(4);
        horizontalLayout_2->setObjectName(QStringLiteral("horizontalLayout_2"));
        horizontalLayout_2->setContentsMargins(2, -1, -1, -1);
        label = new QLabel(UdpSenderGUI);
        label->setObjectName(QStringLiteral("label"));

        horizontalLayout_2->addWidget(label);

        horizontalSpacer = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

        horizontalLayout_2->addItem(horizontalSpacer);

        pushButton = new QPushButton(UdpSenderGUI);
        pushButton->setObjectName(QStringLiteral("pushButton"));

        horizontalLayout_2->addWidget(pushButton);


        verticalLayout->addLayout(horizontalLayout_2);

        logEdit = new QPlainTextEdit(UdpSenderGUI);
        logEdit->setObjectName(QStringLiteral("logEdit"));
        logEdit->setReadOnly(true);

        verticalLayout->addWidget(logEdit);

        horizontalLayout = new QHBoxLayout();
        horizontalLayout->setSpacing(3);
        horizontalLayout->setObjectName(QStringLiteral("horizontalLayout"));
        lblPortStatus = new QLabel(UdpSenderGUI);
        lblPortStatus->setObjectName(QStringLiteral("lblPortStatus"));
        lblPortStatus->setMinimumSize(QSize(120, 18));
        lblPortStatus->setFrameShape(QFrame::Panel);
        lblPortStatus->setFrameShadow(QFrame::Sunken);

        horizontalLayout->addWidget(lblPortStatus);

        lblCompress = new QLabel(UdpSenderGUI);
        lblCompress->setObjectName(QStringLiteral("lblCompress"));
        lblCompress->setMinimumSize(QSize(60, 18));
        lblCompress->setFrameShape(QFrame::Panel);
        lblCompress->setFrameShadow(QFrame::Sunken);

        horizontalLayout->addWidget(lblCompress);

        lblStatesSent = new QLabel(UdpSenderGUI);
        lblStatesSent->setObjectName(QStringLiteral("lblStatesSent"));
        lblStatesSent->setMinimumSize(QSize(100, 18));
        lblStatesSent->setFrameShape(QFrame::Panel);
        lblStatesSent->setFrameShadow(QFrame::Sunken);

        horizontalLayout->addWidget(lblStatesSent);

        lblMessagesSent = new QLabel(UdpSenderGUI);
        lblMessagesSent->setObjectName(QStringLiteral("lblMessagesSent"));
        lblMessagesSent->setMinimumSize(QSize(100, 18));
        lblMessagesSent->setFrameShape(QFrame::Panel);
        lblMessagesSent->setFrameShadow(QFrame::Sunken);

        horizontalLayout->addWidget(lblMessagesSent);

        lblSpeedStatus = new QLabel(UdpSenderGUI);
        lblSpeedStatus->setObjectName(QStringLiteral("lblSpeedStatus"));
        lblSpeedStatus->setMinimumSize(QSize(90, 18));
        lblSpeedStatus->setFrameShape(QFrame::Panel);
        lblSpeedStatus->setFrameShadow(QFrame::Sunken);

        horizontalLayout->addWidget(lblSpeedStatus);


        verticalLayout->addLayout(horizontalLayout);


        retranslateUi(UdpSenderGUI);
        QObject::connect(pushButton, SIGNAL(clicked()), UdpSenderGUI, SLOT(close()));

        QMetaObject::connectSlotsByName(UdpSenderGUI);
    } // setupUi

    void retranslateUi(QDialog *UdpSenderGUI)
    {
        UdpSenderGUI->setWindowTitle(QApplication::translate("UdpSenderGUI", "TerraME Observer :: UDP Sender", 0));
        label->setText(QApplication::translate("UdpSenderGUI", "UDP Log messages: ", 0));
        pushButton->setText(QApplication::translate("UdpSenderGUI", "Close", 0));
        lblPortStatus->setText(QApplication::translate("UdpSenderGUI", "Sending at: 456456", 0));
        lblCompress->setText(QApplication::translate("UdpSenderGUI", "Compress off", 0));
        lblStatesSent->setText(QApplication::translate("UdpSenderGUI", "States sent: 0", 0));
        lblMessagesSent->setText(QApplication::translate("UdpSenderGUI", "Messages sent:", 0));
        lblSpeedStatus->setText(QApplication::translate("UdpSenderGUI", "Speed: unknown", 0));
    } // retranslateUi

};

namespace Ui {
    class UdpSenderGUI: public Ui_UdpSenderGUI {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_UDPSENDERGUI_H
