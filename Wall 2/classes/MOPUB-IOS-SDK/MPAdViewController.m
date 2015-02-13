//
//  MPAdViewController.m
//  VietTVPro
//
//  Created by HIEPLM on 02/20/14.
//
//

#import "MPAdViewController.h"

#define kEventCountLogKey                   @"EventToShowFullscreenAd"

@interface MPAdViewController ()
{
    ////////// Product Type ///////////////
    PRODUCT_INAPP_TYPE    _productType;
    
    ////////// BANNER AD //////////////////
    MPAdView    *mp_adView;
    
    NSTimer             *bannerAdShowTimer;
    NSTimer             *bannerAdFreeTimer;
    NSTimer             *bannerAdFreeBonusTimer;
    
    ////////// FULLSCREEN AD //////////////
    MPInterstitialAdController *mp_interstitial;
    
    NSTimer             *fullScreenAdFromOpenAppTimer;
    NSTimer             *fullScreenAdFreeBonusTimer;
    NSTimer             *fullScreenAdFreeTimer;
    
    ///////// CONFIG PARAMS ///////////////
    BOOL bShowAdconolyVideoFirst;
    int percentShowAdconolyVideoVsInterstitalAd;
    
    int nBannerAdShowTimeInSecond;
    int nBannerAdFreeTimeInSecond;
    int nBannerAdBonusTimeInSecond;
    
    int nFullscreenAdFreeTimeFromOpenAppInSecond;
    int nFullscreenAdBonusTimeInSecond;
    int nFullscreenAdFreeTime;
    
    int nAdBannerReloadCounter;         /* When banner ad loading is failed, we can try to load it again nAdBannerReloadCounter times until succesful, but no more than 3 times */
    
    int nFullscreenAdReloadCounter;     /* When interstitial ad loading is failed, we can try to load it again nFullscreenAdReloadCounter times until succesful, but no more than 3 times */
    
    BOOL bBannerAdIsRequestedToShow;    /* Use to store banner ad state, YES if banner ad is able to show, NO in others case */
    
    BOOL bIsAdconolyReadyForCurrentZone;     /* The adconoly video state, YES if there is a video ready to be play, other wise NO. */
    
    BOOL bAdconolyVideoIsPlayed;        /* For each time the app become active, adconoly video is not show more than one time. */
    
    BOOL bIsFullscreenAdFreeBonus;      /* YES if there bonus time when fullscreen ad not to be show, NO in other case */
    
    BOOL bIsOnTestingMode;
}
@end

@implementation MPAdViewController

+ (MPAdViewController *)sharedManager
{
    static MPAdViewController *_sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[super allocWithZone:NULL] init];
        
    });
    
    return _sharedManager;
}

- (id) initWithTestModeEnabled:(BOOL)testModeEnabled
{
    if (self = [super init])
    {
        _productType = PRODUCT_INAPP_TYPE_FREE;
        bIsOnTestingMode = testModeEnabled;
        
        percentShowAdconolyVideoVsInterstitalAd = 0;
        
        nBannerAdShowTimeInSecond = 0;
        nBannerAdFreeTimeInSecond = 0;
        nBannerAdBonusTimeInSecond = 0;
        
        nFullscreenAdFreeTimeFromOpenAppInSecond = 120;
        nFullscreenAdBonusTimeInSecond = 900;
        nFullscreenAdFreeTime = 60;
        
        bShowAdconolyVideoFirst = YES;
        
        bannerAdFreeTimer = nil;
        bannerAdShowTimer = nil;
        bannerAdFreeBonusTimer = nil;
        
        fullScreenAdFreeBonusTimer = nil;
        fullScreenAdFromOpenAppTimer = nil;
        
        [self updateAdConfigParam];
        
        [self initBannerAd];
        [self initInterstitialAd];
        [self initAdconolyAd];
        
        [self initNotifications];
        
        [self showBannerAd];
    }
    return self;
}

- (id) init
{
    return [self initWithTestModeEnabled:NO];
}

