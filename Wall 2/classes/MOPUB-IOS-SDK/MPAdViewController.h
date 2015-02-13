//
//  MPAdViewController.h
//  VietTVPro
//
//  Created by HIEPLM on 02/20/14.
//
//

/**
 *  Current Mopub Version:    2.0.0
 *  Last modify:            24/04/2014
 */

#import <UIKit/UIKit.h>

#import "MPAdView.h"
#import "MPInterstitialAdController.h"
#import <AdColony/AdColony.h>


/**
 *  Default key TV IOS
 */

#define MOPUB_AD_BANNER_IPHONE_KEY          @"39c887caf2e64a23827aad8e4c7e745f"
#define MOPUB_AD_BANNER_IPAD_KEY            @"99b38ea89a774eea8e442aaaf3fad323"
#define MOPUB_AD_INTERSTITIAL_IPHONE_KEY    @"1d5e7ba43c2747b0ad846e0572a2467c"
#define MOPUB_AD_INTERSTITIAL_IPAD_KEY      @"cd91f098d29f43359ec361ed5c52d16c"


/**
 * DEFAULT TV IOS: ADCOLONY APP ID, ACTIVE ZONE & TEST ZONE
 */
#define ADCONOLY_APP_ID                     @"app95d9b99f3384462ba3"
#define ADCONOLY_ZONE_ID_ACTIVED            @"vzf1a0a75f36fc45ef96"
#define ADCONOLY_ZONE_ID_FOR_TEST           @"vz8f50bcb1284f4aa592"


///**
// *  Default key IOS
// */
//#define MOPUB_AD_BANNER_IPHONE_KEY          @"0ff5eff3a95b43c88eaa8a2d8abc51b4"
//#define MOPUB_AD_BANNER_IPAD_KEY            @"cb643476df7040dca19f6e59388ae426"
//#define MOPUB_AD_INTERSTITIAL_IPHONE_KEY    @"c454913ecef24c3dbd27f5aea74e4fa3"
//#define MOPUB_AD_INTERSTITIAL_IPAD_KEY      @"5e9d9332504d4cca9d768cdbebdc642a"
//
//
///**
// * DEFAULT IOS: ADCOLONY APP ID, ACTIVE ZONE & TEST ZONE
// */
//#define ADCONOLY_APP_ID                     @"app81a5fb046cd64a12a0"
//#define ADCONOLY_ZONE_ID_ACTIVED            @"vzc8b2b9d198874a19ac"
//#define ADCONOLY_ZONE_ID_FOR_TEST           @"vz8f50bcb1284f4aa592"

#define kNotificationBannerAdJustChangedVisibility  @"BannerAdChangedVisibility"

typedef enum
{
    PRODUCT_INAPP_TYPE_FREE = 1,
    PRODUCT_INAPP_TYPE_PAID = 2
} PRODUCT_INAPP_TYPE;

@class MPAdViewController;
@protocol MPAdViewControllerDelegate

@optional
- (void) updateMPAdBannerFrame;

- (void) mpAdBannerWillPresentModalView;
- (void) mpAdBannerWillDismissModalView;
- (void) mpAdBannerWillLeaveAppFromAd;
@end

@interface MPAdViewController : UIViewController <MPAdViewDelegate,MPInterstitialAdControllerDelegate,AdColonyAdDelegate,AdColonyDelegate>

/**
 *  Delegate chỉ tới controller sẽ nhận sự kiện callback (vd người dùng tap vào banner ad, khi người dùng đóng quảng cáo,..)
 */
@property (nonatomic, unsafe_unretained) id delegate;

/**
 *  Khi thêm banner ad vào view nào đó, không add thêm mp_adView mà thêm bannerAdView.
 *  View trung gian này nhằm giúp chỉnh lại vị trí banner ad khi kích thước trả về có giá trị khác nhau (vd banner ad trên ipad).
 */
@property (nonatomic, assign) UIView *bannerAdView;

/**
 *  Khi người dùng tap vào banner ad, trang quảng cáo sẽ bung lên dạng modal view, và cần truyền một rootviewcontroller cho nó.
 *  Thông thường chọn rootviewcontroller là viewcontroller đang ở top view.
 */
@property (nonatomic, unsafe_unretained) UIViewController *rootViewControllerBannerAd;

////////// INTERSTITIAL AD //////////////
/**
 *  MPInterstitialAdController là quảng cáo fullscreen.
 *  Khi fullscreen ad bung lên theo dạng modal view, cần chọn cho nó rootviewconller. Cũng tương tự như banner ad.
 */
@property (nonatomic, unsafe_unretained) UIViewController *rootViewControllerFullscreenAd;

+ (MPAdViewController *)sharedManager;

/**
 *  Set TestMode Enabled/Disable. Nhằm hạn chế việc nhấn vào quảng cáo thật khi test, set TestMode = YES khi debug.
 *  Không được quên set lại TestMode = NO trước khi build release.
 */
- (id) initWithTestModeEnabled:(BOOL)testModeEnabled;

/**
 *  Các hàm ẩn/hiện quảng cáo banner. bBannerAdIsShowing trả về YES khi quảng cáo banner đang được hiện, NO trong trường hợp còn lại.
 */
- (void) showBannerAd;
- (void) hideBannerAd;
- (BOOL) bBannerAdIsShowing;
- (CGSize)getAdBannerCGSize;

/////////// FULSCREEN AD HANDLE ////////
/**
 *  Ưu tiên (YES) hiện adconoly video trước nếu nó đã load thành công, sau đó mới hiện interstitial ad, 
 *  nếu không ưu tiên thì sẽ dựa theo tỉ lệ % lấy từ server
 */
- (void) setAdconolyVideoToShowFirst:(BOOL)adconolyShowFirst;

/**
 *  Hàm gọi hiển thị quảng cáo to (adconoly & interstitial)
 */
- (void) logEventToShowFullscreenAd;

/**
 *  Thông báo cho adcontroller biết rằng app đã in-app purchased hay chưa. 
 *  Gọi hàm này ngay khi khởi tạo adcontroller, và khi user mua in-app thành công, hoặc restore previous purchase thành công.
 *  Nếu quên gọi hàm này, khả năng app vẫn sẽ hiện quảng cáo như bản free.
 */
- (void) setProductType:(PRODUCT_INAPP_TYPE)productType;

@end

