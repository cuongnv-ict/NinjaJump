
//
//  VDConfigNotification.m
//  VietTVPro
//
//  Created by Do Lam on 10/8/12.
//
//

#import "VDConfigNotification.h"
#import "CJSONDeserializer.h"
#import "Reachability.h"

#import "LocalizationSystem.h"

#define documentPath			[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define libraryPath				[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define appDataDirectoryPath	[libraryPath stringByAppendingString:@"/AppData"]

#ifndef SAFE_RELEASE
#define SAFE_RELEASE(p) if( p != nil ){ [p release]; p = nil; }
#endif

#ifndef SAFE_ENDTIMER
#define SAFE_ENDTIMER(p) if( p != nil ){ [p invalidate]; p = nil; }
#endif

VDConfigNotification* g_vdConfigNotification = nil;

#define fileNameNotificationData                    @"vdnotification.dat"
#define fileNameAdClickCount                        @"vdadclickcount.dat"
#define fileNameAdImpressionCount                   @"vdadimpressioncount.dat"

// File store data generate by user or some server settings...
#define fileNameConfigSettings                      @"vdconfigsettings.dat"

#define CLEVERNET_AD_ID_1   @"89"
#define CLEVERNET_AD_ID_2   @"90"

@interface VDConfigNotification(Private)
- (int)getAdRate;
- (void)getUDID;
@end

@implementation VDConfigNotification

@synthesize _config;
@synthesize delegate;
@synthesize _notifications;
@synthesize popupAlertView = _popupAlertView;

+ (NSString*) getProductName
{
	return (NSString*)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleNameKey);
}

+ (NSString*) getProductVersion
{
	return (NSString*)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey);
}

+ (NSString*)getBundleID
{
	return (NSString*)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleIdentifierKey);
}

+ (int)getRandomIntValue:(int)nN
{
	srand (time(NULL));
	return (rand() % nN);
}

-(id)init
{
    if (self = [super init])
    {
        _productType = PT_FREE;
        popupStyle = POPUP_STYLE_ALERT;
        _shouldShowNotificationWhenOpenApp = NO;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:appDataDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        _dictConfigSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameConfigSettings]];
        if (!_dictConfigSettings)
            _dictConfigSettings = [[NSMutableDictionary alloc] init];
        
        NSString *sUDID = [_dictConfigSettings objectForKey:keyUDID];
        if (!sUDID)
            [self getUDID];
        
        _dictAdClickCount = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameAdClickCount]];
        if (!_dictAdClickCount)
            _dictAdClickCount = [[NSMutableDictionary alloc] init];
        
        _dictAdImpressionCount = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameAdImpressionCount]];
        if (!_dictAdImpressionCount)
            _dictAdImpressionCount = [[NSMutableDictionary alloc] init];
        
        _dictConfigNotifications = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameNotificationData]];
        if (!_dictConfigNotifications)
            _dictConfigNotifications = [[NSMutableDictionary alloc] init];
        
        _config = nil;
        if (_dictConfigNotifications && [_dictConfigNotifications respondsToSelector:@selector(objectForKey:)])
            _config = [_dictConfigNotifications objectForKey:kConfig];
        
        NSLog(@"CONFIG_NOTIFICATION: %@",_dictConfigNotifications);
        NSLog(@"_CONFIG: %@",_config);
        
        _notifications = nil;
        if (_dictConfigNotifications && [_dictConfigNotifications respondsToSelector:@selector(objectForKey:)])
            _notifications = [_dictConfigNotifications objectForKey:kNotifications];
        
        
        _dictCleverNetAdCachedInfo = [[NSMutableDictionary alloc] init];
        _dictLastCleverNetAdInfo = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidLoadNewConfig object:nil];
        
        
        if ([_dictConfigSettings objectForKey:kCurrentIndexAd])
            _nCurIndexAd = [[_dictConfigSettings objectForKey:kCurrentIndexAd] intValue];
        else
            _nCurIndexAd = -1;
        
        if (_nCurIndexAd >= [_notifications count])
            _nCurIndexAd = 0;
        
        _nAdRate = [self getAdRate];
        
        _popupNotification = nil;
        CGRect rectFrame;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            if ([VDUtilities isiPhone5Screen])
            {
                rectFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 230, 320, 230);
            }
            else
            {
                rectFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 190, 320, 190);
            }

        }
        else
        {
            rectFrame = CGRectMake(0, 0, 0, 0);
        }
        
        _popupNotification = [[PopupAlertView alloc] initWithFrame:rectFrame];
        _popupNotification.delegate = self;
        _popupNotification.view;
        
        _strCleverNetAdZoneID = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
      }
    return self;
}

- (id)initWithProductType:(PRODUCT_TYPE)productType
{
    if (self = [self init])
    {
        [self setProductType:productType];
    }
    return self;
}

- (void)setProductType:(PRODUCT_TYPE)productType
{
    if (_productType != productType)
    {
        _productType = productType;
        _nAdRate = [self getAdRate];
    }
    
}

- (void) setCleverNetAdZoneID:(NSString*)zoneID
{
    [_strCleverNetAdZoneID release];
    _strCleverNetAdZoneID = [[NSString alloc] initWithFormat:@"%@",zoneID];
}

- (NSString *)getAdMobMediationID
{
    return [_config objectForKey:kConfig_kAdMobMediationID];
}



- (int)getAdRate
{
    if (!_config)
        return -1;
    
    int nMaxAdRate, nMinAdRate;
    if (_productType == PT_PAID)
    {
        nMinAdRate = [[_config objectForKey:kConfig_MinPaidAdsRate] intValue];
        nMaxAdRate = [[_config objectForKey:kConfig_PaidAdsRate] intValue];
    }
    else
    {
        nMinAdRate = [[_config objectForKey:kConfig_MinFreeAdsRate] intValue];
        nMaxAdRate = [[_config objectForKey:kConfig_FreeAdsRate] intValue];
    }
    
    if (nMaxAdRate == 0)
        return 0;
    
    return nMinAdRate + [VDConfigNotification getRandomIntValue:(nMaxAdRate-nMinAdRate+1)];
}

- (void)appDidBecomeActive
{
    int nCountOpenApp = [[[NSUserDefaults standardUserDefaults] objectForKey:kCountOpenApp] intValue]; //[[_dictConfigSettings objectForKey:kCountOpenApp] intValue];
    nCountOpenApp++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nCountOpenApp] forKey:kCountOpenApp];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