- (void) initBannerAd
{
    self.rootViewControllerBannerAd = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        mp_adView = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPHONE_KEY size:MOPUB_BANNER_SIZE];
    }
    else
    {
        /**
         *  Banner Ad tren ipad co hai kich thuoc 768x90 va 728x90
         */
        
        //mp_adView = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPAD_KEY size:MOPUB_LEADERBOARD_SIZE];
        mp_adView = [[MPAdView alloc] initWithAdUnitId:MOPUB_AD_BANNER_IPAD_KEY size:CGSizeMake(768, 90)];
    }
    
    mp_adView.delegate = self;
    mp_adView.accessibilityLabel = @"banner";
    mp_adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    nAdBannerReloadCounter = 0;
    bBannerAdIsRequestedToShow = NO;
    
    mp_adView.testing = bIsOnTestingMode;
    
    ///// Init ad views here //////
    CGSize sizeAdBanner = [self getAdBannerCGSize];
    CGRect recMainView = CGRectMake(0, 0, sizeAdBanner.width, sizeAdBanner.height);
    if (!self.bannerAdView)
        self.bannerAdView = [[UIView alloc] initWithFrame:recMainView];
    
    self.bannerAdView.backgroundColor = [UIColor clearColor];
    self.bannerAdView.clipsToBounds = YES;
    
    [self.bannerAdView addSubview:mp_adView];
    
    [self setBannerAdFrame:recMainView];
    
}

- (void) initInterstitialAd
{
    fullScreenAdFreeTimer = nil;
    fullScreenAdFreeBonusTimer = nil;

    
    self.rootViewControllerFullscreenAd = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        mp_interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:MOPUB_AD_INTERSTITIAL_IPHONE_KEY];
        
    }
    else
    {
        mp_interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:MOPUB_AD_INTERSTITIAL_IPAD_KEY];
    }
    
    mp_interstitial.delegate = self;
    
    //// TEST MODE
    mp_interstitial.testing = bIsOnTestingMode;
    
    nFullscreenAdReloadCounter = 0;
    
    /**
     *  Load trước một cái fullscreen ad để khi cần show là show luôn, không phải chờ nó load từ đầu nhằm giảm hiện tượng delay.
     *  Chú ý: trước khi show fullscreen ad cần check xem nó ready không. Có thể thêm cơ chế reload lại khi nó bị expired.
     */
    [self startInterstitialAd];
}

- (void) initAdconolyAd
{
    /**
     *  AppID và zoneID sẽ lấy trên mạng. Request Lâm để generate cái mới cho từng ứng dụng.
     *  Mỗi app ứng với 1 AppID và có thể có nhiều zoneIDs. Mình chỉ cần 1 là ok.
     */
    bIsAdconolyReadyForCurrentZone = NO;
    bAdconolyVideoIsPlayed = NO;
    
    if (bIsOnTestingMode)
    {
        [AdColony configureWithAppID:ADCONOLY_APP_ID zoneIDs:@[ADCONOLY_ZONE_ID_FOR_TEST] delegate:self logging:YES];
    }
    else
    {
        [AdColony configureWithAppID:ADCONOLY_APP_ID zoneIDs:@[ADCONOLY_ZONE_ID_ACTIVED] delegate:self logging:YES];
    }
}


- (void) initNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyDidChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUpdateAdConfigNotification) name:@"GetUpdatedAdConfigParams" object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    mp_adView.delegate = nil;
    mp_interstitial.delegate = nil;
    if(self.bannerAdView)
        [self.bannerAdView autorelease];
    
    [super dealloc];
}

- (void) appDidBecomeActive
{
    NSLog(@"ADVIEWCONTROLLER : appDidBecomeActive");
    
    /// Reactive adconoly video
    bAdconolyVideoIsPlayed = NO;
    
    if (nFullscreenAdFreeTimeFromOpenAppInSecond > 0)
    {
        if (fullScreenAdFromOpenAppTimer)
        {
            [fullScreenAdFromOpenAppTimer invalidate];
            fullScreenAdFromOpenAppTimer = nil;
        }
        
        fullScreenAdFromOpenAppTimer = [NSTimer scheduledTimerWithTimeInterval:nFullscreenAdFreeTimeFromOpenAppInSecond target:self selector:@selector(onFullscreenAdWhenOpenAppTimer) userInfo:nil repeats:NO];
    }
    else
        fullScreenAdFromOpenAppTimer = nil;
    
}

- (void) onFullscreenAdWhenOpenAppTimer
{
    if (fullScreenAdFromOpenAppTimer)
    {
        [fullScreenAdFromOpenAppTimer invalidate];
        fullScreenAdFromOpenAppTimer = nil;
    }
}

#pragma mark - Set up Ad config params
/**
 *  Set AppType, so that if user has purchased in-app before, ad won't be displayed.
 */
