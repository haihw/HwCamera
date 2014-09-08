//
//  HWInstantEffectView.h
//  imageprocessing
//
//  Created by Hai Hw on 8/13/12.
//
//

#import <UIKit/UIKit.h>

#import "HWEffectMenuView.h"
#import "GPUImage.h"
#import "HWInstantEffect.h"

typedef enum 
{
    menuViewStateMenuChoosing,
    menuViewStateParameterChanging,
    menuViewStateNone,
}MenuViewState;


@interface HWInstantEffectView : UIView
{
    HWEffectMenuView            *menuView;
    GPUImageView                *imageView;
    //for menuview
    CGPoint                     startLocationPanGesture;
    CGPoint                     previousLocationPanGesture;
    MenuViewState               menuState;
    UILabel                     *menuStatusLabel;
    
    NSArray                     *adjustmentLayersNames;
    NSMutableArray              *adjustmentLayerParameters;
    NSArray                     *defaultParameters;
    UIImage                     *processedImage;

    GPUImagePicture             *backgroundPic;
    GPUImagePicture             *sourcePic;
    GPUImageHueFilter           *hueFilter;
    GPUImageSaturationFilter    *saturationFilter;
    GPUImageBrightnessFilter    *brightnessFilter;
    GPUImageContrastFilter      *contrastFilter;
    GPUImageAlphaBlendFilter    *alphaFilter;

    UIImage *inputImage;
    GPUImageFilterGroup *filter;

 }

-(void)setFilter:(GPUImageFilterGroup *)newfilter andInputImage:(UIImage*)image;
-(void)changeParameterOfLayerHasIndex:(NSInteger)layerIndex withValue:(float)value;
-(void)processEffect;

-(float)getHue;
-(float)getSaturation;
-(float)getBrightness;
-(float)getContrast;
-(float)getOpacity;
@end
