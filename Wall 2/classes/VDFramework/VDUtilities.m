//
//  VDUtilities.m
//  vietradio
//
//  Created by VietDorje on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VDUtilities.h"
#import "Reachability.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#import <objc/runtime.h>


@implementation UIAlertView (Context)
static char ContextPrivateKey;
-(void)setMyUserInfo:(NSDictionary *)myUserInfo
{
    objc_setAssociatedObject(self, &ContextPrivateKey, myUserInfo, OBJC_ASSOCIATION_RETAIN);
}
-(NSDictionary *)myUserInfo
{
    return objc_getAssociatedObject(self, &ContextPrivateKey);
}
@end


@implementation UINavigationController (iOS6OrientationFix)

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations
{
    if([self.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return [self.topViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end


@implementation UITabBarController (iOS6OrientationFix)

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations
{
    if([self.selectedViewController respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return [self.selectedViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end


@implementation VDUtilities

+ (BOOL)isiPhone5Screen
{
    return ([UIScreen mainScreen].bounds.size.height == 568);
}

+ (BOOL)isMultitaskingSupported
{
	UIDevice* device = [UIDevice currentDevice];
	BOOL backgroundSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		backgroundSupported = device.multitaskingSupported;
	
	return backgroundSupported;
}

+ (int)getRandomIntValue:(int)nN
{
	srand (time(NULL));
	return (rand() % nN);
}


+ (NSString*)getProductOnAppStoreURL
{
    NSString* sConfigFilePathInBundle = [[NSBundle mainBundle] pathForResource:kFileNameAppConfig ofType:kFileExtension inDirectory:DIRNAME_CHANNEL_DATA];
    NSMutableDictionary* g_appConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:sConfigFilePathInBundle];
    
	return [g_appConfig objectForKey:kURLProductOnAppStore];
}

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

+ (BOOL)checkInternetConnectionViaWifi
{
	Reachability* re = [Reachability reachabilityForInternetConnection];
	if (!re || [re currentReachabilityStatus] != ReachableViaWiFi)
		return NO;
	return YES;
}

+ (NSString *)getMachineName
{
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name =(char*)malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	NSString *machine = [NSString stringWithCString:name];
	
	// Done with this
	free(name);
	
	return machine;
}

//Add text to UIImage
+(UIImage *)addText:(UIImage *)img text:(NSString *)text1
{
	CGFloat flScale = 1.0;
//	if([UIScreen instancesRespondToSelector:@selector(scale)])
//		flScale = [[UIScreen mainScreen] scale];
	
	if([UIImage instancesRespondToSelector:@selector(scale)])
		flScale = [img scale];
	
    int w = img.size.width*flScale;
    int h = img.size.height*flScale;

	NSString* text = [text1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	UIGraphicsBeginImageContext(CGSizeMake(w, h));

	[img drawInRect:CGRectMake(0, 0, w, h)];
	
/*    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);*/
	
	CGFloat space = 8*w/96;
	//CGRect textRect = CGRectMake(0, 0, w, h/2);
	CGFloat maxFontSize = 40;
	CGFloat minFontSize = 16;
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) 
	{
		maxFontSize = 26;
		minFontSize = 13;
	}else {
		if(([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)){
			maxFontSize = 24;
			minFontSize = 13;
		}else {
			maxFontSize = 24;
			minFontSize = 13;
		}
	}

	NSString* fontName = @"Arial-BoldMT";
	UIFont* font = [UIFont fontWithName:fontName size:maxFontSize];
	CGFloat fontSize;
	CGSize size = [text sizeWithFont:font minFontSize:minFontSize actualFontSize:&fontSize forWidth:(w-space*2) lineBreakMode:UILineBreakModeTailTruncation];
	
	font = [UIFont fontWithName:fontName size:fontSize];
	size = [text sizeWithFont:font forWidth:(w-space*2) lineBreakMode:UILineBreakModeTailTruncation];
	
	[[UIColor whiteColor] set];
	//[text1 drawAtPoint:CGPointMake((w-size.width)/2, (h/2-size.height)/2) withFont:font];
	[text drawInRect:CGRectMake((w-size.width)/2, (h/2-size.height)/2+4, size.width, size.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation];
	
	UIImage* pImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if (flScale == 2.0 && [UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
		return [UIImage imageWithCGImage:pImg.CGImage scale:2.0 orientation:UIImageOrientationUp];
	else 
		return [UIImage imageWithCGImage:pImg.CGImage];
}

+ (UIImage *)createImageWithText:(NSString *)text imageSize:(CGSize)imgSize
{
	CGFloat flScale = 1.0;
	if([UIScreen instancesRespondToSelector:@selector(scale)])
		flScale = [[UIScreen mainScreen] scale];
	
    int w = imgSize.width*flScale;
    int h = imgSize.height*flScale;
	
	UIGraphicsBeginImageContext(CGSizeMake(w, h));
	
	CGFloat space = 2*flScale;
	CGFloat maxFontSize = 30;
	CGFloat minFontSize = 10;
	
	//NSString* fontName = @"Arial";
	//UIFont* font = [UIFont fontWithName:fontName size:maxFontSize];
	UIFont *font = [UIFont systemFontOfSize:maxFontSize];
	CGFloat fontSize;
	CGSize size = [text sizeWithFont:font minFontSize:minFontSize actualFontSize:&fontSize forWidth:(w-space*2) lineBreakMode:UILineBreakModeTailTruncation];
	//font = [UIFont fontWithName:fontName size:fontSize];
	font = [UIFont systemFontOfSize:fontSize];
	size = [text sizeWithFont:font forWidth:(w-space*2) lineBreakMode:UILineBreakModeTailTruncation];
	
	[[UIColor blueColor] set];
	[text drawInRect:CGRectMake(0, (h-size.height)/2, w, h) withFont:font lineBreakMode:UILineBreakModeTailTruncation];
	
	UIImage* pImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if (flScale == 2.0 && [UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
		return [UIImage imageWithCGImage:pImg.CGImage scale:2.0 orientation:UIImageOrientationUp];
	else 
		return [UIImage imageWithCGImage:pImg.CGImage];
}

+ (NSString*)getStringDurationFromSeconds:(NSInteger)nSeconds
{
	NSInteger hours=nSeconds/3600;
	NSInteger minutes=(nSeconds-hours*3600)/60;
	NSInteger seconds=nSeconds-hours*3600-minutes*60;
	
	NSString* strHours=hours<10?[NSString stringWithFormat:@"0%d",hours]:[NSString stringWithFormat:@"%d",hours];
	NSString* strMinutes=minutes<10?[NSString stringWithFormat:@"0%d",minutes]:[NSString stringWithFormat:@"%d",minutes];
	NSString* strSeconds=seconds<10?[NSString stringWithFormat:@"0%d",seconds]:[NSString stringWithFormat:@"%d",seconds];
	
	if (hours > 0)
		return [NSString stringWithFormat:@"%@:%@:%@",strHours,strMinutes,strSeconds];
	else 
		return [NSString stringWithFormat:@"%@:%@",strMinutes,strSeconds];
}

+ (NSData*) downloadContentFromURL:(NSString*)sURL
{
	int nTimeOut = 10;
	NSURLRequest *pTheRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:sURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:nTimeOut];
	if (!pTheRequest) return nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:pTheRequest returningResponse:nil error:nil]; 
	return returnData;
}

+ (BOOL) downLoadFileFromURL:(NSString*)sURL toFolderPath:(NSString*) sFolderPath withFileName:(NSString*) sFileName:(BOOL) isOverWritten
{
    // Create folder to store file if not exist
	[[NSFileManager defaultManager] createDirectoryAtPath:sFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
	
	NSString* sDesFilePath = nil;	
	if ([sFileName length] > 0)
		sDesFilePath = [NSString stringWithFormat:@"%@/%@", sFolderPath, sFileName];
	else 
		sDesFilePath = [NSString stringWithFormat:@"%@/%@", sFolderPath, [sURL lastPathComponent]];
	
    // Not overwritten file if exist
	if ([[NSFileManager defaultManager] fileExistsAtPath:sDesFilePath] &&
		!isOverWritten) return YES;
	
    NSData *returnData = [self downloadContentFromURL:sURL];
	if (!returnData) return NO;
	
// Check file not found on server error	
	NSString* sData = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding]; 
	if ([sData length] > 0 && ([sData rangeOfString:@"Not Found" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                               [sData rangeOfString:@"Error 404" options:NSCaseInsensitiveSearch].location != NSNotFound))
	{
        //NSLog(@"404 Not Found");
		[sData release];
		return NO;
	}
    
    if ([sData length] > 0 && [sData rangeOfString:@"not found" options:NSCaseInsensitiveSearch].location != NSNotFound)
	{
        //NSLog(@"not found");
		[sData release];
		return NO;
	}    
    
    [sData release];
    
	if (![[NSFileManager defaultManager] createFileAtPath:sDesFilePath contents:returnData attributes:nil]) 
		return NO;
	
    //NSLog(@"Downloaded file OK");
	return YES;
	
}

+ (BOOL)checkInternetConnection
{
	Reachability* re = [Reachability reachabilityForInternetConnection];
	if (!re || [re currentReachabilityStatus] == NotReachable)
		return NO;
	
	return YES;
}

+ (BOOL)timeIs24HourFormat 
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
    [formatter release];
    return is24Hour;
}

+ (NSString *)generateRecordFileNameWithChannelSymbol:(NSString *)sChannelSymbol
{
	NSDateFormatter* f=[[NSDateFormatter alloc] init];
	f.dateFormat=@"yyyyMMdd_HHmmss";
	[f setPMSymbol:@"PM"];
	[f setAMSymbol:@"AM"];
	NSString* name=[f stringFromDate:[NSDate date]];
	[f release];
	return [NSString stringWithFormat:@"%@_%@",sChannelSymbol,name];
}

+ (BOOL) bIsIOS7Version
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7) return NO;
    return YES;
}

+ (BOOL) bIsIOS8Version
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8) return NO;
    return YES;
}

/*
NSString* getRecordDateTimeString(NSDate* date)
{
	NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
	
	if (g_bTimeIs24HourFormat)
		formatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
	else
	{
		formatter.dateFormat=@"dd/MM/yyyy HH:mm:ss a";
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
	}
	NSString* s	=[formatter stringFromDate:date];
	[formatter release];
	
	if (g_bTimeIs24HourFormat) return s;
	
	NSString* sBegin = [s substringToIndex:11];
	NSInteger nHour = [[s substringWithRange:NSMakeRange(11, 2)] intValue];
	NSString* sEnd = [s substringFromIndex:13];
	if (nHour > 12) nHour -= 12;
	
	if (nHour < 10)
		return [NSString stringWithFormat:@"%@0%d%@", sBegin, nHour, sEnd];
	else
		return [NSString stringWithFormat:@"%@%d%@", sBegin, nHour, sEnd];
}
*/

@end





int compareDays(NSDate* date1, NSDate* date2)
{
	NSInteger result=0;
	NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
	formatter.dateFormat=@"yyyyMMdd";
	NSString* d1=[formatter stringFromDate:date1];
	NSString* d2=[formatter stringFromDate:date2];
	NSInteger year1=[[d1 substringToIndex:4] intValue];
	NSInteger year2=[[d2 substringToIndex:4] intValue];
	if(year1>year1){
		result=1;
	}
	else if(year1<year2){
		result=-1;
	}
	else {
		char* x1=(char*)[d1 UTF8String];
		char* x2=(char*)[d2 UTF8String];
		NSInteger month1=[[NSString stringWithFormat:@"%d%d",x1[4]-48,x1[5]-48] intValue];
		NSInteger month2=[[NSString stringWithFormat:@"%d%d",x2[4]-48,x2[5]-48] intValue];
		if(month1>month2){
			result=1;
		}
		else if(month1<month2){
			result=-1;
		}
		else {
			NSInteger day1=[[d1 substringFromIndex:6] intValue];
			NSInteger day2=[[d2 substringFromIndex:6] intValue];
			if (day1>day2) {
				result=1;
			}
			
			else if(day1<day2){
				result=-1;
			}
		}
	}
	[formatter release];
	return result;
}

int compareTimeHourMinute(NSDate* date1, NSDate* date2)
{
	NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
	formatter.dateFormat=@"HH:mm a";
	NSString* s1 = [formatter stringFromDate:date1];
	NSString* s2 = [formatter stringFromDate:date2];
	int nAPM1 = 0;
	if ([s1 rangeOfString:[formatter PMSymbol]].location != NSNotFound)
		nAPM1++;
	int nAPM2 = 0;
	if ([s2 rangeOfString:[formatter PMSymbol]].location != NSNotFound)
		nAPM2++;
	
	[formatter release];
	
	if([s1 isEqualToString:s2]) return 0;
	
	if (nAPM1 < nAPM2) 
		return -1;
	else if (nAPM1 > nAPM2) 
		return 1;
	else 
	{
		int hour1 = [[s1 substringToIndex:2] intValue];
		int hour2 = [[s2 substringToIndex:2] intValue];
		if(hour1 < hour2) 
			return -1;
		else if(hour1 > hour2) 
			return 1;
		else 
		{
			
			int min1 = [[s1 substringWithRange:NSMakeRange(3, 2)] intValue];
			int min2 = [[s2 substringWithRange:NSMakeRange(3, 2)] intValue];
			if(min1 < min2)
				return -1;
			else if(min1 > min2)
				return 1;
			else 
				return 0;
			
		}
	}
}