// Check app update version...
    NSString* sCurAppVersion = [VDConfigNotification getProductVersion];
    NSString* sAppVersionOnFile = [NSString stringWithContentsOfFile:[appDataDirectoryPath stringByAppendingString:@"/appversion.dat"] encoding:NSUTF8StringEncoding error:nil];
   
    if (!sAppVersionOnFile || [sCurAppVersion compare:sAppVersionOnFile] == NSOrderedDescending)
    {
        [sCurAppVersion writeToFile:[appDataDirectoryPath stringByAppendingString:@"/appversion.dat"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
        int nUpdate = sAppVersionOnFile ? 1:0; // Check user update version or new installation
        
        NSString* sURL = [NSString stringWithFormat:@"http://deltago.com/notifications/update_app_version.php?appid=%@&version=%@&update=%d", [VDConfigNotification getBundleID], sCurAppVersion, nUpdate];
        sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sURL]
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                              timeoutInterval:8.0];
        NSURLConnection *urlConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
    }
    
    
    if (_shouldShowNotificationWhenOpenApp){
        [self showPopUpNotifications];
        //[self forceToShowPopUpNotifications];
    }
    
    [self getNotification];
}

- (void)appDidEnterBackground
{
    if (_urlConnGetNotifications)
        [_urlConnGetNotifications cancel];
}

- (void)getNotification
{
    NSString* sUDID = [_dictConfigSettings objectForKey:keyUDID];
    if (!sUDID)
    {
        if (!_urlConnGetUDID)
            [self getUDID];
        return;
    }
    DEVICE_TARGET curDeviceType = DT_IPHONE;
    if ([[UIDevice currentDevice] deviceFamily] == UIDeviceFamilyiPad)
        curDeviceType = DT_IPAD;
    
    NSString* sURL = [NSString stringWithFormat:@"http://%@/notifications/get_notifications.php?udid=%@&appid=%@&version=%@&vconfig=%d&target=%d&product=%d&devicename=%@&os=iOS%@", SERVER_CONFIGNOTIFICATION, sUDID, [VDConfigNotification getBundleID], [VDConfigNotification getProductVersion], VERSION_CONFIG, (int)curDeviceType, (int)_productType, [[UIDevice currentDevice] platformString], [[UIDevice currentDevice] systemVersion]];
    
    sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",sURL);
    
    //sURL = @"http://mdcgate.com/viettv/get_tvplus_list.php";
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sURL]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:15.0];

    _urlConnGetNotifications = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (_urlConnGetNotifications)
		_dataReceived = [[NSMutableData data] retain];
    
    
    /*
     VD ket qua tra ve:
     notifications =     (
     {
     AppId = appid;
     CancelText = Cancel;
     Description = "CleverNET.Ad1";
     MaxClick = 100;
     MaxImpression = 1000;
     NotificationId = 89;
     Title = "CleverNET.Ad1";
     TryNowText = Free;
     Type = 2;
     URL = "http://deltago.com/notifications/getCleverNETAd.php";
     },
     {
     AppId = appid;
     CancelText = Cancel;
     Description = "CleverNET.Ad2";
     MaxClick = 100;
     MaxImpression = 1000;
     NotificationId = 90;
     Title = "CleverNET.Ad2";
     TryNowText = Free;
     Type = 2;
     URL = "http://deltago.com/notifications/getCleverNETAd.php";
     }
     );   
    */
}

- (void)getUDID
{
    NSString *sDeviceDescription = [NSString stringWithFormat:@"%@-iOS%@", [[UIDevice currentDevice] platformString], [[UIDevice currentDevice] systemVersion]];
    
    NSString* sURL = [NSString stringWithFormat:@"http://%@/notifications/get_udid.php?appid=%@&appname=%@&version=%@&name=%@", SERVER_CONFIGNOTIFICATION, [VDConfigNotification getBundleID], [VDConfigNotification getProductName], [VDConfigNotification getProductVersion], sDeviceDescription];
    sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sURL]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:15.0];
    
    _urlConnGetUDID = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (_urlConnGetUDID)
		_dataReceivedUDID = [[NSMutableData data] retain];
}

- (NSString*) getUserAgentString
{
    UIWebView* webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    return [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}

- (NSString*) getUUIDString
{
    NSString *UUID = nil;
    UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"kApplicationUUIDKey"];
    if (UUID == nil)
    {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        UUID = (NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:@"kApplicationUUIDKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return UUID;
}

+ (BOOL)isInstalledAppId:(NSString *)sAppId
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", sAppId]]];
}

- (BOOL) showPopUpNotifications
{
    if ([[_config objectForKey:kConfig_EnableAds] intValue] == 0)
        return NO;
    if ([_notifications count] == 0)
        return NO;
    
    //// Check if pop-up alert is currently being showed
    if (_popupNotification && _popupNotification.isBeingShow) {
        return NO;
    }
    if (_alertNotification) {
        return NO;
    }

    
    int nCountOpenApp = [[[NSUserDefaults standardUserDefaults] objectForKey:kCountOpenApp] intValue];
    
    if (_nAdRate > 0 && (nCountOpenApp % _nAdRate) == 0)
    {
        nCountOpenApp = 0;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nCountOpenApp] forKey:kCountOpenApp];
        [[NSUserDefaults standardUserDefaults] synchronize];
         // Reset adrate with random value
        _nAdRate = [self getAdRate];
    }
    else
        return NO;
    
    return [self startShowingPopUpNotifications];
}

- (BOOL) forceToShowPopUpNotifications
{
    //// Check if pop-up alert is currently being showed
    if (_popupNotification && _popupNotification.isBeingShow) {
        return NO;
    }
    if (_alertNotification) {
        return NO;
    }

    return [self startShowingPopUpNotifications];
}

