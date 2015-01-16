//
//  MyParallax.h
//  Wall
//
//  Created by Nguyen Van Cuong on 12/3/14.
//
//

#ifndef __Wall__MyParallax__
#define __Wall__MyParallax__

#include <iostream>
#include "cocos2d.h"

class MyParallax : public cocos2d::ParallaxNode
{
public:
    static MyParallax* create();
    void updatePosition();
    inline void setOffsetHeight(float offset_height){ _offset_height = offset_height;}
    inline void setNumberWall(int number_wall){ _number_wall = number_wall;}
private:
    float _offset_height;
    int _number_wall;
};

#endif /* defined(__Wall__MyParallax__) */
