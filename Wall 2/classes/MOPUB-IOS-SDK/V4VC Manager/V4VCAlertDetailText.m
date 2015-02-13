//
//  V4VCAlertDetailText.m
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 8/7/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import "V4VCAlertDetailText.h"
#import "LocalizationSystem.h"
#import "V4VCBonusManager.h"

@implementation V4VCAlertDetailText

+ (NSString*) getTitleTextOfType:(V4VC_ALERT_TYPE)alertType
{
    if ([LocalizationGetLanguage isEqualToString:@"vi"])
    {
        //// Tiếng Việt
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"Xin chúc mừng!";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"Thông báo!";
                break;
                
            default:
                break;
        }
    }
    else if ([LocalizationGetLanguage isEqualToString:@"ru"])
    {
        //// Tiếng Nga
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"Congratulation!";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"";
                break;
                
            default:
                break;
        }
    }
    else
    {
        //// Mặc định là tiếng Anh
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"Congratulation!";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"";
                break;
                
            default:
                break;
        }
    }
    
    return nil;
}

+ (NSString*) getMessageTextOfType:(V4VC_ALERT_TYPE)alertType
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int timeFreeAdBonusWhenClickOnAdInMinutes = [[defaults objectForKey:@"V4VCAdFreeTimeIntervalBonus"] intValue]/60;
    
    if ([LocalizationGetLanguage isEqualToString:@"vi"])
    {
        //// Tiếng Việt
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return [NSString stringWithFormat:@"Xem quảng cáo để được tặng %d điểm và sẽ không có thêm quảng cáo trong %d phút.",[V4VCBonusManager getNumberBonusPointPerView],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return [NSString stringWithFormat:@"+ Bạn đã tích lũy được %d điểm, khi tích lũy đủ %d điểm sẽ được nâng cấp lên bản PRO không có quảng cáo.\n+ Xem quảng cáo để được tặng %d điểm và sẽ không có thêm quảng cáo trong %d phút.",[V4VCBonusManager getCurrentTotalBonusPoint],[V4VCBonusManager getProVersionRequiredNumberPoint],[V4VCBonusManager getNumberBonusPointPerView],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return [NSString stringWithFormat:@"+ Bạn đã tích lũy được thêm %d điểm\n+ Số điểm hiện tại của bạn là %d\n+ Hãy tích đủ %d điểm để nâng cấp lên phiên bản Pro không có quảng cáo.\n+ Quảng cáo sẽ không hiện trong %d phút.",[V4VCBonusManager getNumberBonusPointPerView],[V4VCBonusManager getCurrentTotalBonusPoint],[V4VCBonusManager getProVersionRequiredNumberPoint],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return [NSString stringWithFormat:@"Bạn đã tích lũy đủ %d điểm và được nâng cấp lên phiên bản Pro không có quảng cáo trong %d tháng.",[V4VCBonusManager getProVersionRequiredNumberPoint],[V4VCBonusManager getProUpgradeBonusDuration]/(60*60*24*30)];
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return [NSString stringWithFormat:@"+ Thời gian bạn hưởng khuyến mại bản Pro đã hết. Version hiện tại bạn sử dụng là bản Free.\n+ Hãy tiếp tục tích đủ %d điểm để nâng cấp lên phiên bản Pro không có quảng cáo.",[V4VCBonusManager getProVersionRequiredNumberPoint]];
                break;
                
            default:
                break;
        }
    }
    else if ([LocalizationGetLanguage isEqualToString:@"ru"])
    {
        //// Tiếng Nga
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return [NSString stringWithFormat:@"Watch video to get %d points and feel free from Ads for %d minutes",[V4VCBonusManager getNumberBonusPointPerView],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return [NSString stringWithFormat:@"+ You have archived %d points, get %d points to upgrade to Pro Version with no Ads.\n+ Watch video to get %d points and feel free from Ads for %d minutes.",[V4VCBonusManager getCurrentTotalBonusPoint],[V4VCBonusManager getProVersionRequiredNumberPoint],[V4VCBonusManager getNumberBonusPointPerView],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return [NSString stringWithFormat:@"+ You have earned %d points more\n+ Your total earned points: %d\n+ Get %d points to upgrade to Pro Version with no Ads.\n+ Ads will not show again for %d minutes from now.",[V4VCBonusManager getNumberBonusPointPerView],[V4VCBonusManager getCurrentTotalBonusPoint],[V4VCBonusManager getProVersionRequiredNumberPoint],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return [NSString stringWithFormat:@"You earned enough %d points. App have been upgraded to Pro Version with no Ads for %d months.",[V4VCBonusManager getProVersionRequiredNumberPoint],[V4VCBonusManager getProUpgradeBonusDuration]/(60*60*24*30)];
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return [NSString stringWithFormat:@"+ Your Pro Upgrading Duration has been passed. You now use Free Version.\n+ Let's earn more %d points to upgrade to Pro Version again.",[V4VCBonusManager getProVersionRequiredNumberPoint]];
                break;
                
            default:
                break;
        }
    }
    else
    {
        //// Mặc định là tiếng Anh
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return [NSString stringWithFormat:@"Watch video to get %d points and feel free from Ads for %d minutes",[V4VCBonusManager getNumberBonusPointPerView],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return [NSString stringWithFormat:@"+ You have archived %d points, get %d points to upgrade to Pro Version with no Ads.\n+ Watch video to get %d points and feel free from Ads for %d minutes.",[V4VCBonusManager getCurrentTotalBonusPoint],[V4VCBonusManager getProVersionRequiredNumberPoint],[V4VCBonusManager getNumberBonusPointPerView],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return [NSString stringWithFormat:@"+ You have earned %d points more\n+ Your total earned points: %d\n+ Get %d points to upgrade to Pro Version with no Ads.\n+ Ads will not show again for %d minutes from now.",[V4VCBonusManager getNumberBonusPointPerView],[V4VCBonusManager getCurrentTotalBonusPoint],[V4VCBonusManager getProVersionRequiredNumberPoint],timeFreeAdBonusWhenClickOnAdInMinutes];
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return [NSString stringWithFormat:@"You earned enough %d points. App have been upgraded to Pro Version with no Ads for %d months.",[V4VCBonusManager getProVersionRequiredNumberPoint],[V4VCBonusManager getProUpgradeBonusDuration]/(60*60*24*30)];
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return [NSString stringWithFormat:@"+ Your Pro Upgrading Duration has been passed. You now use Free Version.\n+ Let's earn more %d points to upgrade to Pro Version again.",[V4VCBonusManager getProVersionRequiredNumberPoint]];
                break;
                
            default:
                break;
        }
    }
    
    return nil;
}

+ (NSString*) getLeftButtonTextOfType:(V4VC_ALERT_TYPE)alertType
{
    
    if ([LocalizationGetLanguage isEqualToString:@"vi"])
    {
        //// Tiếng Việt
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"Chi tiết";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"";
                break;
                
            default:
                break;
        }
    }
    else if ([LocalizationGetLanguage isEqualToString:@"ru"])
    {
        //// Tiếng Nga
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"Detail";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"";
                break;
                
            default:
                break;
        }
    }
    else
    {
        //// Mặc định là tiếng Anh
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"Detail";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"";
                break;
                
            default:
                break;
        }
    }
    
    return nil;
}

+ (NSString*) getRightButtonTextOfType:(V4VC_ALERT_TYPE)alertType
{
    
    if ([LocalizationGetLanguage isEqualToString:@"vi"])
    {
        //// Tiếng Việt
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"Xem ngay";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"Xem ngay";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"Đóng lại";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"Đóng lại";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"Đóng lại";
                break;
                
            default:
                break;
        }
    }
    else if ([LocalizationGetLanguage isEqualToString:@"ru"])
    {
        //// Tiếng Nga
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"Watch now";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"Watch now";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"OK";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"OK";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"OK";
                break;
                
            default:
                break;
        }
    }
    else
    {
        //// Mặc định là tiếng Anh
        switch (alertType) {
            case V4VC_ALERT_TYPE_INFO:
                return @"Watch now";
                break;
                
            case V4VC_ALERT_TYPE_DETAIL:
                return @"Watch now";
                break;
                
            case V4VC_ALERT_TYPE_BONUS_RECEIVED:
                return @"OK";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADED:
                return @"OK";
                break;
                
            case V4VC_ALERT_TYPE_PRO_UPGRADING_EXPIRED:
                return @"OK";
                break;
                
            default:
                break;
        }
    }
    
    return nil;
}