- (BOOL) startShowingPopUpNotifications
{
    _nCurIndexAd++;
    if (_nCurIndexAd >= [_notifications count])
        _nCurIndexAd = 0;
    
    NSString* sCurAdID = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_ID];
    int nCurAdMaxClick = [[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_MaxClick] intValue];
    int nCurAdMaxImpression = [[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotifcation_MaxImpression] intValue];
    
    NOTIFICATION_TYPE curNotifyType = (NOTIFICATION_TYPE)[[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Type] intValue];
    NSString *sCurAdAppId = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_AppId];
    
    NSString *sAppBundleID = [VDConfigNotification getBundleID];
    
    int nStartIndexID = _nCurIndexAd;
    
    //BOOL bIsAppInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", sCurAdAppId]]];
    
    while ([[_dictAdClickCount objectForKey:sCurAdID] intValue] >= nCurAdMaxClick ||
           [[_dictAdImpressionCount objectForKey:sCurAdID] intValue] >= nCurAdMaxImpression ||
           (curNotifyType == NTYPE_APP && ([sAppBundleID isEqualToString:sCurAdAppId] ||
                                           [VDConfigNotification isInstalledAppId:sCurAdAppId])))  // prevent app ad itself and  app that is installed
    {
        if ([_notifications count] == 0) return NO;
        
        _nCurIndexAd++;
        if (_nCurIndexAd >= [_notifications count])
            _nCurIndexAd = 0;
        
        if (_nCurIndexAd == nStartIndexID)  // There is nothing to show...
            return NO;
        
        curNotifyType = (NOTIFICATION_TYPE)[[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Type] intValue];
        sCurAdID = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_ID];
        nCurAdMaxClick = [[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_MaxClick] intValue];
        nCurAdMaxImpression = [[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotifcation_MaxImpression] intValue];
        sCurAdAppId = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_AppId];
        
    }
    
    [_dictConfigSettings setObject:[NSNumber numberWithInt:_nCurIndexAd] forKey:kCurrentIndexAd];
    [_dictConfigSettings writeToFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameConfigSettings] atomically:NO];
    
    // Count impression of current ad
    int nCurAdImpressionCount = [[_dictAdImpressionCount objectForKey:sCurAdID] intValue];
    [_dictAdImpressionCount setObject:[NSNumber numberWithInt:nCurAdImpressionCount + 1] forKey:sCurAdID];
    [_dictAdImpressionCount writeToFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameAdImpressionCount] atomically:NO];
    
    // Show ad
    if (curNotifyType == NTYPE_INAPP)
    {
        if ([delegate respondsToSelector:@selector(VDConfigNotification:showNotificationWithInfo:)])
            [delegate VDConfigNotification:self showNotificationWithInfo:[_notifications objectAtIndex:_nCurIndexAd]];
        
        // Count impression here
        if (_nCurIndexAd < [_notifications count])
        {
            [self showANotifyWithNotificationId:[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_ID]];
        }
    }
    else if (curNotifyType == NTYPE_APP)
    {
        if ([delegate respondsToSelector:@selector(VDConfigNotification:showNotificationWithInfo:)])
        {
            [delegate VDConfigNotification:self showNotificationWithInfo:[_notifications objectAtIndex:_nCurIndexAd]];
        }
        else
        {
            NSString* sTryNowText = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_TryNowText];
            if ([sTryNowText length] == 0)
                sTryNowText = @"Try now";
            NSString* sCancelText = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_CancelText];
            if ([sCancelText length] == 0)
                sCancelText = @"Cannel";
            
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && popupStyle == POPUP_STYLE_SLICEFROMBOTTOM && (UIInterfaceOrientationIsPortrait(orientation)))
            {
                NSString* sMsgTitle = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Title];
                NSString* sMsgContent = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Description];
                
                [_popupNotification setTitleText:sMsgTitle];
                [_popupNotification setMessageText:sMsgContent];
                [_popupNotification setOKText:sTryNowText];
                [_popupNotification showPopupView];
            }
            else
            {
                _alertNotification = [[UIAlertView alloc] initWithTitle:[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Title] message:[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Description] delegate:self cancelButtonTitle:sCancelText otherButtonTitles:sTryNowText, nil];
                _alertNotification.tag = _nCurIndexAd;
                [_alertNotification show];
                [_alertNotification release];
            }
        }
        
        // Count impression here
        if (_nCurIndexAd < [_notifications count])
        {
            [self showANotifyWithNotificationId:[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_ID]];
        }
    }
    else if (curNotifyType == NTYPE_CLEVERNET)
    {
        /* Hien thi quang cao clevernet theo trinh tu:
         1. Request quang cao CleverNET den Sever
         2. Neu nhan duoc thanh cong thi hien thi ket qua nhan duoc
         3. Neu request that bai (hoac ket qua ko hop le), tim va hien thi quang cao non-CleverNET tiep theo
         */
        [self getCleverNETAdInfo];
    }
    
    return YES;
}

- (void)showANotifyWithNotificationId:(NSString *)sNotificationID
{
    // Click count to server
    NSString* sURL = [NSString stringWithFormat:@"http://%@/notifications/handle_click.php?udid=%@&appid=%@&id=%@&impression=1", SERVER_CONFIGNOTIFICATION, [_dictConfigSettings objectForKey:keyUDID], [VDConfigNotification getBundleID],sNotificationID];
    sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Count impression view to %@", sURL);
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sURL]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:13.0];
    NSURLConnection *urlConnClickReport = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
}

- (void)userJustClickTryNowWithNotificationId:(NSString *)sNotificationID
{
    // Click count to server
    NSString* sURL = [NSString stringWithFormat:@"http://%@/notifications/handle_click.php?udid=%@&appid=%@&id=%@", SERVER_CONFIGNOTIFICATION, [_dictConfigSettings objectForKey:keyUDID], [VDConfigNotification getBundleID],sNotificationID];
    //if ([sNotificationID isEqualToString:CLEVERNET_AD_ID_1] || [sNotificationID isEqualToString:CLEVERNET_AD_ID_2])
    if (_dictLastCleverNetAdInfo && [self isCleverNETNotificationID:sNotificationID])
    {
        NSString *strExtraInfo = [_dictLastCleverNetAdInfo objectForKey:@"link"];
        NSArray *arr = [strExtraInfo componentsSeparatedByString:@"zoneid="];
        strExtraInfo = [NSString stringWithFormat:@"&zoneid=%@",[arr lastObject]];
        strExtraInfo = [strExtraInfo lowercaseString];
        sURL = [sURL stringByAppendingString:strExtraInfo];
    }
    
    sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Count click view to %@", sURL);
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sURL]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:13.0];
    NSURLConnection *urlConnClickReport = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
    
    
    int nCurAdClickCount = [[_dictAdClickCount objectForKey:sNotificationID] intValue];
    [_dictAdClickCount setObject:[NSNumber numberWithInt:nCurAdClickCount + 1] forKey:sNotificationID];
    [_dictAdClickCount writeToFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameAdClickCount] atomically:NO];
}

