//
//  VDMailComposer.h
//  vietradio
//
//  Created by DoLam on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class VDMailComposer;

extern VDMailComposer *g_vdMailComposer;

#define kMailComposerInfo_ToRecipients			@"MailComposerInfo_ToRecipients"
#define kMailComposerInfo_Subject				@"MailComposerInfo_Subject"
#define kMailComposerInfo_Body					@"MailComposerInfo_Body"
#define kMailComposerInfo_isHTMLBody			@"MailComposerInfo_isHTMLBody"
#define kMailComposerInfo_AttachmentFilePath	@"MailComposerInfo_AttachmentFilePath"
#define kMailComposerInfo_AttachmentFileName	@"MailComposerInfo_AttachmentFileName"
#define kMailComposerInfo_AttachmentMimeType	@"MailComposerInfo_AttachmentMimeType"

@interface VDMailComposer:UIViewController <MFMailComposeViewControllerDelegate>
{
	NSDictionary* dictMailInfo;
	UIViewController* vcDelegate;
}

- (void)showMailComposerFromViewController:(UIViewController *)viewControllerDelegate:(NSDictionary *)dictionaryMailInfo;
@end
