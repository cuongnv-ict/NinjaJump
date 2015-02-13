//
//  V4VCBonusManager.m
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 7/10/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import "V4VCBonusManager.h"
#import "V4VCAlertView.h"
#import "V4VCAlertDetailText.h"

/**
 * Here we define number bonus point will be added per each view,
 * total number point is request to upgrade to Pro Version
 */

#define PRO_UPGRADE_TOTAL_POINT_REQUIRED    20000
#define NUMBER_BONUS_POINT_PER_VIEW         200

/**
 *  Thời gian được hưởng nâng cấp bản pro khi click du quang cao
 */
#define PRO_UPGRADE_VALID_DURATION_IN_SECOND                60*60*24*30*1

/*
 *  Đơn vị tính điểm : vd Điểm, Point, Coint, Gem, Karma, ...
 */
#define BONUS_POINT_SYMBOL                  @"Karma"

#define kCurrentTotalPointEarned            @"CurrentTotalPointErned"

@implementation V4VCBonusManager

+ (int) getProVersionRequiredNumberPoint
{
    int numberPointRequired = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    numberPointRequired = [[defaults objectForKey:kProUpgradePointRequired] intValue];
    
    if (numberPointRequired <= 0) numberPointRequired = PRO_UPGRADE_TOTAL_POINT_REQUIRED;
    
    return numberPointRequired;
}

+ (int) getNumberBonusPointPerView
{
    int numberPointPerView = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    numberPointPerView = [[defaults objectForKey:kProUpgradePointBonusPerView] intValue];
    
    if (numberPointPerView <= 0) numberPointPerView = NUMBER_BONUS_POINT_PER_VIEW;
    
    return numberPointPerView;
}

+ (int) getProUpgradeBonusDuration
{
    int bonusDuration = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bonusDuration = [[defaults objectForKey:kProUpgradeDurationBonus] intValue];
    if (bonusDuration <= 0) bonusDuration = PRO_UPGRADE_VALID_DURATION_IN_SECOND;
    return bonusDuration;
}

+ (NSString*) getBonusPointSymbol
{
    return BONUS_POINT_SYMBOL;
}

+ (int) getCurrentTotalBonusPoint
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int numberPoint = [[defaults objectForKey:kCurrentTotalPointEarned] intValue];
    if (numberPoint < 0) numberPoint = 0;
    if (numberPoint > [V4VCBonusManager getProVersionRequiredNumberPoint]) numberPoint = [V4VCBonusManager getProVersionRequiredNumberPoint];
    return numberPoint;
}

+ (void) setProVersionRequiredNumberPoint:(int)pointRequired
{
    int numberPointRequired = pointRequired;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (numberPointRequired <= 0) numberPointRequired = PRO_UPGRADE_TOTAL_POINT_REQUIRED;
    [defaults setObject:[NSNumber numberWithInt:numberPointRequired] forKey:kProUpgradePointRequired];
    [defaults synchronize];
}

+ (void) setNumberBonusPointPerView:(int)pointBonus
{
    int numberPointPerView = pointBonus;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (numberPointPerView <= 0) numberPointPerView = NUMBER_BONUS_POINT_PER_VIEW;
    [defaults setObject:[NSNumber numberWithInt:numberPointPerView] forKey:kProUpgradePointBonusPerView];
    [defaults synchronize];
}

+ (void) setProUpgradeBonusDuration:(int)duration
{
    int bonusDuration = duration;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (bonusDuration <= 0) bonusDuration = PRO_UPGRADE_VALID_DURATION_IN_SECOND;
    [defaults setObject:[NSNumber numberWithInt:bonusDuration] forKey:kProUpgradeDurationBonus];
    [defaults synchronize];
}

+ (void) addBonusPoint:(int)addedPoint
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int currentNumberPoint = [[defaults objectForKey:kCurrentTotalPointEarned] intValue];
    
    if (currentNumberPoint < 0) currentNumberPoint = 0;
    currentNumberPoint += addedPoint;
    if (currentNumberPoint > [V4VCBonusManager getProVersionRequiredNumberPoint]) currentNumberPoint = [V4VCBonusManager getProVersionRequiredNumberPoint];
    
    [defaults setObject:[NSNumber numberWithInt:currentNumberPoint] forKey:kCurrentTotalPointEarned];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCurrentBonusPointHasChanged object:nil];
}

+ (void) resetBonusPointToOriginalValue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   
    [defaults setObject:[NSNumber numberWithInt:0] forKey:kCurrentTotalPointEarned];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCurrentBonusPointHasChanged object:nil];
}


