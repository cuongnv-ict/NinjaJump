

#import "CleverNetAd.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "InAppLandingPageController.h"
#import "CleverNetDelegationProtocol.h"


// enum of available banner formats
typedef enum tagCleverNetAdClass {
    custom,mma,medium_rectangle,leaderboard,fullscreen,portrait,landscape, RichMedia,IphonePreloader,IpadPreloader,IphonePreloaderLandscape,IpadPreloaderPortrait
} CleverNetAdClass;


@class CleverNetAd;

@protocol MRAdViewDelegate;

typedef NSUInteger MRAdViewPlacementType;


@interface CleverNetView : UIView<UIWebViewDelegate, MRAdViewDelegate> {
    
    // attributes
    InAppLandingPageController* inAppLandingPageController;
    id<CleverNetDelegationProtocol> cleverNetDelegate;           // the delegate which receives ad related events like: adLoaded or adLoadFailed
    NSMutableDictionary* post_params;
    NSMutableData* receivedData;                            // data received thorugh the connection to the ad server
    NSMutableURLRequest* request;
    NSURLConnection *conn;                                  // current request object
    
    CleverNetAd* currentAd;                                 // current ad
    CleverNetAdClass currentAdClass;                        // ad type
    MRAdViewPlacementType placementType;
    
    NSInteger responseCode;                                 // flag that indicates if http response from ad server is ok
    bool isBannerMode;                                      // flag that indicates if the view shows a banner or a popup
        
    UIView* currentView;
    UIView* nextView;
    UIView* currentViewFull;
    
    NSLock* lock;                                           // lock which is used to avoid race conditions while requesting an ad
    
    NSTimer* timer;                                         // the ad rotation timer
    double interval;                                        // interval of ad refresh
    Boolean reload;
    int x, y;                                               // Position
    bool isCustom;
    double animationDuration;
    CleverNetAnimationClass animationType;
    // TextAds config color
    UIColor* txtBGColor;
    UIColor* txtTextColor;
    int customAdWidth;
    int customAdHeight;
    bool mCustomEvent;
    Boolean suspended;
    
}


/////////////////
/// constructor
////////////////


@property (nonatomic,retain) id<CleverNetDelegationProtocol> cleverNetDelegate;
@property CleverNetAdClass currentAdClass;
@property (nonatomic, retain) UIView *currentView;
@property (nonatomic, retain) UIView *nextView;
@property (nonatomic, retain) UIView *currentViewFull;

@property (nonatomic, retain) NSMutableURLRequest *request;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, retain) NSMutableData *receivedData;

+ (CleverNetView*)loadAdWithDelegate:(id<CleverNetDelegationProtocol>)delegate secondsToRefresh:(int)secondsToRefresh includeFullscreen:(bool)mincludeFullscreen;
+ (CleverNetView*)loadOneAdWithDelegate:(id<CleverNetDelegationProtocol>)delegate onlyFullscreen:(bool)onlyFullscreen;
+ (void) adLoadedHandlerWithObserver:(id) addObserver AndSelector:(SEL) selector;
+ (void) adLoadFailedHandlerWithObserver:(id) addObserver AndSelector:(SEL) selector;
+ (void) adClickedAdHandlerWithObserver:(id) observer AndSelector:(SEL) selector;
- (void)place_at_x:(int)x_pos y:(int)y_pos;               // position the frame for the view
- (void) setWidth:(int)w Height:(int)h;
- (void)setHadViewFullScreen:(bool)fullscreen;
- (void)clickProcess:(NSString *) url;

@end