- (void) setProductType:(PRODUCT_INAPP_TYPE)productType
{
    _productType = productType;
}

- (void) setAdconolyVideoToShowFirst:(BOOL)adconolyShowFirst
{
    bShowAdconolyVideoFirst = adconolyShowFirst;
}

- (void) receivedUpdateAdConfigNotification
{
    NSLog(@"MPAdViewController: Did receiv update ad config notification");
    [self updateAdConfigParam];
    
}
- (void) updateAdConfigParam
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int nBetweenFullAdInterval = [[defaults objectForKey:@"fullScreenAdFreeBetweenAdShowMinTimeInterval"] intValue];
    
    int nFullAdBonus = [[defaults objectForKey:@"fullScreenAdFreeTimeIntervalBonus"] intValue];
    
    int nFullAdFreeWhenOpenApp = [[defaults objectForKey:@"fullScreenAdFreeWhenOpenAppTimeInterval"] intValue];
    
    int nBannerAdBonus = [[defaults objectForKey:@"bannerAdFreeTimeIntervalBonus"] intValue];
    
    int nBannerAdFreeTime = [[defaults objectForKey:@"bannerAdFreeTimeInterval"] intValue];
    
    int nBannerAdShowTime = [[defaults objectForKey:@"bannerAdShowTimeInterval"] intValue];
    
    int nAdconolyPercentage = [[defaults objectForKey:@"AdConolyAdPercentage"] intValue];
    
    
    /// Refine some params
    if (nBetweenFullAdInterval == 0) nBetweenFullAdInterval = 60;
    if (nFullAdFreeWhenOpenApp == 0) nFullAdFreeWhenOpenApp = 60;
    if (nFullAdBonus == 0) nFullAdBonus = 60;
    
    if (nFullAdBonus == 0) nFullAdBonus = 600;
    if (nBannerAdBonus == 0) nBannerAdBonus = 100;
    
    
    /// Set up ad config param here
    nFullscreenAdFreeTimeFromOpenAppInSecond = 0;//nFullAdFreeWhenOpenApp;
    nFullscreenAdBonusTimeInSecond = 10;//nFullAdBonus;
    nFullscreenAdFreeTime = 10;//nBetweenFullAdInterval;
    
    percentShowAdconolyVideoVsInterstitalAd = nAdconolyPercentage;
    
    nBannerAdShowTimeInSecond = nBannerAdShowTime;
    nBannerAdFreeTimeInSecond = nBannerAdFreeTime;
    nBannerAdBonusTimeInSecond = nBannerAdBonus;
}

#pragma mark - Update Banner Ad frame
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

- (void) setBannerAdFrame:(CGRect)adFrame
{
    /// This return the banner ad size on mainscreen
    self.bannerAdView.frame = adFrame;
}

- (void)updateAdFrameInNewOrientation
{
    /// Notify delegate to update the banner ad on its view
    if ([self.delegate respondsToSelector:@selector(updateMPAdBannerFrame)])
    {
        [self.delegate updateMPAdBannerFrame];
    }
}

