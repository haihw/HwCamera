//
//  SharingView.h
//  iDarkRoomClone
//
//  Created by applistar1 on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;
@interface SharingView : UIView
{
    ViewController* rootViewController;
}
@property (nonatomic, retain) ViewController* rootViewController;
-(void)createGUI;
@end
