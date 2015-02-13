/****************************************************************************
 Copyright (c) 2010 cocos2d-x.org
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/


#import "AppController.h"
#import "CCEAGLView.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "MPMediationAdController.h"
#include "deprecated/CCNotificationCenter.h"
#import "VDConfigNotification.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AudioToolbox/AudioToolbox.h>
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "iRate.h"
#import "Definitions.h"


NSString* g_leaderBoardName = [NSString stringWithFormat:@"com.catviet.coolninja.leaderboard"];
//NSString* g_leaderBoardName = [NSString stringWithFormat:@"com.vietlotus.linesplus.leaderboard"];
AppController * g_AppCtrl = nil;
BOOL g_bShowFullscreen = FALSE;
BOOL g_bShowAdsBaner = TRUE;
BOOL g_bShowAlertBonus = FALSE;
class AdsSupporter : public cocos2d::Ref
{
public:
    void myNotification(cocos2d::Ref* obj);
    ~AdsSupporter();
    
    void updateDayByDay(cocos2d::Ref *obj);
    void updateDayByDay();
    void clickDoneADV();
    void watchinhADV();
    void vibrateIphone(cocos2d::Ref* obj);
    void showGameCenterHighscore(cocos2d::Ref *obj);
    void hideAdsBanner(cocos2d::Ref *obj);
    void showAdsBanner(cocos2d::Ref *obj);
    void updateScore(cocos2d::Ref *obj);
    void getHint(cocos2d::Ref *obj);
    void showAdsRate(cocos2d::Ref *obj);
    void forceshowAdsFullscreen(cocos2d::Ref *obj);
};

void AdsSupporter::updateDayByDay(cocos2d::Ref *obj){
    NSDate *now = [NSDate date];
    
    NSLog(@"now: %@", now); // now: 2011-02-28 09:57:49 +0000
    
    NSString *strDate = [[NSString alloc] initWithFormat:@"%@",now];
    NSArray *arr = [strDate componentsSeparatedByString:@" "];
    NSString *str;
    str = [arr objectAtIndex:0];
    NSLog(@"strdate: %@",str); // strdate: 2011-02-28
    
    NSArray *arr_my = [str componentsSeparatedByString:@"-"];
    
    NSInteger date = [[arr_my objectAtIndex:2] intValue];
    NSInteger month = [[arr_my objectAtIndex:1] intValue];
    NSInteger year = [[arr_my objectAtIndex:0] intValue];
    cocos2d::UserDefault *def = cocos2d::UserDefault::getInstance();
    int dateOld = def->getIntegerForKey(DAY, NUMBER_DAY_DEFAULT);
    def->flush();
    int monthOld = def->getIntegerForKey(MONTH, NUMBER_MONTH_DEFAULT);
    def->flush();
    int yearOld = def->getIntegerForKey(YEAR, NUMBER_YEAR_DEFAULT);
    def->flush();
    if (year>yearOld) {
        def->setIntegerForKey(YEAR, (int)year);
        def->flush();
        def->setIntegerForKey(MONTH, (int)month);
        def->flush();
        def->setIntegerForKey(DAY, (int)date);
        def->flush();
        def->setIntegerForKey(KEY_NUMBER_SHARE_ONE_DAY, 0);
        def->flush();
        cocos2d::MessageBox("You've just got 1 hint!","Daily hint bonus" );
    }
    else if (month>monthOld) {
        def->setIntegerForKey(MONTH, (int)month);
        def->flush();
        def->setIntegerForKey(DAY, (int)date);
        def->flush();
        def->setIntegerForKey(KEY_NUMBER_SHARE_ONE_DAY, 0);
        def->flush();
        cocos2d::MessageBox("You've just got 1 hint!","Daily hint bonus");
    }
    else if (date>dateOld) {
        def->setIntegerForKey(DAY, (int)date);
        def->flush();
        def->setIntegerForKey(KEY_NUMBER_SHARE_ONE_DAY, 0);
        def->flush();
        cocos2d::MessageBox("You've just got 1 hint!","Daily hint bonus");
    }
    
    [strDate release];
}

void AdsSupporter::updateDayByDay(){
    NSLog("LDKSJALSDFJLSKDFJLAKSDJFLSKDJFALS");
    
    NSDate *now = [NSDate date];
    
    NSLog(@"now: %@", now); // now: 2011-02-28 09:57:49 +0000
    
    NSString *strDate = [[NSString alloc] initWithFormat:@"%@",now];
    NSArray *arr = [strDate componentsSeparatedByString:@" "];
    NSString *str;
    str = [arr objectAtIndex:0];
    NSLog(@"strdate: %@",str); // strdate: 2011-02-28
    
    NSArray *arr_my = [str componentsSeparatedByString:@"-"];
    
    NSInteger date = [[arr_my objectAtIndex:2] intValue];
    NSInteger month = [[arr_my objectAtIndex:1] intValue];
    NSInteger year = [[arr_my objectAtIndex:0] intValue];
    cocos2d::UserDefault *def = cocos2d::UserDefault::getInstance();
    int dateOld = def->getIntegerForKey(DAY, NUMBER_DAY_DEFAULT);
    def->flush();
    int monthOld = def->getIntegerForKey(MONTH, NUMBER_MONTH_DEFAULT);
    def->flush();
    int yearOld = def->getIntegerForKey(YEAR, NUMBER_YEAR_DEFAULT);
    def->flush();
    if (year>yearOld) {
        def->setIntegerForKey(YEAR, (int)year);
        def->flush();
        def->setIntegerForKey(MONTH, (int)month);
        def->flush();
        def->setIntegerForKey(DAY, (int)date);
        def->flush();
        def->setIntegerForKey(KEY_NUMBER_SHARE_ONE_DAY, 0);
        def->flush();
        cocos2d::MessageBox("You've just got 1 hint!","Daily hint bonus" );
    }
    else if (month>monthOld) {
        def->setIntegerForKey(MONTH, (int)month);
        def->flush();
        def->setIntegerForKey(DAY, (int)date);
        def->flush();
        def->setIntegerForKey(KEY_NUMBER_SHARE_ONE_DAY, 0);
        def->flush();
        cocos2d::MessageBox("You've just got 1 hint!","Daily hint bonus");
    }
    else if (date>dateOld) {
        def->setIntegerForKey(DAY, (int)date);
        def->flush();
        def->setIntegerForKey(KEY_NUMBER_SHARE_ONE_DAY, 0);
        def->flush();
        cocos2d::MessageBox("You've just got 1 hint!","Daily hint bonus");
    }
    
    [strDate release];
}

void AdsSupporter::getHint(cocos2d::Ref *obj){
    [g_AppCtrl showAlertViewHint];
}

// Handle the notification
void AdsSupporter::myNotification(cocos2d::Ref* obj)
{
    
    //Uu tien bat Rate truoc
    cocos2d::UserDefault *def2 = cocos2d::UserDefault::getInstance();
    auto number_died = def2->getIntegerForKey(DIED, NUMBER_DIED);
    def2->flush();
    if (number_died ==3) {
        [g_AppCtrl showRateApp];
        def2->setIntegerForKey(DIED, 0);
        def2->flush();
    }
    else
    {
        [[MPMediationAdController sharedManager] logEventToShowFullscreenAd];
    }
}

void AdsSupporter::updateScore(cocos2d::Ref *obj){
    //    cocos2d::UserDefault *defau = cocos2d::UserDefault::getInstance();
    //    int score = defau->getIntegerForKey(SCORE, 0);
    //    defau->flush();
    //    int best = defau->getIntegerForKey(HIGH_SCORE, 0);
    //    defau->flush();
    //    if (score>best) {
    [g_AppCtrl submitHighScoreToGameCenter:0];
    //    }
}

void AdsSupporter::clickDoneADV()
{
    //Khi click vao quang cao hien full man hinh
    [g_AppCtrl showAlertBonusPoint];
}

void AdsSupporter::vibrateIphone(cocos2d::Ref *obj){
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

void AdsSupporter::showGameCenterHighscore(cocos2d::Ref *obj)
{
    [g_AppCtrl showLeaderBoard];
}

void AdsSupporter::hideAdsBanner(cocos2d::Ref *obj){
    [g_AppCtrl setShowHideAdv:NO];
}
void AdsSupporter::showAdsBanner(cocos2d::Ref *obj) {
    
    if(g_bShowFullscreen == NO)
        [g_AppCtrl setShowHideAdv:YES];
}
void AdsSupporter::watchinhADV(){
    //Khi xem video
    
}

void AdsSupporter::showAdsRate(cocos2d::Ref *obj) {
    [g_AppCtrl showRateApp];
}
void AdsSupporter::forceshowAdsFullscreen(cocos2d::Ref *obj) {
    
    [g_AppCtrl showAlertViewHint];
    //[[MPMediationAdController sharedManager] forceFullscreenAdToBeShow];
}
AdsSupporter::~AdsSupporter()
{
    cocos2d::NotificationCenter::getInstance()->removeObserver(this, "");
}


@interface AppController ()<VDConfigNotificationDelegate,GameCenterManagerDelegate,GKLeaderboardViewControllerDelegate>
{
    GameCenterManager *m_pGameCenterManager;
    AdsSupporter* m_pAdsSupporter;
    
    UIAlertView *m_pAlertView;
    
}
//@property (nonatomic, retain)
@end

@implementation AppController


+ (void) initialize
{
    iRate *pIRate = [iRate sharedInstance];
    // pIRate.delegate = self;
    pIRate.applicationBundleID = [NSString stringWithFormat:@"%@",[VDConfigNotification getBundleID]];
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 0; /* Số ngày kể từ khi cài app tới khi ứng dụng bung alertView để người dùng rate ứng dụng. */
    
    
    [iRate sharedInstance].usesUntilPrompt = 1; /* Số lần tối thiểu sử dụng trước khi ứng dụng bung alertView để người dùng rate ứng dụng */
    
    [iRate sharedInstance].eventsUntilPrompt = 3 ; /* Thuộc tính eventsUntilPrompt sẽ chờ N sự kiện xảy ra mới bung alertView. */
    
    [iRate sharedInstance].remindPeriod = 0.5;
    
    pIRate.promptAgainForEachNewVersion = YES; /* Gán thuộc tính = YES khi muốn người dùng Rate lại mỗi khi có phiên bản mới trên Store */
    pIRate.onlyPromptIfLatestVersion = YES; /*  Default là YES bởi người dùng sẽ không bị rate và comment  sai về các lỗi mà phiên bản cũ gặp phải nhưng đã sửa trên phiên bản mới. */
    pIRate.promptAtLaunch = YES;     /* Set thuộc tính bằng NO để disable alertView rating được bật tự động khi chương trình khởi động hoặc trở về từ background. */
    //pIRate.turnonRepeatMode = YES;  /* Set thuộc tính này bằng YES trong trường hợp muốn iRate có thể bật lại khi người dùng chưa rate và đã chọn "Not now", trường hợp mặc định : NO, iRate sẽ chỉ bật lên 1 lần */
    
    pIRate.messageTitle = @"Like this App?";
    pIRate.message = @"Please rate it in the AppStore!";
    pIRate.cancelButtonLabel = @"No Thanks";
    pIRate.rateButtonLabel = @"Rate It";
    pIRate.remindButtonLabel = @"";//@"Later";
    
}



