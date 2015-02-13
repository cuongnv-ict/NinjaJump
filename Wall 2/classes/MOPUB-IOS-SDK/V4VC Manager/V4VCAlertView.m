//
//  V4VCAlertView.m
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 7/11/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import "V4VCAlertView.h"
#import <QuartzCore/QuartzCore.h>

/**
 *  Thêm một số Notifications từ MPMediationAdViewController, để ẩn pop-up notifications khi có một ad bung lên full màn hình
 */
#import "AdNetworkKeyConfig.h"

#define kAlertWidth         320.0f
#define kAlertHeight        220.0f

#define kTitleYOffset       25.0f
#define kTitleHeight        25.0f

#define kContentOffset      30.0f

#define kBetweenLabelOffset 20.0f
#define kSingleButtonWidth  160.0f
#define kCoupleButtonWidth  107.0f
#define kButtonHeight       40.0f
#define kButtonBottomOffset 10.0f

#define POPUP_ALERT_SHOWING_INTERVAL    15

@interface V4VCAlertView ()
{
    BOOL        _autoDismiss;
    
    NSTimer*    _showHidePopupAlertTimer;
    BOOL        _isShowing;
}

@property (nonatomic, strong) UILabel *alertTitleLabel;
@property (nonatomic, strong) UILabel *alertContentLabel;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIView *backImageView;

@end

@implementation V4VCAlertView

+ (CGFloat)alertWidth
{
    return kAlertWidth;
}

+ (CGFloat)alertHeight
{
    return kAlertHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
        contentText:(NSString *)content
    leftButtonTitle:(NSString *)leftTitle
   rightButtonTitle:(NSString *)rigthTitle
{
    if (self = [super init]) {
        
        _autoDismiss = YES;
        
        _showHidePopupAlertTimer = nil;
        _isShowing = NO;
        
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1];//[UIColor whiteColor];
        
        UIImageView* imageBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAlertWidth, kAlertHeight)];
        imageBackgroundView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1];
        UIImage *image = [UIImage imageNamed:@"Info_bgr.png"];
        imageBackgroundView.image = image;
        [self addSubview:imageBackgroundView];
        
        if (title && [title length] > 0)
        {
            self.alertTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTitleYOffset, kAlertWidth, kTitleHeight)];
            self.alertTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
            self.alertTitleLabel.textColor =[UIColor whiteColor];// [UIColor colorWithRed:56.0/255.0 green:64.0/255.0 blue:71.0/255.0 alpha:1];
            [self addSubview:self.alertTitleLabel];
            self.alertTitleLabel.backgroundColor = [UIColor clearColor];
            
            CGFloat contentLabelWidth = kAlertWidth - 16;
            CGFloat contentLabelHeight = kAlertHeight - kTitleYOffset - kTitleHeight - kButtonBottomOffset - kButtonHeight;
            self.alertContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((kAlertWidth - contentLabelWidth) * 0.5, CGRectGetMaxY(self.alertTitleLabel.frame), contentLabelWidth, contentLabelHeight)];
            self.alertContentLabel.numberOfLines = 0;
            self.alertContentLabel.textAlignment = self.alertTitleLabel.textAlignment = NSTextAlignmentCenter;
            self.alertContentLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1];
            self.alertContentLabel.font = [UIFont systemFontOfSize:15.0f];
            [self addSubview:self.alertContentLabel];
            self.alertContentLabel.backgroundColor = [UIColor clearColor];
        }
        else
        {
            CGFloat contentLabelWidth = kAlertWidth - 16;
            CGFloat contentLabelHeight = kAlertHeight - kTitleYOffset - kTitleHeight - kButtonBottomOffset - kButtonHeight;
            self.alertContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((kAlertWidth - contentLabelWidth) * 0.5, kTitleYOffset, contentLabelWidth, contentLabelHeight)];
            self.alertContentLabel.numberOfLines = 0;
            self.alertContentLabel.textAlignment = self.alertTitleLabel.textAlignment = NSTextAlignmentCenter;
            self.alertContentLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1];
            self.alertContentLabel.font = [UIFont systemFontOfSize:15.0f];
            [self addSubview:self.alertContentLabel];
            self.alertContentLabel.backgroundColor = [UIColor clearColor];
        }

        self.alertContentLabel.textAlignment = NSTextAlignmentLeft;
        
        CGRect leftBtnFrame;
        CGRect rightBtnFrame;

        if (!leftTitle || [leftTitle length] <= 0)
        {
            rightBtnFrame = CGRectMake((kAlertWidth - kSingleButtonWidth) * 0.5, kAlertHeight - kButtonBottomOffset - kButtonHeight, kSingleButtonWidth, kButtonHeight);
            self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.rightBtn.frame = rightBtnFrame;
            
        }
        else
        {
            leftBtnFrame = CGRectMake((kAlertWidth - 2 * kCoupleButtonWidth - kButtonBottomOffset) * 0.5, kAlertHeight - kButtonBottomOffset - kButtonHeight, kCoupleButtonWidth, kButtonHeight);
            rightBtnFrame = CGRectMake(CGRectGetMaxX(leftBtnFrame) + kButtonBottomOffset, kAlertHeight - kButtonBottomOffset - kButtonHeight, kCoupleButtonWidth, kButtonHeight);
            self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.leftBtn.frame = leftBtnFrame;
            self.rightBtn.frame = rightBtnFrame;
        }
        
        [self.rightBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:87.0/255.0 green:135.0/255.0 blue:173.0/255.0 alpha:1]] forState:UIControlStateNormal];
        [self.leftBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:227.0/255.0 green:100.0/255.0 blue:83.0/255.0 alpha:1]] forState:UIControlStateNormal];
        [self.rightBtn setTitle:rigthTitle forState:UIControlStateNormal];
        [self.leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        self.leftBtn.titleLabel.font = self.rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.leftBtn.layer.masksToBounds = self.rightBtn.layer.masksToBounds = YES;
        self.leftBtn.layer.cornerRadius = self.rightBtn.layer.cornerRadius = 3.0;
        [self addSubview:self.leftBtn];
        [self addSubview:self.rightBtn];
        
        self.alertTitleLabel.text = title;
        self.alertContentLabel.text = content;
        
        UIButton *xButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [xButton setImage:[UIImage imageNamed:@"btn_close_normal3.png"] forState:UIControlStateNormal];
        [xButton setImage:[UIImage imageNamed:@"btn_close_selected.png"] forState:UIControlStateHighlighted];
        xButton.frame = CGRectMake(kAlertWidth - 32, 0, 32, 32);
        //xButton.frame = CGRectMake(kAlertWidth - 44 + 5, - 5, 44, 44);
        [self addSubview:xButton];
        [xButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
        
        [self initNotifications];
    }
    return self;
}