+ (NSString*) getCurrentPointText
{
    if ([LocalizationGetLanguage isEqualToString:@"vi"])
    {
        //// Tiếng Việt
        return @"ĐIỂM HIỆN TẠI";
    }
    else if ([LocalizationGetLanguage isEqualToString:@"ru"])
    {
        //// Tiếng Nga
        return @"TOTAL EARNED POINTS";
    }
    else
    {
        //// Mặc định là tiếng Anh
        return @"TOTAL EARNED POINTS";
    }

    return nil;
}

+ (NSString*) getEarnMorePointText
{
    if ([LocalizationGetLanguage isEqualToString:@"vi"])
    {
        //// Tiếng Việt
        return @"Thêm điểm";
    }
    else if ([LocalizationGetLanguage isEqualToString:@"ru"])
    {
        //// Tiếng Nga
        return @"Earn more";
    }
    else
    {
        //// Mặc định là tiếng Anh
        return @"Earn more";
    }

    return nil;
}

+ (NSString*) getProUpgradedText
{
    if ([LocalizationGetLanguage isEqualToString:@"vi"])
    {
        //// Tiếng Việt
        return @"Bạn đang trong thời gian hưởng nâng cấp bản Pro không có quảng cáo.";
    }
    else if ([LocalizationGetLanguage isEqualToString:@"ru"])
    {
        //// Tiếng Nga
        return @"You are in Pro Upgrading Bonus time. No Ads will show at this time.";
    }
    else
    {
        //// Mặc định là tiếng Anh
        return @"You are in Pro Upgrading Bonus time. No Ads will show at this time.";
    }

    return nil;
}

@end