#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    
    
    m_pGameCenterManager = nil;
    // Init the CCEAGLView
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [window bounds]
                                         pixelFormat: kEAGLColorFormatRGBA8
                                         depthFormat: GL_DEPTH24_STENCIL8_OES
                                  preserveBackbuffer: NO
                                          sharegroup: nil
                                       multiSampling: NO
                                     numberOfSamples: 0];
    
    // Use RootViewController manage CCEAGLView
    _viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    _viewController.wantsFullScreenLayout = YES;
    _viewController.view = eaglView;
    
    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: _viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:_viewController];
    }
    
    [window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden:true];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    
    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLView::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    
    
    cocos2d::Application::getInstance()->run();
    
    g_vdConfigNotification = nil;
    g_vdConfigNotification = [[VDConfigNotification alloc] initWithProductType:PT_FREE];
    g_vdConfigNotification.shouldShowNotificationWhenOpenApp = YES;
    g_vdConfigNotification.delegate = self;
    [g_vdConfigNotification setPopupStyle:POPUP_STYLE_SLICEFROMBOTTOM];
    [g_vdConfigNotification setCleverNetAdZoneID:@"7a266402ce2c1f100849c6f6c6a9b648"];
    
    [MPMediationAdController sharedManager].rootViewControllerBannerAd = window.rootViewController;
    [MPMediationAdController sharedManager].rootViewControllerFullscreenAd = window.rootViewController;
    
    
    /*
     NSString *adMobID = nil;
     adMobID       = @"ca-app-pub-9099762180397469/7716121437";
     adFullScreenCtrl = [[ADViewController alloc] initWithAdMobID:adMobID];
     adFullScreenCtrl.rootViewController = window.rootViewController;
     [adFullScreenCtrl loadInterstitialAd];
     */
    m_pAdsSupporter = new AdsSupporter;
    
    cocos2d::NotificationCenter::getInstance()->addObserver(m_pAdsSupporter, callfuncO_selector(AdsSupporter::myNotification), "showFullScreenAds", NULL);
    
    cocos2d::NotificationCenter::getInstance()->addObserver(m_pAdsSupporter, callfuncO_selector(AdsSupporter::showGameCenterHighscore), NOTIFICATION_HIGHSCORE, NULL);
    
    cocos2d::NotificationCenter::getInstance()->addObserver(m_pAdsSupporter, callfuncO_selector(AdsSupporter::hideAdsBanner), NOTIFICATION_HIDEADS_BANNER, NULL);
    
    cocos2d::NotificationCenter::getInstance()->addObserver(m_pAdsSupporter, callfuncO_selector(AdsSupporter::showAdsBanner), NOTIFICATION_SHOWADS_BANNER, NULL);
    
    cocos2d::NotificationCenter::getInstance()->addObserver(m_pAdsSupporter, callfuncO_selector(AdsSupporter::updateDayByDay), NOTIFICATION_UPDATE_DAY, NULL);
    
    cocos2d::NotificationCenter::getInstance()->addObserver(m_pAdsSupporter, callfuncO_selector(AdsSupporter::showAdsRate), NOTIFICATION_SHOWRATE, NULL);
    
    cocos2d::NotificationCenter::getInstance()->addObserver(m_pAdsSupporter, callfuncO_selector(AdsSupporter::forceshowAdsFullscreen), NOTIFICATION_SHOWADS_FULLSCREEN, NULL);
    
    cocos2d::Application::getInstance()->run();
    
    g_AppCtrl = self;
    