- (id) initWithTitle:(NSString *)title contentText:(NSString *)content leftButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rigthTitle autoDismiss:(BOOL)autoDismiss
{
    self = [self initWithTitle:title contentText:content leftButtonTitle:leftTitle rightButtonTitle:rigthTitle];
    
    _autoDismiss = autoDismiss;
    
    return self;
}

- (void) initNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyDidChangeStatusBarOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kNotifyMPBannerAdViewWillPresentModalView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kNotifyMPBannerAdViewWillLeaveAppFromAd object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kInterstitialAdWillAppear object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kStartV4VCVideoWatching object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kNotifyFullscreenAdIsForcedToBeShow object:nil];
}

#pragma mark - Notifications
- (void) notifyDidChangeStatusBarOrientation
{
    UIViewController *topVC = [self appRootViewController];
    CGRect afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, CGRectGetHeight(topVC.view.bounds), kAlertWidth, kAlertHeight);
    
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight)/2, kAlertWidth, kAlertHeight);
            }
            else
            {
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight)/2, kAlertWidth, kAlertHeight);
            }
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, kAlertHeight, kAlertWidth, kAlertHeight);
            }
            else
            {
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, kAlertHeight, kAlertWidth, kAlertHeight);
            }
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            break;
            
        default:
            break;
    }
    
    
    [UIView animateWithDuration:0.35f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = afterFrame;
    } completion:^(BOOL finished) {
    }];

}

- (void) onNotifyAdWillShowFullscreen
{
    if (_autoDismiss)
    {
       [self dismissAlert];
    }
}

#pragma mark - Handle Actions

- (void)leftBtnClicked:(id)sender
{
    [self dismissAlert];
    if (self.leftBlock) {
        self.leftBlock();
    }
}

