//
//  UtilityView.h
//  blendcamerapro
//
//  Created by Do Khanh Toan on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
/*
ther are 8 orientation state;
 0: up
 1: up mirror   (HF)
 2: down mirror (VF)
 3: down        (RR)
 4: right       (R)
 5: left mirror (R, VF)
 6: right mirror (L, VF)
 7: left        (L)
 
 int lookupTable[][4] = {
 {7, 4, 1, 2},
 {6, 5, 0, 3},
 {5, 6, 3, 0},
 {4, 7, 2, 1},
 {0, 3, 6, 5},
 {1, 2, 7, 4},
 {2, 1, 4, 7},
 {3, 0, 5, 6},
 };
 */

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class CropView;
@interface UtilityView : UIView
{
    ViewController * rootViewController;
    // GUI processing
    UIView * rotationMovingBar;
    UIView * cropMovingBar;
    int currentState;
    
    // GUI processing
    UIImageView * cropModeImgViewON; 
    UIImageView * cropModeImgViewOFF; 
    UIImageView * rotationModeImgViewOff;
    UIImageView * rotationModeImgViewOn;
    UIView * cropModeView; // right view button
    UIView * rotationModeView; // lelf view button
    
    // Current cropView
    CropView * currentCropView;
    // add cancel button
    UIButton * btnCancel;
    UIButton * btnApply;
    // preserver the preview image
    UIImage * previewImg;
    bool shouldCropFlag;
    
    // Show btn hightlight when click :
    //define Image
    
    UIImage *OffBGImg;
    UIImage *OnBGImg;
    UIImage* normalManualCropImg;
    UIImage* hightlightManualCropImg;
    UIImage* normalSquareCropImg;
    UIImage* hightlightSquareCropImg;
    UIImage* normalOriginalCropImg;
    UIImage* hightlightOriginalCropImg;
    UIImage* normal3x2CropImg;
    UIImage* hightlight3x2CropImg;
    UIImage* normal4x3CropImg;
    UIImage* hightlight4x3CropImg;
    UIImage* normal3x4CropImg;
    UIImage* hightlight3x4CropImg;
    UIImage* normal16x9CropImg;
    UIImage* hightlight16x9CropImg;
    UIImage* normalFacebookCropImg;
    UIImage* hightlightFacebookCropImg;
    
    // btn :
    UIButton *btnManualCrop;
    UIButton * btnSquareCrop;
    UIButton * btnOriginalCrop;
    UIButton * btn3x2Crop;
    UIButton * btn4x3Crop;
    UIButton * btn3x4Crop;
    UIButton * btn16x9Crop;
    UIButton * btnFacebookCrop;
}

@property (nonatomic,strong) ViewController * rootViewController;
@property (nonatomic, strong) UIButton * btnCancel;
@property (nonatomic, strong) UIButton * btnApply;
-(int)getCurrentState;
// Apply cropfilter to input image
-(UIImage *) applyCropFilterFor:(UIImage *) inputImage;
// Apply rotation for input image
-(UIImage *) applyRotationImageFor:(UIImage *) inputImage withStage:(int) stage;
// add 2 button Cancel and Apply
-(void) addCancelAndApplyButtonToRootController;
-(void)removeAll;
-(bool)shouldCrop;
-(bool)shouldRotate;
-(void)hideAll;
@end
