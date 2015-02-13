//
//  MPMediationAdController.m
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 6/13/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//
//  Last modify: 08/07/2014

#import "MPMediationAdController.h"

//#import "CleverNetView.h"

////////// KEY FOR Ad Network Config Updating //////
#define kPPCLINKMediationConfig_AdBanner        @"PPCLINKMediationConfig_AdBanner"
#define kPPCLINKMediationConfig_Interstitial    @"PPCLINKMediationConfig_Interstitial"

////////// AD NETWORK NAME DEFINITION ///////
#define kCleverNETNetwordName       @"clevernet"
#define kMopubNetwordName           @"mopub"
#define kAdmobNetwordName           @"admob"
#define kStartAppNetwordName        @"startapp"
#define kMillennialNetwordName      @"mmedia"
#define kAdconolyNetwordName        @"adcolony"
#define kVungleNetwordName          @"vungle"

#define kTheLastWatchingVideoPromtDate          @"LastWatchingVideoPromtDate"
#define kTheLastTimeUserClickOnAdOrWatchVideo   @"LastTimeUserClickOnAdOrWatchVideo"

typedef enum
{
    AD_AVAIBILITY_STATUS_OFF = 0,
    AD_AVAIBILITY_STATUS_PREPARING = 1,
    AD_AVAIBILITY_STATUS_READY = 2,
    AD_AVAIBILITY_STATUS_UNKNOW
} AD_AVAIBILITY_STATUS ;

@interface MPMediationAdController ()
{
    ////////// Product Type ///////////////
    PRODUCT_INAPP_TYPE    _productType;
    
    ////////// BANNER AD //////////////////
    MPAdView            *mopubBannerAd;
    GADBannerView       *admobBannerAd;
    //STABannerView       *startAppBannerAd;
    
    //CleverNetView       *cleverNetBannerAd;
    
    BOOL                isMopubBannerAdReady;
    BOOL                isAdmobBannerAdReady;
    BOOL                isStartAppBannerAdReady;
    BOOL                isMillennialBannerAdReady;
    
    NSMutableArray      *bannerAdNetworkGroup;
    int                 currentBannerAdNetworkIndex;
    
    ////////// FULLSCREEN AD //////////////
    MPInterstitialAdController  *mopubInterstitial;
    GADInterstitial             *admobInterstitial;
    //STAStartAppAd               *startAppInterstitial;
    
    NSTimer             *fullScreenAdFreeFromOpenAppTimer;
    //NSTimer             *minTimeIntervalBetweenTwoFullscreenAdTimer;
    NSTimer             *checkIntertitialAvaibilityTimer;
    
    BOOL                isMopubInterstitialReady;
    BOOL                isAdmobInterstitialReady;
    BOOL                isStartAppInterstitialReady;

    BOOL                isAdconolyZoneIDReady;
    
    NSMutableArray      *interstitialAdNetworkGroup;
    int                 currentSelectedInterstitialAdNetworkIndex;
    int                 loadingInterstitialAdNetworkIndex;
    
    AD_AVAIBILITY_STATUS    interstitialAdAvaibilityStatus;
    
    ///////// CONFIG PARAMS ///////////////
    int _timeMinToShowFullscreenAdFromOpenApp;
    int _timeMinBetweenTwoFullscreenAd;
    int _timeFreeAdBonusWhenClickOnAd;
    int _timeFreeFullScreenAdBonusWhenClickOnAd;
    
    BOOL _isAdNetworkInitialized;
    BOOL _recirculateAdNetworkEnabled;

    BOOL bBannerAdIsRequestedToShow;    /* Use to store banner ad state, YES if banner ad is able to show, NO in others case */

    
    ////////// V4VC Params ////////////////
    BOOL bAdconolyNetworkEnabled;
    BOOL bVungleNetworkEnabled;
    
    NSTimer *v4vcTimer;                 /* This timer is used to check if v4vc ad is available */
    AD_AVAIBILITY_STATUS v4vcStatus;
    
    
    ///////// AdNetwork Initialized mark //////
    BOOL _bDidInitMopubInterstitial;
    BOOL _bDidInitAdmobInterstitial;
    BOOL _bDidInitStartAppInterstitial;
    BOOL _bDidInitAdcolony;
    BOOL _bDidInitVungle;
}

@end

@implementation MPMediationAdController

+ (MPMediationAdController *)sharedManager
{
    static MPMediationAdController *_sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[super allocWithZone:NULL] init];
        
    });
    
    return _sharedManager;
}

- (GADRequest*) refineGADRequest
{
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for
    // the simulator as well as any devices you want to receive test ads.

#if __TESTMODE__
        request.testDevices = [NSArray arrayWithObjects:
                               GAD_SIMULATOR_ID,
                               @"e6d0c267c72816f7c4ebcb184604876f10e2187d",
                               @"8abdbc33cdbcf5142d69618635d12741224493ed",
                               @"8b2a47ecd967052e76e57c19486fd7729c9043b2",
                               @"8a2dff652613f84d195a4a92a674a9236e2cf63a",
                               @"269c55a6ed188006bcefde3b8b0642dd57127558",
                               @"890cfe8ba9beee0646750461fdd01e7cea89baf8",
                               @"2fd76652e88ed36474c16223fd630dcc910248c3",
                               @"a2b3cf2cd85fac403649dfcb7f902ccc0e668c44",
                               @"8b404a76d2188505943f31f4e20737464d89db0a",
                               @"a870077af6f4507b339172ef0e1c6cb5cd4eba68",
                               @"1534a37a240cda88c7841fae1d227a95cb415988",
                               @"90be99c0488968cbaa92514c683e5115321ba445",
                               @"f9699f6f0b2b10b68b9d92cc1f75411574c76505",
                               @"ed1c3c48a0e706bbff4471314bf4f9ff66af2f6b",
                               @"2b45de0e82ac9c0e6bae2ae850fd7f8f30f83e2d",
                               @"676de2dc613139b6ffe962fe021a78080ec8a422",
                               @"a00562afacd2ac12b4fe47d48341a50c50728089",
                               @"8b404a76d2188505943f31f4e20737464d89db0a",
                               nil];
#else
        request.testDevices = [NSArray arrayWithObjects:
                               GAD_SIMULATOR_ID,
                               nil];
#endif
    
    return request;
}

- (id) init
{
    if (self = [super init])
    {
        _productType = PRODUCT_INAPP_TYPE_FREE;
        
        _timeMinToShowFullscreenAdFromOpenApp = 120;
        _timeMinBetweenTwoFullscreenAd = 60;
        _timeFreeAdBonusWhenClickOnAd = 600;
        _timeFreeFullScreenAdBonusWhenClickOnAd = 600;
        
        //minTimeIntervalBetweenTwoFullscreenAdTimer = nil;
        fullScreenAdFreeFromOpenAppTimer = nil;
        
        bAdconolyNetworkEnabled = NO;
        bVungleNetworkEnabled = NO;
        
        interstitialAdAvaibilityStatus = AD_AVAIBILITY_STATUS_OFF;
        checkIntertitialAvaibilityTimer = nil;
        
        v4vcTimer = nil;
        v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
        
        self.enableBonusPointForWatchingVideoMode = NO;
        
        _bDidInitMopubInterstitial = NO;
        _bDidInitAdmobInterstitial = NO;
        _bDidInitStartAppInterstitial = NO;
        _bDidInitAdcolony = NO;
        _bDidInitVungle = NO;
        
        bannerAdNetworkGroup = [[NSMutableArray alloc] init];
        interstitialAdNetworkGroup = [[NSMutableArray alloc] init];
        
        [self initNotifications];
        
        if (self.enableBonusPointForWatchingVideoMode && [V4VCBonusManager isProVersionRequiredPointArchived])
        {
            //// Pro Version Upgraded
            _isAdNetworkInitialized = NO;
        }
        else
        {
            //// Free version
            _isAdNetworkInitialized = YES;
            
            [self loadCurrentActivedAdNetworkGroup];
            
            [self initAdNetworkComponent];
        
            [self updateAdConfigParam];
            
//            [NSThread detachNewThreadSelector:@selector(initOnDetachedThread) toTarget:self withObject:nil];
        }
    }
    
    return self;
}

- (void) initOnDetachedThread
{
    [self initAdNetworkComponent];
    
    [self updateAdConfigParam];
}