#pragma mark Init GameCenter
    
    //[self authenticateLocalPlayer];
    
    
    //Notification
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyStartV4VCWatching) name:kStartV4VCVideoWatching object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyWillAppearInterstitial:) name:kInterstitialAdWillAppear object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyFinishV4VCWatching) name:kFinishV4VCVideoWatching object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyWillDissappear) name:kInterstitialAdWillDissappear object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyInterstitialAdDidTap) name:kInterstitialAdDidTap object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyShowAds) name:@"NotifShowAds" object:nil];
    
    
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8)
    {
        [window addSubview:[MPMediationAdController sharedManager].bannerAdView];
        //
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            [MPMediationAdController sharedManager].bannerAdView.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 320)/2, [[UIScreen mainScreen] bounds].size.height - 50, 320, 50);
        }
        else
        {
            [MPMediationAdController sharedManager].bannerAdView.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 768)/2, [[UIScreen mainScreen] bounds].size.height - 90, 768, 90);
        }
        
        [[MPMediationAdController sharedManager] showBannerAd];
    }
    
    return YES;
}


-(void)showFullScreenAds:(NSNotification*)notif{
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    //We don't need to call this method any more. It will interupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->pause(); */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    //We don't need to call this method any more. It will interupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->resume(); */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
    
    m_pAdsSupporter->updateDayByDay();
    if(g_bShowAlertBonus)
    {
        g_bShowAlertBonus = FALSE;
        cocos2d::MessageBox("You've just got 1 hint!", "Ads view hint bonus");
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void) initGameCenter {
    
    if(m_pGameCenterManager == nil)
    {
        if([GameCenterManager isGameCenterAvailable])
        {
            m_pGameCenterManager = [GameCenterManager defaultGameCenterManager];
            [m_pGameCenterManager setDelegate:self];
            [m_pGameCenterManager authenticateLocalUser];
            
        }
        else
        {
            /*
             UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Game Center Support Required!"
             message:@"The current device does not support Game Center, which this sample requires."
             delegate:NULL
             cancelButtonTitle:@"OK"
             otherButtonTitles: NULL] autorelease];
             [alert show];
             */
        }
        
        [m_pGameCenterManager reloadHighScoresForCategory:g_leaderBoardName];
    }
}
- (void) showAlertBonusPoint {
    
}
- (void) showRateApp {
    
    if([[iRate sharedInstance] ratedThisVersion])
    {
        
    }
    else
    {
        [[iRate sharedInstance] promptIfNetworkAvailable];
    }
    
}
- (void) showLeaderBoard {
    
    [self initGameCenter];
    
    if(m_pGameCenterManager)
    {
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
        if (leaderboardController != NULL)
        {
            
            [[MPMediationAdController sharedManager] hideBannerAd];
            
            leaderboardController.category = g_leaderBoardName;
            leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
            leaderboardController.leaderboardDelegate = self;
            [[GameCenterManager defaultGameCenterManager] reloadHighScoresForCategory:g_leaderBoardName];
            [_viewController presentViewController:leaderboardController animated:YES completion:^{}];
        }
    }
    
}

- (void) showAlertViewHint{
    
    if(m_pAlertView)
    {
        [m_pAlertView release];
        m_pAlertView = nil;
    }
    m_pAlertView = [[UIAlertView alloc] initWithTitle:@"Add hints" message:@"You can get more hints now by click ads." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View ad", nil];
    
    [m_pAlertView show];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView == m_pAlertView)
    {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                
                g_bShowAdsBaner = FALSE;
                g_bShowAlertBonus = FALSE;
                if([[MPMediationAdController sharedManager] isInterstitialAdAvailable])
                {
                    [[MPMediationAdController sharedManager] forceFullscreenAdToBeShow];
                }
                else
                {
                    [[MPMediationAdController sharedManager] logEventToShowFullscreenAd];
                }
                break;
            default:
                break;
        }
    }
    
}

