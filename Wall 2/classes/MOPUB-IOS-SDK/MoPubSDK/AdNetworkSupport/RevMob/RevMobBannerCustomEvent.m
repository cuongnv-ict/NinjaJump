//
//  InMobiBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "RevMobBannerCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPConstants.h"
#import "MPLogging.h"

#define kRevMobPublisherID            @"YOUR_REVMOB_PUBLISHER_ID"

@interface MPInstanceProvider (RevMobBanners)

- (RevMobBannerView *)buildRevMobBannerViewWithPlacementId:(NSString *)placementId;

@end

@implementation MPInstanceProvider (RevMobBanners)

- (RevMobBannerView *)buildRevMobBannerViewWithPlacementId:(NSString *)placementId
{
    return [[RevMobAds session] bannerViewWithPlacementId:placementId];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RevMobBannerCustomEvent ()

@property (nonatomic, retain) RevMobBannerView *revMobBanner;

@end

@implementation RevMobBannerCustomEvent

#pragma mark - MPBannerCustomEvent Subclass Methods

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting RevMob banner");

    NSString* publisherId = [info objectForKey:@"publisherId"];
    if(!publisherId){
        publisherId = kRevMobPublisherID;
    }
    [RevMobAds startSessionWithAppID:publisherId];
#ifdef DEBUG
    [[RevMobAds session] setTestingMode:RevMobAdsTestingModeWithAds];
#endif
    
    NSString* placementId = [info objectForKey:@"placementId"];
    
    self.revMobBanner = [[MPInstanceProvider sharedProvider] buildRevMobBannerViewWithPlacementId:placementId];
    self.revMobBanner.delegate = self;
    
    if (CGSizeEqualToSize(size, MOPUB_BANNER_SIZE)) {
        self.revMobBanner.frame = CGRectMake(0, 0, 320, 50);
    } else if (CGSizeEqualToSize(size, MOPUB_MEDIUM_RECT_SIZE)) {
        self.revMobBanner.frame = CGRectMake(0, 0, 300, 250);
    } else if (CGSizeEqualToSize(size, MOPUB_LEADERBOARD_SIZE)) {
        self.revMobBanner.frame = CGRectMake(0, 0, 768, 90);
    } else {
        self.revMobBanner.frame = CGRectMake(0, 0, 0, 0);

    }
    
    [self.revMobBanner setNeedsLayout];
    [self.revMobBanner loadAd];

}


- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Override this method to return NO to perform impression and click tracking manually.

    return YES;
}

- (void)dealloc
{
    [self.revMobBanner setDelegate:nil];
    self.revMobBanner = nil;
    [super dealloc];
}

#pragma mark - Required RevMob methods


-(void)revmobAdDidFailWithError:(NSError *)error {
    MPLogInfo(@"RevMob Banner failed to load with error: %@", error.localizedDescription);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

-(void)revmobAdDidReceive {
    MPLogInfo(@"RevMob Banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:self.revMobBanner];
}

-(void)revmobAdDisplayed {
    MPLogInfo(@"Ad displayed");
    
}

-(void)revmobUserClickedInTheAd {
    MPLogInfo(@"RevMob Banner will present modal");
    [self.delegate bannerCustomEventWillBeginAction:self];

}

-(void)revmobUserClosedTheAd {
    MPLogInfo(@"RevMob Banner did dismiss modal");
    [self.delegate bannerCustomEventDidFinishAction:self];

}




@end
