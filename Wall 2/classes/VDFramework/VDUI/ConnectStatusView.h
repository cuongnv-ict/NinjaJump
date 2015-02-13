//
//  ConnectStatusView.h
//  VietTV
//
//  Created by DoLam on 02/19/12.
//  Copyright 2012 DoLam. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ConnectStatusView : UIView
{
    UIActivityIndicatorView*    indicator;
    UILabel*                    label;
@public
    BOOL bIsShow;
}

-(void)show:(NSString*)sText;
-(void)hide;
- (void)updateSize;

@end
