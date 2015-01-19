#include "HelloWorldScene.h"
#include "MyDefine.h"
USING_NS_CC;
#define SCALE_RATIO 32.0
Scene* HelloWorld::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto layer = HelloWorld::create();
    // add layer as a child to scene
    scene->addChild(layer);

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool HelloWorld::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }
    this->setColor(cocos2d::Color3B(0,255,0));
    visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();
    
    /////////////////////////////
    // 2. add a menu item with "X" image, which is clicked to quit the program
    //    you may modify it.

    // add a "close" icon to exit the progress. it's an autorelease object
    //Hình nền
    floorRed = cocos2d::Sprite::create("Floor.png");
    floorRed->setAnchorPoint(cocos2d::Point(0,0));
    floorRed->runAction(FadeOut::create(0.0));
    floorRed->setScaleX(visibleSize.width / floorRed->getContentSize().width);
    floorRed->setScaleY(visibleSize.height / floorRed->getContentSize().height);
    this->addChild(floorRed, -1);
    
    floorBlue = cocos2d::Sprite::create("floorBlue.png");
    floorBlue->setAnchorPoint(cocos2d::Point(0,0));
    floorBlue->runAction(FadeOut::create(0.0));
    floorBlue->setScaleX(visibleSize.width / floorBlue->getContentSize().width);
    floorBlue->setScaleY(visibleSize.height / floorBlue->getContentSize().height);
    this->addChild(floorBlue, -1);
    
    floorGreen = cocos2d::Sprite::create("floorGreen.png");
    floorGreen->setAnchorPoint(cocos2d::Point(0,0));
    floorGreen->setScaleX(visibleSize.width / floorGreen->getContentSize().width);
    floorGreen->setScaleY(visibleSize.height / floorGreen->getContentSize().height);
    this->addChild(floorGreen, -1);
    /////////////////////////////
    /////////////////////////////
    // Add Wall
    {
        wallRight = Sprite::create("Wall.png");
        wallRight->setTag(2);
        wallRight->setScaleX(SIZE_WALL_WIDTH/wallRight->getContentSize().width);
        wallRight->setScaleY(getContentSize().height/wallRight->getContentSize().height);
        wallRight->setPosition(getContentSize().width - SIZE_WALL_WIDTH/2,getContentSize().height/2);
        this->addChild(wallRight, 0);
        wallLeft = Sprite::create("Wall.png");
        wallLeft->setTag(2);
        wallLeft->setScaleX(-SIZE_WALL_WIDTH/wallLeft->getContentSize().width);
        wallLeft->setScaleY(getContentSize().height/wallLeft->getContentSize().height);
        wallLeft->setPosition(Point(SIZE_WALL_WIDTH/2,getContentSize().height/2));
        this->addChild(wallLeft,0);
    }
    
    //Event Tag Scence
    {
        cocos2d::EventListenerTouchOneByOne * _listener = cocos2d::EventListenerTouchOneByOne::create();
        _listener->onTouchBegan = CC_CALLBACK_2(HelloWorld::onTouchBegan, this);
        _listener->onTouchEnded = CC_CALLBACK_2(HelloWorld::onTouchEnded, this);
        _eventDispatcher->addEventListenerWithSceneGraphPriority(_listener, this);
    }
    _upLevelWait = 0;
    _score = 0;
    _level = 3.5;
    _count_wait = 2;
    _isPlaying = false;
    existBall = false;
    _isFlying = false;
    _isDead = false;
    b2Vec2 gravity = b2Vec2(0.0f, -9.8f);
    world = new b2World(gravity);
    world->SetContactListener(this);
    addWall(SIZE_WALL_WIDTH ,visibleSize.height ,SIZE_WALL_WIDTH/2,visibleSize.height / 2 ); //Trái
    addWall(SIZE_WALL_WIDTH,visibleSize.height ,visibleSize.width - SIZE_WALL_WIDTH/2,visibleSize.height / 2);// Phải
    this->createGameScene();
    _obstacle = *new Vector<Node *>(3);
    schedule(schedule_selector(HelloWorld::update),0.01);
    //schedule(schedule_selector(HelloWorld::setObstacles), 0.8);
    return true;
}
void HelloWorld::createGameScene(){
    numType = 0;
    _obstacle.clear();
    startPoint = 0;
    jumpTimed = 1;
    ninja = SkeletonAnimation::createWithFile("skeleton.json", "skeleton.atlas", 0.175f);
    ninja->setAnimation(0, "Run on Wall", true);
    ninja->setTimeScale(1);
    shield = Sprite::create("circle.png");
    shield->setPosition(0,0.175 * 2 * SIZE_NINJA);
    shield->setScale(0.65);
    ninja->addChild(shield);
    
    explosion = Sprite::create("circle.png");
    explosion->setPosition(ninja->getPosition());
    explosion->setScale(0.1);
    explosion->runAction(FadeOut::create(0.0));
    this->addChild(explosion, 0);
    
    FiniteTimeAction* _shield = Sequence::create(ScaleTo::create(0.3, 0.85), ScaleTo::create(0.3, 0.65) ,NULL);
    auto _swing = RepeatForever::create( (ActionInterval*) _shield );
    shield->runAction(_swing);
    _isRunning = true;
    ninja->setPosition(0.175 * SIZE_NINJA + SIZE_WALL_WIDTH, NINJA_POSITION_Y);
    ninja->setTag(1);
    ninja->setScaleX(-1);
    this->addChild(ninja, 0);
    bodyShape.m_radius = (0.15 * SIZE_NINJA)/SCALE_RATIO;
    fixtureDef.density=100;
    fixtureDef.friction=0.8;
    fixtureDef.restitution=0.6;
    fixtureDef.shape=&bodyShape;
    bodyDef.type = b2_dynamicBody;
    bodyDef.userData = ninja;
    bodyDef.position.Set(ninja->getPosition().x/SCALE_RATIO, ninja->getPosition().y/SCALE_RATIO);
}
void HelloWorld::gameOver(){
    auto closeItem = MenuItemImage::create(
                                           "CloseNormal.png",
                                           "CloseSelected.png",
                                           CC_CALLBACK_1(HelloWorld::menuCloseCallback, this));
    
    closeItem->setPosition(Point(getContentSize().width - closeItem->getContentSize().width/2 - 10,closeItem->getContentSize().height/2 + 10));
    
    // create menu, it's an autorelease object
    auto menu = Menu::create(closeItem, NULL);
    menu->setPosition(Vec2::ZERO);
    this->addChild(menu, 1);
}
void HelloWorld::levelUp(){
    if (_level == 3.5) {
        floorGreen->runAction(FadeOut::create(1.0));
        floorBlue->runAction(FadeIn::create(1.0));
        _upLevelWait = 240;
        _level = 3.25;
    }
    
    else if (_level == 3.25) {
        floorBlue->runAction(FadeOut::create(1.0));
        floorRed->runAction(FadeIn::create(1.0));
        _upLevelWait = 240;
        _level = 3.0;
    }
    else if (_level == 3.0 && numType == 0) {
        numType = 2;
    }
}
void HelloWorld::update(float delta)
{
    if (_upLevelWait > 0) {
        _upLevelWait --;
    }
    if (_score>15&&_level==3.5) {
        this->levelUp();
    }
    if (_score>30&&_level==3.25) {
        this->levelUp();
    }
    if (_score>45&&_level==3.0 && numType == 0) {
        this->levelUp();
    }
    if(ninja->getPositionY()<= -100 && !_isDead){
        this->gameOver();
        _isDead = true;
    }
    if (_isPlaying) {
        int sizeObs = (int)_obstacle.size();
        if (_obstacle.at(sizeObs -1)->getPositionY() < visibleSize.height/2) {
            if (_upLevelWait == 0) {
                this->setObstacles();
            }
        }
        //CCLOG("%d", a);
        for (int i = startPoint; i<_obstacle.size(); i++) {
            if (_obstacle.at(i) != NULL) {
                if (_obstacle.at(i)->getPositionY()<=-200) {
                    startPoint += 1;
                }
                
                if (ninja->getBoundingBox().intersectsRect(_obstacle.at(i)->getBoundingBox())&&!_isDead) {
                    if (shield->isVisible()) {
                        if (_obstacle.at(i)->getTag() == OBSTACLES) {
                            _obstacle.at(i)->setTag(0);
                            //shield->setVisible(false);
                            _obstacle.at(i)->runAction(FadeOut::create(0.5));
                        }
                    }
                    if(_obstacle.at(i)->getTag() == OBSTACLES){
                        bodyDef.position.Set(ninja->getPosition().x/SCALE_RATIO, ninja->getPosition().y/SCALE_RATIO);
                        body = world->CreateBody(&bodyDef);
                        body->SetGravityScale(8);
                        body->CreateFixture(&fixtureDef);
                        body->SetLinearVelocity(b2Vec2(0, 0));
                        ninja->setAnimation(0, "die", false);
                        _isDead = true;
                        _isFlying = false;
                        this->gameOver();
                        CCLOG("aaa");
                    }
                    if(_obstacle.at(i)->getTag() == ITEM_ONE){
                        shield->setVisible(true);
                        _obstacle.at(i)->runAction(FadeOut::create(0.0));
                        _obstacle.at(i)->setTag(0);
                    }
                    if(_obstacle.at(i)->getTag() == ITEM_TWO){
                        //                    _obstacle.at(i)->setTag(0);
                        //                    explosion->runAction(FadeIn::create(0.5));
                        //                    explosion->runAction(ScaleTo::create(0.5, 5));
                    }
                    if (_obstacle.at(i)->getTag() == CLOUDS && _isFlying && !_isClouding) {
                        _obstacle.at(i)->runAction(Sequence::create(ScaleTo::create(0.1, 1.1), ScaleTo::create(0.1, 1.0), NULL));
                        jumpTimed = 0;
                        _isClouding = true;
                        world->DestroyBody(body);
                        bodyDef.position.Set(ninja->getPosition().x/SCALE_RATIO, ninja->getPosition().y/SCALE_RATIO);
                        body = world->CreateBody(&bodyDef);
                        body->SetGravityScale(8);
                        body->CreateFixture(&fixtureDef);
                        if(_isMovingLeft){
                            CCLOG("bbb");
                            if(ninja->getPositionX()<_obstacle.at(i)->getPositionX()){
                                if (ninja->getPositionY()>=_obstacle.at(i)->getPositionY()) {
                                    body->SetLinearVelocity(b2Vec2(-15, 25));
                                }
                                if (ninja->getPositionY()<_obstacle.at(i)->getPositionY()) {
                                    body->SetLinearVelocity(b2Vec2(-20, 5));
                                }
                                ninja->setScaleX(-1);
                                
                            }
                            if(ninja->getPositionX()>=_obstacle.at(i)->getPositionX()){
                                if (ninja->getPositionY()>=_obstacle.at(i)->getPositionY()) {
                                    body->SetLinearVelocity(b2Vec2(15, 25));
                                }
                                if (ninja->getPositionY()<_obstacle.at(i)->getPositionY()) {
                                    body->SetLinearVelocity(b2Vec2(20, 5));
                                }
                                ninja->setScaleX(1);
                            }
                        }
                        if (!_isMovingLeft) {
                            if(ninja->getPositionX()<_obstacle.at(i)->getPositionX()){
                                if (ninja->getPositionY()>=_obstacle.at(i)->getPositionY()) {
                                    body->SetLinearVelocity(b2Vec2(-15, 25));
                                }
                                if (ninja->getPositionY()<_obstacle.at(i)->getPositionY()) {
                                    body->SetLinearVelocity(b2Vec2(-20, 5));
                                }
                                ninja->setScaleX(-1);
                                
                            }
                            if(ninja->getPositionX()>=_obstacle.at(i)->getPositionX()){
                                if (ninja->getPositionY()>=_obstacle.at(i)->getPositionY()) {
                                    body->SetLinearVelocity(b2Vec2(15, 25));
                                }
                                if (ninja->getPositionY()<_obstacle.at(i)->getPositionY()) {
                                    body->SetLinearVelocity(b2Vec2(20, 5));
                                }
                                ninja->setScaleX(1);
                            }
                        }
                        
                    }
                }
            }
    }
    
    }
    int positionIterations = 10;
    int velocityIterations = 10;
    auto deltaTime = delta;
    explosion->setPosition(Point(ninja->getPositionX(), ninja->getPositionY() + 40 ));

    world->Step(deltaTime, velocityIterations, positionIterations);
    
    if (existBall) {
        if(ninja->getPositionX()>visibleSize.width/2){
            world->DestroyBody(body);
            ninja->setPositionX(visibleSize.width - (0.175 * SIZE_NINJA + SIZE_WALL_WIDTH));
            
        }
        if(ninja->getPositionX()<visibleSize.width/2){
            world->DestroyBody(body);
            ninja->setPositionX(0.175 * SIZE_NINJA + SIZE_WALL_WIDTH);
            
        }
        ninja->setBonesToSetupPose();
        ninja->setAnimation(0, "Run on Wall", true);
        _isRunning = true;
        existBall = false;
    }
    if (_isFlying||_isDead) {
        ninja->setPosition(body->GetPosition().x*SCALE_RATIO, body->GetPosition().y*SCALE_RATIO);
    }
    if(_isRunning&&ninja->getPositionY() >  NINJA_POSITION_Y){
        ninja->setPositionY(ninja->getPositionY() - 2);
    }
    if(_isRunning&&ninja->getPositionY() <  NINJA_POSITION_Y -2){
        ninja->setPositionY(ninja->getPositionY() + 2);
    }
    world->ClearForces();
    world->DrawDebugData();
}
void HelloWorld::addWall(float w, float h, float px, float py){
    b2PolygonShape floorShape;
    floorShape.SetAsBox(w/ SCALE_RATIO,h/ SCALE_RATIO);
    b2FixtureDef floorFixture;
    floorFixture.density=0;
    floorFixture.friction=10;
    floorFixture.restitution=0.5;
    floorFixture.shape=&floorShape;
    
    b2BodyDef floorBodyDef;
    floorBodyDef.position.Set(px/ SCALE_RATIO,py/ SCALE_RATIO);
    floorBodyDef.userData = wallRight;
    b2Body *floorBody = world->CreateBody(&floorBodyDef);
    floorBody->CreateFixture(&floorFixture);
}

