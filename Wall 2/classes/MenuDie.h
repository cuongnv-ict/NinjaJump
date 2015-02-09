//
//  MenuDie.h
//  Wall
//
//  Created by Nguyen Van Cuong on 2/6/15.
//
//

#ifndef __Wall__MenuDie__
#define __Wall__MenuDie__

#include "cocos2d.h"

#define SPACE 20
#define SIZE 100
USING_NS_CC;
class MenuDie : public cocos2d::Layer
{
public:
    virtual bool init();
    void menuHome(cocos2d::Ref * pSender);
    void menuShare(cocos2d::Ref * pSender);
    void menuRate(cocos2d::Ref * pSender);
    void menuReplay(cocos2d::Ref * pSender);
    void menuRank(cocos2d::Ref * pSender);
    void menuMoreGame(cocos2d::Ref * pSender);
    bool isHome();
    bool isReplay();
    void reset();
    CREATE_FUNC(MenuDie);
private:
    cocos2d::MenuItemImage * _rank;
    cocos2d::MenuItemImage * _home;
    cocos2d::MenuItemImage * _rate;
    cocos2d::MenuItemImage * _replay;
    cocos2d::MenuItemImage * _share;
    cocos2d::MenuItemImage * _more_game;
    cocos2d::LabelTTF * _title_score;
    cocos2d::LabelTTF * _title_hiscore;
    cocos2d::LabelTTF * _value_score;
    cocos2d::LabelTTF * _value_hiscore;
    cocos2d::LabelTTF * _game_over;
    bool _ishome,_isreplay;
    cocos2d::Sprite * _best;
    cocos2d::Sprite * _background;
    cocos2d::Sprite * _back;
    cocos2d::Menu * _menu;
};
#endif /* defined(__Wall__MenuDie__) */
