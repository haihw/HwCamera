#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

// Note: If you want to use this effect you have to add lookup_warm_forrest.png
//       from Resources folder to your application bundle.

@interface GPUImageWarmForrestFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
