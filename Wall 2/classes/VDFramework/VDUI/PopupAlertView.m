//
//  PopupAlertView.m
//  VietTVPro
//
//  Created by Mr. Luong on 5/15/13.
//
//

#import "PopupAlertView.h"
#import "VDUIImage.h"
#import "VDUtilities.h"

/**
 *  Thêm một số Notifications từ MPMediationAdViewController, để ẩn pop-up notifications khi có một ad bung lên full màn hình
 */
#import "AdNetworkKeyConfig.h"

#define TIME_INTERVAL_ANIMATE   0.5
#define TIME_INTERVAL_SHOWING   18

@interface PopupAlertView ()

@end

@implementation PopupAlertView

@synthesize delegate;
@synthesize baseView;
-(id) initWithFrame:(CGRect)rect
{
    if (self = [super init])
    {
        rectMainFrame = rect;
        baseView = [[UIView alloc] initWithFrame:rectMainFrame];
        
        iSelectedBtnIndex = 0;
        
        delegate = nil;
        
        self.isBeingShow = NO;
        
        [self initNotifications];
    }
    
    return self;
}

- (void) initNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kNotifyMPBannerAdViewWillPresentModalView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kNotifyMPBannerAdViewWillLeaveAppFromAd object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kInterstitialAdWillAppear object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kStartV4VCVideoWatching object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAdWillShowFullscreen) name:kNotifyFullscreenAdIsForcedToBeShow object:nil];
}


-(void) dealloc
{
     
    
    delegate = nil;
    [baseView release];
    
    [super dealloc];
}

-(void) loadView
{
    [super loadView];
    
    
    baseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:baseView];
    
    CGRect rectTest = baseView.frame;
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, rectMainFrame.size.height, rectMainFrame.size.width, rectMainFrame.size.height)];
    mainView.backgroundColor = [UIColor colorWithPatternImage:[[VDUIImage imageNamed:@"popup_alert_bgr.png"] imageScaledToSize:rectMainFrame.size]];
    [baseView addSubview:mainView];
    [mainView release];


    CGRect rectBtnClose, rectBtnOK, rectLabelTitle, rectLabelMessage;
    if ([VDUtilities isiPhone5Screen])
    {
        /* Height : 230 = 30 + 30 + 120 + 50 */
//        int btnCloseW = 30;
//        int btnCloseH = 30;
        int btnCloseW = 44;
        int btnCloseH = 44;
        int headerH = 30;
        int btnOkW = 180;
        int btnOkH = 50;
        
        rectBtnClose = CGRectMake(rectMainFrame.size.width - btnCloseW + 6, 6, btnCloseW - 6, btnCloseH - 6);
        rectLabelTitle = CGRectMake(10, 30, rectMainFrame.size.width - 20, headerH);
        rectLabelMessage = CGRectMake(10, headerH + 30, rectMainFrame.size.width - 20, rectMainFrame.size.height - headerH - btnOkH - 30 - 10);
        rectBtnOK = CGRectMake(rectMainFrame.size.width/2 - btnOkW/2, rectMainFrame.size.height - btnOkH  + 2, btnOkW, btnOkH - 10);
    }
    else
    {
        /* Height : 190 = 30(30) + 115 + 45 */
//        int btnCloseW = 30;
//        int btnCloseH = 30;
        int btnCloseW = 44;
        int btnCloseH = 44;
        int headerH = 30;
        int btnOkW = 190;
        int btnOkH = 45;
        
        rectBtnClose = CGRectMake(rectMainFrame.size.width - btnCloseW + 4, 6, btnCloseW - 2, btnCloseH - 2);
        rectLabelTitle = CGRectMake(10, 10, rectMainFrame.size.width - 20, headerH);
        rectLabelMessage = CGRectMake(10, headerH, rectMainFrame.size.width - 20, rectMainFrame.size.height - headerH - btnOkH - 8);
        rectBtnOK = CGRectMake(rectMainFrame.size.width/2 - btnOkW/2, rectMainFrame.size.height - btnOkH  - 2, btnOkW, btnOkH - 5);
    }
    
    lblTitle = [[UILabel alloc] initWithFrame:rectLabelTitle];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont boldSystemFontOfSize:20];
    lblTitle.text = @"Title";
    [mainView addSubview:lblTitle];
    [lblTitle release];    

    btnCancel = [[UIButton alloc] initWithFrame:rectBtnClose];
    [btnCancel setImage:[VDUIImage imageNamed:@"popup_alert_del_btn2.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCloseClicked) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:btnCancel];
    [btnCancel release];
    
    lblMessage = [[UILabel alloc] initWithFrame:rectLabelMessage];
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.textAlignment = NSTextAlignmentCenter;
    lblMessage.lineBreakMode = NSLineBreakByWordWrapping;
    lblMessage.textColor = [UIColor whiteColor];
    lblMessage.numberOfLines = 0;
    lblMessage.text = @"Message's content";
    [mainView addSubview:lblMessage];
    [lblMessage release];    
    
    btnOK = [[UIButton alloc] initWithFrame:rectBtnOK];
    [btnOK setImage:[VDUIImage imageNamed:@"popup_alert_btn_bgr.png"] forState:UIControlStateNormal];
    [btnOK addTarget:self action:@selector(btnOKClicked) forControlEvents:UIControlEventTouchUpInside];
    btnOK.titleLabel.textColor = [UIColor whiteColor];
    [mainView addSubview:btnOK];
    [btnOK release];
    
    lblBtnOK = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnOK.frame.size.width, btnOK.frame.size.height)];
    lblBtnOK.backgroundColor = [UIColor clearColor];
    lblBtnOK.textColor = [UIColor whiteColor];
    lblBtnOK.font = [UIFont boldSystemFontOfSize:18];
    lblBtnOK.textAlignment = NSTextAlignmentCenter;
    lblBtnOK.text = @"OK";
    [btnOK addSubview:lblBtnOK];
    [lblBtnOK release];
    
    
    bIsShowing = NO;
    baseView.hidden = YES;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setTitleText:(NSString*)titleText
{
    lblTitle.text = titleText;
}

