//
//  VDConfigNotification.h
//  VietTVPro
//
//  Created by Do Lam on 10/8/12.
//
//

#import <Foundation/Foundation.h>
#import "UIDevice-Hardware.h"
#import "VDUtilities.h"
#import "PopupAlertView.h"

#define VERSION_CONFIG      1

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__);
#else
#   define NSLog(...)
#endif

#define SERVER_CONFIGNOTIFICATION   @"deltago.com"
#define SERVER_CHANNEL_DEFAULT      @"mdcgate.com"

#define keyUDID                     @"keyUDID"
#define kCurrentIndexAd             @"currentIndexAd"
#define kCountOpenApp               @"countOpenApp"
#define kRemindUpdateNewAppVersion  @"remindUpdateNewAppVersion"

#define kGetUDIDData_Result     @"result"
#define kGetUDIDData_UDID       @"udid"

#define kConfig                                     @"config"
#define kConfig_EnableAds                           @"Ads"
#define kConfig_AdsType                             @"Ads_type"
#define kConfig_FreeAdsRate                         @"FreeAdsRate"
#define kConfig_MinFreeAdsRate                      @"MinFreeAdsRate"
#define kConfig_PaidAdsRate                         @"PaidAdsRate"
#define kConfig_MinPaidAdsRate                      @"MinPaidAdsRate"
#define kConfig_AppLatestVersion                    @"app_latest_version"
#define kConfig_MessageVersion                      @"message_version"
#define kConfig_Message                             @"message"
#define kConfig_MessageEnable                       @"message_enable"
#define kConfig_EnableVietDorjeAd                           @"enableVietDorjeAd"
#define kConfig_kAdMobMediationID                           @"adMobMediationID"
#define kConfig_Apply3GForAppVersion                        @"apply3GForAppVersion"
#define kConfig_EnableCopyrightChannelForAppVersion   @"enableCopyrightChannelForAppVersion"
#define kConfig_ShowAdWhenSwitchChannel               @"showAdWhenSwitchChannel"
#define kConfig_ServerChannel                           @"serverChannel"
#define kConfig_EnableAdOnTVIdle                        @"enableAdOnTVIdle"
#define kConfig_AppstoreURL                             @"appstoreurl"

#define kConfig_AppleStreamServers                      @"AppleStreamServers"
#define kConfig_ContactUsUIStyle                        @"contactUsUIStyle"

#define kNotifications                  @"notifications"
#define kNotification_ID                @"NotificationId"
#define kNotification_Description       @"Description"
#define kNotification_Title             @"Title"
#define kNotification_TryNowText        @"TryNowText"
#define kNotification_CancelText        @"CancelText"
#define kNotification_MaxClick          @"MaxClick"
#define kNotifcation_MaxImpression      @"MaxImpression"
#define kNotification_URL               @"URL"
#define kNotification_Target            @"Target"
#define kNotification_AppId             @"AppId"
#define kNotification_AdImage           @"AdImage"


#define kCleverNetAdCachedInfo_CurrentURL   @"link"
#define kCleverNetAdCachedInfo_Link         @"link"
#define kCleverNetAdCachedInfo_Content      @"content"
#define kCleverNetAdCachedInfo_Title        @"title"
#define kCleverNetAdInfo_Ready              @"isCleverNETReady"


#define kNotification_DidLoadNewConfig  @"notifyDidLoadNewConfig"

#define kNotification_PopupAlertViewIsShow  @"notifyPopupAlertViewIsShow"
#define kNotification_PopupAlertViewIsHide  @"notifyPopupAlertViewIsHide"

#define iconAppDirectoryPath        [appDataDirectoryPath stringByAppendingString:@"/appicons"]
#define urlDownloadAppIconOnServer   @"http://deltago.com/notifications/adv/public/upload/images/" 

#define CLEVERNET_AD_TEXT_ZONE_ID       @"7a266402ce2c1f100849c6f6c6a9b648"
typedef enum
{
    DT_IPHONE = 1,
    DT_IPAD = 2,
    DT_ANDROID_PHONE = 4,
    DT_ANDROID_TABLET = 8
} DEVICE_TARGET;

#define kNotification_Product           @"Product"
typedef enum
{
    PT_FREE = 1,
    PT_PAID = 2
} PRODUCT_TYPE;

#define kNotification_Type              @"Type"
typedef enum
{
    NTYPE_APP = 0,
    NTYPE_INAPP = 1,
    NTYPE_CLEVERNET = 2
} NOTIFICATION_TYPE;