- (void) notifyDidChangeStatusBarOrientation:(NSNotification *)notification
{
    [self updateAdFrameInNewOrientation];
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
    
    NSLog(@"ADVIEWCONTROLLER : showBannerAd");
    
    bBannerAdIsRequestedToShow = YES;
    [self updateAdBannerVisibility];
    
    /// Check if banner ad show time is set
    if (nBannerAdShowTimeInSecond > 0)
    {
        if (!bannerAdFreeTimer && !bannerAdShowTimer)
            bannerAdShowTimer = [NSTimer scheduledTimerWithTimeInterval:nBannerAdShowTimeInSecond target:self selector:@selector(onTimerHideBannerAd) userInfo:nil repeats:NO];
    }
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

- (void) onTimerHideBannerAd
{
    // Temporary hide banner ad for a moment
    NSLog(@"ADVIEWCONTROLLER : onTimerHideBannerAd");
    
    int bannerAdFreeTimeInterval = nBannerAdFreeTimeInSecond;
    if (bannerAdFreeTimeInterval == 0)
        bannerAdFreeTimeInterval = 0.2;
    
    [bannerAdShowTimer invalidate];
    bannerAdShowTimer = nil;
    
    bannerAdFreeTimer = [NSTimer scheduledTimerWithTimeInterval:bannerAdFreeTimeInterval target:self selector:@selector(onTimerShowBannerAd) userInfo:nil repeats:NO];
    
    [self updateAdBannerVisibility];
}

- (void) onTimerShowBannerAd
{
    // Hien thi ad banner lai
    NSLog(@"ADVIEWCONTROLLER : onTimerShowBannerAd");
    
    [bannerAdFreeTimer invalidate];
    bannerAdFreeTimer = nil;
    
    if (nBannerAdShowTimeInSecond > 0)
        bannerAdShowTimer = [NSTimer scheduledTimerWithTimeInterval:nBannerAdShowTimeInSecond target:self selector:@selector(onTimerHideBannerAd) userInfo:nil repeats:NO];
    
    [self updateAdBannerVisibility];
}

- (void) onTimerAdFreeBonusTimer
{
    if (bannerAdFreeBonusTimer)
    {
        [bannerAdFreeBonusTimer invalidate];
        bannerAdFreeBonusTimer = nil;
    }
    
    bannerAdFreeBonusTimer = nil;
    
    [self updateAdBannerVisibility];
}

- (void) updateAdBannerVisibility
{
    //// TODO: base on adbanner is visible or not, turn it on or off respectively
    
    if (bBannerAdIsRequestedToShow && !bannerAdFreeTimer && !bannerAdFreeBonusTimer)
    {
        self.bannerAdView.hidden = NO;
        [mp_adView startAutomaticallyRefreshingContents];
        [mp_adView loadAd];
        
        [self updateAdFrameInNewOrientation];
        
        NSLog(@"MOPUB: Ad Banner is SHOWED");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBannerAdJustChangedVisibility object:[NSNumber numberWithBool:YES]];
    }
    else
    {
        self.bannerAdView.hidden = YES;
        [mp_adView stopAutomaticallyRefreshingContents];
        
        NSLog(@"MP: Ad Banner is HIDED");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBannerAdJustChangedVisibility object:[NSNumber numberWithBool:NO]];
    }
}

#pragma mark - Fullscreen Ad Show/Hide handle
- (void) startInterstitialAd
{
    [mp_interstitial loadAd];
}

- (void) showInterstitialAd
{
    NSLog(@"Attemp to show interstitial ad");
    
    if ([mp_interstitial ready])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInt:0] forKey:kEventCountLogKey];
        [defaults synchronize];
        
        [mp_interstitial showFromViewController:self.rootViewControllerFullscreenAd];
        
        /// Kích hoạt timer để tính thời gian tối thiểu giữa 2 lần hiện fullscreen ad liên tiếp
        [self enableFullscreenAdFreeTimer];
    }
        
    // Reset counter
    nFullscreenAdReloadCounter = 0;
    [mp_interstitial loadAd];
}

- (void) enableFullscreenAdFreeTimer
{
    
    NSLog(@"MP: enableFullscreenAdFreeTime");
    
    /* Thoi gian tinh freead bat dau khi hien thi 1 fullscreen ad */
    
    if (nFullscreenAdFreeTime > 0)
    {
        if (fullScreenAdFreeTimer)
        {
            [fullScreenAdFreeTimer invalidate];
            fullScreenAdFreeTimer = nil;
        }
        
        fullScreenAdFreeTimer = [NSTimer scheduledTimerWithTimeInterval:nFullscreenAdFreeTime target:self selector:@selector(disableFullscreenAdFreeTimer) userInfo:nil repeats:NO];
    }
    else
    {
        fullScreenAdFreeTimer = nil;
    }
}

- (void) disableFullscreenAdFreeTimer
{
    NSLog(@"MP: disableFullscreenAdFreeTime");
    
    if (fullScreenAdFreeTimer)
    {
        [fullScreenAdFreeTimer invalidate];
        fullScreenAdFreeTimer = nil;
    }
}