- (void) initAdNetworkComponent
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    ///// FIXME: Chỉ khởi tạo các mạng quảng cáo đã được lưu, sau khi update config sẽ khởi tạo thêm những mạng còn thiếu
    
    ///// Init base view
    CGSize sizeAdBanner = [self getAdBannerCGSize];
    CGRect recMainView = CGRectMake(0, 0, sizeAdBanner.width, sizeAdBanner.height);
    if (!self.bannerAdView)
    {
        self.bannerAdView = [[UIView alloc] initWithFrame:recMainView];
        self.bannerAdView.backgroundColor = [UIColor clearColor];
        self.bannerAdView.clipsToBounds = YES;
    }

    
    isMopubBannerAdReady = NO;
    isMopubInterstitialReady = NO;
    
    isAdmobBannerAdReady = NO;
    isAdmobInterstitialReady = NO;
    
    isStartAppBannerAdReady = NO;
    isStartAppInterstitialReady = NO;
    
    isAdconolyZoneIDReady = NO;
    
    currentBannerAdNetworkIndex = 0;
    currentSelectedInterstitialAdNetworkIndex = 0;
    loadingInterstitialAdNetworkIndex = 0;
    
    mopubBannerAd = nil;
    admobBannerAd = nil;
    //startAppBannerAd = nil;
    
    
    /*
    /// CleverNET
    if ([bannerAdNetworkGroup containsObject:kCleverNETNetwordName])
    {
        cleverNetBannerAd = [CleverNetView loadAdWithDelegate:self
                                             secondsToRefresh:25  includeFullscreen:false];
        
        [cleverNetBannerAd place_at_x:0 y:0];
        cleverNetBannerAd.hidden = YES;
    }
    */
    
    /// MOPUB
    if ([bannerAdNetworkGroup containsObject:kMopubNetwordName])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            mopubBannerAd = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPHONE_KEY size:MOPUB_BANNER_SIZE];
        }
        else
        {
            //mopubBannerAd = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPAD_KEY size:MOPUB_LEADERBOARD_SIZE];
            mopubBannerAd = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPAD_KEY size:CGSizeMake(768, 90)];
        }
        
        mopubBannerAd.delegate = self;
        mopubBannerAd.accessibilityLabel = @"banner";
        mopubBannerAd.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
    #if DEBUG
        mopubBannerAd.testing = YES;
    #endif
        
    }
    
    
    if ([interstitialAdNetworkGroup containsObject:kMopubNetwordName])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:MOPUB_AD_INTERSTITIAL_IPHONE_KEY];
        }
        else
        {
            mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:MOPUB_AD_INTERSTITIAL_IPAD_KEY];
        }
        
        mopubInterstitial.delegate = self;
        
#if DEBUG
        mopubInterstitial.testing = YES;
#endif
      
        _bDidInitMopubInterstitial = YES;
    }

    
    //// ADMOB
    if ([bannerAdNetworkGroup containsObject:kAdmobNetwordName])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            admobBannerAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        }
        else
        {
            admobBannerAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
        }
        
        admobBannerAd.adUnitID = kAdmobBannerMediationID;
        admobBannerAd.rootViewController = self;
        admobBannerAd.delegate = self;
    }
    
    if ([interstitialAdNetworkGroup containsObject:kAdmobNetwordName])
    {
        admobInterstitial = [[GADInterstitial alloc] init];
        admobInterstitial.adUnitID = kAdmobInterstitialMediationID;
        admobInterstitial.delegate = self;
        
        _bDidInitAdmobInterstitial = YES;
    }
    
    
//    //// STARTAPP
//    if ([interstitialAdNetworkGroup containsObject:kStartAppNetwordName] || [bannerAdNetworkGroup containsObject:kStartAppNetwordName])
//    {
//        STAStartAppSDK* startAppSdk = [STAStartAppSDK sharedInstance];
//        startAppSdk.appID = kStartAppApplicationID;
//        startAppSdk.devID = kStartAppDeveloperID;
//        
//        if ([bannerAdNetworkGroup containsObject:kStartAppNetwordName])
//        {
//            if (startAppBannerAd == nil){
//                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//                    startAppBannerAd = [[STABannerView alloc] initWithSize:STA_PortraitAdSize_320x50
//                                                                         origin:CGPointMake(0,0)
//                                                                       withView:self.bannerAdView withDelegate:self];
//                } else {
//                    startAppBannerAd = [[STABannerView alloc] initWithSize:STA_PortraitAdSize_768x90
//                                                                         origin:CGPointMake(0,0)
//                                                                       withView:self.bannerAdView withDelegate:self];
//                }
//            }
//        }
//        
//        if ([interstitialAdNetworkGroup containsObject:kStartAppNetwordName]){
//            startAppInterstitial = [[STAStartAppAd alloc] init];
//            
//            _bDidInitStartAppInterstitial = YES;
//        }
//    }
    
    
    ///////// ADCONOLY //////////
    if ([interstitialAdNetworkGroup containsObject:kAdconolyNetwordName]){
        
        [AdColony configureWithAppID:ADCONOLY_APP_ID zoneIDs:@[ADCONOLY_ZONE_ID] delegate:self logging:YES];
        
        _bDidInitAdcolony = YES;
    }

    ///////// VUNGLE ////////////
    if ([interstitialAdNetworkGroup containsObject:kAdconolyNetwordName]){
        VungleSDK* vungleSdk = [VungleSDK sharedSDK];
        [[VungleSDK sharedSDK] setDelegate:self];
        
        [vungleSdk startWithAppId:VUNGLE_APP_ID];
      
        _bDidInitVungle = YES;
    }
    
    mopubBannerAd.hidden = YES;
    admobBannerAd.hidden = YES;
    //startAppBannerAd.hidden = YES;
    
    /// Load & Cache the first interstitials
    //[self startLoadingInterstitialAd];
}


- (void) initExtraAdNetwork
{
    /// MOPUB
    if ([bannerAdNetworkGroup containsObject:kMopubNetwordName] && !mopubBannerAd)
    {
        NSLog(@"MP: Init added AdNetwork %@",kMopubNetwordName);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            mopubBannerAd = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPHONE_KEY size:MOPUB_BANNER_SIZE];
        }
        else
        {
            //mopubBannerAd = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPAD_KEY size:MOPUB_LEADERBOARD_SIZE];
            mopubBannerAd = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPAD_KEY size:CGSizeMake(768, 90)];
        }
        
        mopubBannerAd.delegate = self;
        mopubBannerAd.accessibilityLabel = @"banner";
        mopubBannerAd.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
#if DEBUG
        mopubBannerAd.testing = YES;
#endif
        
    }
    
    
    if ([interstitialAdNetworkGroup containsObject:kMopubNetwordName] && _bDidInitMopubInterstitial == NO)
    {
        NSLog(@"MP Interstitial: Init added AdNetwork %@",kMopubNetwordName);

        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:MOPUB_AD_INTERSTITIAL_IPHONE_KEY];
        }
        else
        {
            mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:MOPUB_AD_INTERSTITIAL_IPAD_KEY];
        }
        
        mopubInterstitial.delegate = self;
        
#if DEBUG
        mopubInterstitial.testing = YES;
#endif
        
        _bDidInitMopubInterstitial = YES;
    }
    
    
    //// ADMOB
    if ([bannerAdNetworkGroup containsObject:kAdmobNetwordName] && !admobBannerAd)
    {
        NSLog(@"MP: Init added AdNetwork %@",kAdmobNetwordName);

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            admobBannerAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        }
        else
        {
            admobBannerAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
        }
        
        admobBannerAd.adUnitID = kAdmobBannerMediationID;
        admobBannerAd.rootViewController = self;
        admobBannerAd.delegate = self;
    }
    
    if ([interstitialAdNetworkGroup containsObject:kAdmobNetwordName] && _bDidInitAdmobInterstitial == NO)
    {
         NSLog(@"MP Interstitial: Init added AdNetwork %@",kAdmobNetwordName);
        
        admobInterstitial = [[GADInterstitial alloc] init];
        admobInterstitial.adUnitID = kAdmobInterstitialMediationID;
        admobInterstitial.delegate = self;
        
        _bDidInitAdmobInterstitial = YES;
    }
    
    
