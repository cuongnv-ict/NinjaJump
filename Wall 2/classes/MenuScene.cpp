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
    if (!Layer::init()) {
        return false;
    }
    auto visibleSize = Director::getInstance()->getVisibleSize();
    _level_1 = cocos2d::Sprite::create("Layer-19.png");
    _level_2 = cocos2d::Sprite::create("Layer-18.png");
    _level_3 = cocos2d::Sprite::create("Layer-17.png");
    _level_4 = cocos2d::Sprite::create("Layer-16.png");
    _score_1 = cocos2d::Sprite::create("Layer-5.png");
    _width_level = visibleSize.width - 2 * SIZE_WALL_WIDTH;
    _scaleValue = _width_level / _level_1->getContentSize().width;
    _level_1->setScaleX(_scaleValue);
    _level_2->setScaleX(_scaleValue);
    _level_3->setScaleX(_scaleValue);
    _level_4->setScaleX(_scaleValue);
    _level_1->setScaleY(visibleSize.height / _level_1->getContentSize().height);
    _level_2->setScaleY(visibleSize.height / _level_2->getContentSize().height);
    _level_3->setScaleY(visibleSize.height / _level_3->getContentSize().height);
    _level_4->setScaleY(visibleSize.height / _level_4->getContentSize().height);
    _height_level = _level_1->getContentSize().height * _scaleValue;
    _score_1->setScaleX(_height_level / _score_1->getContentSize().height * 0.8 / _level_1->getScaleX());
    _score_1->setScaleY(_height_level / _score_1->getContentSize().height * 0.8 / _level_1->getScaleY());
    _score_1->setAnchorPoint(Vec2::ZERO);
    _level_1->setPosition(Vec2(visibleSize.width/2,visibleSize.height * 3 / 2 - _height_level * 4 + 8 *_height_level));
    _level_2->setPosition(Vec2(visibleSize.width/2,visibleSize.height * 3 / 2 - _height_level * 3 + 8 *_height_level));
    _level_3->setPosition(Vec2(visibleSize.width/2,visibleSize.height * 3 / 2 - _height_level * 2 + 8 *_height_level));
    _level_4->setPosition(Vec2(visibleSize.width/2,visibleSize.height * 3 / 2 - _height_level * 1 + 8 *_height_level));
//    _score_1->setPosition(Vec2(_width_level/2 + _score_1->getContentSize().width * _score_1->getScaleX()/2, _score_1->getContentSize().height * _score_1->getScaleY()/2));
//    _score_1->setPosition(Vec2(_width_level/2,0));
    _level_1->addChild(_score_1);
    this->addChild(_level_1, -2);
    this->addChild(_level_2, -2);
    this->addChild(_level_3, -2);
    this->addChild(_level_4, -2);
    
    _title = cocos2d::Sprite::create("Layer-10.png");
    _title->setScale(0);
    _title->setPosition(Vec2(visibleSize.width/2,visibleSize.height - 4 * _height_level - _title->getContentSize().height * _scaleValue));
    this->addChild(_title,0);
        
    //add Tag
    {
        _tag = spine::SkeletonAnimation::createWithFile("skeleton_1.json", "skeleton_1.atlas", _scaleValue);
        _tag->setAnimation(0,"Open",false);
        _tag->setPosition(Vec2(visibleSize.width/2,_title->getPositionY()/2));
        this->addChild(_tag);
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
bool MenuScene::isTag()
{
    return _isTag;
}
void MenuScene::eventTag()
{
    cocos2d::MoveBy * move1 = cocos2d::MoveBy::create(1.4, Vec2(0,8 *_height_level));
    cocos2d::MoveBy * move2 = cocos2d::MoveBy::create(0.9, Vec2(0,8 *_height_level));
    cocos2d::MoveBy * move3 = cocos2d::MoveBy::create(0.5, Vec2(0,8 *_height_level));
    cocos2d::MoveBy * move4 = cocos2d::MoveBy::create(0.2, Vec2(0,8 *_height_level));
    _level_1->runAction(move1);
    _level_2->runAction(move2);
    _level_3->runAction(move3);
    _level_4->runAction(move4);
    _title->runAction(Sequence::create(DelayTime::create(0.4),ScaleTo::create(1, 0) ,NULL));
    _tag->setAnimation(0, "tap to jump up", false);
    _tag->runAction(Sequence::create(DelayTime::create(1.0),cocos2d::MoveBy::create(0.4,Vec2(0,_title->getPositionY()/2)),DelayTime::create(1.4),FadeTo::create(1.0,0), NULL));
    
}
void MenuScene::beginPlay()
{
    cocos2d::MoveBy * move1 = cocos2d::MoveBy::create(0.25, Vec2(0,-8 *_height_level));
    cocos2d::MoveBy * move2 = cocos2d::MoveBy::create(0.5, Vec2(0,-8 *_height_level));
    cocos2d::MoveBy * move3 = cocos2d::MoveBy::create(0.75, Vec2(0,-8 *_height_level));
    cocos2d::MoveBy * move4 = cocos2d::MoveBy::create(1.0, Vec2(0,-8 *_height_level));
    _level_1->runAction(move1);
    _level_2->runAction(move2);
    _level_3->runAction(move3);
    _level_4->runAction(move4);
    _title->runAction(Sequence::create(ScaleTo::create(0.8, _scaleValue * 1.2), ScaleTo::create(0.3, _scaleValue), NULL));
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









