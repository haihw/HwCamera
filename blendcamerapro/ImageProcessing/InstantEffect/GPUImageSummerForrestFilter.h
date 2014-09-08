#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

// Note: If you want to use this effect you have to add lookup_summer_forrest.png
//       from Resources folder to your application bundle.

@interface GPUImageSummerForrestFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