- (BOOL) isCleverNETNotificationID:(NSString*)strID
{
    int nTotalNotify = [_notifications count];
    BOOL isCleverNETNotify = FALSE;
    if (nTotalNotify > 0)
        for (int i = 0; i < nTotalNotify; i++)
        {
            NOTIFICATION_TYPE curNotifyType = (NOTIFICATION_TYPE)[[[_notifications objectAtIndex:i] objectForKey:kNotification_Type] intValue];
            NSString* sCurAdID = [[_notifications objectAtIndex:i] objectForKey:kNotification_ID];
            
            if ([sCurAdID isEqualToString:strID] && curNotifyType == NTYPE_CLEVERNET)
                isCleverNETNotify = TRUE;
        }
    
    return isCleverNETNotify;
}

- (void) setPopupStyle:(POPUP_STYLE)style
{
    popupStyle = style;
}

- (NSArray*) getListOfNotificationPPCLINK
{
    /* Loc nhung notification khong thuoc loai cleverNet */
    /* va ca nhung App da cai tren may */
    int nNumberNotify = [_notifications count];
    NSMutableArray *arrNotificationPPCLINK = [[NSMutableArray alloc] init];
    for (int index = 0; index < nNumberNotify; index++)
    {
        NOTIFICATION_TYPE curNotifyType = (NOTIFICATION_TYPE)[[[_notifications objectAtIndex:index] objectForKey:kNotification_Type] intValue];
        NSString *strAppID = [[_notifications objectAtIndex:index] objectForKey:kNotification_AppId];
        if (curNotifyType != NTYPE_CLEVERNET)
        {
            if (![VDConfigNotification isInstalledAppId:strAppID])
                [arrNotificationPPCLINK addObject:[_notifications objectAtIndex:index]];
        }
    }
    return [arrNotificationPPCLINK autorelease];
}

- (void) updateConfigParams:(NSDictionary*)dictConfigParam
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int nBetweenFullAdInterval = [[dictConfigParam objectForKey:@"fullScreenAdFreeBetweenAdShowMinTimeInterval"] intValue];
    [defaults setObject:[NSNumber numberWithInt:nBetweenFullAdInterval] forKey:@"fullScreenAdFreeBetweenAdShowMinTimeInterval"];
    
    int nFullAdFreeWhenOpenApp = [[dictConfigParam objectForKey:@"fullScreenAdFreeWhenOpenAppTimeInterval"] intValue];
    [defaults setObject:[NSNumber numberWithInt:nFullAdFreeWhenOpenApp] forKey:@"fullScreenAdFreeWhenOpenAppTimeInterval"];

    int v4vcAdFreeTimeIntervalBonus = [[dictConfigParam objectForKey:@"V4VCAdFreeTimeIntervalBonus"] intValue];
    [defaults setObject:[NSNumber numberWithInt:v4vcAdFreeTimeIntervalBonus] forKey:@"V4VCAdFreeTimeIntervalBonus"];

    //int nFullAdBonus = [[dictConfigParam objectForKey:@"fullScreenAdFreeTimeIntervalBonus"] intValue];
    //[defaults setObject:[NSNumber numberWithInt:nFullAdBonus] forKey:@"fullScreenAdFreeTimeIntervalBonus"];
    
    //int nBannerAdBonus = [[dictConfigParam objectForKey:@"bannerAdFreeTimeIntervalBonus"] intValue];
    //[defaults setObject:[NSNumber numberWithInt:nBannerAdBonus] forKey:@"bannerAdFreeTimeIntervalBonus"];

    //int nBannerAdFreeTime = [[dictConfigParam objectForKey:@"bannerAdFreeTimeInterval"] intValue];
    //[defaults setObject:[NSNumber numberWithInt:nBannerAdFreeTime] forKey:@"bannerAdFreeTimeInterval"];

    //int nBannerAdShowTime = [[dictConfigParam objectForKey:@"bannerAdShowTimeInterval"] intValue];
    //[defaults setObject:[NSNumber numberWithInt:nBannerAdShowTime] forKey:@"bannerAdShowTimeInterval"];

    //int nAdconolyPercentage = [[dictConfigParam objectForKey:@"AdConolyAdPercentage"] intValue];
    //[defaults setObject:[NSNumber numberWithInt:nAdconolyPercentage] forKey:@"AdConolyAdPercentage"];

    NSString *bannerNetworkConfigValue = [dictConfigParam objectForKey:@"PPCLINKMediationConfig_AdBanner"];
    NSArray *bannerNetworkGroup = [bannerNetworkConfigValue componentsSeparatedByString:@"#"];
    [defaults setObject:bannerNetworkGroup forKey:@"PPCLINKMediationConfig_AdBanner"];
    
    NSString *interstitialNetworkConfigValue = [dictConfigParam objectForKey:@"PPCLINKMediationConfig_Interstitial"];
    NSArray *interstitialNetworkGroup = [interstitialNetworkConfigValue componentsSeparatedByString:@"#"];
    [defaults setObject:interstitialNetworkGroup forKey:@"PPCLINKMediationConfig_Interstitial"];
    
    int recirculateAdNetworkEnable = [[dictConfigParam objectForKey:@"RecirculateAdNetworkEnable"] intValue];
    [defaults setObject:[NSNumber numberWithInt:recirculateAdNetworkEnable] forKey:@"RecirculateAdNetworkEnable"];
    
    [defaults synchronize];
    
    NSLog(@"POST NOTIFY: Get updated ad config param");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetUpdatedAdConfigParams" object:nil];
}

