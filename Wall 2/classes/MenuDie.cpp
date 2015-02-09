//
//  MenuDie.cpp
//  Wall
//
//  Created by Nguyen Van Cuong on 2/6/15.
//
//

#include "MenuDie.h"

bool MenuDie::init()
{
    if(!Layer::init())
    {
        return false;
    }
    this->setColor(Color3B(0,0,0));
    Size visible = Director::getInstance()->getVisibleSize();
    // add background
    {
        _back = Sprite::create("back.png");
        _back->setOpacity(128);
        _back->setAnchorPoint(Vec2::ZERO);
        _back->setScaleX(visible.width / _back->getContentSize().width);
        _back->setScaleY(visible.height / _back->getContentSize().height);
        this->addChild(_back);
    }
    // add Menu
    {
        //===================================================================================
        _home = MenuItemImage::create("2.png", "2.png",CC_CALLBACK_1(MenuDie::menuHome, this));
        _rate = MenuItemImage::create("4.png","4.png",CC_CALLBACK_1(MenuDie::menuRate, this));
        _rank = MenuItemImage::create("3.png","3.png",CC_CALLBACK_1(MenuDie::menuRank,this));
        _replay = MenuItemImage::create("5.png","5.png",CC_CALLBACK_1(MenuDie::menuReplay,this));
        _home->setScale(SIZE / _home->getContentSize().width);
        _rank->setScale(SIZE / _rank->getContentSize().width);
        _rate->setScale(SIZE / _rate->getContentSize().width);
        _replay->setScale(SIZE / _replay->getContentSize().width);
        _home->setPosition(visible.width/2 - _home->getContentSize().width * _home->getScale()/2 - SIZE - 1.5 * SPACE, visible.height/4);
        _rank->setPosition(visible.width/2 - _rank->getContentSize().width * _rank->getScale()/2 - 0.5 * SPACE, visible.height/4);
        _rate->setPosition(visible.width/2 + _rate->getContentSize().width * _rate->getScale()/2 + 0.5 * SPACE, visible.height/4);
        _replay->setPosition(visible.width/2 + _replay->getContentSize().width * _replay->getScale()/2 + SIZE + 1.5 * SPACE, visible.height/4);
        //===================================================================================
        _share = MenuItemImage::create("6.png","6.png",CC_CALLBACK_1(MenuDie::menuShare, this));
        _more_game = MenuItemImage::create("6.png","6.png",CC_CALLBACK_1(MenuDie::menuMoreGame,this));
        _share->setScale(1.5 * SIZE / _share->getContentSize().width);
        _more_game->setScale(1.5 * SIZE / _more_game->getContentSize().width);
        _share->setPosition(visible.width/2 - _share->getContentSize().width * _share->getScale()/ 2 - SPACE,_home->getPositionY() + 1.25 * SIZE);
        _more_game->setPosition(visible.width/2 + _more_game->getContentSize().width * _more_game->getScale()/ 2 + SPACE,_home->getPositionY() + 1.25 * SIZE);
        
        _menu = Menu::create(_home,_rank,_rate,_replay,_share,_more_game, NULL);
        _menu->setPosition(0, 0);
        this->addChild(_menu);
    }
    //add Score
    {
        _background = Sprite::create("1.png");
        _background->setScaleX((4 * SIZE + 1.5 * SPACE) / _background->getContentSize().width);
        _background->setScaleY(2.5 * SIZE / _background->getContentSize().height);
        _background->setPosition(visible.width/2,_share->getPositionY() + _background->getContentSize().height * _background->getScaleY()/2 + 1.25 * SIZE);
        this->addChild(_background);
        
        UserDefault * user = UserDefault::getInstance();
        int score = user->getIntegerForKey("score", 0);
        int hiscore = user->getIntegerForKey("hiscore", 0);
        char str_score[50],str_hiscore[50];
        sprintf(str_score,"%d",score);
        if(score > hiscore)
        {
            sprintf(str_hiscore,"%d",score);
            user->setIntegerForKey("hiscore", score);
            user->flush();
        }
        else
        {
            sprintf(str_hiscore,"%d",hiscore);
        }
       
        _title_score = LabelTTF::create("Score",  "Arial", 80);
        _title_score->setScale(0.75 * _background->getContentSize().height*_background->getScaleY()/6 / _title_score->getContentSize().height );
        _title_score->setAnchorPoint(Vec2::ANCHOR_MIDDLE_BOTTOM);
        _title_score->setPosition(visible.width/2, _background->getPositionY()+ _background->getContentSize().height*_background->getScaleY()/3 - _background->getContentSize().height*_background->getScaleY()*0.05);
        _title_score->setColor(cocos2d::Color3B(0,0,0));
        this->addChild(_title_score);
        
        _value_score = LabelTTF::create(str_score,  "Arial", 80);
        _value_score->setScale(0.75 * _background->getContentSize().height*_background->getScaleY()/3 / _value_score->getContentSize().height );
        _value_score->setPosition(visible.width/2, _background->getPositionY()+ _background->getContentSize().height*_background->getScaleY()/6 - _background->getContentSize().height*_background->getScaleY()*0.05);
        _value_score->setColor(cocos2d::Color3B(0,0,0));
        this->addChild(_value_score);

        
        _title_hiscore = LabelTTF::create("Hi-Score",  "Arial", 80);
        _title_hiscore->setScale(0.75 * _background->getContentSize().height*_background->getScaleY()/6 / _title_hiscore->getContentSize().height );

        _title_hiscore->setAnchorPoint(Vec2::ANCHOR_MIDDLE_BOTTOM);
        _title_hiscore->setPosition(visible.width/2, _background->getPositionY()- _background->getContentSize().height*_background->getScaleY()/6 );
        _title_hiscore->setColor(cocos2d::Color3B(0,0,0));
        this->addChild(_title_hiscore);
        
        if(score > hiscore)
        {
            _best = Sprite::create("6.png");
            _best->setScale(0.6 * _background->getContentSize().height*_background->getScaleY()/6 / _best->getContentSize().height );
            _best->setAnchorPoint(Vec2::ANCHOR_MIDDLE_BOTTOM);
            _best->setPosition(visible.width / 2 + _background->getContentSize().width * _background->getScaleX()/4,_background->getPositionY()- _background->getContentSize().height*_background->getScaleY()/6);
            this->addChild(_best);
        }
        
        _value_hiscore = LabelTTF::create(str_hiscore,  "Arial", 80);
        _value_hiscore->setScale(0.75 * _background->getContentSize().height*_background->getScaleY()/3 / _value_hiscore->getContentSize().height );

        _value_hiscore->setPosition(visible.width/2, _background->getPositionY()- _background->getContentSize().height*_background->getScaleY()/3 );
        _value_hiscore->setColor(cocos2d::Color3B(0,0,0));
        this->addChild(_value_hiscore);

    }
    // add Title Game Over
    {
        _game_over = LabelTTF::create("Game Over !", "Arial", 80);
        _game_over->setScale((4 * SIZE + 1.5 * SPACE) / _game_over->getContentSize().width);
        _game_over->setPosition(visible.width/2,_background->getPositionY()+_background->getContentSize().height * _background->getScaleY()/2 + SIZE);
        this->addChild(_game_over);
    }
    // init Flags
    {
        _ishome = false;
        _isreplay = false;
    }

    return true;
}
void MenuDie::menuHome(cocos2d::Ref *pSender)
{
    _ishome = true;
}
void MenuDie::menuMoreGame(cocos2d::Ref *pSender)
{
  
}
void MenuDie::menuRank(cocos2d::Ref *pSender)
{
    
}
void MenuDie::menuShare(cocos2d::Ref *pSender)
{
    
}
void MenuDie::menuReplay(cocos2d::Ref *pSender)
{
    _isreplay = true;
}
void MenuDie::menuRate(cocos2d::Ref *pSender)
{

}
bool MenuDie::isHome()
{
    return _ishome;
}
bool MenuDie::isReplay()
{
    return _isreplay;
}
void MenuDie::reset()
{
    _ishome = false;
    _ishome = false;
}