typedef enum
{
    POPUP_STYLE_ALERT = 0,
    POPUP_STYLE_SLICEFROMBOTTOM = 1
} POPUP_STYLE;

@class VDConfigNotification;
extern VDConfigNotification* g_vdConfigNotification;

@protocol VDConfigNotificationDelegate <NSObject>

/**
 *  Hàm này sử dụng khi App không sử dụng pop-up alert default, mà tự custom lấy pop-up alertview riêng, thông tin hiện thị lấy từ dictNotifyInfo
 */
- (void)VDConfigNotification:(VDConfigNotification *)vdConfigNotification showNotificationWithInfo:(NSDictionary *)dictNotifyInfo;


//- (void)VDConfigNotification_updateNewAppVersion:(VDConfigNotification *)vdConfigNotification;

@end

@interface VDConfigNotification : NSObject <PopupAlertViewDelegate>
{
    NSMutableData       *_dataReceivedUDID;
    NSMutableData       *_dataReceived;
    NSMutableData       *_dataReceivedCleverNetAd;
    NSURLConnection     *_urlConnGetUDID;
    NSURLConnection     *_urlConnGetNotifications;
    NSURLConnection     *_urlConnGetCleverNetAdInfo;
    //NSString            *_sUDID;
    
    NSMutableDictionary         *_dictConfigNotifications;
    UIAlertView                 *_alertNotification;
    UIAlertView                 *_alertShowCleverNetAd;
    UIAlertView                 *_alertNewAppVersion;
    NSMutableDictionary         *_dictAdClickCount;
    NSMutableDictionary         *_dictAdImpressionCount;
    NSArray                     *_notifications;
    NSDictionary                *_config;
    
    NSMutableDictionary         *_dictConfigSettings;
    
    int                         _nCurIndexAd;
    int                         _nAdRate;
    PRODUCT_TYPE                _productType;
    id<VDConfigNotificationDelegate> delegate;
    
    PopupAlertView              *_popupNotification;
    POPUP_STYLE                 popupStyle;
    
    NSMutableDictionary         *_dictCleverNetAdCachedInfo;
    NSMutableDictionary         *_dictLastCleverNetAdInfo;
    NSString                    *_strCleverNetAdZoneID;
}

@property(nonatomic, retain) NSDictionary   *_config;
@property(nonatomic, retain)    NSArray     *_notifications;
@property(nonatomic, assign) id<VDConfigNotificationDelegate> delegate;
@property (nonatomic, assign) PopupAlertView    *popupAlertView;

/**
 *  Giá trị mặc định là NO
 *  Nếu gán là YES, thì khi bật ứng dụng, sẽ tự động gọi hàm showPopUpNotifications
 */
@property (nonatomic, assign) BOOL  shouldShowNotificationWhenOpenApp;



+ (NSString*) getProductName;
+ (NSString*) getProductVersion;
+ (NSString*)getBundleID;
+ (int)getRandomIntValue:(int)nN;
+ (BOOL)isInstalledAppId:(NSString *)sAppId;


/**
 *  Khi sử dụng custom pop-up alertView riêng của App, thì sau khi người dùng click vào Ad để mở ra, thì cần gọi lại VDConfigNotification kèm theo tham số là ID của quảng cáo vừa hiện để thực hiện thống kê
 */
- (void)userJustClickTryNowWithNotificationId:(NSString *)sNotificationID;

- (id)initWithProductType:(PRODUCT_TYPE)productType;
- (void)getNotification;

/**
 *  Gọi hàm hiển thị quảng cáo pop-up, nếu hiển thị trong lần gọi này, thì trả về YES, nếu ko hiển thị thì trả về NO
 */
- (BOOL) showPopUpNotifications;

/**
 * Gọi hàm hiển thị quảng cáo pop-up mà không cần kiểm tra các kiều kiện, hàm trả về YES nếu hiển thị thành công, NO trong trường hợp còn lại
 */
- (BOOL) forceToShowPopUpNotifications;

- (NSString *)getAdMobMediationID;
- (void)setProductType:(PRODUCT_TYPE)productType;  // Paid/Free

- (void) setPopupStyle:(POPUP_STYLE)style;

- (NSArray*) getListOfNotificationPPCLINK;
- (void) setCleverNetAdZoneID:(NSString*)zoneID;

@end

