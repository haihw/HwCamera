#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

@interface GPUImageGreenFodderFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
