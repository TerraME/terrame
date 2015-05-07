#include "player.h"
#include "playerGUI.h"

using namespace TerraMEObserver;

Player & Player::getInstance()
{
    static Player player;
    return player;
}

// Player::Player(Subject *sub) : ObserverInterf(sub)
Player::Player()
{
    playerGUI = new PlayerGUI();
}

Player::~Player()
{
    delete playerGUI;
}

//bool Player::draw(QDataStream &)
//{
//    QString msg;
//    return true;
//}
//
//const TypesOfObservers Player::getObserverType()
//{
//    return observerType;
//}
//
//QStringList Player::getAttributes()
//{
//    return itemList;
//}
//
//int Player::close()
//{
//    PlayerGUI->close();
//    return 0;
//}

void Player::appendMessage(const QString & msg)
{
    playerGUI->appendMessage(msg);
}

void Player::setActiveButtons(bool active)
{
    playerGUI->setEnabled(active);
}

void Player::show()
{
    playerGUI->showNormal();
}

void Player::setEnabled(bool enabled)
{
    playerGUI->setEnabled(enabled);
}

bool Player::isEnabled()
{
    return playerGUI->isEnabled();
}
