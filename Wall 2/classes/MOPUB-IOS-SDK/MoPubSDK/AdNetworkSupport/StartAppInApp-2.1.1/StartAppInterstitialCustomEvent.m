//
//  InMobiInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "StartAppInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

#define kStartAppApplicationID          @"ApplicationID"
#define kStartAppDeveloperID            @"DeveloperID"

#define DEFAULT_APPLICATION_ID          @"Default App ID"
#define DEFAULT_DEVELOPER_ID            @"Default Dev ID"

//@interface MPInstanceProvider (StartAppInterstitials)
//
//- (RevMobFullscreen *)builStartAppInterstitialAdWithPlacementId:(NSString *)placementId;
//
//@end
//
//@implementation MPInstanceProvider (RevMobInterstitials)
//
//- (RevMobFullscreen *)buildRevMobInterstitialAdWithPlacementId:(NSString *)placementId
//{
//    return [[RevMobAds session] fullscreenWithPlacementId:placementId];
//}
//
//
//@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface StartAppInterstitialCustomEvent ()

@property (nonatomic, retain) STAStartAppAd *startAppInterstitial;

@end

@implementation StartAppInterstitialCustomEvent
@synthesize startAppInterstitial;


#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting StartApp interstitial");
    
    NSString* applicationID = [info objectForKey:kStartAppApplicationID];
    NSString* developerID = [info objectForKey:kStartAppDeveloperID];
    
    if(!applicationID)
    {
        applicationID = DEFAULT_APPLICATION_ID;
    }
    
    if(!developerID)
    {
        developerID = DEFAULT_DEVELOPER_ID;
    }
    
    if (!self.startAppInterstitial)
    {
        // initialize the SDK with your appID and devID
        STAStartAppSDK* sdk = [STAStartAppSDK sharedInstance];
        sdk.appID = applicationID;
        sdk.devID = developerID;
        
        self.startAppInterstitial = [[STAStartAppAd alloc] init];
    }
    
    [self.startAppInterstitial loadAd:STAAdType_Automatic withDelegate:self];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.startAppInterstitial showAd];
}

- (void)dealloc
{
    [self.startAppInterstitial autorelease];
    self.startAppInterstitial = nil;
    [super dealloc];
}

#pragma mark - IMAdInterstitialDelegate

/*
Implementation of the STADelegationProtocol.
All methods here are optional and you can
implement only the ones you need.
*/

// StartApp Ad loaded successfully
- (void) didLoadAd:(STAAbstractAd*)ad;
{
    MPLogInfo(@"StartApp Ad had been loaded successfully");
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
}

// StartApp Ad failed to load
- (void) failedLoadAd:(STAAbstractAd*)ad withError:(NSError *)error;
{
    MPLogInfo(@"StartApp Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

// StartApp Ad is being displayed
- (void) didShowAd:(STAAbstractAd*)ad;
{
    MPLogInfo(@"StartApp Interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

// StartApp Ad failed to display
- (void) failedShowAd:(STAAbstractAd*)ad withError:(NSError *)error;
{
    NSLog(@"StartApp Ad is failed to display");
}

// StartApp Ad close ad
- (void) didCloseAd:(STAAbstractAd*)ad
{
    MPLogInfo(@"StartApp Interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
    MPLogInfo(@"StartApp Interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

//-(void)revmobUserClickedInTheAd
//{
//    MPLogInfo(@"RevMob Interstitial UserClickedInTheAd");
//}

@end
