//
//  MenuScene.h
//  Wall
//
//  Created by Nguyen Van Cuong on 1/23/15.
//
//

#ifndef __Wall__MenuScene__
#define __Wall__MenuScene__

#include <iostream>
#include "cocos2d.h"
#include "spine/spine-cocos2dx.h"
USING_NS_CC;
class MenuScene : public cocos2d::Node
{
public :
    virtual bool init();
    void eventTag();
    void beginPlay();
    void update(float delta);
//    std::function<void (cocos2d::Ref*)> menuLeft;
//    std::function<void (cocos2d::Ref*)> menuRight;
    void menuLeft(cocos2d::Ref* pSender);
    void menuRight(cocos2d::Ref* pSender);
    bool isTag();
    cocos2d::Sprite * _level_1;
    cocos2d::Sprite * _level_2;
    cocos2d::Sprite * _level_3;
    cocos2d::Sprite * _level_4;
    cocos2d::Sprite * _title;
    cocos2d::Sprite * _cloud;
    cocos2d::Sprite * _drats;
    cocos2d::Sprite * _background;
    cocos2d::MenuItemImage * _leftTag;
    cocos2d::MenuItemImage * _rightTag;
    bool _isLevel,_isTag,_isRun;

    spine::SkeletonAnimation * getSpine();
    CREATE_FUNC(MenuScene);
private:
        spine::SkeletonAnimation * ninja;
    Menu *menu;
    float _height_level,_width_level;
    float _scaleValue;
   };
#endif /* defined(__Wall__MenuScene__) */

