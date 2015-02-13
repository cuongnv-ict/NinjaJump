//
//  MPNativeAdView.h
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 5/19/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"
#import "MPNativeAdRequest.h"

#define NATIVE_MOPUB_KEY    @"561f62121ccc4125a525205f537b92f5"

#define NATIVE_AD_SQUARE_SIZE   CGSizeMake(320,300)

@interface MPNativeAdView : UIView <MPNativeAdRendering>

@property (assign, nonatomic) UILabel *titleLabel;
@property (assign, nonatomic) UILabel *mainTextLabel;
@property (assign, nonatomic) UIButton *callToActionButton;
@property (assign, nonatomic) UIImageView *iconImageView;
@property (assign, nonatomic) UIImageView *mainImageView;
@property (assign, nonatomic) UIViewController *rootViewController;

@property (nonatomic, retain) MPNativeAdRequest *currentAdRequest;
@property (nonatomic, retain) MPNativeAd *currentAdObject;

@property (nonatomic, assign) BOOL bIsNativeAdFetchedSuccessful;

- (void) startNewNativeAdRequest;

@end
