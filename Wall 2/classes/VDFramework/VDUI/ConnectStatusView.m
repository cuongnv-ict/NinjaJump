//
//  ConnectStatusView.h
//  VietTV
//
//  Created by DoLam on 02/19/12.
//  Copyright 2012 DoLam. All rights reserved.
//

#import "ConnectStatusView.h"
#import "VDUIImage.h"

@implementation ConnectStatusView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        bIsShow = NO;
        
        [self setBackgroundColor:[UIColor clearColor]];
        UIImageView* imgViewBk = [[UIImageView alloc] initWithImage:[VDUIImage imageNamed:@"Images/UI/connectstatusbar_bk"]];
        CGRect rc = self.bounds;
        imgViewBk.frame = self.bounds;
        [self addSubview:imgViewBk];
        [imgViewBk release];
        [self setAlpha:0];
        
		int nIndicatorSize = self.bounds.size.height - 4;
        indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(3, 2, nIndicatorSize, nIndicatorSize)];
		//indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [indicator setTag:1234];
        [self addSubview:indicator];
        [indicator release];
        CGFloat fX = indicator.frame.origin.x + indicator.frame.size.width + 5;
        label = [[UILabel alloc] initWithFrame:CGRectMake(fX, 2, self.bounds.size.width - fX - 9, nIndicatorSize)];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setAdjustsFontSizeToFitWidth:YES];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            [label setMinimumFontSize:8];
        else 
            [label setMinimumFontSize:12];
		[label setTextAlignment:UITextAlignmentLeft];
        [self addSubview:label];
        [label release];
        
    }
    return self;
}

- (void)updateSize
{
    int nIndicatorSize = indicator.frame.size.width;
    
    [indicator setFrame:CGRectMake((self.bounds.size.width - nIndicatorSize)/2, (self.bounds.size.height - 2*nIndicatorSize)/2, nIndicatorSize, nIndicatorSize)];
    
    [label setFrame:CGRectMake(5, (self.bounds.size.height - 2*nIndicatorSize)/2+nIndicatorSize, self.bounds.size.width-2*8, nIndicatorSize)];
    
}

-(void)show:(NSString*)sText
{
    bIsShow = YES;
    [label setText:sText];
    [indicator startAnimating];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.1];
    [self setAlpha:1];
    [UIView commitAnimations];
}

-(void)hide
{
    bIsShow = NO;
    [indicator stopAnimating];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [self setAlpha:0];
    [UIView commitAnimations];
}

- (void)dealloc
{
    [super dealloc];
}


@end
