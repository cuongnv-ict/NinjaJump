//
//  InMobiInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialCustomEvent.h"

/* Import of StartApp SDK header files */
#import "STAStartAppSDK.h"

#import "STAStartAppAd.h"
#import "STABannerSize.h"
#import "STABannerView.h"


/*
 * Compatible with version 4.0.0 of the InMobi SDK.
 */

@interface StartAppInterstitialCustomEvent : MPInterstitialCustomEvent <STADelegateProtocol>
{
    /*
     Declaration of STAStartAppAd which later on will be used
     for loading when user clicks on a button and showing the
     loaded ad when the ad was loaded with delegation
     */
    STAStartAppAd *startAppInterstitial;
}
@end
