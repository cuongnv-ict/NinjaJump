//
//  InMobiInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "RevMobInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

#define kRevMobPublisherID            @"YOUR_REVMOB_PUBLISHER_ID"


@interface MPInstanceProvider (RevMobInterstitials)

- (RevMobFullscreen *)buildRevMobInterstitialAdWithPlacementId:(NSString *)placementId;

@end

@implementation MPInstanceProvider (RevMobInterstitials)

- (RevMobFullscreen *)buildRevMobInterstitialAdWithPlacementId:(NSString *)placementId
{
    return [[RevMobAds session] fullscreenWithPlacementId:placementId];
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RevMobInterstitialCustomEvent ()

@property (nonatomic, retain) RevMobFullscreen *revMobInterstitial;

@end

@implementation RevMobInterstitialCustomEvent
@synthesize revMobInterstitial = _revMobInterstitial;


#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSString* publisherId = [info objectForKey:@"publisherId"];
    if(!publisherId){
        publisherId = kRevMobPublisherID;
    }
    [RevMobAds startSessionWithAppID:publisherId];
#ifdef DEBUG
    [[RevMobAds session] setTestingMode:RevMobAdsTestingModeWithAds];
#endif
    
    NSString* placementId = [info objectForKey:@"placementId"];
    
    self.revMobInterstitial = [[MPInstanceProvider sharedProvider] buildRevMobInterstitialAdWithPlacementId:placementId];
    self.revMobInterstitial.delegate = self;
    
    [self.revMobInterstitial loadWithSuccessHandler:^(RevMobFullscreen *fs) {
        MPLogInfo(@"RevMob Interstitial did load");
        [self.delegate interstitialCustomEvent:self didLoadAd:self];
    } andLoadFailHandler:^(RevMobFullscreen *fs, NSError *error) {
        MPLogInfo(@"RevMob Interstitial failed to load with error: %@", error.localizedDescription);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.revMobInterstitial showAd];
}

- (void)dealloc
{
    self.revMobInterstitial.delegate = nil;
    self.revMobInterstitial = nil;
    [super dealloc];
}

#pragma mark - IMAdInterstitialDelegate

-(void)revmobAdDidFailWithError:(NSError *)error {
    MPLogInfo(@"RevMob Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

-(void)revmobAdDidReceive {
    MPLogInfo(@"RevMob Interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
}

-(void)revmobAdDisplayed {
    MPLogInfo(@"RevMob Interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

-(void)revmobUserClickedInTheAd {
    MPLogInfo(@"RevMob Interstitial UserClickedInTheAd");
}

-(void)revmobUserClosedTheAd {
    
    MPLogInfo(@"RevMob Interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
    MPLogInfo(@"RevMob Interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}


@end
