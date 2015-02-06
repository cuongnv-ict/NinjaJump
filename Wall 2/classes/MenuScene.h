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
    bool isTag();
    CREATE_FUNC(MenuScene);
private:
    cocos2d::Sprite * _level_1;
    cocos2d::Sprite * _level_2;
    cocos2d::Sprite * _level_3;
    cocos2d::Sprite * _level_4;
    cocos2d::Sprite * _title;
    cocos2d::Sprite * _background;
    cocos2d::Sprite * _score_1;
    cocos2d::Sprite * _score_2;
    cocos2d::Sprite * _score_3;
    cocos2d::Sprite * _score_4;
    cocos2d::MenuItemImage * _leftTag;
    cocos2d::MenuItemImage * _rightTag;
    spine::SkeletonAnimation * _tag;
    float _height_level,_width_level;
    float _scaleValue;
    bool _isLevel,_isTag,_isRun;
   };
#endif /* defined(__Wall__MenuScene__) */