//    //// STARTAPP
//    if ([interstitialAdNetworkGroup containsObject:kStartAppNetwordName] || [bannerAdNetworkGroup containsObject:kStartAppNetwordName])
//    {
//        STAStartAppSDK* startAppSdk = [STAStartAppSDK sharedInstance];
//        startAppSdk.appID = kStartAppApplicationID;
//        startAppSdk.devID = kStartAppDeveloperID;
//        
//        if ([bannerAdNetworkGroup containsObject:kStartAppNetwordName] && !startAppBannerAd)
//        {
//             NSLog(@"MP: Init added AdNetwork %@",kStartAppNetwordName);
//            
//            if (startAppBannerAd == nil){
//                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//                    startAppBannerAd = [[STABannerView alloc] initWithSize:STA_PortraitAdSize_320x50
//                                                                    origin:CGPointMake(0,0)
//                                                                  withView:self.bannerAdView withDelegate:self];
//                } else {
//                    startAppBannerAd = [[STABannerView alloc] initWithSize:STA_PortraitAdSize_768x90
//                                                                    origin:CGPointMake(0,0)
//                                                                  withView:self.bannerAdView withDelegate:self];
//                }
//            }
//        }
//        
//        if ([interstitialAdNetworkGroup containsObject:kStartAppNetwordName] && _bDidInitStartAppInterstitial == NO){
//            
//            NSLog(@"MP Interstitial: Init added AdNetwork %@",kStartAppNetwordName);
//            
//            startAppInterstitial = [[STAStartAppAd alloc] init];
//            
//            _bDidInitStartAppInterstitial = YES;
//        }
//    }
    
    
    ///////// ADCONOLY //////////
    if ([interstitialAdNetworkGroup containsObject:kAdconolyNetwordName] && _bDidInitAdcolony == NO){
        NSLog(@"MP Interstitial: Init added AdNetwork %@",kAdconolyNetwordName);
        
        [AdColony configureWithAppID:ADCONOLY_APP_ID zoneIDs:@[ADCONOLY_ZONE_ID] delegate:self logging:YES];
        
        _bDidInitAdcolony = YES;
    }
    
    ///////// VUNGLE ////////////
    if ([interstitialAdNetworkGroup containsObject:kVungleNetwordName] && _bDidInitVungle == NO){
        
        NSLog(@"MP Interstitial: Init added AdNetwork %@",kVungleNetwordName);
        
        VungleSDK* vungleSdk = [VungleSDK sharedSDK];
        [[VungleSDK sharedSDK] setDelegate:self];
        
        [vungleSdk startWithAppId:VUNGLE_APP_ID];
        
        _bDidInitVungle = YES;
    }
    
    
    /*
    ///////// CLEVER NET ////////////
    if ([bannerAdNetworkGroup containsObject:kCleverNETNetwordName] && !cleverNetBannerAd)
    {
        cleverNetBannerAd = [CleverNetView loadAdWithDelegate:self
                                             secondsToRefresh:25  includeFullscreen:false];
        
        [cleverNetBannerAd place_at_x:0 y:0];
        cleverNetBannerAd.hidden = YES;
    }
     */

}

- (void) initNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUpdateAdConfigNotification) name:@"GetUpdatedAdConfigParams" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyProUpgradeRequiredPointArchived) name:kNotifyProUpgradeRequiredPointArchived object:nil];
}

//- (void) dealloc
//{
//    [checkIntertitialAvaibilityTimer invalidate];
//    checkIntertitialAvaibilityTimer = nil;
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    [[VungleSDK sharedSDK] setDelegate:nil];
//    
//    mopubBannerAd.delegate = nil;
//    mopubInterstitial.delegate = nil;
//    [self.bannerAdView autorelease];
//    
//    [super dealloc];
//}



- (void) onTimerHideFullscreenAdWhenOpenApp
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    if (fullScreenAdFreeFromOpenAppTimer)
    {
        [fullScreenAdFreeFromOpenAppTimer invalidate];
        fullScreenAdFreeFromOpenAppTimer = nil;
    }
}

#pragma mark - Notifications
- (void) receivedUpdateAdConfigNotification
{
    NSLog(@"MPAdViewController: Did receive update ad config notification");
    
    if (_isAdNetworkInitialized == YES){
        [self updateAdConfigParam];
    }
}

- (void) appDidBecomeActive
{
    NSLog(@"ADVIEWCONTROLLER : appDidBecomeActive");
    
    if (_isAdNetworkInitialized == NO)
    {
        //// Pro Version Upgraded
        NSLog(@"Setup AdNetwork");
        
        _isAdNetworkInitialized = YES;
        
        [self initAdNetworkComponent];
        
        [self updateAdConfigParam];
    }

    
    /// Reactive adconoly video
    isAdconolyZoneIDReady = NO;
    
    if (_timeMinToShowFullscreenAdFromOpenApp > 0)
    {
        if (fullScreenAdFreeFromOpenAppTimer)
        {
            [fullScreenAdFreeFromOpenAppTimer invalidate];
            fullScreenAdFreeFromOpenAppTimer = nil;
        }
        
        fullScreenAdFreeFromOpenAppTimer = [NSTimer scheduledTimerWithTimeInterval:_timeMinToShowFullscreenAdFromOpenApp target:self selector:@selector(onTimerHideFullscreenAdWhenOpenApp) userInfo:nil repeats:YES];
    }
    else
        fullScreenAdFreeFromOpenAppTimer = nil;
    
}

- (void) onNotifyProUpgradeRequiredPointArchived
{
    [self hideBannerAd];
}

#pragma mark - Update Ad Config Params
- (void) loadCurrentActivedAdNetworkGroup
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *currentBannerNetworkGroup = [defaults objectForKey:kPPCLINKMediationConfig_AdBanner];
    NSArray *currentInterstitialNetworkGroup = [defaults objectForKey:kPPCLINKMediationConfig_Interstitial];
    
    if (currentBannerNetworkGroup && [currentBannerNetworkGroup count] > 0)
    {
        [bannerAdNetworkGroup addObjectsFromArray:currentBannerNetworkGroup];
    }
    else
    {
        [bannerAdNetworkGroup addObject:kMopubNetwordName];
    }
    
    if (currentInterstitialNetworkGroup && [currentInterstitialNetworkGroup count] > 0)
    {
        [interstitialAdNetworkGroup addObjectsFromArray:currentInterstitialNetworkGroup];
    }
    else
    {
        [interstitialAdNetworkGroup addObject:kMopubNetwordName];
    }
}

- (void) updateAdConfigParam
{
     NSLog(@"%s",__PRETTY_FUNCTION__);
    
    //// Update show/hide ad params
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _timeMinBetweenTwoFullscreenAd = [[defaults objectForKey:@"fullScreenAdFreeBetweenAdShowMinTimeInterval"] intValue];
    
    _timeMinToShowFullscreenAdFromOpenApp = [[defaults objectForKey:@"fullScreenAdFreeWhenOpenAppTimeInterval"] intValue];
    
    _timeFreeAdBonusWhenClickOnAd = [[defaults objectForKey:@"V4VCAdFreeTimeIntervalBonus"] intValue];
    
    _timeFreeFullScreenAdBonusWhenClickOnAd = [[defaults objectForKey:@"fullScreenAdFreeTimeIntervalBonus"] intValue];
    
    _recirculateAdNetworkEnabled = [[defaults objectForKey:@"RecirculateAdNetworkEnable"] boolValue];
   
    
    int timeDurationProUpgradeBonus = [[defaults objectForKey:@"ProUpgradeTimeDurationBonusInSecond"] intValue];
    int requiredPointToUpgradePro = [[defaults objectForKey:@"ProUpgradeRequiredPoint"] intValue];
    int proUpgradePointBonusPerView = [[defaults objectForKey:@"ProUpgradeBonusPointPerClick"] intValue];

    [V4VCBonusManager setProUpgradeBonusDuration:timeDurationProUpgradeBonus];
    [V4VCBonusManager setProVersionRequiredNumberPoint:requiredPointToUpgradePro];
    [V4VCBonusManager setNumberBonusPointPerView:proUpgradePointBonusPerView];
    
    ///////  AdNetwork Params Config
    currentBannerAdNetworkIndex = 0;
    currentSelectedInterstitialAdNetworkIndex = 0;
    
    [bannerAdNetworkGroup removeAllObjects];
    [interstitialAdNetworkGroup removeAllObjects];
    
    [self loadCurrentActivedAdNetworkGroup];
    
    
//    //// ???: TEST
//    //// TEST
//    
//    [bannerAdNetworkGroup removeAllObjects];
//    [bannerAdNetworkGroup addObject:kStartAppNetwordName];
//    
//    [interstitialAdNetworkGroup removeAllObjects];
//    [interstitialAdNetworkGroup addObject:kStartAppNetwordName];
    
    
    //// FIXME: Sau khi update config quảng cáo, cần khởi tạo lại những mạng còn thiếu chưa khởi tạo ở bước <initAdNetworkComponent>
    [self initExtraAdNetwork];
    
    //// Start V4VC Checking timer
    [self startLoadingInterstitialAd];
    [self startCheckingInterstitialAvailability];
    
    //// Check V4VC network availability
    bAdconolyNetworkEnabled = NO;
    bVungleNetworkEnabled = NO;
    
    for (NSString *networkName in interstitialAdNetworkGroup)
    {
        if ([networkName isEqualToString:kAdconolyNetwordName])
            bAdconolyNetworkEnabled = YES;
        
        if ([networkName isEqualToString:kVungleNetwordName])
            bVungleNetworkEnabled = YES;
    }
    
    //// Start V4VC Checking timer
    loadingInterstitialAdNetworkIndex = 0;
    [self startCheckingV4VCAvailability];
    
    
#if __TESTMODE__
    _timeMinBetweenTwoFullscreenAd = 0;
    _timeMinToShowFullscreenAdFromOpenApp = 5;
    _timeFreeAdBonusWhenClickOnAd = 0;
    _timeFreeFullScreenAdBonusWhenClickOnAd = 0;
#endif

}

/**
 *  Set AppType, so that if user has purchased in-app before, ad won't be displayed.
 */
- (void) setProductType:(PRODUCT_INAPP_TYPE)productType
{
    _productType = productType;
}

