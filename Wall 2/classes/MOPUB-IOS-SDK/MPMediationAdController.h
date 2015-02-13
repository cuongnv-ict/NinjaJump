//
//  MPMediationAdController.h
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 6/13/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdNetworkKeyConfig.h"

#import "V4VCAlertView.h"
#import "V4VCBonusManager.h"
#import "V4VCAlertDetailText.h"

//// Mopub
#import "MPAdView.h"
#import "MPInterstitialAdController.h"

//// Adconoly
#import <AdColony/AdColony.h>

//// Vungle
#import <VungleSDK/VungleSDK.h>

//// Other Network: Admob, MMedia, StartApp
#import "GADBannerView.h"
#import "GADInterstitial.h"

//#import "STAStartAppSDK.h"
//#import "STAStartAppAd.h"
//#import "STABannerSize.h"
//#import "STABannerView.h"

//#import "CleverNetDelegationProtocol.h"

typedef enum
{
    PRODUCT_INAPP_TYPE_FREE = 1,
    PRODUCT_INAPP_TYPE_PAID = 2
} PRODUCT_INAPP_TYPE;

@interface MPMediationAdController : UIViewController <MPAdViewDelegate,MPInterstitialAdControllerDelegate,
                                                        AdColonyAdDelegate,AdColonyDelegate,
                                                        VungleSDKDelegate,
                                                        //STADelegateProtocol,STABannerDelegagteProtocol,
                                                        GADBannerViewDelegate,GADInterstitialDelegate/*,
                                                        CleverNetDelegationProtocol*/>

/**
 *  Khi thêm banner ad vào view nào đó, không add thêm mp_adView mà thêm bannerAdView.
 *  View trung gian này nhằm giúp chỉnh lại vị trí banner ad khi kích thước trả về có giá trị khác nhau (vd banner ad trên ipad).
 */
@property (nonatomic, strong) UIView *bannerAdView;

/**
 *  Khi người dùng tap vào banner ad, trang quảng cáo sẽ bung lên dạng modal view, và cần truyền một rootviewcontroller cho nó.
 *  Thông thường chọn rootviewcontroller là viewcontroller đang ở top view.
 */
@property (nonatomic, weak) UIViewController *rootViewControllerBannerAd;

////////// INTERSTITIAL AD //////////////
/**
 *  MPInterstitialAdController là quảng cáo fullscreen.
 *  Khi fullscreen ad bung lên theo dạng modal view, cần chọn cho nó rootviewconller. Cũng tương tự như banner ad.
 */
@property (nonatomic, weak) UIViewController *rootViewControllerFullscreenAd;

/////////// PRO VERSION UPGRADE POINT SYSTEM ///
/**
 *  Enable/Disable Adding bonus point to upgrade to ProVersion when user watch ad video or click on Ads
 *  Default là NO : Tắt.
*/
@property (nonatomic) BOOL enableBonusPointForWatchingVideoMode;


/**
 * Ad Management Singleton
 */
+ (MPMediationAdController *)sharedManager;

/**
 *  Khởi tạo ad manager, gọi chỉ 1 lần.
 *   - bannerAdRootView : base viewcontroller mà banner Ad nhận làm root view, khi click vào banner, cửa sổ pop up sẽ bung lên từ đây
 *   - fullscreenAdRootView : viewcontroller mà fullscreen Ad nhận làm root view, khi click vào fullscreen ad, cửa sổ pop up sẽ bung lên từ đây
 */
- (id) init __attribute__((deprecated));

/**
 *  Hàm này kiểm tra xem có đang trong thời gian bonus hoặc nâng cấp Pro không, nếu có thì quảng cáo sẽ không được hiện, khi đó hàm trả về NO
 */
- (BOOL) shouldShowBannerAdsAtTheMoment;
- (BOOL) shouldShowFullScreenAdsAtTheMoment;


/**
 *  Các hàm ẩn/hiện quảng cáo banner. bBannerAdIsShowing trả về YES khi quảng cáo banner đang được hiện, NO trong trường hợp còn lại.
 */
- (void) showBannerAd;
- (void) hideBannerAd;
- (BOOL) bBannerAdIsShowing;
- (CGSize)getAdBannerCGSize;
/////////// FULSCREEN AD HANDLE ////////

- (BOOL) isInterstitialAdAvailable;
/**
 *  Hàm gọi hiển thị quảng cáo to (adconoly & interstitial) theo cách thông thường, tức là có xét đến các tham số từ server
 *  hàm này gọi mỗi khi từ App muốn bật quảng cáo khi kết thúc 1 sự kiện. Nếu gọi rồi mà vẫn đang trong giai đoạn bonus quảng cáo - 
 *  (phụ thuộc tham số trên server) thì quảng cáo sẽ ko hiện.
 */
- (bool) logEventToShowFullscreenAd;

/**
 *  Bắt hiển thị video/fullscreen Ad mà không cần quan tâm đến các điều kiện & tham số từ server,
 *  Hàm này gọi khi người dùng nhất vào nút <Xem video để lấy điểm thưởng>
 */
- (void) forceFullscreenAdToBeShow;

/**
 *  Call this function whenever WatchVideo Promt could be presented on the screen, 
 *  for example: top watching a tv channel, move between views,...
 *  Watch video promt will be show if the time from the last promt is more than MIN_DURATION_TO_THE_NEXT_WATCH_VIDEO_PROMT
 */
- (void) logEventToShowWatchVideoPromt;

/**
 *  Force Watch video promt to be show
 */
- (void) forceWatchVideoPromtToBeShow;

/**
 *  Hàm kiểm tra và show video mà người dùng chủ động xem để được nhận thưởng (coin, gems, time bonus, ...)
 *  Note: don't forget to check delegate callback function to make sure if user watched video completely
 */
- (BOOL) isV4VCVideoAvailable;
- (void) playV4VCVideo;

/**
 *  Thông báo cho adcontroller biết rằng app đã in-app purchased hay chưa.
 *  Gọi hàm này ngay khi khởi tạo adcontroller, và khi user mua in-app thành công, hoặc restore previous purchase thành công.
 *  Nếu quên gọi hàm này, khả năng app vẫn sẽ hiện quảng cáo như bản free.
 */
- (void) setProductType:(PRODUCT_INAPP_TYPE)productType;

@end
