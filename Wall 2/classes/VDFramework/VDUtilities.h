//
//  VDUtilities.h
//  vietradio
//
//  Created by VietDorje on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__);
#else
#   define NSLog(...)
#endif

#import <UIKit/UIKit.h>
#import "VDUIImage.h"
#import "Reachability.h"
#import "VDiSizeStardard.h"
#import "VDMailComposer.h"

#define documentPath			[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define libraryPath				[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define applicationSupportPath	[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define appDataDirectoryPath	[libraryPath stringByAppendingString:@"/AppData"]

#define iconChannelDirectoryPath        [appDataDirectoryPath stringByAppendingString:@"/channelicons"]
#define  linkDownloadFileURLImageRadioShow @"http://mdcgate.com/viettv/public/file"  // duong dan den thu muc down load icon cho radio show category

#define recordingsPath          documentPath

//*** File name to store date
#define kFileNameAppConfig              @"appconfig"
#define kFileExtension                  @"plist"
#define DIRNAME_CHANNEL_DATA            @"data"
#define kURLProductOnAppStore			@"urlProductOnAppStore"

#ifndef SAFE_RELEASE
#define SAFE_RELEASE(p) if( p != nil ){ [p release]; p = nil; }
#endif

#ifndef SAFE_ENDTIMER
#define SAFE_ENDTIMER(p) if( p != nil ){ [p invalidate]; p = nil; }
#endif

#ifndef SAFE_DELETE
#define SAFE_DELETE(p) {if( p != NULL ){ delete p; p = NULL; }}
#endif

#ifndef SAFE_DELETE_ARRAY
#define SAFE_DELETE_ARRAY(p) {if( p != NULL ){ delete [] p; p = NULL; }}
#endif

#ifndef SAFE_FREE
#define SAFE_FREE(p) {if( p != NULL ){ free(p); p = NULL; }}
#endif

#ifndef RGB
#define RGB(r, g, b)		[UIColor colorWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0]
#endif

#ifndef RGBA
#define RGBA(r, g, b, a)		[UIColor colorWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:a]
#endif

@interface UIAlertView (Context)
@property (nonatomic, retain) NSDictionary *myUserInfo;
@end

@interface UINavigationController (iOS6OrientationFix)
-(NSUInteger) supportedInterfaceOrientations;
- (BOOL)shouldAutorotate;
@end

@interface UITabBarController(iOS6OrientationFix)
-(NSUInteger) supportedInterfaceOrientations;
- (BOOL)shouldAutorotate;
@end

@interface VDUtilities : NSObject 
{
}

+ (BOOL)isMultitaskingSupported;

+ (UIImage *)createImageWithText:(NSString *)text imageSize:(CGSize)imgSize;
+ (UIImage *)addText:(UIImage *)img text:(NSString *)text1;
+ (NSData*) downloadContentFromURL:(NSString*)sURL;
+ (BOOL) downLoadFileFromURL:(NSString*)sURL toFolderPath:(NSString*) sFolderPath withFileName:(NSString*) sFileName:(BOOL) isOverWritten;
+ (NSString*) getProductName;
+ (NSString*) getProductVersion;
+ (NSString*)getProductOnAppStoreURL;
+ (NSString*)getBundleID;
+ (int)getRandomIntValue:(int)nN;

+ (BOOL) timeIs24HourFormat;

+ (NSString *)generateRecordFileNameWithChannelSymbol:(NSString *)sChannelSymbol;
+ (NSString*)getStringDurationFromSeconds:(NSInteger)nSeconds;

+ (BOOL)checkInternetConnectionViaWifi;
+ (BOOL)checkInternetConnection;
+ (NSString *)getMachineName;
+ (BOOL)isiPhone5Screen;
+ (BOOL) bIsIOS7Version;
+ (BOOL) bIsIOS8Version;
@end

int compareDays(NSDate* date1, NSDate* date2);
int compareTimeHourMinute(NSDate* date1, NSDate* date2);

