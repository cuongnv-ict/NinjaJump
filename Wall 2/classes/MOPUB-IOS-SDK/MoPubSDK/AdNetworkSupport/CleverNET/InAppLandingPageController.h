

#import <UIKit/UIKit.h>
#import "CleverNetAd.h"

@class CleverNetView;

@interface InAppLandingPageController : UIViewController <UIWebViewDelegate> {
  CleverNetAd* ad;
  CleverNetView* cleverNetAd_view;
  UIView *banner_view;
  SEL onClose;
  UIView *banner_container;
  UIActivityIndicatorView *spinner;
  UIView *overlay;
  UIWebView* webview;
}

@property(nonatomic,retain) CleverNetAd* ad;
@property(nonatomic,retain) CleverNetView* cleverNetAd_view;
@property(nonatomic,retain) UIView* banner_view;
@property SEL onClose;


@end
