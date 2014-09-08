#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

@interface GPUImageColdWhiteFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
