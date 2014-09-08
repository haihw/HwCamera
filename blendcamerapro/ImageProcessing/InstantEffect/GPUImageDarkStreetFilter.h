#import "GPUImageFilterGroup.h"

@class GPUImagePicture;

@interface GPUImageDarkStreetFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
-(NSString*)getEffectName;
@end
