//
//  VDContactController.m
//  VietTVPro
//
//  Created by Mr. Luong on 7/16/13.
//
//

#import "VDContactUsController.h"
#import "VDConfigNotification.h"
#import "VDUtilities.h"

#import "LocalizationSystem.h"

#define kTag_ViewToMove     16072013
#define nCellHeightSingle   30
#define nCellHeightMultiple 180


@interface VDContactUsController ()

@end

@implementation VDContactUsController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.title = kText_Title;
        
        // Custom initialization
//        UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(btnBackPressed)];
//        self.navigationItem.leftBarButtonItem = barBack;
//        [barBack release];
//        UIImage *backBtnImage = [UIImage imageNamed:@"Images/UI/nav_back_button.png"];
//        CGSize sizeImage = backBtnImage.size;
//        backBtnImage = [backBtnImage resizableImageWithCapInsets:UIEdgeInsetsMake(sizeImage.width - 2, sizeImage.height - 2, 0, 0)];
//        [barBack setBackgroundImage:backBtnImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        UIImage *backBtnImage = [UIImage imageNamed:@"Images/UI/nav_back_button.png"];
        CGSize sizeImage = backBtnImage.size;
        backBtnImage = [backBtnImage resizableImageWithCapInsets:UIEdgeInsetsMake(sizeImage.width - 2, sizeImage.height - 2, 0, 0)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithImage:backBtnImage
                                                 style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(btnBackPressed)];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
        
        UIBarButtonItem *barSendEmail = [[UIBarButtonItem alloc] initWithTitle:kText_Send style:UIBarButtonItemStyleBordered target:self action:@selector(sendEmail)];
        self.navigationItem.rightBarButtonItem = barSendEmail;
        [barSendEmail release];
        
        if ([VDUtilities bIsIOS7Version])
        {
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        }
        else
        {
            self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        }
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6)
        {
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        }
        
        tvMessage = nil;
        tfEmail = nil;
        tfName = nil;
        tfTitle = nil;
    }
    return self;
}

