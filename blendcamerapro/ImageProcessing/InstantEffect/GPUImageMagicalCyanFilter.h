#import "GPUImageFilterGroup.h"

@class GPUImagePicture, GPUImageSharpenFilter, GPUImageAlphaBlendFilter;

// Note: If you want to use this effect you have to add lookup_cyan_forrest_1.png lookup_cyan_forrest_2.png
//       from Resources folder to your application bundle.

@interface GPUImageMagicalCyanFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource1;
    GPUImagePicture *lookupImageSource2;
    GPUImagePicture *linearGradientPic;
    GPUImagePicture *radialGradientPic;
    GPUImageAlphaBlendFilter *linearGradientBlendFilter;
    GPUImageAlphaBlendFilter *radialGradientBlendFilter;
    GPUImageSharpenFilter *sharpenFilter;
}
-(NSString*)getEffectName;
@end
