#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

@interface GPUImageCityNightFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
