//
//  XmasCardIAP.m
//  SewingXmasCard
//
//  Created by Hai Hw on 11/16/12.
//  Copyright (c) 2012 Applistar. All rights reserved.
//

#import "IAPBlendHelper.h"

@implementation IAPBlendHelper

+ (IAPBlendHelper *)sharedInstance
{
    static dispatch_once_t once;
    static IAPBlendHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects: @"com.applistar.blendinstacameralite.fullpack",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}
@end
