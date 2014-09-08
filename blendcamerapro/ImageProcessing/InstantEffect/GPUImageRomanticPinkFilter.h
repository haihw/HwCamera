#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

// Note: If you want to use this effect you have to add lookup_pink_romantic_part1
//       from Resources folder to your application bundle.

@interface GPUImageRomanticPinkFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
