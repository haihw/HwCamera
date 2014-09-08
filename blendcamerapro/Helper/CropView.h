//
//  CropView.h
//  blendcamerapro
//
//  Created by Do Khanh Toan on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

enum SelectedCropButton {
    TopLeft = 1,
    TopRight = 2,
    BottomLeft =3,
    BottomRight =4,
    };

@class CropGripViewBorderView,UtilityView;
@interface CropView : UIView
{
    CGPoint preLocation; // previous touch location
    UIView * contentView; // sticker item of this view
    CropGripViewBorderView *borderView; // border of content view    
    ViewController * parentController; // parent controller call this view
    UtilityView * utilityView;
    
    CGFloat minScaleWidthItem;
    CGFloat maxScaleWidthItem;
    
    BOOL  isSelectedControlPoint;
    enum  SelectedCropButton currSelectedButton;
    CGRect outlineRect;
    CGSize maxSize;
}
@property (nonatomic,strong) UtilityView * utilityView;
@property (nonatomic,strong) ViewController * parentController;
@property (nonatomic,assign) CGRect outlineRect;
@property (nonatomic,assign)  CGSize maxSize;
@property (nonatomic,assign) BOOL isCustomMode;
- (void)setContentView:(UIView *)newContentView;
//   get actuall crop rect
-(CGRect) getCropRectArea;
// get actault outline of image be croped
-(CGRect) getOutlineImageBeCropedImage;

@end