+ (void) addBonusPointForWatchingVideoOrClickOnAd
{
    [V4VCBonusManager addBonusPoint:[V4VCBonusManager getNumberBonusPointPerView]];
    
    //// Check if user collect enough point to upgrade to PRO version
    if ([V4VCBonusManager isProVersionRequiredPointArchived])
    {
        //// Hiện thị Form Pro Upgraded
        NSString* titleText = [V4VCAlertDetailText getTitleTextOfType:V4VC_ALERT_TYPE_PRO_UPGRADED];
        NSString* messageText = [V4VCAlertDetailText getMessageTextOfType:V4VC_ALERT_TYPE_PRO_UPGRADED];
        NSString* leftButtonText = [V4VCAlertDetailText getLeftButtonTextOfType:V4VC_ALERT_TYPE_PRO_UPGRADED];
        NSString* rightButtonText = [V4VCAlertDetailText getRightButtonTextOfType:V4VC_ALERT_TYPE_PRO_UPGRADED];
        
        V4VCAlertView *alert = [[V4VCAlertView alloc] initWithTitle:titleText contentText:messageText leftButtonTitle:leftButtonText rightButtonTitle:rightButtonText autoDismiss:NO];
        
        [alert performSelector:@selector(show) withObject:nil afterDelay:1.0f];
        alert.rightBlock = ^()
        {
            NSLog(@"MP: OK button clicked");
        };
        alert.dismissBlock = ^()
        {
            NSLog(@"MP: Do something interesting after dismiss block");
        };
        
        
        //// You now is upgraded to PRO version
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDate date] forKey:kDateUpgradedToProVersion];
        [defaults synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyProUpgradeRequiredPointArchived object:nil];
    }
    else
    {
        //// Hiện thị Form Bonus Received chi có 1 nút OK
        NSString* titleText = [V4VCAlertDetailText getTitleTextOfType:V4VC_ALERT_TYPE_BONUS_RECEIVED];
        NSString* messageText = [V4VCAlertDetailText getMessageTextOfType:V4VC_ALERT_TYPE_BONUS_RECEIVED];
        NSString* leftButtonText = [V4VCAlertDetailText getLeftButtonTextOfType:V4VC_ALERT_TYPE_BONUS_RECEIVED];
        NSString* rightButtonText = [V4VCAlertDetailText getRightButtonTextOfType:V4VC_ALERT_TYPE_BONUS_RECEIVED];
        
        V4VCAlertView *alert = [[V4VCAlertView alloc] initWithTitle:titleText contentText:messageText leftButtonTitle:leftButtonText rightButtonTitle:rightButtonText autoDismiss:YES];
        
        [alert performSelector:@selector(show) withObject:nil afterDelay:1.0f];
        alert.rightBlock = ^()
        {
            NSLog(@"MP: OK button clicked");
        };
        alert.dismissBlock = ^()
        {
            NSLog(@"MP: Do something interesting after dismiss block");
        };
    }
}

+ (BOOL) isProVersionRequiredPointArchived
{
    /**
     * Tại thời điểm này cần kiểm tra rõ các trường hợp sau:
     *  1. Nếu chưa tồn tại ngày nâng cấp kDateUpgradedToProVersion, thì kiểm tra bình thường
     *  2. Nếu đã tồn tại ngày nâng cấp kDateUpgradedToProVersion, thì kiểm tra đến ngày hiện tại đã đủ thời gian thưởng chưa:
     *      + Nếu chưa đủ, kiểm tra bình thường
     *      + Nếu đã đủ, trừ 2000 điểm hiện tại, và remove ngày nâng cấp kDateUpgradedToProVersion đi
    */
    int currentTotalPointBonus = [V4VCBonusManager getCurrentTotalBonusPoint];
    int numberPointRequiredForProUpgrade = [V4VCBonusManager getProVersionRequiredNumberPoint];
    
    if (currentTotalPointBonus >= numberPointRequiredForProUpgrade)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate* upgradedDate = [defaults objectForKey:kDateUpgradedToProVersion];
        if (upgradedDate)
        {
            NSTimeInterval passedTimeFromUpgradingDate = [[NSDate date] timeIntervalSinceDate:upgradedDate];
            NSLog(@"Passed time in second: %f",passedTimeFromUpgradingDate);
            if (passedTimeFromUpgradingDate >= [V4VCBonusManager getProUpgradeBonusDuration])
            {
                //// Invalidate pro upgraded version, reset to original state and alert to user about this change
                [defaults removeObjectForKey:kDateUpgradedToProVersion];
                [defaults synchronize];
                
                [V4VCBonusManager resetBonusPointToOriginalValue];
                
                //// Hiện thị Form Pro Upgrading Expired
                NSString* titleText = [V4VCAlertDetailText getTitleTextOfType:V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED];
                NSString* messageText = [V4VCAlertDetailText getMessageTextOfType:V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED];
                NSString* leftButtonText = [V4VCAlertDetailText getLeftButtonTextOfType:V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED];
                NSString* rightButtonText = [V4VCAlertDetailText getRightButtonTextOfType:V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED];
                
                V4VCAlertView *alert = [[V4VCAlertView alloc] initWithTitle:titleText contentText:messageText leftButtonTitle:leftButtonText rightButtonTitle:rightButtonText autoDismiss:NO];
                
                [alert show];
                alert.rightBlock = ^()
                {
                    NSLog(@"MP: OK button clicked");
                };
                alert.dismissBlock = ^()
                {
                    NSLog(@"MP: Do something interesting after dismiss block");
                };
                
                //// Send Notification outside to inform that Pro Upgrade Duration has passed
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyProUpgradeDurationHasPassed object:nil];
            }
        }
    }
    
    return currentTotalPointBonus >= numberPointRequiredForProUpgrade;
}

@end
