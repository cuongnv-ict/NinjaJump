//
//  V4VCBonusManager.h
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 7/10/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This notifi is send when user current point has changed
 */
#define kNotifyCurrentBonusPointHasChanged          @"CurrentBonusPointHasChanged"

/**
 *  This notify that user has collected enough requirec point to upgrade to Pro version
 */
#define kNotifyProUpgradeRequiredPointArchived      @"ProUpgradeRequiredPointArchived"
#define kNotifyProUpgradeDurationHasPassed          @"ProUpgradeDurationHasPassed"
#define kDateUpgradedToProVersion                   @"DateUpgradedToProVersion"

#define kProUpgradeDurationBonus                     @"kProUpgradeDurationBonus"
#define kProUpgradePointRequired                     @"kProUpgradePointRequired"
#define kProUpgradePointBonusPerView                 @"kProUpgradePointBonusPerView"

/**
 *  Thời gian giữa 2 lần bật thông báo xem video liên tiếp = 30 min
 */
#define MIN_DURATION_TO_THE_NEXT_WATCH_VIDEO_PROMT          60*30


@interface V4VCBonusManager : NSObject

+ (int) getProVersionRequiredNumberPoint;
+ (int) getCurrentTotalBonusPoint;
+ (int) getNumberBonusPointPerView;
+ (int) getProUpgradeBonusDuration;

+ (NSString*) getBonusPointSymbol;
+ (void) addBonusPoint:(int)numberPoint;
+ (void) addBonusPointForWatchingVideoOrClickOnAd;
+ (BOOL) isProVersionRequiredPointArchived;

+ (void) setProVersionRequiredNumberPoint:(int)pointRequired;
+ (void) setNumberBonusPointPerView:(int)pointBonus;
+ (void) setProUpgradeBonusDuration:(int)duration;

@end



///**
// * Define some text to show in specific situation
// */
//#define kV4VC_Info_View_Title                   @""
//#define kV4VC_Info_View_Message                 @"Xem quảng cáo để được tặng %d điểm và sẽ không có thêm quảng cáo trong một khoảng thời gian."
//#define kV4VC_Info_View_Left_Button_Text        @"Chi tiết"
//#define kV4VC_Info_View_Right_Button_Text       @"Xem ngay"
//
//#define kV4VC_Detail_View_Title                 @""
//#define kV4VC_Detail_View_Message               @"+ Bạn đã tích lũy được %d điểm, khi tích lũy đủ %d điểm sẽ được nâng cấp lên bản PRO không có quảng cáo.\
//\n+ Xem quảng cáo để được tặng %d điểm và sẽ không có thêm quảng cáo trong một khoảng thời gian."
//#define kV4VC_Detal_View_Right_Button_Text      @"Xem ngay"
//
//
//#define kV4VC_Bonus_Received_View_Title                   @"Xin chúc mừng!"
//#define kV4VC_Bonus_Received_View_Message                 @"+ Bạn đã tích lũy được thêm %d điểm\n+ Số điểm hiện tại của bạn là %d\n+ Hãy tích đủ %d điểm để nâng cấp lên phiên bản Pro không có quảng cáo.\n+ Quảng cáo sẽ không hiện trong 1 khoảng thời gian."
//#define kV4VC_Bonus_Received_View_Left_Button_Text        @""
//#define kV4VC_Bonus_Received_View_Right_Button_Text       @"Đóng lại"
//
//
//#define kV4VC_Pro_Upgrade_View_Title                   @""
//#define kV4VC_Pro_Upgrade_View_Message                 @"Xin chúc mừng! Bạn đã tích lũy đủ %d điểm và được nâng cấp lên phiên bản Pro không có quảng cáo."
//#define kV4VC_Pro_Upgrade_View_Left_Button_Text        @""
//#define kV4VC_Pro_Upgrade_View_Right_Button_Text       @"Đóng lại"
//
//
//#define kV4VC_PRO_UPGRADING_DURATION_PASSED_Title                   @"Thông báo!"
//#define kV4VC_PRO_UPGRADING_DURATION_PASSED_Message                 @"+ Thời gian bạn hưởng khuyến mại bản Pro đã hết. Version hiện tại bạn sử dụng là bản Free.\n+ Hãy tiếp tục tích đủ %d điểm để nâng cấp lên phiên bản Pro không có quảng cáo."
//#define kV4VC_PRO_UPGRADING_DURATION_PASSED_Left_Button_Text        @""
//#define kV4VC_PRO_UPGRADING_DURATION_PASSED_Right_Button_Text       @"Đóng lại"
