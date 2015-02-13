

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CleverNetTracker : NSObject {
	
}

// sends a request on first start to the cleverNet server
// !!call setDebugMode and setProductToken before!!
+ (void) reportActionToCleverNet: (NSString*) action_type;

// set debug mode, default is NO
+ (void) setDebugMode: (BOOL) debugMode;

// set product token, that you will geth from cleverNet
+ (void) setProductToken: (NSString *) productToken;

+ (void) enable;

@end
