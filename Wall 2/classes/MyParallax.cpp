//
//  MyParallax.cpp
//  Wall
//
//  Created by Nguyen Van Cuong on 12/3/14.
//
//

#include "MyParallax.h"
#include "PointObject.h"
#include "MyDefine.h"

MyParallax * MyParallax::create()
{
    MyParallax * node = new MyParallax();
    if(node)
    {
        node->autorelease();
    }
    else
    {
        delete node;
        node = NULL;
    }
    return node;
}
void MyParallax::updatePosition()
{
    for(int i =0; i < _children.size();i++)
    {
        Node * node = _children.at(i);
        if(convertToWorldSpace(node->getPosition()).y <= (-_offset_height))
        {
            for(int j=0;j<_parallaxArray->num;j++)
            {
                PointObject * pObject = (PointObject * )_parallaxArray->arr[j];
                if(pObject->getChild()== node)
                {
                    pObject->setOffset(pObject->getOffset() +
                                       cocos2d::Point(0,_number_wall * _offset_height));
                    if(node->getTag() == OBSTACLES || node->getTag() == DARTS)
                    {
                        removeChild(node, true);
                    }
                    break;
                }
            }
        }
    }
}