- (void) setMessageText:(NSString*)msgText
{
    lblMessage.text = msgText;
}

- (void) setOKText:(NSString*)okText
{
    lblBtnOK.text = okText;
}

-(void) fadeIn
{
    NSLog(@"Show popup alert");
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:TIME_INTERVAL_ANIMATE];
    mainView.frame =  CGRectMake(0, 0, rectMainFrame.size.width, rectMainFrame.size.height);
    
    [UIView commitAnimations];
    
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:baseView];
}

-(void) fadeOut
{
    NSLog(@"Hide popup alert");
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:TIME_INTERVAL_ANIMATE];
    mainView.frame =  CGRectMake(0, rectMainFrame.size.height, rectMainFrame.size.width, rectMainFrame.size.height);
    [UIView commitAnimations];
}

- (void) hideBaseView
{
    self.isBeingShow = NO;
    
    
    NSLog(@"hideBaseView");
    bIsShowing = NO;
    baseView.hidden = YES;
    
    if (_timerShowHide)
    {
        [_timerShowHide invalidate];
        _timerShowHide = nil;
    }
}

- (void) showBaseView
{
    bIsShowing = YES;
    baseView.hidden = NO;
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:baseView];
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:baseView];
    //[baseView.superview bringSubviewToFront:baseView];
}

#pragma mark - Notifications
- (void) onNotifyAdWillShowFullscreen
{
    [self hidePopupView];
}

#pragma mark - Functions
- (void) showPopupView
{
    if (self.isBeingShow){
        NSLog(@"PopUp view is currently showing. Don't need to show more");
        return;
    }
    
    self.isBeingShow = YES;
    
    /* Hien tai chi show ad khi dang o che do man hinh doc */
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationPortrait:
            break;
        default: return;
            break;
    }
    
    [self showBaseView];
    
    if ([delegate respondsToSelector:@selector(didPopupAlertViewStartToShow)])
        [delegate didPopupAlertViewStartToShow];
    
    [self performSelector:@selector(fadeIn) withObject:nil afterDelay:0.01];
    
    /* Popup se tu an sau mot khoang thoi gian la TIME_INTERVAL_SHOWING */
    //[self performSelector:@selector(hidePopupView) withObject:nil afterDelay:TIME_INTERVAL_SHOWING];
    
    if (_timerShowHide)
    {
        [_timerShowHide invalidate];
        _timerShowHide = nil;
    }
    
    _timerShowHide = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_SHOWING target:self selector:@selector(hidePopupView) userInfo:nil repeats:YES];
}

- (void) hidePopupView
{
    if (bIsShowing)
    {
        [self fadeOut];
        
        [self performSelector:@selector(hideBaseView) withObject:nil afterDelay:TIME_INTERVAL_ANIMATE];
    }
}

-(void) btnCloseClicked
{
    [self hidePopupView];
    
    iSelectedBtnIndex = 0;
    
    [self performSelector:@selector(dismissPopupAlertView) withObject:nil afterDelay:TIME_INTERVAL_ANIMATE];
}

-(void) btnOKClicked
{
    [self hidePopupView];
    
    iSelectedBtnIndex = 1;
    
    [self performSelector:@selector(dismissPopupAlertView) withObject:nil afterDelay:TIME_INTERVAL_ANIMATE];
}

-(void) dismissPopupAlertView
{
    if ([delegate respondsToSelector:@selector(dismissPopupAlertViewWithIndex:)])
        [delegate dismissPopupAlertViewWithIndex:iSelectedBtnIndex];
    
}

@end
