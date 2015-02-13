
#import <UIKit/UIKit.h>

@interface CleverNetTextAdView : UIView {
    NSString* text;
}

@property(nonatomic,retain) NSString *text;
+ (CleverNetTextAdView*)withText:(NSString*)text withBGColor:(UIColor*) bgColor withTextColor:(UIColor *) txtColor;
@end
