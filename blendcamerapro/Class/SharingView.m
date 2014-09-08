//
//  SharingView.m
//  iDarkRoomClone
//
//  Created by applistar1 on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SharingView.h"
#import "ViewController.h"
#import "SHK.h"
#import "SHKPhotoAlbum.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "SHKFlickr.h"
#import "SHKTumblr.h"
#import "SHKMail.h"
#import "SHKInstagram.h"
#import "MBProgressHUD.h"


#define kShareTitle @"My photo created with #hwcamera www.haihw.com"
#define kSaveAlbum       1
#define kFaceBookService 2
#define kTwitterServicce 3
#define kTumblrService   4
#define kFlickrService   5
#define kEmailService    6
#define kInstagramService 7
@implementation SharingView
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

-(void)createGUI
{
    int btnWidth;
    int btnHeight;
    int originX;
    int originY;
    int numRow = 2;
    int numColumm = 3;
    float topPaddingScale = 1.8;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        btnWidth = 49;
        btnHeight = 49;
    }
    else
    {
        btnWidth = 107;
        btnHeight = 107;
        
    }
    int leftPadding = (self.frame.size.width - btnWidth*numColumm)/(numColumm+1);
    int topPadding =(self.frame.size.height - btnHeight*numRow)/(numRow+1);

    UIImage *normalButton = [UIImage imageNamed:@"ShareButtonBGNormal.png"];
    UIImage *highlightButton = [UIImage imageNamed:@"ShareButtonBGHighlight.png"];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ShareBackground.png"]];

    originX = (leftPadding + btnWidth) * 0 + leftPadding;
    originY = (topPadding + btnHeight) * 0 + topPaddingScale * topPadding;
    UIButton* btnSave = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, btnWidth, btnHeight)];
    [btnSave addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setBackgroundImage:normalButton forState:UIControlStateNormal];
    [btnSave setBackgroundImage:highlightButton forState:UIControlStateHighlighted];
    [btnSave setImage:[UIImage imageNamed:@"Share_Save"] forState:UIControlStateNormal];
    [self addSubview:btnSave];
    
    originX = (leftPadding + btnWidth) * 1 + leftPadding;
    originY = (topPadding + btnHeight) * 0 + topPaddingScale * topPadding;
    UIButton* btnFacebook = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, btnWidth, btnHeight)];
    [btnFacebook addTarget:self action:@selector(shareToFacebook) forControlEvents:UIControlEventTouchUpInside];
    [btnFacebook setBackgroundImage:normalButton forState:UIControlStateNormal];
    [btnFacebook setBackgroundImage:highlightButton forState:UIControlStateHighlighted];
    [btnFacebook setImage:[UIImage imageNamed:@"Share_Facebook"] forState:UIControlStateNormal];
    [self addSubview:btnFacebook];
    
    originX = (leftPadding + btnWidth) * 2 + leftPadding;
    originY = (topPadding + btnHeight) * 0 + topPaddingScale * topPadding;
    UIButton* btnTwitter = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, btnWidth, btnHeight)];
    [btnTwitter addTarget:self action:@selector(shareToTwitter) forControlEvents:UIControlEventTouchUpInside];
    [btnTwitter setBackgroundImage:normalButton forState:UIControlStateNormal];
    [btnTwitter setBackgroundImage:highlightButton forState:UIControlStateHighlighted];
    [btnTwitter setImage:[UIImage imageNamed:@"Share_Twitter"] forState:UIControlStateNormal];
    [self addSubview:btnTwitter];
    
    originX = (leftPadding + btnWidth) * 0 + leftPadding;
    originY = (topPadding + btnHeight) * 1 + topPaddingScale * topPadding;
    UIButton* btnEmail = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, btnWidth, btnHeight)];
    [btnEmail addTarget:self action:@selector(shareViaEmail) forControlEvents:UIControlEventTouchUpInside];
    [btnEmail setBackgroundImage:normalButton forState:UIControlStateNormal];
    [btnEmail setBackgroundImage:highlightButton forState:UIControlStateHighlighted];
    [btnEmail setImage:[UIImage imageNamed:@"Share_Email"] forState:UIControlStateNormal];
    [self addSubview:btnEmail];
    
    originX = (leftPadding + btnWidth) * 1 + leftPadding;
    originY = (topPadding + btnHeight) * 1 + topPaddingScale * topPadding;
    UIButton* btnFlickr = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, btnWidth, btnHeight)];
    [btnFlickr addTarget:self action:@selector(shareToFlickr) forControlEvents:UIControlEventTouchUpInside];
    [btnFlickr setBackgroundImage:normalButton forState:UIControlStateNormal];
    [btnFlickr setBackgroundImage:highlightButton forState:UIControlStateHighlighted];
    [btnFlickr setImage:[UIImage imageNamed:@"Share_Flickr"] forState:UIControlStateNormal];
    [self addSubview:btnFlickr];
    
    originX = (leftPadding + btnWidth) * 2 + leftPadding;
    originY = (topPadding + btnHeight) * 1 + topPaddingScale * topPadding;
    UIButton* btnTumblr = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, btnWidth, btnHeight)];
    [btnTumblr addTarget:self action:@selector(shareViaInstagram) forControlEvents:UIControlEventTouchUpInside];
    [btnTumblr setBackgroundImage:normalButton forState:UIControlStateNormal];
    [btnTumblr setBackgroundImage:highlightButton forState:UIControlStateHighlighted];
    [btnTumblr setImage:[UIImage imageNamed:@"Share_Insta"] forState:UIControlStateNormal];
    [self addSubview:btnTumblr];
}
-(void)saveImage
{
    [MBProgressHUD showHUDAddedTo:self.rootViewController.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shareWith:kSaveAlbum];
        [MBProgressHUD hideHUDForView:self.rootViewController.view animated:YES];
    });

}
-(void)shareToFacebook
{
    [MBProgressHUD showHUDAddedTo:self.rootViewController.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shareWith:kFaceBookService];
        [MBProgressHUD hideHUDForView:self.rootViewController.view animated:YES];
    });
}
-(void)shareToTwitter
{
    [MBProgressHUD showHUDAddedTo:self.rootViewController.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shareWith:kTwitterServicce];
        [MBProgressHUD hideHUDForView:self.rootViewController.view animated:YES];
    });
}
-(void)shareToFlickr
{
    [MBProgressHUD showHUDAddedTo:self.rootViewController.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shareWith:kFlickrService];
        [MBProgressHUD hideHUDForView:self.rootViewController.view animated:YES];
    });
}
-(void)shareToTumblr
{
    [MBProgressHUD showHUDAddedTo:self.rootViewController.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shareWith:kTumblrService];
        [MBProgressHUD hideHUDForView:self.rootViewController.view animated:YES];
    });
}
-(void)shareViaEmail
{
    [MBProgressHUD showHUDAddedTo:self.rootViewController.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shareWith:kEmailService];
        [MBProgressHUD hideHUDForView:self.rootViewController.view animated:YES];
    });
}
-(void)shareViaInstagram
{
    if (![SHKInstagram canShare])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Install Instagram first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.rootViewController.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shareWith:kInstagramService];
        [MBProgressHUD hideHUDForView:self.rootViewController.view animated:YES];
    });
}
-(void)shareWith:(int)services
{
    UIImage* image = [self.rootViewController getShareImage];
    if (!image)
    {
        NSLog(@"No Image to share");
        return;
    }
    switch (services) {
        case kSaveAlbum: // save to album
            [SHKPhotoAlbum shareImage:image title:kShareTitle];
            break;
        case kFaceBookService: // facebook
            [SHKFacebook shareImage:image title:kShareTitle];
            break;
        case kTwitterServicce: // twitter
            [SHKTwitter shareImage:image title:kShareTitle];
            break;
        case kTumblrService:// tumblr
            [SHKTumblr shareImage:image title:kShareTitle];
            break;
        case kFlickrService: // flicker
            [SHKFlickr shareImage:image title:kShareTitle];
            break;
        case kEmailService: // email
            [SHKMail shareImage:image title:kShareTitle];
            break;
        case kInstagramService: //Instagram
            if ([SHKInstagram canShare]){
                [SHKInstagram shareImage:image title:kShareTitle];
            }else
            {
                NSLog(@"Can't share");
            }
        default:
            break;
    }
    [self.rootViewController hideShareView];
}
@end