- (void) addBonusTimeFreeAdForUserWatchingVideoAndClickOnAd
{
    //// Set time bonus here when user click on ad or watch a ad video
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:kTheLastTimeUserClickOnAdOrWatchVideo];
    [defaults synchronize];
}

- (int) getRemainingFreeAdBonusTime
{
    //// For both FullScreen Ad + BANNER AD
    //// Check if bonus time free ad is remaining, if NO -> Ad able to be show
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* theLastTimeUserClickOnAd =  [defaults objectForKey:kTheLastTimeUserClickOnAdOrWatchVideo];
    if (!theLastTimeUserClickOnAd)
    {
        NSLog(@"MP: The is no bonus time remaining!");
        return 0;
    }

    
    NSDate* currentDate = [NSDate date];
    NSTimeInterval bonusTimeIntervalPassed = [currentDate timeIntervalSinceDate:theLastTimeUserClickOnAd];
    if (bonusTimeIntervalPassed > _timeFreeAdBonusWhenClickOnAd)
    {
        NSLog(@"MP: The is no bonus time remaining!");
        return 0;
    }
    else
    {
        NSLog(@"MP: Bonus time remaining!");
        return _timeFreeAdBonusWhenClickOnAd - bonusTimeIntervalPassed;
    }
    
    return 0;
}

- (int) getRemainingFreeFullScreenAdBonusTime
{
    //// For FULLSCREEN AD only
    //// Check if bonus time free ad is remaining, if NO -> Ad able to be show
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* theLastTimeUserClickOnAd =  [defaults objectForKey:kTheLastTimeUserClickOnAdOrWatchVideo];
    if (!theLastTimeUserClickOnAd)
    {
        NSLog(@"MP: The is no bonus time remaining!");
        return 0;
    }
    
    
    NSDate* currentDate = [NSDate date];
    NSTimeInterval bonusTimeIntervalPassed = [currentDate timeIntervalSinceDate:theLastTimeUserClickOnAd];
    if (bonusTimeIntervalPassed > _timeFreeFullScreenAdBonusWhenClickOnAd)
    {
        NSLog(@"MP: The is no bonus time for FullScreenAd remaining!");
        return 0;
    }
    else
    {
        NSLog(@"MP: Bonus time for FullScreenAd remaining!");
        return _timeFreeFullScreenAdBonusWhenClickOnAd - bonusTimeIntervalPassed;
    }
    
    return 0;
}

- (BOOL) isInterstitialAdAvailable
{
    if (isMopubInterstitialReady) return YES;
    if (isAdmobInterstitialReady) return YES;
    if (isStartAppInterstitialReady) return YES;
    
    return NO;
}


- (BOOL) shouldShowBannerAdsAtTheMoment
{
    //// Kiểm tra trường hợp đã tích đủ điểm được nâng cấp bản Pro
    if (self.enableBonusPointForWatchingVideoMode)
    {
        if ([V4VCBonusManager isProVersionRequiredPointArchived]){
            return NO;
        }
    }
    
    //// Còn trong thời gian thưởng sau khi click quảng cáo 
    if ([self getRemainingFreeAdBonusTime] > 0){
        return NO;
    }
    
    return YES;
}

- (BOOL) shouldShowFullScreenAdsAtTheMoment
{
    //// Kiểm tra trường hợp đã tích đủ điểm được nâng cấp bản Pro
    if (self.enableBonusPointForWatchingVideoMode)
    {
        if ([V4VCBonusManager isProVersionRequiredPointArchived]){
            return NO;
        }
    }
    
    //// Còn trong thời gian thưởng sau khi click quảng cáo
    if ([self getRemainingFreeAdBonusTime] > 0){
        return NO;
    }
    
    if ([self getRemainingFreeFullScreenAdBonusTime] > 0){
        return NO;
    }
    return YES;
}


#pragma mark - Update Banner Ad & Interstitial
- (CGSize)getAdBannerCGSize
{
    CGSize sizeAdBanner;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        sizeAdBanner = CGSizeMake(320, 50);
    }
    else
    {
        sizeAdBanner = CGSizeMake(768, 90);
    }
    
    return sizeAdBanner;
}

- (void) startCheckingInterstitialAvailability
{
    //// Call this function once after updating ad config param
    if (checkIntertitialAvaibilityTimer)
    {
        [checkIntertitialAvaibilityTimer invalidate];
        checkIntertitialAvaibilityTimer = nil;
    }
    
    checkIntertitialAvaibilityTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onInterstitialAvaibilityChecking) userInfo:nil repeats:YES];
}

- (void) onInterstitialAvaibilityChecking
{
    //// This checks each second if any interstitial available
    
    if ([interstitialAdNetworkGroup count] <= 0)
    {
        [checkIntertitialAvaibilityTimer invalidate];
        checkIntertitialAvaibilityTimer = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyInterstitialOff object:nil];
        return;
    }
    
    if ([self isInterstitialAdAvailable])
    {
        if (interstitialAdAvaibilityStatus != AD_AVAIBILITY_STATUS_READY)
        {
            interstitialAdAvaibilityStatus = AD_AVAIBILITY_STATUS_READY;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyInterstitialReady object:nil];
            
        }
    }
    else
    {
        if (interstitialAdAvaibilityStatus != AD_AVAIBILITY_STATUS_PREPARING)
        {
            interstitialAdAvaibilityStatus = AD_AVAIBILITY_STATUS_PREPARING;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyInterstitialLoading object:nil];
        }
    }

}
#pragma mark - Ad Banner Show/Hide handle
- (void) showBannerAd
{
    if (_productType == PRODUCT_INAPP_TYPE_PAID)
    {
        /// In-App purchased is done
        NSLog(@"In-App purchased is done");
        return;
    }
    
    if (self.enableBonusPointForWatchingVideoMode)
    {
        if ([V4VCBonusManager isProVersionRequiredPointArchived])
        {
            /// Đã đủ số điểm thưởng để lên bản PRO, không hiện quảng cáo nữa
            NSLog(@"Require Pro Upgrade point is enough");
            return;
        }
    }
    
    NSLog(@"ADVIEWCONTROLLER : showBannerAd");
    
    bBannerAdIsRequestedToShow = YES;
    [self updateAdBannerVisibility];
}

- (void) hideBannerAd
{
    NSLog(@"ADVIEWCONTROLLER : hideBannerAd");
    
    bBannerAdIsRequestedToShow = NO;
    [self updateAdBannerVisibility];
}

- (BOOL) bBannerAdIsShowing
{
    return !self.bannerAdView.hidden;
}


- (void) startAutoRefreshAdBanner
{
    NSLog(@"MOPUB: startAutoRefreshAdBanner");
    
    //// Notify start autorefresh banner ad
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewStartAutoRefresh object:nil];
    
    mopubBannerAd.hidden = YES;
    admobBannerAd.hidden = YES;
    //startAppBannerAd.hidden = YES;
    //cleverNetBannerAd.hidden = YES;
    
    [mopubBannerAd removeFromSuperview];
    [admobBannerAd removeFromSuperview];
    //[startAppBannerAd removeFromSuperview];
    //[cleverNetBannerAd removeFromSuperview];

    
    NSString *activeAdNetworkName = kMopubNetwordName;
    if (currentBannerAdNetworkIndex >= [bannerAdNetworkGroup count]) {
        currentBannerAdNetworkIndex = 0;
        return;
    }
    
    activeAdNetworkName = [bannerAdNetworkGroup objectAtIndex:currentBannerAdNetworkIndex];
    
    /*
    if ([activeAdNetworkName isEqualToString:kCleverNETNetwordName])
    {
        NSLog(@"MP BANNER: loading CleverNET Banner");
        
        /// Active Mopub Banner
        cleverNetBannerAd.hidden = NO;
        [self.bannerAdView addSubview:cleverNetBannerAd];
        [self.bannerAdView bringSubviewToFront:cleverNetBannerAd];
        return;
    }
     */
    
    if ([activeAdNetworkName isEqualToString:kMopubNetwordName])
    {
        NSLog(@"MP BANNER: loading MOPUB");
        
        /// Active Mopub Banner
        mopubBannerAd.hidden = NO;
        [self.bannerAdView addSubview:mopubBannerAd];
        [self.bannerAdView bringSubviewToFront:mopubBannerAd];
        [mopubBannerAd startAutomaticallyRefreshingContents];
        [mopubBannerAd loadAd];
        return;
    }
    
    if ([activeAdNetworkName isEqualToString:kAdmobNetwordName])
    {
        NSLog(@"MP BANNER: loading ADMOB");
        
        /// Active Mopub Banner
        admobBannerAd.hidden = NO;
        [self.bannerAdView addSubview:admobBannerAd];
        [self.bannerAdView bringSubviewToFront:admobBannerAd];
        [admobBannerAd loadRequest:[self refineGADRequest]];
        return;
    }
    