#pragma mark - CleverNET Ad Handle
- (void) getCleverNETAdInfo
{
    NSLog(@"CLEVERNET : getCleverNETAdInfo");
    /* Gui request den server MDC, lay thong tin cho notification tiep theo cua cleverNET */
    
    /* Clear cached info */
    [_dictCleverNetAdCachedInfo setObject:[NSNumber numberWithBool:NO] forKey:kCleverNetAdInfo_Ready];
    
    /* Check if there is a slot of cleverNetAD */
    BOOL bCleverNETAdShouldBePresent = NO;
    int nNumberNotification = [_notifications count];
    for (int index = 0; index < nNumberNotification; index++)
    {
        NOTIFICATION_TYPE curNotifyType = (NOTIFICATION_TYPE)[[[_notifications objectAtIndex:index] objectForKey:kNotification_Type] intValue];
        if (curNotifyType == NTYPE_CLEVERNET)
        {
            bCleverNETAdShouldBePresent = YES;
            break;
        }
    }
    
    // Uncomment to exist test
    //if (!bCleverNETAdShouldBePresent) return;
    
    /* Request Info for the next cleverNetAd show */
    if (!_strCleverNetAdZoneID)
        _strCleverNetAdZoneID = [[NSString alloc] initWithString:@"7a266402ce2c1f100849c6f6c6a9b648"];
    NSString *strUUID = [self getUUIDString];
    NSString *strUserAgent = [self getUserAgentString];
    NSString *strDeviceName = [[UIDevice currentDevice] name];
    NSString *strIsIOS = @"IOS";
    if ([[UIDevice currentDevice] deviceFamily] != UIDeviceFamilyUnknown)
        strIsIOS = @"IOS";
    //else strIsIOS = @"ANDROI";
    
    NSString* sURL = [NSString stringWithFormat:@"http://deltago.com/notifications/getCleverNETAd.php?zoneid=%@&imeinumber=%@&DeviceName=%@&OS=%@&ua=%@",_strCleverNetAdZoneID,strUUID,strDeviceName,strIsIOS,strUserAgent];
    sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"%@",sURL);
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sURL]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:15.0];
    
    _urlConnGetCleverNetAdInfo = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (_urlConnGetCleverNetAdInfo)
		_dataReceivedCleverNetAd = [[NSMutableData data] retain];
    
}

- (void) didGetCleverNETAdInfoFailed
{
    NSLog(@"CLEVERNET : didGetCleverNETAdInfoFailed");
    
    if ([_notifications count] == 0) return;

    // Need to show non-CleverNet Ad instead
    // Truong hop chua load duoc quang cao cleverNet thi hien thi mot quang cao PPCLINK thay the

    _nCurIndexAd++;
    if (_nCurIndexAd >= [_notifications count])
        _nCurIndexAd = 0;
    
    NSString* sCurAdID = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_ID];
    int nCurAdMaxClick = [[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_MaxClick] intValue];
    int nCurAdMaxImpression = [[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotifcation_MaxImpression] intValue];
    
    NOTIFICATION_TYPE curNotifyType = (NOTIFICATION_TYPE)[[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Type] intValue];
    NSString *sCurAdAppId = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_AppId];
    
    NSString *sAppBundleID = [VDConfigNotification getBundleID];
    
    int nStartIndexID = _nCurIndexAd;
    
    while ([[_dictAdClickCount objectForKey:sCurAdID] intValue] >= nCurAdMaxClick ||
           [[_dictAdImpressionCount objectForKey:sCurAdID] intValue] >= nCurAdMaxImpression ||
           (curNotifyType == NTYPE_APP && ([sAppBundleID isEqualToString:sCurAdAppId] ||
                                           [VDConfigNotification isInstalledAppId:sCurAdAppId])) ||
           curNotifyType == NTYPE_CLEVERNET)
    {
        if ([_notifications count] == 0) return;
        
        _nCurIndexAd++;
        if (_nCurIndexAd >= [_notifications count])
            _nCurIndexAd = 0;
        
        if (_nCurIndexAd == nStartIndexID)  // There is nothing to show...
            return;
        
        curNotifyType = (NOTIFICATION_TYPE)[[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Type] intValue];
        sCurAdID = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_ID];
        nCurAdMaxClick = [[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_MaxClick] intValue];
        nCurAdMaxImpression = [[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotifcation_MaxImpression] intValue];
        sCurAdAppId = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_AppId];
    }
    
    if ([delegate respondsToSelector:@selector(VDConfigNotification:showNotificationWithInfo:)])
    {
        [delegate VDConfigNotification:self showNotificationWithInfo:[_notifications objectAtIndex:_nCurIndexAd]];
    }
    else
    {
        // Show found popup type of NTYPE_APP
        NSString* sTryNowText = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_TryNowText];
        if ([sTryNowText length] == 0)
            sTryNowText = @"Try now";
        NSString* sCancelText = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_CancelText];
        if ([sCancelText length] == 0)
            sCancelText = @"Cannel";
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && popupStyle == POPUP_STYLE_SLICEFROMBOTTOM && (UIInterfaceOrientationIsPortrait(orientation)))
        {
            NSString* sMsgTitle = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Title];
            NSString* sMsgContent = [[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Description];
            
            [_popupNotification setTitleText:sMsgTitle];
            [_popupNotification setMessageText:sMsgContent];
            [_popupNotification setOKText:sTryNowText];
            [_popupNotification showPopupView];
        }
        else
        {
            _alertNotification = [[UIAlertView alloc] initWithTitle:[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Title] message:[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Description] delegate:self cancelButtonTitle:sCancelText otherButtonTitles:sTryNowText, nil];
            _alertNotification.tag = _nCurIndexAd;
            [_alertNotification show];
            [_alertNotification release];
        }
    }
    
    // Count impression here
    if (_nCurIndexAd < [_notifications count])
    {
        [self showANotifyWithNotificationId:[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_ID]];
    }
}

