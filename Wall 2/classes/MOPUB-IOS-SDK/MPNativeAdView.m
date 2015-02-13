//
//  MPNativeAdView.m
//  Mopub_Sample
//
//  Created by Luong Minh Hiep on 5/19/14.
//  Copyright (c) 2014 ppclink. All rights reserved.
//

#import "MPNativeAdView.h"

@interface MPNativeAdView()
{
    
    CGRect mainFrame;
    UIView *baseViewSquare;
    
    UIButton *btnMainImageTapHandle;
}

@end
@implementation MPNativeAdView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        mainFrame = frame;
        
        self.currentAdObject = nil;
        self.currentAdRequest = nil;
        self.bIsNativeAdFetchedSuccessful = NO;
        
        self.rootViewController = nil;
        
        [self initComponentViews];
    }
    return self;
}

- (void) initComponentViews
{
    int nIconWidth = 50;
    int nDescriptionHeight = 50;
    
    int nImageViewWidth = mainFrame.size.width;
    int nImageViewHeight = nImageViewWidth/2;
    
    int nActionButtonWidth = 100;
    int nActionButtonHeight = 30;
    
    int nMargin = 5;
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nMargin, nMargin, nIconWidth - nMargin*2, nIconWidth - nMargin*2)];
    self.iconImageView.backgroundColor = [UIColor redColor];
    [self addSubview:self.iconImageView];
    [self.iconImageView release];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(nIconWidth, nMargin, mainFrame.size.width - nIconWidth, nIconWidth - nMargin*2)];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = @"Title Label";
    self.titleLabel.numberOfLines = 2;
    [self addSubview:self.titleLabel];
    [self.titleLabel release];
    
    self.mainTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(nMargin, nIconWidth , mainFrame.size.width - nMargin*2, nDescriptionHeight)];
    self.mainTextLabel.textAlignment = NSTextAlignmentLeft;
    self.mainTextLabel.font = [UIFont boldSystemFontOfSize:14];
    self.mainTextLabel.textColor = [UIColor grayColor];
    self.mainTextLabel.numberOfLines = 3;
    self.mainTextLabel.text = @"Short description\nThis is the second line of description\nThe third line here";
    [self addSubview:self.mainTextLabel];
    [self.mainTextLabel release];
    
    self.mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nMargin, nIconWidth + nDescriptionHeight + nMargin, nImageViewWidth - nMargin*2, nImageViewHeight - nMargin*2)];
    self.mainImageView.backgroundColor = [UIColor blueColor];
    [self addSubview:self.mainImageView];
    [self.mainImageView release];
    
    btnMainImageTapHandle = [[UIButton alloc] initWithFrame:self.mainImageView.frame];
    btnMainImageTapHandle.backgroundColor = [UIColor clearColor];
    [btnMainImageTapHandle setTitle:@"" forState:UIControlStateNormal];
    [btnMainImageTapHandle addTarget:self action:@selector(callToActionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnMainImageTapHandle];
    [btnMainImageTapHandle release];
    
    self.callToActionButton = [[UIButton alloc] initWithFrame:CGRectMake(mainFrame.size.width - nMargin - nActionButtonWidth, nIconWidth + nDescriptionHeight + nImageViewHeight, nActionButtonWidth, nActionButtonHeight)];
    self.callToActionButton.center = CGPointMake(mainFrame.size.width - nMargin - nActionButtonWidth + nActionButtonWidth/2, (mainFrame.size.height + nIconWidth + nDescriptionHeight + nImageViewHeight)/2);
    [self.callToActionButton setTitle:@"Install" forState:UIControlStateNormal];
    self.callToActionButton.backgroundColor = [UIColor grayColor];
    [self addSubview:self.callToActionButton];
    [self.callToActionButton release];
    [self.callToActionButton addTarget:self action:@selector(callToActionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void) startNewNativeAdRequest
{
    self.currentAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:NATIVE_MOPUB_KEY];
    [self.currentAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error)
        {
            // Handle error.
            NSLog(@"%@",error.description);
            
            self.bIsNativeAdFetchedSuccessful = NO;
        }
        else
        {
            // Use the 'response' object to render a native ad.
            NSLog(@"Request native ad OK");
            
            self.bIsNativeAdFetchedSuccessful = YES;
            
            self.currentAdObject = response;
            [response prepareForDisplayInView:self];
        }
    }];

}

- (void) callToActionButtonPressed
{
    NSLog(@"ActionCall is pressed, Open URL: %@",self.currentAdObject.defaultActionURL);
    [self.currentAdObject displayContentForURL:self.currentAdObject.defaultActionURL rootViewController:self.rootViewController completion:^(BOOL success, NSError *error)
    {
        if (success)
        {
            NSLog(@"Completed ad action.");
        }
        else
        {
            NSLog(@"Ad action could not be completed. Error: %@", error);
        }
    }];
}

- (void)layoutAdAssets:(MPNativeAd *)adObject
{
    [adObject loadTitleIntoLabel:self.titleLabel];
    [adObject loadTextIntoLabel:self.mainTextLabel];
    [adObject loadCallToActionTextIntoLabel:self.callToActionButton.titleLabel];
    [adObject loadIconIntoImageView:self.iconImageView];
    [adObject loadImageIntoImageView:self.mainImageView];
}



@end
