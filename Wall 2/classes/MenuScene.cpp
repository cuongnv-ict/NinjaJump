//
//  MenuScene.cpp
//  Wall
//
//  Created by Nguyen Van Cuong on 1/23/15.
//
//

#include "MenuScene.h"
#include "MyDefine.h"
#include "cocos2d.h"
bool MenuScene::init()
{
    if (!Node::init()) {
        return false;
    }
    auto visibleSize = Director::getInstance()->getVisibleSize();
    _level_1 = cocos2d::Sprite::create("Layer-19.png");
    _level_2 = cocos2d::Sprite::create("Layer-18.png");
    _level_3 = cocos2d::Sprite::create("Layer-17.png");
    _level_4 = cocos2d::Sprite::create("Layer-16.png");
    _width_level = visibleSize.width - 2 * SIZE_WALL_WIDTH;
    _scaleValue = _width_level / _level_1->getContentSize().width;
    _level_1->setScaleX(_scaleValue);
    _level_2->setScaleX(_scaleValue);
    _level_3->setScaleX(_scaleValue);
    _level_4->setScaleX(_scaleValue);
    _level_1->setScaleY(visibleSize.height / _level_1->getContentSize().height);
    _level_2->setScaleY(visibleSize.height / _level_1->getContentSize().height);
    _level_3->setScaleY(visibleSize.height / _level_1->getContentSize().height);
    _level_4->setScaleY(visibleSize.height / _level_1->getContentSize().height);
    _height_level = _level_1->getContentSize().height * _scaleValue;
    _level_1->setPosition(Vec2(visibleSize.width/2,3/2*visibleSize.height - _height_level * 3.5 + 8 *_height_level + visibleSize.height /2));
    _level_2->setPosition(Vec2(visibleSize.width/2,3/2*visibleSize.height - _height_level * 2.5 + 8 *_height_level + visibleSize.height /2));
    _level_3->setPosition(Vec2(visibleSize.width/2,3/2*visibleSize.height - _height_level * 1.5 + 8 *_height_level + visibleSize.height /2));
    _level_4->setPosition(Vec2(visibleSize.width/2,3/2*visibleSize.height - _height_level * 0.5 + 8 *_height_level + visibleSize.height /2));
    this->addChild(_level_1, -2);
    this->addChild(_level_2, -2);
    this->addChild(_level_3, -2);
    this->addChild(_level_4, -2);
    
    _title = cocos2d::Sprite::create("Layer-10.png");
    _title->setScale(_scaleValue);
    _title->setPosition(Vec2(visibleSize.width/2,visibleSize.height - 4 * _height_level - _title->getContentSize().height * _scaleValue));
    this->addChild(_title,0);
    
    _cloud = cocos2d::Sprite::create("Layer-11.png");
    _cloud->setPosition(Vec2(visibleSize.width/2 - 3 * _title->getContentSize().width / 8 * _scaleValue,visibleSize.height - 4 * _height_level - _title->getContentSize().height * _scaleValue/3));
    _cloud->setScale(_scaleValue);
    this->addChild(_cloud,-1);
    
    _drats = cocos2d::Sprite::create("Layer-12.png");
    _drats->setScale(_scaleValue);
    _drats->setPosition(Vec2(visibleSize.width/2 + 7 * _title->getContentSize().width * _scaleValue /16, visibleSize.height - 4 * _height_level - 4 * _title->getContentSize().height * _scaleValue/3 - _drats->getContentSize().height * _scaleValue /2));
    this->addChild(_drats,-1);
    
    _background = cocos2d::Sprite::create("Layer-8.png");
    _leftTag = MenuItemImage::create("Layer-6.png","Layer-6.png",CC_CALLBACK_1(MenuScene::menuLeft, this));
    _rightTag = MenuItemImage::create("Layer-7.png","Layer-7.png",CC_CALLBACK_1(MenuScene::menuRight, this));
    _leftTag->setScale(_scaleValue);
    _rightTag->setScale(_scaleValue);
    _background->setScale(_scaleValue);
    _leftTag->setPosition(Vec2(visibleSize.width/2 - _background->getContentSize().width* _background->getScale()/2 -_leftTag->getContentSize().width * _leftTag->getScale()/2,_drats->getPosition().y - _leftTag->getContentSize().height * _leftTag->getScale()/2 - _drats->getScale()* _drats->getContentSize().height/2));
    _rightTag->setPosition(Vec2(visibleSize.width/2 + _background->getContentSize().width* _background->getScale()/2 +_rightTag->getContentSize().width * _leftTag->getScale()/2,_drats->getPosition().y - _rightTag->getContentSize().height * _rightTag->getScale()/2 - _drats->getScale()* _drats->getContentSize().height/2));
     _background->setPosition(Vec2(visibleSize.width/2,_leftTag->getPosition().y - _leftTag->getScale()*_leftTag->getContentSize().height/2 + _background->getContentSize().height * _background->getScale()/2));
    this->addChild(_background, 0);
    menu = Menu::create(_leftTag,_rightTag, NULL);
    menu->setPosition(Vec2::ZERO);
    this->addChild(menu, 1);
    //add Ninja
    {
        ninja = spine::SkeletonAnimation::createWithFile("skeleton.json", "skeleton.atlas", 0.175f);
        ninja->setAnimation(0,"Stay",true);
        ninja->setPosition(Vec2(visibleSize.width/2,0));
        //this->addChild(ninja);
    }
    // init value
    {
        _isLevel = true;
        _isTag = false;
        _isRun = true;
    }
    schedule(schedule_selector(MenuScene::update), 1.0/60);
    return true;
}
spine::SkeletonAnimation * MenuScene::getSpine()
{
    return ninja;
}
void MenuScene::menuLeft(cocos2d::Ref * pSender)
{
    if(_isLevel){
        return;
    }
    eventTag();
//    ninja->setAnimation(0, "Run on wall_2", true);
//    ninja->setScaleX(-1);
//    ninja->setPosition(0.175 * SIZE_NINJA + SIZE_WALL_WIDTH, NINJA_POSITION_Y);
    _isTag = true;
    this->removeChild(menu);
}
void MenuScene::menuRight(cocos2d::Ref * pSender)
{
    if(_isLevel){
        return;
    }
    eventTag();
//    ninja->setScaleX(1);
//    ninja->setAnimation(0, "Run on wall_2", true);
//    ninja->setPosition(Director::getInstance()->getVisibleSize().width - (0.175 * SIZE_NINJA + SIZE_WALL_WIDTH), NINJA_POSITION_Y);
    _isTag = true;
    this->removeChild(menu);
}
bool MenuScene::isTag()
{
    return _isTag;
}
void MenuScene::eventTag()
{
    cocos2d::MoveBy  * moveLeft = cocos2d::MoveBy::create(0.75, Vec2(-2* Director::getInstance()->getVisibleSize().width,0));
    cocos2d::MoveBy  * moveRight = cocos2d::MoveBy::create(0.75, Vec2(2* Director::getInstance()->getVisibleSize().width,0));
    cocos2d::FadeTo * fadeto = cocos2d::FadeTo::create(1, 0);
    cocos2d::FadeOut * fadeout = cocos2d::FadeOut::create(0);
    _level_1->runAction(moveLeft);
    _level_2->runAction(moveRight);
    _level_3->runAction(moveLeft->clone());
    _level_4->runAction(moveRight->clone());
    _cloud->runAction(fadeto);
    _drats->runAction(fadeto->clone());
    _title->runAction(fadeto->clone());
    _leftTag->runAction(fadeout);
    _rightTag->runAction(fadeout->clone());
    _background->runAction(fadeout->clone());
}
void MenuScene::beginPlay()
{
    cocos2d::MoveBy * move1 = cocos2d::MoveBy::create(2, Vec2(0,-8 *_height_level));
    cocos2d::MoveBy * move2 = cocos2d::MoveBy::create(2.25, Vec2(0,-8 *_height_level));
    cocos2d::MoveBy * move3 = cocos2d::MoveBy::create(2.5, Vec2(0,-8 *_height_level));
    cocos2d::MoveBy * move4 = cocos2d::MoveBy::create(2.75, Vec2(0,-8 *_height_level));
    _level_1->runAction(move1);
    _level_2->runAction(move2);
    _level_3->runAction(move3);
    _level_4->runAction(move4);
}
void MenuScene::update(float deta)
{
    if(_isLevel)//Trong  qua trinh troi bang dien xuong
    {
        if(_isRun)
        {
            beginPlay();
            _isRun = false;
            
        }
        if(_level_4->getNumberOfRunningActions()==0)
        {
            _isLevel = false;
        }
    }
    else //Cho qua trinh chon tuong chay
    {
        if(_isTag) //da tag chon tuong
        {
            
        }
    }
}