- (void) didGetCleverNETAdInfoSuccessfully
{
    NSLog(@"CLEVERNET : didGetCleverNETAdInfoSuccessfully");
    if ([_notifications count] == 0) return;

    //  Now you are ready to show cleverNet Ad
    if ([[_dictCleverNetAdCachedInfo objectForKey:kCleverNetAdInfo_Ready] boolValue])
    {
        // Hien thi quang cao cleverNet da load duoc va cached lai truoc do
        NSString *strTitle = [_dictCleverNetAdCachedInfo objectForKey:kCleverNetAdCachedInfo_Title];
        NSString *strContent = [_dictCleverNetAdCachedInfo objectForKey:kCleverNetAdCachedInfo_Content];
        NSString *strLink = [_dictCleverNetAdCachedInfo objectForKey:kCleverNetAdCachedInfo_Link];
        [_dictCleverNetAdCachedInfo setObject:strLink forKey:kCleverNetAdCachedInfo_CurrentURL];
        
        NSString *sTryNowText = nil;
        NSString *sCancelText = nil;

        sTryNowText = AMLocalizedString(@"BUTTON_TRY_NOW",@"Try now");
        sCancelText = AMLocalizedString(@"BUTTON_CANCEL",@"Cancel");

        if ([delegate respondsToSelector:@selector(VDConfigNotification:showNotificationWithInfo:)])
        {
            NSMutableDictionary *cleverNETAdDictInfo = [[NSMutableDictionary alloc] init];
            if (_nCurIndexAd < [_notifications count])
            {
                [cleverNETAdDictInfo addEntriesFromDictionary:[_notifications objectAtIndex:_nCurIndexAd]];
            }
            
            [cleverNETAdDictInfo setObject:strTitle forKey:kNotification_Title];
            [cleverNETAdDictInfo setObject:strContent forKey:kNotification_Description];
            [cleverNETAdDictInfo setObject:strLink forKey:kNotification_URL];
            
            [delegate VDConfigNotification:self showNotificationWithInfo:cleverNETAdDictInfo];
            [cleverNETAdDictInfo release];
        }
        else
        {
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && popupStyle == POPUP_STYLE_SLICEFROMBOTTOM && (UIInterfaceOrientationIsPortrait(orientation)))
            {
                [_popupNotification setTitleText:strTitle];
                [_popupNotification setMessageText:strContent];
                [_popupNotification setOKText:sTryNowText];
                [_popupNotification showPopupView];
            }
            else
            {
                _alertShowCleverNetAd = [[UIAlertView alloc] initWithTitle:strTitle message:strContent delegate:self cancelButtonTitle:sCancelText otherButtonTitles:sTryNowText, nil];
                _alertShowCleverNetAd.tag = _nCurIndexAd;
                [_alertShowCleverNetAd show];
                [_alertShowCleverNetAd release];
            }
        }
        
        [_dictCleverNetAdCachedInfo setObject:[NSNumber numberWithBool:NO] forKey:kCleverNetAdInfo_Ready];
        
        NSLog(@"CurrentAdIndex : %d",_nCurIndexAd);
        // Count impression here
        if (_nCurIndexAd < [_notifications count])
        {
            [self showANotifyWithNotificationId:[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_ID]];
        }
    }
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertNotification)
    {
        switch (buttonIndex)
        {
            case 0: //Cannel
                break;
                
            case 1: // Try Now
            {
                int nCurIndexAd = alertView.tag;
                NSString *sNotificationID = [[_notifications objectAtIndex:nCurIndexAd] objectForKey:kNotification_ID];
                [self userJustClickTryNowWithNotificationId:sNotificationID];
                
                NSString *sURL = [[_notifications objectAtIndex:nCurIndexAd] objectForKey:kNotification_URL];
                NSLog(@"Open URL: %@", sURL);
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
            
                break;
            }
                
            default:
                break;
        }
        
        _alertNotification = nil;
    }
    
    if (alertView == _alertShowCleverNetAd)
    {
        switch (buttonIndex)
        {
            case 0: //Cannel
                break;
                
            case 1: // Try Now
            {
                int nCurIndexAd = alertView.tag;
                NSString *sNotificationID = [[_notifications objectAtIndex:nCurIndexAd] objectForKey:kNotification_ID];
                [self userJustClickTryNowWithNotificationId:sNotificationID];
                
                NSString *sURL = [_dictCleverNetAdCachedInfo objectForKey:kCleverNetAdCachedInfo_CurrentURL];
                NSLog(@"Open URL: %@", sURL);
                sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
                                 
                
                break;
            }
                
            default:
                break;
        }
        
        _alertShowCleverNetAd = nil;
    }

    if (alertView == _alertNewAppVersion)
    {
        switch (buttonIndex)
        {
            case 0: //Cannel
                [_dictConfigSettings setObject:[NSNumber numberWithBool:NO] forKey:[kRemindUpdateNewAppVersion stringByAppendingString:[_config objectForKey:kConfig_AppLatestVersion]]];
                break;
                
            case 1: // Update
            {
                [_dictConfigSettings setObject:[NSNumber numberWithBool:NO] forKey:[kRemindUpdateNewAppVersion stringByAppendingString:[_config objectForKey:kConfig_AppLatestVersion]]];
                
//                if ([delegate respondsToSelector:@selector(VDConfigNotification_updateNewAppVersion:)])
//                    [delegate VDConfigNotification_updateNewAppVersion:self];
//                else
                {
                    NSString* sURL = [_config objectForKey:kConfig_AppstoreURL];
                    if ([sURL length] > 0)
                    {
                        NSLog(@"Open URL: %@", sURL);
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
                    }
                }
                
                
                break;
            }
                
            case 2: // Remind me later
                [_dictConfigSettings setObject:[NSNumber numberWithBool:YES] forKey:[kRemindUpdateNewAppVersion stringByAppendingString:[_config objectForKey:kConfig_AppLatestVersion]]];
            default:
                break;
        }
        
        [_dictConfigSettings writeToFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameConfigSettings] atomically:NO];
        
        _alertNewAppVersion = nil;
    }


}

