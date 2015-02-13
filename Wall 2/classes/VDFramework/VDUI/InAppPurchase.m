//
//  InAppPurchase.m
//  VietTVPro
//
//  Created by Mr. Hiep on 11/11/13.
//
//

#import "InAppPurchase.h"
#import "VDUIImage.h"
#import "VDUtilities.h"

#define TIME_INTERVAL_ANIMATE   0.6
#define TIME_INTERVAL_SHOWING   20

@interface InAppPurchase ()

@end


@implementation InAppPurchase

@synthesize delegate;
@synthesize baseView;
@synthesize bIsShowing;

-(id) init
{
    if (self = [super init])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            rectMainFrame = CGRectMake(0, 0, 320, 50);
        else
            rectMainFrame = CGRectMake(0, 0, 769, 90);
        
        baseView = [[UIView alloc] initWithFrame:rectMainFrame];
        
        iSelectedBtnIndex = 0;
        bIsShowing = NO;
        
        delegate = nil;
    }
    
    return self;
}

-(id) initWithFrame:(CGRect)rect
{
    if (self = [super init])
    {
        rectMainFrame = rect;
        baseView = [[UIView alloc] initWithFrame:rectMainFrame];
        
        iSelectedBtnIndex = 0;
        
        delegate = nil;
    }
    
    return self;
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
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(- rectMainFrame.size.width, 0, rectMainFrame.size.width, rectMainFrame.size.height)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        mainView.backgroundColor = [UIColor colorWithPatternImage:[[VDUIImage imageNamed:@"inappbanner-USTV"] imageScaledToSize:rectMainFrame.size]];
    }
    else
    {
        mainView.backgroundColor = [UIColor colorWithPatternImage:[[VDUIImage imageNamed:@"inappbanner-USTV-ipad"] imageScaledToSize:rectMainFrame.size]];
    }
    [baseView addSubview:mainView];
    [mainView release];
    
    
    CGRect rectBtnClose, rectBtnOK;

    int btnCloseW = rectMainFrame.size.height;
    int btnCloseH = rectMainFrame.size.height;

    rectBtnClose = CGRectMake(rectMainFrame.size.width - btnCloseW, 0, btnCloseW, btnCloseH);
    rectBtnOK = CGRectMake(0, 0, rectMainFrame.size.width - btnCloseW, rectMainFrame.size.height);    

    btnOK = [[UIButton alloc] initWithFrame:rectBtnOK];
    //[btnOK setImage:[VDUIImage imageNamed:@"popup_alert_btn_bgr.png"] forState:UIControlStateNormal];
    btnOK.backgroundColor = [UIColor clearColor];
    [btnOK setTitle:@"" forState:UIControlStateNormal];
    [btnOK addTarget:self action:@selector(btnOKClicked) forControlEvents:UIControlEventTouchUpInside];
    btnOK.titleLabel.textColor = [UIColor whiteColor];
    [mainView addSubview:btnOK];
    [btnOK release];
    
    btnCancel = [[UIButton alloc] initWithFrame:rectBtnClose];
    //[btnCancel setImage:[VDUIImage imageNamed:@"popup_alert_del_btn2.png"] forState:UIControlStateNormal];
    btnCancel.backgroundColor = [UIColor clearColor];
    [btnCancel setTitle:@"" forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCloseClicked) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:btnCancel];
    [btnCancel release];
    
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

- (void) setNewFrame:(CGRect)newRect
{
    rectMainFrame = newRect;
    baseView.frame = rectMainFrame;
}

-(void) fadeIn
{
    CGRect rect1 = mainView.frame;
    
    NSLog(@"Start show inapp view");
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:TIME_INTERVAL_ANIMATE];
    mainView.frame =  CGRectMake(0, 0, rectMainFrame.size.width, rectMainFrame.size.height);
    
    [UIView commitAnimations];
    
    CGRect rect2 = mainView.frame;
    
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:baseView];
}

-(void) fadeOut
{
    NSLog(@"Hide popup alert");
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:TIME_INTERVAL_ANIMATE];
    mainView.frame =  CGRectMake(- rectMainFrame.size.width, 0, rectMainFrame.size.width, rectMainFrame.size.height);
    [UIView commitAnimations];
}

- (void) hideBaseView
{
    NSLog(@"hideBaseView");
    bIsShowing = NO;
    baseView.hidden = YES;
    
    if (_timerShowHide)
    {
        [_timerShowHide invalidate];
        _timerShowHide = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(didDismissInAppPurchaseWithIndex:)])
    {
        [self.delegate didDismissInAppPurchaseWithIndex:0];
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

- (void) updateBaseViewFrame:(CGRect)newRect
{
    
    NSLog(@"+++++ UPDATE IN-APP PURCHASE rect : (%f,%f),(%f,%f)",newRect.origin.x,newRect.origin.y,newRect.size.width,newRect.size.height);
    
    rectMainFrame = newRect;

    baseView.frame = rectMainFrame;

    mainView.frame = CGRectMake(0, 0, rectMainFrame.size.width, rectMainFrame.size.height);

    CGRect rectBtnClose, rectBtnOK;
    
    int btnCloseW = rectMainFrame.size.height;
    int btnCloseH = rectMainFrame.size.height;
    
    rectBtnClose = CGRectMake(mainView.frame.size.width - btnCloseW, 0, btnCloseW, btnCloseH);
    rectBtnOK = CGRectMake(0, 0, mainView.frame.size.width - btnCloseW, mainView.frame.size.height);
    
    btnOK.frame = rectBtnOK;
    btnCancel.frame = rectBtnClose;
}

#pragma mark - Functions
- (void) showInAppView
{    
    [self showBaseView];
    
    if ([delegate respondsToSelector:@selector(didInAppViewStartToShow)])
        [delegate didInAppViewStartToShow];
    
    [self performSelector:@selector(fadeIn) withObject:nil afterDelay:0.01];
    
    /* Popup se tu an sau mot khoang thoi gian la TIME_INTERVAL_SHOWING */
    if (_timerShowHide)
    {
        [_timerShowHide invalidate];
        _timerShowHide = nil;
    }
    
    _timerShowHide = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_SHOWING target:self selector:@selector(hideInAppView) userInfo:nil repeats:YES];
}

- (void) hideInAppView
{
    if (bIsShowing)
    {
        [self fadeOut];
        
        [self performSelector:@selector(hideBaseView) withObject:nil afterDelay:TIME_INTERVAL_ANIMATE];
    }
}

-(void) btnCloseClicked
{
    [self hideInAppView];
    
    iSelectedBtnIndex = 0;
    
    [self performSelector:@selector(dismissInAppView) withObject:nil afterDelay:TIME_INTERVAL_ANIMATE];
}

-(void) btnOKClicked
{
    [self hideInAppView];
    
    iSelectedBtnIndex = 1;
    
    [self performSelector:@selector(dismissInAppView) withObject:nil afterDelay:TIME_INTERVAL_ANIMATE];
}

-(void) dismissInAppView
{
    if ([delegate respondsToSelector:@selector(didDismissInAppPurchaseWithIndex:)])
        [delegate didDismissInAppPurchaseWithIndex:iSelectedBtnIndex];
    
}

@end