//    if ([activeAdNetworkName isEqualToString:kStartAppNetwordName])
//    {
//        NSLog(@"MP BANNER: loading STARTAPP");
//        
//        /// StartApp Banner
//        startAppBannerAd.hidden = NO;
//        [self.bannerAdView addSubview:startAppBannerAd];
//        [self.bannerAdView bringSubviewToFront:startAppBannerAd];
//        return;
//    }
    
    NSLog(@"This Ad Netword doest not supported : %@",activeAdNetworkName);
}

- (void) stopAutoRefreshAdBanner
{
    NSLog(@"MOPUB: stopAutoRefreshAdBanner");
    
    [mopubBannerAd stopAutomaticallyRefreshingContents];
}

- (void) updateAdBannerVisibility
{
    if (bBannerAdIsRequestedToShow)
    {
        self.bannerAdView.hidden = NO;
        [self startAutoRefreshAdBanner];
        
//        //// Không ẩn banner khi có bonus timer nữa
//        int numberSecondFreeAdRemaining = [self getRemainingFreeAdBonusTime];
//        if (numberSecondFreeAdRemaining > 0)
//        {
//            self.bannerAdView.hidden = YES;
//            [self stopAutoRefreshAdBanner];
//            
//            [self performSelector:@selector(updateAdBannerVisibility) withObject:nil afterDelay:numberSecondFreeAdRemaining + 1];
//        }
//        else
//        {
//            self.bannerAdView.hidden = NO;
//            [self startAutoRefreshAdBanner];
//        }
    }
    else
    {
        self.bannerAdView.hidden = YES;
        [self stopAutoRefreshAdBanner];
    }
}


#pragma mark - Handle fullscreen ad bonus
- (void) enableBonusBetweenTwoFullscreenAdShowing
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:@"DateShowingTheLastFullscreenAd"];
    [defaults synchronize];
}

- (BOOL) isBonusTimeBetweenTwoFullscreenAdShowingRemain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"DateShowingTheLastFullscreenAd"]) return NO;
    
    NSDate *dateShowingLastInterstitial = [defaults objectForKey:@"DateShowingTheLastFullscreenAd"];
    if (!dateShowingLastInterstitial) return NO;
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:dateShowingLastInterstitial];
    
    if (timeInterval > _timeMinBetweenTwoFullscreenAd)
        return NO;
    else
        return YES;
}


//- (void) enableBonusBetweenTwoFullscreenAdShowing
//{
//    
//    NSLog(@"MP: enableFullscreenAdFreeTime");
//    
//    /* Thoi gian tinh freead bat dau khi hien thi 1 fullscreen ad */
//    if (_timeMinBetweenTwoFullscreenAd > 0)
//    {
//        if (minTimeIntervalBetweenTwoFullscreenAdTimer)
//        {
//            [minTimeIntervalBetweenTwoFullscreenAdTimer invalidate];
//            minTimeIntervalBetweenTwoFullscreenAdTimer = nil;
//        }
//        
//        minTimeIntervalBetweenTwoFullscreenAdTimer = [NSTimer scheduledTimerWithTimeInterval:_timeMinBetweenTwoFullscreenAd target:self selector:@selector(disableMinTimeIntervalBetweenTwoFullscreenAdTimer) userInfo:nil repeats:YES];
//    }
//    else
//    {
//        minTimeIntervalBetweenTwoFullscreenAdTimer = nil;
//    }
//}
//
//- (void) disableMinTimeIntervalBetweenTwoFullscreenAdTimer
//{
//    NSLog(@"MP: disableMinTimeIntervalBetweenTwoFullscreenAdTimer");
//    
//    if (minTimeIntervalBetweenTwoFullscreenAdTimer)
//    {
//        [minTimeIntervalBetweenTwoFullscreenAdTimer invalidate];
//        minTimeIntervalBetweenTwoFullscreenAdTimer = nil;
//    }
//}



#pragma mark - Fullscreen Ad Show/Hide handle
- (void) startLoadingInterstitialAd
{
    //// Load lần lượt từng mạng theo thứ tự, cho đến khi lấy thành công quảng cáo hoặc đã duyệt hết 1 lượt
    NSLog(@"MOPUB INTERSTITIAL: startLoadingInterstitialAd");
    
    if (loadingInterstitialAdNetworkIndex >= [interstitialAdNetworkGroup count]){
        loadingInterstitialAdNetworkIndex = 0;
        return;
    }
    
    NSString *loadingInterstitialAdNetworkName = [interstitialAdNetworkGroup objectAtIndex:loadingInterstitialAdNetworkIndex];
    
    NSLog(@"FULLSCREEN: current LOADING NETWORK: %@",loadingInterstitialAdNetworkName);
    
    if ([loadingInterstitialAdNetworkName isEqualToString:kAdconolyNetwordName])
    {
        if (isAdconolyZoneIDReady) return;
        
        /// Load the next interstitial network
        loadingInterstitialAdNetworkIndex++;
        [self startLoadingInterstitialAd];
        return;
    }
    
    if ([loadingInterstitialAdNetworkName isEqualToString:kVungleNetwordName])
    {
        if ([[VungleSDK sharedSDK] isCachedAdAvailable]) return;
        
        /// Load the next interstitial network
        loadingInterstitialAdNetworkIndex++;
        [self startLoadingInterstitialAd];
        return;
    }
   
    
    if ([loadingInterstitialAdNetworkName isEqualToString:kMopubNetwordName])
    {
        if (!isMopubInterstitialReady)
            [mopubInterstitial loadAd];
        return;
    }
    
    if ([loadingInterstitialAdNetworkName isEqualToString:kAdmobNetwordName])
    {
        if (!isAdmobInterstitialReady)
            [admobInterstitial loadRequest:[self refineGADRequest]];
        return;
    }
    
//    if ([loadingInterstitialAdNetworkName isEqualToString:kStartAppNetwordName])
//    {
//        if(!isStartAppInterstitialReady)
//            [startAppInterstitial loadAd:STAAdType_Automatic withDelegate:self];
//        return;
//    }
}

- (bool) logEventToShowFullscreenAd
{
    
    bool bForce = false;
    if (_productType == PRODUCT_INAPP_TYPE_PAID)
    {
        /// In-App purchased is done
        NSLog(@"In-App purchased is done");
        return bForce;
    }
    
    if (self.enableBonusPointForWatchingVideoMode)
    {
        if ([V4VCBonusManager isProVersionRequiredPointArchived])
        {
            /// Đã đủ số điểm thưởng để lên bản PRO, không hiện quảng cáo nữa
            NSLog(@"Require Pro Upgrade point is enough");
            return bForce;
        }
    }


    if (fullScreenAdFreeFromOpenAppTimer)
    {
        NSLog(@"MP: Bonus free fullscreen is avaiable : Open app");
        return bForce;          /* Thoi gian tu luc mo ung dung van chua du, ko hien quang cao */
    }
    
    //if (minTimeIntervalBetweenTwoFullscreenAdTimer)
    if ([self isBonusTimeBetweenTwoFullscreenAdShowingRemain])
    {
        NSLog(@"MP: Time between opening 2 fullAd");
        return bForce;          /* Thoi gian toi thieu giua cac lan hien quang cao fullscreen */
    }
    
    int numberSecondFreeAdRemaining = [self getRemainingFreeAdBonusTime];
    if (numberSecondFreeAdRemaining > 0)
    {
        NSLog(@"MP: Time bonus (click ad, watch video) is remaining");
        return bForce;          /* Thoi gian bonus khi xem/click quang cao fullscreen */
    }
    
    int numberSecondFreeFullScreenAdRemaining = [self getRemainingFreeFullScreenAdBonusTime];
   
    if (numberSecondFreeFullScreenAdRemaining > 0){
        NSLog(@"MP: Time bonus for FullScreenAd (click ad, watch video) is remaining");
        return bForce;          /* Thoi gian bonus khi xem/click quang cao fullscreen */
    }
    
    bForce = true;
    [self forceFullscreenAdToBeShow];
    
    return bForce;
}

- (void) forceFullscreenAdToBeShow
{
    NSLog(@"MP Interstitial: Attemp to show fullscreen ad");
    currentSelectedInterstitialAdNetworkIndex = 0;
    
    
    //// Notify to inform tat fullscreen Ad is forced to be showed rightnow
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFullscreenAdIsForcedToBeShow object:nil];
    
    [self startShowingFullscreenAd];
}

