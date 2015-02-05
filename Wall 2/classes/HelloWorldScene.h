#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#include "Box2D/Box2D.h"
#include "spine/spine-cocos2dx.h"
#include "MenuScene.h"
USING_NS_CC;
using namespace spine;
using namespace std;
class HelloWorld : public cocos2d::Layer, public b2ContactListener
{
public:
    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* createScene();

    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool init();  
    
    // a selector callback
    void menuCloseCallback(cocos2d::Ref* pSender);
    void update(float delta);
    float radomValueBetween(float low,float height);
    bool onTouchBegan(cocos2d::Touch * touch,cocos2d::Event * event);
    void onTouchEnded(cocos2d::Touch * touch,cocos2d::Event * event);
    void setObstacles();
    void setPositionBarLeft(cocos2d::Sprite * bar);
    void setPositionBarRight(cocos2d::Sprite * bar);
    void setPositionBarMidle(cocos2d::Sprite * bar_one,cocos2d::Sprite * bar_two);
    void createGameScene();
    void gameOver();
    void levelUp();
    void addWall(float w, float h, float px, float py);
    void addNinja();
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    // implement the "static create()" method manually
    CREATE_FUNC(HelloWorld);
private :
    MenuScene * _menu;
    cocos2d::Sprite * _ball;
    cocos2d::Sprite * _ninja;
    cocos2d::Action * _actionRun;
    float distance;
    float gravityScale;
    float deathPoint;
    float move;
    float _level;
    float _weight;
    float _height;
    float _scaleWidth;
    float _scaleHeight;
    int numType;
    int _score;
    int _upLevelWait;
    int _count_wait;
    int startPoint;
    bool existBall;
    bool _isMovingLeft, _isFlying, _isRunning, _isDead, _isToMuch, _isClouding, _isPlaying;
    int jumpTimed;

    Sprite *strength;
    Sprite *floorRed;
    Sprite *floorGreen;
    Sprite *floorBlue;
    Sprite *wallRight;
    Sprite * wallLeft;
    Sprite *shield;
    Sprite *explosion;
    Size visibleSize;
    LabelTTF *scoreLabel;
    b2World *world;
    b2Body *body;
    b2BodyDef bodyDef;
    b2FixtureDef fixtureDef;
    b2CircleShape bodyShape;
    SkeletonAnimation *ninja;
    cocos2d::Vector<cocos2d::Node *> _obstacle;

};

#endif // __HELLOWORLD_SCENE_H__