#pragma mark - <MPAdViewDelegate>
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [mp_adView rotateToOrientation:toInterfaceOrientation];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    NSLog(@"--------- %s", __PRETTY_FUNCTION__);
    
    UIViewController *modalView = self.rootViewControllerBannerAd.modalViewController;
    if (modalView)
    {
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
    
    // Reset counter
    nAdBannerReloadCounter = 0;
    
    CGSize size = [view adContentViewSize];
    CGFloat centeredX = (self.bannerAdView.frame.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.bannerAdView.frame.size.height - size.height;
    //CGRect rectBanner = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
    
    mp_adView.center = CGPointMake(self.bannerAdView.frame.size.width/2 + centeredX, self.bannerAdView.frame.size.height/2);
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    nAdBannerReloadCounter++;

    if (nAdBannerReloadCounter < 3)
        [view loadAd];
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
    //// Todo: User tap on banner ad, and app is about to present a modal view. Need to add bonus for user this time.
    //// Update interface if needed.
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (nBannerAdBonusTimeInSecond > 0)
    {
        if (!bannerAdFreeBonusTimer)
        {
            bannerAdFreeBonusTimer = [NSTimer scheduledTimerWithTimeInterval:nBannerAdBonusTimeInSecond target:self selector:@selector(onTimerAdFreeBonusTimer) userInfo:nil repeats:NO];
        }
        
        [self updateAdBannerVisibility];
    }
  
    if ([self.delegate respondsToSelector:@selector(mpAdBannerWillPresentModalView)])
        [self.delegate mpAdBannerWillPresentModalView];
}

- (void)didDismissModalViewForAd:(MPAdView *)view
{
    //// Todo: User closed modal view.
    //// Update interface if needed.
    
    NSLog(@"%s", __PRETTY_FUNCTION__);

    if ([self.delegate respondsToSelector:@selector(mpAdBannerWillPresentModalView)])
        [self.delegate mpAdBannerWillDismissModalView];
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view
{
    //// Todo: User tap on banner ad, and app quit to open webview.
    ////  Need to add bonus for user this time.
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (nBannerAdBonusTimeInSecond > 0)
    {
        if (!bannerAdFreeBonusTimer)
        {
            bannerAdFreeBonusTimer = [NSTimer scheduledTimerWithTimeInterval:nBannerAdBonusTimeInSecond target:self selector:@selector(onTimerAdFreeBonusTimer) userInfo:nil repeats:NO];
        }
        
        [self updateAdBannerVisibility];
    }

    
    if ([self.delegate respondsToSelector:@selector(mpAdBannerWillLeaveAppFromAd)])
        [self.delegate mpAdBannerWillLeaveAppFromAd];
}

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    //// Note: Fullscreen ad is loaded successfully. Now it's ready to be show.
    
    NSLog(@"====== %s", __PRETTY_FUNCTION__);
    
    // Reset counter
    nFullscreenAdReloadCounter = 0;
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    //// Note: Fullscreen Ad failed to load.
    //// Reloading ad may be need to process.
    
    NSLog(@"====== %s : %d", __PRETTY_FUNCTION__,nFullscreenAdReloadCounter);
    
    nFullscreenAdReloadCounter++;
    
    if (nFullscreenAdReloadCounter < 3)
        [interstitial loadAd];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    //// Note: Fullscreen Ad  justexpired.
    //// Reloading ad may be need to process.
    
    NSLog(@"====== %s", __PRETTY_FUNCTION__);
    
    if ([interstitial isBeingPresented])
        [interstitial dismissViewControllerAnimated:YES completion:nil];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void) interstitialDidTap:(MPInterstitialAdController *)interstitial
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self onFullscreenAdBonus];
}

- (void) onFullscreenAdBonus
{
    if (nFullscreenAdBonusTimeInSecond > 0)
    {
        NSLog(@"On FULLSCREEN AD BONUS");
        
        bIsFullscreenAdFreeBonus = YES;
        
        if (fullScreenAdFreeBonusTimer)
        {
            [fullScreenAdFreeBonusTimer invalidate];
            fullScreenAdFreeBonusTimer = nil;
        }
        
        fullScreenAdFreeBonusTimer = [NSTimer scheduledTimerWithTimeInterval:nFullscreenAdBonusTimeInSecond target:self selector:@selector(onDisableFullscreenAdBonus) userInfo:nil repeats:NO];
    }

}

- (void) onDisableFullscreenAdBonus
{
    NSLog(@"ADVIEWCONTROLLER : onDisableFullscreenAdBonus");
    
    bIsFullscreenAdFreeBonus = NO;
    
    if (fullScreenAdFreeBonusTimer)
    {
        [fullScreenAdFreeBonusTimer invalidate];
        fullScreenAdFreeBonusTimer = nil;
    }
}