-(void) btnBackPressed
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void) sendEmail
{
    if (![VDUtilities checkInternetConnection])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[VDUtilities getProductName] message:AMLocalizedString(@"MESSAGE_ERROR_NETWORK",nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if ([tfTitle.text length] == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:kText_Warning message:kText_Subject_WarningEmpty delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    if ([tfName.text length] == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[VDUtilities getProductName] message:kText_Name_WarningEmpty delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    if ([tfEmail.text length] == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[VDUtilities getProductName] message:kText_Email_WarningEmpty delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    if ([tvMessage.text length] == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[VDUtilities getProductName] message:kText_Message_WarningEmpty delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }    
    
    [[NSUserDefaults standardUserDefaults] setObject:tfEmail.text forKey:kText_Previous_Email];
    [[NSUserDefaults standardUserDefaults] setObject:tfTitle.text forKey:kText_Previous_Subject];
    [[NSUserDefaults standardUserDefaults] setObject:tfName.text forKey:kText_Previous_Name];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissModalViewControllerAnimated:YES];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[VDUtilities getProductName] message:kText_NotifySendEmailComplete delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
   
    NSString *appID = [NSString stringWithFormat:@"%@",[VDConfigNotification getBundleID]];
    NSString *appVersion = [NSString stringWithFormat:@"%@",[VDConfigNotification getProductVersion]];
    NSString *strTitle = [NSString stringWithFormat:@"%@",tfTitle.text];
    NSString *strName = [NSString stringWithFormat:@"%@",tfName.text];
    NSString *strEmail = [NSString stringWithFormat:@"%@",tfEmail.text];
    NSString *strMessage = [NSString stringWithFormat:@"%@",tvMessage.text];
 
    strName = [self getValidPHPStringParam:strName];
    strTitle = [self getValidPHPStringParam:strTitle];
    strEmail = [self getValidPHPStringParam:strEmail];
    strMessage = [self getValidPHPStringParam:strMessage];    
 
    NSString * contentToPost = [[NSString alloc] initWithFormat:@"appid=%@&appversion=%@&name=%@&email=%@&subject=%@&message=%@",appID,appVersion,strName,strEmail,strTitle,strMessage];
    //NSLog(@"++++++++++++ %@",contentToPost);
    
    NSURL *url=[NSURL URLWithString:@"http://deltago.com/notifications/feedback.php"];
    NSData *postData = [contentToPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:8];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *returnData=nil;
    returnData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    NSLog(@"Return data : %@",returnData);
    [returnData release];
    [contentToPost release];

}

- (NSString*) getValidPHPStringParam:(NSString*)inputString
{
    NSString *strResult = [inputString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strResult = [strResult stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    return strResult;   
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (void) loadView
{
    [super loadView];
    
    if ([VDUtilities bIsIOS7Version])
    {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }

    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6)
{
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kText_Previous_Name])
        tfName.text = [[NSUserDefaults standardUserDefaults] objectForKey:kText_Previous_Name];    
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:kText_Previous_Subject])
//        tfTitle.text = [[NSUserDefaults standardUserDefaults] objectForKey:kText_Previous_Subject];    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kText_Previous_Email])
        tfEmail.text = [[NSUserDefaults standardUserDefaults] objectForKey:kText_Previous_Email];

    tfTitle.text = [NSString stringWithFormat:@"Feedback of %@ %@",[VDUtilities getProductName], [VDUtilities getProductVersion]];
    
    //[self.tableView reloadData];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kText_Previous_Name] && [[NSUserDefaults standardUserDefaults] objectForKey:kText_Previous_Email])
        [tvMessage becomeFirstResponder];
    else
        [tfName becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier=@"cellIdentifier";
	UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
     if (!cell)
     {
         cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
         cell.selectionStyle=UITableViewCellSelectionStyleNone;
     }
     
     UIView *viewToMove = [cell.contentView viewWithTag:kTag_ViewToMove];
     if (viewToMove)
     {
         [viewToMove removeFromSuperview];
         viewToMove = nil;
     }
     
     int nCellHeight = 0;
     if (indexPath.section == 0)
         nCellHeight = nCellHeightSingle;
     else if (indexPath.section == 1)
         nCellHeight = nCellHeightSingle;
     else if (indexPath.section == 2)
         nCellHeight = nCellHeightSingle;
     else if (indexPath.section == 3)
         nCellHeight = nCellHeightMultiple;
    
    UIView *viewToCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, nCellHeight)];
    viewToCell.tag = kTag_ViewToMove;
    viewToCell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0)
    {
        if (!tfName)
            tfName = [[UITextField alloc] init];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            tfName.frame = CGRectMake(40, 5, self.view.bounds.size.width-80, nCellHeight-10);
        else
            tfName.frame = CGRectMake(15, 3, self.view.bounds.size.width-30, nCellHeight-6);
        
        tfName.backgroundColor = [UIColor clearColor];
        [tfName setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [tfName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [tfName setClearButtonMode:UITextFieldViewModeWhileEditing];
        [viewToCell addSubview:tfName];
        
        [tfName setKeyboardType:UIKeyboardTypeDefault];
    }
    else if (indexPath.section == 1)
    {
        if (!tfEmail)
            tfEmail = [[UITextField alloc] init];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            tfEmail.frame = CGRectMake(40, 5, self.view.bounds.size.width-80, nCellHeight-10);
        else
            tfEmail.frame = CGRectMake(15, 3, self.view.bounds.size.width-30, nCellHeight-6);
        
        tfEmail.backgroundColor = [UIColor clearColor];
        [tfEmail setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [tfEmail setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [tfEmail setClearButtonMode:UITextFieldViewModeWhileEditing];
        [viewToCell addSubview:tfEmail];
        
        [tfEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    }
    else if (indexPath.section == 2)
    {
        if (!tfTitle)
            tfTitle = [[UITextField alloc] init];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            tfTitle.frame = CGRectMake(40, 5, self.view.bounds.size.width-80, nCellHeight-10);
        else
            tfTitle.frame = CGRectMake(15, 3, self.view.bounds.size.width-30, nCellHeight-6);
        
        tfTitle.backgroundColor = [UIColor clearColor];
        [tfTitle setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [tfTitle setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [tfTitle setClearButtonMode:UITextFieldViewModeWhileEditing];
        [tfTitle setAutocorrectionType:UITextAutocorrectionTypeNo];
        [viewToCell addSubview:tfTitle];
        
        [tfTitle setKeyboardType:UIKeyboardTypeDefault];
        //[tfTitle becomeFirstResponder];
    }
    else if (indexPath.section == 3)
    {
        if (!tvMessage)
            tvMessage = [[UITextView alloc] init];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            tvMessage.frame = CGRectMake(40, 5, self.view.bounds.size.width-80, nCellHeight-10);
        else
            tvMessage.frame = CGRectMake(15, 5, self.view.bounds.size.width-30, nCellHeight-10);
        tvMessage.backgroundColor = [UIColor clearColor];
        tvMessage.font = [UIFont systemFontOfSize:15];
        [viewToCell addSubview:tvMessage];
        
        [tvMessage setKeyboardType:UIKeyboardTypeDefault];
    }
    
    [cell.contentView addSubview:viewToCell];
    [viewToCell release];
    
    return cell;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return kText_Name;
    else if (section == 1)
        return kText_Email;
    else if (section == 2)
        return kText_Subject;
    else if (section == 3)
        return kText_Message;
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return nCellHeightSingle;
    else if (indexPath.section == 1)
        return nCellHeightSingle;
    else if (indexPath.section == 2)
        return nCellHeightSingle;
    else if (indexPath.section == 3)
        return nCellHeightMultiple;
    else
        return 0;
}


- (void)dealloc
{
    
    [tvMessage release];
    [tfTitle release];
    [tfEmail release];
    [tfName release];
    
    [super dealloc];
}

@end
