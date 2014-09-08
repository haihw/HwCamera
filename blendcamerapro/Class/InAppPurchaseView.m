//
//  InAppPurchaseView.m
//  SewingXmasCard
//
//  Created by Hai Hw on 11/16/12.
//  Copyright (c) 2012 Applistar. All rights reserved.
//
#define kProductsLoadedNotification         @"ProductsLoaded"

#import "InAppPurchaseView.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "ViewController.h"
@interface InAppPurchaseView () {
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
    MBProgressHUD *_hud;

}
@end
@implementation InAppPurchaseView
@synthesize products = _products;
//@synthesize hud = _hud;
@synthesize acIndicatorView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *background = [[UIView alloc] initWithFrame:self.bounds];
        [background setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
        [self addSubview:background];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler)];
        [background addGestureRecognizer:tapGesture];
        
        
        int unlockH = 189;
        int unlockW = 288;
        CGRect buyRect = CGRectMake(155, 276, 70, 20);
        if ([UIScreen mainScreen].bounds.size.height > 480)
            buyRect = CGRectMake(155, 325, 70, 20);
//        int fontSize = 13;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            unlockH = 454;
            unlockW = 693;
            buyRect = CGRectMake(380, 605, 156, 46);
        }

        UIView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, unlockW, unlockH) ];
        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"InAppBg"]];
        bgView.center = self.center;
        [self addSubview:bgView];
        
        UIButton *buyBtn = [[UIButton alloc] initWithFrame:buyRect];
        [buyBtn addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [buyBtn setImage:[UIImage imageNamed:@"Bt_BuyOff"] forState:UIControlStateNormal];
        [buyBtn setImage:[UIImage imageNamed:@"Bt_BuyOn"] forState:UIControlStateHighlighted];
        [self addSubview:buyBtn];
        

    }
    return self;
}
-(void)tapHandler
{
    self.hidden = YES;
}

-(void)startIndicator
{
    NSLog(@"show startIndicator");
    acIndicatorView = [[UIActivityIndicatorView alloc]init];
    acIndicatorView.frame = self.frame;
    acIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    acIndicatorView.alpha  = 1.0;
    acIndicatorView.hidesWhenStopped = NO;
    acIndicatorView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    
    UILabel *newLabel = [[UILabel alloc]init];
    newLabel.bounds = CGRectMake(0, 0, 300, 300);
    newLabel.center = CGPointMake(acIndicatorView.center.x, acIndicatorView.center.y + 30);
    newLabel.text = @"Please wait ...";
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.textColor  = [UIColor blackColor];
    newLabel.shadowColor = [UIColor whiteColor];
    newLabel.backgroundColor = [UIColor clearColor];
    [acIndicatorView addSubview:newLabel];
    [acIndicatorView bringSubviewToFront:newLabel];
    
    [self.rootViewController.view addSubview:acIndicatorView];
    [acIndicatorView startAnimating];
}

- (IBAction)buyButtonTapped:(id)sender {
    self.hidden = YES;

    [self startIndicator];
    [IAPBlendHelper sharedInstance].delegate = self;
//    self.rootViewController.acIndicatorView = self.acIndicatorView;
    [[IAPBlendHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success && [products count]>0) {
            _products = products;
            SKProduct * product = products[0];
            NSLog(@"Buying %@...", product.productIdentifier);
            [[IAPBlendHelper sharedInstance] buyProduct:product];

        } else
        {
            [self.acIndicatorView stopAnimating];
            [self.acIndicatorView removeFromSuperview];
            self.acIndicatorView = nil;
            [self.rootViewController inAppPurchaseCompleteWithStatus:NO];
            NSLog(@"Connection Failed");
        }
    }];

}
- (IBAction)close:(id)sender
{
    self.hidden = YES;
}
- (void)active
{
    NSLog(@"Geting items from store...");
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        NSLog(@"No internet connection!");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Check the internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    } else {
        self.hidden = NO;
    }
}
-(void) timeout

{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Check the internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [self addSubview:alertView];

    NSLog(@"time out!");
}

#pragma mark - IAPHelperDelegate
-(void)InAppPurchaseDidSuccess{
    [self.acIndicatorView stopAnimating];
    [self.acIndicatorView removeFromSuperview];
    self.acIndicatorView = nil;

    [self.rootViewController inAppPurchaseCompleteWithStatus:YES];
}
-(void)InAppPurchaseDidFail
{
    [self.acIndicatorView stopAnimating];
    [self.acIndicatorView removeFromSuperview];
    self.acIndicatorView = nil;

    [self.rootViewController inAppPurchaseCompleteWithStatus:NO];
}
@end