#pragma mark - Connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == _urlConnGetCleverNetAdInfo)
    {
        [_dataReceivedCleverNetAd appendData:data];
    }
    else if (connection == _urlConnGetUDID)
        [_dataReceivedUDID appendData:data];
    else
        [_dataReceived appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //NSLog(error.descript);
    if (connection == _urlConnGetUDID)
	{
        SAFE_RELEASE(_urlConnGetUDID);
        SAFE_RELEASE(_dataReceivedUDID);
	}
    if (connection == _urlConnGetCleverNetAdInfo)
	{
        SAFE_RELEASE(_urlConnGetCleverNetAdInfo);
        SAFE_RELEASE(_dataReceivedCleverNetAd);
        
        [self didGetCleverNETAdInfoFailed];
	}
    else if (connection == _urlConnGetNotifications)
    {
        SAFE_RELEASE(_urlConnGetNotifications);
        SAFE_RELEASE(_dataReceived);
    }    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _urlConnGetUDID)
	{
        SAFE_RELEASE(_urlConnGetUDID);
        NSError* theError = nil;
        NSDictionary* dictReturn = [[CJSONDeserializer deserializer] deserialize:_dataReceivedUDID error:&theError];
        NSError* theError2 = nil;
        NSDictionary* dictReturn2 = [[CJSONDeserializer deserializer] deserializeAsDictionary:_dataReceivedUDID error:&theError2];
        SAFE_RELEASE(_dataReceivedUDID);
        
        if ([[dictReturn objectForKey:kGetUDIDData_Result] isEqualToString:@"success"])
        {
            [_dictConfigSettings setObject:[dictReturn objectForKey:kGetUDIDData_UDID] forKey:keyUDID];
            [_dictConfigSettings writeToFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameConfigSettings] atomically:NO];
            
            [self getNotification];
        }
        
    }
    else if (connection == _urlConnGetCleverNetAdInfo)
    {
        SAFE_RELEASE(_urlConnGetCleverNetAdInfo);
        NSError* theError = nil;
        NSDictionary* dictReturn = [[CJSONDeserializer deserializer] deserialize:_dataReceivedCleverNetAd error:&theError];
        NSString *strData = [[NSString alloc] initWithData:_dataReceivedCleverNetAd encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",strData);
        SAFE_RELEASE(_dataReceivedCleverNetAd);
        
        [_dictLastCleverNetAdInfo removeAllObjects];
        
        if (dictReturn && [dictReturn respondsToSelector:@selector(objectForKey:)])
        {
            [_dictLastCleverNetAdInfo addEntriesFromDictionary:dictReturn];
            
            int nNumberParamCounter = 0;
            if ([dictReturn objectForKey:kCleverNetAdCachedInfo_Title] && [dictReturn objectForKey:kCleverNetAdCachedInfo_Title] != [NSNull null] && [[dictReturn objectForKey:kCleverNetAdCachedInfo_Title] length] > 0)
            {
                nNumberParamCounter++;
                [_dictCleverNetAdCachedInfo setObject:[dictReturn objectForKey:kCleverNetAdCachedInfo_Title] forKey:kCleverNetAdCachedInfo_Title];
            }
            
            if ([dictReturn objectForKey:kCleverNetAdCachedInfo_Content] && [dictReturn objectForKey:kCleverNetAdCachedInfo_Content] != [NSNull null] && [[dictReturn objectForKey:kCleverNetAdCachedInfo_Content] length] > 0)
            {
                nNumberParamCounter++;
                [_dictCleverNetAdCachedInfo setObject:[dictReturn objectForKey:kCleverNetAdCachedInfo_Content] forKey:kCleverNetAdCachedInfo_Content];
            }
            
            if ([dictReturn objectForKey:kCleverNetAdCachedInfo_Link] && [dictReturn objectForKey:kCleverNetAdCachedInfo_Link] != [NSNull null] && [[dictReturn objectForKey:kCleverNetAdCachedInfo_Link] length] > 0)
            {
                nNumberParamCounter++;
                [_dictCleverNetAdCachedInfo setObject:[dictReturn objectForKey:kCleverNetAdCachedInfo_Link] forKey:kCleverNetAdCachedInfo_Link];
            }
            
            // Assume that cleverNet Ad is valid if only client received all 3 params: title, content, link
            if (nNumberParamCounter > 2)
            {
                [_dictCleverNetAdCachedInfo setObject:[NSNumber numberWithBool:YES] forKey:kCleverNetAdInfo_Ready];
                [self didGetCleverNETAdInfoSuccessfully];
            }
            else
            {
                [_dictCleverNetAdCachedInfo setObject:[NSNumber numberWithBool:NO] forKey:kCleverNetAdInfo_Ready];
                [self didGetCleverNETAdInfoFailed];
            }
                
        }
        else
        {
            [_dictCleverNetAdCachedInfo setObject:[NSNumber numberWithBool:NO] forKey:kCleverNetAdInfo_Ready];
            [self didGetCleverNETAdInfoFailed];
        }
    }
	else if (connection == _urlConnGetNotifications)
    {
        SAFE_RELEASE(_urlConnGetNotifications);
        NSError* theError = nil;
        NSDictionary *dictReturn = [[[CJSONDeserializer deserializer] deserialize:_dataReceived error:&theError] retain];
        SAFE_RELEASE(_dataReceived);
        
        if (dictReturn)
        {
            [_dictConfigNotifications setDictionary:dictReturn];
            [dictReturn release];
            if ([_dictConfigNotifications writeToFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameNotificationData] atomically:YES])
            {
                NSLog(@"CONFIG_NOTIFICATION write to file %@ OK",fileNameNotificationData);
            }
            else
            {
                NSLog(@"CONFIG_NOTIFICATION write to file %@ FAILED",fileNameNotificationData);
            }
            
            _notifications = [_dictConfigNotifications objectForKey:kNotifications];
            
            NSDictionary* _dictConfigParam = [_dictConfigNotifications objectForKey:@"config"];
            if (_dictConfigParam && [_dictConfigParam count] > 0)
            {
                /// Save params and then post notification to call updating config
                [self updateConfigParams:_dictConfigParam];
            }
            
            int numberNotification = [_notifications count];
            if (numberNotification > 0)
            {
                NSMutableArray *arrNewNotification = [[NSMutableArray alloc] init];
                NSString *sAppBundleID = [VDConfigNotification getBundleID];
                
                /* Loc nhung notification cua nhung app chua cai dat */
                for (int index = 0; index < numberNotification; index++)
                {
                    NSString *sCurAdAppId = [[_notifications objectAtIndex:index] objectForKey:kNotification_AppId];
                    if (![VDConfigNotification isInstalledAppId:sCurAdAppId] && ![sCurAdAppId isEqualToString:sAppBundleID])
                    {
                        [arrNewNotification addObject:[_notifications objectAtIndex:index]];
                    }
                }
                
                [_dictConfigNotifications setObject:arrNewNotification forKey:kNotifications];
                [arrNewNotification release];
                

                if (_dictConfigNotifications && [_dictConfigNotifications respondsToSelector:@selector(objectForKey:)])
                    _notifications = [_dictConfigNotifications objectForKey:kNotifications];
                
//                if ([_notifications count] > 0)
//                    [self getCleverNETAdInfo];
            }
            
             
            if (_dictConfigNotifications && [_dictConfigNotifications respondsToSelector:@selector(objectForKey:)])
                _config = [_dictConfigNotifications objectForKey:kConfig];
            
            if (_nAdRate <= 0)
                _nAdRate = [self getAdRate];
            
            //NSLog(_dictConfigNotifications.debugDescription);
            
            
            /* Thong bao la da download xong file config */
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidLoadNewConfig object:nil];
            
            /* Download AppIcon tai background  */
            //[self performSelectorInBackground:@selector(backgroundDownloadAppIcons) withObject:nil];
            [NSThread detachNewThreadSelector:@selector(backgroundDownloadAppIcons) toTarget:self withObject:nil];
            
            // Check update app
            NSString *sCurProductVersion = [NSString stringWithFormat:@"%@",[VDConfigNotification getProductVersion]];
            NSString *sAppLatestVersion = [_config objectForKey:kConfig_AppLatestVersion];
            if ([sCurProductVersion compare:sAppLatestVersion] == NSOrderedAscending)
            {
                NSNumber *numRemindUpdate = [_dictConfigSettings objectForKey:[kRemindUpdateNewAppVersion stringByAppendingString:sAppLatestVersion]];
                
                NSString *strUpdateMessage = nil;
                NSString *strUpdate = nil;
                NSString *strRemindLater = nil;
                NSString *strCancel = nil;
                
                strUpdateMessage = AMLocalizedString(@"MESSAGE_NEW_VERSION_AVAIABLE",@"The new version is available on App Store. Please update for better experience. Thank you for using our product.");
                strUpdate = AMLocalizedString(@"BUTTON_UPDATE",@"Update");
                strRemindLater = AMLocalizedString(@"BUTTON_REMIND_LATER",@"Remind me later");
                strCancel = AMLocalizedString(@"BUTTON_CANCEL",@"Cancel");
                
                
                if (!numRemindUpdate || [numRemindUpdate boolValue])
                {
                    _alertNewAppVersion = [[UIAlertView alloc] initWithTitle:[VDConfigNotification getProductName] message:strUpdateMessage delegate:self cancelButtonTitle:strCancel otherButtonTitles:strUpdate, strRemindLater, nil];

                    [_alertNewAppVersion show];
                    [_alertNewAppVersion release];
                }
            }
            
            // Check message to customer
            if ([[_config objectForKey:kConfig_MessageEnable] boolValue] && [[_config objectForKey:kConfig_MessageVersion] intValue] > [[_dictConfigSettings objectForKey:kConfig_MessageVersion] intValue])
            {
                UIAlertView *alertMsg = [[UIAlertView alloc] initWithTitle:[VDConfigNotification getProductName] message:[_config objectForKey:kConfig_Message] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertMsg show];
                [alertMsg release];
                
                [_dictConfigSettings setObject:[_config objectForKey:kConfig_MessageVersion] forKey:kConfig_MessageVersion];
                [_dictConfigSettings writeToFile:[NSString stringWithFormat:@"%@/%@", appDataDirectoryPath, fileNameConfigSettings] atomically:NO];
                
            }
            
        }
        
        
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == _urlConnGetCleverNetAdInfo)
    {
        [_dataReceivedCleverNetAd setLength:0];
    }
    else if (connection == _urlConnGetUDID)
        [_dataReceivedUDID setLength:0];
    else
        [_dataReceived setLength:0];
}