- (void) startShowingFullscreenAd
{
    NSString *activeAdNetworkName = kMopubNetwordName;
    if (currentSelectedInterstitialAdNetworkIndex >= [interstitialAdNetworkGroup count])
    {
        NSLog(@"MP FULLSCREEN: Not any network avaiable, try to reload from starting");
        
        /// Not any network avaiable, try to reload from starting
        loadingInterstitialAdNetworkIndex = 0;
        currentSelectedInterstitialAdNetworkIndex = 0;
        [self startLoadingInterstitialAd];
        return;
    }
    
    activeAdNetworkName = [interstitialAdNetworkGroup objectAtIndex:currentSelectedInterstitialAdNetworkIndex];
    
    NSLog(@"MP FULLSCREEN: current NETWORK: %@",activeAdNetworkName);
    
    //// Adconoly ////
    if ([activeAdNetworkName isEqualToString:kAdconolyNetwordName])
    {
        if (!isAdconolyZoneIDReady)
        {
            currentSelectedInterstitialAdNetworkIndex++;
            [self startShowingFullscreenAd];
            return;
        }
        
        isAdconolyZoneIDReady = NO;
        
        NSLog(@"MP FULLSCREEN: Play ADCONOLY VIDEO for zone: %@",ADCONOLY_ZONE_ID);
        [AdColony playVideoAdForZone:ADCONOLY_ZONE_ID withDelegate:self];
        
        
        isAdconolyZoneIDReady = NO;
        [self enableBonusBetweenTwoFullscreenAdShowing];
        
        /// Recirculate AdNetwork for futher loading
        if (_recirculateAdNetworkEnabled){
            [self runRecirculateAdNetworkProcess];
        }
        
        /// Load & Cache the next ad
        loadingInterstitialAdNetworkIndex = 0;
        [self startLoadingInterstitialAd];
        
        return;
    }
    
    //// Vungle ////
    if ([activeAdNetworkName isEqualToString:kVungleNetwordName])
    {
        if (![[VungleSDK sharedSDK] isCachedAdAvailable])
        {
            currentSelectedInterstitialAdNetworkIndex++;
            [self startShowingFullscreenAd];
            return;
        }
        
        // Grab instance of Vungle SDK
        VungleSDK* sdk = [VungleSDK sharedSDK];
        
//        // Dict to set custom ad options
//        NSDictionary* options = @{@"orientations": @(UIInterfaceOrientationMaskAll),
//                                  @"incentivized": @(YES),
//                                  @"userInfo": @{@"user": @""},
//                                  @"showClose": @(NO)};
//        
//        // Pass in dict of options, play ad
//        [sdk playAd:self.rootViewControllerFullscreenAd withOptions:options];
        [sdk playAd:self.rootViewControllerFullscreenAd];
        
        /// Recirculate AdNetwork for futher loading
        if (_recirculateAdNetworkEnabled){
            [self runRecirculateAdNetworkProcess];
        }

        /// Load & Cache the next ad
        loadingInterstitialAdNetworkIndex = 0;
        [self startLoadingInterstitialAd];
        
        return;
    }
    
    //// Mopub ////
    if ([activeAdNetworkName isEqualToString:kMopubNetwordName])
    {
        if (!isMopubInterstitialReady)
        {
            currentSelectedInterstitialAdNetworkIndex++;
            [self startShowingFullscreenAd];
            return;
        }
        
        [mopubInterstitial showFromViewController:self.rootViewControllerFullscreenAd];
        [self enableBonusBetweenTwoFullscreenAdShowing];
        
        /// Need to check interstitial Ads avaibility again
        interstitialAdAvaibilityStatus = AD_AVAIBILITY_STATUS_OFF;
        isMopubInterstitialReady = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyInterstitialOff object:nil];
        
        /// Recirculate AdNetwork for futher loading
        if (_recirculateAdNetworkEnabled){
            [self runRecirculateAdNetworkProcess];
        }

        /// Load & Cache the next ad
        loadingInterstitialAdNetworkIndex = 0;
        [self startLoadingInterstitialAd];
        
        return;
    }
    
    
    //// Admob ////
    if ([activeAdNetworkName isEqualToString:kAdmobNetwordName])
    {
        if (!isAdmobInterstitialReady)
        {
            currentSelectedInterstitialAdNetworkIndex++;
            [self startShowingFullscreenAd];
            return;
        }
        
        [admobInterstitial presentFromRootViewController:self.rootViewControllerFullscreenAd];
        [self enableBonusBetweenTwoFullscreenAdShowing];
        isAdmobInterstitialReady = NO;
        
        /// Need to check interstitial Ads avaibility again
        interstitialAdAvaibilityStatus = AD_AVAIBILITY_STATUS_OFF;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyInterstitialOff object:nil];
        
        /// Recirculate AdNetwork for futher loading
        if (_recirculateAdNetworkEnabled){
            [self runRecirculateAdNetworkProcess];
        }

        /// Load & Cache the next ad
        loadingInterstitialAdNetworkIndex = 0;
        [self startLoadingInterstitialAd];
        
        return;
    }
    
    
//    //// StartApp ////
//    if ([activeAdNetworkName isEqualToString:kStartAppNetwordName])
//    {
//        if (!isStartAppInterstitialReady)
//        {
//            currentSelectedInterstitialAdNetworkIndex++;
//            [self startShowingFullscreenAd];
//            return;
//        }
//        
//        [startAppInterstitial showAd];
//        [self enableBonusBetweenTwoFullscreenAdShowing];
//        isStartAppInterstitialReady = NO;
//        
//        /// Need to check interstitial Ads avaibility again
//        interstitialAdAvaibilityStatus = AD_AVAIBILITY_STATUS_OFF;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyInterstitialOff object:nil];
//        
//        /// Recirculate AdNetwork for futher loading
//        if (_recirculateAdNetworkEnabled){
//            [self runRecirculateAdNetworkProcess];
//        }
//
//        /// Load & Cache the next ad
//        loadingInterstitialAdNetworkIndex = 0;
//        [self startLoadingInterstitialAd];
//        
//        return;
//    }
    
    
}

- (void) runRecirculateAdNetworkProcess
{
    //NSLog(@"Switch from adnetwork %@ to %@",);
    
    int numberAdNetworkTobePushed = currentSelectedInterstitialAdNetworkIndex + 1;

    for (int counter = 0; counter < numberAdNetworkTobePushed; counter++)
    {
        NSString* networkNameToBePushed = [NSString stringWithFormat:@"%@",[interstitialAdNetworkGroup objectAtIndex:0]];
        //NSString* networkNameToBePushed = [interstitialAdNetworkGroup objectAtIndex:0];
        [interstitialAdNetworkGroup removeObjectAtIndex:0];
        [interstitialAdNetworkGroup addObject:networkNameToBePushed];
    }
    
    NSLog(@"AdNetwork: %@",interstitialAdNetworkGroup);
}

#pragma mark - CleverNET Handle
/*
- (NSString *) appId
{
    return kCleverNetAppID;
}

- (bool) customEventEnabled
{
    return YES;
}

- (void)adViewDidClickAd:(CleverNetView *)adView
{
    NSLog(@"CleverNET: did click on Ad");
}
*/
//- (void)adViewDidReceiveAd:(CleverNetView *)adView
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    
//    //// Notify did load banner Ad successfully
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewDidLoadAdSuccessful object:nil];
//}

#pragma mark - MOPUB BannerAdView Delegate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [mopubBannerAd rotateToOrientation:toInterfaceOrientation];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    NSLog(@"--------- %s", __PRETTY_FUNCTION__);
    
    //return self;
    UIViewController *modalView = self.rootViewControllerBannerAd.presentedViewController;
    if (modalView){
        if(modalView.parentViewController){
            return modalView.parentViewController;
        }else{
            return modalView;
        }
    }
    
    return self.rootViewControllerBannerAd;
    
    return [[[[UIApplication sharedApplication]delegate] window] rootViewController];
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //// Notify did load banner Ad successfully
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewDidLoadAdSuccessful object:nil];
    
    //mopubBannerAd.center = CGPointMake(self.bannerAdView.frame.size.width/2, self.bannerAdView.frame.size.height/2);
    
    CGSize size = [view adContentViewSize];
    CGFloat centeredX = (self.bannerAdView.frame.size.width - size.width) / 2;
    //CGFloat bottomAlignedY = self.bannerAdView.frame.size.height - size.height;
    
    mopubBannerAd.center = CGPointMake(self.bannerAdView.frame.size.width/2 + centeredX, self.bannerAdView.frame.size.height/2);
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"MP BANNER: MOPUB failed to load");
    
    /// Try to get banner Ad of the next network
    currentBannerAdNetworkIndex++;
    [self startAutoRefreshAdBanner];
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //// ???: Check then
    [self userDidClickOnBannerAd];

    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewWillPresentModalView object:nil];
}

- (void)didDismissModalViewForAd:(MPAdView *)view
{
    //// Todo: User closed modal view.
    //// Update interface if needed.
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewWillDismissModalView object:nil];
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view
{
    //// Todo: User tap on banner ad, and app quit to open webview.
    ////  Need to add bonus for user this time.
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //// ???: Check then
    [self userDidClickOnBannerAd];
  
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewWillLeaveAppFromAd object:nil];
}

