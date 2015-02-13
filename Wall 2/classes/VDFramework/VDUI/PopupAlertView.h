//
//  PopupAlertView.h
//  VietTVPro
//
//  Created by Mr. Luong on 5/15/13.
//
//

#import <UIKit/UIKit.h>
@class PopupAlertView;
@protocol PopupAlertViewDelegate
@optional
- (void) dismissPopupAlertViewWithIndex:(NSInteger)index;
- (void) didPopupAlertViewStartToShow;
@end

@interface PopupAlertView : UIViewController
{
    UIView*     baseView;
    UIView*     mainView;
    UILabel*    lblTitle;
    UILabel*    lblMessage;
    UIButton*   btnOK;
    UIButton*   btnCancel;
    UILabel*    lblBtnOK;
    
    CGRect      rectMainFrame;
    
    int         iSelectedBtnIndex;
    BOOL        bIsShowing;
    
    NSTimer     *_timerShowHide;
    
    id  delegate;
}
@property (nonatomic, assign) id<PopupAlertViewDelegate>  delegate;
@property (nonatomic, assign) UIView*   baseView;
@property (nonatomic, assign) BOOL isBeingShow;

- (id) initWithFrame:(CGRect)rect;

- (void) setTitleText:(NSString*)titleText;
- (void) setMessageText:(NSString*)msgText;
- (void) setOKText:(NSString*)okText;

- (void) showPopupView;
- (void) hidePopupView;
@end
