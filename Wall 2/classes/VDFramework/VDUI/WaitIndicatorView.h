//
//  WaitIndicatorView.h
//  ChineseDict
//
//  Created by baubi on 9/29/09.
//  Copyright 2009 ltgbau. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitIndicatorView : UIView
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
