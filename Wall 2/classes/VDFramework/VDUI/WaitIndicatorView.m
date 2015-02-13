//
//  WaitIndicatorView.mm
//  ChineseDict
//
//  Created by baubi on 9/29/09.
//  Copyright 2009 ltgbau. All rights reserved.
//

#import "WaitIndicatorView.h"

@implementation WaitIndicatorView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        bIsShow = NO;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAlpha:0];
		int nIndicatorSize = 50;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			nIndicatorSize = 80;
        indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width - nIndicatorSize)/2, (frame.size.height - 2*nIndicatorSize)/2, nIndicatorSize, nIndicatorSize)];
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [indicator setTag:1234];
        [self addSubview:indicator];
        [indicator release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(5, (frame.size.height - 2*nIndicatorSize)/2+nIndicatorSize, frame.size.width-2*8, nIndicatorSize)];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setAdjustsFontSizeToFitWidth:YES];
		[label setMinimumFontSize:14];
		[label setTextAlignment:UITextAlignmentCenter];
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

- (void)drawRect:(CGRect)rect
{
	// ve bong bong
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor colorWithWhite:0 alpha:.7] setFill];
	[[UIColor clearColor] setStroke];
    CGRect rrect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect)-2;
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    float _nRadius = 8;
    // Start at 1
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, _nRadius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, _nRadius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, _nRadius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, _nRadius);
    // Close the path
    CGContextClosePath(context);
    // Fill & stroke the path
	CGContextSaveGState(context);
	CGContextDrawPath(context, kCGPathFillStroke);
	CGContextRestoreGState(context);
}


- (void)dealloc
{
    [super dealloc];
}


@end
