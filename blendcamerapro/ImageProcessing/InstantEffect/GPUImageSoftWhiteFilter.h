#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

// Note: If you want to use this effect you have to add lookup_soft_white(no highpass 10px).png
//       from Resources folder to your application bundle.

@interface GPUImageSoftWhiteFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
