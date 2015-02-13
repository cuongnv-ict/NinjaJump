

#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIDevice.h>
#import <CoreLocation/CoreLocation.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import "NSString+MD5.h"

#if DEBUG
#define CNLog(format, ...) [CleverNetUtilities logWithPath:__FILE__ line:__LINE__ string:(format), ## __VA_ARGS__]
#else
#define CNLog(format, ...)
#endif

NSString *UserAgentString(void);

@interface CleverNetUtilities : NSObject
+ (NSString *) getIP;
+ (NSString *) base64Hash:(NSString*) toHash;
+ (NSString *) buildUserAgent:(UIDevice*) device;
+ (NSString *) getTimestamp;
+ (NSString*) getAppName;
+ (NSString*) getAppVersion;
+ (void) setDebugMode:(BOOL) debug;
+ (void) localDebug:(NSString*)debugMessage;

+ (void) setParameter: (NSMutableDictionary*) post_params isLocation: (bool) isGetLocation;
+ (NSString *)getImei;
+ (NSString *)getPhone;
+ (CLLocationManager *) getLocationManager;
+ (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
+ (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
+ (void) releaseLocationManager;
+ (NSString*) getMacMD5Hash;
+ (NSString*) getMacSHA1Hash;

+ (CGSize)    getScreenResolution;
+ (NSString*) getDeviceOrientation;
+ (NSString*) getIdentifierForAdvertiser;
+ (NSString*) urlEncodeUsingEncoding:(NSStringEncoding)encoding withString:(NSString *)string;
+ (BOOL)      isConnectionAvailable;

+ (void)logWithPath:(char *)path line:(NSUInteger)line string:(NSString *)format, ...;
+ (void) resetCache:(NSString*)key;

+ (void) setObject:(NSData*)data forKey:(NSString*)key;
+ (id) objectForKey:(NSString*)key;

@end
