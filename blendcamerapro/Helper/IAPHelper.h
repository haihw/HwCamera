//
//  IAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);
@class ViewController;
@protocol IAPHelperDelegate <NSObject>
@optional
- (void) InAppPurchaseDidSuccess;
- (void) InAppPurchaseDidFail;

@end
@interface IAPHelper : NSObject
{
    __unsafe_unretained id <IAPHelperDelegate> _delegate;
}

@property (unsafe_unretained) id delegate;
@property (nonatomic, strong) NSSet * productIdentifiers;
@property (nonatomic, strong) NSMutableSet * purchasedProductIdentifiers;
@property (nonatomic, strong) ViewController *rootViewController;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
@end
