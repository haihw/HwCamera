//
//  InAppPurchaseView.h
//  SewingXmasCard
//
//  Created by Hai Hw on 11/16/12.
//  Copyright (c) 2012 Applistar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPBlendHelper.h"
@class  ViewController;
@interface InAppPurchaseView : UIView <IAPHelperDelegate>
{
    UILabel *btnLabel;
}
@property (nonatomic, strong) NSArray *products;
//@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ViewController *rootViewController;
@property (nonatomic, strong) UIActivityIndicatorView *acIndicatorView;
-(void) active;
@end
