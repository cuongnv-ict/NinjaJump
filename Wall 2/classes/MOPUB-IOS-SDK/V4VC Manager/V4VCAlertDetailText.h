//
//  V4VCAlertDetailText.h
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 8/7/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    V4VC_ALERT_TYPE_INFO = 0,
    V4VC_ALERT_TYPE_DETAIL = 1,
    V4VC_ALERT_TYPE_BONUS_RECEIVED = 2,
    V4VC_ALERT_TYPE_PRO_UPGRADED = 3,
    V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED = 4,
    V4VC_ALERT_TYPE_UNKNOW
} V4VC_ALERT_TYPE;

@interface V4VCAlertDetailText : NSObject

+ (NSString*) getTitleTextOfType:(V4VC_ALERT_TYPE)alertType;
+ (NSString*) getMessageTextOfType:(V4VC_ALERT_TYPE)alertType;
+ (NSString*) getLeftButtonTextOfType:(V4VC_ALERT_TYPE)alertType;
+ (NSString*) getRightButtonTextOfType:(V4VC_ALERT_TYPE)alertType;

+ (NSString*) getCurrentPointText;
+ (NSString*) getEarnMorePointText;
+ (NSString*) getProUpgradedText;


@end