- (void) submitHighScoreToGameCenter:(int)iScore
{
    
    [self initGameCenter];
    if(iScore > 0)
    {
        if(m_pGameCenterManager)
            [m_pGameCenterManager reportScore:iScore forCategory:g_leaderBoardName];
    }
    
}

- (void) setShowHideAdv:(bool)bShow {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8)
    {
        if(bShow)
        {
            [[MPMediationAdController sharedManager] showBannerAd];
            [window  bringSubviewToFront:[MPMediationAdController sharedManager].bannerAdView];
        }
        else
        {
            [[MPMediationAdController sharedManager] hideBannerAd];
        }
    }
}


#pragma mark LeaderBoard Delegate
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [_viewController dismissViewControllerAnimated:YES completion:^{
        [[MPMediationAdController sharedManager] showBannerAd];
    }];
    [viewController release];
    
}


#pragma mark GameCenterManager delegates

- (void)processGameCenterAuth:(NSError *)error
{
    if (error == NULL)
    {
        [m_pGameCenterManager reloadHighScoresForCategory:g_leaderBoardName];
    }
    else
    {
        UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Game Center Account Required"
                                                        message:[NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]
                                                       delegate:self cancelButtonTitle: @"Try Again..." otherButtonTitles: NULL] autorelease];
        [alert show];
    }
}

