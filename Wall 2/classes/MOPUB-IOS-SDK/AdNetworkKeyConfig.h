//
//  AdNetworkKeyConfig.h
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 7/7/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#ifndef Mopub_Sample_AdNetworkKeyConfig_h
#define Mopub_Sample_AdNetworkKeyConfig_h

#if __TESTMODE__

////////// DEFAULT KEY FOR TEST ///////////
#define ADCONOLY_APP_ID                     @"app81a5fb046cd64a12a0"
#define ADCONOLY_ZONE_ID                    @"vz8cd0d8df81774ae88c"
//
//#define ADCONOLY_APP_ID                     @"app23ded9cacfe04178b1"
//#define ADCONOLY_ZONE_ID                    @"vz8d133e760b4a4db8ba"

#define VUNGLE_APP_ID                       @"53fd5fdd8694acfd17000016"

#define kAdmobBannerMediationID             @"ca-app-pub-4154334692952403/3683185772"
#define kAdmobInterstitialMediationID       @"ca-app-pub-4154334692952403/5159918974"

#define MOPUB_AD_BANNER_IPHONE_KEY          @"0ff5eff3a95b43c88eaa8a2d8abc51b4"
#define MOPUB_AD_BANNER_IPAD_KEY            @"cb643476df7040dca19f6e59388ae426"
#define MOPUB_AD_INTERSTITIAL_IPHONE_KEY    @"c454913ecef24c3dbd27f5aea74e4fa3"
#define MOPUB_AD_INTERSTITIAL_IPAD_KEY      @"5e9d9332504d4cca9d768cdbebdc642a"

#define kStartAppApplicationID              @"206322466"
#define kStartAppDeveloperID                @"106242227"

#define kCleverNetAppID                      @"TEST_BANNER_MMA"

#else

#import "PrivateAdKey.h"

/**********************************
/* CHÚ Ý: 
 + Cần tạo file PrivateAdKey.h, chứa những key quảng cáo riêng của sản phẩm hiện tại. File này KHÔNG được để trong thư mục chứa module quảng cáo.
 + Mục đích: để khi thay module quảng cáo mới, có thể copy - past đè cả Module quảng cáo, nhưng file PrivateAdKey.h sẽ không bị ảnh hưởng, và key
 quảng cáo vẫn được giữ nguyên.
 + Vd nội dung file PrivateAdKey.h có thể như sau <chú ý nhớ thay key thật của từng app tương ứng vào>:
 
/////////// KEY riêng của mỗi sản phẩm  ///////
#define ADCONOLY_APP_ID                     @"app81a5fb046cd64a12a0"
#define ADCONOLY_ZONE_ID                    @"vzc8b2b9d198874a19ac"

#define VUNGLE_APP_ID                       @"53ba08326e325bea6500002f"

#define kAdmobBannerMediationID             @"ca-app-pub-1403873600040672/6515971741"
#define kAdmobInterstitialMediationID       @"ca-app-pub-1403873600040672/7992704948"

#define MOPUB_AD_BANNER_IPHONE_KEY          @"0ff5eff3a95b43c88eaa8a2d8abc51b4"
#define MOPUB_AD_BANNER_IPAD_KEY            @"cb643476df7040dca19f6e59388ae426"
#define MOPUB_AD_INTERSTITIAL_IPHONE_KEY    @"c454913ecef24c3dbd27f5aea74e4fa3"
#define MOPUB_AD_INTERSTITIAL_IPAD_KEY      @"5e9d9332504d4cca9d768cdbebdc642a"

#define kStartAppApplicationID              @"206322466"
#define kStartAppDeveloperID                @"106242227"

#define kCleverNetAppID                     @"7a266402ce2c1f100849c6f6c6a9b648"
 *********************************/

#endif




/**
 *  Sử dụng các notifications dưới đây để biết trạng thái (loading/ready) của quảng cáo interstitial/video.
 *  thao tác của người dùng: click vào banner ad, interstitial, hoặc xem đầy đủ ad video.
 */

#define kNotifyMPBannerAdViewStartAutoRefresh       @"MPBannerAdViewStartAutoRefresh"
#define kNotifyMPBannerAdViewDidLoadAdSuccessful    @"MPBannerAdViewDidLoadAdSuccessful"

//// Notifications when show/hide modal view after user click on ad
#define kNotifyMPBannerAdViewWillPresentModalView   @"MPBannerAdViewWillPresentModalView"
#define kNotifyMPBannerAdViewWillDismissModalView   @"MPBannerAdViewWillDismissModalView"
#define kNotifyMPBannerAdViewWillLeaveAppFromAd     @"MPBannerAdViewWillLeaveAppFromAd"


//// Notifications for interstitial ad checking avaibility
#define kNotifyInterstitialOff              @"NotifyInterstitialOff"
#define kNotifyInterstitialLoading          @"NotifyInterstitialLoading"
#define kNotifyInterstitialReady            @"NotifyInterstitialReady"


//// Notifications for Show/Hide interstitial Ads, khi user tap vào quảng cáo
#define kInterstitialAdWillAppear       @"InterstitialAdWillAppear"
#define kInterstitialAdWillDissappear   @"InterstitialAdWillDissappear"
#define kInterstitialAdDidTap          @"InterstitialAdDidTap"


//// Notifications bắn về khi trạng thái Off/Loading/Ready của V4VC video thay đổi
#define kV4VCZoneLoading                @"V4VCZoneLoading"
#define kV4VCZoneReady                  @"V4VCZoneReady"
#define kV4VCZoneOff                    @"V4VCZoneOff"


//// Notifications when start playing ad video, stop playing ad video
//// Riêng notify kFinishV4VCVideoWatching có kèm tham số [NSNumber numberWithBool:YES/NO],
//// YES : video đươc xem hết -> được cộng điểm, NO: user skip video -> không được cộng điểm
#define kStartV4VCVideoWatching         @"StartV4VCWatching"
#define kFinishV4VCVideoWatching        @"FinishV4VCWatching"

#define kNotifyFullscreenAdIsForcedToBeShow @"FullscreenAdIsForcedToBeShow"

#endif
