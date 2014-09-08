#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

@interface GPUImageMagentaLeavesFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
