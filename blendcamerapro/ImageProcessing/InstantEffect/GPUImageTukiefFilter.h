#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

@interface GPUImageTukiefFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
