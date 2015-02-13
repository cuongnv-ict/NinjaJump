//
//  VDContactController.h
//  VietTVPro
//
//  Created by Mr. Luong on 7/16/13.
//
//

#import <UIKit/UIKit.h>

#define kText_Title     @"Contact us"
#define kText_Send      @"Send"
#define kText_Name      @"Your Name"
#define kText_Email     @"Your Email"
#define kText_Subject   @"Subject"
#define kText_Message   @"Message"
#define kText_Warning   @"Warning"

#define kText_Previous_Name      @"ContactUsPreviousName"
#define kText_Previous_Email     @"ContactUsPreviousEmail"
#define kText_Previous_Subject   @"ContactUsPreviousTitle"

#define kText_Name_WarningEmpty      @"Please enter your name. Thank you."
#define kText_Email_WarningEmpty     @"Please enter your email. Thank you."
#define kText_Subject_WarningEmpty   @"Please enter subject. Thank you."
#define kText_Message_WarningEmpty   @"Please enter your message. Thank you."

#define kText_NotifySendEmailComplete @"Your message has been sent to our system. Thank you for using our product."

@interface VDContactUsController : UITableViewController
{
    UITextField *tfName;
    UITextField *tfTitle;
    UITextField *tfEmail;
    UITextView  *tvMessage;
}

- (id)initWithStyle:(UITableViewStyle)style;

@end
