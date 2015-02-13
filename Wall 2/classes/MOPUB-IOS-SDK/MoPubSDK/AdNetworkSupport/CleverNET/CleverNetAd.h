

#import <Foundation/Foundation.h>

@interface CleverNetAd : NSObject {
    NSString* clickUrl;
    NSString* clickAction;
    NSString* bannerUrl;
    NSString* text;
    NSString* bannerType;
    NSString* beaconUrl;
    NSString* txtColor;
    NSString* txtBgColor;
    //NSString* p_oadest;
    bool hasBanner;
    bool shouldOpenInAppBrowser;
    int width;
    int height;
    double secondsToRefresh;
    bool mHasAds;
    
    NSString* actionType;
    NSString* tel;
    NSString* zoneType;
    
    NSString* mlistApp ;
    
	NSString* mlistOSBannedRMA ;
    
	bool mFullscreen;
    
	bool mIsLocation ;
	bool mresetData ;
    bool checkFullScreen ;
}

@property(nonatomic,retain) NSString *clickUrl;
//@property(nonatomic,retain) NSString *p_oadest;
@property(nonatomic,retain) NSString *clickAction;
@property(nonatomic,retain) NSString *bannerUrl;
@property(nonatomic,retain) NSString *text;
@property(nonatomic,retain) NSString *bannerType;
@property(nonatomic,retain) NSString *beaconUrl;
@property(nonatomic,retain) NSString* txtColor;
@property(nonatomic,retain) NSString* txtBgColor;

@property(nonatomic,retain) NSString* actionType;
@property(nonatomic,retain) NSString* tel;
@property(nonatomic,retain) NSString* zoneType;

@property bool hasBanner;
@property bool shouldOpenInAppBrowser;
@property int height;
@property int width;
@property double secondsToRefresh;
@property bool mHasAds;

@property(nonatomic,retain) NSString* mlistApp;
@property(nonatomic,retain) NSString* mlistOSBannedRMA;

@property bool mFullscreen;
@property bool mIsLocation;
@property bool mresetData;
@property bool checkFullScreen;

+(CleverNetAd*)initFromDictionary:(NSDictionary*) dictionary;
-(NSString*)to_html;
-(NSString*)to_htmlCustom;
-(void) setWidth:(int)w Height:(int)h;
-(NSString*)to_htmlfromText;

- (NSURL*) url;
- (Boolean)isValid;

@end
