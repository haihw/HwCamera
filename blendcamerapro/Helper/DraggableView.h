//
//  DraggableView.h
//  Description : This class encapsulates the imageView inside the dragable view
//                Allow user close this view by click on topleft icon or moving or rotation by drag the
//                lowerRight icon.
//  Created by Dung NP on 8/9/12.
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "HWCustomUILabel.h"
@class SPGripViewBorderView, TextView;
@interface DraggableView : UIView <UIGestureRecognizerDelegate>
{
    CGAffineTransform preTransform;
    CGPoint preLocation; // previous touch location
    CGRect originalBounds;
    UIView * contentView; // sticker item of this view
    SPGripViewBorderView *borderView; // border of content view

    ViewController * parentController; // parent controller call this view
    
    BOOL isSelectedControlPoint;
//    CGRect limitedMovingRegion; // moving region of this dragable
    int minScaleHeightItem;
    int maxScaleHeightItem;
    
    BOOL isMoving;
    float currRotationAngle;
    int currRotationDirection;
    CGPoint center;
}
@property (nonatomic, assign) bool isTextContent;
@property (nonatomic, strong) HWCustomUILabel *label;
@property (nonatomic,strong) ViewController * parentController;
@property (nonatomic,assign) CGRect limitedMovingRegion; // moving region of this dragable

- (void)setContentView:(UIView *)newContentView;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (id)copy;
- (id)copyWithZone:(NSZone*)zone;

@end