float HelloWorld::radomValueBetween(float low,float height)
{
    return ((float)rand()/RAND_MAX) * (height - low) +low;
}
bool HelloWorld::onTouchBegan(cocos2d::Touch * touch, cocos2d::Event * event)
{
    if (!_isPlaying) {
        this->setObstacles();
        _isPlaying = true;
    }
    auto touchPos = touch->getLocation();
    if (jumpTimed == 0) {
        CCLOG("out of Jump");
        return true;
    }
    if (!_isDead && !_isClouding && jumpTimed == 1) {
        bodyDef.position.Set(ninja->getPosition().x/SCALE_RATIO, ninja->getPosition().y/SCALE_RATIO);
        if (!_isRunning&&jumpTimed==1) {
            if (_isMovingLeft) {
                world->DestroyBody(body);
                body = world->CreateBody(&bodyDef);
                body->SetGravityScale(12);
                body->CreateFixture(&fixtureDef);
                if (touchPos.x>=visibleSize.width/2) {
                    body->SetLinearVelocity(b2Vec2(20, 30));
                    ninja->setScaleX(1);
                }
                if (touchPos.x<visibleSize.width/2) {
                    body->SetLinearVelocity(b2Vec2(-20, 30));
                    ninja->setScaleX(-1);

                }
                jumpTimed = 0;
            }
            if (!_isMovingLeft) {
                world->DestroyBody(body);
                body = world->CreateBody(&bodyDef);
                body->SetGravityScale(12);
                body->CreateFixture(&fixtureDef);
                if (touchPos.x>=visibleSize.width/2) {
                    body->SetLinearVelocity(b2Vec2(20, 30));
                    ninja->setScaleX(1);
                }
                if (touchPos.x<visibleSize.width/2) {
                    body->SetLinearVelocity(b2Vec2(-20, 30));
                    ninja->setScaleX(-1);
                }
                jumpTimed = 0;
            }
        }
        if (_isRunning ) {
            body = world->CreateBody(&bodyDef);
            if (ninja->getPositionX()<visibleSize.width/2) {
                fixtureDef.density = 0;
                body->CreateFixture(&fixtureDef);
                body->SetGravityScale(12);
                body->SetLinearVelocity(b2Vec2(15, 35));
                ninja->setScaleX(1);
                ninja->setRotation(0);
                ninja->setAnimation(0, "Jump_Loop", true);
                _isMovingLeft = false;
            }
            if (ninja->getPositionX()>visibleSize.width/2) {
                fixtureDef.density = 0;
                body->CreateFixture(&fixtureDef);
                body->SetGravityScale(12);
                body->SetLinearVelocity(b2Vec2(-15, 35));
                ninja->setScaleX(-1);
                ninja->setRotation(0);
                ninja->setAnimation(0, "Jump_Loop", true);
                _isMovingLeft = true;
            }
            _isRunning = false;

        }
        _isFlying = true;
    }
    
    
    return true;
}
void HelloWorld::setObstacles()
{
    //addNinja();
    cocos2d::Sprite * bar_one = cocos2d::Sprite::create("Xa.png");
    cocos2d::Sprite * bar_two = cocos2d::Sprite::create("Xa.png");
    cocos2d::Sprite * thorns = cocos2d::Sprite::create("Chong.png");
    cocos2d::Sprite * thorns2 = cocos2d::Sprite::create("Chong.png");
    cocos2d::Sprite * cloud_one = cocos2d::Sprite::create("May.png");
    cocos2d::Sprite * cloud_two = cocos2d::Sprite::create("May.png");
    cocos2d::Sprite * item_one = cocos2d::Sprite::create("ball.jpg");
    cocos2d::Sprite * item_two = cocos2d::Sprite::create("Item.png");
    bar_one->setAnchorPoint(cocos2d::Point(0,0));
    bar_two->setAnchorPoint(cocos2d::Point(0,0));
    item_one->setScale(0.65);
    bar_one->setTag(OBSTACLES);
    bar_two->setTag(OBSTACLES);
    thorns->setTag(OBSTACLES);
    thorns2->setTag(OBSTACLES);
    cloud_one->setTag(CLOUDS);
    cloud_two->setTag(CLOUDS);
    item_one->setTag(ITEM_ONE);
    item_two->setTag(ITEM_TWO);
    unsigned int type = arc4random() % 10 + numType;
    type = 10;
    switch (type) {
        case 4:
            setPositionBarRight(bar_one);
            cloud_one->setPosition(Point(visibleSize.width*4/7,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(cloud_one,0);
            cloud_one->runAction(MoveTo::create(_level*(cloud_one->getPositionY()/visibleSize.height), Point(cloud_one->getPositionX(), -200)));
            thorns->setPosition(Point(thorns->getContentSize().width/2 + SIZE_WALL_WIDTH,_count_wait * visibleSize.height- visibleSize.height/2 - visibleSize.height/3));
            this->addChild(thorns,0);
            thorns->runAction(MoveTo::create(_level*(thorns->getPositionY()/visibleSize.height), Point(thorns->getPositionX(), -200)));
            if(arc4random()%100 > 75)
            {
                if(arc4random()%100 >= 80)
                {
                    item_two->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_two->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height));
                    this->addChild(item_two,0);
                    _obstacle.pushBack(item_two);
                    item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                }
                else
                {
                    item_one->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_one->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height));
                    this->addChild(item_one,0);
                    _obstacle.pushBack(item_one);
                    item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                }
            }
            _obstacle.pushBack(cloud_one);
            _obstacle.pushBack(thorns);
            _obstacle.pushBack(bar_one);
            break;
        case 5:
            setPositionBarLeft(bar_one);
            cloud_one->setPosition(cocos2d::Point(visibleSize.width*3/7 ,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(cloud_one,0);
            cloud_one->runAction(MoveTo::create(_level*(cloud_one->getPositionY()/visibleSize.height), Point(cloud_one->getPositionX(), -200)));
            thorns->setRotation(180);
            thorns->setPosition(cocos2d::Point(getContentSize().width - SIZE_WALL_WIDTH - thorns->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(thorns,0);
            thorns->runAction(MoveTo::create(_level*(thorns->getPositionY()/visibleSize.height), Point(thorns->getPositionX(), -200)));
            if(arc4random()%100 > 75)
            {
                if(arc4random()%100 >= 80)
                {
                    item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height));
                    this->addChild(item_two,0);
                    _obstacle.pushBack(item_two);
                    item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                }
                else
                {
                    item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height));
                    this->addChild(item_one,0);
                    _obstacle.pushBack(item_one);
                    item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                }
            }
            _obstacle.pushBack(cloud_one);
            _obstacle.pushBack(thorns);
            _obstacle.pushBack(bar_one);
            break;
        case 2:
            setPositionBarRight(bar_one);
            thorns->setRotation(180);
            thorns->setPosition(cocos2d::Point(getContentSize().width - SIZE_WALL_WIDTH - thorns->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            thorns->runAction(MoveTo::create(_level*(thorns->getPositionY()/visibleSize.height), Point(thorns->getPositionX(), -200)));
            this->addChild(thorns,0);
            if(arc4random()%100 > 75)
            {
                if(arc4random()%2 == 0)
                {
                    if(arc4random()%100 >= 80)
                    {
                        item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                        _obstacle.pushBack(item_two);
                        this->addChild(item_two,0);
                    }
                    else
                    {
                        item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                        _obstacle.pushBack(item_one);
                        this->addChild(item_one,0);
                    }
                }
                else
                {
                    if(arc4random()%100 >= 80)
                    {
                        item_two->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                        _obstacle.pushBack(item_two);
                        this->addChild(item_two,0);
                    }
                    else
                    {
                        item_one->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_one->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
                        item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                        _obstacle.pushBack(item_one);
                        this->addChild(item_one,0);
                    }
                    
                }
            }
            _obstacle.pushBack(thorns);
            _obstacle.pushBack(bar_one);
            break;
        case 3:
            setPositionBarLeft(bar_one);
            thorns->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + thorns->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            thorns->runAction(MoveTo::create(_level*(thorns->getPositionY()/visibleSize.height), Point(thorns->getPositionX(), -200)));
            this->addChild(thorns,0);
            if(arc4random()%100 > 75)
            {
                if(arc4random()%2 == 0)
                {
                    if(arc4random()%100 >= 80)
                    {
                        item_two->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_two->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                        _obstacle.pushBack(item_two);
                        this->addChild(item_two,0);
                    }
                    else
                    {
                        item_one->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_one->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                        _obstacle.pushBack(item_one);
                        this->addChild(item_one,0);
                    }
                }
                else
                {
                    if(arc4random()%100 >= 80)
                    {
                        item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
                        item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                        _obstacle.pushBack(item_two);
                        this->addChild(item_two,0);
                    }
                    else
                    {
                        item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
                        item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                        _obstacle.pushBack(item_one);
                        this->addChild(item_one,0);
                    }

                }
            }
            _obstacle.pushBack(thorns);
            _obstacle.pushBack(bar_one);
            break;
        case 0:
            setPositionBarRight(bar_one);
            if(arc4random()%100 > 75)
            {
                if(arc4random()%2 == 0)
                {
                    if(arc4random()%100 >= 80)
                    {
                        item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                        _obstacle.pushBack(item_two);
                        this->addChild(item_two,0);
                    }
                    else
                    {
                        item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width * item_one->getScale() - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                        _obstacle.pushBack(item_one);
                        this->addChild(item_one,0);
                    }
                }
                else
                {
                    if(arc4random()%100 >= 80)
                    {
                        item_two->setPosition(cocos2d::Point(SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
                        item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                        _obstacle.pushBack(item_two);
                        this->addChild(item_two,0);
                    }
                    else
                    {
                        item_one->setPosition(cocos2d::Point(SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
                        item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                        _obstacle.pushBack(item_one);
                        this->addChild(item_one,0);
                    }
                    
                }
            }
            _obstacle.pushBack(bar_one);

            break;
        case 1:
            setPositionBarLeft(bar_one);
            if(arc4random()%100 > 75)
            {
                if(arc4random()%2 == 0)
                {
                    if(arc4random()%100 >= 80)
                    {
                        item_two->setPosition(cocos2d::Point(SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                        _obstacle.pushBack(item_two);
                        this->addChild(item_two,0);
                    }
                    else
                    {
                        item_one->setPosition(cocos2d::Point(SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns->getContentSize().height));
                        item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                        _obstacle.pushBack(item_one);
                        this->addChild(item_one,0);
                    }
                }
                else
                {
                    if(arc4random()%100 >= 80)
                    {
                        item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
                        item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                        _obstacle.pushBack(item_two);
                        this->addChild(item_two,0);
                        
                    }
                    else
                    {
                        item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width * item_one->getScale() - SIZE_WALL_WIDTH,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
                        item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                        _obstacle.pushBack(item_one);
                        this->addChild(item_one,0);
                        
                    }
                    
                }
            }
            _obstacle.pushBack(bar_one);
            break;
        case 6:
            setPositionBarLeft(bar_one);
            cloud_one->setPosition(cocos2d::Point(visibleSize.width*3/7,
                                                  _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            cloud_one->runAction(MoveTo::create(_level*(cloud_one->getPositionY()/visibleSize.height), Point(cloud_one->getPositionX(), -200)));
            this->addChild(cloud_one,0);
            if(arc4random()%100 > 75)
            {
                if(arc4random()%100 >= 80)
                {
                    item_two->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_two->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - thorns->getContentSize().height));
                    item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                    _obstacle.pushBack(item_two);
                    this->addChild(item_two,0);
                }
                else
                {
                    item_one->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_one->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - thorns->getContentSize().height));
                    item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                    _obstacle.pushBack(item_one);
                    this->addChild(item_one,0);
                }
            }
            _obstacle.pushBack(cloud_one);
            _obstacle.pushBack(bar_one);
            break;
        case 7:
            setPositionBarRight(bar_one);
            cloud_one->setPosition(cocos2d::Point(visibleSize.width*4/7,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            cloud_one->runAction(MoveTo::create(_level*(cloud_one->getPositionY()/visibleSize.height), Point(cloud_one->getPositionX(), -200)));
            this->addChild(cloud_one,0);
            if(arc4random()%100 > 75)
            {
                if(arc4random()%100 >= 80)
                {
                    item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2 - thorns->getContentSize().height));
                    _obstacle.pushBack(item_two);
                    item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                    this->addChild(item_two,0);
                }
                else
                {
                    item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width/2 * item_one->getScale() - SIZE_WALL_WIDTH,_count_wait * visibleSize.height - visibleSize.height/2 - thorns->getContentSize().height));
                    item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                    _obstacle.pushBack(item_one);
                    this->addChild(item_one,0);
                }
            }
            _obstacle.pushBack(cloud_one);
            _obstacle.pushBack(bar_one);
            break;
        case 8:
            setPositionBarLeft(bar_one);
            cloud_one->setPosition(Point(visibleSize.width*3/7,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(cloud_one,0);
            cloud_one->runAction(MoveTo::create(_level*(cloud_one->getPositionY()/visibleSize.height), Point(cloud_one->getPositionX(), -200)));
            thorns->setPosition(Point(SIZE_WALL_WIDTH  + thorns->getContentSize().width/2,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(thorns,0);
            thorns->runAction(MoveTo::create(_level*(thorns->getPositionY()/visibleSize.height), Point(thorns->getPositionX(), -200)));
            if(arc4random()%100 > 75)
            {
                if(arc4random()%100 >= 80)
                {
                    item_two->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_two->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2));
                    this->addChild(item_two,0);
                    _obstacle.pushBack(item_two);
                    item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                }
                else
                {
                    item_one->setPosition(cocos2d::Point(SIZE_WALL_WIDTH + item_one->getContentSize().width/2,_count_wait * visibleSize.height - visibleSize.height/2));
                    this->addChild(item_one, 0);
                    _obstacle.pushBack(item_one);
                    item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                }
            }
            _obstacle.pushBack(cloud_one);
            _obstacle.pushBack(thorns);
            _obstacle.pushBack(bar_one);
            break;
        case 9:
            setPositionBarRight(bar_one);
            cloud_one->setPosition(cocos2d::Point(getContentSize().width*3/7,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(cloud_one,0);
            cloud_one->runAction(MoveTo::create(_level*(cloud_one->getPositionY()/visibleSize.height), Point(cloud_one->getPositionX(), -200)));
            thorns->setRotation(180);
            thorns->setPosition(cocos2d::Point(getContentSize().width - SIZE_WALL_WIDTH - + thorns->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(thorns,0);
            thorns->runAction(MoveTo::create(_level*(thorns->getPositionY()/visibleSize.height), Point(thorns->getPositionX(), -200)));
            if(arc4random()%100 > 75)
            {
                if(arc4random()%100 >= 80)
                {
                    item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2));
                    this->addChild(item_two,0);
                    _obstacle.pushBack(item_two);
                    item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                }
                else
                {
                    item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width/2 - SIZE_WALL_WIDTH,_count_wait * visibleSize.height - visibleSize.height/2));
                    this->addChild(item_one,0);
                    _obstacle.pushBack(item_one);
                    item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                }
            }
            _obstacle.pushBack(cloud_one);
            _obstacle.pushBack(thorns);
            _obstacle.pushBack(bar_one);
            break;
        case 10:
            setPositionBarRight(bar_one);
            bar_one->setPositionX(bar_one->getPositionX() + bar_one->getContentSize().width/3);
            cloud_one->setPosition(cocos2d::Point(getContentSize().width/2,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(cloud_one,0);
            cloud_one->runAction(MoveTo::create(_level*(cloud_one->getPositionY()/visibleSize.height), Point(cloud_one->getPositionX(), -200)));
            thorns->setRotation(180);
            thorns->setPosition(cocos2d::Point(getContentSize().width - SIZE_WALL_WIDTH - + thorns->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(thorns,0);
            thorns->runAction(MoveTo::create(_level*(thorns->getPositionY()/visibleSize.height), Point(thorns->getPositionX(), -200)));
            thorns2->setPosition(Point(SIZE_WALL_WIDTH  + thorns2->getContentSize().width/2,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(thorns2,0);
            thorns2->runAction(MoveTo::create(_level*(thorns2->getPositionY()/visibleSize.height), Point(thorns2->getPositionX(), -200)));
            if(arc4random()%100 > 75)
            {
                if(arc4random()%100 >= 80)
                {
                    item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2));
                    this->addChild(item_two,0);
                    _obstacle.pushBack(item_two);
                    item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                }
                else
                {
                    item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width/2 - SIZE_WALL_WIDTH,_count_wait * visibleSize.height - visibleSize.height/2));
                    this->addChild(item_one,0);
                    _obstacle.pushBack(item_one);
                    item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                }
            }
            _obstacle.pushBack(cloud_one);
            _obstacle.pushBack(thorns);
            _obstacle.pushBack(thorns2);
            _obstacle.pushBack(bar_one);
            break;
        case 11:
            setPositionBarRight(bar_one);
            cloud_one->setPosition(cocos2d::Point(getContentSize().width*3/7,_count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3));
            this->addChild(cloud_one,0);
            cloud_one->runAction(MoveTo::create(_level*(cloud_one->getPositionY()/visibleSize.height), Point(cloud_one->getPositionX(), -200)));
            thorns->setRotation(180);
            thorns->setPosition(cocos2d::Point(getContentSize().width - SIZE_WALL_WIDTH - + thorns->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 - thorns->getContentSize().height));
            this->addChild(thorns,0);
            thorns->runAction(MoveTo::create(_level*(thorns->getPositionY()/visibleSize.height), Point(thorns->getPositionX(), -200)));
            thorns2->setRotation(180);
            thorns2->setPosition(cocos2d::Point(getContentSize().width - SIZE_WALL_WIDTH - + thorns2->getContentSize().width/2, _count_wait * visibleSize.height - visibleSize.height/2 - visibleSize.height/3 + thorns2->getContentSize().height));
            this->addChild(thorns2,0);
            thorns2->runAction(MoveTo::create(_level*(thorns2->getPositionY()/visibleSize.height), Point(thorns2->getPositionX(), -200)));
            if(arc4random()%100 > 75)
            {
                if(arc4random()%100 >= 80)
                {
                    item_two->setPosition(cocos2d::Point(getContentSize().width - item_two->getContentSize().width/2 - SIZE_WALL_WIDTH, _count_wait * visibleSize.height - visibleSize.height/2));
                    this->addChild(item_two,0);
                    _obstacle.pushBack(item_two);
                    item_two->runAction(MoveTo::create(_level*(item_two->getPositionY()/visibleSize.height), Point(item_two->getPositionX(), -200)));
                }
                else
                {
                    item_one->setPosition(cocos2d::Point(getContentSize().width - item_one->getContentSize().width/2 - SIZE_WALL_WIDTH,_count_wait * visibleSize.height - visibleSize.height/2));
                    this->addChild(item_one,0);
                    _obstacle.pushBack(item_one);
                    item_one->runAction(MoveTo::create(_level*(item_one->getPositionY()/visibleSize.height), Point(item_one->getPositionX(), -200)));
                }
            }
            _obstacle.pushBack(cloud_one);
            _obstacle.pushBack(thorns);
            _obstacle.pushBack(thorns2);
            _obstacle.pushBack(bar_one);
            break;
        default:
            
            break;
    }
}
void HelloWorld::setPositionBarLeft(cocos2d::Sprite * bar)
{
    bar->setScaleX((getContentSize().width - 2 * SIZE_WALL_WIDTH - SIZE_SPACE)/bar->getContentSize().width);
    bar->setScaleY(SIZE_BAR_HEIGHT / bar->getContentSize().height);
    bar->setPosition(cocos2d::Point(SIZE_SPACE+SIZE_WALL_WIDTH,
                                    _count_wait *visibleSize.height - visibleSize.height/2));
    float a = (bar->getPositionY())/visibleSize.height;
    bar->runAction(MoveTo::create(_level*a, Point(bar->getPositionX(), -200)));
    this->addChild(bar,0);
}
void HelloWorld::setPositionBarRight(cocos2d::Sprite * bar)
{
    bar->setScaleX((getContentSize().width - 2 * SIZE_WALL_WIDTH - SIZE_SPACE)/bar->getContentSize().width);
    bar->setScaleY(SIZE_BAR_HEIGHT / bar->getContentSize().height);
    bar->setPosition(Point(SIZE_WALL_WIDTH, _count_wait *visibleSize.height - visibleSize.height/2));
    float a = (bar->getPositionY())/visibleSize.height;
    bar->runAction(MoveTo::create(_level*a, Point(bar->getPositionX(), -200)));
    this->addChild(bar,0);
}

void HelloWorld::onTouchEnded(cocos2d::Touch * touch, cocos2d::Event * event)
{

}
void HelloWorld::BeginContact(b2Contact *contact){
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    b2Body* body1 = fixtureA->GetBody();
    b2Body* body2 = fixtureB->GetBody();
    auto a = (Sprite*)body2->GetUserData();
    auto b = (Sprite*)body1->GetUserData();
    if (a->getTag()&&b->getTag()) {
        if (((a->getTag() == 1 && b->getTag() == 2) || (a->getTag() == 2 && b->getTag() == 1))&&_isFlying) {
            if (ninja->getPositionX()>visibleSize.width/2&&body->GetLinearVelocity().x>0) {
                existBall = true;
                _isFlying = false;
                _isClouding = false;
                jumpTimed = 1;

            }
            if (ninja->getPositionX()<visibleSize.width/2&&body->GetLinearVelocity().x<0) {
                existBall = true;
                _isFlying = false;
                _isClouding = false;
                jumpTimed = 1;

            }
            _score ++;
        }
    }
}
void HelloWorld::EndContact(b2Contact *contact){
    
}
void HelloWorld::addNinja()
{
    SkeletonAnimation * vs_ninja = SkeletonAnimation::createWithFile("skeleton.json", "skeleton.atlas", 0.175);
    vs_ninja->setAnimation(0, "Run on Wall", true);
    vs_ninja->setTag(OBSTACLES);
    _obstacle.pushBack(vs_ninja);
    this->addChild(vs_ninja);
    auto delete_ninja = CallFunc::create([=]{
        this->removeChild(vs_ninja,true);
    });
    if(arc4random()%2 == 0)
    {
        vs_ninja->setScaleX(-1);
        vs_ninja->setPosition(Point(SIZE_WALL_WIDTH + 0.175 * SIZE_NINJA, getContentSize().height));
    }
    else
    {
        vs_ninja->setPosition(Point(getContentSize().width - SIZE_WALL_WIDTH - 0.175 * SIZE_NINJA, getContentSize().height));
    }
    vs_ninja->runAction(Sequence::create(cocos2d::MoveBy::create(5.0, cocos2d::Point(0,-getContentSize().height - SIZE_NINJA * 3)),delete_ninja, NULL));
}
void HelloWorld::menuCloseCallback(Ref* pSender)
{
    Director::getInstance()->replaceScene(TransitionZoomFlipX::create(0.5, HelloWorld::createScene()));
}