- (void)rightBtnClicked:(id)sender
{
    [self dismissAlert];
    if (self.rightBlock) {
        self.rightBlock();
    }
}

- (void) closeButtonClicked:(id)sender
{
    [self dismissAlert];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

- (void)show
{
    UIViewController *topVC = [self appRootViewController];
    self.frame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, - kAlertHeight - 30, kAlertWidth, kAlertHeight);
    
    [topVC.view addSubview:self];
    
    _isShowing = YES;
    
    if (_autoDismiss)
    {
        if (_showHidePopupAlertTimer)
        {
            [_showHidePopupAlertTimer invalidate];
            _showHidePopupAlertTimer = nil;
        }
        
        _showHidePopupAlertTimer = [NSTimer scheduledTimerWithTimeInterval:POPUP_ALERT_SHOWING_INTERVAL target:self selector:@selector(hideV4VCPopupAlert) userInfo:nil repeats:YES];
    }
}

- (void) hideV4VCPopupAlert
{
    if (_showHidePopupAlertTimer)
    {
        [_showHidePopupAlertTimer invalidate];
        _showHidePopupAlertTimer = nil;
    }
    
    [self dismissAlert];
}

- (void)dismissAlert
{
    if (_isShowing)
    {
        _isShowing = NO;
        
        if (_showHidePopupAlertTimer)
        {
            [_showHidePopupAlertTimer invalidate];
            _showHidePopupAlertTimer = nil;
        }
        
        [self removePopupFromSuperview];
    }
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


- (void) removePopupFromSuperview
{
    NSLog(@"V4VC AlertVIew: removeFromSuperview");
    
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
    UIViewController *topVC = [self appRootViewController];
    CGRect afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, CGRectGetHeight(topVC.view.bounds), kAlertWidth, kAlertHeight);

    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                 afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, CGRectGetHeight(topVC.view.bounds), kAlertWidth, kAlertHeight);
            }
            else
            {
                 afterFrame = CGRectMake(- kAlertWidth, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            }
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, 0, kAlertWidth, kAlertHeight);
            }
            else
            {
                afterFrame = CGRectMake(- kAlertWidth * 2, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            }
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            afterFrame = CGRectMake(- kAlertWidth, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            afterFrame = CGRectMake(CGRectGetWidth(topVC.view.bounds), (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            break;
            
        default:
            break;
    }

    
    [UIView animateWithDuration:0.35f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = afterFrame;
        //self.alpha = 0.2;
    } completion:^(BOOL finished) {
        if ([super respondsToSelector:@selector(removeFromSuperview)])
            //[super removeFromSuperview];
            [self removeFromSuperview];
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil)
    {
        return;
    }
    
    UIViewController *topVC = [self appRootViewController];
    
    if (!self.backImageView)
    {
        self.backImageView = [[UIView alloc] initWithFrame:topVC.view.bounds];
        self.backImageView.backgroundColor = [UIColor blackColor];
        self.backImageView.alpha = 0.6f;
        self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    [topVC.view addSubview:self.backImageView];
    
    CGRect beforeFrame;
    CGRect afterFrame;
    
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                beforeFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, CGRectGetHeight(topVC.view.bounds), kAlertWidth, kAlertHeight);
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, CGRectGetHeight(topVC.view.bounds) - kAlertHeight, kAlertWidth, kAlertHeight);
            }
            else
            {
                beforeFrame = CGRectMake(- kAlertWidth, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            }
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                beforeFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, 0, kAlertWidth, kAlertHeight);
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, kAlertHeight, kAlertWidth, kAlertHeight);
            }
            else
            {
                beforeFrame = CGRectMake(- kAlertWidth, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
                afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            }
            
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            beforeFrame = CGRectMake(- kAlertWidth, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            beforeFrame = CGRectMake(CGRectGetWidth(topVC.view.bounds), (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - kAlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - kAlertHeight) * 0.5, kAlertWidth, kAlertHeight);
            break;
            
        default:
            break;
    }

    self.frame = beforeFrame;
    [UIView animateWithDuration:0.35f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = afterFrame;
    } completion:^(BOOL finished) {
    }];
    
    [super willMoveToSuperview:newSuperview];
}

@end

@implementation UIImage (colorful)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