#pragma mark - Download AppIcon 
- (void) backgroundDownloadAppIcons
{
    NSDictionary *dictApp = nil;
    NSString *strIconName = nil;
    NSString *strIconURL = nil;
    
    int nAppNumber = [_notifications count];
    
    for (int index = 0; index < nAppNumber; index++)
    {
        dictApp = [_notifications objectAtIndex:index];
        
        strIconName = [dictApp objectForKey:kNotification_AdImage];
        if (!strIconName || strIconName == (id)[NSNull null] || strIconName.length == 0) continue;
        else if ([[strIconName pathExtension] length] == 0)
            strIconName = [strIconName stringByAppendingString:@".png"];
        
        if ([strIconName isEqualToString:@"appicon_default.png"]) continue;
        
        strIconURL = [NSString stringWithFormat:@"%@/%@",urlDownloadAppIconOnServer,strIconName];
        BOOL bIconDownload = [VDUtilities downLoadFileFromURL:strIconURL toFolderPath:iconAppDirectoryPath withFileName:strIconName :NO];
    }
    
    [self performSelectorOnMainThread:@selector(mainThreadDidFinishDownloadAppIcon) withObject:nil waitUntilDone:YES];
}

- (void) mainThreadDidFinishDownloadAppIcon
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidLoadNewConfig object:nil];
}


#pragma mark - Popup AlertView Delegate

- (void) didPopupAlertViewStartToShow
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_PopupAlertViewIsShow object:nil];
}

- (void) dismissPopupAlertViewWithIndex:(NSInteger)index
{
    if (index == 1)
    {
        NOTIFICATION_TYPE curNotifyType = (NOTIFICATION_TYPE)[[[_notifications objectAtIndex:_nCurIndexAd] objectForKey:kNotification_Type] intValue];
        if (curNotifyType == NTYPE_CLEVERNET)
        {
            int nCurIndexAd = _nCurIndexAd;
            NSString *sNotificationID = [[_notifications objectAtIndex:nCurIndexAd] objectForKey:kNotification_ID];
            [self userJustClickTryNowWithNotificationId:sNotificationID];
            
            NSString *sURL = [_dictCleverNetAdCachedInfo objectForKey:kCleverNetAdCachedInfo_CurrentURL];
            NSLog(@"Open URL: %@", sURL);
            sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
        }
        else
        {
            int nCurIndexAd = _nCurIndexAd;
            NSString *sNotificationID = [[_notifications objectAtIndex:nCurIndexAd] objectForKey:kNotification_ID];
            [self userJustClickTryNowWithNotificationId:sNotificationID];
            
            NSString *sURL = [[_notifications objectAtIndex:nCurIndexAd] objectForKey:kNotification_URL];
            
            NSLog(@"Open URL: %@", sURL);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_PopupAlertViewIsHide object:nil];
}

/*
-(void) onNotifyHidePopupAlert:(NSNotification *)notify
{
    int iSelectedBtnIndex = [[notify object] intValue];
    NSLog(@"VDConfigNotification : %d",iSelectedBtnIndex);
    
    if (iSelectedBtnIndex == 1)
    {
        int nCurIndexAd = _nCurIndexAd;
        NSString *sNotificationID = [[_notifications objectAtIndex:nCurIndexAd] objectForKey:kNotification_ID];
        [self userJustClickTryNowWithNotificationId:sNotificationID];
        
        NSString *sURL = [[_notifications objectAtIndex:nCurIndexAd] objectForKey:kNotification_URL];
        NSLog(@"Open URL: %@", sURL);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
    }
}
*/

- (void)dealloc
{
    SAFE_RELEASE(_dictConfigNotifications);
    SAFE_RELEASE(_dictAdImpressionCount);
    SAFE_RELEASE(_dictAdClickCount);
    SAFE_RELEASE(_dictConfigSettings);
    
    SAFE_RELEASE(_dictCleverNetAdCachedInfo);
    SAFE_RELEASE(_dictLastCleverNetAdInfo);
    
    SAFE_RELEASE(_strCleverNetAdZoneID);
    
    _notifications = nil;
    _config = nil;   
   
    SAFE_RELEASE(_popupNotification);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
