#import <CoreLocation/CoreLocation.h>

typedef enum tagCleverNetAnimationClass {
  leftToRight, topToBottom, curlDown, fade, none 
} CleverNetAnimationClass;


@class CleverNetView;

@protocol CleverNetDelegationProtocol<NSObject>

@required
- (NSString *) appId;


@optional

- (double) durationOfBannerAnimation;               // 1.5 for example
- (CleverNetAnimationClass) bannerAnimationType;    // curlDown, topToBottom, leftToRight, fade, none
- (void) inAppBrowserWillOpen;                      // YES | NO
- (void) inAppBrowserClosed;                        // YES | NO
- (bool) debugEnabled;                              // YES | NO
- (bool) downloadTrackerEnabled;                    // YES | NO
- (NSString *) adServer;                           
- (CLLocationCoordinate2D) location;
- (NSString *) gender;                              // F | M 
- (NSString *) age;                                 // single number 1,2,.. || range 0-120
- (UIColor *) textAdBackGroundColor;
- (UIColor *) textlabelColor;
- (void)adViewDidReceiveAd:(CleverNetView *)adView;
- (void)adViewDidClickAd:(CleverNetView *)adView;
- (void)adView:(CleverNetView *)view didFailToReceiveAdWithError:(NSError *)error;
- (void)adViewWillPresentScreen:(CleverNetView *)adView;
- (void)adViewWillDismissScreen:(CleverNetView *)adView;
- (void)adViewDidDismissScreen:(CleverNetView *)adView;
- (void)adViewWillLeaveApplication:(CleverNetView *)adView;
- (bool) customEventEnabled;

- (BOOL) mRaidDisabled;                             // YES | NO

@end
