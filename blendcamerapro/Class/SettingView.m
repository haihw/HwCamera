//
//  SettingView.m
//  iDarkRoomClone
//
//  Created by applistar1 on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingView.h"
#import "ViewController.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "SHKFlickr.h"
#import "SHKTumblr.h"
#define kfontLogOut 10
#define kTextColor blackColor
@implementation SettingView
@synthesize rootViewController;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createGUI];
    }
    return self;
}



- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    NSLog(@"webViewDidFinishLoad");
    
}

// Show help view
-(IBAction)showHelp:(UIButton *)sender
{
    NSLog(@"showHelp");
    
}

-(void)createGUI
{
    int headerFontSize = 15;
    int bodyFontSize = 13;
    int accountH = 18;
    int accountW = 227;
    int accountLeft = 9;
    int accountSpace = 2;
    int accountStart = 200;
    int accountTextPadding = 40;
    int accountFontSize = 10;
    CGRect generalFrame = CGRectMake(20, 60, 205, 20);
    CGRect saveOriginalFrame = CGRectMake(20, 90, 80, 20);
    CGRect switchFrame = CGRectMake(162, 90, 20, 20);
    CGRect resolutionFrame = CGRectMake(20, 115, 80, 20);
    CGRect segmentFrame = CGRectMake(9, 135, 227, 25);
    CGRect servieFrame = CGRectMake(20, 170, 205, 20);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        headerFontSize = 30;
        bodyFontSize = 23;
        accountH = 40;
        accountW = 506;
        accountLeft = 22;
        accountSpace = 8;
        accountStart = 410;
        accountTextPadding = 80;
        accountFontSize = 20;
        generalFrame = CGRectMake(20, 140, 510, 40);
        saveOriginalFrame = CGRectMake(20, 188, 510, 40);
        switchFrame = CGRectMake(450, 190, 40, 40);
        resolutionFrame = CGRectMake(20, 236, 510, 40);
        segmentFrame = CGRectMake(22, 284, 506, 44);
        servieFrame = CGRectMake(20, 350, 510, 40);
    } else
    {
        resolutionSegmentedControl.transform = CGAffineTransformMakeScale(1, .8f);
        saveOriginalSwitch.transform = CGAffineTransformMakeScale(.6f, 0.7f);

    }
    UIImageView *bg = [[UIImageView alloc]initWithFrame:self.bounds];
    bg.image = [UIImage imageNamed:@"SettingBG"];
    [self addSubview:bg];

    UILabel *generalLabel = [[UILabel alloc] initWithFrame:generalFrame];
    generalLabel.text = @"Generals";
    generalLabel.textAlignment = NSTextAlignmentCenter;
    generalLabel.textColor = [UIColor kTextColor];
    generalLabel.backgroundColor = [UIColor clearColor];
    generalLabel.font = [UIFont boldSystemFontOfSize:headerFontSize];
    [self addSubview:generalLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:saveOriginalFrame];
    label.text = @"Save Original";
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor kTextColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:bodyFontSize];
    [self addSubview:label];
    
    saveOriginalSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
    [self addSubview:saveOriginalSwitch];

    label = [[UILabel alloc] initWithFrame:resolutionFrame];
    label.text = @"Resolution";
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor kTextColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:bodyFontSize];
    [self addSubview:label];

    NSArray *itemArray = [NSArray arrayWithObjects: @"600",@"800", @"1200", @"1600", @"Full", nil];
    resolutionSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    resolutionSegmentedControl.frame = segmentFrame;

    resolutionSegmentedControl.selectedSegmentIndex = 2;
    [self addSubview:resolutionSegmentedControl];

    //Share services logout
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:servieFrame];
    headerLabel.text = @"Sharing Services";
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor kTextColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:headerFontSize];
    [self addSubview:headerLabel];
    
    
    //facebook
    CGRect frame = CGRectMake(accountLeft, accountStart + (accountSpace+ accountH) * 0, accountW, accountH);
    btnLogoutFacebook = [[UIButton alloc] initWithFrame:frame];
    [btnLogoutFacebook setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateNormal];
    [btnLogoutFacebook setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateHighlighted];
    [btnLogoutFacebook addTarget:self action:@selector(logoutFacebook:) forControlEvents:UIControlEventTouchUpInside];

    labelFB = [[UILabel alloc] initWithFrame:frame];
    labelFB.text = @"Logout from Facebook";
    labelFB.textAlignment = NSTextAlignmentCenter;
    labelFB.textColor = [UIColor blackColor];
    labelFB.backgroundColor = [UIColor clearColor];
    labelFB.font = [UIFont systemFontOfSize: accountFontSize];
    btnLogoutFacebook.enabled = NO;
    if ([SHKFacebook isServiceAuthorized])
    {
        [btnLogoutFacebook setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateNormal];
        [btnLogoutFacebook setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateHighlighted];
        btnLogoutFacebook.enabled = YES;
    }
    [self addSubview:btnLogoutFacebook];
    
    [self addSubview:labelFB];

    //twitter
    frame = CGRectMake(accountLeft, accountStart + (accountSpace+ accountH) * 1, accountW, accountH);

    btnLogoutTwitter = [[UIButton alloc] initWithFrame:frame];
    [btnLogoutTwitter setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateNormal];
    [btnLogoutTwitter setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateHighlighted];
    [btnLogoutTwitter addTarget:self action:@selector(logoutTwitter:) forControlEvents:UIControlEventTouchUpInside];
    labelTW = [[UILabel alloc] initWithFrame:frame];
    labelTW.text = @"Logout from Twitter";
    labelTW.textColor = [UIColor blackColor];
    labelTW.textAlignment = NSTextAlignmentCenter;
    labelTW.backgroundColor = [UIColor clearColor];
    labelTW.font = [UIFont systemFontOfSize: accountFontSize];
    btnLogoutTwitter.enabled = NO;

    if ([SHKTwitter isServiceAuthorized])
    {
        [btnLogoutTwitter setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateNormal];
        [btnLogoutTwitter setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateHighlighted];
        btnLogoutTwitter.enabled = YES;
        
    }
    [self addSubview:btnLogoutTwitter];
    [self addSubview:labelTW];

    //flickr
    frame = CGRectMake(accountLeft, accountStart + (accountSpace+ accountH) * 2, accountW, accountH);

    btnLogoutFlickr = [[UIButton alloc] initWithFrame:frame];
    [btnLogoutFlickr setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateNormal];
    [btnLogoutFlickr setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateHighlighted];
    [btnLogoutFlickr addTarget:self action:@selector(logoutFlickr:) forControlEvents:UIControlEventTouchUpInside];
    labelFL = [[UILabel alloc] initWithFrame:frame];
    labelFL.text = @"Logout from Flickr";
    labelFL.textAlignment = NSTextAlignmentCenter;
    labelFL.textColor = [UIColor blackColor];
    labelFL.backgroundColor = [UIColor clearColor];
    labelFL.font = [UIFont systemFontOfSize: accountFontSize];
    btnLogoutFlickr.enabled = NO;
    if ([SHKFlickr isServiceAuthorized])
    {
        btnLogoutFlickr.enabled = YES;
        [btnLogoutFlickr setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateNormal];
        [btnLogoutFlickr setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateHighlighted];
    }
    
    [self addSubview:btnLogoutFlickr];
    [self addSubview:labelFL];

}
-(void)showGUI
{
    NSLog(@"show gui");
    if ([SHKFacebook isServiceAuthorized])
    {
        [btnLogoutFacebook setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateNormal];
        [btnLogoutFacebook setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateHighlighted];
        btnLogoutFacebook.enabled = YES;

    }
    if ([SHKTwitter isServiceAuthorized])
    {
        [btnLogoutTwitter setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateNormal];
        [btnLogoutTwitter setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateHighlighted];
        btnLogoutTwitter.enabled = YES;
    }

    if ([SHKFlickr isServiceAuthorized])
    {
        btnLogoutFlickr.enabled = YES;
        [btnLogoutFlickr setImage:[UIImage imageNamed:@"SettingBarOn"] forState:UIControlStateNormal];
        [btnLogoutFlickr setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateHighlighted];
   }
    
    
}
-(float)getOuputResolution
{
    NSInteger t = resolutionSegmentedControl.selectedSegmentIndex;
    switch (t) {
        case 0:
            return 600;
        case 1:
            return 800;
        case 2:
            return 1200;
        case 3:
            return 1600;
        default:
            return 0;
    }
}
-(bool)shouldSaveOriginal
{
    return saveOriginalSwitch.on;
}
-(IBAction)doneBtn_click:(id)sender
{
    [self.rootViewController hideSettingView];
    self.hidden = YES;
    NSLog(@"Done");
}
-(IBAction)logoutFacebook:(id)sender
{
    [SHKFacebook logout];
    btnLogoutFacebook.enabled = NO;
    [btnLogoutFacebook setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateNormal];

    NSLog(@"logout facebook");
}
-(IBAction)logoutTwitter:(id)sender
{
    [SHKTwitter logout];
    btnLogoutTwitter.enabled = NO;
    [btnLogoutTwitter setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateNormal];

    NSLog(@"logout twitter");
}

-(IBAction)logoutFlickr:(id)sender
{
    [SHKFlickr logout];
    btnLogoutFlickr.enabled = NO;
    [btnLogoutFlickr setImage:[UIImage imageNamed:@"SettingBarOff"] forState:UIControlStateNormal];

    NSLog(@"logout flickr");
}

-(IBAction)logoutTumblr:(id)sender
{
    [SHKTumblr logout];
    btnLogoutTumblr.enabled = NO;
    NSLog(@"logout Tumblr");
}

@end
