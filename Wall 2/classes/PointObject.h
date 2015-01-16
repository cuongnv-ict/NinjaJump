//
//  PointObject.h
//  Wall
//
//  Created by Nguyen Van Cuong on 12/3/14.
//
//

#ifndef __Wall__PointObject__
#define __Wall__PointObject__

#include <iostream>
#include "cocos2d.h"

class PointObject : public cocos2d::Ref
{
public:
    inline void setRation(cocos2d::Point ration){_ration = ration;}
    inline void setOffset(cocos2d::Point offset){_offset = offset;}
    inline void setChild(cocos2d::Node * child){_child = child;}
    inline cocos2d::Point getOffset() const {return _offset;}
    inline cocos2d::Node * getChild() const {return _child;}
private:
    cocos2d::Point _ration;
    cocos2d::Point _offset;
    cocos2d::Node * _child;
};

#endif /* defined(__Wall__PointObject__) */
