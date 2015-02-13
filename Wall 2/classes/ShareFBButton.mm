//
//  ShareFBButton.cpp
//  SoftTest
//
//  Created by NXT's Macbook Pro on 10/20/14.
//
//

#import "ShareFBButton.h"
#import <Foundation/Foundation.h>
//#import "VDUtilities.h"
#import <cocos2d.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "AppController.h"
#import "Reachability.h"


void ShareFBButton::shareFB(int typeShare)
{
    Reachability* re = [Reachability reachabilityForInternetConnection];
    if (!re || [re currentReachabilityStatus] != ReachableViaWiFi)
    {
        UIAlertView * a = [[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Please check internet connection!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [a show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifShowAds" object:nil];
        return;
    }
    
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        AppController *app = (AppController *)[UIApplication sharedApplication].delegate;
        //SLComposeViewController *sl = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        if (typeShare==0) {
            [mySLComposerSheet setInitialText:@"Cool Ninja:"];
            [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/cool-ninja/id951310832?ls=1&mt=8"]];
            [mySLComposerSheet addImage:[UIImage imageNamed:@"icon_sharefacebook_new.png"]];
            [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifShowAds" object:nil];
                        NSLog(@"Post Canceled");
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        
                        //Thực hiện khi người dùng click Done
                        
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifShowAds" object:nil];
                        //NotificationCenter::getInstance()->postNotification(NOTIFICATION_UPDATE_SCORE);
                        
                        
                        
                        break;
                    }
                    default:
                        break;
                }
            }];
        }
        else if (typeShare==1){
            [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"I got points in Cool Ninja Game.\nhttps://itunes.apple.com/us/app/cool-ninja/id951310832?ls=1&mt=8"]];
            //            [mySLComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/cool-ninja/id951310832?ls=1&mt=8"]];
            [mySLComposerSheet addImage:[UIImage imageNamed:@"icon_sharefacebook_new.png"]];
            [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifShowAds" object:nil];
                        NSLog(@"Post Canceled");
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        UIAlertView * a = [[[UIAlertView alloc] initWithTitle:@"" message:@"Share Facebook successful" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
                        [a show];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifShowAds" object:nil];
                        //NotificationCenter::getInstance()->postNotification(NOTIFICATION_UPDATE_SCORE);
                        break;
                    }
                    default:
                        break;
                }
            }];
        }
        
        
        // nen test tren devi
        [[app viewController] presentModalViewController:mySLComposerSheet animated:YES];
        // nen test tren device, vi may ao ko co connect facebook mac dinh
        
        /*
         //Check xem co mang hay khong thi hay goi chuc nang nay neu khong se bi hack
         //Nut nay bat event Post Done
         if (SLComposeViewControllerResultDone)
         {
         
         
         
         }
         */
    }
    else
    {
        UIAlertView * a = [[[UIAlertView alloc]initWithTitle:@"Please Login Facebook !!" message:@"Settings -> Facebook -> Login" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [a show];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifShowAds" object:nil];
        CCLOG(" chua dang nhap mac dinh ");
    }
}
void ShareFBButton::shareTwitter()
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        AppController *app = (AppController *)[UIApplication sharedApplication].delegate;
        SLComposeViewController *sl = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [sl setInitialText:@"https://itunes.apple.com/us/app/symbol-link-new-puzzle-game/id818245884?mt=8"];
        
        [[app viewController] presentModalViewController:sl animated:YES];
        // nen test tren device, vi may ao ko co connect facebook mac dinh
    }
    else
    {
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Please Login Twitter !!" message:@"Settings -> Twitter -> Login" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];
        [a show];
        
        CCLOG(" chua dang nhap mac dinh ");
    }
}