#pragma mark - MOPUB Interstitial AdController Delegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"====== %s", __PRETTY_FUNCTION__);
    
    isMopubInterstitialReady = YES;
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"====== %s", __PRETTY_FUNCTION__);
    
    
    /// Fail to load mopub interstitial, try to load interstitial of the next ad network
    isMopubInterstitialReady = NO;
    loadingInterstitialAdNetworkIndex++;
    [self startLoadingInterstitialAd];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    NSLog(@"====== %s", __PRETTY_FUNCTION__);
    
    if ([interstitial isBeingPresented])
        [interstitial dismissViewControllerAnimated:YES completion:nil];
    
    /// Make sure not to display expired interstitial
    isMopubInterstitialReady = NO;
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
   [[NSNotificationCenter defaultCenter] postNotificationName:kInterstitialAdWillAppear object:nil];
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInterstitialAdWillDissappear object:nil];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void) interstitialDidTap:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //// ???: Check then
    [self userDidClickOnInterstitialAd];
    [[NSNotificationCenter defaultCenter] postNotificationName:kInterstitialAdDidTap object:nil];
}

#pragma mark - ADMOB BannerAdView Delegate
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //// Notify did load banner Ad successfully
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewDidLoadAdSuccessful object:nil];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"ADMOB failed to load with error: %@", error.localizedDescription);
    NSLog(@"MP BANNER: ADMOB failed to load");
    
    /// Try to get banner Ad of the next network
    currentBannerAdNetworkIndex++;
    [self startAutoRefreshAdBanner];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //// ???: Check then
    
    [self userDidClickOnBannerAd];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewWillPresentModalView object:nil];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewWillDismissModalView object:nil];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //// ???: Check then
    [self userDidClickOnBannerAd];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewWillLeaveAppFromAd object:nil];
}

#pragma mark - ADMOB Interstitial AdController Delegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    isAdmobInterstitialReady = YES;
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    /// Fail to load admob interstitial, try to load interstitial of the next ad network
    isAdmobInterstitialReady = NO;
    loadingInterstitialAdNetworkIndex++;
    [self startLoadingInterstitialAd];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //// ???: Check then
    [[NSNotificationCenter defaultCenter] postNotificationName:kInterstitialAdWillAppear object:nil];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    admobInterstitial = [[GADInterstitial alloc] init];
    admobInterstitial.adUnitID = kAdmobInterstitialMediationID;
    admobInterstitial.delegate = self;
    [admobInterstitial loadRequest:[self refineGADRequest]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInterstitialAdWillDissappear object:nil];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //// ???: Check then
    [self userDidClickOnInterstitialAd];
    [[NSNotificationCenter defaultCenter] postNotificationName:kInterstitialAdDidTap object:nil];
}


//#pragma mark - STARTAPP Banner Ad Delegate
//- (void) didDisplayBannerAd:(STABannerView*)banner
//{
//    NSLog(@"StartApp Banner: %s",__PRETTY_FUNCTION__);
//    
//    //// Notify did load banner Ad successfully
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewDidLoadAdSuccessful object:nil];
//}
//
//- (void) failedLoadBannerAd:(STABannerView*)banner withError:(NSError *)error
//{
//    NSLog(@"StartApp Banner: %s",__PRETTY_FUNCTION__);
//}
//
//- (void) didClickBannerAd:(STABannerView*)banner
//{
//    NSLog(@"StartApp Banner: %s",__PRETTY_FUNCTION__);
//    
//    [self userDidClickOnBannerAd];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMPBannerAdViewWillPresentModalView object:nil];
//}
//
//#pragma mark - STARTAPP Interstitial Ad Delegate
//- (void) didLoadAd:(STAAbstractAd*)ad;
//{
//    NSLog(@"StartApp Banner: %s",__PRETTY_FUNCTION__);
//    
//    isStartAppInterstitialReady = YES;
//}
//
//- (void) failedLoadAd:(STAAbstractAd*)ad withError:(NSError *)error;
//{
//    NSLog(@"StartApp Banner: %s",__PRETTY_FUNCTION__);
//    
//    /// Fail to load startapp interstitial, try to load interstitial of the next ad network
//    isStartAppInterstitialReady = NO;
//    loadingInterstitialAdNetworkIndex++;
//    [self startLoadingInterstitialAd];
//}
//
//- (void) didShowAd:(STAAbstractAd*)ad;
//{
//    NSLog(@"StartApp Banner: %s",__PRETTY_FUNCTION__);
//    
//    //// ???: Check then
//}
//
//- (void) failedShowAd:(STAAbstractAd*)ad withError:(NSError *)error;
//{
//    NSLog(@"StartApp Banner: %s",__PRETTY_FUNCTION__);
//}
//
//- (void) didCloseAd:(STAAbstractAd*)ad
//{
//    NSLog(@"StartApp Banner: %s",__PRETTY_FUNCTION__);
//    
//    //// ???: Check if startapp has callback when user click on ad
//    //[[NSNotificationCenter defaultCenter] postNotificationName:kInterstitialAdDidTap object:nil];
//}

#pragma mark - AdConolyDelegate & AdConolyAdDelegate
- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID
{
    
    if(available)
    {
        NSLog(@"Adconoly READY for zone : %@",zoneID);
        
        if ([zoneID isEqualToString:ADCONOLY_ZONE_ID])
                isAdconolyZoneIDReady = YES;
	}
    else
    {
        NSLog(@"Adconoly NOT READY for zone : %@",zoneID);
        
		if ([zoneID isEqualToString:ADCONOLY_ZONE_ID])
                isAdconolyZoneIDReady = NO;
 	}

    ADCOLONY_ZONE_STATUS zoneStatus = [AdColony zoneStatusForZone:ADCONOLY_ZONE_ID];
    switch (zoneStatus) {
        case ADCOLONY_ZONE_STATUS_NO_ZONE:
            NSLog(@"ZoneStatus: ADCOLONY_ZONE_STATUS_NO_ZONE");
            break;
        case ADCOLONY_ZONE_STATUS_OFF:
            NSLog(@"ZoneStatus: ADCOLONY_ZONE_STATUS_OFF");
            break;
        case ADCOLONY_ZONE_STATUS_LOADING:
            NSLog(@"ZoneStatus: ADCOLONY_ZONE_STATUS_LOADING");
            break;
        case ADCOLONY_ZONE_STATUS_ACTIVE:
            NSLog(@"ZoneStatus: ADCOLONY_ZONE_STATUS_ACTIVE");
            break;
        case ADCOLONY_ZONE_STATUS_UNKNOWN:
            NSLog(@"ZoneStatus: ADCOLONY_ZONE_STATUS_UNKNOWN");
            break;
        default:
            break;
    }
    
}

- ( void ) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID
{
    NSLog(@"MP : onAdColonyV4VCReward : %d, currencyName : %@, currencyAmount: %d, inZone : %@",success,currencyName,amount,zoneID);
    
    if (success)
    {
        //// ???: Check then
        [self userDidWatchAnAdVideo];
        v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneOff object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishV4VCVideoWatching object:[NSNumber numberWithBool:YES]];
	}
    else
    {
        v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
        [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneOff object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishV4VCVideoWatching object:[NSNumber numberWithBool:NO]];
		
	}

}

- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID
{
    NSLog(@"onAdColonyAdStartedInZone %@",zoneID);
    
    //// Do pause game/sound if need
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartV4VCVideoWatching object:nil];
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID
{
    NSLog(@"onAdColonyAdStartedInZone %@ - %d",zoneID,shown);
    
    //// Do un-pause game/sound if need
    //// Passed param: YES - if v4vc is watched compleletely, NO - otherwise
    
    if (shown)
    {
        //// ???: Check then
        [self userDidWatchAnAdVideo];
        v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneOff object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishV4VCVideoWatching object:[NSNumber numberWithBool:YES]];
    }
    else
    {
        v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneOff object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishV4VCVideoWatching object:[NSNumber numberWithBool:NO]];
    }
}

#pragma mark - VungleSDK Delegate
/**
 * if implemented, this will get called when the SDK is about to show an ad. This point
 * might be a good time to pause your game, and turn off any sound you might be playing.
 */
- (void)vungleSDKwillShowAd
{
    NSLog(@"MP_Vungle: vungleSDKwillShowAd");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartV4VCVideoWatching object:[NSNumber numberWithBool:NO]];
}

/**
 * if implemented, this will get called when the SDK closes the ad view, but there might be
 * a product sheet that will be presented. This point might be a good place to resume your game
 * if there's no product sheet being presented. The viewInfo dictionary will contain the
 * following keys:
 * - "completedView": NSNumber representing a BOOL whether or not the video can be considered a
 *               full view.
 * - "playTime": NSNumber representing the time in seconds that the user watched the video.
 * - "didDownlaod": NSNumber representing a BOOL whether or not the user clicked the download
 *                  button.
 */
- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary*)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    NSLog(@"MP_Vungle: vungleSDKwillCloseAdWithViewInfo : %@, viewSheet:%d",viewInfo,willPresentProductSheet);
    
    if (!willPresentProductSheet)
    {
        //// Do un-pause game/sound if needed
        if ([[viewInfo objectForKey:@"completedView"] boolValue])
        {
            //// ???: Check then
            [self userDidWatchAnAdVideo];
            v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneOff object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishV4VCVideoWatching object:[NSNumber numberWithBool:YES]];
        }
        else
        {
            v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneOff object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishV4VCVideoWatching object:[NSNumber numberWithBool:NO]];
        }
    }
}

/**
 * if implemented, this will get called when the product sheet is about to be closed.
 */
- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    NSLog(@"MP_Vungle: vungleSDKwillCloseProductSheet %@",productSheet);
    
    //// ???: Check then
    [self userDidWatchAnAdVideo];
    v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneOff object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinishV4VCVideoWatching object:[NSNumber numberWithBool:YES]];
}


#pragma mark - V4VC : Video for value exchange
- (void) startCheckingV4VCAvailability
{
    //// Call this function once after updating ad config param
    if (v4vcTimer)
    {
        [v4vcTimer invalidate];
        v4vcTimer = nil;
    }
    
    v4vcTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onV4VCChecking) userInfo:nil repeats:YES];
}

- (void) onV4VCChecking
{
    //// This checks each second if any video ad available
    if (!bAdconolyNetworkEnabled && !bVungleNetworkEnabled)
    {
        [v4vcTimer invalidate];
        v4vcTimer = nil;
        
        v4vcStatus = AD_AVAIBILITY_STATUS_OFF;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneOff object:nil];
        
        return;
    }
    
    if ([self isV4VCVideoAvailable])
    {
        if (v4vcStatus != AD_AVAIBILITY_STATUS_READY)
        {
            v4vcStatus = AD_AVAIBILITY_STATUS_READY;
            [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneReady object:nil];
            
        }
    }
    else
    {
        if (v4vcStatus != AD_AVAIBILITY_STATUS_PREPARING)
        {
            v4vcStatus = AD_AVAIBILITY_STATUS_PREPARING;
            [[NSNotificationCenter defaultCenter] postNotificationName:kV4VCZoneLoading object:nil];
        }
    }
}

- (BOOL) isV4VCVideoAvailable
{
    if (bAdconolyNetworkEnabled && isAdconolyZoneIDReady) return YES;
    
    if (bVungleNetworkEnabled && [[VungleSDK sharedSDK] isCachedAdAvailable]) return YES;
    
    return NO;
}

- (void) playV4VCVideo
{
    if (![self isV4VCVideoAvailable]) return;
    
    v4vcStatus = AD_AVAIBILITY_STATUS_UNKNOW;
    
    [self forceFullscreenAdToBeShow];
}

- (void) logEventToShowWatchVideoPromt
{
#if !__FreeVersion__
    //// Paid Version
    return;
#endif
    
    if (_productType == PRODUCT_INAPP_TYPE_PAID)
    {
        /// In-App purchased is done
        NSLog(@"In-App purchased is done");
        return;
    }
    
    if (self.enableBonusPointForWatchingVideoMode)
    {
        if ([V4VCBonusManager isProVersionRequiredPointArchived])
        {
            /// Đã đủ số điểm thưởng để lên bản PRO, không hiện quảng cáo nữa
            NSLog(@"Require Pro Upgrade point is enough");
            return;
        }
    }
    
    //// Check if any video cached
    if (v4vcStatus != AD_AVAIBILITY_STATUS_READY)
    {
        NSLog(@"MP : Not any video cached yet!");
        return;
    }
    
    
    //// Check : Thời gian giữa 2 lần bật thông báo xem video liên tiếp
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL allowToShowWatchVideoPromt = YES;
    if (![defaults objectForKey:kTheLastWatchingVideoPromtDate])
    {
        allowToShowWatchVideoPromt = YES;
    }
    else
    {
        NSDate *theLastDate = [defaults objectForKey:kTheLastWatchingVideoPromtDate];
        NSDate *currentDate = [NSDate date];
        NSTimeInterval timeDurationFromTheLastPromtDate = [currentDate timeIntervalSinceDate:theLastDate];
        if (timeDurationFromTheLastPromtDate > MIN_DURATION_TO_THE_NEXT_WATCH_VIDEO_PROMT)
        {
            allowToShowWatchVideoPromt = YES;
        }
        else
        {
            NSLog(@"MP: The previous prompt is just showed");
            
            allowToShowWatchVideoPromt = NO;
        }
        
#if __TESTMODE__
        allowToShowWatchVideoPromt = YES;
#endif
        
    }
    
    if (allowToShowWatchVideoPromt)
    {
        [self forceWatchVideoPromtToBeShow];
    }
}

- (void) forceWatchVideoPromtToBeShow
{
    if (self.enableBonusPointForWatchingVideoMode)
    {
        //// Hiện thị Form thông báo có 2 nút Detail + Watch now
        MPMediationAdController* __unsafe_unretained weakSelf = self;
        
        NSString* titleText = [V4VCAlertDetailText getTitleTextOfType:V4VC_ALERT_TYPE_INFO];
        NSString* messageText = [V4VCAlertDetailText getMessageTextOfType:V4VC_ALERT_TYPE_INFO];
        NSString* leftButtonText = [V4VCAlertDetailText getLeftButtonTextOfType:V4VC_ALERT_TYPE_INFO];
        NSString* rightButtonText = [V4VCAlertDetailText getRightButtonTextOfType:V4VC_ALERT_TYPE_INFO];
        
        V4VCAlertView *alert = [[V4VCAlertView alloc] initWithTitle:titleText contentText:messageText leftButtonTitle:leftButtonText rightButtonTitle:rightButtonText autoDismiss:YES];
        
        [alert show];
        alert.leftBlock = ^()
        {
            NSLog(@"MP: left button clicked");
            [weakSelf showV4VCWatchVideoPromtDetailView];
        };
        alert.rightBlock = ^()
        {
            NSLog(@"MP: right button clicked");
            
            //// WATH VIDEO NOW
            [weakSelf forceFullscreenAdToBeShow];
        };
        alert.dismissBlock = ^()
        {
            NSLog(@"MP: Do something interesting after dismiss block");
        };

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate *currentDate = [NSDate date];
        [defaults setObject:currentDate forKey:kTheLastWatchingVideoPromtDate];
        [defaults synchronize];
    }
}

- (void) showV4VCWatchVideoPromtDetailView
{
    if (self.enableBonusPointForWatchingVideoMode)
    {
        MPMediationAdController* __unsafe_unretained weakSelf = self;
        
        //// Hiện thị Form Detail chi có 1 nút Watch now
        NSString* titleText = [V4VCAlertDetailText getTitleTextOfType:V4VC_ALERT_TYPE_DETAIL];
        NSString* messageText = [V4VCAlertDetailText getMessageTextOfType:V4VC_ALERT_TYPE_DETAIL];
        NSString* leftButtonText = [V4VCAlertDetailText getLeftButtonTextOfType:V4VC_ALERT_TYPE_DETAIL];
        NSString* rightButtonText = [V4VCAlertDetailText getRightButtonTextOfType:V4VC_ALERT_TYPE_DETAIL];
        
        V4VCAlertView *alert = [[V4VCAlertView alloc] initWithTitle:titleText contentText:messageText leftButtonTitle:leftButtonText rightButtonTitle:rightButtonText autoDismiss:YES];
        
        [alert show];
        alert.rightBlock = ^()
        {
            NSLog(@"MP: right button clicked");
            
            //// WATH VIDEO NOW
            [weakSelf forceFullscreenAdToBeShow];
        };
        alert.dismissBlock = ^()
        {
            NSLog(@"MP: Do something interesting after dismiss block");
        };
    }
}

#pragma mark - Action when user watch Video Ad or click on Banner Ad/ Interstitial Ad
- (void) userDidClickOnBannerAd
{
    NSLog(@"MP: userDidClickOnBannerAd");
    
    if (self.enableBonusPointForWatchingVideoMode)
    {
        [V4VCBonusManager addBonusPointForWatchingVideoOrClickOnAd];
    }
    
    [self addBonusTimeFreeAdForUserWatchingVideoAndClickOnAd];
    [self updateAdBannerVisibility];
}

- (void) userDidClickOnInterstitialAd
{
    NSLog(@"MP: userDidClickOnInterstitialAd");
    
    if (self.enableBonusPointForWatchingVideoMode)
    {
        [V4VCBonusManager addBonusPointForWatchingVideoOrClickOnAd];
    }
    
    [self addBonusTimeFreeAdForUserWatchingVideoAndClickOnAd];
    [self updateAdBannerVisibility];
}

- (void) userDidWatchAnAdVideo
{
    NSLog(@"MP: userDidWatchAnAdVideo");
    
    if (self.enableBonusPointForWatchingVideoMode)
    {
        [V4VCBonusManager addBonusPointForWatchingVideoOrClickOnAd];
    }
    
    [self addBonusTimeFreeAdForUserWatchingVideoAndClickOnAd];
    [self updateAdBannerVisibility];
}


@end

