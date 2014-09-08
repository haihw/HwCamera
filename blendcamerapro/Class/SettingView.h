//
//  SettingView.h
//  iDarkRoomClone
//
//  Created by applistar1 on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;
@interface SettingView : UIView<UIWebViewDelegate>
{
    BOOL isSaveOriginal;
    UISegmentedControl *resolutionSegmentedControl;
    UIButton *btnLogoutFacebook;
    UILabel *labelFB;
    UIButton *btnLogoutTwitter;
    UILabel *labelTW;
    UIButton *btnLogoutFlickr;
    UILabel *labelFL;
    UIButton *btnLogoutTumblr;
    UILabel *labelTB;
    UISwitch *saveOriginalSwitch;
    UISwitch *blackAndWhiteCameraSwitch;
    
    UIScrollView * helpScrollView;
    UIWebView * helpPage;
    BOOL isHideHelp;
}
@property (nonatomic, retain)ViewController *rootViewController;
-(void)createGUI;
-(void)showGUI;
-(float)getOuputResolution; // resolution is defined as the largest demension of the output image
-(bool)shouldSaveOriginal;
@end