#pragma mark - AdConolyDelegate & AdConolyAdDelegate
- ( void ) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID
{
    /**
     * Hàm callback này được gọi khi có một video sẵn sàng từ server ứng với 1 slot mình đã đăng kí.
     * Dùng hàm này để đánh dấu đã có thể play ad video được chưa.
     */
    
	if(available)
    {
        NSLog(@"Adconoly READY for zone : %@",zoneID);
		if ([zoneID isEqualToString:ADCONOLY_ZONE_ID_ACTIVED] && !bIsOnTestingMode)
            bIsAdconolyReadyForCurrentZone = YES;
        else if ([zoneID isEqualToString:ADCONOLY_ZONE_ID_FOR_TEST] && bIsOnTestingMode)
            bIsAdconolyReadyForCurrentZone = YES;
        else
            bIsAdconolyReadyForCurrentZone = NO;
	}
    else
    {
        NSLog(@"Adconoly NOT READY for zone : %@",zoneID);
		bIsAdconolyReadyForCurrentZone = NO;
	}
}

- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID
{
    NSLog(@"onAdColonyAdStartedInZone %@",zoneID);
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID
{
    NSLog(@"onAdColonyAdStartedInZone %@ - %d",zoneID,shown);
}

#pragma mark - Play Adconoly video ad
- (void) startPlayingAdconolyVideo
{
    /**
     *  Chú ý: check xem video ở slot (zone) tương ứng đã sẵn sàng chưa, trước khi play nó.
     */
    
    if (bIsAdconolyReadyForCurrentZone)
    {
        if (bIsOnTestingMode)
        {
            NSLog(@"Play ADCONOLY VIDEO for zone: %@",ADCONOLY_ZONE_ID_FOR_TEST);
            [AdColony playVideoAdForZone:ADCONOLY_ZONE_ID_FOR_TEST withDelegate:self];
        }
        else
        {
            NSLog(@"Play ADCONOLY VIDEO for zone: %@",ADCONOLY_ZONE_ID_FOR_TEST);
            [AdColony playVideoAdForZone:ADCONOLY_ZONE_ID_FOR_TEST withDelegate:self];
        }

        bIsAdconolyReadyForCurrentZone = NO;
    }
}

#pragma mark - Log event to show fullscreen ad
- (void) logEventToShowFullscreenAd
{
    if (_productType == PRODUCT_INAPP_TYPE_PAID)
    {
        /// In-App purchased is done
        NSLog(@"In-App purchased is done");
        return;
    }
    
    if (bIsFullscreenAdFreeBonus)
    {
        NSLog(@"MP: Bonus free fullscreen is avaiable : bonus");
        return;               /* Van con dang thoi gian bonus, khong hien quang cao */
    }
    
    if (fullScreenAdFromOpenAppTimer)
    {
        NSLog(@"MP: Bonus free fullscreen is avaiable : Open app");
        return;          /* Thoi gian tu luc mo ung dung van chua du, ko hien quang cao */
    }
    
    if (fullScreenAdFreeTimer)
    {
        NSLog(@"MP: Time between opening fullAd");
        return;          /* Thoi gian toi thieu giua cac lan hien quang cao fullscreen */
    }
    
    
    NSLog(@"MP: Attemp to show fullscreen ad");
    
    srand (time(NULL));
    int iGetRandom = rand() % 100 + 1;
    if (bShowAdconolyVideoFirst || iGetRandom <= percentShowAdconolyVideoVsInterstitalAd)
    {
        ////    Time to show adconoly video, check if it is ready to play, otherwise show interstitial
        if (bIsAdconolyReadyForCurrentZone && !bAdconolyVideoIsPlayed)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:0] forKey:kEventCountLogKey];
            [defaults synchronize];
            
            
            bIsAdconolyReadyForCurrentZone = NO;
            bAdconolyVideoIsPlayed = YES;

            if (bIsOnTestingMode)
            {
                NSLog(@"MP: Play ADCONOLY VIDEO for zone: %@",ADCONOLY_ZONE_ID_FOR_TEST);
                [AdColony playVideoAdForZone:ADCONOLY_ZONE_ID_FOR_TEST withDelegate:self];
            }
            else
            {
                NSLog(@"MP: Play ADCONOLY VIDEO for zone: %@",ADCONOLY_ZONE_ID_ACTIVED);
                [AdColony playVideoAdForZone:ADCONOLY_ZONE_ID_ACTIVED withDelegate:self];
            }

            
            [self onFullscreenAdBonus];
            [self enableFullscreenAdFreeTimer];
        }
        else
        {
            [self showInterstitialAd];
        }
    }
    else
    {
        [self showInterstitialAd];
    }
}
@end