- (void)scoreReported:(NSError *)error
{
    if (error == NULL)
    {
        [m_pGameCenterManager reloadHighScoresForCategory:g_leaderBoardName];
        //        UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"High Score Reported!"
        //                                                        message:[NSString stringWithFormat:@""]
        //                                                       delegate:self cancelButtonTitle: @"OK" otherButtonTitles: NULL] autorelease];
        //		[alert show];
    }
    else
    {
        UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Score Report Failed!"
                                                        message:[NSString stringWithFormat:@"Reason: %@", [error localizedDescription]]
                                                       delegate:self cancelButtonTitle: @"OK" otherButtonTitles: NULL] autorelease];
        [alert show];
    }
}

- (void)reloadScoresComplete:(GKLeaderboard *)leaderBoard error:(NSError *)error
{
    if(error == NULL)
    {
        /*
         if([leaderBoard.scores count] > 0)
         {
         SAFE_RELEASE(_highScores);
         SAFE_RELEASE(_topPlayers);
         _highScores = [[NSMutableArray alloc] initWithCapacity:0];
         _topPlayers = [[NSMutableArray alloc] initWithCapacity:0];
         _totalPlayers = [leaderBoard.scores count];
         for (int i = 0; i < [leaderBoard.scores count]; i++) {
         GKScore *score = [leaderBoard.scores objectAtIndex:i];
         [_highScores addObject:score.formattedValue];
         //                [[GameCenterManager defaultGameCenterManager] mapPlayerIDtoPlayer:score.playerID];
         [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:score.playerID] withCompletionHandler:^(NSArray *playerArray, NSError *error)
         {
         for (GKPlayer *player in playerArray)
         {
         if([player.playerID isEqualToString:score.playerID])
         {
         [_topPlayers addObject:player.alias];
         [_topPlayersDictionary setObject:score.formattedValue forKey:player.alias];
         
         break;
         }
         }
         }];
         }
         }
         //        [self reloadGlobalHighScore];
         */
    }
    else
    {
        
    }
}

