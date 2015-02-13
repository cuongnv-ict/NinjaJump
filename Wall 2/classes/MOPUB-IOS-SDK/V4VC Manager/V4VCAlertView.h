//
//  V4VCAlertView.h
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 7/11/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import <UIKit/UIKit.h>


//localisation string keys
static NSString *const v4vcInfoViewTitleKey         = @"v4vcInfoViewTitle";
static NSString *const v4vcInfoViewMessageKey       = @"v4vcInfoViewMessage";
static NSString *const v4vcInfoViewLeftButtonKey    = @"v4vcInfoViewLeftButton";
static NSString *const v4vcInfoViewRightButtonKey   = @"v4vcInfoViewRightButton";

static NSString *const v4vcDetailViewTitleKey         = @"v4vcDetailViewTitle";
static NSString *const v4vcDetailViewMessageKey       = @"v4vcDetailViewMessage";
static NSString *const v4vcDetailViewLeftButtonKey    = @"v4vcDetailViewLeftButton";
static NSString *const v4vcDetailViewRightButtonKey   = @"v4vcDetailViewRightButton";

static NSString *const v4vcBonusReceivedTitleKey         = @"v4vcBonusReceivedTitle";
static NSString *const v4vcBonusReceivedMessageKey       = @"v4vcBonusReceivedMessage";
static NSString *const v4vcBonusReceivedLeftButtonKey    = @"v4vcBonusReceivedLeftButton";
static NSString *const v4vcBonusReceivedRightButtonKey   = @"v4vcBonusReceivedRightButton";

static NSString *const v4vcProUpgradedTitleKey         = @"v4vcProUpgradedTitle";
static NSString *const v4vcProUpgradedMessageKey       = @"v4vcProUpgradedMessage";
static NSString *const v4vcProUpgradedLeftButtonKey    = @"v4vcProUpgradedLeftButton";
static NSString *const v4vcProUpgradedRightButtonKey   = @"v4vcProUpgradedRightButton";


static NSString *const v4vcProUpgradingExpiredTitleKey         = @"v4vcProUpgradingExpiredTitle";
static NSString *const v4vcProUpgradingExpiredMessageKey       = @"v4vcProUpgradingExpiredMessage";
static NSString *const v4vcProUpgradingExpiredLeftButtonKey    = @"v4vcProUpgradingExpiredLeftButton";
static NSString *const v4vcProUpgradingExpiredRightButtonKey   = @"v4vcProUpgradingExpiredRightButton";


@interface V4VCAlertView : UIView

- (id)initWithTitle:(NSString *)title
        contentText:(NSString *)content
    leftButtonTitle:(NSString *)leftTitle
   rightButtonTitle:(NSString *)rigthTitle;

- (id)initWithTitle:(NSString *)title
        contentText:(NSString *)content
    leftButtonTitle:(NSString *)leftTitle
   rightButtonTitle:(NSString *)rigthTitle
        autoDismiss:(BOOL)autoDismiss;

- (void)show;

//// Action blocks
@property (nonatomic, copy) dispatch_block_t leftBlock;
@property (nonatomic, copy) dispatch_block_t rightBlock;
@property (nonatomic, copy) dispatch_block_t dismissBlock;


@end

@interface UIImage (colorful)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
