
//
//  VDMailComposer.mm
//  vietradio
//
//  Created by DoLam on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VDMailComposer.h"

VDMailComposer *g_vdMailComposer = nil;

@interface VDMailComposer(Private)
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
@end
@implementation VDMailComposer

- (void)showMailComposerFromViewController:(UIViewController *)viewControllerDelegate:(NSDictionary *)dictionaryMailInfo
{
	vcDelegate = viewControllerDelegate;
	if (!vcDelegate)
		vcDelegate = self;
	if (dictMailInfo)
		[dictMailInfo release];
	dictMailInfo = [dictionaryMailInfo retain];
	
	if (!dictMailInfo) return;
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}

#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	//CFBundleRef bundle = CFBundleGetMainBundle();
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7)
        picker.navigationBar.tintColor = [UIColor blackColor];
    else
        picker.navigationBar.tintColor = [UIColor whiteColor];
        
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6)
    {
        picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
    
	picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)vcDelegate;
	NSArray *toRecipients = nil;
	NSArray *ccRecipients = nil;
	NSArray *bccRecipients = nil;
	NSString *emailBody = nil;
	
	[picker setSubject:[dictMailInfo objectForKey:kMailComposerInfo_Subject]];
	if ([dictMailInfo objectForKey:kMailComposerInfo_ToRecipients])
		toRecipients = [NSArray arrayWithObject:[dictMailInfo objectForKey:kMailComposerInfo_ToRecipients]]; 
	emailBody = [dictMailInfo objectForKey:kMailComposerInfo_Body];
	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];	
	[picker setBccRecipients:bccRecipients];
	if ([[dictMailInfo objectForKey:kMailComposerInfo_isHTMLBody] boolValue])
		[picker setMessageBody:emailBody isHTML:YES];
	else 
		[picker setMessageBody:emailBody isHTML:NO];
	
	if ([dictMailInfo objectForKey:kMailComposerInfo_AttachmentFilePath])
	{
		NSData *myData = [NSData dataWithContentsOfFile:[dictMailInfo objectForKey:kMailComposerInfo_AttachmentFilePath]];
		[picker addAttachmentData:myData mimeType:[dictMailInfo objectForKey:kMailComposerInfo_AttachmentMimeType] fileName:[dictMailInfo objectForKey:kMailComposerInfo_AttachmentFileName]];
	}
	
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        picker.modalPresentationStyle = UIModalPresentationFormSheet;
        //navDisplayWeb.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    if (vcDelegate)
        [vcDelegate presentModalViewController:picker animated:YES];
    else 
        [self presentModalViewController:picker animated:YES];
    
    [picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	
	NSString* sMessageNotify = nil;
	switch (result)
	{
		case MFMailComposeResultCancelled:
			sMessageNotify = nil;
			break;
		case MFMailComposeResultSaved:
			sMessageNotify = nil;
			break;
		case MFMailComposeResultSent:
			sMessageNotify = @"Sent mail success!";
			break;
		case MFMailComposeResultFailed:
			sMessageNotify = @"Send mail fail. Please check internet connection and email configuration.";
			break;
		default:
			sMessageNotify = nil;
			break;
	}
	
	if (sMessageNotify)
	{
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Mail Composer"
													 message:sMessageNotify delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		[al show];
		[al release];
	}
	[self dismissModalViewControllerAnimated:YES];
}
	 

#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	/*
	 NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
	 NSString *body = @"&body=It is raining in sunny California!";
	 */
	
	NSString *email = [NSString stringWithFormat:@"mailto:%@&subject=%@&body=%@", 
					   [dictMailInfo objectForKey:kMailComposerInfo_ToRecipients],
					   [dictMailInfo objectForKey:kMailComposerInfo_Subject],
					   [dictMailInfo objectForKey:kMailComposerInfo_Body]];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

@end
