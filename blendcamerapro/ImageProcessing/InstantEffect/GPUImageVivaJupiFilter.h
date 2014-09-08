#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

@interface GPUImageVivaJupiFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