- (void)achievementSubmitted:(GKAchievement *)ach error:(NSError *)error
{
    
}

- (void)achievementResetResult:(NSError *)error
{
    
}

- (void)mappedPlayerIDToPlayer:(GKPlayer *)player error:(NSError *)error
{
    if((error == NULL) && (player != NULL))
    {
        
    }
    else
    {
        
    }
}


#pragma mark Notification
-(void)onNotifyWillAppearInterstitial:(NSNotification*)notify
{
    g_bShowFullscreen = YES;
    [self setShowHideAdv:NO];
}
- (void) onNotifyStartV4VCWatching {
    g_bShowFullscreen = YES;
    [self setShowHideAdv:NO];
}

- (void) onNotifyFinishV4VCWatching {
    
    g_bShowAlertBonus = TRUE;
    g_bShowFullscreen = NO;
    [self setShowHideAdv:YES];
    
    m_pAdsSupporter->clickDoneADV();
}

- (void) onNotifyWillDissappear {
    g_bShowFullscreen = NO;
    if(g_bShowAdsBaner == FALSE)
    {
        g_bShowAdsBaner = TRUE;
        
    }
    else
        [self setShowHideAdv:YES];
}

- (void) onNotifyInterstitialAdDidTap {
    
    g_bShowAlertBonus = TRUE;
    [self showAlertBonusPoint];
    
    m_pAdsSupporter->clickDoneADV();
    
}
- (void) onNotifyShowAds {
    [self setShowHideAdv:YES];
}
#pragma mark Destroy
- (void)dealloc {
    
    [window release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    m_pGameCenterManager.delegate = nil;
    [super dealloc];
}


@end
