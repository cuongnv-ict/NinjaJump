//
//  InAppPurchase.h
//  VietTVPro
//
//  Created by Mr. Hiep on 11/11/13.
//
//

#import <UIKit/UIKit.h>
@class InAppPurchase;
@protocol InAppPurchaseDelegate
@optional
- (void) didDismissInAppPurchaseWithIndex:(int)index;
- (void) didInAppViewStartToShow;
@end

@interface InAppPurchase : UIViewController
{
    UIView*     baseView;
    UIView*     mainView;

    UIButton*   btnOK;
    UIButton*   btnCancel;
   
    CGRect      rectMainFrame;
    
    int         iSelectedBtnIndex;
    BOOL        bIsShowing;
    
    NSTimer     *_timerShowHide;
    
    id<InAppPurchaseDelegate>  delegate;

}
@property (nonatomic, assign) id<InAppPurchaseDelegate>  delegate;
@property (nonatomic, assign) UIView*   baseView;
@property (nonatomic, assign) BOOL bIsShowing;

- (id) initWithFrame:(CGRect)rect;
- (void) setNewFrame:(CGRect)newRect;

- (void) showInAppView;
- (void) hideInAppView;

- (void) updateBaseViewFrame:(CGRect)newRect;

@end
