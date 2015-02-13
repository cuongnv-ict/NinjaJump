#import <UIKit/UIKit.h>
//#import "ADViewController.h"

@class RootViewController;

@interface AppController : NSObject <UIApplicationDelegate,UIAlertViewDelegate> {
    UIWindow *window;
    //ADViewController *adFullScreenCtrl;
    
}

@property(nonatomic, readonly) RootViewController* viewController;

- (void) showRateApp;
- (void) showLeaderBoard;
- (void) submitHighScoreToGameCenter:(int)iScore;
- (void) setShowHideAdv:(bool)bShow;
- (void) showAlertBonusPoint;
- (void) showAlertViewHint;
@end

